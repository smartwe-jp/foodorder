import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';

import 'CustomLogerHandler.dart';
import 'Storage.dart';
import 'app_event_outbox.dart';
import 'machine_runtime_service.dart';

class SettingsSnapshotReporter {
  static const int schemaVersion = 1;
  static const String _lastSnapshotKey = 'monitorSettingsLastSnapshot';
  static const String _lastHashKey = 'monitorSettingsLastHash';
  static const String _revisionKey = 'monitorSettingsRevision';

  Timer? _debounceTimer;
  Future<void> _reportChain = Future<void>.value();

  void scheduleChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () => _queueReport('settings_changed'),
    );
  }

  Future<void> reportInitial() {
    _debounceTimer?.cancel();
    return _queueReport('initial_sync');
  }

  Future<void> _queueReport(String reason) {
    _reportChain = _reportChain.then((_) => _report(reason)).catchError(
      (Object error, StackTrace stackTrace) {
        logW(
          'Settings snapshot reporting failed',
          tag: 'Settings',
          eventCode: 'APP_SETTINGS_SNAPSHOT_FAILED',
          error: error,
          stack: stackTrace,
        );
      },
    );
    return _reportChain;
  }

  Future<void> _report(String reason) async {
    if (!Get.isRegistered<MachineRuntimeService>()) return;
    final runtime = Get.find<MachineRuntimeService>();
    if (!runtime.isHydrated || runtime.machineCode.trim().isEmpty) return;
    final machineKey = runtime.machineCode.trim();

    final settings = await _capture(runtime);
    final canonicalSettings = _canonicalize(settings);
    final settingsJson = jsonEncode(canonicalSettings);
    final machineType = runtime.machineModelCode.trim().toUpperCase();
    final settingsHash = sha256
        .convert(
          utf8.encode(
            jsonEncode(
              _canonicalize(<String, Object?>{
                'machine_type': machineType,
                'settings': canonicalSettings,
              }),
            ),
          ),
        )
        .toString();
    final previousHash = await Storage.getString('${_lastHashKey}_$machineKey');
    if (previousHash == settingsHash) return;

    final previousSnapshot = _decodePreviousSnapshot(
      await Storage.getString('${_lastSnapshotKey}_$machineKey'),
    );
    final changes = previousSnapshot == null
        ? <Map<String, Object?>>[]
        : _diff(previousSnapshot, canonicalSettings);
    final changedSections = changes
        .map((change) => change['path'].toString().split('.').first)
        .where((section) => section.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final previousRevision = int.tryParse(
          await Storage.getString('${_revisionKey}_$machineKey') ?? '',
        ) ??
        0;
    final revision = previousRevision + 1;
    final capturedAt = DateTime.now().toUtc().toIso8601String();

    final snapshot = <String, Object?>{
      'schema_version': schemaVersion,
      'machine_type': machineType,
      'revision': revision,
      'captured_at': capturedAt,
      'reason': previousSnapshot == null ? 'initial_sync' : reason,
      'settings_hash': settingsHash,
      if (previousHash?.isNotEmpty ?? false) 'previous_hash': previousHash,
      'changed_sections': changedSections,
      'changes': changes,
      'settings': canonicalSettings,
    };

    logI(
      previousSnapshot == null
          ? 'Application settings snapshot synchronized'
          : 'Application settings snapshot changed',
      upload: true,
      tag: 'Settings',
      recordType: 'settings_snapshot',
      eventCode: 'APP_SETTINGS_SNAPSHOT',
      data: <String, Object?>{
        'settings_schema_version': schemaVersion,
        'settings_revision': revision,
        'settings_hash': settingsHash,
        if (previousHash?.isNotEmpty ?? false)
          'previous_settings_hash': previousHash,
        'change_reason': snapshot['reason'],
        'changed_sections': changedSections,
        'settings_json': jsonEncode(snapshot),
      },
    );
    await appEventReporter.flushPersistence();

    await Storage.setString('${_lastSnapshotKey}_$machineKey', settingsJson);
    await Storage.setString('${_lastHashKey}_$machineKey', settingsHash);
    await Storage.setString(
      '${_revisionKey}_$machineKey',
      revision.toString(),
    );
  }

  Future<Map<String, Object?>> _capture(MachineRuntimeService runtime) async {
    final system = runtime.systemSettings;
    final mode = runtime.machineModeInfo;
    final pos = runtime.posSettings;
    final screenCall = runtime.screenCallSettings;
    final rawSubscriptions = await Storage.getData('SSESetting');
    final machineType = runtime.machineModelCode.trim().toUpperCase();
    final hasCashMachineSetting = machineType == 'SWF1' ||
        machineType == 'SWF2' ||
        machineType == 'SWFG';
    final hasDenominationSettings =
        machineType == 'SWF1' || machineType == 'SWF2';

    return <String, Object?>{
      'general': <String, Object?>{
        'machine_modes': <String, bool>{
          'sell': _asBool(mode['sell'], fallback: true),
          'takeout': _asBool(mode['takeout']),
          'checkout': _asBool(mode['checkout']),
          'scanbuy': _asBool(mode['scanbuy']),
        },
        'menu_direction': system['menuDirection']?.toString() ?? '1',
        'panel_type': system['panelType']?.toString() ?? 'Mini',
        'return_after_payment':
            _asBool(system['isBackHome'], fallback: true) ? 'home' : 'menu',
        'register_close_enabled': _asBool(system['isAllowRejishime']),
        'spicy_hot_pot_enabled':
            _asBool(system['spicyHotPotEnabled'], fallback: true),
      },
      'receipt': <String, Object?>{
        'receipt_mode': system['isAllowReceipt']?.toString() ?? '1',
        'order_sheet_print':
            (system['isAllowReceiptMenu']?.toString() ?? '1') == '1',
        'receipt_option_print': _asBool(system['printReceiptOptions']),
        'text_size': _asInt(system['printPaperTxtSize'], fallback: 2),
      },
      if (hasCashMachineSetting)
        'cash': <String, Object?>{
          'machine_enabled':
              _asBool(system['cashMachineEnabled'], fallback: true),
          if (hasDenominationSettings)
            'accepted_denominations': <String, bool>{
              '1': _asBool(
                system['isAllowOneYen'] ?? system['isAllowOneyen'],
              ),
              '5': _asBool(system['isAllow5'], fallback: true),
              '10': _asBool(system['isAllow10'], fallback: true),
              '5000': _asBool(system['isAllow5000'], fallback: true),
              '10000': _asBool(system['isAllow10000'], fallback: true),
            },
        },
      'printing': <String, Object?>{
        'machine_print_width': runtime.machinePrintWidth,
        'usb_printer': Map<String, Object?>.from(runtime.usbDevice),
        'network_printers': runtime.printerList
            .whereType<Map>()
            .map(_normalizePrinter)
            .toList(growable: false),
      },
      'integrations': <String, Object?>{
        'pos': <String, Object?>{
          'enabled': _asBool(system['isAllowPos']),
          'ip': pos['posIp']?.toString() ?? '',
          'port': pos['posPort']?.toString() ?? '',
        },
        'number_panel': <String, Object?>{
          'enabled': _asBool(screenCall['isAllowScreenCall']),
          'ip': screenCall['wlanPrintIp']?.toString() ?? '',
          'port': screenCall['wlanPrintPort']?.toString() ?? '',
        },
      },
      'sse_subscriptions': rawSubscriptions is List
          ? rawSubscriptions
              .whereType<Map>()
              .map((item) => Map<String, Object?>.from(item))
              .toList(growable: false)
          : <Object?>[],
    };
  }

  Map<String, Object?> _normalizePrinter(Map printer) => <String, Object?>{
        'name': printer['name']?.toString() ?? '',
        'type': _asInt(printer['type']),
        'format': _asInt(printer['receipt']) == 1 ? 'label' : 'receipt',
        'enabled': !_asBool(printer['isOff'], fallback: true),
        'ip': printer['printIp']?.toString() ?? '',
        'port': printer['printPort']?.toString() ?? '9100',
        'continuous': _asInt(printer['continuous']),
        'label_width': _asInt(printer['labelWidth']),
        'label_size': printer['labelSize']?.toString() ?? '',
        'direction': _asInt(printer['direction']),
        'option': _asBool(printer['option'], fallback: true),
        'print_category': _asBool(printer['printCategory']),
        'print_head': _asBool(printer['printHead']),
        'print_option_code': _asBool(printer['printOptionCode']),
        'is_default': _asBool(printer['isDefault']),
      };

  Map<String, Object?>? _decodePreviousSnapshot(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final decoded = jsonDecode(value);
      return decoded is Map ? Map<String, Object?>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, Object?>> _diff(
    Object? before,
    Object? after, [
    String path = '',
  ]) {
    if (before is Map && after is Map) {
      final keys = <String>{
        ...before.keys.map((key) => key.toString()),
        ...after.keys.map((key) => key.toString()),
      }.toList()
        ..sort();
      return keys
          .expand((key) => _diff(
                before[key],
                after[key],
                path.isEmpty ? key : '$path.$key',
              ))
          .toList(growable: false);
    }
    if (before is List && after is List) {
      final length =
          before.length > after.length ? before.length : after.length;
      return List<int>.generate(length, (index) => index)
          .expand((index) => _diff(
                index < before.length ? before[index] : null,
                index < after.length ? after[index] : null,
                '$path[$index]',
              ))
          .toList(growable: false);
    }
    if (jsonEncode(before) == jsonEncode(after)) return const [];
    return <Map<String, Object?>>[
      <String, Object?>{'path': path, 'before': before, 'after': after},
    ];
  }

  Object? _canonicalize(Object? value) {
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return <String, Object?>{
        for (final key in keys) key: _canonicalize(value[key]),
      };
    }
    if (value is Iterable) {
      return value.map(_canonicalize).toList(growable: false);
    }
    return value;
  }

  bool _asBool(Object? value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    switch (value?.toString().toLowerCase()) {
      case '1':
      case 'true':
        return true;
      case '0':
      case 'false':
        return false;
      default:
        return fallback;
    }
  }

  int _asInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

final SettingsSnapshotReporter settingsSnapshotReporter =
    SettingsSnapshotReporter();
