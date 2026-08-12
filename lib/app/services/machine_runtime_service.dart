import 'dart:convert';

import '../models/machine_activation.dart';
import '../models/machine_capabilities.dart';
import '../repositories/machine_activation_repository.dart';
import 'Storage.dart';

enum CashMachineRuntimeStatus {
  notChecked,
  notRequired,
  checking,
  ready,
  failed,
  ignored,
}

class MachineRuntimeService {
  MachineRuntimeService({
    MachineActivationRepository? activationRepository,
    MachineCapabilitiesResolver capabilitiesResolver =
        const MachineCapabilitiesResolver(),
  })  : _capabilitiesResolver = capabilitiesResolver,
        _activationRepository =
            activationRepository ?? MachineActivationRepository();

  final MachineActivationRepository _activationRepository;
  final MachineCapabilitiesResolver _capabilitiesResolver;

  bool _isHydrated = false;
  String _machineCode = '';
  Map<String, dynamic> _systemSettings = {};
  MachineActivation? _activation;
  String _settingPassword = '';
  String _printLogoImageData = '';
  bool _cashMachineEnabled = true;
  CashMachineRuntimeStatus _cashMachineStatus =
      CashMachineRuntimeStatus.notChecked;
  List<dynamic> _printerList = [];
  Map<String, dynamic> _machineModeInfo = {};
  Map<String, dynamic> _posSettings = {};
  Map<String, dynamic> _screenCallSettings = {};
  Map<String, dynamic> _usbDevice = {};
  double _machinePrintWidth = 385.0;

  bool get isHydrated => _isHydrated;
  String get machineCode => _machineCode;
  Map<String, dynamic> get systemSettings =>
      Map<String, dynamic>.unmodifiable(_systemSettings);
  MachineActivation? get activation => _activation;
  String get settingPassword => _settingPassword;
  String get printLogoImageData => _printLogoImageData;
  String get machineModelCode => _activation?.machineModelCode ?? '';
  MachineCapabilities get capabilities =>
      _capabilitiesResolver.resolve(machineModelCode);
  bool get cashMachineEnabled => _cashMachineEnabled;
  CashMachineRuntimeStatus get cashMachineStatus => _cashMachineStatus;
  bool get shouldCheckCashMachine =>
      _cashMachineEnabled && capabilities.supportsCashMachine;
  bool get requiresCashMachineStartupCheck =>
      shouldCheckCashMachine &&
      _cashMachineStatus != CashMachineRuntimeStatus.ready &&
      _cashMachineStatus != CashMachineRuntimeStatus.ignored;
  bool get cashPaymentAvailable =>
      shouldCheckCashMachine &&
      _cashMachineStatus == CashMachineRuntimeStatus.ready;
  List<dynamic> get printerList => List<dynamic>.from(_printerList);
  Map<String, dynamic> get machineModeInfo =>
      Map<String, dynamic>.from(_machineModeInfo);
  Map<String, dynamic> get posSettings =>
      Map<String, dynamic>.from(_posSettings);
  Map<String, dynamic> get screenCallSettings =>
      Map<String, dynamic>.from(_screenCallSettings);
  Map<String, dynamic> get usbDevice => Map<String, dynamic>.from(_usbDevice);
  double get machinePrintWidth => _machinePrintWidth;

  Future<void> hydrate({String machineCode = ''}) async {
    if (_isHydrated) {
      if (machineCode.isNotEmpty) _machineCode = machineCode;
      return;
    }

    _machineCode = machineCode.isNotEmpty
        ? machineCode
        : await Storage.getString('machineInfo') ?? '';
    _systemSettings = _decodeMap(
      await Storage.getString('smartwe_systemSetting'),
    );
    _activation = await _activationRepository.loadCached();
    _settingPassword =
        await Storage.getString('machineSettingManagePassword') ?? '';
    _printLogoImageData =
        await Storage.getString('smartwe_logoImageData') ?? '';
    _cashMachineEnabled =
        _asBool(_systemSettings['cashMachineEnabled'], fallback: true);
    if (!_cashMachineEnabled) {
      _cashMachineStatus = CashMachineRuntimeStatus.notRequired;
    }
    final printerList = await Storage.getData('printerListInfo');
    _printerList = printerList is List ? List<dynamic>.from(printerList) : [];
    final machineModeInfo = await Storage.getData('machineModeInfo');
    _machineModeInfo = machineModeInfo is Map
        ? Map<String, dynamic>.from(machineModeInfo)
        : {};
    _posSettings = _decodeMap(await Storage.getString('smartwe_posSetting'));
    _screenCallSettings =
        _decodeMap(await Storage.getString('smartwe_wlanPanelPrintSetting'));
    _usbDevice = _decodeMap(await Storage.getString('smartwe_usbPrintSetting'));
    _machinePrintWidth = await Storage.getDouble('machinePrintWidth') ?? 385.0;
    _isHydrated = true;
  }

  Future<MachineActivation?> activate({
    required String machineCode,
    required String version,
  }) async {
    final activation = await _activationRepository.activate(
      machineCode: machineCode,
      version: version,
    );
    if (activation != null) _activation = activation;
    return activation;
  }

  Future<void> updateMachineCode(String machineCode) async {
    _machineCode = machineCode;
    await Storage.setString('machineInfo', machineCode);
  }

  Future<void> updateSystemSettings(Map<String, dynamic> settings) async {
    _systemSettings = Map<String, dynamic>.from(settings);
    _cashMachineEnabled =
        _asBool(_systemSettings['cashMachineEnabled'], fallback: true);
    if (!_cashMachineEnabled) {
      _cashMachineStatus = CashMachineRuntimeStatus.notRequired;
    } else if (_cashMachineStatus == CashMachineRuntimeStatus.notRequired) {
      _cashMachineStatus = CashMachineRuntimeStatus.notChecked;
    }
    await Storage.setString('smartwe_systemSetting', json.encode(settings));
  }

  Future<void> updateCashMachineEnabled(bool enabled) async {
    final settings = Map<String, dynamic>.from(_systemSettings)
      ..['cashMachineEnabled'] = enabled;
    await updateSystemSettings(settings);
  }

  void markCashMachineChecking() {
    _cashMachineStatus = CashMachineRuntimeStatus.checking;
  }

  void markCashMachineReady() {
    _cashMachineStatus = CashMachineRuntimeStatus.ready;
  }

  void markCashMachineFailed() {
    _cashMachineStatus = CashMachineRuntimeStatus.failed;
  }

  void markCashMachineIgnored() {
    _cashMachineStatus = CashMachineRuntimeStatus.ignored;
  }

  void markCashMachineNotRequired() {
    _cashMachineStatus = CashMachineRuntimeStatus.notRequired;
  }

  Future<void> updateSettingPassword(String password) async {
    _settingPassword = password;
    await Storage.setString('machineSettingManagePassword', password);
  }

  Future<void> updatePrinterList(List<dynamic> printers) async {
    _printerList = List<dynamic>.from(printers);
    await Storage.setData('printerListInfo', json.encode(printers));
  }

  Future<void> updateMachineModeInfo(Map<String, dynamic> machineMode) async {
    _machineModeInfo = Map<String, dynamic>.from(machineMode);
    await Storage.setData('machineModeInfo', json.encode(machineMode));
  }

  Future<void> updatePosSettings(Map<String, dynamic> settings) async {
    _posSettings = Map<String, dynamic>.from(settings);
    await Storage.setString('smartwe_posSetting', json.encode(settings));
  }

  Future<void> updateScreenCallSettings(Map<String, dynamic> settings) async {
    _screenCallSettings = Map<String, dynamic>.from(settings);
    await Storage.setString(
        'smartwe_wlanPanelPrintSetting', json.encode(settings));
  }

  Future<void> updateUsbDevice(Map<String, dynamic> device) async {
    _usbDevice = Map<String, dynamic>.from(device);
    await Storage.setString('smartwe_usbPrintSetting', json.encode(device));
  }

  Future<void> updateMachinePrintWidth(double width) async {
    _machinePrintWidth = width;
    await Storage.setDouble('machinePrintWidth', width);
  }

  Map<String, dynamic> _decodeMap(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return {};
    try {
      final decoded = json.decode(rawValue);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : {};
    } catch (_) {
      return {};
    }
  }

  bool _asBool(dynamic value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }
}
