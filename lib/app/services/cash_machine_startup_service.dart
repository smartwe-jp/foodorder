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
import 'package:foodorder/app/services/scale_serial_service.dart';
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

    await ScaleSerialService.releaseUsbSafely(
      reason: 'cash_machine_startup',
    );
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

    if (mode == CashMachineCheckMode.startupRecovery) {
      return _LegacyCashChangerStartup(onStep).run();
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
        final openCode = await _openCashChanger(mode);
        if (openCode == null) {
          return const CashMachineCheckResult.failed(
            CashMachineCheckFailure.disconnected,
            detail: 'CashChanger open failed',
          );
        }

        await _delayForCashChangerRecovery(mode);
        // The established 225 path checks the pending amount directly.
        if (openCode != 225 || mode == CashMachineCheckMode.singlePass) {
          onStep?.call(CashMachineStartupStep.startingDeposit);
          if (!await _startCashChangerDeposit(mode)) {
            return const CashMachineCheckResult.failed(
              CashMachineCheckFailure.recoveryFailed,
              detail: 'CashChanger deposit start failed',
            );
          }
          await _delayForCashChangerRecovery(mode);
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

    await _delayForCashChangerRecovery(mode);
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

    await _delayForCashChangerRecovery(mode);
    onStep?.call(CashMachineStartupStep.applyingSettings);
    final sswResult = await CashChanger.setSixDigitDispenseAmount()
        .timeout(_timeoutFor(mode));
    final sswOposResult = CashChanger.getOposResult(sswResult) as OposResult;
    if (sswOposResult.resultCode != HealthResultCode.OPOS_SUCCESS) {
      _logger.warning(
        'CashChanger bill SSW 24 setting failed: $sswResult',
      );
      return CashMachineCheckResult.failed(
        CashMachineCheckFailure.recoveryFailed,
        detail: 'CashChanger bill SSW 24 setting failed: $sswResult',
      );
    }

    onStep?.call(CashMachineStartupStep.readingBalance);
    if (!await _readCashChangerBalance(mode)) {
      // The field-proven flow records the balance error but still completes
      // bootstrap after the repay/end-deposit operation has succeeded.
      _logger.warning('CashChanger balance read failed after recovery');
    }

    onStep?.call(CashMachineStartupStep.completed);
    return const CashMachineCheckResult.ready();
  }

  Future<HealthResultCode> _waitForCashChangerHealth(
    CashMachineCheckMode mode,
  ) async {
    while (true) {
      var code = await CashChanger.checkChangerStatus
          .timeout(const Duration(seconds: 10));
      if (code == null) {
        if (mode == CashMachineCheckMode.singlePass) return HealthResultCode.NONE;
        await Future<void>.delayed(const Duration(seconds: 5));
        continue;
      }
      if (code == 0) code = 100;
      final result = HealthResultCode.values.fromIndex(code - 100) ??
          HealthResultCode.NONE;
      if (result != HealthResultCode.OPOS_E_BUSY) return result;
      if (mode == CashMachineCheckMode.singlePass) return result;
      await Future<void>.delayed(const Duration(seconds: 5));
    }
  }

  Future<int?> _openCashChanger(CashMachineCheckMode mode) async {
    final deadline = DateTime.now().add(_stepTimeout);
    while (DateTime.now().isBefore(deadline)) {
      final result = await CashChangerPlatform.instance
          .openCashChanger()
          .timeout(const Duration(seconds: 15));
      final code = result?['code'];
      // 0: opened, 301: OPOS already open. 225 is retained for compatibility
      // with existing field installations that report the legacy value.
      if (code == 0 || code == 301 || code == 225) return code as int;
      if (mode == CashMachineCheckMode.singlePass) return null;
      await _delayForCashChangerRecovery(mode);
    }
    return null;
  }

  Future<void> _delayForCashChangerRecovery(CashMachineCheckMode mode) async {
    if (mode == CashMachineCheckMode.startupRecovery) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<bool> _startCashChangerDeposit(CashMachineCheckMode mode) async {
    final deadline = DateTime.now().add(_stepTimeout);
    while (mode == CashMachineCheckMode.startupRecovery ||
        DateTime.now().isBefore(deadline)) {
      final result = await CashChangerPlatform.instance
          .startDeposit()
          .timeout(const Duration(seconds: 15));
      final oposResult =
          CashChanger.getOposResult(result?['code']) as OposResult;
      if (oposResult.resultCode == HealthResultCode.OPOS_SUCCESS) return true;
      if (mode == CashMachineCheckMode.singlePass) return false;
      if (!await _recoverInterfaceError(oposResult)) return false;
      await _delayForCashChangerRecovery(mode);
    }
    return false;
  }

  Future<bool> _waitForChangerCommand(
    Future<int?> Function() command,
    CashMachineCheckMode mode,
  ) async {
    final deadline = DateTime.now().add(_stepTimeout);
    while (mode == CashMachineCheckMode.startupRecovery ||
        DateTime.now().isBefore(deadline)) {
      final code = await command().timeout(const Duration(seconds: 15));
      final result = CashChanger.getOposResult(code) as OposResult;
      if (result.resultCode == HealthResultCode.OPOS_SUCCESS) return true;
      if (mode == CashMachineCheckMode.singlePass) return false;
      if (!await _recoverInterfaceError(result)) return false;
      await _delayForCashChangerRecovery(mode);
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
    while (mode == CashMachineCheckMode.startupRecovery ||
        DateTime.now().isBefore(deadline)) {
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
      await _delayForCashChangerRecovery(mode);
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

// Startup follows HomeControllerExtension before the 3.0 migration, including
// its callback sequencing, with a one-minute watchdog and no fake close step.
// Payment checks use the separate flow.
class _LegacyCashChangerStartup {
  _LegacyCashChangerStartup(this.onStep);

  final CashMachineStepCallback? onStep;
  final logger = Logger('LegacyCashChangerStartup');
  final _completion = Completer<CashMachineCheckResult>();
  Timer? _watchdog;
  int _depositAttempts = 0;

  Future<CashMachineCheckResult> run() async {
    // One deadline for the entire startup, not a timeout reset per step.
    _watchdog = Timer(const Duration(minutes: 1), () {
      fail(CashMachineCheckFailure.timeout,
          'Legacy CashChanger startup did not complete within one minute');
    });
    try {
      unawaited(checkChangerStatus().catchError((Object error, StackTrace stack) {
        logger.warning('Legacy CashChanger startup failed', error, stack);
      }));
      return await _completion.future;
    } finally {
      _watchdog?.cancel();
    }
  }

  void fail(CashMachineCheckFailure failure, String detail) {
    if (!_completion.isCompleted) {
      _completion.complete(CashMachineCheckResult.failed(
        failure,
        detail: detail,
      ));
    }
  }

  void complete() {
    if (_completion.isCompleted) return;
    onStep?.call(CashMachineStartupStep.completed);
    if (!_completion.isCompleted) {
      _completion.complete(const CashMachineCheckResult.ready());
    }
  }

  //打开之前 检查状态

  Future<void> checkChangerStatus() async {
    if (_completion.isCompleted) return;
    debugPrint("checkChangerStatus 1");
    logger.info('-- checkChangerStatus --');
    onStep?.call(CashMachineStartupStep.checkingStatus);

    int? resultCode = await CashChanger.checkChangerStatus;
    if (_completion.isCompleted) return;
    logger.info('-- checkChangerStatus : $resultCode --');
    debugPrint("checkChangerStatus resultCode:  " + resultCode.toString());
    if (resultCode == null) {
      debugPrint("Unknown error");
      checkChangerStatus();
      return;
    }
    if (resultCode == 0) {
      resultCode = 100;
    }
    final resultCodeEnum = HealthResultCode.values.fromIndex(resultCode - 100) ??
        HealthResultCode.NONE;
    debugPrint(
        "checkChangerStatus resultCodeEnum:  " + resultCodeEnum.toString());
    switch (resultCodeEnum) {
      case HealthResultCode.OPOS_SUCCESS:
      case HealthResultCode.OPOS_E_ILLEGAL:
        await stopCashChanger(DepositAction.repay.index, true);
        break;
      case HealthResultCode.OPOS_E_CLOSED:
      case HealthResultCode.OPOS_E_NOTCLAIMED:
      case HealthResultCode.OPOS_E_DISABLED:
        await openCashChanger();
        break;
      case HealthResultCode.OPOS_E_BUSY:
        await Future.delayed(Duration(seconds: 5));
        await checkChangerStatus();
        break;
      case HealthResultCode.OPOS_E_NOHARDWARE:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
      default:
        debugPrint("checkChangerStatus error: $resultCode");
        break;
    }
  }

  //现金机开始 打开现金机，准备开始投币
  openCashChanger() async {
    if (_completion.isCompleted) return;
    debugPrint("OpenPayCube 1");
    onStep?.call(CashMachineStartupStep.opening);
    //如果检测现金机打开错误，则重新打开一下
    logger.info('-- openCashChanger --');
    await CashChanger.openCashChanger(
      onSuccess: () async {
        debugPrint("OpenPayCube 6");
        logger.info('-- openCashChanger success --');
        await Future.delayed(Duration(milliseconds: 200));
        startDeposit();
      },
      catchError: (retCode, error) async {
        debugPrint("OpenPayCube error: $error");
        logger.info('-- openCashChanger error: $error --');
        if (retCode == 225) {
          //已打开 // clearinput?
          _calculateAmount();
        }
      },
    );
  }

  //现金机开始 打开现金机，准备开始投币
  Future<void> startDeposit() async {
    if (_completion.isCompleted) return;
    if (_depositAttempts >= 5) {
      fail(CashMachineCheckFailure.recoveryFailed,
          'Legacy CashChanger deposit start reached five attempts');
      return;
    }
    _depositAttempts++;
    onStep?.call(CashMachineStartupStep.startingDeposit);
    logger.info('-- startDeposit attempt $_depositAttempts/5 --');
    // Same command and result callbacks as CashChanger.startDeposit, with the
    // retry callback owned here so the startup attempt limit is effective.
    final result = await CashChangerPlatform.instance.startDeposit();
    if (_completion.isCompleted) return;
    await CashChanger.changerResultNext(
      resultCode: result?['code'],
      onSuccess: () async {
        logger.info('-- startDeposit success --');
        await Future<void>.delayed(const Duration(milliseconds: 200));
        _calculateAmount();
      },
      onRetry: () async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        await startDeposit();
      },
      showError: (String error) {
        logger.info('-- startDeposit error: $error --');
      },
    );
  }

  //计算投币金额
  void _calculateAmount() async {
    if (_completion.isCompleted) return;
    debugPrint("CalculateAmount 1");
    onStep?.call(CashMachineStartupStep.checkingDepositAmount);
    logger.info('-- calculateAmount --');
    //int connectCount = 0;
    //计算投币金额
    final result = await CashChanger.depositAmount;
    if (_completion.isCompleted) return;
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () async {
          debugPrint("CalculateAmount 2");
          logger.info('-- depositAmount success --');
          await Future.delayed(Duration(milliseconds: 200));
          stopCashChanger(DepositAction.repay.index, true);
        },
        onRetry: () async {
          debugPrint("CalculateAmount 3");
          await Future<void>.delayed(Duration(milliseconds: 200));
          _calculateAmount();
        },
        showError: (String error) {
          logger.info('-- depositAmount error: $error --');
          stopCashChanger(DepositAction.repay.index, true);
          debugPrint("CalculateAmount error: $error");
        });
  }

  stopCashChanger(action, next) async {
    if (_completion.isCompleted) return;
    debugPrint("stopPaycube 1");
    onStep?.call(CashMachineStartupStep.endingDeposit);
    logger.info('-- stopCashChanger --');
    int? result = await CashChanger.endDeposit(action);
    if (_completion.isCompleted) return;
    await CashChanger.changerResultNext(
        resultCode: result,
        onSuccess: () async {
          debugPrint("stopPaycube 3");
          logger.info('-- stopCashChanger success --');
          await Future.delayed(Duration(milliseconds: 200));
          if (next) {
            getMachineCashInfo();
          }
        },
        onRetry: () async {
          debugPrint("stopPaycube 4");
          await Future.delayed(Duration(milliseconds: 200));
          stopCashChanger(action, true);
        },
        showError: (String error) async {
          logger.info('-- stopCashChanger error: $error --');
          debugPrint("stopCashChanger error: $error");
        });
  }

  Future<void> getMachineCashInfo() async {
    if (_completion.isCompleted) return;
    debugPrint("getMachineCashInfo 0");
    onStep?.call(CashMachineStartupStep.readingBalance);
    logger.info('-- getMachineCashInfo --');
    await CashChanger.getCashBalance(
      onSuccess: (value) {
        logger.info('-- getMachineCashInfo : $value --');
      },
      catchError: (error) {
        debugPrint("getMachineCashInfo error: $error");
        logger.info('-- getMachineCashInfo error: $error --');
      },
    );
    complete();
  }

}
