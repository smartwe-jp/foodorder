import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/OrderHome/controllers/order_home_controller.dart';
import 'package:get/get.dart';

class checkStatusView extends GetView<OrderHomeController> {


  const checkStatusView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderHomeController>(builder: (controller) {
      return SimpleDialog(
        //机器状态检查
        title: const Text(
          '机器状态检查',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        contentPadding: const EdgeInsets.all(20),
        children: [
          const Text(
            '请稍等，正在检查机器状态...',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          // Obx(() {
          //   return controller.isChecking.value
          //       ? const CircularProgressIndicator()
          //       : const Icon(Icons.check_circle, color: Colors.green, size: 40);
          // }),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Get.back();
            },
            child: const Text('关闭'),
          ),
        ],
      );
    });
  }
}