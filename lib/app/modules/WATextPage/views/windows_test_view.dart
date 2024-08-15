import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/imageData.dart';
import 'package:foodorder/app/modules/WATextPage/controllers/windows_test_controller.dart';
import 'package:foodorder/app/modules/WATextPage/views/custom_button.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';

class WindewsTestView extends GetView<WindowsTestController> {

  final WindowsTestController controller = Get.put(WindowsTestController());
  WindewsTestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(
          () => Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          //padding: EdgeInsets.only(top: 4),
                          child: Wrap(
                            direction: Axis.horizontal,
                            //runAlignment: WrapAlignment.spaceAround,
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 20,
                            children: [
                              CustomToggleButton(
                                text: "開局処理",
                                isSelected: false,
                                isActived: !controller.openSuccess.value,
                                onToggle: (newState) {
                                  debugPrint("  開局処理 touch ");
                                  controller.openCashChange();
                                },
                              ),
                              CustomToggleButton(
                                text: "閉局処理",
                                isSelected: false,
                                isActived: true,
                                onToggle: (newState) {
                                  debugPrint("  閉局処理 touch ");
                                  controller.closeCashChange();
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 4),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 10,
                            runSpacing: 20,
                            children: [
                              CustomToggleButton(
                                text: "スキャン開始",
                                isSelected: false,
                                isActived: controller.openSuccess.value,
                                onToggle: (newState) {
                                  controller.startDeposit();
                                },
                              ),
                              CustomToggleButton(
                                text: "小計",
                                isSelected: false,
                                isActived: controller.openSuccess.value,
                                onToggle: (newState) {
                                  //controller.openCashChange();
                                },
                              ),
                              CustomToggleButton(
                                text: "現計",
                                isSelected: false,
                                isActived: controller.openSuccess.value,
                                onToggle: (newState) {
                                  controller.getDepositAmount();
                                },
                              ),
                              CustomToggleButton(
                                text: "キャンセル",
                                isSelected: false,
                                isActived: controller.openSuccess.value,
                                onToggle: (newState) {
                                  //controller.stopDeposit();
                                  controller.depositRepay();
                                },
                              ),
                              CustomToggleButton(
                                text: "返品処理",
                                isSelected: false,
                                isActived: controller.openSuccess.value,
                                onToggle: (newState) {
                                  //controller.;
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 4),
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            spacing: 10,
                            runSpacing: 20,
                            children: [
                              CustomToggleButton(
                                text: "在高表示",
                                isSelected: false,
                                isActived: controller.openSuccess.value,
                                onToggle: (newState) {
                                  controller.GetCashBalanceInfo();
                                },
                              ),
                              CustomToggleButton(
                                text: "全回収",
                                isSelected: false,
                                isActived: controller.openSuccess.value,
                                onToggle: (newState) {
                                  //controller.depositRepay();
                                },
                              ),
                              CustomToggleButton(
                                text: "エラー解除",
                                isSelected: false,
                                isActived: controller.openSuccess.value,
                                onToggle: (newState) {
                                  //controller.openCashChange();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Text(
                                    "商品合計",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded (child: 
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.end,
                                      onChanged: (value) {
                                        debugPrint("value:  " + value);
                                      },
                                      decoration: InputDecoration(hintText: "0"),
                                      style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                                    ),
                                  ),
                                )
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Text(
                                    "預かり金額",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(child: 
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    child: TextField(
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.end,
                                      onChanged: (value) {
                                        debugPrint("value:  " + value);
                                      },
                                      decoration: InputDecoration(hintText: controller.depositAmount.value),
                                      style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                                    ),
                                  ),
                                )
                                
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.only(right: 20),
                                  child: Text(
                                    "お釣り",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded (child: 
                                  Container(
                                    padding: EdgeInsets.only(right: 20),
                                    child: 
                                      Text(
                                        controller.changeAmount.value,
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ),
                              ]),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Color.fromARGB(255, 11, 87, 100),
                                padding: const EdgeInsets.all(16.0),
                                textStyle: const TextStyle(fontSize: 20),
                              ),
                              onPressed: () {
                                //to home page
                                Future.delayed(Duration(milliseconds: 200), () {
                                  Get.back();
                                });
                              },
                              child: const Text('終了'),
                            ),
                          ),
                        ],
                      ),
                  )),
            ],
          ),
        ),
      ),
    );
  }


}
