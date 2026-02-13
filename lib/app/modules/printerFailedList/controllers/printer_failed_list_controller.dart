import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

import '../../../print_failed/print_failed_models.dart';
import '../../../services/print_failed_service.dart';
import 'package:widget_to_image/widget_to_image.dart';
import 'package:flutter_printer_plus/flutter_printer_plus.dart' as printerPlus;
import 'package:print_image_generate_tool/print_image_generate_tool.dart';

class PrinterFailedListController extends GetxController {
  final PrintFailedService _service = Get.find<PrintFailedService>();

  final RxInt printerType = 0.obs;
  final RxString printerName = ''.obs;

  final RxList<PrintRecord> failedRecords = <PrintRecord>[].obs;
  final Rxn<PrintRecord> selected = Rxn<PrintRecord>();

  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg is Map) {
      final t = arg['printerType'];
      if (t is int) {
        printerType.value = t;
      } else if (t != null) {
        printerType.value = int.tryParse(t.toString()) ?? 0;
      }
      printerName.value = (arg['printerName'] ?? '').toString();
    }

    _syncFromService();
    ever<List<PrintRecord>>(_service.records, (_) => _syncFromService());
  }

  void _syncFromService() {
    final list = _service.records.where((r) {
      if (r.status != 'failed') return false;
      return r.printerType == printerType.value;
    }).toList();
    // keep stable ordering: oldest updated first
    list.sort((a, b) => a.updatedAt.compareTo(b.updatedAt));

    failedRecords.assignAll(list);

    final current = selected.value;
    if (current == null) {
      if (failedRecords.isNotEmpty) {
        selected.value = failedRecords.first;
      }
      return;
    }

    final stillExists = failedRecords.any((r) => r.uuid == current.uuid);
    if (!stillExists) {
      selected.value = failedRecords.isNotEmpty ? failedRecords.first : null;
    } else {
      selected.value = failedRecords.firstWhere((r) => r.uuid == current.uuid);
    }
  }

  void selectRecord(PrintRecord record) {
    selected.value = record;
  }

  Future<void> clearCurrentPrinterFailed() async {
    final type = printerType.value;
    if (type == 0) {
      await _service.clearAll();
    } else {
      await _service.clearByPrinterType(type);
    }
  }

  Future<void> deleteSelectedRecordByUuid(String uuid) async {
    await _service.removeFailure(uuid);
  }

  bool hasFailedByPrinterType(int type) {
    return _service.records
        .any((r) => r.printerType == type && r.status == 'failed');
  }

  void retrySelectedRecord(PrintRecord record) async {
    final printerInfo = PrinterInfo(
      ip: record.printerIp,
      printerType: record.printerType,
      printInfo: record.printInfo,
    );
    final printData = record.printData.map((e) => e.toList()).toList();

    if (Get.isRegistered<HomeController>()) {
      final homeController = Get.find<HomeController>();
      await homeController.printTask(printerInfo, printData);
    }
  }
}
