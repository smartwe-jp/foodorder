import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/services/app_event_outbox.dart';
import 'package:foodorder/app/services/app_log_models.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<dynamic> box;
  late AppEventOutbox outbox;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('app_event_outbox_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('test_app_events');
    outbox = AppEventOutbox(box: box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test_app_events');
    await tempDirectory.delete(recursive: true);
  });

  test('buffers startup logs until Hive outbox is initialized', () async {
    final reporter = AppEventReporter(outbox);
    reporter.record(_entry('LOGGER_INITIALIZED'));
    reporter.record(_entry('APP_BOOTSTRAP_STARTED'));

    await reporter.initialize();

    expect(outbox.length, 2);
    expect(
      outbox.pending().map((event) => event.payload['event_code']),
      ['LOGGER_INITIALIZED', 'APP_BOOTSTRAP_STARTED'],
    );
  });

  test('uploads structured logger events in one batch', () async {
    final reporter = AppEventReporter(outbox);
    await reporter.initialize();
    reporter.record(_entry('HTTP_REQUEST_STARTED'));
    reporter.record(_entry('HTTP_REQUEST_SUCCEEDED'));
    await reporter.flushPersistence();

    late List<Map<String, Object?>> uploaded;
    await reporter.flush((events) async {
      uploaded = events;
      return true;
    });

    expect(uploaded, hasLength(2));
    expect(uploaded.first['record_type'], 'log');
    expect(uploaded.first['merchant_id'], 'shop-1');
    expect(outbox.length, 0);
  });

  test('keeps a rejected batch for retry', () async {
    final reporter = AppEventReporter(outbox);
    await reporter.initialize();
    reporter.record(_entry('PAYMENT_FAILED'));
    await reporter.flushPersistence();

    await reporter.flush((_) async => false);

    final pending = outbox.pending(
      now: DateTime.now().add(const Duration(minutes: 1)),
    );
    expect(pending.single.retryCount, 1);
    expect(pending.single.lastUploadError, contains('not acknowledged'));
  });
}

AppLogEntry _entry(String eventCode) {
  return AppLogEntry(
    timestamp: DateTime.parse('2026-07-22T10:30:00+09:00'),
    level: 'INFO',
    tag: 'Test',
    eventCode: eventCode,
    message: eventCode,
    context: const AppLogContext(
      sessionId: 'session-1',
      merchantId: 'shop-1',
      machineId: 'machine-1',
      platform: 'android',
    ),
  );
}
