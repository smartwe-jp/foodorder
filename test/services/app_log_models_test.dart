import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/services/app_log_models.dart';
import 'package:logging/logging.dart';

void main() {
  group('AppLogSanitizer', () {
    test('redacts sensitive map values recursively', () {
      final sanitized = AppLogSanitizer.map({
        'machine_id': 'machine-1',
        'Authorization': 'Bearer private-token',
        'nested': {
          'password': '123456',
          'status_code': 500,
        },
      });

      expect(sanitized['machine_id'], 'machine-1');
      expect(sanitized['Authorization'], '[REDACTED]');
      expect(
        (sanitized['nested'] as Map<String, Object?>)['password'],
        '[REDACTED]',
      );
      expect(
        (sanitized['nested'] as Map<String, Object?>)['status_code'],
        500,
      );
    });

    test('redacts bearer and inline secrets from text', () {
      final sanitized = AppLogSanitizer.text(
        'Authorization: Bearer abc.def token=secret-value result=failed',
      );

      expect(sanitized, isNot(contains('abc.def')));
      expect(sanitized, isNot(contains('secret-value')));
      expect(sanitized, contains('[REDACTED]'));
    });
  });

  test('restores structured message after logging converts it to text', () {
    const message = AppLogMessage(
      message: 'Payment request started',
      recordType: 'device_heartbeat',
      eventCode: 'PAYMENT_REQUEST_STARTED',
      flowId: 'flow-1',
      data: {'phase': 'request'},
    );
    final record = LogRecord(
      Level.INFO,
      message.toString(),
      'Payment',
    );

    final entry = AppLogEntry.fromRecord(
      record,
      const AppLogContext(sessionId: 'session-1'),
    );

    expect(entry.message, 'Payment request started');
    expect(entry.recordType, 'device_heartbeat');
    expect(entry.eventCode, 'PAYMENT_REQUEST_STARTED');
    expect(entry.flowId, 'flow-1');
    expect(entry.data, {'phase': 'request'});
  });

  test('restores the local-only upload decision after text conversion', () {
    const message = AppLogMessage(
      message: 'Timer reset',
      upload: false,
    );
    final entry = AppLogEntry.fromRecord(
      LogRecord(Level.INFO, message.toString(), 'Timer'),
      const AppLogContext(sessionId: 'session-1'),
    );

    expect(entry.message, 'Timer reset');
    expect(entry.shouldUpload, isFalse);
  });

  test('does not upload structured messages unless explicitly enabled', () {
    const localMessage = AppLogMessage(message: 'Local debug log');
    const uploadMessage = AppLogMessage(
      message: 'Confirmed monitoring event',
      upload: true,
    );

    expect(AppLogMessage.tryDecode(localMessage.toString())?.upload, isFalse);
    expect(AppLogMessage.tryDecode(uploadMessage.toString())?.upload, isTrue);
  });

  test('promotes device heartbeat fields for OpenObserve dashboards', () {
    final entry = AppLogEntry(
      timestamp: DateTime.parse('2026-08-27T10:30:00+09:00'),
      level: 'INFO',
      tag: 'Monitoring',
      recordType: 'device_heartbeat',
      eventCode: 'DEVICE_HEARTBEAT',
      message: 'Device heartbeat',
      data: const {
        'shop_name': '',
        'logo_image_url': 'https://example.jp/logo.png',
        'machine_type': 'SWF1',
        'device_status': 'online',
        'heartbeat_interval_seconds': 60,
      },
      context: const AppLogContext(
        sessionId: 'session-1',
        merchantId: 'shop-1',
        machineId: 'machine-1',
      ),
    );

    final uploadJson = entry.toOpenObserveJson(eventId: 'event-1');

    expect(uploadJson['record_type'], 'device_heartbeat');
    expect(uploadJson['shop_name'], '');
    expect(uploadJson['logo_image_url'], 'https://example.jp/logo.png');
    expect(uploadJson['machine_type'], 'SWF1');
    expect(uploadJson['device_status'], 'online');
    expect(uploadJson['heartbeat_interval_seconds'], 60);
    expect(entry.shouldWriteToLocalLog, isFalse);
  });

  test('formats local logs without repeating upload context', () {
    final entry = AppLogEntry(
      timestamp: DateTime(2026, 9, 14, 10, 30, 0, 123, 456),
      level: 'WARNING',
      tag: 'CashOperation',
      eventCode: 'CASH_OPERATION_STAGE_FAILED',
      message: 'Cash Changer balance read failed',
      flowId: 'flow-1',
      data: const {
        'operation_type': 'cash_sync',
        'stage': 'read_balance',
      },
      error: 'TimeoutException',
      context: const AppLogContext(
        sessionId: 'session-1',
        merchantId: 'shop-1',
        machineId: 'machine-1',
        appVersion: '3.0.0',
        buildNumber: '190',
        platform: 'windows',
      ),
    );

    final localText = entry.toLocalText();

    expect(
      localText,
      startsWith(
        '2026-09-14 10:30:00.123456: WARNING: '
        '[CashOperation] [CASH_OPERATION_STAGE_FAILED] '
        'Cash Changer balance read failed flow=flow-1',
      ),
    );
    expect(localText, contains('\n  data: '));
    expect(localText, contains('\n  error: TimeoutException'));
    expect(localText, isNot(contains('session-1')));
    expect(localText, isNot(contains('shop-1')));
    expect(localText, isNot(contains('machine-1')));
    expect(localText, isNot(contains('build_number')));
  });

  test('keeps ordinary local log lines compact', () {
    final entry = AppLogEntry(
      timestamp: DateTime(2026, 9, 14, 10, 30),
      level: 'INFO',
      tag: 'App',
      message: '--- App Start ---',
      context: const AppLogContext(sessionId: 'session-1'),
    );

    expect(
      entry.toLocalText(),
      '2026-09-14 10:30:00.000: INFO: --- App Start ---',
    );
    expect(entry.shouldWriteToLocalLog, isTrue);
  });

  test('structured entry contains searchable context and error details', () {
    final entry = AppLogEntry(
      timestamp: DateTime.parse('2026-07-22T10:30:00+09:00'),
      level: 'SEVERE',
      tag: 'Payment',
      eventCode: 'PAYMENT_FAILED',
      message: 'Payment failed',
      flowId: 'flow-1',
      incidentId: 'incident-1',
      data: const {'phase': 'connect_cash_machine'},
      error: 'TimeoutException',
      stackTrace: '#0 PaymentService.start',
      context: const AppLogContext(
        sessionId: 'session-1',
        merchantId: 'shop-1',
        machineId: 'machine-1',
        appVersion: '2.9.5',
        buildNumber: '181',
        platform: 'windows',
      ),
    );

    final json = entry.toJson();
    expect(json['event_code'], 'PAYMENT_FAILED');
    expect(json['merchant_id'], 'shop-1');
    expect(json['machine_id'], 'machine-1');
    expect(json['flow_id'], 'flow-1');
    expect(json['error'], 'TimeoutException');
    expect(json['stack_trace'], contains('PaymentService'));

    final uploadJson = entry.toOpenObserveJson(eventId: 'event-1');
    expect(uploadJson['record_type'], 'log');
    expect(uploadJson['event_id'], 'event-1');
    expect(uploadJson['severity'], 'error');
    expect(uploadJson['_timestamp'], '2026-07-22T01:30:00.000Z');
  });

  test('promotes payment dimensions for OpenObserve queries', () {
    final entry = AppLogEntry(
      timestamp: DateTime.parse('2026-07-22T10:30:00+09:00'),
      level: 'INFO',
      tag: 'PaymentFlow',
      eventCode: 'PAYMENT_FLOW_SUCCEEDED',
      message: 'Payment flow succeeded',
      flowId: 'flow-1',
      data: const {
        'order_id': 'order-1',
        'payment_method': 'cash',
        'event_status': 'succeeded',
        'duration_ms': 1500,
        'internal_detail': 'kept_nested_only',
      },
      context: const AppLogContext(sessionId: 'session-1'),
    );

    final uploadJson = entry.toOpenObserveJson(eventId: 'event-1');

    expect(uploadJson['order_id'], 'order-1');
    expect(uploadJson['payment_method'], 'cash');
    expect(uploadJson['event_status'], 'succeeded');
    expect(uploadJson['duration_ms'], 1500);
    expect(uploadJson, isNot(contains('internal_detail')));
    expect(
      uploadJson['data'],
      containsPair('internal_detail', 'kept_nested_only'),
    );
  });

  test('promotes remote print task dimensions for OpenObserve queries', () {
    final entry = AppLogEntry(
      timestamp: DateTime.parse('2026-09-10T10:30:00+09:00'),
      level: 'INFO',
      tag: 'RemotePrint',
      recordType: 'remote_print_task',
      eventCode: 'REMOTE_PRINT_SOCKET_SENT',
      message: 'Remote print task socket data sent',
      flowId: 'print-flow-1',
      data: const {
        'event_status': 'success',
        'print_status': 'success',
        'operation': 'upsert',
        'print_task_id': 'print-flow-1:3',
        'printer_type': 10,
        'printer_ip': '192.168.5.30',
        'print_source': 'checkout_direct',
        'retry_count': 0,
        'result_semantics': 'socket_flushed',
        'print_info': '{"order_sn_code":"0002","items":[]}',
      },
      context: const AppLogContext(sessionId: 'session-1'),
    );

    final uploadJson = entry.toOpenObserveJson(eventId: 'event-1');

    expect(uploadJson['record_type'], 'remote_print_task');
    expect(uploadJson['print_task_id'], 'print-flow-1:3');
    expect(uploadJson['printer_type'], 10);
    expect(uploadJson['printer_ip'], '192.168.5.30');
    expect(uploadJson['print_source'], 'checkout_direct');
    expect(uploadJson['print_status'], 'success');
    expect(uploadJson['result_semantics'], 'socket_flushed');
    expect(uploadJson['print_info'], '{"order_sn_code":"0002","items":[]}');
  });

  test('promotes HTTP dimensions without exposing request payloads', () {
    final entry = AppLogEntry(
      timestamp: DateTime.parse('2026-08-25T10:30:00+09:00'),
      level: 'WARNING',
      tag: 'HTTP',
      eventCode: 'HTTP_REQUEST_FAILED',
      message: 'HTTP request failed',
      data: const {
        'method': 'POST',
        'path': '/api/payment',
        'status_code': 503,
        'dio_error_type': 'connectionError',
        'request_payload': {'auth_code': 'must-not-be-promoted'},
      },
      context: const AppLogContext(sessionId: 'session-1'),
    );

    final uploadJson = entry.toOpenObserveJson(eventId: 'event-1');

    expect(uploadJson['method'], 'POST');
    expect(uploadJson['path'], '/api/payment');
    expect(uploadJson['status_code'], 503);
    expect(uploadJson['dio_error_type'], 'connectionError');
    expect(uploadJson, isNot(contains('request_payload')));
  });
}
