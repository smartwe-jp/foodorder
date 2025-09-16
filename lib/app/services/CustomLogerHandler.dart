import 'dart:io';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

Logger l([String name = 'App']) => Logger(name);

// 级别快捷方法
void logI(Object msg, {String tag = 'App'}) => Logger(tag).info(msg);
void logW(Object msg, {String tag = 'App'}) => Logger(tag).warning(msg);
void logE(Object msg, {String tag = 'App', Object? error, StackTrace? stack}) =>
    Logger(tag).severe(msg, error, stack);

// 给任意对象用的扩展
extension LogExt on Object {
  Logger get logger => Logger(runtimeType.toString());
  void infoLog(Object msg) => logger.info(msg);
  void warnLog(Object msg) => logger.warning(msg);
  void errorLog(Object msg, {Object? error, StackTrace? stack}) =>
      logger.severe(msg, error, stack);
}

class CustomLogHandler {
  static late File _logFile;
  static late String _logFileName;
  static late DateTime _currentDate;
  static late Directory _appDocDir;

  static Future<void> initializeLogging() async {
    _appDocDir = await getTemporaryDirectory();
    _currentDate = DateTime.now();
    await _createNewLogFile();

    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      final logMessage =
          '${record.time}: ${record.level.name}: ${record.message}';
      _writeToFile(logMessage);
      print(logMessage); // 同时在控制台输出
      print('Log file path: $_appDocDir');
    });
  }

  static Future<void> _createNewLogFile() async {
    final dateStr = DateFormat('yyyyMMdd').format(_currentDate);
    _logFileName = 'app_log_$dateStr.txt';
    final logFilePath = '${_appDocDir.path}/$_logFileName';
    _logFile = File(logFilePath);

    if (!await _logFile.exists()) {
      await _logFile.create();
    }
  }

  static Future<void> _writeToFile(String message) async {

    final now = DateTime.now();
    if (!_isSameDay(now, _currentDate)) {
      _currentDate = now;
      await _createNewLogFile();
    }

    _logFile.writeAsStringSync('$message\n', mode: FileMode.append);
  }

  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  static Future<String> exportLogs() async {
    final appDocDir = await getTemporaryDirectory();
    final today = DateTime.now();
    final yesterday = today.subtract(Duration(days: 1));

    final todayStr = DateFormat('yyyyMMdd').format(today);
    final yesterdayStr = DateFormat('yyyyMMdd').format(yesterday);

    final todayLog = File('${appDocDir.path}/app_log_$todayStr.txt');
    final yesterdayLog = File('${appDocDir.path}/app_log_$yesterdayStr.txt');

    final exportFilePath =
        '${appDocDir.path}/exported_logs_${todayStr}_$yesterdayStr.txt';
    final exportFile = File(exportFilePath);

    // 合并昨天和今天的日志
    String combinedLogs = '';
    if (await yesterdayLog.exists()) {
      combinedLogs += await yesterdayLog.readAsString();
      combinedLogs += '\n';
    }
    if (await todayLog.exists()) {
      combinedLogs += await todayLog.readAsString();
    }

    // 写入合并后的日志到导出文件
    await exportFile.writeAsString(combinedLogs);

    return exportFilePath;
  }

  static Future<void> clearLogs() async {
    await _logFile.writeAsString('');
  }
}
