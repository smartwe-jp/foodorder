

import 'package:foodorder/app/controllers/create_printImage_controller.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/setting/printList/state.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller_printer_extension.dart';
import 'package:foodorder/app/services/PrintInfoService.dart';
import 'package:get/get.dart';

class PrintListPageLogic extends GetxController with StateMixin {
  MachineInfoController machineInfo = Get.find();
  final PrintListState state = PrintListState();
  PrintService printService = Get.find();
  CreatePrintImageController createPrintImageController = Get.find();

  @override
  void onInit() {
    super.onInit();
    loadPrintList();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> loadPrintList() async {
    change(null, status: RxStatus.loading());
    try {
      final svc = Get.find<PrintInfoService>();
      final jobs = await svc.readAll();
      // 最近 30 条（假设添加顺序即时间顺序）
      final recent = jobs.length > 30 ? jobs.sublist(jobs.length - 30) : jobs;
      state.printList = recent.reversed // 最新的放前面
          .map((e) => PrintOrderItem.fromMap(e))
          .toList();
      change(state, status: RxStatus.success());
    } catch (e) {
      change(null, status: RxStatus.error(e.toString()));
    }
  }

  void reprint(PrintOrderItem item) {
    createPrintImageController.tpPrintnew('1', item.raw, machineInfo.receiptPrintType);
  }
}
