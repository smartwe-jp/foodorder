import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showScaleConnectionPrompt({required String message}) async {
  return await Get.dialog<bool>(
        AlertDialog(
          title: const Text('電子秤を確認してください'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('閉じる'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('設定へ'),
            ),
          ],
        ),
        barrierDismissible: false,
      ) ??
      false;
}
