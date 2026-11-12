import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/config/printer_info.dart';
import 'package:foodorder/app/print_failed/print_failed_models.dart';
import 'package:foodorder/app/services/print_failed_service.dart';
import 'package:hive/hive.dart';

void main() {
  test('only retries the failed kitchen printer with its own ticket', () async {
    final directory = await Directory.systemTemp.createTemp('kitchen_retry_');
    Hive.init(directory.path);
    Hive.registerAdapter(PrintRecordAdapter());
    await Hive.openBox<PrintRecord>(PrintFailedService.boxName);
    final service = PrintFailedService();
    addTearDown(() async {
      service.onClose();
      await Hive.close();
      await directory.delete(recursive: true);
    });
    await service.init();

    Future<String> enqueue(int type, String ip, int data) async {
      final id = PrinterInfo.ticketId('order-0255', type, ip, 'continuous');
      await service.addPending(
        uuid: id,
        printerType: type,
        printerIp: ip,
        printData: [
          [data]
        ],
        printInfo: {'uuid': id},
      );
      return id;
    }

    final kitchen = await enqueue(10, '192.168.0.3', 1);
    final drinks = await enqueue(12, '192.168.0.101', 2);
    await service.markSuccess(kitchen);
    await service.markFailed(drinks);

    final retry = service.getRetryCandidates().single;
    expect(retry.printerIp, '192.168.0.101');
    expect(retry.printData.single, [2]);
    expect(retry.printInfo['uuid'], drinks);
    expect(
        service.records.firstWhere((r) => r.uuid == kitchen).status, 'success');
  });
}
