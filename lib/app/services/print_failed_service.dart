import 'dart:async';
import 'dart:typed_data';

import 'package:foodorder/app/services/CustomLogerHandler.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../print_failed/print_failed_models.dart';

class PrintFailedService extends GetxService {
  static const String boxName = 'print_records';
  //static const int keepHours = 24;
  static const int keepMinutes = 30;

  late Box<PrintRecord> _box;
  StreamSubscription<BoxEvent>? _boxWatchSub;
  final RxList<PrintRecord> records = <PrintRecord>[].obs;
  final Map<int, RxBool> _failedByTypeCache = <int, RxBool>{};
  Worker? _recordsWorker;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    _box = Hive.box<PrintRecord>(boxName);

    await _boxWatchSub?.cancel();
    _boxWatchSub = _box.watch().listen((_) {
      _refresh();
    });

    await _markPendingAsFailedOnInit();
    await pruneExpired();
    _refresh();

    _recordsWorker ??= ever<List<PrintRecord>>(records, (_) {
      _syncFailedByTypeCache();
    });
    _syncFailedByTypeCache();
  }

  @override
  void onClose() {
    _boxWatchSub?.cancel();
    _boxWatchSub = null;
    _recordsWorker?.dispose();
    _recordsWorker = null;
    _failedByTypeCache.clear();
    super.onClose();
  }

  Future<void> _markPendingAsFailedOnInit() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final pendingList =
        _box.values.where((r) => r.status == 'pending').toList();
    for (final record in pendingList) {
      record.status = 'failed';
      record.updatedAt = now;
      if (record.lastError.isEmpty) {
        record.lastError = 'init migration: pending -> failed';
      }
      await _box.put(record.uuid, record);
    }
  }

  void _refresh() {
    final list = _box.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    records.assignAll(list);
  }

  bool hasFailedByPrinterType(int printerType) {
    return _hasFailedByPrinterType(printerType);
  }

  RxBool watchFailedByPrinterType(int printerType) {
    final rx = _failedByTypeCache.putIfAbsent(printerType, () {
      final value = _hasFailedByPrinterType(printerType);
      return RxBool(value);
    });
    return rx;
  }

  bool _hasFailedByPrinterType(int printerType) {
    return records
        .any((r) => r.printerType == printerType && r.status == 'failed');
  }

  void _syncFailedByTypeCache() {
    if (_failedByTypeCache.isEmpty) return;
    _failedByTypeCache.forEach((type, rx) {
      rx.value = _hasFailedByPrinterType(type);
    });
  }

  Future<void> addPending({
    required String uuid,
    required int printerType,
    required String printerIp,
    required List<List<int>> printData,
    required Map printInfo,
  }) async {
    if (_box.containsKey(uuid)) {
      return;
    }
    logI('Adding new pending print record $uuid');
    final now = DateTime.now().millisecondsSinceEpoch;
    final record = PrintRecord(
      uuid: uuid,
      printerType: printerType,
      printerIp: printerIp,
      printData: printData.map((e) => Uint8List.fromList(e)).toList(),
      printInfo: printInfo,
      createdAt: now,
      updatedAt: now,
      retryCount: 0,
      lastError: '',
      status: 'pending',
    );
    await _box.put(uuid, record);
    _refresh();
  }

  Future<void> markSuccess(String uuid) async {
    final record = _box.get(uuid);
    if (record == null) return;
    logI('Marking print record $uuid as success.');
    record.updatedAt = DateTime.now().millisecondsSinceEpoch;
    record.status = 'success';
    await _box.put(uuid, record);
    _refresh();
  }

  Future<void> markFailed(String uuid, {String? error}) async {
    final record = _box.get(uuid);
    if (record == null) return;
    logI(
        'Marking print record $uuid as failed. retryCount=${record.retryCount + 1}');
    record.updatedAt = DateTime.now().millisecondsSinceEpoch;
    record.retryCount = record.retryCount + 1;
    record.status = 'failed';
    if (error != null) {
      record.lastError = error;
    }
    await _box.put(uuid, record);
    _refresh();
  }

  Future<void> updateFailure(
    PrintRecord record, {
    String? error,
  }) async {
    record.updatedAt = DateTime.now().millisecondsSinceEpoch;
    record.retryCount = record.retryCount + 1;
    record.status = 'failed';
    if (error != null) {
      record.lastError = error;
    }
    await _box.put(record.uuid, record);
    _refresh();
  }

  Future<void> removeFailure(String uuid) async {
    logI('Removing print record $uuid from failed records.');
    await _box.delete(uuid);
    _refresh();
  }

  Future<void> clearAll() async {
    await _box.clear();
    _refresh();
  }

  Future<void> clearByPrinterType(int printerType) async {
    final keysToRemove = _box.values
        .where((r) => r.printerType == printerType)
        .map((r) => r.uuid)
        .toList();
    for (final key in keysToRemove) {
      await _box.delete(key);
    }
    _refresh();
  }

  Future<void> pruneExpired() async {
    final expireBefore = DateTime.now()
        .subtract(const Duration(minutes: keepMinutes))
        .millisecondsSinceEpoch;
    final keysToRemove = _box.values
        .where((r) => r.createdAt < expireBefore)
        .map((r) => r.uuid)
        .toList();
    for (final key in keysToRemove) {
      await _box.delete(key);
    }
    if (keysToRemove.isNotEmpty) {
      _refresh();
    }
  }

  List<PrintRecord> getRetryCandidates() {
    final list = _box.values.where((record) {
      if (record.status != 'failed') return false;
      return !_isExpired(record);
    }).toList();
    list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));
    return list;
  }

  bool _isExpired(PrintRecord record) {
    final expireBefore = DateTime.now()
        .subtract(const Duration(minutes: keepMinutes))
        .millisecondsSinceEpoch;
    return record.createdAt < expireBefore;
  }
}
