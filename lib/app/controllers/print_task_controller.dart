import 'package:get/get.dart';

import '../print_task/print_task_models.dart';
import '../services/print_task_service.dart';

class PrintTaskController extends GetxController {
  final PrintTaskService _service = Get.find<PrintTaskService>();

  final RxString selectedJobBizId = ''.obs;
  final RxList<PrintTask> tasks = <PrintTask>[].obs;

  RxList<PrintJob> get jobs => _service.jobs;

  void selectJob(String jobBizId) {
    selectedJobBizId.value = jobBizId;
    tasks.assignAll(_service.getTasksByJob(jobBizId));
  }

  Future<void> refreshSelected() async {
    final jobBizId = selectedJobBizId.value;
    if (jobBizId.isEmpty) return;
    tasks.assignAll(_service.getTasksByJob(jobBizId));
  }

  Future<void> retryTask(PrintTask task) async {
    await _service.markTaskStatus(task.taskId, 'pending');
    await refreshSelected();
  }
}
