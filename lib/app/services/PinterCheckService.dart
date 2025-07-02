import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class PrinterCheckService extends GetxService{
  Future<void> checkPrinters(
      List printerList,
      Function(Map) onPrinterChecked,
      ) async {
    for (var printer in printerList) {
      final ip = printer['ip'] ?? '';
      final port = printer['port'] ?? 9100;

      printer['isChecking'] = true;

      onPrinterChecked(printer); // Notify that the printer is being checked
      if (printer['isOn'] == false) {
        printer['checked'] = true;
        printer['isChecking'] = false;
        printer['isReady'] = false; // Printer is off, skip checking
        continue;
      }
      try {
        debugPrint('Checking printer at $ip:$port');
        final socket = await Socket.connect(ip, 9100, timeout: Duration(seconds: 10));
        socket.destroy();
        printer['isReady'] = true;
        printer['isChecking'] = false;
        printer['checked'] = true;
        onPrinterChecked(printer);// Connection successful
      } catch (e) {
        printer['isReady'] = false;
        printer['isChecking'] = false;
        printer['checked'] = true;
        onPrinterChecked(printer);// Connection failed
      }

       // Notify the result of the check
    }
  }
}