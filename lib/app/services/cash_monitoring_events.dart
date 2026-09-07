import 'dart:convert';

import 'CustomLogerHandler.dart';

class CashBalanceSyncResult {
  const CashBalanceSyncResult({
    required this.snapshotCaptured,
    required this.backendSynced,
  });

  final bool snapshotCaptured;
  final bool backendSynced;
}

abstract final class CashMonitoringEvents {
  static const Map<String, int> _denominationByCode = <String, int>{
    '61': 1,
    '62': 5,
    '63': 10,
    '64': 50,
    '65': 100,
    '66': 500,
    '87': 1000,
    '88': 2000,
    '89': 5000,
    '8A': 10000,
    'A1': 1,
    'A2': 5,
    'A3': 10,
    'A4': 50,
    'A5': 100,
    'A6': 500,
    '97': 1000,
    '98': 2000,
    '99': 5000,
    '9A': 10000,
  };

  static String newFlowId() => CustomLogHandler.newFlowId();

  static Map<String, int> normalizeCodeCounts(Map values) {
    final result = <String, int>{};
    for (final entry in values.entries) {
      final denomination =
          _denominationByCode[entry.key.toString().toUpperCase()];
      final count = int.tryParse(entry.value.toString());
      if (denomination == null || count == null) continue;
      final key = denomination.toString();
      result[key] = (result[key] ?? 0) + count;
    }
    return result;
  }

  static Map<String, int> movementDelta({
    Iterable? puts,
    Iterable? pops,
  }) {
    final result = <String, int>{};
    void add(Iterable? movements, int sign) {
      for (final movement in movements ?? const []) {
        if (movement is! Map) continue;
        final denomination =
            _denominationByCode[movement['catVal']?.toString().toUpperCase()];
        final count = int.tryParse(movement['val']?.toString() ?? '');
        if (denomination == null || count == null || count == 0) continue;
        final key = denomination.toString();
        result[key] = (result[key] ?? 0) + sign * count;
      }
    }

    add(puts, 1);
    add(pops, -1);
    result.removeWhere((_, value) => value == 0);
    return result;
  }

  static void registerClose(
    String eventCode,
    String message, {
    required String flowId,
    required String status,
    required String stage,
    String cashDevice = 'glory',
    bool warning = false,
    Object? error,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    final payload = <String, Object?>{
      'event_status': status,
      'stage': stage,
      'cash_device': cashDevice,
      'operation_type': 'register_close',
      ...data,
    };
    if (warning) {
      logW(
        message,
        upload: true,
        tag: 'RegisterClose',
        eventCode: eventCode,
        flowId: flowId,
        data: payload,
        error: error,
      );
    } else {
      logI(
        message,
        upload: true,
        tag: 'RegisterClose',
        recordType: 'register_close_event',
        eventCode: eventCode,
        flowId: flowId,
        data: payload,
      );
    }
  }

  static void snapshot({
    required String reason,
    required Map counts,
    required bool isBaseline,
    String? flowId,
    String backendSyncStatus = 'succeeded',
  }) {
    final normalized = normalizeCodeCounts(counts);
    logI(
      'Cash Changer balance snapshot captured',
      upload: true,
      tag: 'CashMonitoring',
      recordType: 'cash_snapshot',
      eventCode: 'CASH_BALANCE_SNAPSHOT',
      flowId: flowId,
      data: <String, Object?>{
        'event_status': 'succeeded',
        'cash_device': 'glory',
        'snapshot_reason': reason,
        'is_baseline': isBaseline,
        'denomination_counts': jsonEncode(normalized),
        'total_amount': _total(normalized),
        'backend_sync_status': backendSyncStatus,
      },
    );
  }

  static void ledgerDelta({
    required String cashDevice,
    required String operationType,
    required Map<String, int> delta,
    String? flowId,
    String source = 'app_event',
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    final effectiveDelta = Map<String, int>.from(delta)
      ..removeWhere((_, count) => count == 0);
    if (effectiveDelta.isEmpty) return;
    logI(
      'Cash inventory movement recorded',
      upload: true,
      tag: 'CashMonitoring',
      recordType: 'cash_ledger_delta',
      eventCode: 'CASH_LEDGER_DELTA',
      flowId: flowId,
      data: <String, Object?>{
        'event_status': 'succeeded',
        'cash_device': cashDevice,
        'operation_type': operationType,
        'event_source': source,
        'delta_counts': jsonEncode(effectiveDelta),
        'delta_amount': _total(effectiveDelta),
        ...data,
      },
    );
  }

  static int _total(Map<String, int> counts) => counts.entries.fold(
        0,
        (total, entry) => total + (int.tryParse(entry.key) ?? 0) * entry.value,
      );
}
