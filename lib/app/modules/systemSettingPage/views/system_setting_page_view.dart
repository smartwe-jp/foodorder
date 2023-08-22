import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/system_setting_page_controller.dart';
import 'SetPassword.dart';
import 'SetPosIp.dart';

class SystemSettingPageView extends GetView {
  final SystemSettingPageController controller = Get.put(SystemSettingPageController());
  SystemSettingPageView({Key key}) : super(key: key);

  //设置就餐类型
  setDiningtype() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("利用形式",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Text("(お持帰りと店内のご利用で税率が異なります。)",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkDiningtype("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("店内のみ",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.dining_type.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkDiningtype("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(220),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("テイクアウトのみ",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.dining_type.value == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkDiningtype("3");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("両方可",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.dining_type.value == "3")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  //设置菜单方向
  setMenuDirection() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("メニューバーの表示",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkMenuDirection("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("上部横並び",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.menu_direction.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkMenuDirection("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("左側縦表示",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.menu_direction.value == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  //设置打印菜单部分文字大小
  setPrintPaperTxtSize() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("レシート字体設置",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkPrintPaperTxtSize("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("普通",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.print_paper_txt_size.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkPrintPaperTxtSize("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("大",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.print_paper_txt_size.value == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkPrintPaperTxtSize("3");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("特大",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.print_paper_txt_size.value == "3")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  //设置是否必须打印领収书
  setIsAllowReceipt() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("領収書の発行の設定",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Text("（必須を選ぶ場合は、領収書が自動的に印刷されます。）",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkIsAllowReceipt("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("必須",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_receipt.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkIsAllowReceipt("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("要確認",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_receipt.value == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  //设置机器类型
  setMachineMode() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("マシンモード設定",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkMachineMode("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("券売機モード",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.machine_mode.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkMachineMode("2");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("精算機モード",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.machine_mode.value == "2")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                /*InkWell(
                  onTap: () {
                    checkMachineMode("3");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("自助收银机",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (_machine_mode == "3")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),*/

              ],
            ),
          ),
        ],
      ),
    );
  }

  //设置是否开启预约
  setIsReservation() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("予約サービス設定",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkIsReservation("0");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("停止",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.isReservation.value == "0")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkIsReservation("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("起動",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.isReservation.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  //设置是否开启pos刷卡
  setIsAllowPos() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("キャッシュレス端末設定",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkIsAllowPos("0");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("OFF",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_pos.value == "0")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    //if(_pos_ip == ""){
                    _showPosSettingDialog();

                    //}
                    /*else{
                      checkIsAllowPos("1");
                    }*/
                  },
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(10),
                                right: ScreenAdapter.width(10)),
                            width: ScreenAdapter.width(190),
                            height: ScreenAdapter.height(65),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#409eff"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            //お持ち帰り
                            child: Text("ON",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                          (controller.pos_ip.value != "" && controller.pos_port.value != "") ? Row(
                            children: [
                              Text(
                                  "ip:${controller.pos_ip.value}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              ),
                              Text(
                                  "Port:${controller.pos_port.value}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              )
                            ],
                          ) : Container(height: 0,)
                        ],
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_pos.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(45),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  //预约弹出框
  _showPosSettingDialog() async {
    Get.dialog(
        SetPosIpPage(
          posIp: controller.pos_ip.value,
          posPort: controller.pos_port.value,
          showRadio:0,
          onConfrimClick: (String posIp, String posPort, int showPrintType) {
            if(posIp != ""){

                controller.pos_ip.value = posIp;
                controller.pos_port.value = posPort;


              controller.checkIsAllowPos("1");
            }

          },
        )
    );
  }

  //设置是否开启打印机
  setIsAllowWlanPrint() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("キッチンプリンター",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkIsAllowWlanPrint("0");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("OFF",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_wlanPrint.value == "0")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    //if(_pos_ip == ""){
                    _showWlanPrintSettingDialog();

                    //}
                    /*else{
                      checkIsAllowPos("1");
                    }*/
                  },
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(10),
                                right: ScreenAdapter.width(10)),
                            width: ScreenAdapter.width(190),
                            height: ScreenAdapter.height(65),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#409eff"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            //お持ち帰り
                            child: Text("ON",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                          (controller.wlan_print_ip.value != "" && controller.wlan_print_port.value != "") ? Row(
                            children: [
                              Text(
                                  "ip:${controller.wlan_print_ip.value}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              ),
                              Text(
                                  "Port:${controller.wlan_print_port.value}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              )
                            ],
                          ) : Container(height: 0,)
                        ],
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_wlanPrint.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(45),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                if(controller.wlan_print_ip.value != "" && controller.wlan_print_port.value != "")
                  InkWell(
                    onTap: () {
                      controller.printTest(controller.wlan_print_ip.value,controller.wlan_print_port.value,printType:controller.showPrintType.value);
                    },
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(10),
                                  right: ScreenAdapter.width(10)),
                              width: ScreenAdapter.width(190),
                              height: ScreenAdapter.height(65),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorsUtil.hexToColor("#409eff"),
                                //设置圆角
                                borderRadius: new BorderRadius.circular((16.0)),
                              ),
                              //お持ち帰り
                              child: Text("テスト印刷",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(24),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                  )),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  //设置网络打印机ip
  _showWlanPrintSettingDialog() async {
    Get.dialog(
        SetPosIpPage(
          posIp: controller.wlan_print_ip.value,
          posPort: controller.wlan_print_port.value,
          showRadio:1,
          showPrintType:controller.showPrintType.value,
          onConfrimClick: (String printIp, String printPort, int showPrintType) {
            if(printIp != ""){

                controller.wlan_print_ip.value = printIp;
                controller.wlan_print_port.value = printPort;
                controller.showPrintType.value = showPrintType;

              controller.checkIsAllowWlanPrint("1");
            }

          },
        )
    );
  }

  //设置是否开启打印机
  setIsAllowWlanPrintTwo() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("カウンタープリンター",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkIsAllowWlanPrintTwo("0");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("OFF",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_wlanPrint_Two.value == "0")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    //if(_pos_ip == ""){
                    _showWlanPrintSettingDialogTwo();

                    //}
                    /*else{
                      checkIsAllowPos("1");
                    }*/
                  },
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(10),
                                right: ScreenAdapter.width(10)),
                            width: ScreenAdapter.width(190),
                            height: ScreenAdapter.height(65),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#409eff"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            //お持ち帰り
                            child: Text("ON",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                          (controller.wlan_print_ip_Two.value != "" && controller.wlan_print_port_Two.value != "") ? Row(
                            children: [
                              Text(
                                  "ip:${controller.wlan_print_ip_Two.value}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              ),
                              Text(
                                  "Port:${controller.wlan_print_port_Two.value}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22),
                                  )
                              )
                            ],
                          ) : Container(height: 0,)
                        ],
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_wlanPrint_Two.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(45),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                if(controller.wlan_print_ip_Two.value != "" && controller.wlan_print_port_Two.value != "")
                  InkWell(
                    onTap: () {
                      controller.printTest(controller.wlan_print_ip_Two.value,controller.wlan_print_port_Two.value);
                    },
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(10),
                                  right: ScreenAdapter.width(10)),
                              width: ScreenAdapter.width(190),
                              height: ScreenAdapter.height(65),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorsUtil.hexToColor("#409eff"),
                                //设置圆角
                                borderRadius: new BorderRadius.circular((16.0)),
                              ),
                              //お持ち帰り
                              child: Text("テスト印刷",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(24),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                  )),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }


  //设置网络打印机ip
  _showWlanPrintSettingDialogTwo() async {
    Get.dialog(
        SetPosIpPage(
      posIp: controller.wlan_print_ip_Two.value,
      posPort: controller.wlan_print_port_Two.value,
      showRadio:0,
      onConfrimClick: (String printIp, String printPort, int showPrintType) {
        if(printIp != ""){
          controller.wlan_print_ip_Two.value = printIp;
          controller.wlan_print_port_Two.value = printPort;

          controller.checkIsAllowWlanPrintTwo("1");
        }

      },
    )
    );
  }

  //设置是否允许使用一元
  setIsAllowOneYen() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("お釣り1円",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkIsAllowOneYen("0");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("不使用",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_oneyen.value == "0")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkIsAllowOneYen("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("使用",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_oneyen.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  //设置是否允许使用一元
  setIsAllowSettlementHome() {
    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("都度topページに",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            width: ScreenAdapter.width(1050.0),
            padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    controller.checkIsAllowBackHome("0");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text("戻る",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_backhome.value == "0")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    controller.checkIsAllowBackHome("1");
                  },
                  child: Stack(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)),
                        width: ScreenAdapter.width(190),
                        height: ScreenAdapter.height(65),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: ColorsUtil.hexToColor("#409eff"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        //お持ち帰り
                        child: Text("戻らない",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )),
                      ),
                      //绝对定位 盖章
                      (controller.is_allow_backhome.value == "1")
                          ? Positioned(
                        right: ScreenAdapter.width(15),
                        top: ScreenAdapter.height(20),
                        child: Container(
                          width: ScreenAdapter.width(40),
                          height: ScreenAdapter.height(40),
                          padding: EdgeInsets.only(
                              top: ScreenAdapter.height(4),
                              left: ScreenAdapter.width(10)),
                          //alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            image: DecorationImage(
                              image:
                              AssetImage(GImage.getImageString("imgpublic", "optionChecked")),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      )
                          : Container(
                        height: 0,
                      ),
                    ],
                  ),
                ),

              ],
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
      appBar: AppBar(title: Text("システム設定")),
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
                      Get.back();
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
                            fontSize: ScreenAdapter.fontSize(24),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                          )),
                    ),
                  ),
                  Row(
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
                                fontSize: ScreenAdapter.fontSize(24),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )),
                        ),
                      ),
                      SizedBox(width: 30,),
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
                                fontSize: ScreenAdapter.fontSize(24),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            Container(
              decoration: new BoxDecoration(color: Colors.white),
              margin: EdgeInsets.only(
                top: ScreenAdapter.height(5.0),
              ),
              padding: EdgeInsets.only(
                top: ScreenAdapter.height(10.0),
                left: ScreenAdapter.width(14.0),
                right: ScreenAdapter.width(14.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  SizedBox(
                    height: ScreenAdapter.height(10),
                  ),
                  setDiningtype(),//食事のタイプ
                  setMenuDirection(),//菜单方向
                  //setPrintPaperSize(),//打印纸大小
                  setPrintPaperTxtSize(),//打印菜单文字大小
                  setIsAllowReceipt(),//设置是否允强制必须打印领収书
                  (controller.actuarial.value == true) ? setMachineMode() : Container(height: 0,), //设置机器类型
                  (controller.lineup.value == true) ? setIsReservation() : Container(height: 0,),  //是否开启预约服务
                  //setIsAllowAttendance(),//是否开启签到
                  setIsAllowPos(),//是否开启pos机刷卡
                  setIsAllowWlanPrint(),//是否开启网络打印机
                  setIsAllowWlanPrintTwo(),//第二台打印机
                  setIsAllowOneYen(),//是否允许一元
                  setIsAllowSettlementHome(),//是否结算完后回到首页
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
