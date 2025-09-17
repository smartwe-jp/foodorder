import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'checkout_page_controller.dart';

class checkStatusCopyView extends GetView<CheckoutPageController> {

  final Function? onEnd;

  const checkStatusCopyView({
    Key? key,
    this.onEnd,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutPageController>(builder: (controller) {
      return SimpleDialog(
        //机器状态检查
        title: Text(
          'status_check'.tr,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        contentPadding: const EdgeInsets.all(20),
        children: [
          if (!controller.allAreReady.value)
            Text(
              'status_check_tips'.tr,
              style: TextStyle(fontSize: 16),
            ),
          const SizedBox(height: 20),
          Obx(() {
            return Container(
              width: 500,
              child: Column(
                children: controller.checkList.map((printer) {
                  return printerCheckItem(
                    printerName: printer['name'],
                    isOpen: printer['isOn'],
                    isOnline: printer['isReady'],
                    isChecking: printer['isChecking'],
                    isChecked: printer['checked'],
                  );
                }).toList(),
              ),
            );
          }),
          const SizedBox(height: 20),
          if (controller.allAreReady.value)
          //显示重试和关闭按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child:
                ElevatedButton(
                  onPressed: () {
                    controller.checkPrinterStatus();
                  },
                  child: Text('retry_button'.tr),
                )),
                SizedBox(width: 20),
                Expanded(
                  child:
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (onEnd != null) {
                        onEnd!();
                      }
                    },
                    child: Text('tag_button_yes'.tr),
                  ),
                )
              ],
            )
        ],
      );
    });
  }

  //实现一个打印机检查Item view
  //左边打印机图标，名字，是否开启，状态检查的Loading 如果成功换成☑️，不是当前Item检查的时候整个Item显灰
  Widget printerCheckItem({
    required String printerName,
    required bool isOpen,
    required bool isOnline,
    required bool isChecking,
    required bool isChecked,
  }) {
    return GetBuilder<CheckoutPageController>(builder: (controller) {
      return Stack(
        children: [
          ListTile(
              leading: Icon(
                Icons.print,
                color: Colors.grey,
              ),
              title: Text(
                  printerName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  )),
              subtitle:
              Text(
                '${isOpen ? "status_on".tr : "status_off".tr}',
                style: TextStyle(
                  color: isOpen ? Colors.black : Colors.grey,
                ),
              ),
              trailing: isChecking
                  ? const CircularProgressIndicator()
                  :
              isOpen ?
              Icon(
                isOnline ? Icons.check : isChecked ? Icons.close : Icons
                    .timelapse_rounded,
                color: isOnline ? Colors.green : isChecked ? Colors.red : Colors
                    .grey,
              ) :
              controller.allAreReady.value ?
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed('/middlewaresettingpage', arguments: {
                    "machineCode": controller.machineInfo.machineCode
                  });
                },
                child: Text('go_setting'.tr),
              )
                  : Icon(
                Icons.timelapse_rounded,
                color: Colors.black,
              ) // 如果正在检查，则禁用点击
          ),
          if (!isChecking && !controller.allAreReady.value)
            Positioned.fill(
              child: Container(
                color: Colors.grey.withOpacity(0.3), // 灰色遮罩
              ),
            ),
        ],
      );
    });
  }

}