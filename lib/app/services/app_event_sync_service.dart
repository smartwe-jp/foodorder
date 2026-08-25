import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import 'app_event_outbox.dart';
import 'incident_sync_service.dart';

class AppEventSyncService {
  AppEventSyncService({
    required this.reporter,
    required this.uploader,
    Connectivity? connectivity,
    this.retryCheckInterval = const Duration(seconds: 5),
    this.uploadDebounce = const Duration(seconds: 1),
  }) : _connectivity = connectivity ?? Connectivity();

  final AppEventReporter reporter;
  final OpenObserveUploadService uploader;
  final Connectivity _connectivity;
  final Duration retryCheckInterval;
  final Duration uploadDebounce;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _retryTimer;
  Timer? _debounceTimer;
  bool _started = false;

  Future<void> start() async {
    if (_started || !uploader.isConfigured) return;
    _started = true;
    reporter.setOnEventQueued(requestSync);
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
    );
    _retryTimer = Timer.periodic(retryCheckInterval, (_) {
      unawaited(syncNow());
    });

    final current = await _connectivity.checkConnectivity();
    await _handleConnectivityChanged(current);
  }

  Future<void> requestSync() async {
    if (_debounceTimer != null) return;
    _debounceTimer = Timer(uploadDebounce, () {
      _debounceTimer = null;
      unawaited(syncNow());
    });
  }

  Future<void> _handleConnectivityChanged(
    List<ConnectivityResult> results,
  ) async {
    if (results.every((result) => result == ConnectivityResult.none)) return;
    await syncNow();
  }

  Future<void> syncNow() async {
    if (!uploader.isConfigured || !reporter.outbox.isInitialized) return;
    await reporter.flush(uploader.uploadRecords);
  }

  Future<void> dispose() async {
    reporter.setOnEventQueued(null);
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
  }
}

final AppEventSyncService appEventSyncService = AppEventSyncService(
  reporter: appEventReporter,
  uploader: openObserveUploadService,
);
