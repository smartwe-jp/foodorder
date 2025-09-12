// dart
import 'dart:io';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:path_provider/path_provider.dart';

// class FileLogOutput implements LogOutput {
//   final File _file;
//   FileLogOutput._(this._file);
//
//   static Future<FileLogOutput> create(String filename) async {
//     final dir = await getApplicationDocumentsDirectory();
//     final file = File('${dir.path}/$filename');
//     if (!file.existsSync()) file.createSync(recursive: true);
//     return FileLogOutput._(file);
//   }
//
//   @override
//   void output(List<String> lines) {
//     final text = lines.join('\n') + '\n';
//     // synchronous append to avoid async signature issues in LogOutput
//     _file.writeAsStringSync(text, mode: FileMode.append, flush: true);
//   }
// }

class LogService extends GetxService {
  final File _file;
  final String _filename;

  LogService._(this._file, this._filename);

  /// Initialize and return the singleton LogService.
  /// Use: await Get.putAsync<LogService>(() => LogService.init());
  static Future<LogService> init({String filename = 'app.log'}) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    if (!file.existsSync()) {
      await file.create(recursive: true);
    }
    return LogService._(file, filename);
  }

  String _timestamp() {
    final now = DateTime.now();
    // Format: yyyy-MM-dd HH:mm (no seconds)
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  Future<void> _write(String level, String message) async {
    final line = '[${_timestamp()}] [$level] $message';
    await _file.writeAsString(line + '\n', mode: FileMode.append, flush: true);
  }

  Future<void> d(String message) async => await _write('DEBUG', message);
  Future<void> i(String message) async => await _write('INFO', message);
  Future<void> w(String message) async => await _write('WARN', message);
  Future<void> e(String message, [Object? error, StackTrace? st]) async {
    var full = message;
    if (error != null) full += ' | error: $error';
    if (st != null) full += ' | stack: ${st.toString()}';
    await _write('ERROR', full);
  }

  Future<File> exportFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_filename');
  }

  Future<void> clear() async {
    await _file.writeAsString('');
  }

  @override
  void onClose() {
    // nothing to dispose for File, but override if needed later
    super.onClose();
  }
}