import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

const _variants = {'android7', 'android11', 'windows'};
const _environments = {'dev', 'prod'};

final _root = Directory(
  File(Platform.script.toFilePath()).parent.parent.path,
);
final _backupDirectory = Directory(
  '${_root.path}${Platform.pathSeparator}.dart_tool'
  '${Platform.pathSeparator}variant_runner_backup',
);
final _ownerPidFile = File('${_backupDirectory.path}/owner.pid');
final _childPidFile = File('${_backupDirectory.path}/child.pid');

const _snapshotPaths = <String>[
  'pubspec.yaml',
  'pubspec.lock',
  '.flutter-plugins',
  '.flutter-plugins-dependencies',
  'android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java',
  'ios/Runner/GeneratedPluginRegistrant.m',
  'macos/Flutter/GeneratedPluginRegistrant.swift',
  'linux/flutter/generated_plugin_registrant.cc',
  'linux/flutter/generated_plugin_registrant.h',
  'linux/flutter/generated_plugins.cmake',
  'windows/flutter/generated_plugin_registrant.cc',
  'windows/flutter/generated_plugin_registrant.h',
  'windows/flutter/generated_plugins.cmake',
];

Future<void> main(List<String> arguments) async {
  try {
    await _main(arguments);
  } on _VariantException {
    // _fail already printed the actionable message and set exitCode.
  }
}

Future<void> _main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.contains('--help')) {
    _printUsage();
    return;
  }

  final command = arguments.first;
  if (command == 'restore') {
    if (await _backupHasActiveProcess()) {
      _fail(
        'A variant run or build is still active. Stop it before restoring.',
      );
    }
    await _restoreBackup(refreshPackages: true);
    return;
  }

  if (arguments.length < 2) {
    _fail('Missing variant name.');
  }

  final variant = arguments[1];
  _requireVariant(variant);

  switch (command) {
    case 'resolve':
      await _resolveVariant(variant);
    case 'run':
      final options = _parseRunOptions(arguments.skip(2).toList());
      await _runVariant(variant, options);
    case 'build-apk':
      if (variant == 'windows') {
        _fail('build-apk only supports android7 and android11.');
      }
      final options = _parseRunOptions(arguments.skip(2).toList());
      await _buildApkVariant(variant, options);
    case 'build-windows':
      if (variant != 'windows') {
        _fail('build-windows only supports the windows variant.');
      }
      final options = _parseRunOptions(arguments.skip(2).toList());
      await _buildWindowsVariant(options);
    default:
      _fail('Unknown command "$command".');
  }
}

Future<void> _resolveVariant(String variant) async {
  await _prepareBackup();
  try {
    await _activateVariant(variant, useVariantLock: false);
    final result = await _runFvm(
      const ['flutter', 'pub', 'get'],
    );
    if (result != 0) {
      _fail('Dependency resolution failed for $variant.', result);
    }

    final source = File('${_root.path}/pubspec.lock');
    final destination = File('${_root.path}/variants/locks/$variant.lock');
    destination.parent.createSync(recursive: true);
    source.copySync(destination.path);
    stdout.writeln('Updated ${destination.path}');
  } finally {
    await _restoreBackup(refreshPackages: true);
  }
}

Future<void> _runVariant(String variant, _RunOptions options) async {
  await _prepareBackup();
  var result = 1;

  try {
    await _activateVariant(variant, useVariantLock: true);

    result = await _runFvm(
      const ['flutter', 'pub', 'get', '--enforce-lockfile'],
    );
    if (result != 0) {
      _fail(
        'The $variant lock file is stale. '
        'Run: fvm dart run tool/variant.dart resolve $variant',
        result,
      );
    }

    final flutterArguments = <String>[
      'flutter',
      'run',
      '-t',
      'lib/main.dart',
      if (options.release) '--release',
      '--dart-define=APP_ENV=${options.environment}',
      '--dart-define=APP_VARIANT=$variant',
      ...options.forwardedArguments,
    ];

    stdout.writeln(
      'Running variant=$variant env=${options.environment} '
      'mode=${options.release ? 'release' : 'debug'}',
    );
    result = await _runFvm(flutterArguments, forwardSignals: true);
  } finally {
    await _restoreBackup(refreshPackages: true);
  }

  exitCode = result;
}

Future<void> _buildApkVariant(String variant, _RunOptions options) async {
  await _prepareBackup();
  var result = 1;

  try {
    await _activateVariant(variant, useVariantLock: true);

    result = await _runFvm(
      const ['flutter', 'pub', 'get', '--enforce-lockfile'],
    );
    if (result != 0) {
      _fail(
        'The $variant lock file is stale. '
        'Run: fvm dart run tool/variant.dart resolve $variant',
        result,
      );
    }

    final flutterArguments = <String>[
      'flutter',
      'build',
      'apk',
      options.release ? '--release' : '--debug',
      '--dart-define=APP_ENV=${options.environment}',
      '--dart-define=APP_VARIANT=$variant',
      ...options.forwardedArguments,
    ];

    stdout.writeln(
      'Building variant=$variant env=${options.environment} '
      'mode=${options.release ? 'release' : 'debug'}',
    );
    result = await _runFvm(flutterArguments, forwardSignals: true);
    if (result == 0) {
      _preserveApkArtifact(variant, release: options.release);
    }
  } finally {
    await _restoreBackup(refreshPackages: true);
  }

  exitCode = result;
}

void _preserveApkArtifact(String variant, {required bool release}) {
  final source = File(
    '${_root.path}/build/app/outputs/flutter-apk/'
    'app-${release ? 'release' : 'debug'}.apk',
  );
  if (!source.existsSync()) {
    _fail('Built APK was not found: ${source.path}');
  }

  final manifest = loadYaml(
    File('${_root.path}/pubspec.yaml').readAsStringSync(),
  );
  if (manifest is! YamlMap) {
    _fail('Cannot read package information from pubspec.yaml.');
  }

  final appName = (manifest['appName'] ?? manifest['name']).toString();
  final version = manifest['version'].toString().split('+').first;
  final suffix = switch (variant) {
    'android7' => 'Android7',
    'android11' => 'Android11',
    _ => variant,
  };
  final mode = release ? 'release' : 'debug';
  final destination = File(
    '${_root.path}/build/releases/'
    '${appName}_${version}_${suffix}_$mode.apk',
  );

  destination.parent.createSync(recursive: true);
  source.copySync(destination.path);
  stdout.writeln('Saved APK: ${destination.path}');
}

Future<void> _buildWindowsVariant(_RunOptions options) async {
  const variant = 'windows';
  await _prepareBackup();
  var result = 1;

  try {
    await _activateVariant(variant, useVariantLock: true);

    result = await _runFvm(
      const ['flutter', 'pub', 'get', '--enforce-lockfile'],
    );
    if (result != 0) {
      _fail(
        'The windows lock file is stale. '
        'Run: fvm dart run tool/variant.dart resolve windows',
        result,
      );
    }

    final flutterArguments = <String>[
      'flutter',
      'build',
      'windows',
      options.release ? '--release' : '--debug',
      '--dart-define=APP_ENV=${options.environment}',
      '--dart-define=APP_VARIANT=windows',
      ...options.forwardedArguments,
    ];

    stdout.writeln(
      'Building variant=windows env=${options.environment} '
      'mode=${options.release ? 'release' : 'debug'}',
    );
    result = await _runFvm(flutterArguments, forwardSignals: true);
  } finally {
    await _restoreBackup(refreshPackages: true);
  }

  exitCode = result;
}

Future<void> _activateVariant(
  String variant, {
  required bool useVariantLock,
}) async {
  final overlay = File('${_root.path}/variants/$variant.yaml');
  if (!overlay.existsSync()) {
    _fail('Missing variant overlay: ${overlay.path}');
  }

  final rootManifest = File('${_root.path}/pubspec.yaml');
  final manifestContents = _composeVariantManifest(
    variant,
    rootContents: rootManifest.readAsStringSync(),
    overlayContents: overlay.readAsStringSync(),
  );
  _validateManifest(variant, manifestContents);
  rootManifest.writeAsStringSync(manifestContents, flush: true);
  stdout
      .writeln('Composed pubspec.yaml from common config + $variant overlay.');
  _cleanGeneratedPluginSymlinks();

  if (!useVariantLock) {
    return;
  }

  final lock = File('${_root.path}/variants/locks/$variant.lock');
  if (!lock.existsSync()) {
    _fail(
      'Missing lock file for $variant. '
      'Run: fvm dart run tool/variant.dart resolve $variant',
    );
  }
  lock.copySync('${_root.path}/pubspec.lock');
}

String _composeVariantManifest(
  String variant, {
  required String rootContents,
  required String overlayContents,
}) {
  _validateVariantOverlay(variant, overlayContents);

  final root = loadYaml(rootContents);
  if (root is! YamlMap || root['dependencies'] is! YamlMap) {
    _fail('Root pubspec.yaml must contain a dependencies map.');
  }

  final lineEnding = rootContents.contains('\r\n') ? '\r\n' : '\n';
  final hadTrailingLineEnding = rootContents.endsWith(lineEnding);
  final lines = rootContents.split(RegExp(r'\r?\n'));
  if (hadTrailingLineEnding && lines.isNotEmpty && lines.last.isEmpty) {
    lines.removeLast();
  }

  final dependenciesStart = lines.indexWhere(
    (line) => RegExp(r'^dependencies\s*:\s*(?:#.*)?$').hasMatch(line),
  );
  if (dependenciesStart < 0) {
    _fail('Cannot locate dependencies in pubspec.yaml.');
  }

  var dependenciesEnd = _findTopLevelSectionEnd(
    lines,
    dependenciesStart + 1,
  );
  final platformDependency = RegExp(r'^  (paycube_old|paycube)\s*:');

  for (var index = dependenciesEnd - 1; index > dependenciesStart; index--) {
    if (!platformDependency.hasMatch(lines[index])) {
      continue;
    }

    var blockEnd = index + 1;
    while (blockEnd < dependenciesEnd) {
      final line = lines[blockEnd];
      final trimmed = line.trimLeft();
      if (trimmed.isNotEmpty &&
          !trimmed.startsWith('#') &&
          line.length - trimmed.length <= 2) {
        break;
      }
      blockEnd++;
    }
    lines.removeRange(index, blockEnd);
    dependenciesEnd -= blockEnd - index;
  }

  final overlayLines = overlayContents.split(RegExp(r'\r?\n'));
  final overlayDependenciesStart = overlayLines.indexWhere(
    (line) => RegExp(r'^dependencies\s*:').hasMatch(line),
  );
  final dependencyLines = overlayLines
      .skip(overlayDependenciesStart + 1)
      .where((line) => line.trim().isNotEmpty)
      .toList(growable: false);
  lines.insertAll(dependenciesEnd, dependencyLines);

  final result = lines.join(lineEnding);
  return hadTrailingLineEnding ? '$result$lineEnding' : result;
}

int _findTopLevelSectionEnd(List<String> lines, int start) {
  for (var index = start; index < lines.length; index++) {
    final line = lines[index];
    final trimmed = line.trimLeft();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    if (trimmed.length == line.length) {
      return index;
    }
  }
  return lines.length;
}

void _validateVariantOverlay(String variant, String contents) {
  final yaml = loadYaml(contents);
  if (yaml is! YamlMap ||
      yaml.keys.any((key) => key != 'dependencies') ||
      yaml['dependencies'] is! YamlMap) {
    _fail(
      'Variant overlay $variant may only contain a dependencies map.',
    );
  }

  final dependencies = yaml['dependencies'] as YamlMap;
  final unsupported = dependencies.keys.where(
    (key) => key != 'paycube_old' && key != 'paycube',
  );
  if (unsupported.isNotEmpty) {
    _fail(
      'Variant overlay $variant contains unsupported dependencies: '
      '${unsupported.join(', ')}.',
    );
  }

  final hasOld = dependencies.containsKey('paycube_old');
  final hasNew = dependencies.containsKey('paycube');
  final valid = switch (variant) {
    'android7' => hasOld && !hasNew,
    'android11' => !hasOld && hasNew,
    'windows' => !hasOld && !hasNew,
    _ => false,
  };
  if (!valid) {
    _fail(
      'Variant overlay $variant has an invalid PayCube selection '
      '(paycube_old=$hasOld, paycube=$hasNew).',
    );
  }
}

void _cleanGeneratedPluginSymlinks() {
  const paths = <String>[
    'linux/flutter/ephemeral/.plugin_symlinks',
    'macos/Flutter/ephemeral/.plugin_symlinks',
    'windows/flutter/ephemeral/.plugin_symlinks',
  ];

  for (final path in paths) {
    final directory = Directory('${_root.path}/$path');
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
  }
}

void _validateManifest(String variant, String contents) {
  final yaml = loadYaml(contents);
  if (yaml is! YamlMap || yaml['dependencies'] is! YamlMap) {
    _fail('Invalid pubspec variant: $variant');
  }

  final dependencies = yaml['dependencies'] as YamlMap;
  final hasOld = dependencies.containsKey('paycube_old');
  final hasNew = dependencies.containsKey('paycube');

  final valid = switch (variant) {
    'android7' => hasOld && !hasNew,
    'android11' => !hasOld && hasNew,
    'windows' => !hasOld && !hasNew,
    _ => false,
  };

  if (!valid) {
    _fail(
      'Variant $variant has an invalid PayCube dependency selection '
      '(paycube_old=$hasOld, paycube=$hasNew).',
    );
  }
}

Future<void> _prepareBackup() async {
  if (_backupDirectory.existsSync()) {
    if (await _backupHasActiveProcess()) {
      _fail(
        'Another variant run or build is still active. '
        'Stop it before starting a new one.',
      );
    }

    stdout.writeln('Recovering a stale variant session...');
    await _restoreBackup(refreshPackages: true);
  }

  _backupDirectory.createSync(recursive: true);
  final filesDirectory = Directory('${_backupDirectory.path}/files')
    ..createSync(recursive: true);
  final metadata = <Map<String, Object>>[];

  for (var index = 0; index < _snapshotPaths.length; index++) {
    final relativePath = _snapshotPaths[index];
    final source = File('${_root.path}/$relativePath');
    final exists = source.existsSync();
    metadata.add({'path': relativePath, 'exists': exists});
    if (exists) {
      source.copySync('${filesDirectory.path}/$index');
    }
  }

  File('${_backupDirectory.path}/metadata.json').writeAsStringSync(
    jsonEncode(metadata),
    flush: true,
  );
  _ownerPidFile.writeAsStringSync('$pid', flush: true);
}

Future<bool> _backupHasActiveProcess() async {
  for (final file in [_ownerPidFile, _childPidFile]) {
    if (!file.existsSync()) {
      continue;
    }

    final processId = int.tryParse(file.readAsStringSync().trim());
    if (processId != null && await _isProcessRunning(processId)) {
      return true;
    }
  }
  return false;
}

Future<bool> _isProcessRunning(int processId) async {
  try {
    if (Platform.isWindows) {
      final result = await Process.run(
        'tasklist',
        ['/FI', 'PID eq $processId', '/FO', 'CSV', '/NH'],
        runInShell: true,
      );
      return result.exitCode == 0 &&
          result.stdout.toString().contains(',"$processId",');
    }

    final result = await Process.run('kill', ['-0', '$processId']);
    return result.exitCode == 0;
  } on ProcessException {
    // If process inspection is unavailable, preserve the backup rather than
    // risk restoring over a live variant session.
    return true;
  }
}

Future<void> _restoreBackup({required bool refreshPackages}) async {
  if (!_backupDirectory.existsSync()) {
    stdout.writeln('No variant backup found. Nothing to restore.');
    return;
  }

  final metadataFile = File('${_backupDirectory.path}/metadata.json');
  if (!metadataFile.existsSync()) {
    _fail('Variant backup metadata is missing: ${metadataFile.path}');
  }

  final metadata = (jsonDecode(metadataFile.readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();

  void restoreFiles() {
    for (var index = 0; index < metadata.length; index++) {
      final entry = metadata[index];
      final destination = File('${_root.path}/${entry['path']}');
      final existed = entry['exists'] as bool;
      final backup = File('${_backupDirectory.path}/files/$index');

      if (existed) {
        destination.parent.createSync(recursive: true);
        backup.copySync(destination.path);
      } else if (destination.existsSync()) {
        destination.deleteSync();
      }
    }
  }

  restoreFiles();

  if (refreshPackages) {
    _cleanGeneratedPluginSymlinks();
    final result = await _runFvm(const ['flutter', 'pub', 'get']);
    if (result != 0) {
      stderr.writeln(
        'Warning: original pubspec was restored, but flutter pub get failed.',
      );
    }
  }

  // pub get may rewrite generated registrants. Preserve the exact pre-run
  // working-tree state, including any user edits.
  restoreFiles();
  _backupDirectory.deleteSync(recursive: true);
  stdout.writeln('Restored the original pubspec and plugin state.');
}

Future<int> _runFvm(
  List<String> arguments, {
  bool forwardSignals = false,
}) async {
  final useSystemFlutter =
      Platform.environment['VARIANT_USE_SYSTEM_FLUTTER'] == 'true';
  final executable = useSystemFlutter ? 'flutter' : 'fvm';
  final processArguments =
      useSystemFlutter ? arguments.skip(1).toList() : arguments;

  final process = await Process.start(
    executable,
    processArguments,
    workingDirectory: _root.path,
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  if (_backupDirectory.existsSync()) {
    _childPidFile.writeAsStringSync('${process.pid}', flush: true);
  }

  final subscriptions = <StreamSubscription<ProcessSignal>>[];
  if (forwardSignals && !Platform.isWindows) {
    for (final signal in [ProcessSignal.sigint, ProcessSignal.sigterm]) {
      try {
        subscriptions.add(
          signal.watch().listen((_) {
            process.kill(signal);
          }),
        );
      } on UnsupportedError {
        // Some signals are not supported on Windows.
      }
    }
  }

  try {
    return await process.exitCode;
  } finally {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    if (_childPidFile.existsSync() &&
        _childPidFile.readAsStringSync().trim() == '${process.pid}') {
      _childPidFile.deleteSync();
    }
  }
}

_RunOptions _parseRunOptions(List<String> arguments) {
  var environment = 'dev';
  var release = false;
  final forwarded = <String>[];

  for (var index = 0; index < arguments.length; index++) {
    final argument = arguments[index];
    if (argument == '--env') {
      if (index + 1 >= arguments.length) {
        _fail('Missing value after --env.');
      }
      environment = arguments[++index];
    } else if (argument == '--release') {
      release = true;
    } else if (argument != '--') {
      forwarded.add(argument);
    }
  }

  if (!_environments.contains(environment)) {
    _fail('Environment must be "dev" or "prod".');
  }

  return _RunOptions(
    environment: environment,
    release: release,
    forwardedArguments: forwarded,
  );
}

void _requireVariant(String variant) {
  if (!_variants.contains(variant)) {
    _fail('Variant must be android7, android11, or windows.');
  }
}

Never _fail(String message, [int code = 64]) {
  stderr.writeln(message);
  exitCode = code;
  throw _VariantException();
}

void _printUsage() {
  stdout.writeln('''
Usage:
  fvm dart run tool/variant.dart resolve <variant>
  fvm dart run tool/variant.dart run <variant> [--env dev|prod] [--release] [flutter run args]
  fvm dart run tool/variant.dart build-apk <android7|android11> [--env dev|prod] [--release] [flutter build apk args]
  fvm dart run tool/variant.dart build-windows windows [--env dev|prod] [--release] [flutter build windows args]
  fvm dart run tool/variant.dart restore

Examples:
  fvm dart run tool/variant.dart run android7 --env dev -d emulator-5554
  fvm dart run tool/variant.dart run android11 --env prod --release -d device-id
  fvm dart run tool/variant.dart run windows --env dev -d windows
  fvm dart run tool/variant.dart build-apk android11 --env dev
  fvm dart run tool/variant.dart build-windows windows --env prod --release
''');
}

final class _RunOptions {
  const _RunOptions({
    required this.environment,
    required this.release,
    required this.forwardedArguments,
  });

  final String environment;
  final bool release;
  final List<String> forwardedArguments;
}

final class _VariantException implements Exception {}
