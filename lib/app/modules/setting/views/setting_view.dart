import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../../TransitPage/views/transit_page_view.dart';
import '../controllers/setting_controller.dart';

class SettingView extends GetView<SettingController> {
  final SettingController controller = Get.put(SettingController());
  SettingView({Key key}) : super(key: key);

  //支付金额展示
  getDepositListShow() {
    return Container(
      margin: EdgeInsets.only(
          top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("売上",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(22),
                fontWeight: FontWeight.w600,
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("預り金",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("現金",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("Alipay",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("PayPay",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: Text("WechatPay",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            )),
                      ),
                    ],
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                              text: controller.depositData.value['deposit_payment'].toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                              children: [
                                TextSpan(
                                  text: "円",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  ),
                                ),
                              ]),
                        ),
                      ),

                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                              text: controller.depositData.value['deposit_crash'].toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                              children: [
                                TextSpan(
                                  text: "円",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                              text: controller.depositData.value['deposit_alipay'].toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                              children: [
                                TextSpan(
                                  text: "円",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: RichText(
                          text: TextSpan(
                              text: controller.depositData.value['deposit_paypay'].toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                              children: [
                                TextSpan(
                                  text: "円",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      Container(
                        width: ScreenAdapter.width(200),
                        height: ScreenAdapter.height(45),
                        margin: EdgeInsets.only(
                            left: ScreenAdapter.width(5),
                            right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child:  RichText(
                          text: TextSpan(
                              text: controller.depositData.value['deposit_wechat'].toString(),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(22),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor("#000000"),
                              ),
                              children: [
                                TextSpan(
                                  text: "円",
                                  style: TextStyle(
                                    fontSize:
                                    ScreenAdapter.fontSize(18),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        "#000000"),
                                  ),
                                ),
                              ]),
                        ),
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

  getCashListShow() {
    return controller.cashList.value.length > 0
        ? Container(
      margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(15)),
      child: Column(
        children: [
          Text("お釣り状態(NO.${controller.machineCode.value})",
              style: TextStyle(
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
                                    fontSize: ScreenAdapter.fontSize(20),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(_textColor),
                                  )),
                            )),
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
        return controller.obx((state) => ListView(
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
                            controller.ordersqlcontroller.removeAllFromCart();
                            controller.menuPagecontroller.clearCartList();
                            //sleep(Duration(milliseconds: 100));
                            //Get.back();
                            //controller.goToBack();
                            Future.delayed(Duration(milliseconds: 100), () {
                              //Get.back();
                              Get.off(() => TransitPageView());
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
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            controller.ordersqlcontroller.removeAllFromCart();
                            controller.showBullyScreen();
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
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                        ),

                        InkWell(
                          onTap: () {
                            Get.toNamed('/system-setting-page', arguments: {"machineCode": controller.machineCode.value});

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
                  getCashListShow(),
                  SizedBox(
                    height: ScreenAdapter.height(20),
                  ),

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
