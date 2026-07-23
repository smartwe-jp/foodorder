import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import 'incident_outbox.dart';

const String openObserveIngestUrl = String.fromEnvironment(
  'OPENOBSERVE_INGEST_URL',
);
const String openObserveIngestKey = String.fromEnvironment(
  'OPENOBSERVE_INGEST_KEY',
);
const String appEnvironment = String.fromEnvironment(
  'APP_ENVIRONMENT',
  defaultValue: 'production',
);

bool get openObserveUploadEnabled =>
    openObserveIngestUrl.trim().isNotEmpty &&
    openObserveIngestKey.trim().isNotEmpty;

typedef OpenObserveRequestSender = Future<Response<dynamic>> Function(
  String url,
  List<Map<String, Object?>> body,
  Map<String, String> headers,
);

class OpenObserveUploadService {
  OpenObserveUploadService({
    String? ingestUrl,
    String? ingestKey,
    OpenObserveRequestSender? requestSender,
  })  : ingestUrl = ingestUrl ?? openObserveIngestUrl,
        ingestKey = ingestKey ?? openObserveIngestKey,
        _requestSender = requestSender ?? _sendToOpenObserve;

  final String ingestUrl;
  final String ingestKey;
  final OpenObserveRequestSender _requestSender;

  bool get isConfigured =>
      ingestUrl.trim().isNotEmpty && ingestKey.trim().isNotEmpty;

  Future<bool> uploadIncident(PendingIncident incident) {
    return uploadRecords(<Map<String, Object?>>[incident.toUploadJson()]);
  }

  Future<bool> uploadRecords(List<Map<String, Object?>> records) async {
    if (!isConfigured) return false;
    if (records.isEmpty) return true;

    final response = await _requestSender(
      ingestUrl,
      records,
      <String, String>{
        'Content-Type': 'application/json',
        if (ingestKey.trim().isNotEmpty) 'X-Ingest-Key': ingestKey,
      },
    );
    return _isAcknowledged(response, expectedRecords: records.length);
  }

  bool _isAcknowledged(
    Response<dynamic> response, {
    required int expectedRecords,
  }) {
    if (response.statusCode != 200) return false;

    dynamic body = response.data;
    if (body is String && body.isNotEmpty) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        return false;
      }
    }
    if (body is! Map) return false;
    if (body['code'] != 200 && body['code']?.toString() != '200') return false;

    final statuses = body['status'];
    if (statuses is! List || statuses.isEmpty) return false;
    var successfulRecords = 0;
    var failedRecords = 0;
    for (final status in statuses.whereType<Map>()) {
      final successful = int.tryParse(status['successful']?.toString() ?? '0');
      final failed = int.tryParse(status['failed']?.toString() ?? '0');
      successfulRecords += successful ?? 0;
      failedRecords += failed ?? 0;
    }
    return successfulRecords == expectedRecords && failedRecords == 0;
  }
}

final Dio _incidentDio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ),
);

Future<Response<dynamic>> _sendToOpenObserve(
  String url,
  List<Map<String, Object?>> body,
  Map<String, String> headers,
) {
  return _incidentDio.post<dynamic>(
    url,
    data: body,
    options: Options(headers: headers),
  );
}

class IncidentSyncService {
  IncidentSyncService({
    required this.reporter,
    required this.uploader,
    Connectivity? connectivity,
    this.retryCheckInterval = const Duration(seconds: 5),
  }) : _connectivity = connectivity ?? Connectivity();

  final IncidentReporter reporter;
  final OpenObserveUploadService uploader;
  final Connectivity _connectivity;
  final Duration retryCheckInterval;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _retryTimer;
  bool _started = false;

  Future<void> start() async {
    if (_started || !uploader.isConfigured) return;
    _started = true;
    reporter.setOnIncidentQueued(syncNow);
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
    );
    _retryTimer = Timer.periodic(retryCheckInterval, (_) {
      unawaited(syncNow());
    });

    final current = await _connectivity.checkConnectivity();
    await _handleConnectivityChanged(current);
  }

  Future<void> _handleConnectivityChanged(
    List<ConnectivityResult> results,
  ) async {
    if (!_hasNetwork(results)) return;
    await syncNow();
  }

  Future<void> syncNow() async {
    if (!uploader.isConfigured || !reporter.outbox.isInitialized) return;
    final pendingCount = reporter.outbox.pending().length;
    if (pendingCount == 0) return;

    await reporter.flush(uploader.uploadIncident);
  }

  bool _hasNetwork(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<void> dispose() async {
    reporter.setOnIncidentQueued(null);
    _retryTimer?.cancel();
    _retryTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
  }
}

final OpenObserveUploadService openObserveUploadService =
    OpenObserveUploadService();
final IncidentSyncService incidentSyncService = IncidentSyncService(
  reporter: incidentReporter,
  uploader: openObserveUploadService,
);
