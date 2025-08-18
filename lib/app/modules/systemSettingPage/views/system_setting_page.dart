import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/systemSettingPage/controllers/system_setting_page_controller.dart';
import 'package:get/get.dart';

class SystemSettingPage extends GetView<SystemSettingPageController> {
  const SystemSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SystemSettingPageController>(builder: (logic) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Card(
            margin: const EdgeInsets.all(8),
            //elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: AppBar(
              title: const Text('システム設定'),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: Colors.black,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _modeArea(logic.machineModeInfo),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    });
  }

  Widget _modeArea(Map modeInfo) {
    bool isSellOn = modeInfo['sell'] ?? false;
    bool isTakeoutOn = modeInfo['takeout'] ?? false;
    bool isCheckoutOn = modeInfo['checkout'] ?? false;
    bool isScanbuyOn = modeInfo['scanbuy'] ?? false;

    //实现一个Card模式的选择设置区域，上方标题 分割线 下方是四个按钮 使用Wrap容器。每个Item 选中显示边框。
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'モード設定',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Wrap(
              runAlignment: WrapAlignment.spaceBetween,
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                _modeButton('販売', isSellOn, () => controller.updateMachineMode(sell: !isSellOn)),
                _modeButton('テイクアウト', isTakeoutOn, () => controller.updateMachineMode(takeout: !isTakeoutOn)),
                _modeButton('チェックアウト', isCheckoutOn, () => controller.updateMachineMode(checkout: !isCheckoutOn)),
                _modeButton('スキャン購入', isScanbuyOn, () => controller.updateMachineMode(scanbuy: !isScanbuyOn)),
              ],
            ),
          ],
        ),
      ),
    );

  }

  Widget _modeButton(String label, bool isSelected, VoidCallback onPressed) {
    //每个Item 选中显示边框 不要使用 ElevatedButton 因为需要设置高宽
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 80,
        //width: double.infinity,

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }




}