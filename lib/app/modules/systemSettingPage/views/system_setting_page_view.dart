import 'dart:ffi';

import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/system_setting_page_controller.dart';
import 'SetPassword.dart';
import 'SetPosIp.dart';

class SystemSettingPageView extends GetView {
  final SystemSettingPageController controller = Get.put(SystemSettingPageController());
  SystemSettingPageView({Key? key}) : super(key: key);

  //设置就餐类型
  setDiningtype() {
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
              controller.checkDiningtype("1");
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
                color: (controller.dining_type_one.value == true) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("店　内",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: 'NotoSansJP',
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.dining_type_one.value == true) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkDiningtype("2");
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
                color: (controller.dining_type_two.value == true) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("テイクアウト",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: 'NotoSansJP',
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.dining_type_two.value == true) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          /*InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkDiningtype("3");
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
                color: (controller.dining_type.value == "3") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("両方可",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.dining_type.value == "3") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),*/

        ],
      ),
    );
  }

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
                color: (controller.menu_direction.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.menu_direction.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
                color: (controller.menu_direction.value == "2") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.menu_direction.value == "2") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
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
              controller.checkPrintPaperTxtSize("1");
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
                color: (controller.print_paper_txt_size.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.print_paper_txt_size.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkPrintPaperTxtSize("2");
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
                color: (controller.print_paper_txt_size.value == "2") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.print_paper_txt_size.value == "2") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkPrintPaperTxtSize("3");
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
                color: (controller.print_paper_txt_size.value == "3") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("特　大",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.print_paper_txt_size.value == "3") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
                      color: (controller.is_allow_receipt.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                          color: (controller.is_allow_receipt.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
                      color: (controller.is_allow_receipt.value == "2") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                          color: (controller.is_allow_receipt.value == "2") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                        )
                    ),
                  ),
                ),

              ],
            ),
          ),
          Text("注：現金でお支払いの場合の設定です。他のお支払い方法の場合は全て「発行」となります。",
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
                      color: (controller.is_allow_receipt_menu.value == "2") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                          color: (controller.is_allow_receipt_menu.value == "2") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
                      color: (controller.is_allow_receipt_menu.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                          color: (controller.is_allow_receipt_menu.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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

  //设置机器类型
  setMachineMode() {
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
              controller.checkMachineMode("1");
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
                color: (controller.machine_mode.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("券売機",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: (controller.machine_mode.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkMachineMode("2");
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
                color: (controller.machine_mode.value == "2") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: RichText(
                text: TextSpan(
                    text: "精算機",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenAdapter.fontSize(22.0),
                      color: (controller.machine_mode.value == "2") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                    ),
                    children: [
                      TextSpan(
                        text: "（後払い）",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(18),
                          fontWeight: FontWeight.w400,
                          color: ColorsUtil.hexToColor("#d90000"),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkMachineMode("3");
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
                color: (controller.machine_mode.value == "3") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: RichText(
                text: TextSpan(
                    text: "精算機",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenAdapter.fontSize(22.0),
                      color: (controller.machine_mode.value == "3") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                    ),
                    children: [
                      TextSpan(
                        text: "（バーコード）",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(18),
                          fontWeight: FontWeight.w400,
                          color: ColorsUtil.hexToColor("#d90000"),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
        ],
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
                color: (controller.isReservation.value == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.isReservation.value == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
                color: (controller.isReservation.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.isReservation.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  //设置是否开启pos刷卡
  setIsAllowPos() {
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
                color: (controller.is_allow_pos.value == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.is_allow_pos.value == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
              width: ScreenAdapter.width(220),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.is_allow_pos.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.is_allow_pos.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          if (controller.pos_ip.value != "" && controller.pos_port.value != "")
          Container(
            margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
            child:
            InkWell(
              highlightColor: Colors.transparent, // 透明色
              splashColor: Colors.transparent, // 透明色
              onTap: (){
                controller.posTest(controller.pos_ip.value,controller.pos_port.value);
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
                            "${controller.pos_ip.value}:",
                            style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontSize: ScreenAdapter.fontSize(22),
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )
                        ),
                        Text(
                            "${controller.pos_port.value}",
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
          onConfrimClick: (String posIp, String posPort) {
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
    return Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
            padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: (){
                    controller.checkIsAllowWlanPrint("0");
                  },
                  child: Container(
                    //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                    //设置 child 居中
                    alignment: Alignment(0, 0),
                    height: ScreenAdapter.height(60),
                    width: ScreenAdapter.width(140),
                    //边框设置
                    decoration: new BoxDecoration(
                      //背景
                      color: (controller.is_allow_wlanPrint.value == "0" && controller.showPrintType.value==0) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                          color: (controller.is_allow_wlanPrint.value == "0" && controller.showPrintType.value==0) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                        )
                    ),
                  ),
                ),
                InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: (){
                    //controller.is_allow_wlanPrint_continuous.value = "0";
                    _showWlanPrintSettingDialog("0",0);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                    //设置 child 居中
                    alignment: Alignment(0, 0),
                    height: ScreenAdapter.height(60),
                    width: ScreenAdapter.width(140),
                    //边框设置
                    decoration: new BoxDecoration(
                      //背景
                      color: (controller.is_allow_wlanPrint.value == "1" && controller.is_allow_wlanPrint_continuous.value == "0" && controller.showPrintType.value==0) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //设置四周边框
                      //border: new Border.all(width: 1, color: Colors.red),
                    ),
                    child: RichText(
                      text: TextSpan(
                          text: "オン",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenAdapter.fontSize(22.0),
                            color: (controller.is_allow_wlanPrint.value == "1" && controller.is_allow_wlanPrint_continuous.value == "0" && controller.showPrintType.value==0) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                          ),
                          children: [
                            TextSpan(
                              text: "（単票）",
                              style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(18),
                                fontWeight: FontWeight.w400,
                                color: ColorsUtil.hexToColor("#d90000"),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
                InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: (){

                    _showWlanPrintSettingDialog("1",0);
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                    //设置 child 居中
                    alignment: Alignment(0, 0),
                    height: ScreenAdapter.height(60),
                    width: ScreenAdapter.width(140),
                    //边框设置
                    decoration: new BoxDecoration(
                      //背景
                      color: (controller.is_allow_wlanPrint.value == "1" && controller.is_allow_wlanPrint_continuous.value == "1" && controller.showPrintType.value==0) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                      //设置四周圆角 角度
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //设置四周边框
                      //border: new Border.all(width: 1, color: Colors.red),
                    ),
                    child: RichText(
                      text: TextSpan(
                          text: "オン",
                          style: TextStyle(
                            fontFamily: 'NotoSansJP',
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenAdapter.fontSize(22.0),
                            color: (controller.is_allow_wlanPrint.value == "1" && controller.is_allow_wlanPrint_continuous.value == "1" && controller.showPrintType.value==0) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                          ),
                          children: [
                            TextSpan(
                              text: "（連票）",
                              style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(18),
                                fontWeight: FontWeight.w400,
                                color: ColorsUtil.hexToColor("#d90000"),
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
                if(controller.wlan_print_ip.value != "" && controller.wlan_print_port.value != "" && controller.showPrintType.value==0)
                  InkWell(
                    highlightColor: Colors.transparent, // 透明色
                    splashColor: Colors.transparent, // 透明色
                    onTap: (){
                      controller.printTest(controller.wlan_print_ip.value,controller.wlan_print_port.value,printType:controller.showPrintType.value);
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
                                  "${controller.wlan_print_ip.value}:",
                                  style: TextStyle(
                                    fontFamily: 'NotoSansJP',
                                    fontSize: ScreenAdapter.fontSize(20),
                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                  )
                              ),
                              Text(
                                  "${controller.wlan_print_port.value}",
                                  style: TextStyle(
                                    fontFamily: 'NotoSansJP',
                                    fontSize: ScreenAdapter.fontSize(20),
                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                  )
                              )
                            ],
                          ),
                          Text("テスト印刷",
                              style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontWeight: FontWeight.w400,
                                fontSize: ScreenAdapter.fontSize(20.0),
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )
                          ),
                        ],
                      ),
                    ),
                  ),

              ],
            ),
          ),
          Table(
              border: TableBorder.all(),
              columnWidths: const <int, TableColumnWidth>{
                //0: IntrinsicColumnWidth(),
                0: FlexColumnWidth(200),
                1: FlexColumnWidth(550),
              },
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[

                TableRow(
                    children: <Widget>[
                      Container(
                        height: ScreenAdapter.height(80),
                        alignment: Alignment.center,
                        child: Text(
                          "プリント方向",
                          style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontSize: ScreenAdapter.fontSize(22),
                              fontWeight: FontWeight.w500
                          ),
                        ),
                      ),
                      setPrintDirection(1,controller.printDirection),//第二台打印机

                    ]
                ),

              ]
          ),
        ]
    );
  }

  setIsAllowWlanLablePrint() {
    return
      Column(
          children: [
            Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowWlanPrint("0");
            },
            child: Container(
              //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(140),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.is_allow_wlanPrint.value == "0" && controller.showPrintType.value==1) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.is_allow_wlanPrint.value == "0" && controller.showPrintType.value==1) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              //controller.is_allow_wlanPrint_continuous.value = "0";
              _showWlanPrintSettingDialog("0",1);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(140),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: (controller.is_allow_wlanPrint.value == "1" && controller.is_allow_wlanPrint_continuous.value == "0" && controller.showPrintType.value==1) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: RichText(
                text: TextSpan(
                    text: "オン",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenAdapter.fontSize(22.0),
                      color: (controller.is_allow_wlanPrint.value == "1" && controller.is_allow_wlanPrint_continuous.value == "0" && controller.showPrintType.value==1) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                    ),
                    children: [
                      TextSpan(
                        text: "",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontSize: ScreenAdapter.fontSize(18),
                          fontWeight: FontWeight.w400,
                          color: ColorsUtil.hexToColor("#d90000"),
                        ),
                      ),
                    ]),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
            //设置 child 居中
            alignment: Alignment(0, 0),
            height: ScreenAdapter.height(60),
            width: ScreenAdapter.width(140),
          ),
          if(controller.wlan_print_ip.value != "" && controller.wlan_print_port.value != "" && controller.showPrintType.value==1)
            InkWell(
              highlightColor: Colors.transparent, // 透明色
              splashColor: Colors.transparent, // 透明色
              onTap: (){
                controller.printTest(controller.wlan_print_ip.value,controller.wlan_print_port.value,printType:controller.showPrintType.value);
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
                            "${controller.wlan_print_ip.value}:",
                            style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontSize: ScreenAdapter.fontSize(20),
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )
                        ),
                        Text(
                            "${controller.wlan_print_port.value}",
                            style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontSize: ScreenAdapter.fontSize(20),
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                            )
                        )
                      ],
                    ),
                    Text("テスト印刷",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          fontWeight: FontWeight.w400,
                          fontSize: ScreenAdapter.fontSize(20.0),
                          color: ColorsUtil.hexToColor("#FFFFFF"),
                        )
                    ),
                  ],
                ),
              ),
            ),

        ],
      ),
    ),
            Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{
                  //0: IntrinsicColumnWidth(),
                  0: FlexColumnWidth(200),
                  1: FlexColumnWidth(550),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[

                  TableRow(
                      children: <Widget>[
                        Container(
                          height: ScreenAdapter.height(80),
                          alignment: Alignment.center,
                          child: Text(
                            "プリント方向",
                            style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                        setPrintDirection(3,controller.printThreeDirection),//第二台打印机

                      ]
                  ),

                ]
            ),
            Table(
                border: TableBorder.all(),
                columnWidths: const <int, TableColumnWidth>{
                  //0: IntrinsicColumnWidth(),
                  0: FlexColumnWidth(200),
                  1: FlexColumnWidth(550),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: <TableRow>[

                  TableRow(
                      children: <Widget>[
                        Container(
                          height: ScreenAdapter.height(80),
                          alignment: Alignment.center,
                          child: Text(
                            "プリントサイズ",
                            style: TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                        setLabelPrintSize(),//第二台打印机

                      ]
                  ),

                ]
            ),
          ]
      );
  }

  //设置网络打印机ip
  _showWlanPrintSettingDialog(continousType,showPrintType) async {
    Get.dialog(
        SetPosIpPage(
          posIp: controller.wlan_print_ip.value,
          posPort: controller.wlan_print_port.value,
          showRadio:1,
          showPrintType:controller.showPrintType.value,
          onConfrimClick: (String printIp, String printPort) {
            if(printIp != ""){

                controller.wlan_print_ip.value = printIp;
                controller.wlan_print_port.value = printPort;
                controller.showPrintType.value = showPrintType;
                controller.is_allow_wlanPrint_continuous.value = continousType;
              controller.checkIsAllowWlanPrint("1");
            }

          },
        )
    );
  }

  //设置是否开启打印机
  setIsAllowWlanPrintTwo() {

     return
      Column(
        children: [
          Container(
          margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
          padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
          child:
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    highlightColor: Colors.transparent, // 透明色
                    splashColor: Colors.transparent, // 透明色
                    onTap: (){
                      controller.checkIsAllowWlanPrintTwo("0");
                    },
                    child: Container(
                      //margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                      //设置 child 居中
                      alignment: Alignment(0, 0),
                      height: ScreenAdapter.height(60),
                      width: ScreenAdapter.width(140),
                      //边框设置
                      decoration: new BoxDecoration(
                        //背景
                        color: (controller.is_allow_wlanPrint_Two.value == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                            color: (controller.is_allow_wlanPrint_Two.value == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                          )
                      ),
                    ),
                  ),
                  InkWell(
                    highlightColor: Colors.transparent, // 透明色
                    splashColor: Colors.transparent, // 透明色
                    onTap: (){

                      _showWlanPrintSettingDialogTwo("0");
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                      //设置 child 居中
                      alignment: Alignment(0, 0),
                      height: ScreenAdapter.height(60),
                      width: ScreenAdapter.width(140),
                      //边框设置
                      decoration: new BoxDecoration(
                        //背景
                        color: (controller.is_allow_wlanPrint_Two.value == "1" && controller.is_allow_wlanPrint_Two_continuous.value == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                        //设置四周圆角 角度
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        //设置四周边框
                        //border: new Border.all(width: 1, color: Colors.red),
                      ),
                      child: RichText(
                        text: TextSpan(
                            text: "オン",
                            style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontWeight: FontWeight.w400,
                              fontSize: ScreenAdapter.fontSize(22.0),
                              color: (controller.is_allow_wlanPrint_Two.value == "1" && controller.is_allow_wlanPrint_Two_continuous.value == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                            ),
                            children: [
                              TextSpan(
                                text: "（単票）",
                                style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(18),
                                  fontWeight: FontWeight.w400,
                                  color: ColorsUtil.hexToColor("#d90000"),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                  InkWell(
                    highlightColor: Colors.transparent, // 透明色
                    splashColor: Colors.transparent, // 透明色
                    onTap: (){
                      _showWlanPrintSettingDialogTwo("1");
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                      //设置 child 居中
                      alignment: Alignment(0, 0),
                      height: ScreenAdapter.height(60),
                      width: ScreenAdapter.width(140),
                      //边框设置
                      decoration: new BoxDecoration(
                        //背景
                        color: (controller.is_allow_wlanPrint_Two.value == "1" && controller.is_allow_wlanPrint_Two_continuous.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                        //设置四周圆角 角度
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        //设置四周边框
                        //border: new Border.all(width: 1, color: Colors.red),
                      ),
                      child: RichText(
                        text: TextSpan(
                            text: "オン",
                            style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontWeight: FontWeight.w400,
                              fontSize: ScreenAdapter.fontSize(22.0),
                              color: (controller.is_allow_wlanPrint_Two.value == "1" && controller.is_allow_wlanPrint_Two_continuous.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                            ),
                            children: [
                              TextSpan(
                                text: "（連票）",
                                style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(18),
                                  fontWeight: FontWeight.w400,
                                  color: ColorsUtil.hexToColor("#d90000"),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ),
                  if(controller.wlan_print_ip_Two.value != "" && controller.wlan_print_port_Two.value != "")
                    InkWell(
                      highlightColor: Colors.transparent, // 透明色
                      splashColor: Colors.transparent, // 透明色
                      onTap: (){
                        controller.printTest(controller.wlan_print_ip_Two.value,controller.wlan_print_port_Two.value);
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
                                    "${controller.wlan_print_ip_Two.value}:",
                                    style: TextStyle(
                                      fontFamily: 'NotoSansJP',
                                      fontSize: ScreenAdapter.fontSize(20),
                                      color: ColorsUtil.hexToColor("#FFFFFF"),
                                    )
                                ),
                                Text(
                                    "${controller.wlan_print_port_Two.value}",
                                    style: TextStyle(
                                      fontFamily: 'NotoSansJP',
                                      fontSize: ScreenAdapter.fontSize(20),
                                      color: ColorsUtil.hexToColor("#FFFFFF"),
                                    )
                                )
                              ],
                            ),
                            Text("テスト印刷",
                                style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontWeight: FontWeight.w400,
                                  fontSize: ScreenAdapter.fontSize(20.0),
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )
                            ),
                          ],
                        ),
                      ),
                    ),

                ],
              )),
              Table(
                  border: TableBorder.all(),
                  columnWidths: const <int, TableColumnWidth>{
                    //0: IntrinsicColumnWidth(),
                    0: FlexColumnWidth(200),
                    1: FlexColumnWidth(550),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[

                    TableRow(
                        children: <Widget>[
                          Container(
                            height: ScreenAdapter.height(80),
                            alignment: Alignment.center,
                            child: Text(
                              "プリント方向",
                              style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(22),
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                          ),
                          setPrintDirection(2,controller.printTwoDirection),//第二台打印机

                        ]
                    ),

                  ]
              ),

            ]
          );
  }


  //设置网络打印机ip
  _showWlanPrintSettingDialogTwo(continousType) async {
    Get.dialog(
        SetPosIpPage(
      posIp: controller.wlan_print_ip_Two.value,
      posPort: controller.wlan_print_port_Two.value,
      showRadio:0,
      onConfrimClick: (String printIp, String printPort) {
        if(printIp != ""){
          controller.wlan_print_ip_Two.value = printIp;
          controller.wlan_print_port_Two.value = printPort;

          controller.is_allow_wlanPrint_Two_continuous.value = continousType;
          controller.checkIsAllowWlanPrintTwo("1");
        }

      },
    )
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
                color: (controller.is_allow_oneyen.value == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.is_allow_oneyen.value == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
                color: (controller.is_allow_oneyen.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.is_allow_oneyen.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
              controller.checkIsAllowRejishime("1");
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
                color: (controller.is_allow_rejishime.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.is_allow_rejishime.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowRejishime("0");
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
                color: (controller.is_allow_rejishime.value == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.is_allow_rejishime.value == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),

        ],
      ),
    );
  }

  setLabelPrintSize() {

    final _labelPrintSize = {"50x30":384,"40x30":284};

    return Container(
        margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
        padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(3),bottom: ScreenAdapter.height(3)),
        child: Wrap(
          spacing: ScreenAdapter.width(15), // 主轴(水平)方向间距
          children: _labelPrintSize.keys.map((e) {
            return InkWell(
              highlightColor: Colors.transparent, // 透明色
              splashColor: Colors.transparent, // 透明色
              onTap: (){
                controller.setLabelPrintSize(_labelPrintSize[e]?.toDouble());
              },
              child: Container(
                //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
                //设置 child 居中
                alignment: Alignment(0, 0),
                height: ScreenAdapter.height(60),
                width: ScreenAdapter.width(140),
                //边框设置
                decoration: new BoxDecoration(
                  //背景
                  color: (controller.printLabelWidth.value == _labelPrintSize[e]) ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],//
                  //设置四周圆角 角度
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  //设置四周边框
                  //border: new Border.all(width: 1, color: Colors.red),
                ),
                child: Text("$e",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.w400,
                      fontSize: ScreenAdapter.fontSize(22.0),
                      color: (controller.printLabelWidth.value == _labelPrintSize[e]) ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                    )
                ),
              ),
            );
          }).toList(),
        ),
    );
  }

  setPrintDirection(index,printDirection) {
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
              controller.setPrintDirection("0",index);
            },
            child: Container(
              //1margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(140),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: !printDirection.value ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("デフォルト",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: !printDirection.value ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.setPrintDirection("1",index);
            },
            child: Container(
              margin: EdgeInsets.only(left: ScreenAdapter.width(15)),
              //设置 child 居中
              alignment: Alignment(0, 0),
              height: ScreenAdapter.height(60),
              width: ScreenAdapter.width(140),
              //边框设置
              decoration: new BoxDecoration(
                //背景
                color: printDirection.value ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
                //设置四周圆角 角度
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                //设置四周边框
                //border: new Border.all(width: 1, color: Colors.red),
              ),
              child: Text("逆に",
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontWeight: FontWeight.w400,
                    fontSize: ScreenAdapter.fontSize(22.0),
                    color: printDirection.value ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
              controller.checkIsAllowBackHome("0");
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
                color: (controller.is_allow_backhome.value == "0") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.is_allow_backhome.value == "0") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
                  )
              ),
            ),
          ),
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: (){
              controller.checkIsAllowBackHome("1");
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
                color: (controller.is_allow_backhome.value == "1") ? ColorsUtil.hexToColor("#409eff"):Colors.grey[200],
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
                    color: (controller.is_allow_backhome.value == "1") ? ColorsUtil.hexToColor("#FFFFFF"):ColorsUtil.hexToColor("#000000"),
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
                                  if(controller.actuarial.value == true)
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
                                        setMachineMode(),//设置机器类型
                                      ]
                                  ), //设置机器类型
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
                                  TableRow(
                                      children: <Widget>[
                                        Container(
                                          //height: ScreenAdapter.height(65),
                                          alignment: Alignment.center,
                                          child: Text(
                                            "店内・テイクアウト",
                                            style: TextStyle(
                                                fontFamily: 'NotoSansJP',
                                                fontSize: ScreenAdapter.fontSize(22),
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                        ),
                                        setDiningtype(),//食事のタイプ
                                      ]
                                  ),
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
                                              Text(
                                                "（セルフレジから）",
                                                style: TextStyle(
                                                  fontFamily: 'NotoSansJP',
                                                    fontSize: ScreenAdapter.fontSize(18),
                                                    fontWeight: FontWeight.w500,
                                                  color: ColorsUtil.hexToColor("#d90000"),
                                                ),
                                              ),
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
                                  // TableRow(
                                  //     children: <Widget>[
                                  //       Container(
                                  //         //height: ScreenAdapter.height(65),
                                  //         alignment: Alignment.center,
                                  //         child: Text(
                                  //           "レジ締め",
                                  //           style: TextStyle(
                                  //               fontFamily: 'NotoSansJP',
                                  //               fontSize: ScreenAdapter.fontSize(22),
                                  //               fontWeight: FontWeight.w500
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       setOpenRejishime(),//是否结算完后回到首页
                                  //     ]
                                  // )
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
                                                "キッチン",
                                                style: TextStyle(
                                                    fontFamily: 'NotoSansJP',
                                                    fontSize: ScreenAdapter.fontSize(22),
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ),
                                            setIsAllowWlanPrint(),//是否开启网络打印机

                                          ]
                                      ),
                                      TableRow(
                                          children: <Widget>[
                                            Container(
                                              height: ScreenAdapter.height(90),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "キッチン（ラベル）",
                                                style: TextStyle(
                                                    fontFamily: 'NotoSansJP',
                                                    fontSize: ScreenAdapter.fontSize(22),
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ),
                                            setIsAllowWlanLablePrint(),//是否开启网络打印机

                                          ]
                                      ),
                                    ]
                                ),
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
                                      0: FlexColumnWidth(200),
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
                                                "カウンター",
                                                style: TextStyle(
                                                    fontFamily: 'NotoSansJP',
                                                    fontSize: ScreenAdapter.fontSize(22),
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ),
                                            setIsAllowWlanPrintTwo(),//第二台打印机

                                          ]
                                      ),

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
