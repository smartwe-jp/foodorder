import 'dart:async';

import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/models/machine_capabilities.dart';
import 'package:foodorder/app/routes/app_pages.dart';
import 'package:foodorder/app/services/cash_machine_startup_service.dart';
import 'package:foodorder/app/services/machine_runtime_service.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';

class CashMachineCheckController extends GetxController {
  final MachineRuntimeService _runtime = Get.find();
  final CashMachineStartupService _startupService = Get.find();
  final AppConfig _appConfig = Get.find();
  final Logger _logger = Logger('CashMachineCheckController');

  final RxBool isChecking = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<CashMachineStartupStep> currentStep =
      CashMachineStartupStep.checkingStatus.obs;
  bool _navigated = false;

  String get machineModelCode => _runtime.machineModelCode;

  String get driverName => switch (_runtime.capabilities.cashMachineDriver) {
        CashMachineDriver.payCube => 'PayCube',
        CashMachineDriver.cashChanger => 'CashChanger',
        CashMachineDriver.none => '-',
      };

  String get stepTitle => switch (currentStep.value) {
        CashMachineStartupStep.checkingStatus => '現金機の状態を確認しています',
        CashMachineStartupStep.opening => '現金機を開いています',
        CashMachineStartupStep.startingDeposit => '入金処理を開始しています',
        CashMachineStartupStep.checkingDepositAmount => '残留現金を確認しています',
        CashMachineStartupStep.endingDeposit => '残留取引を返金・終了しています',
        CashMachineStartupStep.readingBalance => '現金機の残高を確認しています',
        CashMachineStartupStep.endingTrade => '取引を終了しています',
        CashMachineStartupStep.applyingSettings => '現金機の設定を反映しています',
        CashMachineStartupStep.completed => '現金機の確認が完了しました',
      };

  @override
  void onReady() {
    super.onReady();
    check();
  }

  Future<void> check() async {
    if (isChecking.value || _navigated) return;

    isChecking.value = true;
    errorMessage.value = '';
    _runtime.markCashMachineChecking();

    final result = await _startupService.check(
      _runtime.capabilities.cashMachineDriver,
      machineCode: _runtime.machineCode,
      onStep: (step) {
        if (!isClosed) currentStep.value = step;
      },
    );
    if (isClosed || _navigated) return;

    if (result.isReady) {
      _runtime.markCashMachineReady();
      currentStep.value = CashMachineStartupStep.applyingSettings;
      await _applyCashSettings();
      currentStep.value = CashMachineStartupStep.completed;
      _refreshMachineInfo();
      _goNext();
      return;
    }

    _runtime.markCashMachineFailed();
    errorMessage.value = _messageFor(result);
    isChecking.value = false;
  }

  void ignore() {
    if (_navigated) return;
    _runtime.markCashMachineIgnored();
    _refreshMachineInfo();
    _goNext();
  }

  Future<void> _applyCashSettings() async {
    if (_runtime.capabilities.cashMachineDriver != CashMachineDriver.payCube) {
      return;
    }
    if (!Get.isRegistered<MachineInfoController>() ||
        Get.find<MachineInfoController>().is_allow_oneyen != '0') {
      return;
    }
    try {
      await _appConfig.payCube.prohibitOneCash
          .timeout(const Duration(seconds: 10));
    } catch (error, stackTrace) {
      _logger.warning('Failed to apply one-yen setting', error, stackTrace);
    }
  }

  void _refreshMachineInfo() {
    if (Get.isRegistered<MachineInfoController>()) {
      Get.find<MachineInfoController>().update(['selectPayment']);
    }
  }

  void _goNext() {
    _navigated = true;
    final initLaunch = Get.arguments?['initLaunch'] ?? false;
    Get.offNamed(
      Routes.CHECKOUT_PAGE,
      arguments: {'initLaunch': initLaunch},
    );
  }

  String _messageFor(CashMachineCheckResult result) {
    return switch (result.failure) {
      CashMachineCheckFailure.unsupportedPlatform => 'この端末では選択された現金機を利用できません。',
      CashMachineCheckFailure.busy => '現金機が処理中です。しばらくしてから再試行してください。',
      CashMachineCheckFailure.timeout => '現金機から応答がありません。接続状態を確認してください。',
      CashMachineCheckFailure.disconnected => '現金機に接続できません。電源と接続状態を確認してください。',
      CashMachineCheckFailure.unexpectedResponse => '現金機から予期しない応答が返されました。',
      CashMachineCheckFailure.recoveryFailed =>
        '現金機の起動復旧処理を完了できませんでした。機器の状態を確認してください。',
      _ => '現金機の確認に失敗しました。機器の状態を確認してください。',
    };
  }
}
