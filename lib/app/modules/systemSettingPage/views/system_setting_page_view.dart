import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/systemSettingPage/views/system_setting_page_extention.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../services/PosCheckService.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/system_setting_page_controller.dart';
import 'SetPassword.dart';
import 'SetPosIp.dart';

class SystemSettingPageView extends GetView {
  final SystemSettingPageController controller = Get.put(SystemSettingPageController());
  SystemSettingPageView({Key? key}) : super(key: key);


  //设置菜单方向
  setMenuDirection() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkMenuDirection("1");
            },
            child: Container(
              //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.menu_direction == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("上に横に",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.menu_direction == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkMenuDirection("2");
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.menu_direction == "2") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("左に縦に",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.menu_direction == "2") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  setMachineType() {
    return Container(
        margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
        padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
        child:
        Container(
          alignment: Alignment.centerLeft,
          child: Container(
            width: 200,
            child: DropdownButtonFormField<String>(
              value: controller.machineInfo.panelType,
              onChanged: (String? newValue) {

                controller.checkPanelType(newValue ?? 'Mini');

              },
              items: controller.panelTypes.map<DropdownMenuItem<String>>((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key, style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(18.0),
                  ),),
                );
              }).toList(),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
              ),
              icon: Icon(Icons.arrow_drop_down),
              iconSize: 24,
              isExpanded: true,
            ),
          ),
        )




    );
  }

  //设置打印菜单部分文字大小
  setPrintPaperTxtSize() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkPrintPaperTxtSize(1);
            },
            child: Container(
              //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(120),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.print_paper_txt_size == 1) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("小",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.print_paper_txt_size == 1) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkPrintPaperTxtSize(2);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(120),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.print_paper_txt_size == 2) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("普　通",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.print_paper_txt_size == 2) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkPrintPaperTxtSize(3);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(120),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.print_paper_txt_size == 3) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("大",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.print_paper_txt_size == 3) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkPrintPaperTxtSize(4);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(120),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.print_paper_txt_size == 4) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("特 大",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.print_paper_txt_size == 4) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
        ],
      ),
    );
  }

  //设置是否必须打印领収书
  setIsAllowReceipt() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: (){
                    controller.checkIsAllowReceipt("1");
                  },
                  child: Container(
                    //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                    //设置 child 居中
                    alignment: Alignment(0, 0),
                    height: ScreenAdapter.height(60),
                    width: ScreenAdapter.width(220),
                    //边框设置
                    decoration: new BoxDecoration(
                      //背景
                      color: (controller.machineInfo.isAllowReceipt == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //设置四周边框
                      //border: new Border.all(width: 1, color: Colors.red),
                    ),
                    child: Text("発　行",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontWeight: FontWeight.w400,
                          fontSize: ScreenAdapter.fontSize(22.0),
                          color: (controller.machineInfo.isAllowReceipt == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                        )
                    ),
                  ),
                ),
                InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: (){
                    controller.checkIsAllowReceipt("2");
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                    //设置 child 居中
                    alignment: Alignment(0, 0),
                    height: ScreenAdapter.height(60),
                    width: ScreenAdapter.width(220),
                    //边框设置
                    decoration: new BoxDecoration(
                      //背景
                      color: (controller.machineInfo.isAllowReceipt == "2") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //设置四周边框
                      //border: new Border.all(width: 1, color: Colors.red),
                    ),
                    child: Text("お客様選択",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontWeight: FontWeight.w400,
                          fontSize: ScreenAdapter.fontSize(22.0),
                          color: (controller.machineInfo.isAllowReceipt == "2") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                        )
                    ),
                  ),
                ),

              ],
            ),
          ),
          // Text("注：現金でお支払いの場合の設定です。他のお支払い方法の場合は全て「発行」となります。",
          //     style: TextStyle(
          //       fontFamily: 'NotoSansJP',
          //       fontSize: ScreenAdapter.fontSize(17),
          //       fontWeight: FontWeight.w400,
          //       color: ColorsUtil.hexToColor("#d90000"),
          //     )),
        ],
      ),
    );
  }

  //设置是否必须打印领収书顶部菜单
  setIsAllowReceiptMenu() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: (){
                    controller.checkIsAllowReceiptMenu("2");
                  },
                  child: Container(
                    //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                    //设置 child 居中
                    alignment: Alignment(0, 0),
                    height: ScreenAdapter.height(60),
                    width: ScreenAdapter.width(220),
                    //边框设置
                    decoration: new BoxDecoration(
                      //背景
                      color: (controller.machineInfo.isPrintReceipt == "2") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //设置四周边框
                      //border: new Border.all(width: 1, color: Colors.red),
                    ),
                    child: Text("プリントしない",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontWeight: FontWeight.w400,
                          fontSize: ScreenAdapter.fontSize(22.0),
                          color: (controller.machineInfo.isPrintReceipt == "2") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                        )
                    ),
                  ),
                ),
                InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: (){
                    controller.checkIsAllowReceiptMenu("1");
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                    //设置 child 居中
                    alignment: Alignment(0, 0),
                    height: ScreenAdapter.height(60),
                    width: ScreenAdapter.width(220),
                    //边框设置
                    decoration: new BoxDecoration(
                      //背景
                      color: (controller.machineInfo.isPrintReceipt == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //设置四周边框
                      //border: new Border.all(width: 1, color: Colors.red),
                    ),
                    child: Text("プリントする",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontWeight: FontWeight.w400,
                          fontSize: ScreenAdapter.fontSize(22.0),
                          color: (controller.machineInfo.isPrintReceipt == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                        )
                    ),
                  ),
                ),

              ],
            ),
          ),
          Text("注：券売機モードはキッチンプリンターを設置した場合、プリントする必要はありません。",
              style: TextStyle(
                fontFamily: 'NotoSansJP',
                fontSize: ScreenAdapter.fontSize(17),
                fontWeight: FontWeight.w400,
                color: ColorsUtil.hexToColor("#d90000"),
              )),
        ],
      ),
    );
  }

  // 麻辣烫模式下的注文方式设置（扫码注文 vs 普通注文）
  setSpicyHotPotOrderType() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left: ScreenAdapter.width(20), top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  controller.updateSpicyHotPotOrderType('scan');
                },
                child: Container(
                  alignment: Alignment(0, 0),
                  height: ScreenAdapter.height(60),
                  width: ScreenAdapter.width(220),
                  decoration: BoxDecoration(
                    color: (controller.machineInfo.spicyHotPotOrderType == 'scan')
                        ? ColorsUtil.hexToColor("#409eff")
                        : Colors.grey[200],
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text("スキャン注文",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontWeight: FontWeight.w400,
                        fontSize: ScreenAdapter.fontSize(22.0),
                        color: (controller.machineInfo.spicyHotPotOrderType == 'scan')
                            ? ColorsUtil.hexToColor("#FFFFFF")
                            : ColorsUtil.hexToColor("#000000"),
                      )),
                ),
              ),
              InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () {
                  controller.updateSpicyHotPotOrderType('normal');
                },
                child: Container(
                  margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                  alignment: Alignment(0, 0),
                  height: ScreenAdapter.height(60),
                  width: ScreenAdapter.width(220),
                  decoration: BoxDecoration(
                    color: (controller.machineInfo.spicyHotPotOrderType == 'normal')
                        ? ColorsUtil.hexToColor("#409eff")
                        : Colors.grey[200],
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                  child: Text("通常注文",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontWeight: FontWeight.w400,
                        fontSize: ScreenAdapter.fontSize(22.0),
                        color: (controller.machineInfo.spicyHotPotOrderType == 'normal')
                            ? ColorsUtil.hexToColor("#FFFFFF")
                            : ColorsUtil.hexToColor("#000000"),
                      )),
                ),
              ),
            ],
          ),
          // 注：スキャン注文はバーコードスキャンで商品を選択、通常注文は画面タッチで商品を選択
          Text("注：スキャン注文はバーコードスキャンで商品を選択します。通常注文は画面タッチで商品を選択します。",
              style: TextStyle(
                fontFamily: 'NotoSansJP',
                fontSize: ScreenAdapter.fontSize(17),
                fontWeight: FontWeight.w400,
                color: ColorsUtil.hexToColor("#d90000"),
              )),
        ],
      ),
    );
  }

  //设置机器类型：多按钮自动换行，避免 5 个挤在一行
  setMachineMode(Map machineInfos) {
    bool isSellOn = machineInfos['sell'] ?? false;
    bool isTakeoutOn = machineInfos['takeout'] ?? false;
    bool isCheckoutOn = machineInfos['checkout'] ?? false;
    bool isScanbuyOn = machineInfos['scanbuy'] ?? false;
    bool isSpicyHotPotOn = machineInfos['spicyHotPot'] ?? false;

    final buttons = <Widget>[
      _machineModeChip(
        label: "店　内",
        selected: isSellOn,
        onTap: () => controller.updateMachineMode(sell: !isSellOn),
      ),
      _machineModeChip(
        label: "テイクアウト",
        selected: isTakeoutOn,
        onTap: () => controller.updateMachineMode(takeout: !isTakeoutOn),
      ),
      if (controller.actuarial.value == true)
        _machineModeChip(
          label: "精算機",
          suffix: "（後払い）",
          selected: isCheckoutOn,
          onTap: () => controller.updateMachineMode(checkout: !isCheckoutOn),
        ),
      _machineModeChip(
        label: "精算機",
        suffix: "（バーコード）",
        selected: isScanbuyOn,
        onTap: () => controller.updateMachineMode(scanbuy: !isScanbuyOn),
      ),
      if (controller.isspicyHotPot.value == "1")
        _machineModeChip(
          label: "麻辣烫",
          selected: isSpicyHotPotOn,
          onTap: () =>
              controller.updateMachineMode(spicyHotPot: !isSpicyHotPotOn),
        ),
    ];

    return Container(
      margin: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(
        left: ScreenAdapter.width(12),
        top: ScreenAdapter.height(6),
        bottom: ScreenAdapter.height(6),
        right: ScreenAdapter.width(12),
      ),
      width: double.infinity,
      child: Wrap(
        spacing: ScreenAdapter.width(12),
        runSpacing: ScreenAdapter.height(10),
        alignment: WrapAlignment.start,
        children: buttons,
      ),
    );
  }

  /// モード按钮：选中填色，由 Wrap 控制一行多个
  Widget _machineModeChip({
    required String label,
    String? suffix,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final textColor =
        selected ? ColorsUtil.hexToColor("#FFFFFF") : ColorsUtil.hexToColor("#000000");
    // 注意：Container 不要设 alignment，否则在 Wrap 内会撑满整行
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        height: ScreenAdapter.height(60),
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(18),
          vertical: ScreenAdapter.height(8),
        ),
        decoration: BoxDecoration(
          color: selected ? ColorsUtil.hexToColor("#409eff") : Colors.grey[200],
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: suffix == null
              ? Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: 'NotoSansJP',
                    fontSize: ScreenAdapter.fontSize(20.0),
                    color: textColor,
                  ),
                )
              : RichText(
                  text: TextSpan(
                    text: label,
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenAdapter.fontSize(20.0),
                      color: textColor,
                    ),
                    children: [
                      TextSpan(
                        text: suffix,
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(16),
                          fontWeight: FontWeight.w400,
                          color: selected
                              ? ColorsUtil.hexToColor("#FFE0E0")
                              : ColorsUtil.hexToColor("#d90000"),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  //设置是否开启预约
  setIsReservation() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsReservation("0");
            },
            child: Container(
              //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.isReservation == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("停 止",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.isReservation == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsReservation("1");
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.isReservation == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("起 動",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.isReservation == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }
  setIsAllowPanelDisplay() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowWlanPanelPrint("0");
            },
            child: Container(
              //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: !(controller.machineInfo.isAllowScreenCall) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("設置しない",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: !(controller.machineInfo.isAllowScreenCall) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              _showPanelSettingDialog();
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(120),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.isAllowScreenCall) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("設置",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.isAllowScreenCall) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          if (controller.machineInfo.wlan_panel_print_ip != "" && controller.machineInfo.wlan_panel_print_port != "")
            Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
              child:
              InkWell(
                highlightColor: Colors.transparent, // 透明色
                splashColor: Colors.transparent, // 透明色

                child: Container(
                  margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                  //设置 child 居中
                  alignment: Alignment(0, 0),
                  height: ScreenAdapter.height(60),
                  width: ScreenAdapter.width(220),
                  //边框设置
                  decoration: new BoxDecoration(
                    //背景
                    color: ColorsUtil.hexToColor("#409eff"),
                    //设置四周圆角 角度
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    //设置四周边框
                    //border: new Border.all(width: 1, color: Colors.red),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "${controller.machineInfo.wlan_panel_print_ip}:",
                              style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(22),
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )
                          ),
                          Text(
                              "${controller.machineInfo.wlan_panel_print_port}",
                              style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(22),
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )
                          )
                        ],
                      )

                    ],
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }
  //设置是否开启pos刷卡
  setIsAllowPos() {
    final posCheckService = Get.find<PosCheckService>();
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowPos("0");
            },
            child: Container(
              //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.isAllowPos == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("設置しない",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.isAllowPos == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              _showPosSettingDialog();
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(120),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.isAllowPos == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("設置",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.isAllowPos == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          if (controller.machineInfo.pos_ip != "" && controller.machineInfo.pos_port != "")
            Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
              child:
              InkWell(
                highlightColor: Colors.transparent, // 透明色
                splashColor: Colors.transparent, // 透明色
                onTap: (){
                  controller.posTest(controller.machineInfo.pos_ip, controller.machineInfo.pos_port);
                },
                child: Container(
                  margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                  //设置 child 居中
                  alignment: Alignment(0, 0),
                  height: ScreenAdapter.height(60),
                  width: ScreenAdapter.width(220),
                  //边框设置
                  decoration: new BoxDecoration(
                    //背景
                    color: ColorsUtil.hexToColor("#409eff"),
                    //设置四周圆角 角度
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    //设置四周边框
                    //border: new Border.all(width: 1, color: Colors.red),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              "${controller.machineInfo.pos_ip}:",
                              style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(22),
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )
                          ),
                          Text(
                              "${controller.machineInfo.pos_port}",
                              style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(22),
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )
                          )
                        ],
                      ),
                      Text("テスト Pos",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenAdapter.fontSize(18.0),
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )
                      ),
                    ],
                  ),
                ),
              ),
              // Row(
              //   children: [
              //     Text(
              //         "${controller.pos_ip.value}:",
              //         style: TextStyle(
              //           fontSize: ScreenAdapter.fontSize(22),
              //         )
              //     ),
              //     Text(
              //         "${controller.pos_port.value}",
              //         style: TextStyle(
              //           fontSize: ScreenAdapter.fontSize(22),
              //         )
              //     )
              //   ],
              // ),
            ),
          // if (controller.pos_ip.value != "")
          // SizedBox(width: ScreenAdapter.width(20)),
          // if (controller.pos_ip.value != "")
          // Switch(value: posCheckService.isActive, onChanged: (value) {
          //   posCheckService.toggleActive(value);
          //   controller.update();
          // }),

        ],
      ),
    );
  }

  _showPanelSettingDialog() async {
    Get.dialog(
        SetPosIpPage(
          posIp: controller.machineInfo.wlan_panel_print_ip,
          posPort: controller.machineInfo.wlan_panel_print_port,
          showRadio:0,
          onConfrimClick: (String posIp, String posPort) {
            if(posIp != ""){

              controller.machineInfo.wlan_panel_print_ip = posIp;
              controller.machineInfo.wlan_panel_print_port = posPort;


              controller.checkIsAllowWlanPanelPrint("1");
            }

          },
        )
    );
  }

  //预约弹出框
  _showPosSettingDialog() async {
    Get.dialog(
        SetPosIpPage(
          posIp: controller.machineInfo.pos_ip,
          posPort: controller.machineInfo.pos_port,
          showRadio:0,
          onConfrimClick: (String posIp, String posPort) {
            if(posIp != ""){

              controller.machineInfo.pos_ip = posIp;
              controller.machineInfo.pos_port = posPort;


              controller.checkIsAllowPos("1");
            }

          },
        )
    );
  }

  //设置USB打印机

  setIsAllowPrintOptions() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowPrintReceiptOptions(false);
            },
            child: Container(
              //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: !controller.machineInfo.printReceiptOptions ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("印刷しない",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: !controller.machineInfo.printReceiptOptions ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowPrintReceiptOptions(true);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.printReceiptOptions) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("印刷する",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.printReceiptOptions) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  //设置是否允许使用一元
  setIsAllowOneYen() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowOneYen("0");
            },
            child: Container(
              //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.is_allow_oneyen == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使えない",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.is_allow_oneyen == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowOneYen("1");
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.is_allow_oneyen == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使える",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.is_allow_oneyen == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  setIsAllow5000Yen() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllow5000Yen(false);
            },
            child: Container(
              //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: controller.machineInfo.isAllow5000 ? Colors.grey[200]:ColorsUtil.hexToColor("#409eff"),
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使えない",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: controller.machineInfo.isAllow5000 ? ColorsUtil.hexToColor("#000000"):ColorsUtil.hexToColor("#FFFFFF"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllow5000Yen(true);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: controller.machineInfo.isAllow5000 ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使える",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: controller.machineInfo.isAllow5000 ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  setIsAllow10000Yen() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllow10000Yen(false);
            },
            child: Container(
              //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: controller.machineInfo.isAllow10000 ? Colors.grey[200]:ColorsUtil.hexToColor("#409eff"),
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使えない",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: controller.machineInfo.isAllow10000 ? ColorsUtil.hexToColor("#000000"):ColorsUtil.hexToColor("#FFFFFF"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllow10000Yen(true);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: controller.machineInfo.isAllow10000 ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使える",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: controller.machineInfo.isAllow10000 ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  setIsAllow5Yen() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllow5Yen(false);
            },
            child: Container(
              //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: controller.machineInfo.isAllow5 ? Colors.grey[200]:ColorsUtil.hexToColor("#409eff"),
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使えない",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: controller.machineInfo.isAllow5 ? ColorsUtil.hexToColor("#000000"):ColorsUtil.hexToColor("#FFFFFF"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllow5Yen(true);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: controller.machineInfo.isAllow5 ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使える",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: controller.machineInfo.isAllow5 ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  setIsAllow10Yen() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllow10Yen(false);
            },
            child: Container(
              //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: controller.machineInfo.isAllow10 ? Colors.grey[200]:ColorsUtil.hexToColor("#409eff"),
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使えない",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: controller.machineInfo.isAllow10 ? ColorsUtil.hexToColor("#000000"):ColorsUtil.hexToColor("#FFFFFF"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllow10Yen(true);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: controller.machineInfo.isAllow10 ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("使える",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: controller.machineInfo.isAllow10 ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  setOpenRejishime() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowRejishime("0");
            },
            child: Container(
              //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.isAllowRejishime == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("オフ",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.isAllowRejishime == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowRejishime("1");
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.isAllowRejishime == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("オン",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.isAllowRejishime == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  //会计结算后返回
  setIsAllowSettlementHome() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowBackHome(true);
            },
            child: Container(
              //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.machineInfo.isBackHome) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("トップページに戻る",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machineInfo.isBackHome) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowBackHome(false);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: !(controller.machineInfo.isBackHome) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("メニューリストに戻る",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: !(controller.machineInfo.isBackHome) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  showSettingPassword() async {
    Get.dialog(
        SetPasswordPage()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text("システム設定")),
      body: GetBuilder<SystemSettingPageController>(builder: (controller){
        return controller.obx((state) => ListView(
          children: <Widget>[

            Container(
              decoration: new BoxDecoration(color: Colors.white),
              width: ScreenAdapter.width(820.0),
              margin: EdgeInsets.only(
                top: ScreenAdapter.height(30.0),
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                top: ScreenAdapter.height(5.0),
                left: ScreenAdapter.width(20.0),
                right: ScreenAdapter.width(20.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      /*Navigator.of(context).pushAndRemoveUntil(
                        new MaterialPageRoute(
                          builder: (BuildContext context) {
                            return new HomePage();
                          },
                        ),
                        (Route route) => false,
                      );*/
                      Get.back(result: "setting-back");
                      /*Future.delayed(Duration(milliseconds: 100), () {
                        Navigator.pushNamed(context, '/home');
                      });*/
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          left: ScreenAdapter.width(10),
                          right: ScreenAdapter.width(10)),
                      width: ScreenAdapter.width(120),
                      height: ScreenAdapter.height(65),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#67c23a"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text("戻る",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          showSettingPassword();
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          width: ScreenAdapter.width(180),
                          height: ScreenAdapter.height(65),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#409eff"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((16.0)),
                          ),
                          child: Text("パスワード",
                              style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(24),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )),
                        ),
                      ),
                      SizedBox(width: 30,),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              controller.showDownloadingAlert();
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(10),
                                  right: ScreenAdapter.width(10)),
                              width: ScreenAdapter.width(180),
                              height: ScreenAdapter.height(65),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorsUtil.hexToColor("#409eff"),
                                //设置圆角
                                borderRadius: new BorderRadius.circular((16.0)),
                              ),
                              child: Text("アップデート",
                                  style: TextStyle(
                                    fontFamily: 'NotoSansJP',
                                    fontSize: ScreenAdapter.fontSize(24),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              controller.uploadErrorLog();
                            },
                            child: Container(
                              padding:
                              EdgeInsets.only(right: ScreenAdapter.width(18)),
                              child: Text(
                                "バージョン：${controller.local_version.value}",
                                style: TextStyle(
                                    fontFamily: 'NotoSansJP',
                                    color: Colors.grey[500],
                                    fontSize: ScreenAdapter.fontSize(20.0)),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),

                ],
              ),
            ),
            Container(
              decoration: new BoxDecoration(color: Colors.white),
              margin: EdgeInsets.only(
                top: ScreenAdapter.height(10.0),
              ),
              padding: EdgeInsets.only(
                  top: ScreenAdapter.height(5.0),
                  left: ScreenAdapter.width(14.0),
                  right: ScreenAdapter.width(14.0),
                  bottom: ScreenAdapter.height(30)
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: ScreenAdapter.height(5)),
                    alignment: Alignment.center,
                    child: Text(
                      "セルフレジを設置",
                      style: TextStyle(
                        fontFamily: 'NotoSansJP',
                        fontSize: ScreenAdapter.fontSize(26),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      ),
                    ),
                  ),
                  Table(
                    border: TableBorder.all(),
                    columnWidths: const <int, TableColumnWidth>{
                      //0: IntrinsicColumnWidth(),
                      0: FixedColumnWidth(40),
                      1: FlexColumnWidth(970),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          Container(
                            //color: Colors.blue,
                            //height: ScreenAdapter.height(65),
                            width: ScreenAdapter.width(35),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Container(
                                  width: ScreenAdapter.width(35),
                                  child: Text(
                                    "一般設定",
                                    style: TextStyle(
                                        fontFamily: 'NotoSansJP',
                                        fontSize: ScreenAdapter.fontSize(24),
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            //height: ScreenAdapter.height(65),
                            alignment: Alignment.center,
                            child: Table(
                                border: TableBorder.all(),
                                columnWidths: const <int, TableColumnWidth>{
                                  //0: IntrinsicColumnWidth(),
                                  0:FlexColumnWidth(200),
                                  1: FlexColumnWidth(750),
                                },
                                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                children: <TableRow>[
                                  //if(controller.actuarial.value == true)
                                    TableRow(
                                        children: <Widget>[
                                          Container(
                                            //height: ScreenAdapter.height(65),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "モード",
                                              style: TextStyle(
                                                  fontFamily: 'NotoSansJP',
                                                  fontSize: ScreenAdapter.fontSize(22),
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ),
                                          setMachineMode(controller.machineInfo.machineModeInfo),//设置机器类型
                                        ]
                                    ), //设置机器类型
                                  if(controller.machineInfo.machineModeInfo['spicyHotPot'] == true)
                                    TableRow(
                                        children: <Widget>[
                                          Container(
                                            alignment: Alignment.center,
                                            child: Text(
                                              "麻辣烫注文",
                                              style: TextStyle(
                                                  fontFamily: 'NotoSansJP',
                                                  fontSize: ScreenAdapter.fontSize(22),
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ),
                                          setSpicyHotPotOrderType(),
                                        ]
                                    ),
                                  if(controller.lineup.value == true)
                                    TableRow(
                                        children: <Widget>[
                                          Container(
                                            //height: ScreenAdapter.height(65),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "予約サービス",
                                              style: TextStyle(
                                                  fontFamily: 'NotoSansJP',
                                                  fontSize: ScreenAdapter.fontSize(22),
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ),
                                          setIsReservation(),//设置机器类型
                                        ]
                                    ), //设置机器类型
                                  // TableRow(
                                  //     children: <Widget>[
                                  //       Container(
                                  //         //height: ScreenAdapter.height(65),
                                  //         alignment: Alignment.center,
                                  //         child: Text(
                                  //           "店内・テイクアウト",
                                  //           style: TextStyle(
                                  //               fontFamily: 'NotoSansJP',
                                  //               fontSize: ScreenAdapter.fontSize(22),
                                  //               fontWeight: FontWeight.w500
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       setDiningtype(),//食事のタイプ
                                  //     ]
                                  // ),
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "カテゴリ様式",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setMenuDirection(),//菜单方向
                                      ]
                                  ),
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "マシンタイプ",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setMachineType(),//菜单方向
                                      ]
                                  ),
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "領収書",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setIsAllowReceipt(),//设置是否允强制必须打印领収书
                                      ]
                                  ),
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Column(
                                            children: [
                                              Text(
                                                "レシート字体",
                                                style: TextStyle(
                                                    fontFamily: 'NotoSansJP',
                                                    fontSize: ScreenAdapter.fontSize(22),
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                              // Text(
                                              //   "（セルフレジから）",
                                              //   style: TextStyle(
                                              //     fontFamily: 'NotoSansJP',
                                              //       fontSize: ScreenAdapter.fontSize(18),
                                              //       fontWeight: FontWeight.w500,
                                              //     color: ColorsUtil.hexToColor("#d90000"),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                        setPrintPaperTxtSize(),//打印菜单文字大小
                                      ]
                                  ),
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "オーダーシート",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setIsAllowReceiptMenu(),//设置是否允强制必须打印领収书
                                      ]
                                  ),
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          height: ScreenAdapter.height(90),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "レシートオプション",
                                            style: TextStyle(
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setIsAllowPrintOptions(),//usb打印机

                                      ]
                                  ),
                                  if (!controller.appConfig.isFx)
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "一円",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setIsAllowOneYen(),//是否允许一元
                                      ]
                                  ),
                                  if (!controller.appConfig.isFx)
                                    TableRow(
                                        children: <Widget>[
                                          Container(
                                            //height: ScreenAdapter.height(65),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "五円",
                                              style: TextStyle(
                                                  fontFamily: 'NotoSansJP',
                                                  fontSize: ScreenAdapter.fontSize(22),
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ),
                                          setIsAllow5Yen(),//是否允许一元
                                        ]
                                    ),
                                  if (!controller.appConfig.isFx)
                                    TableRow(
                                        children: <Widget>[
                                          Container(
                                            //height: ScreenAdapter.height(65),
                                            alignment: Alignment.center,
                                            child: Text(
                                              "十円",
                                              style: TextStyle(
                                                  fontFamily: 'NotoSansJP',
                                                  fontSize: ScreenAdapter.fontSize(22),
                                                  fontWeight: FontWeight.w500
                                              ),
                                            ),
                                          ),
                                          setIsAllow10Yen(),//是否允许一元
                                        ]
                                    ),
                                  if (!controller.appConfig.isFx)
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "五千円",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setIsAllow5000Yen(),//是否允许一元
                                      ]
                                  ),
                                  if (!controller.appConfig.isFx)
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "一万円",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setIsAllow10000Yen(),//是否允许一元
                                      ]
                                  ),
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "会計完了",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setIsAllowSettlementHome(),//是否结算完后回到首页
                                      ]
                                  ),
                                  if (!controller.appConfig.isFx)
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "レジ締め",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setOpenRejishime(),//是否结算完后回到首页
                                      ]
                                  )
                                ]
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          Container(
                            //color: Colors.blue,
                            //height: ScreenAdapter.height(65),
                            width: ScreenAdapter.width(35),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Container(
                                  width: ScreenAdapter.width(35),
                                  child: Text(
                                    "プリンタ│",
                                    style: TextStyle(
                                        fontFamily: 'NotoSansJP',
                                        fontSize: ScreenAdapter.fontSize(24),
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            //height: ScreenAdapter.height(65),
                            alignment: Alignment.center,
                            padding: EdgeInsets.zero,
                            child: Column(
                              children: [

                                Table(
                                    border: TableBorder.all(),
                                    columnWidths: const <int, TableColumnWidth>{
                                      //0: IntrinsicColumnWidth(),
                                      0:FlexColumnWidth(1050),
                                    },
                                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                    children: <TableRow>[

                                      TableRow(
                                          children: <Widget>[
                                            Container(
                                              height: ScreenAdapter.height(50),
                                              padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                                              alignment: Alignment.centerLeft,
                                              child: Text("注：「キッチンプリンター」か「キッチン（ラベル）プリンター」かどちらか１台のご利用となります。",
                                                  style: TextStyle(
                                                    fontFamily: 'NotoSansJP',
                                                    fontSize: ScreenAdapter.fontSize(17),
                                                    fontWeight: FontWeight.w400,
                                                    color: ColorsUtil.hexToColor("#d90000"),
                                                  )),
                                            ),

                                          ]
                                      ),
                                    ]
                                ),
                                Table(
                                    border: TableBorder.all(),
                                    columnWidths: const <int, TableColumnWidth>{
                                      //0: IntrinsicColumnWidth(),
                                      0:FlexColumnWidth(200),
                                      1: FlexColumnWidth(750),
                                    },
                                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                    children: <TableRow>[
                                      

                                      TableRow(
                                          children: <Widget>[
                                            Container(
                                              height: ScreenAdapter.height(90),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "マシンプリンター",
                                                style: TextStyle(
                                                    fontSize: ScreenAdapter.fontSize(22),
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ),
                                            //setUSBPrint(),//usb打印机
                                            setMachinePrintSize(controller.machineInfo.machinePrintWidth)

                                          ]
                                      ),
                                      ...controller.machineInfo.printerList.map((printer) => printerSettingWidget(printer)).toList(),
                                      if (controller.machineInfo.printerList.length < 9)
                                        TableRow(
                                            children: <Widget>[
                                              Text(
                                                "追加",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'NotoSansJP',
                                                    fontSize: ScreenAdapter.fontSize(22),
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                              addButton()
                                            ]
                                        )

                                    ]
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        //0: IntrinsicColumnWidth(),
                        0: FlexColumnWidth(258),
                        1: FlexColumnWidth(750),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: <TableRow>[

                        TableRow(
                            children: <Widget>[
                              Container(
                                //height: ScreenAdapter.height(65),
                                alignment: Alignment.center,
                                child: Text(
                                  "番号パネルIP",
                                  style: TextStyle(
                                      fontFamily: 'NotoSansJP',
                                      fontSize: ScreenAdapter.fontSize(22),
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                              setIsAllowPanelDisplay(),//是否开启pos机刷卡
                            ]
                        ),
                      ]
                  ),
                  Table(
                      border: TableBorder.all(),
                      columnWidths: const <int, TableColumnWidth>{
                        //0: IntrinsicColumnWidth(),
                        0: FlexColumnWidth(258),
                        1: FlexColumnWidth(750),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: <TableRow>[

                        TableRow(
                            children: <Widget>[
                              Container(
                                //height: ScreenAdapter.height(65),
                                alignment: Alignment.center,
                                child: Text(
                                  "キャッシュレス端末",
                                  style: TextStyle(
                                      fontFamily: 'NotoSansJP',
                                      fontSize: ScreenAdapter.fontSize(22),
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                              setIsAllowPos(),//是否开启pos机刷卡
                            ]
                        ),
                      ]
                  ),

                  ...controller.machineInfo.sseSettingList.map((sseItem) =>
                      editSSETable(sseItem)
                  ).toList(),

                  /*setDiningtype(),//食事のタイプ
                  setMenuDirection(),//菜单方向
                  setPrintPaperTxtSize(),//打印菜单文字大小
                  setIsAllowReceipt(),//设置是否允强制必须打印领収书
                  setIsAllowReceiptMenu(),//设置是否允强制必须打印领収书
                  (controller.actuarial.value == true) ? setMachineMode() : Container(height: 0,), //设置机器类型
                  (controller.lineup.value == true) ? setIsReservation() : Container(height: 0,),  //是否开启预约服务
                  //setIsAllowAttendance(),//是否开启签到
                  setIsAllowPos(),//是否开启pos机刷卡
                  setIsAllowWlanPrint(),//是否开启网络打印机
                  setIsAllowWlanPrintTwo(),//第二台打印机
                  setIsAllowOneYen(),//是否允许一元
                  setIsAllowSettlementHome(),//是否结算完后回到首页*/
                ],
              ),
            ),
          ],
        ),
          onLoading: Center(
            child: CircularProgressIndicator(
              strokeWidth:6,
              valueColor:new AlwaysStoppedAnimation<Color>(ColorsUtil.hexToColor("#80B646")),
            ),
          ),
        );
      }),
    );
  }
}
