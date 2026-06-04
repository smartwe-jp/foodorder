import 'package:foodorder/app/widget/KioskTap.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/fontSize.dart';
import '../../../config/imageData.dart';
import '../../../controllers/machine_info.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';

class SelectPaymentPage extends StatelessWidget {
  MachineInfoController machineInfo = Get.find();

  SelectPaymentPage(
      {Key? key,
        required this.checkLanguage,
        required this.menuCount,
        required this.shopCartTotalPrice,
        required this.tableNum,
        this.tableName = "",
        this.tax10 = 0,
        this.tax8 = 0,
        required this.onConfrimClick,
        required this.onCancelClick})
      : super(key: key);
  final String checkLanguage;
  final int menuCount;
  final String shopCartTotalPrice;
  final String tableNum;
  final String tableName;
  final Function onConfrimClick;
  final int tax10; //税率
  final int tax8;
  final Function(String) onCancelClick;

  String get showPrice {
    return (int.parse(shopCartTotalPrice)).toString();
  }

  String get taxOutPrice {
    return (int.parse(shopCartTotalPrice) - tax8 - tax10).toString();
  }

  String get taxText {
    return machineInfo.taxSystem
        ? "tax".tr
        : "out_tax".tr;
  }

  Widget selectPrintType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: ScreenAdapter.height(30),
        ),
        Container(
          padding: EdgeInsets.only(
              left: ScreenAdapter.width(20),
              top: ScreenAdapter.height(25),
              right: ScreenAdapter.width(20),
              bottom: ScreenAdapter.height(80)),
          child: Text("settlement_receipt_title".tr,
            style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                fontWeight: FontWeight.w600,
                fontSize: ScreenAdapter.fontSize(50.0)),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            InkWell(
              onTap: () {
                // setState(() {
                //   _receiptPrintType = "1";
                //   _showReceiptPage = false;
                // });
                machineInfo.receiptPrintType = '1';
                machineInfo.showReceiptPage = false;
                machineInfo.update(['selectPayment']);
              },
              child: Container(
                width: ScreenAdapter.width(320),
                height: ScreenAdapter.height(185),
                padding: EdgeInsets.only(top: ScreenAdapter.height(2)),
                //margin: EdgeInsets.only(left: ScreenAdapter.width(30)),
                decoration: BoxDecoration(
                  //设置边框
                  border: new Border.all(
                      color: ColorsUtil.hexToColor("#9e9e9e"), width: 2.0),
                  //背景颜色
                  color: ColorsUtil.hexToColor("#F3F3F3"),
                  //设置圆角
                  //borderRadius: new BorderRadius.circular((5.0)),
                  borderRadius: new BorderRadius.circular((16.0)),
                  //设置阴影
                  //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("settlement_receipt_yes".tr,
                      style: TextStyle(
                          fontFamily: GFont.getFontFamily(),
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenAdapter.fontSize(45.0)),
                    )
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // setState(() {
                //   _receiptPrintType = "2";
                //   _showReceiptPage = false;
                // });
                machineInfo.receiptPrintType = '2';
                machineInfo.showReceiptPage = false;
                machineInfo.update(['selectPayment']);
              },
              child: Container(
                width: ScreenAdapter.width(320),
                height: ScreenAdapter.height(185),
                padding: EdgeInsets.only(top: ScreenAdapter.height(2)),
                //margin: EdgeInsets.only(left: ScreenAdapter.width(30)),
                decoration: BoxDecoration(
                  //设置边框
                  border: new Border.all(
                      color: ColorsUtil.hexToColor("#9e9e9e"), width: 2.0),
                  //背景颜色
                  color: ColorsUtil.hexToColor("#F3F3F3"),
                  //设置圆角
                  //borderRadius: new BorderRadius.circular((5.0)),
                  borderRadius: new BorderRadius.circular((16.0)),
                  //设置阴影
                  //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text(
                    //   GString.getToString(
                    //       checkLanguage, "settlement_receipt_title"),
                    //   style: TextStyle(
                    //       fontFamily: GFont.getFontFamily(),
                    //       color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    //       fontWeight: FontWeight.w600,
                    //       fontSize: ScreenAdapter.fontSize(34.0)),
                    // ),
                    Text("settlement_receipt_no".tr,
                      style: TextStyle(
                          fontFamily: GFont.getFontFamily(),
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenAdapter.fontSize(45.0)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: ScreenAdapter.height(60),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MachineInfoController>(
        id:'selectPayment',
        builder: (controller) {
          return Container(
              color: Colors.black.withOpacity(0.5),
              child: Column(children: <Widget>[
                Spacer(),
                Container(
                  color: ColorsUtil.hexToColor("#FFFFFF"),
                  width: ScreenAdapter.width(1000),
                  padding: EdgeInsets.only(
                      top: ScreenAdapter.height(20),
                      bottom: ScreenAdapter.height(0)),
                  child: machineInfo.showReceiptPage
                      ? selectPrintType()
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: ScreenAdapter.width(20),
                            top: ScreenAdapter.height(25),
                            right: ScreenAdapter.width(20),
                            bottom: ScreenAdapter.height(30)),
                        //width: ScreenAdapter.width(650),

                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("select_payment_type_title".tr,
                              style: TextStyle(
                                  fontFamily: GFont.getFontFamily(),
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.mainTitleColor),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(34.0)),
                            ),
                            SizedBox(
                              height: ScreenAdapter.height(30),
                            ),
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                if (machineInfo.showCash == true)
                                  InkWell(
                                    onTap: () {
                                      //payment_method_num = "1";
                                      machineInfo.paymentMethod = '1';
                                      //Navigator.pop(pcontext);
                                      onConfrimClick();
                                    },
                                    child: Container(
                                      width: ScreenAdapter.width(320),
                                      height: ScreenAdapter.height(225),
                                      padding: EdgeInsets.only(
                                          top: ScreenAdapter.height(2)),
                                      //margin: EdgeInsets.only(left: ScreenAdapter.width(30)),
                                      decoration: BoxDecoration(
                                        //设置边框
                                        border: new Border.all(
                                            color: ColorsUtil.hexToColor(
                                                "#9e9e9e"),
                                            width: 2.0),
                                        //背景颜色
                                        color:
                                        ColorsUtil.hexToColor("#F3F3F3"),
                                        //设置圆角
                                        //borderRadius: new BorderRadius.circular((5.0)),
                                        borderRadius:
                                        new BorderRadius.circular((16.0)),
                                        //设置阴影
                                        //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                      ),
                                      alignment: Alignment.center,
                                      child: Stack(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height:
                                                ScreenAdapter.height(65),
                                              ),
                                              Container(
                                                height:
                                                ScreenAdapter.height(150),
                                                padding: EdgeInsets.only(
                                                    left: ScreenAdapter.width(
                                                        10),
                                                    top: ScreenAdapter.height(
                                                        10),
                                                    right:
                                                    ScreenAdapter.width(
                                                        10),
                                                    bottom:
                                                    ScreenAdapter.height(
                                                        10)),
                                                child: Image.asset(
                                                  GImage.getImageString(
                                                      "imgpublic",
                                                      "payment_cash"),
                                                  //width: ScreenAdapter.width(150),
                                                  height:
                                                  ScreenAdapter.height(
                                                      120),
                                                  //color:  ColorsUtil.hexToColor(Gcolor.mainBackground),
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                              //SizedBox(height: ScreenAdapter.height(20),),
                                            ],
                                          ),
                                          Positioned(
                                            //right: ScreenAdapter.width(120),
                                            top: ScreenAdapter.height(2),
                                            child: Container(
                                              width: ScreenAdapter.width(160),
                                              alignment: Alignment.center,
                                              child: Text("settlement_top_title_cash".tr,
                                                style: TextStyle(
                                                    fontFamily:
                                                    GFont.getFontFamily(),
                                                    color: ColorsUtil
                                                        .hexToColor(Gcolor
                                                        .mainTitleColor),
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    fontSize: ScreenAdapter
                                                        .fontSize(34.0)),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                if(machineInfo.showAlipay || machineInfo.showWechat || machineInfo.showPayPay||
                                    machineInfo.showAuPay || machineInfo.showDPay || machineInfo.showRPay || machineInfo.showMPay)

                                  InkWell(
                                    onTap: () {
                                      machineInfo.paymentMethod = '2';
                                      //Navigator.pop(pcontext);
                                      onConfrimClick();
                                    },
                                    child: Container(
                                      width: ScreenAdapter.width(460),
                                      height: ScreenAdapter.height(225),
                                      padding: EdgeInsets.only(
                                          top: ScreenAdapter.height(2)),
                                      //margin: EdgeInsets.only(right: ScreenAdapter.width(30)),
                                      decoration: BoxDecoration(
                                        //设置边框
                                        border: new Border.all(
                                            color: ColorsUtil.hexToColor(
                                                "#9e9e9e"),
                                            width: 2.0),
                                        //背景颜色
                                        color:
                                        ColorsUtil.hexToColor("#F3F3F3"),
                                        //设置圆角
                                        //borderRadius: new BorderRadius.circular((5.0)),
                                        borderRadius:
                                        new BorderRadius.circular((16.0)),
                                        //设置阴影
                                        //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height:
                                                ScreenAdapter.height(38),
                                              ),
                                              Container(
                                                width:
                                                ScreenAdapter.width(450),
                                                child: Wrap(
                                                    spacing: ScreenAdapter.width(
                                                        22), // set spacing here
                                                    runSpacing:
                                                    ScreenAdapter.height(
                                                        2),
                                                    alignment:
                                                    WrapAlignment.center,
                                                    children: [
                                                      if (machineInfo
                                                          .showPayPay ==
                                                          true)
                                                        Container(
                                                          height:
                                                          ScreenAdapter
                                                              .height(80),
                                                          padding: EdgeInsets.only(
                                                              left:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              top:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5),
                                                              right:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              bottom:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5)),
                                                          child: Image.asset(
                                                            GImage.getImageString(
                                                                "imgpublic",
                                                                "settlement_paypay"),
                                                            width:
                                                            ScreenAdapter
                                                                .width(
                                                                65),
                                                            //height: ScreenAdapter.height(100),
                                                            //color: Colors.lightGreen,
                                                            fit: BoxFit
                                                                .fitWidth,
                                                          ),
                                                        ),
                                                      if (machineInfo
                                                          .showAlipay ==
                                                          true)
                                                        Container(
                                                          height:
                                                          ScreenAdapter
                                                              .height(80),
                                                          padding: EdgeInsets.only(
                                                              left:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              top:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5),
                                                              right:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              bottom:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5)),
                                                          child: Image.asset(
                                                            GImage.getImageString(
                                                                "imgpublic",
                                                                "settlement_alipay"),
                                                            width:
                                                            ScreenAdapter
                                                                .width(
                                                                65),
                                                            //height: ScreenAdapter.height(100),
                                                            //color: Colors.lightGreen,
                                                            fit: BoxFit
                                                                .fitWidth,
                                                          ),
                                                        ),
                                                      if (machineInfo
                                                          .showWechat ==
                                                          true)
                                                        Container(
                                                          height:
                                                          ScreenAdapter
                                                              .height(80),
                                                          padding: EdgeInsets.only(
                                                              left:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              top:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5),
                                                              right:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              bottom:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5)),
                                                          child: Image.asset(
                                                            GImage.getImageString(
                                                                "imgpublic",
                                                                "settlement_wechat"),
                                                            width:
                                                            ScreenAdapter
                                                                .width(
                                                                65),
                                                            //height: ScreenAdapter.height(100),
                                                            //color: Colors.lightGreen,
                                                            fit: BoxFit
                                                                .fitWidth,
                                                          ),
                                                        ),
                                                      if (machineInfo
                                                          .showCreditCard ==
                                                          true &&
                                                          machineInfo
                                                              .isAllowPos ==
                                                              "1" &&
                                                          machineInfo
                                                              .showAuPay ==
                                                              true)
                                                        Container(
                                                          height:
                                                          ScreenAdapter
                                                              .height(80),
                                                          padding: EdgeInsets.only(
                                                              left:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              top:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5),
                                                              right:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              bottom:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5)),
                                                          child: Image.asset(
                                                            GImage.getImageString(
                                                                "imgpublic",
                                                                "settlement_aupay"),
                                                            width:
                                                            ScreenAdapter
                                                                .width(
                                                                65),
                                                            //height: ScreenAdapter.height(100),
                                                            //color: Colors.lightGreen,
                                                            fit: BoxFit
                                                                .fitWidth,
                                                          ),
                                                        ),
                                                      if (machineInfo
                                                          .showCreditCard ==
                                                          true &&
                                                          machineInfo
                                                              .isAllowPos ==
                                                              "1" &&
                                                          machineInfo
                                                              .showDPay ==
                                                              true)
                                                        Container(
                                                          height:
                                                          ScreenAdapter
                                                              .height(80),
                                                          padding: EdgeInsets.only(
                                                              left:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              top:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5),
                                                              right:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              bottom:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5)),
                                                          child: Image.asset(
                                                            GImage.getImageString(
                                                                "imgpublic",
                                                                "settlement_dpay"),
                                                            width:
                                                            ScreenAdapter
                                                                .width(
                                                                65),
                                                            //height: ScreenAdapter.height(100),
                                                            //color: Colors.lightGreen,
                                                            fit: BoxFit
                                                                .fitWidth,
                                                          ),
                                                        ),
                                                      if (machineInfo
                                                          .showCreditCard ==
                                                          true &&
                                                          machineInfo
                                                              .isAllowPos ==
                                                              "1" &&
                                                          machineInfo
                                                              .showRPay ==
                                                              true)
                                                        Container(
                                                          height:
                                                          ScreenAdapter
                                                              .height(80),
                                                          padding: EdgeInsets.only(
                                                              left:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              top:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5),
                                                              right:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              bottom:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5)),
                                                          child: Image.asset(
                                                            GImage.getImageString(
                                                                "imgpublic",
                                                                "settlement_rpay"),
                                                            width:
                                                            ScreenAdapter
                                                                .width(
                                                                65),
                                                            //height: ScreenAdapter.height(100),
                                                            //color: Colors.lightGreen,
                                                            fit: BoxFit
                                                                .fitWidth,
                                                          ),
                                                        ),
                                                      if (machineInfo
                                                          .showCreditCard ==
                                                          true &&
                                                          machineInfo
                                                              .isAllowPos ==
                                                              "1" &&
                                                          machineInfo
                                                              .showMPay ==
                                                              true)
                                                        Container(
                                                          height:
                                                          ScreenAdapter
                                                              .height(80),
                                                          padding: EdgeInsets.only(
                                                              left:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              top:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5),
                                                              right:
                                                              ScreenAdapter
                                                                  .width(
                                                                  5),
                                                              bottom:
                                                              ScreenAdapter
                                                                  .height(
                                                                  5)),
                                                          child: Image.asset(
                                                            GImage.getImageString(
                                                                "imgpublic",
                                                                "settlement_mpay"),
                                                            width:
                                                            ScreenAdapter
                                                                .width(
                                                                65),
                                                            //height: ScreenAdapter.height(100),
                                                            //color: Colors.lightGreen,
                                                            fit: BoxFit
                                                                .fitWidth,
                                                          ),
                                                        ),
                                                    ]),
                                              ),

                                              //SizedBox(height: ScreenAdapter.height(30),),
                                            ],
                                          ),
                                          Positioned(
                                            //right: ScreenAdapter.width(120),
                                            top: ScreenAdapter.height(2),
                                            child: Container(
                                              width: ScreenAdapter.width(420),
                                              alignment: Alignment.center,
                                              child: Text("settlement_top_title_qr".tr,
                                                style: TextStyle(
                                                    fontFamily:
                                                    GFont.getFontFamily(),
                                                    color: ColorsUtil
                                                        .hexToColor(Gcolor
                                                        .mainTitleColor),
                                                    fontWeight:
                                                    FontWeight.w600,
                                                    fontSize: ScreenAdapter
                                                        .fontSize(34.0)),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(
                              height: ScreenAdapter.height(60),
                            ),
                            if (machineInfo.isAllowPos == "1" &&
                                machineInfo.showCreditCard == true &&
                                (machineInfo.showVisa == true ||
                                    machineInfo.showMaster == true ||
                                    machineInfo.showJcb == true ||
                                    machineInfo.showUnionPay == true ||
                                    machineInfo.showAmericanExpress == true ||
                                    machineInfo.showDinersClub == true))
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      machineInfo.isAllowPos = "1";
                                      machineInfo.paymentMethod = "3";

                                      //Navigator.pop(pcontext);
                                      onConfrimClick();
                                    },
                                    child: Container(
                                      width: ScreenAdapter.width(870),
                                      //height: ScreenAdapter.height(335),
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(5),
                                          top: ScreenAdapter.height(20),
                                          right: ScreenAdapter.width(5),
                                          bottom: ScreenAdapter.height(20)),
                                      decoration: BoxDecoration(
                                        //设置边框
                                        border: new Border.all(
                                            color: ColorsUtil.hexToColor(
                                                "#9e9e9e"),
                                            width: 2.0),
                                        //背景颜色
                                        color:
                                        ColorsUtil.hexToColor("#F3F3F3"),
                                        //设置圆角
                                        //borderRadius: new BorderRadius.circular((5.0)),
                                        borderRadius:
                                        new BorderRadius.circular((16.0)),
                                        //设置阴影
                                        //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Text("settlement_top_title_card".tr,
                                            style: TextStyle(
                                                color: ColorsUtil.hexToColor(
                                                    Gcolor.mainTitleColor),
                                                fontFamily:
                                                GFont.getFontFamily(),
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                ScreenAdapter.fontSize(
                                                    34.0)),
                                          ),
                                          /*Container(
                                          height: ScreenAdapter.height(210),
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                          child: Image.asset(GImage.getImageString("imgpublic", "payment_card"),
                                            width: ScreenAdapter.width(220),
                                            //height: ScreenAdapter.height(100),
                                            //color: Colors.lightGreen,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),*/
                                          Wrap(
                                            spacing: ScreenAdapter.width(
                                                10), // set spacing here
                                            runSpacing:
                                            ScreenAdapter.height(20),
                                            alignment: WrapAlignment.center,
                                            //mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              //Touch pay 通用卡图标
                                              Container(
                                                margin: EdgeInsets.only(top: ScreenAdapter.height(4), right: ScreenAdapter.width(10)),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                ),
                                                width: ScreenAdapter.width(110),
                                                height: ScreenAdapter.height(80),
                                                alignment: Alignment.center,
                                                child: Image.asset(
                                                  GImage.getImageString(
                                                      "imgpublic",
                                                      "card_touchpay"),
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),


                                              if (machineInfo.showVisa == true)
                                                Container(
                                                  width: ScreenAdapter.width(
                                                      110),
                                                  height:
                                                  ScreenAdapter.height(
                                                      90),
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.only(
                                                      left:
                                                      ScreenAdapter.width(
                                                          5),
                                                      top: ScreenAdapter
                                                          .height(5),
                                                      right:
                                                      ScreenAdapter.width(
                                                          5),
                                                      bottom: ScreenAdapter
                                                          .height(5)),
                                                  child: Image.asset(
                                                    GImage.getImageString(
                                                        "imgpublic",
                                                        "card_visa"),
                                                    width:
                                                    ScreenAdapter.width(
                                                        90),
                                                    //height: ScreenAdapter.height(100),
                                                    //color: Colors.lightGreen,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              if (machineInfo.showJcb == true)
                                                Container(
                                                  width: ScreenAdapter.width(
                                                      110),
                                                  height:
                                                  ScreenAdapter.height(
                                                      90),
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.only(
                                                      left:
                                                      ScreenAdapter.width(
                                                          5),
                                                      top: ScreenAdapter
                                                          .height(5),
                                                      right:
                                                      ScreenAdapter.width(
                                                          5),
                                                      bottom: ScreenAdapter
                                                          .height(5)),
                                                  child: Image.asset(
                                                    GImage.getImageString(
                                                        "imgpublic",
                                                        "card_jcb"),
                                                    width:
                                                    ScreenAdapter.width(
                                                        90),
                                                    //height: ScreenAdapter.height(100),
                                                    //color: Colors.lightGreen,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              if (machineInfo.showMaster ==
                                                  true)
                                                Container(
                                                  width: ScreenAdapter.width(
                                                      110),
                                                  height:
                                                  ScreenAdapter.height(
                                                      90),
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.only(
                                                      left:
                                                      ScreenAdapter.width(
                                                          5),
                                                      top: ScreenAdapter
                                                          .height(5),
                                                      right:
                                                      ScreenAdapter.width(
                                                          5),
                                                      bottom: ScreenAdapter
                                                          .height(5)),
                                                  child: Image.asset(
                                                    GImage.getImageString(
                                                        "imgpublic",
                                                        "card_master"),
                                                    width:
                                                    ScreenAdapter.width(
                                                        90),
                                                    //height: ScreenAdapter.height(100),
                                                    //color: Colors.lightGreen,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              if (machineInfo.showUnionPay ==
                                                  true)
                                                Container(
                                                  width: ScreenAdapter.width(
                                                      110),
                                                  height:
                                                  ScreenAdapter.height(
                                                      90),
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.only(
                                                      left:
                                                      ScreenAdapter.width(
                                                          5),
                                                      top: ScreenAdapter
                                                          .height(5),
                                                      right:
                                                      ScreenAdapter.width(
                                                          5),
                                                      bottom: ScreenAdapter
                                                          .height(5)),
                                                  child: Image.asset(
                                                    GImage.getImageString(
                                                        "imgpublic",
                                                        "card_unionp"),
                                                    width:
                                                    ScreenAdapter.width(
                                                        90),
                                                    //height: ScreenAdapter.height(100),
                                                    //color: Colors.lightGreen,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              if (machineInfo
                                                  .showAmericanExpress ==
                                                  true)
                                                Container(
                                                  width: ScreenAdapter.width(
                                                      110),
                                                  height:
                                                  ScreenAdapter.height(
                                                      90),
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.only(
                                                      left:
                                                      ScreenAdapter.width(
                                                          5),
                                                      top: ScreenAdapter
                                                          .height(5),
                                                      right:
                                                      ScreenAdapter.width(
                                                          5),
                                                      bottom: ScreenAdapter
                                                          .height(5)),
                                                  child: Image.asset(
                                                    GImage.getImageString(
                                                        "imgpublic",
                                                        "card_american"),
                                                    width:
                                                    ScreenAdapter.width(
                                                        100),
                                                    //height: ScreenAdapter.height(100),
                                                    //color: Colors.lightGreen,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              if (machineInfo.showDinersClub ==
                                                  true)
                                                Container(
                                                  width: ScreenAdapter.width(
                                                      110),
                                                  height:
                                                  ScreenAdapter.height(
                                                      90),
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.only(
                                                      left:
                                                      ScreenAdapter.width(
                                                          5),
                                                      top: ScreenAdapter
                                                          .height(5),
                                                      right:
                                                      ScreenAdapter.width(
                                                          5),
                                                      bottom: ScreenAdapter
                                                          .height(5)),
                                                  child: Image.asset(
                                                    GImage.getImageString(
                                                        "imgpublic",
                                                        "card_diners"),
                                                    width:
                                                    ScreenAdapter.width(
                                                        100),
                                                    //height: ScreenAdapter.height(100),
                                                    //color: Colors.lightGreen,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                              if (machineInfo.showDiscover ==
                                                  true)
                                                Container(
                                                  width: ScreenAdapter.width(
                                                      110),
                                                  height:
                                                  ScreenAdapter.height(
                                                      90),
                                                  alignment: Alignment.center,
                                                  padding: EdgeInsets.only(
                                                      left:
                                                      ScreenAdapter.width(
                                                          5),
                                                      top: ScreenAdapter
                                                          .height(5),
                                                      right:
                                                      ScreenAdapter.width(
                                                          5),
                                                      bottom: ScreenAdapter
                                                          .height(5)),
                                                  child: Image.asset(
                                                    GImage.getImageString(
                                                        "imgpublic",
                                                        "card_discover"),
                                                    width:
                                                    ScreenAdapter.width(
                                                        100),
                                                    //height: ScreenAdapter.height(100),
                                                    //color: Colors.lightGreen,
                                                    fit: BoxFit.fitWidth,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          //SizedBox(height: ScreenAdapter.height(20),),
                                        ],
                                      ),
                                    ),
                                  ),

                                  /*InkWell(
                                  onTap: (){
                                    setState(() {
                                      _isAllowPos = "1";
                                      _payment_method_num = "4";
                                    });
                                    //Navigator.pop(pcontext);
                                    widget.onConfrimClick(_isAllowPos,_payment_method_num);

                                  },
                                  child: Container(
                                    width: ScreenAdapter.width(350),
                                    height: ScreenAdapter.height(335),
                                    padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                    decoration: BoxDecoration(
                                      //设置边框
                                      //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                      //背景颜色
                                      color: Colors.white,
                                      //设置圆角
                                      borderRadius: new BorderRadius.circular((5.0)),
                                      //设置阴影
                                      boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: ScreenAdapter.height(210),
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                          child: Image.asset(GImage.getImageString("imgpublic", "payment_nfc"),
                                            width: ScreenAdapter.width(200),
                                            //height: ScreenAdapter.height(200),
                                            //color: Colors.lightGreen,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        //SizedBox(height: ScreenAdapter.height(20),),
                                        Text(
                                          //"信用卡",
                                          GString.getToString(this._checkLanguage, "settlement_top_title_nfc"),
                                          style: TextStyle(
                                              color:ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                              fontWeight: FontWeight.w600,
                                              fontSize: ScreenAdapter.fontSize(34.0)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),*/
                                ],
                              ),
                            if (machineInfo.isAllowPos == "1" &&
                                (machineInfo.showPosEdy == true ||
                                    machineInfo.showPosiD == true ||
                                    machineInfo.showPosIC == true ||
                                    machineInfo.showPosQUICPay == true ||
                                    machineInfo.showPosWAON == true ||
                                    machineInfo.showPosnanaco == true))
                              Container(
                                margin: EdgeInsets.only(
                                    top: ScreenAdapter.height(50)),
                                child: Column(
                                  //mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Text("settlement_top_title_wallet".tr,
                                      style: TextStyle(
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor),
                                          fontFamily: GFont.getFontFamily(),
                                          fontWeight: FontWeight.w600,
                                          fontSize:
                                          ScreenAdapter.fontSize(34.0)),
                                    ),
                                    SizedBox(
                                      height: ScreenAdapter.height(40),
                                    ),
                                    Wrap(
                                      spacing: ScreenAdapter.width(
                                          90), // set spacing here
                                      runSpacing: ScreenAdapter.height(40),
                                      alignment: WrapAlignment.center,
                                      children: <Widget>[
                                        if (machineInfo.showPosEdy == true)
                                          InkWell(
                                            onTap: () {
                                              machineInfo.isAllowPos = "1";
                                              machineInfo.paymentMethod = "5";

                                              //Navigator.pop(pcontext);
                                              onConfrimClick();
                                            },
                                            child: Container(
                                              width: ScreenAdapter.width(225),
                                              height:
                                              ScreenAdapter.height(140),
                                              padding: EdgeInsets.only(
                                                  top: ScreenAdapter.height(
                                                      5)),
                                              decoration: BoxDecoration(
                                                //设置边框
                                                //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                                //背景颜色
                                                color: Colors.white,
                                                //设置圆角
                                                //borderRadius: new BorderRadius.circular((5.0)),
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    (16.0)),
                                                //设置阴影
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: ColorsUtil
                                                          .hexToColor(
                                                          "#9e9e9e"),
                                                      offset:
                                                      Offset(1.0, 1.0),
                                                      blurRadius: 2.0,
                                                      spreadRadius: 2.0),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceAround,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                    ScreenAdapter.height(
                                                        135),
                                                    padding: EdgeInsets.only(
                                                        left: ScreenAdapter
                                                            .width(10),
                                                        top: ScreenAdapter
                                                            .height(10),
                                                        right: ScreenAdapter
                                                            .width(10),
                                                        bottom: ScreenAdapter
                                                            .height(10)),
                                                    child: Image.asset(
                                                      GImage.getImageString(
                                                          "imgpublic",
                                                          "settlement_edy"),
                                                      height:
                                                      ScreenAdapter.width(
                                                          120),
                                                      //height: ScreenAdapter.height(100),
                                                      //color: Colors.lightGreen,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (machineInfo.showPosiD == true)
                                          InkWell(
                                            onTap: () {
                                              machineInfo.isAllowPos = "1";
                                              machineInfo.paymentMethod = "6";

                                              //Navigator.pop(pcontext);
                                              onConfrimClick();
                                            },
                                            child: Container(
                                              width: ScreenAdapter.width(225),
                                              height:
                                              ScreenAdapter.height(140),
                                              padding: EdgeInsets.only(
                                                  top: ScreenAdapter.height(
                                                      5)),
                                              decoration: BoxDecoration(
                                                //设置边框
                                                //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                                //背景颜色
                                                color: Colors.white,
                                                //设置圆角
                                                //borderRadius: new BorderRadius.circular((5.0)),
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    (16.0)),
                                                //设置阴影
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: ColorsUtil
                                                          .hexToColor(
                                                          "#9e9e9e"),
                                                      offset:
                                                      Offset(1.0, 1.0),
                                                      blurRadius: 2.0,
                                                      spreadRadius: 2.0),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceAround,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                    ScreenAdapter.height(
                                                        135),
                                                    padding: EdgeInsets.only(
                                                        left: ScreenAdapter
                                                            .width(10),
                                                        top: ScreenAdapter
                                                            .height(10),
                                                        right: ScreenAdapter
                                                            .width(10),
                                                        bottom: ScreenAdapter
                                                            .height(10)),
                                                    child: Image.asset(
                                                      GImage.getImageString(
                                                          "imgpublic",
                                                          "settlement_id"),
                                                      height:
                                                      ScreenAdapter.width(
                                                          120),
                                                      //height: ScreenAdapter.height(100),
                                                      //color: Colors.lightGreen,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (machineInfo.showPosnanaco == true)
                                          InkWell(
                                            onTap: () {
                                              machineInfo.isAllowPos = "1";
                                              machineInfo.paymentMethod = "7";

                                              //Navigator.pop(pcontext);
                                              onConfrimClick();
                                            },
                                            child: Container(
                                              width: ScreenAdapter.width(225),
                                              height:
                                              ScreenAdapter.height(140),
                                              padding: EdgeInsets.only(
                                                  top: ScreenAdapter.height(
                                                      5)),
                                              decoration: BoxDecoration(
                                                //设置边框
                                                //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                                //背景颜色
                                                color: Colors.white,
                                                //设置圆角
                                                //borderRadius: new BorderRadius.circular((5.0)),
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    (16.0)),
                                                //设置阴影
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: ColorsUtil
                                                          .hexToColor(
                                                          "#9e9e9e"),
                                                      offset:
                                                      Offset(1.0, 1.0),
                                                      blurRadius: 2.0,
                                                      spreadRadius: 2.0),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceAround,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                    ScreenAdapter.height(
                                                        135),
                                                    padding: EdgeInsets.only(
                                                        left: ScreenAdapter
                                                            .width(10),
                                                        top: ScreenAdapter
                                                            .height(10),
                                                        right: ScreenAdapter
                                                            .width(10),
                                                        bottom: ScreenAdapter
                                                            .height(10)),
                                                    child: Image.asset(
                                                      GImage.getImageString(
                                                          "imgpublic",
                                                          "settlement_nanaco"),
                                                      height:
                                                      ScreenAdapter.width(
                                                          120),
                                                      //height: ScreenAdapter.height(100),
                                                      //color: Colors.lightGreen,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (machineInfo.showPosWAON == true)
                                          InkWell(
                                            onTap: () {
                                              machineInfo.isAllowPos = "1";
                                              machineInfo.paymentMethod = "8";

                                              //Navigator.pop(pcontext);
                                              onConfrimClick();
                                            },
                                            child: Container(
                                              width: ScreenAdapter.width(225),
                                              height:
                                              ScreenAdapter.height(140),
                                              padding: EdgeInsets.only(
                                                  top: ScreenAdapter.height(
                                                      5)),
                                              decoration: BoxDecoration(
                                                //设置边框
                                                //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                                //背景颜色
                                                color: Colors.white,
                                                //设置圆角
                                                //borderRadius: new BorderRadius.circular((5.0)),
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    (16.0)),
                                                //设置阴影
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: ColorsUtil
                                                          .hexToColor(
                                                          "#9e9e9e"),
                                                      offset:
                                                      Offset(1.0, 1.0),
                                                      blurRadius: 2.0,
                                                      spreadRadius: 2.0),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceAround,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                    ScreenAdapter.height(
                                                        135),
                                                    padding: EdgeInsets.only(
                                                        left: ScreenAdapter
                                                            .width(10),
                                                        top: ScreenAdapter
                                                            .height(10),
                                                        right: ScreenAdapter
                                                            .width(10),
                                                        bottom: ScreenAdapter
                                                            .height(10)),
                                                    child: Image.asset(
                                                      GImage.getImageString(
                                                          "imgpublic",
                                                          "settlement_waon"),
                                                      height:
                                                      ScreenAdapter.width(
                                                          120),
                                                      //height: ScreenAdapter.height(100),
                                                      //color: Colors.lightGreen,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (machineInfo.showPosQUICPay == true)
                                          InkWell(
                                            onTap: () {
                                              machineInfo.isAllowPos = "1";
                                              machineInfo.paymentMethod = "9";

                                              //Navigator.pop(pcontext);
                                              onConfrimClick();
                                            },
                                            child: Container(
                                              width: ScreenAdapter.width(225),
                                              height:
                                              ScreenAdapter.height(140),
                                              padding: EdgeInsets.only(
                                                  top: ScreenAdapter.height(
                                                      5)),
                                              decoration: BoxDecoration(
                                                //设置边框
                                                //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                                //背景颜色
                                                color: Colors.white,
                                                //设置圆角
                                                //borderRadius: new BorderRadius.circular((5.0)),
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    (16.0)),
                                                //设置阴影
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: ColorsUtil
                                                          .hexToColor(
                                                          "#9e9e9e"),
                                                      offset:
                                                      Offset(1.0, 1.0),
                                                      blurRadius: 2.0,
                                                      spreadRadius: 2.0),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceAround,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                    ScreenAdapter.height(
                                                        135),
                                                    padding: EdgeInsets.only(
                                                        left: ScreenAdapter
                                                            .width(10),
                                                        top: ScreenAdapter
                                                            .height(10),
                                                        right: ScreenAdapter
                                                            .width(10),
                                                        bottom: ScreenAdapter
                                                            .height(10)),
                                                    child: Image.asset(
                                                      GImage.getImageString(
                                                          "imgpublic",
                                                          "settlement_quicpay"),
                                                      height:
                                                      ScreenAdapter.width(
                                                          120),
                                                      //height: ScreenAdapter.height(100),
                                                      //color: Colors.lightGreen,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        if (machineInfo.showPosIC == true)
                                          InkWell(
                                            onTap: () {
                                              machineInfo.isAllowPos = "1";
                                              machineInfo.paymentMethod = "10";

                                              //Navigator.pop(pcontext);
                                              onConfrimClick();
                                            },
                                            child: Container(
                                              width: ScreenAdapter.width(225),
                                              height:
                                              ScreenAdapter.height(140),
                                              padding: EdgeInsets.only(
                                                  top: ScreenAdapter.height(
                                                      5)),
                                              decoration: BoxDecoration(
                                                //设置边框
                                                //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                                //背景颜色
                                                color: Colors.white,
                                                //设置圆角
                                                //borderRadius: new BorderRadius.circular((5.0)),
                                                borderRadius:
                                                new BorderRadius.circular(
                                                    (16.0)),
                                                //设置阴影
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: ColorsUtil
                                                          .hexToColor(
                                                          "#9e9e9e"),
                                                      offset:
                                                      Offset(1.0, 1.0),
                                                      blurRadius: 2.0,
                                                      spreadRadius: 2.0),
                                                ],
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceAround,
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    height:
                                                    ScreenAdapter.height(
                                                        135),
                                                    padding: EdgeInsets.only(
                                                        left: ScreenAdapter
                                                            .width(10),
                                                        top: ScreenAdapter
                                                            .height(10),
                                                        right: ScreenAdapter
                                                            .width(10),
                                                        bottom: ScreenAdapter
                                                            .height(10)),
                                                    child: Image.asset(
                                                      GImage.getImageString(
                                                          "imgpublic",
                                                          "settlement_jiaotongxi"),
                                                      height:
                                                      ScreenAdapter.width(
                                                          120),
                                                      //height: ScreenAdapter.height(100),
                                                      //color: Colors.lightGreen,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: ScreenAdapter.height(20),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                            left: ScreenAdapter.width(80),
                            right: ScreenAdapter.width(80)),
                        //height: ScreenAdapter.height(100),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (tableNum != "")
                                    Text(
                                      tableNum,
                                      style: TextStyle(
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor),
                                          fontFamily: GFont.getFontFamily(),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(40.0)),
                                    ),
                                  Row(
                                    children: [
                                      Text("settlement_total_price".tr,
                                        style: TextStyle(
                                            color: ColorsUtil.hexToColor(
                                                Gcolor.mainTitleColor),
                                            fontFamily: GFont.getFontFamily(),
                                            fontWeight: FontWeight.w600,
                                            fontSize: ScreenAdapter.fontSize(40.0)),
                                      ),
                                      if (menuCount > 0)
                                        Text(
                                          "  ${menuCount.toString()}  ${"show_selectPay_point".tr}",
                                          style: TextStyle(
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.mainTitleColor),
                                              fontFamily: GFont.getFontFamily(),
                                              fontWeight: FontWeight.w600,
                                              fontSize: ScreenAdapter.fontSize(40.0)),
                                        ),
                                    ],
                                  )

                                ],
                              ),
                            ),
                            //Spacer(),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [


                                  if(!machineInfo.taxSystem)
                                    Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        //taxout
                                        Text(
                                          "taxout_price".tr,
                                          style: TextStyle(
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.mainTitleColor),
                                              fontFamily: GFont.getFontFamily(),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 32),
                                        ),
                                        Spacer(),
                                        //shopCartTotalPrice
                                        Text(
                                          "¥ ",
                                          //GString.getToString(this._checkLanguage, "show_price_front"),
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontFamily: GFont.getFontFamily(),
                                            fontWeight: FontWeight.w500,
                                            color: ColorsUtil.hexToColor(
                                                Gcolor.mainTitleColor),
                                          ),
                                        ),
                                        Text(
                                          formatMoney(taxOutPrice),
                                          style: TextStyle(
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.mainTitleColor),
                                              fontFamily: GFont.getFontFamily(),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 32),
                                        ),
                                      ],
                                    ),

                                  if(!machineInfo.taxSystem)
                                    Divider(
                                      height: 1.5,
                                      color: ColorsUtil.hexToColor("#000000"),
                                    ),

                                  //if(!controller.taxSystem)
                                    Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        //taxin
                                        Text(
                                          taxText + " 10%",
                                          style: TextStyle(
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.mainTitleColor),
                                              fontFamily: GFont.getFontFamily(),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 30),
                                        ),
                                        //showPrice
                                        Spacer(),
                                        //shopCartTotalPrice
                                        Text(
                                          "¥ ",
                                          //GString.getToString(this._checkLanguage, "show_price_front"),
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontFamily: GFont.getFontFamily(),
                                            fontWeight: FontWeight.w500,
                                            color: ColorsUtil.hexToColor(
                                                Gcolor.mainTitleColor),
                                          ),
                                        ),
                                        Text(
                                          formatMoney(tax10.toString()),
                                          style: TextStyle(
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.mainTitleColor),
                                              fontFamily: GFont.getFontFamily(),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 30),
                                        ),
                                      ],
                                    ),

                                  //if(!controller.taxSystem)
                                    Row(
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        //taxin
                                        Text(
                                          taxText + " 8%",
                                          style: TextStyle(
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.mainTitleColor),
                                              fontFamily: GFont.getFontFamily(),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 30),
                                        ),
                                        //showPrice
                                        Spacer(),
                                        //shopCartTotalPrice
                                        Text(
                                          "¥ ",
                                          //GString.getToString(this._checkLanguage, "show_price_front"),
                                          style: TextStyle(
                                            fontSize: 28,
                                            fontFamily: GFont.getFontFamily(),
                                            fontWeight: FontWeight.w500,
                                            color: ColorsUtil.hexToColor(
                                                Gcolor.mainTitleColor),
                                          ),
                                        ),
                                        Text(
                                          formatMoney(tax8.toString()),
                                          style: TextStyle(
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.mainTitleColor),
                                              fontFamily: GFont.getFontFamily(),
                                              fontWeight: FontWeight.w500,
                                              fontSize: 30),
                                        ),
                                      ],
                                    ),




                                  //if(!controller.taxSystem)
                                    Divider(
                                      height: 1.5,
                                      color: ColorsUtil.hexToColor("#000000"),
                                    ),

                                  //if (!controller.taxSystem)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        //taxin
                                        Text(
                                          "tag_amount".tr,
                                          style: TextStyle(
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.mainTitleColor),
                                              fontFamily: GFont.getFontFamily(),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 34),
                                        ),
                                        //showPrice
                                        Container(

                                          child: RichText(
                                            text: TextSpan(
                                                text: "¥ ",
                                                //GString.getToString(this._checkLanguage, "show_price_front"),
                                                style: TextStyle(
                                                  fontSize: ScreenAdapter.fontSize(
                                                      GFontSize.menusettlementBottomPriceLeft),
                                                  fontFamily: GFont.getFontFamily(),
                                                  fontWeight: FontWeight.w600,
                                                  color: ColorsUtil.hexToColor(
                                                      Gcolor.mainTitleColor),
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: formatMoney(showPrice),
                                                    style: TextStyle(
                                                      fontSize: ScreenAdapter.fontSize(
                                                          GFontSize.menusettlementBottomPrice),
                                                      fontFamily: GFont.getFontFamily(),
                                                      fontWeight: FontWeight.w600,
                                                      color: ColorsUtil.hexToColor(
                                                          Gcolor.priceColor),
                                                    ),
                                                  ),
                                                  if (controller.taxSystem)
                                                    TextSpan(
                                                      text: "（${ "show_price_front".tr}）",
                                                      style: TextStyle(
                                                        fontSize: 24,
                                                        fontFamily: GFont.getFontFamily(),
                                                        fontWeight: FontWeight.w600,
                                                        color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                                        textBaseline: TextBaseline.alphabetic,
                                                      ),
                                                    ),

                                                ]),
                                          ),
                                        ),
                                      ],
                                    ),

                                  //if(!controller.taxSystem)
                                    Divider(
                                      height: 1.5,
                                      color: ColorsUtil.hexToColor("#000000"),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),




                      SizedBox(
                        height: ScreenAdapter.height(20),
                      ),
                      Container(
                        //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                        height: ScreenAdapter.height(200),
                        color: ColorsUtil.hexToColor("#DCDCDC"),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            KioskTap(
                              onTap: () {
                                try {
                                  Navigator.pop(context);
                                  onCancelClick("back");
                                } catch (_) {}
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: ScreenAdapter.width(270),
                                height: ScreenAdapter.height(140),
                                //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                                decoration: BoxDecoration(
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                ),
                                child: Text("settlement_back".tr,
                                  style: TextStyle(
                                      color: ColorsUtil.hexToColor("#000000"),
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w500,
                                      fontSize: ScreenAdapter.fontSize(34.0)),
                                ),
                              ),
                            ),
                            /*SizedBox(width: ScreenAdapter.width(180)),
                          InkWell(
                            onTap: (){
                              try {
                                if(_isAllowPos == "1" &&_payment_method_num == "0"){
                                  showToast(GString.getToString(this._checkLanguage, "select_payment_type_title"));
                                  return;
                                }
                                if(_isAllowPos == "1" &&_payment_method_num != "0"){
                                  widget.onConfrimClick(_isAllowPos,_payment_method_num);
                                  Navigator.pop(context);
                                }
                              } catch (_) {}

                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: ScreenAdapter.width(270),
                              height: ScreenAdapter.height(140),
                              margin: EdgeInsets.only(right: ScreenAdapter.width(20)),
                              decoration: BoxDecoration(

                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    ColorsUtil.hexToColor("#C47829"),
                                    ColorsUtil.hexToColor("#854610"),
                                  ],
                                ),
                                //设置圆角
                                borderRadius: new BorderRadius.circular((5.0)),
                              ),
                              child: Text(
                                GString.getToString(this._checkLanguage, "tag_button_yes"),
                                style: TextStyle(
                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                    fontWeight: FontWeight.w500,
                                    fontSize: ScreenAdapter.fontSize(34.0)),
                              ),
                            ),
                          ),*/
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Spacer(),
              ]));
        });
  }
}
