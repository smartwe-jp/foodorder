import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosCheckView extends StatelessWidget {
  final RxInt posCheckStatus; // 0: 检测中, 1: 成功, 2: 失败
  final Function onRetry;

  const PosCheckView({Key? key, required this.posCheckStatus, required this.onRetry}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SimpleDialog(
        title: GestureDetector(
          onLongPress: () {
            Get.back();
          },
          child: Text(
            'pos_check_title'.tr, // 标题
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        contentPadding: const EdgeInsets.all(30),
        children: [
          Center(
            child: SizedBox(
              height: 170,
              width: 160,
              child: _buildStatusView(posCheckStatus.value),
            ),
          ),
          const SizedBox(height: 30),
          if (posCheckStatus.value != 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (posCheckStatus.value == 0)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      posCheckStatus.value = 0; // 重新检测
                      // 这里可以调用检测方法
                      onRetry();
                    },
                    child: Text('retry_button'.tr),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      //posCheckStatus.value = 0;
                      Get.back();
                    },
                    child: Text('tag_button_yes'.tr),
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildStatusView(int status) {
    switch (status) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(strokeWidth: 8),
            const SizedBox(height: 20),
            Text('pos_checking'.tr, style: const TextStyle(fontSize: 18)),
          ],
        );
      case 1:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            Text('pos_check_success'.tr, style: const TextStyle(fontSize: 18)),
          ],
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            Text('pos_check_failed'.tr, style: const TextStyle(fontSize: 18)),
          ],
        );
      default:
        return Container();
    }
  }
}