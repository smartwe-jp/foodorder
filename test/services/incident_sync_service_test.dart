import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/services/incident_outbox.dart';
import 'package:foodorder/app/services/incident_sync_service.dart';

void main() {
  test('requires both the ingestion URL and upload key', () {
    expect(OpenObserveUploadService().isConfigured, isFalse);
    expect(
      OpenObserveUploadService(
        ingestUrl: 'https://observe.example.jp/app-events',
        ingestKey: '',
      ).isConfigured,
      isFalse,
    );
  });

  test('builds the OpenObserve JSON ingestion contract', () async {
    late String sentUrl;
    late List<Map<String, Object?>> sentBody;
    late Map<String, String> sentHeaders;
    final service = OpenObserveUploadService(
      ingestUrl: 'https://observe.example.jp/app-events',
      ingestKey: 'machine-upload-key',
      requestSender: (url, body, headers) async {
        sentUrl = url;
        sentBody = body;
        sentHeaders = headers;
        return Response<dynamic>(
          requestOptions: RequestOptions(path: url),
          statusCode: 200,
          data: {
            'code': 200,
            'status': [
              {'name': 'app_incidents', 'successful': 1, 'failed': 0},
            ],
          },
        );
      },
    );

    final acknowledged = await service.uploadIncident(_incident());

    expect(acknowledged, isTrue);
    expect(sentUrl, 'https://observe.example.jp/app-events');
    expect(sentHeaders['X-Ingest-Key'], 'machine-upload-key');
    expect(sentBody, hasLength(1));
    final event = sentBody.single;
    expect(event['schema_version'], 1);
    expect(event['_timestamp'], '2026-07-22T01:30:00.000Z');
    expect(event['incident_id'], 'incident-1');
    expect(event['event_code'], 'PAYMENT_FAILED');
    expect(event['severity'], 'error');
    expect(event['merchant_id'], 'shop-1');
    expect(event['machine_id'], 'machine-1');
    expect(event['flow_id'], 'payment-flow-1');
    expect(event['data'], {'phase': 'payment_confirm'});
  });

  test('keeps an incident pending when OpenObserve does not acknowledge it',
      () async {
    final service = OpenObserveUploadService(
      ingestUrl: 'https://observe.example.jp/app-events',
      ingestKey: 'machine-upload-key',
      requestSender: (url, _, __) async => Response<dynamic>(
        requestOptions: RequestOptions(path: url),
        statusCode: 200,
        data: {
          'code': 200,
          'status': [
            {'name': 'app_incidents', 'successful': 0, 'failed': 1},
          ],
        },
      ),
    );

    expect(await service.uploadIncident(_incident()), isFalse);
  });
}

PendingIncident _incident() {
  return PendingIncident(
    incidentId: 'incident-1',
    eventCode: 'PAYMENT_FAILED',
    message: 'Payment failed',
    occurredAt: DateTime.parse('2026-07-22T10:30:00+09:00'),
    context: const {
      'merchant_id': 'shop-1',
      'machine_id': 'machine-1',
    },
    data: const {'phase': 'payment_confirm'},
    breadcrumbs: const [],
    flowId: 'payment-flow-1',
  );
}
