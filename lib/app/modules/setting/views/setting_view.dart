import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller_extension.dart';
import 'package:foodorder/app/modules/setting/views/CycleCashSettingView.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../../TransitPage/views/transit_page_view.dart';
import '../controllers/setting_controller.dart';
import 'CashSettingView.dart';

class SettingView extends GetView<SettingController> {
  final SettingController controller = Get.put(SettingController());
  SettingView({Key? key}) : super(key: key);

  //支付金额展示
  getDepositListShow() {
    final depositList = {
      "預り金": controller.depositData.value['deposit_payment'],
      "現金": controller.depositData.value['deposit_crash'],
      "Alipay": controller.depositData.value['deposit_alipay'],
      "PayPay": controller.depositData.value['deposit_paypay'],
      "WechatPay": controller.depositData.value['deposit_wechat'],
    };
    return Container(
      margin: EdgeInsets.only(
          top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("売上",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                fontFamily: GFont.getFontFamily(),
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
            padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
            //width: ScreenAdapter.width(620),
            decoration: BoxDecoration(
                color: Colors.white12,
                border: Border(
                  //bottom: BorderSide(color: Colors.grey, width: 1.0),
                  top: BorderSide(color: Colors.grey.shade400, width: 1.0),
                  left: BorderSide(color: Colors.grey.shade400, width: 1.0),
                  right: BorderSide(color: Colors.grey.shade400, width: 1.0),
                )),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border(
                        bottom:
                        BorderSide(color: Colors.grey.shade400, width: 1.0),
                        //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                      )),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children:
                    depositList.keys.map((key) {
                      return Expanded(
                          child: Container(
                            //width: ScreenAdapter.width(200),
                            height: ScreenAdapter.height(45),
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(5),
                                right: ScreenAdapter.width(5)),
                            alignment: Alignment.center,
                            child: Text(key,
                                style: TextStyle(
                                  fontFamily: 'NotoSansJP',
                                  fontSize: ScreenAdapter.fontSize(20),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#000000"),
                                )),
                          )
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border(
                        bottom:
                        BorderSide(color: Colors.grey.shade400, width: 1.0),
                        //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                      )),
                  child: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:
                    depositList.values.map((value) {
                      return
                        Expanded(
                          child:Container(
                            //width: ScreenAdapter.width(200),
                            height: ScreenAdapter.height(45),
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(5),
                                right: ScreenAdapter.width(5)),
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                  text: value.toString(),
                                  style: TextStyle(
                                    fontFamily: 'NotoSansJP',
                                    fontSize: ScreenAdapter.fontSize(22),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor("#000000"),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "円",
                                      style: TextStyle(
                                        fontFamily: 'NotoSansJP',
                                        fontSize:
                                        ScreenAdapter.fontSize(18),
                                        fontWeight: FontWeight.w500,
                                        color: ColorsUtil.hexToColor(
                                            "#000000"),
                                      ),
                                    ),
                                  ]),
                            ),
                          )
                        );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  rePrintArea() {
    return Container(
      child:
      Row (
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column (
            children: [
              // Text("レシート再印刷",
              //     style: TextStyle(
              //       fontSize: ScreenAdapter.fontSize(22),
              //       fontWeight: FontWeight.w600,
              //       color: ColorsUtil.hexToColor("#000000"),
              //     )),
              InkWell(
                highlightColor: Colors.transparent, // 透明色
                splashColor: Colors.transparent, // 透明色
                onTap: (){
                  //controller.printPreviewReceipt();
                  Get.toNamed('/receipt_query', arguments: {"machineCode": controller.machineCode.value});
                },
                child: Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.height(15), right: ScreenAdapter.height(15)),
                  margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                  //设置 child 居中
                  alignment: Alignment(0, 0),
                  height: ScreenAdapter.height(65),
                  //width: ScreenAdapter.width(160),
                  //边框设置
                  decoration: new BoxDecoration(
                    //背景
                    color: ColorsUtil.hexToColor("#409eff"),
                    //设置四周圆角 角度
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    //设置四周边框
                    //border: new Border.all(width: 1, color: Colors.red),
                  ),
                  child: Text(
                      "領収書再印刷",
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: ScreenAdapter.fontSize(24),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#FFFFFF"),
                      )
                  ),
                ),
              )
            ],

          ),
          SizedBox(width: ScreenAdapter.width(10)),
          if(controller.is_reimburse.value == "1")
            InkWell(
              onTap: () {
                Get.toNamed('/reimburse-order', arguments: {"machineCode": controller.machineCode.value});
              },
              child: Container(
                margin: EdgeInsets.only(
                    left: ScreenAdapter.width(10),
                    right: ScreenAdapter.width(10)),
                width: ScreenAdapter.width(180),
                height: ScreenAdapter.height(65),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ColorsUtil.hexToColor("#A61C1C"),
                  //设置圆角
                  borderRadius: new BorderRadius.circular((16.0)),
                ),
                child: Text("返金",
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(24),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#FFFFFF"),
                    )),
              ),
            ),
        ],
      )

    );
  }

  getCashListShow() {
    return controller.cashList.value.length > 0
        ? Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("お釣り状態(NO.${controller.machineCode.value})",
              style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            //width: ScreenAdapter.width(520),
            margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
            padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
            decoration: BoxDecoration(
                color: Colors.white12,
                border: Border(
                  //bottom: BorderSide(color: Colors.grey, width: 1.0),
                  top: BorderSide(color: Colors.grey.shade400, width: 1.0),
                  left: BorderSide(color: Colors.grey.shade400, width: 1.0),
                  right: BorderSide(color: Colors.grey.shade400, width: 1.0),
                )),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(5)),
                  decoration: BoxDecoration(
                      color: Colors.white12,
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.0),
                        //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Container(
                        width: ScreenAdapter.width(110),
                        height: ScreenAdapter.height(45),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        child: Text("币种",
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize:
                              ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  "#000000"),
                            )),
                      )),
                      Expanded(child: Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(45),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        child: Text("初期枚数",
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize:
                              ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  "#000000"),
                            )),
                      )),
                      Expanded(child: Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(45),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        child: Text("最小枚数",
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize:
                              ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  "#000000"),
                            )),
                      )),

                      Expanded(child: Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(45),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        child: Text("使った枚数",
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize:
                              ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  "#000000"),
                            )),
                      )),
                      Expanded(child: Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(45),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        child: Text("残り枚数",
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize:
                              ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  "#000000"),
                            )),
                      )),
                      Expanded(child: Container(
                        width: ScreenAdapter.width(120),
                        height: ScreenAdapter.height(45),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        child: Text("補充/削减",
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize:
                              ScreenAdapter.fontSize(18),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  "#000000"),
                            )),
                      )),
                    ],
                  ),
                ),
                ListView.builder(
                    shrinkWrap: true, //为true可以解决子控件必须设置高度的问题
                    physics: NeverScrollableScrollPhysics(), //禁用滑动事件
                    itemCount: controller.cashList.value.length,
                    itemBuilder: (context, index) {
                      var _detail = controller.cashList.value[index];

                      var _surplusNum = _detail['standard']-int.parse(_detail['used']);
                      //var _backColor = (_detail['warm'] > _surplusNum)?"#A61C1C":"#F9F9F9";
                      var _textColor = (_detail['warm'] > _surplusNum)?"#A61C1C":"#000000";
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(5)),
                        decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#F9F9F9"),
                            border: Border(
                              bottom: BorderSide( color: Colors.grey.shade400, width: 1.0),
                              //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                            )),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: Container(
                              //width: ScreenAdapter.width(100),
                              height: ScreenAdapter.height(40),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(15),
                                  right: ScreenAdapter.width(5)),
                              child: Text(_detail['name'],
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(_textColor),
                                  )),
                            )),
                            Expanded(child: Container(
                              //width: ScreenAdapter.width(120),
                              height: ScreenAdapter.height(40),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5),
                                  right: ScreenAdapter.width(5)),
                              child: Text(_detail['standard'].toString(),
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(_textColor),
                                  )),
                            )),
                            Expanded(child: Container(
                              //width: ScreenAdapter.width(120),
                              height: ScreenAdapter.height(40),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5),
                                  right: ScreenAdapter.width(5)),
                              child: Text(_detail['warm'].toString(),
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(_textColor),
                                  )),
                            )),

                            Expanded(child: Container(
                              //width: ScreenAdapter.width(120),
                              height: ScreenAdapter.height(40),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5),
                                  right: ScreenAdapter.width(5)),
                              child: Text(_detail['used'].toString(),
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(_textColor),
                                  )),
                            )),
                            Expanded(child: Container(
                              //width: ScreenAdapter.width(120),
                              height: ScreenAdapter.height(40),
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5),
                                  right: ScreenAdapter.width(5)),
                              child: Text(_detail['remainder'].toString(),
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(_textColor),
                                  )),
                            )),
                            InkWell(
                              highlightColor: Colors.transparent, // 透明色
                              splashColor: Colors.transparent, // 透明色
                              onTap: (){
                               // controller.showCashDetail(_detail);

                                  },
                              child: Container(
                                margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                                //设置 child 居中
                                alignment: Alignment(0, 0),
                                height: ScreenAdapter.height(60),
                                width: ScreenAdapter.width(160),
                                //边框设置
                                decoration: new BoxDecoration(
                                  //背景
                                  color: ColorsUtil.hexToColor("#409eff"),
                                  //设置四周圆角 角度
                                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                  //设置四周边框
                                  //border: new Border.all(width: 1, color: Colors.red),
                                ),
                                child: Text(
                                    "補充/削减",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontSize: ScreenAdapter.fontSize(22),
                                      color: ColorsUtil.hexToColor("#FFFFFF"),
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              ],
            ),
          ),
        ],
      ),
    )
        : Text("");
  }

  getLastOrderTotalShow() {
    List<Widget> cashListRows = []; //先建一个数组用于存放循环生成的widget
    for (var _detail in controller.lastTotalList.value) {
      cashListRows.add(Expanded(child: Container(
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        decoration: BoxDecoration(
            color: Colors.white12,
            border: Border(
              right: BorderSide( color: Colors.grey.shade400, width: 1.0),

              //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
            )),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              //width: ScreenAdapter.width(140),
              height: ScreenAdapter.height(40),
              padding: EdgeInsets.only(
                  bottom: ScreenAdapter.height(15)),
              decoration: BoxDecoration(
                  color: Colors.white12,
                  border: Border(
                    bottom: BorderSide( color: Colors.grey.shade400, width: 1.0),

                    //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                  )),
              alignment: Alignment.center,
              child: Text(_detail['day'],
                  style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(20),
                    fontWeight: FontWeight.w500,
                    color: ColorsUtil.hexToColor("#000000"),
                  )),
            ),
            Container(
              //width: ScreenAdapter.width(140),
                height: ScreenAdapter.height(50),
                margin: EdgeInsets.only(
                    left: ScreenAdapter.width(5),
                    top: ScreenAdapter.height(16),
                    right: ScreenAdapter.width(5)),
                alignment: Alignment.center,
                child: Center(
                  //加上Center让文字居中
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: ScreenAdapter.width(20),
                      maxWidth: ScreenAdapter.width(165),
                      minHeight: ScreenAdapter.height(20),
                      maxHeight: ScreenAdapter.height(35),
                    ),
                    child: AutoSizeText(
                      "${_detail['total'].toString()}",
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: ScreenAdapter.fontSize(22),
                        fontWeight: FontWeight.w400,
                        color: ColorsUtil.hexToColor("#000000"),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ),
          ],
        ),
      )));
    }

    return controller.lastTotalList.value.length > 0
        ? Container(
      margin: EdgeInsets.only(
          top: ScreenAdapter.height(15),
          bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("一週間売上報告(円)",
              style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor("#000000"),
              )),
          Container(
            //width: ScreenAdapter.width(570),
            height: ScreenAdapter.height(130),
            margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
            //padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
            decoration: BoxDecoration(
                color: Colors.white12,
                border: Border(
                  bottom:BorderSide(color: Colors.grey.shade400, width: 1.0),
                  top:BorderSide(color: Colors.grey.shade400, width: 1.0),
                  left:BorderSide(color: Colors.grey.shade400, width: 1.0),
                  //right:BorderSide(color: Colors.grey.shade400, width: 1.0),
                )),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: cashListRows,
            ),
          ),
        ],
      ),
    )
        : Text("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SettingController>(builder: (controller){
        return controller.obx((state) => 
        
          Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: 
                  ListView(
                    children: <Widget>[
                      Container(
                        decoration: new BoxDecoration(color: Colors.white),
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
                          children: [
                            Container(
                              width: ScreenAdapter.width(820.0),
                              child: Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      //controller.menuPagecontroller.clearCartList();
                                      //sleep(Duration(milliseconds: 100));
                                      //Get.back();
                                      controller.goToBack();
                                      Future.delayed(Duration(milliseconds: 100), () {
                                        //Get.back();
                                        //Get.off(() => TransitPageView());
                                        //Get.toNamed('/transit-page');
                                        //Get.toNamed('/settingback-transit');
                                        //Get.to(() => TransitPageView());
                                        //Get.offAllNamed('/transit-page');
                                        //Get.offNamedUntil('/transit-page', (route) => route.settings.name == '/home');
                                        //Navigator.of(context, rootNavigator: true).pushReplacementNamed('/transit-page');
                                        //Get.until((route) => Get.currentRoute == '/transit-page');
                                        //Navigator.pushReplacementNamed(context, '/transit-page');
                                      });
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
                                            fontFamily: GFont.getFontFamily(),
                                            fontSize: ScreenAdapter.fontSize(24),
                                            fontWeight: FontWeight.w600,
                                            color: ColorsUtil.hexToColor("#FFFFFF"),
                                          )),
                                    ),
                                  ),

                                  InkWell(
                                    onTap: () {
                                      controller.ordersqlcontroller.removeAllFromCart();
                                      if (Platform.isAndroid) {
                                        controller.showBullyScreen();
                                      }
                                      sleep(Duration(milliseconds: 1500));
                                      Get.back();
                                      //退出关闭
                                      exit(0);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: ScreenAdapter.width(10),
                                          right: ScreenAdapter.width(10)),
                                      width: ScreenAdapter.width(180),
                                      height: ScreenAdapter.height(65),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: ColorsUtil.hexToColor("#e6a23c"),
                                        //设置圆角
                                        borderRadius: new BorderRadius.circular((16.0)),
                                      ),
                                      child: Text("ログアウト",
                                          style: TextStyle(
                                            fontFamily: GFont.getFontFamily(),
                                            fontSize: ScreenAdapter.fontSize(24),
                                            fontWeight: FontWeight.w600,
                                            color: ColorsUtil.hexToColor("#FFFFFF"),
                                          )),
                                    ),
                                  ),

                                  InkWell(
                                    onTap: () async {
                                    final result = await Get.toNamed('/system-setting-page',
                                          arguments: {"machineCode": controller.machineCode.value},
                                      );
                                    if (result != null) {
                                      controller.getSystemSettingInfo();
                                    }

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
                                      child: Text("システム設定",
                                          style: TextStyle(
                                            fontFamily: GFont.getFontFamily(),
                                            fontSize: ScreenAdapter.fontSize(24),
                                            fontWeight: FontWeight.w600,
                                            color: ColorsUtil.hexToColor("#FFFFFF"),
                                          )),
                                    ),
                                  ),


                                ],
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
                                  "Version：${controller.local_version.value}",
                                  style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      color: Colors.grey[500],
                                      fontSize: ScreenAdapter.fontSize(20.0)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: new BoxDecoration(color: Colors.white),
                        margin: EdgeInsets.only(
                          top: ScreenAdapter.height(15.0),
                        ),
                        padding: EdgeInsets.only(
                          top: ScreenAdapter.height(10.0),
                          left: ScreenAdapter.width(14.0),
                          right: ScreenAdapter.width(14.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getDepositListShow(),
                            SizedBox(
                              height: ScreenAdapter.height(20),
                            ),
                            getLastOrderTotalShow(),
                            SizedBox(
                              height: ScreenAdapter.height(20),
                            ),
                            
                            if (Platform.isAndroid)
                            CashSettingView(cashInfoList:
                            controller.cashInfoList.value,
                              isAllowRejishime: controller.isAllowRejishime.value,
                              machineCode: controller.machineCode.value,
                              recycleCash: () {
                                controller.recycleCash();
                              }, adjustCash: (type , number ) {
                                controller.adjustCash(type, number);
                              },
                              setOutset: (type, number) {
                                controller.setCashSenOutset(type, number);
                              },
                              adjustCashFromDeposit: (catVal , number , deposit , qty ) {
                                controller.adjustCashFromDeposit(catVal , number , deposit , qty);
                              },
                              resetCash: () {
                                controller.recycleCash();
                              },),

                            if(Platform.isWindows)
                            cycleCashSetting(),

                            SizedBox(
                              height: ScreenAdapter.height(20),
                            ),

                            rePrintArea(),
                            // SizedBox(
                            //   height: ScreenAdapter.height(20),
                            // ),
                            // CashSettingView(),


                          ],
                        ),
                      ),
                    ],
                  ),
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
