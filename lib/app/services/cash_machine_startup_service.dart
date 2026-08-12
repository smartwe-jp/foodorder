import 'dart:async';
import 'dart:io';

import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/models/machine_capabilities.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer.dart';
import 'package:foodorder/app/plugins/cash_changer/lib/cash_changer_define.dart';
import 'package:logging/logging.dart';

enum CashMachineCheckFailure {
  unsupportedPlatform,
  disconnected,
  busy,
  timeout,
  unexpectedResponse,
  unknown,
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

class CashMachineStartupService {
  CashMachineStartupService({required AppConfig appConfig})
      : _appConfig = appConfig;

  final AppConfig _appConfig;
  final Logger _logger = Logger('CashMachineStartupService');

  Future<CashMachineCheckResult> check(CashMachineDriver driver) async {
    try {
      return await switch (driver) {
        CashMachineDriver.payCube => _checkPayCube(),
        CashMachineDriver.cashChanger => _checkCashChanger(),
        CashMachineDriver.none => const CashMachineCheckResult.ready(),
      };
    } on TimeoutException {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.timeout,
      );
    } catch (error, stackTrace) {
      _logger.warning('Cash machine startup check failed', error, stackTrace);
      return CashMachineCheckResult.failed(
        CashMachineCheckFailure.unknown,
        detail: error.toString(),
      );
    }
  }

  Future<CashMachineCheckResult> _checkPayCube() async {
    if (!Platform.isAndroid) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.unsupportedPlatform,
      );
    }

    final payCube = _appConfig.payCube;
    final status =
        await payCube.CheckPayCubeStatus.timeout(const Duration(seconds: 10));
    if (status == 'openSuccess') {
      return const CashMachineCheckResult.ready();
    }
    if (status != 'openError') {
      return CashMachineCheckResult.failed(
        CashMachineCheckFailure.unexpectedResponse,
        detail: status.toString(),
      );
    }

    for (var attempt = 0; attempt < 3; attempt++) {
      final openStatus =
          await payCube.openPayCube.timeout(const Duration(seconds: 10));
      if (openStatus == 'openSuccess') {
        return const CashMachineCheckResult.ready();
      }
    }
    return const CashMachineCheckResult.failed(
      CashMachineCheckFailure.disconnected,
    );
  }

  Future<CashMachineCheckResult> _checkCashChanger() async {
    if (!Platform.isWindows) {
      return const CashMachineCheckResult.failed(
        CashMachineCheckFailure.unsupportedPlatform,
      );
    }

    for (var attempt = 0; attempt < 3; attempt++) {
      var resultCode = await CashChanger.checkChangerStatus
          .timeout(const Duration(seconds: 10));
      if (resultCode == null) {
        return const CashMachineCheckResult.failed(
          CashMachineCheckFailure.disconnected,
        );
      }
      if (resultCode == 0) resultCode = 100;

      final result = HealthResultCode.values.fromIndex(resultCode - 100);
      if (result == null) {
        return CashMachineCheckResult.failed(
          CashMachineCheckFailure.unexpectedResponse,
          detail: resultCode.toString(),
        );
      }

      switch (result) {
        case HealthResultCode.OPOS_SUCCESS:
        case HealthResultCode.OPOS_E_ILLEGAL:
          return const CashMachineCheckResult.ready();
        case HealthResultCode.OPOS_E_CLOSED:
        case HealthResultCode.OPOS_E_NOTCLAIMED:
        case HealthResultCode.OPOS_E_DISABLED:
          return _openCashChanger();
        case HealthResultCode.OPOS_E_BUSY:
          if (attempt < 2) {
            await Future<void>.delayed(const Duration(seconds: 2));
            continue;
          }
          return const CashMachineCheckResult.failed(
            CashMachineCheckFailure.busy,
          );
        default:
          return CashMachineCheckResult.failed(
            CashMachineCheckFailure.disconnected,
            detail: result.name,
          );
      }
    }

    return const CashMachineCheckResult.failed(
      CashMachineCheckFailure.busy,
    );
  }

  Future<CashMachineCheckResult> _openCashChanger() async {
    var opened = false;
    await CashChanger.openCashChanger(
      onSuccess: () {
        opened = true;
      },
      catchError: (retCode, error) {
        // OPOS 225 means the device is already open.
        opened = retCode == 225;
        if (!opened) {
          _logger.warning('openCashChanger failed: $retCode, $error');
        }
      },
    ).timeout(const Duration(seconds: 15));

    return opened
        ? const CashMachineCheckResult.ready()
        : const CashMachineCheckResult.failed(
            CashMachineCheckFailure.disconnected,
          );
  }
}
