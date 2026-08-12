import 'dart:async';
import 'dart:io';

import 'package:cash_changer/cash_changer_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/models/machine_capabilities.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/machine_runtime_service.dart';
import 'package:logging/logging.dart';

enum CashMachineStartupStep {
  checkingStatus,
  opening,
  startingDeposit,
  checkingDepositAmount,
  endingDeposit,
  readingBalance,
  endingTrade,
  applyingSettings,
  completed,
}

enum CashMachineCheckFailure {
  unsupportedPlatform,
  disconnected,
  busy,
  timeout,
  unexpectedResponse,
  recoveryFailed,
  unknown,
}

enum CashMachineCheckMode {
  startupRecovery,
  singlePass,
}

class CashMachineCheckResult {
  const CashMachineCheckResult._({
    required this.isReady,
    this.failure,
    this.detail = '',
  });

  const CashMachineCheckResult.ready() : this._(isReady: true);

  const CashMachineCheckResult.failed(
    CashMachineCheckFailure failure, {
    String detail = '',
  }) : this._(isReady: false, failure: failure, detail: detail);

  final bool isReady;
  final CashMachineCheckFailure? failure;
  final String detail;
}

typedef CashMachineStepCallback = void Function(CashMachineStartupStep step);

class CashMachineStartupService {
  CashMachineStartupService({
    required AppConfig appConfig,
    required MachineRuntimeService runtime,
  })  : _appConfig = appConfig,
        _runtime = runtime;

  static const _stepTimeout = Duration(seconds: 60);
  static const _singlePassTimeout = Duration(seconds: 15);
  static const _retryDelay = Duration(milliseconds: 500);

  final AppConfig _appConfig;
  final MachineRuntimeService _runtime;
  final Logger _logger = Logger('CashMachineStartupService');

  Future<CashMachineCheckResult> checkForPayment({bool force = false}) async {
    if (!_runtime.shouldCheckCashMachine) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.unsupportedPlatform,
      );
    }
    if (!force && _runtime.cashPaymentAvailable) {
      return const CashMachineCheckResult.ready();
    }
    if (_runtime.cashMachineStatus == CashMachineRuntimeStatus.checking) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.busy,
      );
    }

    _runtime.markCashMachineChecking();
    final result = await check(
      _runtime.capabilities.cashMachineDriver,
      machineCode: _runtime.machineCode,
      mode: CashMachineCheckMode.singlePass,
    );
    if (!result.isReady) {
      _runtime.markCashMachineFailed();
      return result;
    }

    await _applyPayCubeSettings();
    _runtime.markCashMachineReady();
    return result;
  }

  Future<void> _applyPayCubeSettings() async {
    final allowOneYen = _runtime.systemSettings['isAllowOneyen'] ??
        _runtime.systemSettings['isAllowOneYen'] ??
        '0';
    if (_runtime.capabilities.cashMachineDriver != CashMachineDriver.payCube ||
        allowOneYen != '0') {
      return;
    }
    try {
      await _appConfig.payCube.prohibitOneCash
          .timeout(const Duration(seconds: 10));
    } catch (error, stackTrace) {
      _logger.warning('Failed to apply one-yen setting', error, stackTrace);
    }
  }

  Future<CashMachineCheckResult> check(
    CashMachineDriver driver, {
    required String machineCode,
    CashMachineStepCallback? onStep,
    CashMachineCheckMode mode = CashMachineCheckMode.startupRecovery,
  }) async {
    try {
      final result = await switch (driver) {
        CashMachineDriver.payCube => _runPayCubeRecovery(onStep, mode),
        CashMachineDriver.cashChanger => _runCashChangerRecovery(onStep, mode),
        CashMachineDriver.none =>
          Future.value(const CashMachineCheckResult.ready()),
      };
      if (!result.isReady) await _notifyFailure(machineCode);
      return result;
    } on TimeoutException catch (error, stackTrace) {
      _logger.warning(
          'Cash machine startup recovery timed out', error, stackTrace);
      await _notifyFailure(machineCode);
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.timeout,
      );
    } catch (error, stackTrace) {
      _logger.warning(
          'Cash machine startup recovery failed', error, stackTrace);
      await _notifyFailure(machineCode);
      return CashMachineCheckResult.failed(
        CashMachineCheckFailure.unknown,
        detail: error.toString(),
      );
    }
  }

  /// PayCube startup recovery keeps the established field sequence:
  /// status -> open (when needed) -> deposit start -> deposit end -> trade end.
  Future<CashMachineCheckResult> _runPayCubeRecovery(
    CashMachineStepCallback? onStep,
    CashMachineCheckMode mode,
  ) async {
    if (!Platform.isAndroid) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.unsupportedPlatform,
      );
    }

    final payCube = _appConfig.payCube;
    final timeout = _timeoutFor(mode);
    onStep?.call(CashMachineStartupStep.checkingStatus);
    final status = await payCube.CheckPayCubeStatus.timeout(timeout);

    if (status == 'openError') {
      onStep?.call(CashMachineStartupStep.opening);
      var opened = false;
      final maxAttempts = mode == CashMachineCheckMode.startupRecovery ? 2 : 1;
      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final openStatus = await payCube.openPayCube.timeout(timeout);
        if (openStatus == 'openSuccess') {
          opened = true;
          break;
        }
        if (attempt + 1 < maxAttempts) {
          await Future<void>.delayed(_retryDelay);
        }
      }
      if (!opened) {
        return CashMachineCheckResult.failed(
          CashMachineCheckFailure.disconnected,
          detail: 'PayCube open failed after $maxAttempts attempt(s)',
        );
      }
    } else if (status != 'openSuccess') {
      return CashMachineCheckResult.failed(
        CashMachineCheckFailure.unexpectedResponse,
        detail: status.toString(),
      );
    }

    // Starting and immediately ending a deposit restores a device left in an
    // unfinished transaction after power loss or an application crash.
    onStep?.call(CashMachineStartupStep.startingDeposit);
    await _delayForRecovery(mode);
    final started = await payCube
        .startPayCube(onSuccess: () {}, catchError: (_) {})
        .timeout(timeout);
    if (started != true) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.recoveryFailed,
        detail: 'PayCube deposit start failed',
      );
    }

    onStep?.call(CashMachineStartupStep.endingDeposit);
    await _delayForRecovery(mode);
    final ended = await payCube
        .endPayCube(onSuccess: () {}, catchError: (_) {})
        .timeout(timeout);
    if (ended != true) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.recoveryFailed,
        detail: 'PayCube deposit end failed',
      );
    }

    onStep?.call(CashMachineStartupStep.endingTrade);
    await _delayForRecovery(mode);
    final tradeEnded = await payCube
        .endTrade(onSuccess: () {}, catchError: (_) {})
        .timeout(timeout);
    if (tradeEnded != true) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.recoveryFailed,
        detail: 'PayCube trade end failed',
      );
    }

    onStep?.call(CashMachineStartupStep.completed);
    return const CashMachineCheckResult.ready();
  }

  /// CashChanger uses its OPOS recovery sequence. It must not be replaced by
  /// the PayCube flow because the device has separate deposit, repay and
  /// balance APIs.
  Future<CashMachineCheckResult> _runCashChangerRecovery(
    CashMachineStepCallback? onStep,
    CashMachineCheckMode mode,
  ) async {
    if (!Platform.isWindows) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.unsupportedPlatform,
      );
    }

    onStep?.call(CashMachineStartupStep.checkingStatus);
    final health = await _waitForCashChangerHealth(mode);
    switch (health) {
      case HealthResultCode.OPOS_SUCCESS:
      case HealthResultCode.OPOS_E_ILLEGAL:
        // The established flow repays/ends any transaction that was left open.
        break;
      case HealthResultCode.OPOS_E_CLOSED:
      case HealthResultCode.OPOS_E_NOTCLAIMED:
      case HealthResultCode.OPOS_E_DISABLED:
        onStep?.call(CashMachineStartupStep.opening);
        if (!await _openCashChanger(mode)) {
          return const CashMachineCheckResult.failed(
            CashMachineCheckFailure.disconnected,
            detail: 'CashChanger open failed',
          );
        }

        onStep?.call(CashMachineStartupStep.startingDeposit);
        if (!await _startCashChangerDeposit(mode)) {
          return const CashMachineCheckResult.failed(
            CashMachineCheckFailure.recoveryFailed,
            detail: 'CashChanger deposit start failed',
          );
        }

        onStep?.call(CashMachineStartupStep.checkingDepositAmount);
        final depositAmountChecked = await _waitForChangerCommand(
          () => CashChanger.depositAmount,
          mode,
        );
        if (!depositAmountChecked) {
          _logger.warning(
            'CashChanger deposit amount failed; continuing with repay',
          );
        }
        break;
      case HealthResultCode.OPOS_E_BUSY:
        return const CashMachineCheckResult.failed(
          CashMachineCheckFailure.busy,
        );
      default:
        return CashMachineCheckResult.failed(
          CashMachineCheckFailure.disconnected,
          detail: health.name,
        );
    }

    onStep?.call(CashMachineStartupStep.endingDeposit);
    if (!await _waitForChangerCommand(
      () => CashChanger.endDeposit(DepositAction.repay.index),
      mode,
    )) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.recoveryFailed,
        detail: 'CashChanger repay/end deposit failed',
      );
    }

    onStep?.call(CashMachineStartupStep.readingBalance);
    if (!await _readCashChangerBalance(mode)) {
      // The field-proven flow records the balance error but still completes
      // bootstrap after the repay/end-deposit operation has succeeded.
      _logger.warning('CashChanger balance read failed after recovery');
    }

    // The original startup flow intentionally keeps the OPOS device open for
    // settlement. "closeCashChanger" only completed bootstrap navigation.
    onStep?.call(CashMachineStartupStep.completed);
    return const CashMachineCheckResult.ready();
  }

  Future<HealthResultCode> _waitForCashChangerHealth(
    CashMachineCheckMode mode,
  ) async {
    final deadline = DateTime.now().add(_stepTimeout);
    while (DateTime.now().isBefore(deadline)) {
      var code = await CashChanger.checkChangerStatus
          .timeout(const Duration(seconds: 10));
      if (code == null) return HealthResultCode.NONE;
      if (code == 0) code = 100;
      final result = HealthResultCode.values.fromIndex(code - 100) ??
          HealthResultCode.NONE;
      if (result != HealthResultCode.OPOS_E_BUSY) return result;
      if (mode == CashMachineCheckMode.singlePass) return result;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    return HealthResultCode.OPOS_E_BUSY;
  }

  Future<bool> _openCashChanger(CashMachineCheckMode mode) async {
    final deadline = DateTime.now().add(_stepTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final result = await CashChangerPlatform.instance
          .openCashChanger()
          .timeout(const Duration(seconds: 15));
      final code = result?['code'];
      // 0: opened, 301: OPOS already open. 225 is retained for compatibility
      // with existing field installations that report the legacy value.
      if (code == 0 || code == 301 || code == 225) return true;
      if (mode == CashMachineCheckMode.singlePass) return false;
      await Future<void>.delayed(_retryDelay);
    }
    return false;
  }

  Future<bool> _startCashChangerDeposit(CashMachineCheckMode mode) async {
    final deadline = DateTime.now().add(_stepTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final result = await CashChangerPlatform.instance
          .startDeposit()
          .timeout(const Duration(seconds: 15));
      final oposResult =
          CashChanger.getOposResult(result?['code']) as OposResult;
      if (oposResult.resultCode == HealthResultCode.OPOS_SUCCESS) return true;
      if (mode == CashMachineCheckMode.singlePass) return false;
      if (!await _recoverInterfaceError(oposResult)) return false;
      await Future<void>.delayed(_retryDelay);
    }
    return false;
  }

  Future<bool> _waitForChangerCommand(
    Future<int?> Function() command,
    CashMachineCheckMode mode,
  ) async {
    final deadline = DateTime.now().add(_stepTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final code = await command().timeout(const Duration(seconds: 15));
      final result = CashChanger.getOposResult(code) as OposResult;
      if (result.resultCode == HealthResultCode.OPOS_SUCCESS) return true;
      if (mode == CashMachineCheckMode.singlePass) return false;
      if (!await _recoverInterfaceError(result)) return false;
      await Future<void>.delayed(_retryDelay);
    }
    return false;
  }

  Future<bool> _recoverInterfaceError(OposResult result) async {
    if (result.resultCode != HealthResultCode.OPOS_E_EXTENDED ||
        result.resultCodeExtended != ResultCodeExtended.OPOS_ECHAN_IFERROR) {
      return false;
    }

    // This is the recovery prescribed by the existing CashChanger helper:
    // repay/end the stale deposit first, then retry the interrupted command.
    final recoveryCode = await CashChanger.endDeposit(DepositAction.repay.index)
        .timeout(const Duration(seconds: 15));
    final recoveryResult =
        CashChanger.getOposResult(recoveryCode) as OposResult;
    return recoveryResult.resultCode == HealthResultCode.OPOS_SUCCESS;
  }

  Future<bool> _readCashChangerBalance(CashMachineCheckMode mode) async {
    final deadline = DateTime.now().add(_stepTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final result = await CashChangerPlatform.instance
          .getCashBalance()
          .timeout(const Duration(seconds: 15));
      final oposResult =
          CashChanger.getOposResult(result?['code']) as OposResult;
      if (oposResult.resultCode == HealthResultCode.OPOS_SUCCESS) {
        _logger.info('CashChanger balance: ${result?['value'] ?? ''}');
        return true;
      }
      if (mode == CashMachineCheckMode.singlePass) return false;
      if (!await _recoverInterfaceError(oposResult)) return false;
      await Future<void>.delayed(_retryDelay);
    }
    return false;
  }

  Duration _timeoutFor(CashMachineCheckMode mode) =>
      mode == CashMachineCheckMode.startupRecovery
          ? _stepTimeout
          : _singlePassTimeout;

  Future<void> _delayForRecovery(CashMachineCheckMode mode) async {
    if (mode == CashMachineCheckMode.startupRecovery) {
      await Future<void>.delayed(_retryDelay);
    }
  }

  Future<void> _notifyFailure(String machineCode) async {
    if (kDebugMode || machineCode.isEmpty) return;
    try {
      final response = await request(
        'webBootTroubleNotify',
        method: 'POST',
        parameters: {'machineCode': machineCode},
        timeout: const Duration(seconds: 10),
      );
      _logger.info('webBootTroubleNotify: $response');
    } catch (error, stackTrace) {
      _logger.warning('webBootTroubleNotify failed', error, stackTrace);
    }
  }
}
