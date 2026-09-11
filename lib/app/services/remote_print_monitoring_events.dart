import 'dart:convert';

import '../print_failed/print_failed_models.dart';
import 'CustomLogerHandler.dart';
import 'app_log_models.dart';

abstract final class RemotePrintMonitoringEvents {
  static void stateChanged(
    PrintRecord record, {
    String? reason,
  }) {
    final eventCode = switch (record.status) {
      'pending' => 'REMOTE_PRINT_TASK_CREATED',
      'success' => 'REMOTE_PRINT_SOCKET_SENT',
      'failed' => 'REMOTE_PRINT_SOCKET_FAILED',
      _ => 'REMOTE_PRINT_TASK_STATE_CHANGED',
    };
    final message = switch (record.status) {
      'pending' => 'Remote print task created',
      'success' => 'Remote print task socket data sent',
      'failed' => 'Remote print task socket send failed',
      _ => 'Remote print task state changed',
    };
    final data = _data(
      record,
      operation: 'upsert',
      reason: reason,
    );

    if (record.status == 'failed') {
      logW(
        message,
        upload: true,
        tag: 'RemotePrint',
        recordType: 'remote_print_task',
        eventCode: eventCode,
        flowId: _flowId(record),
        data: data,
        error: record.lastError.isEmpty ? null : record.lastError,
      );
      return;
    }

    logI(
      message,
      upload: true,
      tag: 'RemotePrint',
      recordType: 'remote_print_task',
      eventCode: eventCode,
      flowId: _flowId(record),
      data: data,
    );
  }

  static void deleted(
    PrintRecord record, {
    required String reason,
  }) {
    logI(
      'Remote print task deleted',
      upload: true,
      tag: 'RemotePrint',
      recordType: 'remote_print_task',
      eventCode: 'REMOTE_PRINT_TASK_DELETED',
      flowId: _flowId(record),
      data: _data(
        record,
        operation: 'delete',
        status: 'deleted',
        reason: reason,
      ),
    );
  }

  static Map<String, Object?> _data(
    PrintRecord record, {
    required String operation,
    String? status,
    String? reason,
  }) {
    final info = record.printInfo;
    final effectiveStatus = status ?? record.status;
    final items = info['items'];

    return <String, Object?>{
      'event_status': effectiveStatus,
      'print_status': effectiveStatus,
      'operation': operation,
      'print_task_id': record.uuid,
      'printer_type': record.printerType,
      'printer_ip': record.printerIp,
      'print_source': _firstNonEmpty(info, const ['printSource']) ?? 'unknown',
      'print_type': _firstNonEmpty(info, const ['printType']),
      'order_id': _firstNonEmpty(
        info,
        const ['orderId', 'order_id', 'bizId'],
      ),
      'order_sn_code': _firstNonEmpty(
        info,
        const ['orderSnCode', 'order_sn_code'],
      ),
      'from_plate': _firstNonEmpty(
        info,
        const ['fromPlate', 'from_plate'],
      ),
      'order_time': _firstNonEmpty(info, const ['orderTime', 'order_time']),
      'item_count': items is List ? items.length : null,
      'retry_count': record.retryCount,
      'last_error': record.lastError.isEmpty ? null : record.lastError,
      'task_created_at': _timestamp(record.createdAt),
      'task_updated_at': _timestamp(record.updatedAt),
      'update_reason': reason,
      'print_info': AppLogSanitizer.text(
        jsonEncode(AppLogSanitizer.map(info)),
        maxLength: 16000,
      ),
      if (effectiveStatus == 'success') 'result_semantics': 'socket_flushed',
    };
  }

  static String _flowId(PrintRecord record) {
    final explicit = _firstNonEmpty(
      record.printInfo,
      const ['printFlowId', 'print_flow_id'],
    );
    if (explicit != null) return explicit;
    return record.uuid.split(':').first;
  }

  static String? _firstNonEmpty(Map values, List<String> keys) {
    for (final key in keys) {
      final value = values[key]?.toString().trim();
      if (value != null && value.isNotEmpty && value != 'null') return value;
    }
    return null;
  }

  static String _timestamp(int millisecondsSinceEpoch) =>
      DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch)
          .toUtc()
          .toIso8601String();
}
