import 'dart:async';

import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'app_log_models.dart';

typedef AppEventBatchUploader = Future<bool> Function(
  List<Map<String, Object?>> events,
);
typedef AppEventQueuedCallback = Future<void> Function();

class PendingAppEvent {
  const PendingAppEvent({
    required this.eventId,
    required this.occurredAt,
    required this.payload,
    this.queueSequence = 0,
    this.retryCount = 0,
    this.nextRetryAt,
    this.lastUploadError,
  });

  factory PendingAppEvent.fromJson(Map values) {
    return PendingAppEvent(
      eventId: values['event_id']?.toString() ?? '',
      occurredAt: DateTime.tryParse(values['occurred_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      payload: Map<String, Object?>.from(
        values['payload'] as Map? ?? const {},
      ),
      queueSequence: values['queue_sequence'] as int? ?? 0,
      retryCount: values['retry_count'] as int? ?? 0,
      nextRetryAt: DateTime.tryParse(
        values['next_retry_at']?.toString() ?? '',
      ),
      lastUploadError: values['last_upload_error']?.toString(),
    );
  }

  final String eventId;
  final DateTime occurredAt;
  final Map<String, Object?> payload;
  final int queueSequence;
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? lastUploadError;

  PendingAppEvent copyWith({
    int? retryCount,
    DateTime? nextRetryAt,
    String? lastUploadError,
  }) {
    return PendingAppEvent(
      eventId: eventId,
      occurredAt: occurredAt,
      payload: payload,
      queueSequence: queueSequence,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastUploadError: lastUploadError ?? this.lastUploadError,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'event_id': eventId,
        'occurred_at': occurredAt.toIso8601String(),
        'payload': payload,
        'queue_sequence': queueSequence,
        'retry_count': retryCount,
        if (nextRetryAt != null)
          'next_retry_at': nextRetryAt!.toIso8601String(),
        if (lastUploadError?.isNotEmpty ?? false)
          'last_upload_error': lastUploadError,
      };
}

class AppEventOutbox {
  AppEventOutbox({Box<dynamic>? box}) : _box = box;

  static const String boxName = 'app_event_outbox_v1';
  static const int maxItems = 10000;
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

  Future<void> enqueue(PendingAppEvent event) async {
    await _requireBox().put(event.eventId, event.toJson());
    await _enforceSizeLimit();
  }

  List<PendingAppEvent> pending({
    DateTime? now,
    int limit = 100,
  }) {
    final effectiveNow = now ?? DateTime.now();
    final events = _all()
        .where((event) =>
            event.nextRetryAt == null ||
            !event.nextRetryAt!.isAfter(effectiveNow))
        .take(limit)
        .toList(growable: false);
    return events;
  }

  int get length => _requireBox().length;

  Future<void> removeAll(Iterable<String> eventIds) {
    return _requireBox().deleteAll(eventIds);
  }

  Future<void> recordUploadFailure(
    Iterable<PendingAppEvent> events,
    Object error,
  ) async {
    final box = _requireBox();
    final sanitizedError = AppLogSanitizer.text(error.toString());
    for (final event in events) {
      final nextRetryCount = event.retryCount + 1;
      final updated = event.copyWith(
        retryCount: nextRetryCount,
        nextRetryAt: DateTime.now().add(_retryDelay(nextRetryCount)),
        lastUploadError: sanitizedError,
      );
      await box.put(updated.eventId, updated.toJson());
    }
  }

  Future<void> prune() async {
    final expireBefore = DateTime.now().subtract(
      const Duration(days: keepDays),
    );
    final expiredIds = _all()
        .where((event) => event.occurredAt.isBefore(expireBefore))
        .map((event) => event.eventId);
    await _requireBox().deleteAll(expiredIds);
    await _enforceSizeLimit();
  }

  List<PendingAppEvent> _all() {
    final events = _requireBox()
        .values
        .whereType<Map>()
        .map(PendingAppEvent.fromJson)
        .toList();
    events.sort((a, b) {
      if (a.queueSequence > 0 && b.queueSequence > 0) {
        return a.queueSequence.compareTo(b.queueSequence);
      }
      final occurredAtComparison = a.occurredAt.compareTo(b.occurredAt);
      if (occurredAtComparison != 0) return occurredAtComparison;
      return a.eventId.compareTo(b.eventId);
    });
    return events;
  }

  Future<void> _enforceSizeLimit() async {
    final box = _requireBox();
    if (box.length <= maxItems) return;
    final removeCount = box.length - maxItems;
    await box.deleteAll(
      _all().take(removeCount).map((event) => event.eventId),
    );
  }

  Box<dynamic> _requireBox() {
    final box = _box;
    if (box == null || !box.isOpen) {
      throw StateError('AppEventOutbox has not been initialized.');
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
    return delays[(retryCount - 1).clamp(0, delays.length - 1)];
  }
}

class AppEventReporter {
  AppEventReporter(this.outbox);

  static const int maxPreInitializeEvents = 500;
  static const int uploadBatchSize = 100;

  final AppEventOutbox outbox;
  final Uuid _uuid = const Uuid();
  final List<AppLogEntry> _preInitializeEntries = <AppLogEntry>[];

  Future<void> _persistChain = Future<void>.value();
  Future<void>? _flushOperation;
  AppEventQueuedCallback? _onEventQueued;
  bool _initialized = false;
  int _lastQueueSequence = 0;

  void record(AppLogEntry entry) {
    if (!_initialized) {
      _preInitializeEntries.add(entry);
      if (_preInitializeEntries.length > maxPreInitializeEvents) {
        _preInitializeEntries.removeAt(0);
      }
      return;
    }
    _queuePersist(entry);
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    final buffered = List<AppLogEntry>.from(_preInitializeEntries);
    _preInitializeEntries.clear();
    for (final entry in buffered) {
      _queuePersist(entry);
    }
    await flushPersistence();
  }

  void setOnEventQueued(AppEventQueuedCallback? callback) {
    _onEventQueued = callback;
  }

  Future<void> flushPersistence() => _persistChain;

  Future<void> flush(AppEventBatchUploader uploader) {
    final running = _flushOperation;
    if (running != null) return running;

    final operation = _flush(uploader);
    _flushOperation = operation;
    return operation.whenComplete(() {
      _flushOperation = null;
    });
  }

  void _queuePersist(AppLogEntry entry) {
    _persistChain = _persistChain.then((_) async {
      final eventId = _uuid.v4();
      final nowSequence = DateTime.now().microsecondsSinceEpoch;
      final queueSequence = nowSequence > _lastQueueSequence
          ? nowSequence
          : _lastQueueSequence + 1;
      _lastQueueSequence = queueSequence;
      await outbox.enqueue(
        PendingAppEvent(
          eventId: eventId,
          occurredAt: entry.timestamp,
          payload: entry.toOpenObserveJson(eventId: eventId),
          queueSequence: queueSequence,
        ),
      );
      await _onEventQueued?.call();
    }).catchError((_) {
      // Local file logging must keep working if the event outbox fails.
    });
  }

  Future<void> _flush(AppEventBatchUploader uploader) async {
    await flushPersistence();
    while (true) {
      final events = outbox.pending(limit: uploadBatchSize);
      if (events.isEmpty) return;
      try {
        final acknowledged = await uploader(
          events.map((event) => event.payload).toList(growable: false),
        );
        if (!acknowledged) {
          await outbox.recordUploadFailure(
            events,
            StateError('App event batch was not acknowledged.'),
          );
          return;
        }
        await outbox.removeAll(events.map((event) => event.eventId));
      } catch (error) {
        await outbox.recordUploadFailure(events, error);
        return;
      }
    }
  }
}

final AppEventOutbox appEventOutbox = AppEventOutbox();
final AppEventReporter appEventReporter = AppEventReporter(appEventOutbox);
