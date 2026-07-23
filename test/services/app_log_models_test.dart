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
    expect(entry.eventCode, 'PAYMENT_REQUEST_STARTED');
    expect(entry.flowId, 'flow-1');
    expect(entry.data, {'phase': 'request'});
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
}
