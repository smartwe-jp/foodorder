import 'dart:convert';

import 'package:logging/logging.dart';

class AppLogContext {
  const AppLogContext({
    required this.sessionId,
    this.merchantId = '',
    this.machineId = '',
    this.appVersion = '',
    this.buildNumber = '',
    this.platform = '',
    this.environment = 'production',
  });

  final String sessionId;
  final String merchantId;
  final String machineId;
  final String appVersion;
  final String buildNumber;
  final String platform;
  final String environment;

  AppLogContext copyWith({
    String? merchantId,
    String? machineId,
    String? appVersion,
    String? buildNumber,
    String? platform,
    String? environment,
  }) {
    return AppLogContext(
      sessionId: sessionId,
      merchantId: merchantId ?? this.merchantId,
      machineId: machineId ?? this.machineId,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      platform: platform ?? this.platform,
      environment: environment ?? this.environment,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'session_id': sessionId,
        if (merchantId.isNotEmpty) 'merchant_id': merchantId,
        if (machineId.isNotEmpty) 'machine_id': machineId,
        if (appVersion.isNotEmpty) 'app_version': appVersion,
        if (buildNumber.isNotEmpty) 'build_number': buildNumber,
        if (platform.isNotEmpty) 'platform': platform,
        if (environment.isNotEmpty) 'environment': environment,
      };
}

class AppLogMessage {
  static const String _transportPrefix = '\u001eAPP_LOG_V1:';

  const AppLogMessage({
    required this.message,
    this.recordType,
    this.eventCode,
    this.flowId,
    this.incidentId,
    this.data = const <String, Object?>{},
  });

  final String message;
  final String? recordType;
  final String? eventCode;
  final String? flowId;
  final String? incidentId;
  final Map<String, Object?> data;

  static AppLogMessage? tryDecode(Object? value) {
    if (value is AppLogMessage) return value;
    final encoded = value?.toString() ?? '';
    if (!encoded.startsWith(_transportPrefix)) return null;

    try {
      final decoded = jsonDecode(encoded.substring(_transportPrefix.length));
      if (decoded is! Map) return null;
      return AppLogMessage(
        message: decoded['message']?.toString() ?? '',
        recordType: decoded['record_type']?.toString(),
        eventCode: decoded['event_code']?.toString(),
        flowId: decoded['flow_id']?.toString(),
        incidentId: decoded['incident_id']?.toString(),
        data: Map<String, Object?>.from(
          decoded['data'] as Map? ?? const {},
        ),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() => '$_transportPrefix${jsonEncode(<String, Object?>{
            'message': message,
            if (recordType?.isNotEmpty ?? false) 'record_type': recordType,
            if (eventCode?.isNotEmpty ?? false) 'event_code': eventCode,
            if (flowId?.isNotEmpty ?? false) 'flow_id': flowId,
            if (incidentId?.isNotEmpty ?? false) 'incident_id': incidentId,
            if (data.isNotEmpty) 'data': AppLogSanitizer.map(data),
          })}';
}

class AppLogEntry {
  const AppLogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    required this.context,
    this.eventCode,
    this.recordType = 'log',
    this.flowId,
    this.incidentId,
    this.data = const <String, Object?>{},
    this.error,
    this.stackTrace,
  });

  factory AppLogEntry.fromRecord(
    LogRecord record,
    AppLogContext context,
  ) {
    final payload = AppLogMessage.tryDecode(record.message) ??
        AppLogMessage(message: record.message.toString());

    return AppLogEntry(
      timestamp: record.time,
      level: record.level.name,
      tag: record.loggerName,
      message: AppLogSanitizer.text(payload.message),
      recordType: payload.recordType?.trim().isNotEmpty ?? false
          ? payload.recordType!.trim()
          : 'log',
      eventCode: payload.eventCode,
      flowId: payload.flowId,
      incidentId: payload.incidentId,
      data: AppLogSanitizer.map(payload.data),
      error: record.error == null
          ? null
          : AppLogSanitizer.text(record.error.toString()),
      stackTrace: record.stackTrace == null
          ? null
          : AppLogSanitizer.text(
              record.stackTrace.toString(),
              maxLength: 16000,
            ),
      context: context,
    );
  }

  final DateTime timestamp;
  final String level;
  final String tag;
  final String message;
  final String recordType;
  final String? eventCode;
  final String? flowId;
  final String? incidentId;
  final Map<String, Object?> data;
  final String? error;
  final String? stackTrace;
  final AppLogContext context;

  Map<String, Object?> toJson() => <String, Object?>{
        'timestamp': timestamp.toIso8601String(),
        'level': level,
        'tag': tag,
        if (eventCode?.isNotEmpty ?? false) 'event_code': eventCode,
        'message': message,
        ...context.toJson(),
        if (flowId?.isNotEmpty ?? false) 'flow_id': flowId,
        if (incidentId?.isNotEmpty ?? false) 'incident_id': incidentId,
        if (data.isNotEmpty) 'data': data,
        if (error?.isNotEmpty ?? false) 'error': error,
        if (stackTrace?.isNotEmpty ?? false) 'stack_trace': stackTrace,
      };

  Map<String, Object?> toOpenObserveJson({required String eventId}) =>
      <String, Object?>{
        ...toJson(),
        ..._openObserveDimensions,
        'schema_version': 1,
        'record_type': recordType,
        'event_id': eventId,
        '_timestamp': timestamp.toUtc().toIso8601String(),
        'timestamp': timestamp.toUtc().toIso8601String(),
        'severity': _severity,
      };

  Map<String, Object?> get _openObserveDimensions {
    const searchableKeys = <String>{
      'order_id',
      'payment_method',
      'payment_method_code',
      'event_status',
      'stage',
      'attempt',
      'amount',
      'duration_ms',
      'failure_type',
      'result_code',
      'result_sub_code',
      'response_code',
      'will_retry',
      'change_amount',
      'inserted_amount',
      'operation',
      'print_type',
      'is_scan_checkout',
      'has_kitchen_print',
      'confirm_count',
      'method',
      'path',
      'status_code',
      'dio_error_type',
      'cash_device',
      'recovery_exhausted',
      'listener_type',
      'shop_name',
      'logo_image_url',
      'machine_type',
      'device_status',
      'heartbeat_interval_seconds',
    };
    return <String, Object?>{
      for (final entry in data.entries)
        if (searchableKeys.contains(entry.key) && entry.value != null)
          entry.key: entry.value,
    };
  }

  String get _severity {
    switch (level) {
      case 'SHOUT':
        return 'fatal';
      case 'SEVERE':
        return 'error';
      case 'WARNING':
        return 'warning';
      case 'INFO':
        return 'info';
      default:
        return level.toLowerCase();
    }
  }

  String toJsonLine() => jsonEncode(toJson());
}

class AppLogSanitizer {
  static final RegExp _sensitiveKey = RegExp(
    r'(authorization|access[_-]?token|refresh[_-]?token|password|secret|api[_-]?key|card[_-]?number|cvv|qr[_-]?code|customer[_-]?(phone|email))',
    caseSensitive: false,
  );
  static final RegExp _bearerToken = RegExp(
    r'Bearer\s+[A-Za-z0-9._~+/=-]+',
    caseSensitive: false,
  );
  static final RegExp _inlineSecret = RegExp(
    r'((?:authorization|token|password|secret|api[_-]?key)\s*[:=]\s*)[^,\s}\]]+',
    caseSensitive: false,
  );

  static String text(String value, {int maxLength = 4000}) {
    var sanitized = value.replaceAll(_bearerToken, 'Bearer [REDACTED]');
    sanitized = sanitized.replaceAllMapped(
      _inlineSecret,
      (match) => '${match.group(1)}[REDACTED]',
    );
    if (sanitized.length <= maxLength) return sanitized;
    return '${sanitized.substring(0, maxLength)}...[TRUNCATED]';
  }

  static Map<String, Object?> map(Map values) {
    return _sanitizeMap(values, depth: 0);
  }

  static Map<String, Object?> _sanitizeMap(Map values, {required int depth}) {
    if (depth >= 6) return const <String, Object?>{'value': '[MAX_DEPTH]'};
    final result = <String, Object?>{};
    values.forEach((key, value) {
      final normalizedKey = key.toString();
      result[normalizedKey] = _sensitiveKey.hasMatch(normalizedKey)
          ? '[REDACTED]'
          : _sanitizeValue(value, depth: depth + 1);
    });
    return result;
  }

  static Object? _sanitizeValue(Object? value, {required int depth}) {
    if (value == null || value is num || value is bool) return value;
    if (value is String) return text(value, maxLength: 2000);
    if (value is Map) return _sanitizeMap(value, depth: depth);
    if (value is Iterable) {
      return value
          .take(100)
          .map((item) => _sanitizeValue(item, depth: depth + 1))
          .toList(growable: false);
    }
    return text(value.toString(), maxLength: 2000);
  }
}
