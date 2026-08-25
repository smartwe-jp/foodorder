import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/services/incident_outbox.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory tempDirectory;
  late Box<dynamic> box;
  late IncidentOutbox outbox;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('incident_outbox_');
    Hive.init(tempDirectory.path);
    box = await Hive.openBox<dynamic>('test_incidents');
    outbox = IncidentOutbox(box: box);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('test_incidents');
    await tempDirectory.delete(recursive: true);
  });

  test('persists an incident until uploader acknowledges it', () async {
    final incident = _incident('incident-1');
    await outbox.enqueue(incident);

    expect(outbox.all(), hasLength(1));

    final reporter = IncidentReporter(outbox);
    await reporter.flush((pending) async {
      expect(pending.incidentId, 'incident-1');
      return true;
    });

    expect(outbox.all(), isEmpty);
  });

  test('keeps failed uploads and schedules retry', () async {
    final incident = _incident('incident-2');
    await outbox.enqueue(incident);

    final reporter = IncidentReporter(outbox);
    await reporter.flush((_) async => false);

    final stored = outbox.all().single;
    expect(stored.retryCount, 1);
    expect(stored.nextRetryAt, isNotNull);
    expect(stored.lastUploadError, contains('not acknowledged'));
    expect(outbox.pending(), isEmpty);
  });

  test('round-trips structured incident context and breadcrumbs', () async {
    await outbox.enqueue(_incident('incident-3'));

    final stored = outbox.all().single;
    expect(stored.context['merchant_id'], 'shop-1');
    expect(stored.context['machine_id'], 'machine-1');
    expect(stored.data['phase'], 'open_cash_machine');
    expect(stored.breadcrumbs.single['event_code'], 'PAYMENT_STARTED');
  });

  test('capture persists without requiring the caller to await', () async {
    final reporter = IncidentReporter(outbox);

    reporter.capture(
      eventCode: 'STARTUP_FAILED',
      message: 'Startup failed',
      error: StateError('invalid machine settings'),
    );

    await Future<void>.delayed(Duration.zero);
    expect(outbox.all().single.eventCode, 'STARTUP_FAILED');
  });

  test('notifies sync service after an incident is persisted', () async {
    final reporter = IncidentReporter(outbox);
    var notificationCount = 0;
    reporter.setOnIncidentQueued(() async {
      notificationCount++;
    });

    await reporter.report(
      eventCode: 'STARTUP_FAILED',
      message: 'Startup failed',
    );
    await Future<void>.delayed(Duration.zero);

    expect(notificationCount, 1);
    expect(outbox.all(), hasLength(1));
  });
}

PendingIncident _incident(String id) {
  return PendingIncident(
    incidentId: id,
    eventCode: 'PAYMENT_FAILED',
    message: 'Payment failed',
    occurredAt: DateTime.now(),
    context: const {
      'merchant_id': 'shop-1',
      'machine_id': 'machine-1',
    },
    data: const {'phase': 'open_cash_machine'},
    breadcrumbs: const [
      {
        'event_code': 'PAYMENT_STARTED',
        'message': 'Payment started',
      },
    ],
  );
}
