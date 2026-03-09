import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../print_task/print_task_models.dart';

class PrintTaskService extends GetxService {
  static const String jobBoxName = 'print_jobs';
  static const String taskBoxName = 'print_tasks';

  late Box<PrintJob> _jobBox;
  late Box<PrintTask> _taskBox;

  final RxList<PrintJob> jobs = <PrintJob>[].obs;

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    _jobBox = Hive.box<PrintJob>(jobBoxName);
    _taskBox = Hive.box<PrintTask>(taskBoxName);
    _refreshJobs();
  }

  void _refreshJobs() {
    final list = _jobBox.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    jobs.assignAll(list);
  }

  Future<PrintJob> upsertJob(Map data) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final jobBizId = data['bizId'].toString();
    final existing = _jobBox.get(jobBizId);
    if (existing != null) {
      existing.orderSnCode = data['order_sn_code'] ?? existing.orderSnCode;
      existing.orderTime = data['orderTime'] ?? existing.orderTime;
      existing.fromPlate = data['from_plate'] ?? existing.fromPlate;
      existing.orderType = data['order_type'] ?? existing.orderType;
      existing.updatedAt = now;
      await _jobBox.put(jobBizId, existing);
      _refreshJobs();
      return existing;
    }

    final job = PrintJob(
      jobBizId: jobBizId,
      orderSnCode: data['order_sn_code'] ?? '',
      orderTime: data['orderTime'] ?? '',
      fromPlate: data['from_plate'] ?? '',
      orderType: data['order_type'] ?? '',
      taskIds: <String>[],
      status: 'pending',
      createdAt: now,
      updatedAt: now,
    );
    await _jobBox.put(jobBizId, job);
    _refreshJobs();
    return job;
  }

  String buildTaskId({
    required String jobBizId,
    required String itemBizId,
    required int printerType,
    required String printerIp,
    required String mode,
    required String taskKind,
  }) {
    return '${jobBizId}_${itemBizId}_${printerType}_${mode}_${taskKind}_${printerIp}';
  }

  Future<PrintTask> upsertTask(PrintTask task) async {
    final existing = _taskBox.get(task.taskId);
    if (existing != null) {
      existing.payload = task.payload;
      existing.printerIp = task.printerIp;
      existing.printerType = task.printerType;
      existing.mode = task.mode;
      existing.taskKind = task.taskKind;
      existing.batchKey = task.batchKey;
      existing.updatedAt = DateTime.now().millisecondsSinceEpoch;
      await _taskBox.put(task.taskId, existing);
      _ensureTaskInJob(existing.jobBizId, existing.taskId);
      _refreshJobs();
      return existing;
    }
    await _taskBox.put(task.taskId, task);
    _ensureTaskInJob(task.jobBizId, task.taskId);
    _refreshJobs();
    return task;
  }

  void _ensureTaskInJob(String jobBizId, String taskId) {
    final job = _jobBox.get(jobBizId);
    if (job == null) return;
    if (!job.taskIds.contains(taskId)) {
      job.taskIds.add(taskId);
      job.updatedAt = DateTime.now().millisecondsSinceEpoch;
      _jobBox.put(jobBizId, job);
    }
  }

  List<PrintTask> getTasksByJob(String jobBizId) {
    final job = _jobBox.get(jobBizId);
    if (job == null) return [];
    return job.taskIds
        .map((id) => _taskBox.get(id))
        .whereType<PrintTask>()
        .toList();
  }

  Future<void> markTaskStatus(String taskId, String status, {String? error}) async {
    final task = _taskBox.get(taskId);
    if (task == null) return;
    task.status = status;
    if (error != null) {
      task.lastError = error;
      task.retryCount = task.retryCount + 1;
    }
    task.updatedAt = DateTime.now().millisecondsSinceEpoch;
    await _taskBox.put(taskId, task);
    _updateJobStatus(task.jobBizId);
  }

  Future<void> markBatchStatus(String jobBizId, String batchKey, String status,
      {String? error}) async {
    final tasks = _taskBox.values.where((t) => t.jobBizId == jobBizId && t.batchKey == batchKey);
    for (final task in tasks) {
      task.status = status;
      if (error != null) {
        task.lastError = error;
        task.retryCount = task.retryCount + 1;
      }
      task.updatedAt = DateTime.now().millisecondsSinceEpoch;
      await _taskBox.put(task.taskId, task);
    }
    _updateJobStatus(jobBizId);
  }

  void _updateJobStatus(String jobBizId) {
    final job = _jobBox.get(jobBizId);
    if (job == null) return;
    final tasks = job.taskIds
        .map((id) => _taskBox.get(id))
        .whereType<PrintTask>()
        .toList();
    if (tasks.isEmpty) {
      job.status = 'pending';
    } else if (tasks.every((t) => t.status == 'success')) {
      job.status = 'success';
    } else if (tasks.any((t) => t.status == 'failed')) {
      job.status = 'partial';
    } else {
      job.status = 'pending';
    }
    job.updatedAt = DateTime.now().millisecondsSinceEpoch;
    _jobBox.put(jobBizId, job);
    _refreshJobs();
  }

  Future<PrintTask?> getTask(String taskId) async {
    return _taskBox.get(taskId);
  }
}
