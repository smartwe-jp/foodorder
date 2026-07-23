import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'app_log_models.dart';

Logger l([String name = 'App']) => Logger(name);

void logI(
  Object msg, {
  String tag = 'App',
  String? eventCode,
  String? flowId,
  String? incidentId,
  Map<String, Object?> data = const <String, Object?>{},
}) {
  Logger(tag).info(
    AppLogMessage(
      message: msg.toString(),
      eventCode: eventCode,
      flowId: flowId,
      incidentId: incidentId,
      data: data,
    ),
  );
}

void logW(
  Object msg, {
  String tag = 'App',
  String? eventCode,
  String? flowId,
  String? incidentId,
  Map<String, Object?> data = const <String, Object?>{},
  Object? error,
  StackTrace? stack,
}) {
  Logger(tag).warning(
    AppLogMessage(
      message: msg.toString(),
      eventCode: eventCode,
      flowId: flowId,
      incidentId: incidentId,
      data: data,
    ),
    error,
    stack,
  );
}

void logE(
  Object msg, {
  String tag = 'App',
  String? eventCode,
  String? flowId,
  String? incidentId,
  Map<String, Object?> data = const <String, Object?>{},
  Object? error,
  StackTrace? stack,
}) {
  Logger(tag).severe(
    AppLogMessage(
      message: msg.toString(),
      eventCode: eventCode,
      flowId: flowId,
      incidentId: incidentId,
      data: data,
    ),
    error,
    stack,
  );
}

extension LogExt on Object {
  Logger get logger => Logger(runtimeType.toString());

  void infoLog(Object msg) => logI(msg, tag: runtimeType.toString());

  void warnLog(
    Object msg, {
    Object? error,
    StackTrace? stack,
  }) =>
      logW(
        msg,
        tag: runtimeType.toString(),
        error: error,
        stack: stack,
      );

  void errorLog(
    Object msg, {
    Object? error,
    StackTrace? stack,
  }) =>
      logE(
        msg,
        tag: runtimeType.toString(),
        error: error,
        stack: stack,
      );
}

class CustomLogHandler {
  static const int maxRecentEntries = 200;
  static const int keepLogDays = 7;

  static final List<AppLogEntry> _recentEntries = <AppLogEntry>[];
  static final Uuid _uuid = Uuid();

  static late File _logFile;
  static late String _logFileName;
  static late DateTime _currentDate;
  static late Directory _logDirectory;
  static StreamSubscription<LogRecord>? _recordSubscription;
  static Future<void> _writeChain = Future<void>.value();
  static bool _initialized = false;
  static void Function(AppLogEntry entry)? _eventSink;

  static AppLogContext _context = AppLogContext(
    sessionId: _uuid.v4(),
    platform: Platform.operatingSystem,
  );

  static AppLogContext get context => _context;

  static List<Map<String, Object?>> get recentEntries => _recentEntries
      .map((entry) => Map<String, Object?>.from(entry.toJson()))
      .toList(growable: false);

  static String newFlowId() => _uuid.v4();

  static void setEventSink(void Function(AppLogEntry entry)? sink) {
    _eventSink = sink;
  }

  static void configureContext({
    String? merchantId,
    String? machineId,
    String? appVersion,
    String? buildNumber,
    String? platform,
    String? environment,
  }) {
    _context = _context.copyWith(
      merchantId: merchantId,
      machineId: machineId,
      appVersion: appVersion,
      buildNumber: buildNumber,
      platform: platform,
      environment: environment,
    );
  }

  static Future<void> initializeLogging() async {
    if (_initialized) return;

    final appSupportDirectory = await getApplicationSupportDirectory();
    _logDirectory = Directory(
      '${appSupportDirectory.path}${Platform.pathSeparator}logs',
    );
    if (!await _logDirectory.exists()) {
      await _logDirectory.create(recursive: true);
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      configureContext(
        appVersion: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
      );
    } catch (_) {
      // Logging must still start even when package metadata is unavailable.
    }

    _currentDate = DateTime.now();
    await _createNewLogFile();
    await _deleteExpiredLogs();

    Logger.root.level = Level.ALL;
    _recordSubscription = Logger.root.onRecord.listen(_handleRecord);
    _initialized = true;

    logI(
      'Logger initialized',
      tag: 'Bootstrap',
      eventCode: 'LOGGER_INITIALIZED',
    );
  }

  static void _handleRecord(LogRecord record) {
    final entry = AppLogEntry.fromRecord(record, _context);
    _recentEntries.add(entry);
    if (_recentEntries.length > maxRecentEntries) {
      _recentEntries.removeRange(0, _recentEntries.length - maxRecentEntries);
    }
    _eventSink?.call(entry);

    final jsonLine = entry.toJsonLine();
    stdout.writeln(jsonLine);
    _writeChain = _writeChain.then((_) => _writeToFile(jsonLine)).catchError(
      (Object error, StackTrace stackTrace) {
        stderr.writeln('Logger file write failed: $error');
      },
    );
  }

  static Future<void> _createNewLogFile() async {
    final dateStr = DateFormat('yyyyMMdd').format(_currentDate);
    _logFileName = 'app_log_$dateStr.txt';
    _logFile = File(
      '${_logDirectory.path}${Platform.pathSeparator}$_logFileName',
    );

    if (!await _logFile.exists()) {
      await _logFile.create(recursive: true);
    }
  }

  static Future<void> _writeToFile(String message) async {
    final now = DateTime.now();
    if (!_isSameDay(now, _currentDate)) {
      _currentDate = now;
      await _createNewLogFile();
      await _deleteExpiredLogs();
    }

    await _logFile.writeAsString('$message\n', mode: FileMode.append);
  }

  static Future<void> _deleteExpiredLogs() async {
    final expireBefore = DateTime.now().subtract(
      const Duration(days: keepLogDays),
    );
    await for (final entity in _logDirectory.list()) {
      if (entity is! File || !entity.path.contains('app_log_')) continue;
      try {
        final modifiedAt = await entity.lastModified();
        if (modifiedAt.isBefore(expireBefore)) {
          await entity.delete();
        }
      } catch (_) {
        // A cleanup failure must never interfere with application startup.
      }
    }
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static Future<void> flush() => _writeChain;

  static Future<String> exportLogs() async {
    await flush();
    final tempDirectory = await getTemporaryDirectory();
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayStr = DateFormat('yyyyMMdd').format(today);
    final yesterdayStr = DateFormat('yyyyMMdd').format(yesterday);

    final todayLog = File(
      '${_logDirectory.path}${Platform.pathSeparator}app_log_$todayStr.txt',
    );
    final yesterdayLog = File(
      '${_logDirectory.path}${Platform.pathSeparator}app_log_$yesterdayStr.txt',
    );

    final exportFilePath =
        '${tempDirectory.path}${Platform.pathSeparator}exported_logs_${todayStr}_$yesterdayStr.txt';
    final exportFile = File(exportFilePath);

    final buffer = StringBuffer();
    if (await yesterdayLog.exists()) {
      buffer.writeln(await yesterdayLog.readAsString());
    }
    if (await todayLog.exists()) {
      buffer.write(await todayLog.readAsString());
    }

    await exportFile.writeAsString(buffer.toString());
    return exportFilePath;
  }

  static Future<void> clearLogs() async {
    await flush();
    _recentEntries.clear();
    if (await _logFile.exists()) {
      await _logFile.writeAsString('');
    }
  }

  static Future<void> dispose() async {
    await flush();
    await _recordSubscription?.cancel();
    _recordSubscription = null;
    _initialized = false;
  }
}
