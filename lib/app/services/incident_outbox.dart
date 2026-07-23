import 'dart:async';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'CustomLogerHandler.dart';
import 'app_log_models.dart';

typedef IncidentUploader = Future<bool> Function(PendingIncident incident);
typedef IncidentQueuedCallback = Future<void> Function();

class PendingIncident {
  const PendingIncident({
    required this.incidentId,
    required this.eventCode,
    required this.message,
    required this.occurredAt,
    required this.context,
    required this.data,
    required this.breadcrumbs,
    this.flowId,
    this.error,
    this.stackTrace,
    this.retryCount = 0,
    this.nextRetryAt,
    this.lastUploadError,
  });

  factory PendingIncident.fromJson(Map values) {
    return PendingIncident(
      incidentId: values['incident_id']?.toString() ?? '',
      eventCode: values['event_code']?.toString() ?? 'UNKNOWN_ERROR',
      message: values['message']?.toString() ?? '',
      occurredAt: DateTime.tryParse(values['occurred_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      context: Map<String, Object?>.from(values['context'] as Map? ?? const {}),
      data: Map<String, Object?>.from(values['data'] as Map? ?? const {}),
      breadcrumbs: (values['breadcrumbs'] as List? ?? const [])
          .whereType<Map>()
          .map((item) => Map<String, Object?>.from(item))
          .toList(growable: false),
      flowId: values['flow_id']?.toString(),
      error: values['error']?.toString(),
      stackTrace: values['stack_trace']?.toString(),
      retryCount: values['retry_count'] as int? ?? 0,
      nextRetryAt: DateTime.tryParse(
        values['next_retry_at']?.toString() ?? '',
      ),
      lastUploadError: values['last_upload_error']?.toString(),
    );
  }

  final String incidentId;
  final String eventCode;
  final String message;
  final DateTime occurredAt;
  final Map<String, Object?> context;
  final Map<String, Object?> data;
  final List<Map<String, Object?>> breadcrumbs;
  final String? flowId;
  final String? error;
  final String? stackTrace;
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? lastUploadError;

  String get displayCode {
    final normalized = incidentId.replaceAll('-', '').toUpperCase();
    if (normalized.length <= 8) return normalized;
    return normalized.substring(0, 8);
  }

  PendingIncident copyWith({
    int? retryCount,
    DateTime? nextRetryAt,
    String? lastUploadError,
  }) {
    return PendingIncident(
      incidentId: incidentId,
      eventCode: eventCode,
      message: message,
      occurredAt: occurredAt,
      context: context,
      data: data,
      breadcrumbs: breadcrumbs,
      flowId: flowId,
      error: error,
      stackTrace: stackTrace,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastUploadError: lastUploadError ?? this.lastUploadError,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'incident_id': incidentId,
        'event_code': eventCode,
        'message': message,
        'occurred_at': occurredAt.toIso8601String(),
        'context': context,
        'data': data,
        'breadcrumbs': breadcrumbs,
        if (flowId?.isNotEmpty ?? false) 'flow_id': flowId,
        if (error?.isNotEmpty ?? false) 'error': error,
        if (stackTrace?.isNotEmpty ?? false) 'stack_trace': stackTrace,
        'retry_count': retryCount,
        if (nextRetryAt != null)
          'next_retry_at': nextRetryAt!.toIso8601String(),
        if (lastUploadError?.isNotEmpty ?? false)
          'last_upload_error': lastUploadError,
      };

  Map<String, Object?> toUploadJson() => <String, Object?>{
        'schema_version': 1,
        'record_type': 'incident',
        '_timestamp': occurredAt.toUtc().toIso8601String(),
        'incident_id': incidentId,
        'event_code': eventCode,
        'severity': 'error',
        'message': message,
        'occurred_at': occurredAt.toUtc().toIso8601String(),
        'merchant_id': context['merchant_id'] ?? '',
        'machine_id': context['machine_id'] ?? '',
        'session_id': context['session_id'] ?? '',
        'app_version': context['app_version'] ?? '',
        'build_number': context['build_number'] ?? '',
        'platform': context['platform'] ?? '',
        'environment': context['environment'] ?? '',
        if (flowId?.isNotEmpty ?? false) 'flow_id': flowId,
        'data': data,
        'breadcrumbs': breadcrumbs,
        if (error?.isNotEmpty ?? false) 'error': error,
        if (stackTrace?.isNotEmpty ?? false) 'stack_trace': stackTrace,
        'retry_count': retryCount,
      };
}

class IncidentOutbox {
  IncidentOutbox({Box<dynamic>? box}) : _box = box;

  static const String boxName = 'incident_outbox_v1';
  static const int maxItems = 500;
  static const int keepDays = 30;

  Box<dynamic>? _box;

  bool get isInitialized => _box?.isOpen ?? false;

  Future<void> initialize() async {
    if (isInitialized) return;
    _box = Hive.isBoxOpen(boxName)
        ? Hive.box<dynamic>(boxName)
        : await Hive.openBox<dynamic>(boxName);
    await prune();
  }

  Future<void> enqueue(PendingIncident incident) async {
    final box = _requireBox();
    await box.put(incident.incidentId, incident.toJson());
    await _enforceSizeLimit();
  }

  List<PendingIncident> pending({DateTime? now}) {
    final effectiveNow = now ?? DateTime.now();
    final incidents = _requireBox()
        .values
        .whereType<Map>()
        .map(PendingIncident.fromJson)
        .where((incident) =>
            incident.nextRetryAt == null ||
            !incident.nextRetryAt!.isAfter(effectiveNow))
        .toList();
    incidents.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return incidents;
  }

  List<PendingIncident> all() {
    final incidents = _requireBox()
        .values
        .whereType<Map>()
        .map(PendingIncident.fromJson)
        .toList();
    incidents.sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    return incidents;
  }

  Future<void> remove(String incidentId) async {
    await _requireBox().delete(incidentId);
  }

  Future<void> recordUploadFailure(
    PendingIncident incident,
    Object error,
  ) async {
    final nextRetryCount = incident.retryCount + 1;
    final updated = incident.copyWith(
      retryCount: nextRetryCount,
      nextRetryAt: DateTime.now().add(_retryDelay(nextRetryCount)),
      lastUploadError: AppLogSanitizer.text(error.toString()),
    );
    await _requireBox().put(updated.incidentId, updated.toJson());
  }

  Future<void> prune() async {
    final box = _requireBox();
    final expireBefore = DateTime.now().subtract(
      const Duration(days: keepDays),
    );
    final expiredKeys = <dynamic>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is! Map) continue;
      final incident = PendingIncident.fromJson(raw);
      if (incident.occurredAt.isBefore(expireBefore)) {
        expiredKeys.add(key);
      }
    }
    await box.deleteAll(expiredKeys);
    await _enforceSizeLimit();
  }

  Future<void> _enforceSizeLimit() async {
    final box = _requireBox();
    if (box.length <= maxItems) return;
    final ordered = all();
    final removeCount = box.length - maxItems;
    await box.deleteAll(
      ordered.take(removeCount).map((item) => item.incidentId),
    );
  }

  Box<dynamic> _requireBox() {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError('IncidentOutbox has not been initialized.');
    }
    return box;
  }

  static Duration _retryDelay(int retryCount) {
    const delays = <Duration>[
      Duration(seconds: 5),
      Duration(seconds: 30),
      Duration(minutes: 2),
      Duration(minutes: 10),
      Duration(minutes: 30),
    ];
    final index = retryCount - 1;
    return delays[index.clamp(0, delays.length - 1)];
  }
}

class IncidentReporter {
  IncidentReporter(this.outbox);

  final IncidentOutbox outbox;
  final Uuid _uuid = Uuid();
  Future<void>? _flushOperation;
  IncidentQueuedCallback? _onIncidentQueued;

  void setOnIncidentQueued(IncidentQueuedCallback? callback) {
    _onIncidentQueued = callback;
  }

  Future<PendingIncident> report({
    required String eventCode,
    required String message,
    String? flowId,
    Map<String, Object?> data = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final incidentId = _uuid.v4();
    logE(
      message,
      eventCode: eventCode,
      flowId: flowId,
      incidentId: incidentId,
      data: data,
      error: error,
      stack: stackTrace,
    );

    final incident = PendingIncident(
      incidentId: incidentId,
      eventCode: eventCode,
      message: AppLogSanitizer.text(message),
      occurredAt: DateTime.now(),
      context: CustomLogHandler.context.toJson(),
      data: AppLogSanitizer.map(data),
      breadcrumbs: CustomLogHandler.recentEntries,
      flowId: flowId,
      error: error == null ? null : AppLogSanitizer.text(error.toString()),
      stackTrace: stackTrace == null
          ? null
          : AppLogSanitizer.text(
              stackTrace.toString(),
              maxLength: 16000,
            ),
    );
    await outbox.enqueue(incident);
    final onIncidentQueued = _onIncidentQueued;
    if (onIncidentQueued != null) {
      unawaited(onIncidentQueued().catchError((_) {}));
    }
    return incident;
  }

  void capture({
    required String eventCode,
    required String message,
    String? flowId,
    Map<String, Object?> data = const <String, Object?>{},
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!outbox.isInitialized) {
      logE(
        message,
        tag: 'Incident',
        eventCode: eventCode,
        flowId: flowId,
        data: data,
        error: error,
        stack: stackTrace,
      );
      return;
    }

    unawaited(
      report(
        eventCode: eventCode,
        message: message,
        flowId: flowId,
        data: data,
        error: error,
        stackTrace: stackTrace,
      ).then<void>((_) {}).catchError(
        (Object persistError, StackTrace persistStack) {
          logE(
            'Failed to persist incident',
            tag: 'Incident',
            eventCode: 'INCIDENT_PERSIST_FAILED',
            flowId: flowId,
            data: {'original_event_code': eventCode},
            error: persistError,
            stack: persistStack,
          );
        },
      ),
    );
  }

  Future<void> flush(IncidentUploader uploader) {
    final running = _flushOperation;
    if (running != null) return running;

    final operation = _flush(uploader);
    _flushOperation = operation;
    return operation.whenComplete(() {
      _flushOperation = null;
    });
  }

  Future<void> _flush(IncidentUploader uploader) async {
    for (final incident in outbox.pending()) {
      try {
        final acknowledged = await uploader(incident);
        if (acknowledged) {
          await outbox.remove(incident.incidentId);
        } else {
          await outbox.recordUploadFailure(
            incident,
            StateError('Incident upload was not acknowledged.'),
          );
        }
      } catch (error) {
        await outbox.recordUploadFailure(incident, error);
      }
    }
  }
}

final IncidentOutbox incidentOutbox = IncidentOutbox();
final IncidentReporter incidentReporter = IncidentReporter(incidentOutbox);
