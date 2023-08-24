import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../widget/DialogUtils.dart';
import '../controllers/settlement_controller.dart';

class SettlementView extends GetView {
  final SettlementController controller = Get.find<SettlementController>();
  SettlementView({Key key}) : super(key: key);

  showCashAlert(){
    /*Get.dialog(
        Container(
          width: ScreenAdapter.width(950),
          child: SimpleDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              title: Align(
                  alignment: Alignment.center,
                  child: Text(
                      GString.getToString(controller.checkLanguage.value, "tag_title"),
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(28),
                          fontWeight: FontWeight.w600))),
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                      child: Icon(
                        Icons.notifications_outlined,
                        //color: ColorsUtil.hexToColor("#2aa515"),
                        size: 80,
                      ),
                    ),
                    Expanded(
                        child: Container(
                          width: ScreenAdapter.width(700),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(20)),
                          padding: EdgeInsets.only(left: ScreenAdapter.width(20),right: ScreenAdapter.width(20)),
                          child: Align(
                            child: Text(GString.getToString(controller.checkLanguage.value, "settlement_back_alertcontent"),
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(28))),
                            alignment: Alignment(0, 0),
                          ),
                        )
                    ),
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                Divider(
                  thickness: 3.0,
                  color: Colors.black12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.only(left: 70.0),
                        width: ScreenAdapter.width(400),
                        height: ScreenAdapter.height(75),
                        alignment: Alignment.center,
                        child: Text(
                          GString.getToString(controller.checkLanguage.value,
                              "tag_button_no"),
                          style: TextStyle(
                            //color: Colors.lightBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(34.0)
                          ),
                        ),
                      ),
                      onTap: () {
                        //sleep(Duration(milliseconds: 3000));
                        Get.back();

                      },
                    ),
                    //垂直分割线
                    SizedBox(
                      width: 3,
                      height: ScreenAdapter.height(95),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black12),
                      ),
                    ),
                    InkWell(
                      child: Container(
                        padding: EdgeInsets.only(right: 70.0),
                        width: ScreenAdapter.width(400),
                        height: ScreenAdapter.height(75),
                        alignment: Alignment.center,
                        child: Text(
                          GString.getToString(controller.checkLanguage.value,
                              "tag_button_yes"),
                          style: TextStyle(
                            //color: Colors.lightBlue,
                              fontSize: ScreenAdapter.fontSize(34.0),
                              fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                      onTap: () {
                        Get.back();
                        controller.showBackEasyLoading();
                        controller.CancelOrder();

                      },
                    )
                  ],
                ),
              ]),
        ),
      barrierDismissible: false
    );*/
    Get.dialog(
        DialogUtils.alert(GString.getToString(controller.checkLanguage.value, "settlement_back_alertcontent"),
        title: GString.getToString(controller.checkLanguage.value, "tag_title"),
        canceltitle: GString.getToString(controller.checkLanguage.value,"tag_button_no"),
        confirmtitle: GString.getToString(controller.checkLanguage.value,"tag_button_yes"),
        confirm: () {
          Get.back();
          controller.showBackEasyLoading();
          controller.CancelOrder();
        },
        cancle: () {
              Get.back();
        })
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SettlementController>(builder: (controller){
        return controller.obx((state) => AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 0,
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          showCursor: false,
                          // 显示光标
                          //readOnly: true,
                          controller: controller.scanQrCodeController,
                          focusNode: controller.scanQrCodeFocusNode,
                          decoration: InputDecoration(
                            hintText: "请扫码",
                            border: InputBorder.none,
                            isDense: true,
                          ),
                          style: TextStyle(fontSize: ScreenAdapter.fontSize(30.0)),
                          obscureText: false,
                          onChanged: (value) {
                            //print(value);
                          },
                          onSubmitted: (value) {
                            controller.doToPay();
                          },

                          /// 扫码密码
                        )),
                  ],
                ),
              ),
              Container(
                width: ScreenAdapter.getScreenWidth(),
                height: ScreenAdapter.height(115),
                decoration: BoxDecoration(
                  color: ColorsUtil.hexToColor("#ffffff"),
                  border: Border(
                      bottom: BorderSide(color: ColorsUtil.hexToColor("#e5e5e5"), width: 5.0),
                      //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                  )
                  /*gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ColorsUtil.hexToColor("#C47829"),
                      ColorsUtil.hexToColor("#854610"),
                    ],
                  ),*/
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (controller.payment_method_num.value == "1")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /*Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_top_cash"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),*/
                          Icon(
                            Icons.currency_yen_outlined,
                            //color: ColorsUtil.hexToColor("#FFFFFF"),
                            size: 40,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(5),
                          ),
                          Text(
                            GString.getToString(
                                controller.checkLanguage.value, "settlement_top_title_cash"),
                            style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(36.0)),
                          ),
                        ],
                      ),
                    if (controller.payment_method_num.value == "2")
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_top_qr"),
                            width: ScreenAdapter.width(35),
                            fit: BoxFit.fitWidth,
                            color: Colors.black87,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(15),
                          ),
                          Text(
                            GString.getToString(
                                controller.checkLanguage.value, "settlement_top_title_qr"),
                            style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(36.0)),
                          ),
                        ],
                      ),
                    if (controller.payment_method_num.value == "3")
                      InkWell(
                        enableFeedback: false,
                        onLongPress: () {
                          try {
                            //Navigator.pop(context);
                            controller.CancelOrder();;
                            //showCancelConfirm();
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_top_card"),
                              width: ScreenAdapter.width(50),
                              fit: BoxFit.fitWidth,
                              color: Colors.black87,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            Text(
                              GString.getToString(controller.checkLanguage.value,
                                  "settlement_top_title_card"),
                              style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(36.0)),
                            ),
                          ],
                        ),
                      ),
                    if (controller.payment_method_num.value == "4")
                      InkWell(
                        enableFeedback: false,
                        onLongPress: () {
                          try {
                            //Navigator.pop(context);
                            controller.CancelOrder();;
                            //showCancelConfirm();
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_top_nfc"),
                              width: ScreenAdapter.width(40),
                              fit: BoxFit.fitWidth,
                              color: Colors.black87,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(5),
                            ),
                            Text(
                              GString.getToString(controller.checkLanguage.value,
                                  "settlement_top_title_nfc"),
                              style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(36.0)),
                            ),
                          ],
                        ),
                      ),
                    if (controller.payment_method_num.value == "5")
                      InkWell(
                        enableFeedback: false,
                        onLongPress: () {
                          try {
                            //Navigator.pop(context);
                            controller.CancelOrder();;
                            //showCancelConfirm();
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_edy"),
                              width: ScreenAdapter.width(50),
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            Text(
                              GString.getToString(controller.checkLanguage.value,
                                  "settlement_top_title_edy"),
                              style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(36.0)),
                            ),
                          ],
                        ),
                      ),
                    if (controller.payment_method_num.value == "6")
                      InkWell(
                        enableFeedback: false,
                        onLongPress: () {
                          try {
                            //Navigator.pop(context);
                            controller.CancelOrder();;
                            //showCancelConfirm();
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_id"),
                              width: ScreenAdapter.width(50),
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            Text(
                              GString.getToString(controller.checkLanguage.value,
                                  "settlement_top_title_iD"),
                              style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(36.0)),
                            ),
                          ],
                        ),
                      ),
                    if (controller.payment_method_num.value == "7")
                      InkWell(
                        enableFeedback: false,
                        onLongPress: () {
                          try {
                            //Navigator.pop(context);
                            controller.CancelOrder();;
                            //showCancelConfirm();
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_nanaco"),
                              width: ScreenAdapter.width(50),
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            Text(
                              GString.getToString(controller.checkLanguage.value,
                                  "settlement_top_title_nanaco"),
                              style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(36.0)),
                            ),
                          ],
                        ),
                      ),
                    if (controller.payment_method_num.value == "8")
                      InkWell(
                        enableFeedback: false,
                        onLongPress: () {
                          try {
                            //Navigator.pop(context);
                            controller.CancelOrder();;
                            //showCancelConfirm();
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_waon"),
                              width: ScreenAdapter.width(50),
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            Text(
                              GString.getToString(controller.checkLanguage.value,
                                  "settlement_top_title_WAON"),
                              style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(36.0)),
                            ),
                          ],
                        ),
                      ),
                    if (controller.payment_method_num.value == "9")
                      InkWell(
                        enableFeedback: false,
                        onLongPress: () {
                          try {
                            //Navigator.pop(context);
                            controller.CancelOrder();;
                            //showCancelConfirm();
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_quicpay"),
                              width: ScreenAdapter.width(50),
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            Text(
                              GString.getToString(controller.checkLanguage.value,
                                  "settlement_top_title_QUICPay"),
                              style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(36.0)),
                            ),
                          ],
                        ),
                      ),
                    if (controller.payment_method_num.value == "10")
                      InkWell(
                        enableFeedback: false,
                        onLongPress: () {
                          try {
                            //_getPaymentCancelPosData();
                            //Navigator.pop(context);
                            controller.CancelOrder();;
                            //showCancelConfirm();
                          } catch (_) {}
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              GImage.getImageString(
                                  "imgpublic", "settlement_jiaotongxi"),
                              width: ScreenAdapter.width(50),
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            Text(
                              GString.getToString(controller.checkLanguage.value,
                                  "settlement_top_title_IC"),
                              style: TextStyle(
                                //color: ColorsUtil.hexToColor("#FFFFFF"),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(36.0)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (controller.payment_method_num.value == "1")
                Container(
                  width: ScreenAdapter.width(1080),
                  alignment: Alignment.center,
                  //height: ScreenAdapter.height(940),
                  child: Image.asset(
                    GImage.getImageString("imgpublic",
                        "settlement_top_lead_cash_${controller.checkLanguage.value}"),
                    width: ScreenAdapter.width(780),
                    height: ScreenAdapter.width(870),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              if (controller.payment_method_num.value == "2")
                Container(
                  //height: ScreenAdapter.height(940),
                  child: Stack(
                    children: [
                      Image.asset(
                        GImage.getImageString(
                            "imgpublic", "settlement_top_lead_qr"),
                        width: ScreenAdapter.width(1080),
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned(
                          right: ScreenAdapter.width(120),
                          top: ScreenAdapter.height(250),
                          child: Container(
                            width: ScreenAdapter.width(250),
                            child: Wrap(
                                spacing: ScreenAdapter.width(5), // set spacing here
                                runSpacing: ScreenAdapter.height(5),
                                alignment: WrapAlignment.center,
                                children: [
                                  if (controller.showPayPay.value == true)
                                    Container(
                                      height: ScreenAdapter.height(130),
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(10),
                                          top: ScreenAdapter.height(10),
                                          right: ScreenAdapter.width(10),
                                          bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(
                                        GImage.getImageString(
                                            "imgpublic", "settlement_paypay"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if (controller.showAlipay.value == true)
                                    Container(
                                      height: ScreenAdapter.height(130),
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(10),
                                          top: ScreenAdapter.height(10),
                                          right: ScreenAdapter.width(10),
                                          bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(
                                        GImage.getImageString(
                                            "imgpublic", "settlement_alipay"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if (controller.showWechat.value == true)
                                    Container(
                                      height: ScreenAdapter.height(130),
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(10),
                                          top: ScreenAdapter.height(10),
                                          right: ScreenAdapter.width(10),
                                          bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(
                                        GImage.getImageString(
                                            "imgpublic", "settlement_wechat"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if (controller.showCreditCard.value == true && controller.isAllowPos.value =="1" && controller.showauPay.value == true)
                                    Container(
                                      height: ScreenAdapter.height(130),
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(10),
                                          top: ScreenAdapter.height(10),
                                          right: ScreenAdapter.width(10),
                                          bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(
                                        GImage.getImageString(
                                            "imgpublic", "settlement_aupay"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if (controller.showCreditCard.value == true && controller.isAllowPos.value =="1" && controller.showdPay.value == true)
                                    Container(
                                      height: ScreenAdapter.height(130),
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(10),
                                          top: ScreenAdapter.height(10),
                                          right: ScreenAdapter.width(10),
                                          bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(
                                        GImage.getImageString(
                                            "imgpublic", "settlement_dpay"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if (controller.showCreditCard.value == true && controller.isAllowPos.value =="1" && controller.showrPay.value == true)
                                    Container(
                                      height: ScreenAdapter.height(130),
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(10),
                                          top: ScreenAdapter.height(10),
                                          right: ScreenAdapter.width(10),
                                          bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(
                                        GImage.getImageString(
                                            "imgpublic", "settlement_rpay"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if (controller.showCreditCard.value == true && controller.isAllowPos.value =="1" && controller.showmPay.value == true)
                                    Container(
                                      height: ScreenAdapter.height(130),
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(10),
                                          top: ScreenAdapter.height(10),
                                          right: ScreenAdapter.width(10),
                                          bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(
                                        GImage.getImageString(
                                            "imgpublic", "settlement_mpay"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),

                                ]),
                          ))
                    ],
                  ),
                ),
              if (controller.payment_method_num.value == "3")
                Container(
                  alignment: Alignment.center,
                  //height: ScreenAdapter.height(940),
                  child: Stack(
                    children: [
                      Image.asset(
                        GImage.getImageString("imgpublic",
                            "settlement_top_lead_card_${controller.checkLanguage.value}"),
                        width: ScreenAdapter.height(820),
                        fit: BoxFit.fitHeight,
                      ),
                      Positioned(
                        //right: ScreenAdapter.width(120),
                        bottom: ScreenAdapter.height(65),
                        child: Container(
                          width: ScreenAdapter.width(1080),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Wrap(
                                spacing: ScreenAdapter.width(30), // set spacing here
                                runSpacing: ScreenAdapter.height(40),
                                alignment: WrapAlignment.center,
                                //mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(controller.showVisa.value == true)
                                    Container(
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_visa"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if(controller.showJcb.value == true)
                                    Container(
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_jcb"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if(controller.showMaster.value == true)
                                    Container(
                                      // width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_master"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if(controller.showUnionPay.value == true)
                                    Container(
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_unionp"),
                                        width: ScreenAdapter.width(100),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if(controller.showAmericanExpress.value == true)
                                    Container(
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.bottomCenter,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_american"),
                                        width: ScreenAdapter.width(80),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),

                                  if(controller.showDinersClub.value == true)
                                    Container(
                                      //color: Colors.red,
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.topCenter,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_diners"),
                                        width: ScreenAdapter.width(110),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if (controller.payment_method_num.value == "4")
                Container(
                  //height: ScreenAdapter.height(940),
                  child: Stack(
                    children: [
                      Image.asset(
                        GImage.getImageString(
                            "imgpublic", "settlement_top_lead_nfc_${controller.checkLanguage.value}"),
                        width: ScreenAdapter.height(820),
                        fit: BoxFit.fitHeight,
                      ),
                      Positioned(
                        //right: ScreenAdapter.width(120),
                        bottom: ScreenAdapter.height(25),
                        child: Container(
                          width: ScreenAdapter.width(1080),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Wrap(
                                spacing: ScreenAdapter.width(50), // set spacing here
                                runSpacing: ScreenAdapter.height(40),
                                alignment: WrapAlignment.center,
                                //mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if(controller.showVisa.value == true)
                                    Container(
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_visa"),
                                        width: ScreenAdapter.width(105),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if(controller.showJcb.value == true)
                                    Container(
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_jcb"),
                                        width: ScreenAdapter.width(105),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if(controller.showMaster.value == true)
                                    Container(
                                      // width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_master"),
                                        width: ScreenAdapter.width(105),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if(controller.showUnionPay.value == true)
                                    Container(
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_unionp"),
                                        width: ScreenAdapter.width(105),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                  if(controller.showAmericanExpress.value == true)
                                    Container(
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_american"),
                                        width: ScreenAdapter.width(105),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),

                                  if(controller.showDinersClub.value == true)
                                    Container(
                                      //width: ScreenAdapter.width(120),
                                      //height: ScreenAdapter.height(90),
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "card_diners"),
                                        width: ScreenAdapter.width(105),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),

                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              if (controller.payment_method_num.value == "5")
                Container(
                  alignment: Alignment.center,
                  //height: ScreenAdapter.height(940),
                  child: Image.asset(
                    GImage.getImageString(
                        "imgpublic", "settlement_top_lead_posEdy_${controller.checkLanguage.value}"),
                    width: ScreenAdapter.height(820),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              if (controller.payment_method_num.value == "6")
                Container(
                  alignment: Alignment.center,
                  //height: ScreenAdapter.height(940),
                  child: Image.asset(
                    GImage.getImageString(
                        "imgpublic", "settlement_top_lead_posID_${controller.checkLanguage.value}"),
                    width: ScreenAdapter.height(820),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              if (controller.payment_method_num.value == "7")
                Container(
                  alignment: Alignment.center,
                  //height: ScreenAdapter.height(940),
                  child: Image.asset(
                    GImage.getImageString(
                        "imgpublic", "settlement_top_lead_posNanaco_${controller.checkLanguage.value}"),
                    width: ScreenAdapter.height(820),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              if (controller.payment_method_num.value == "8")
                Container(
                  alignment: Alignment.center,
                  //height: ScreenAdapter.height(940),
                  child: Image.asset(
                    GImage.getImageString(
                        "imgpublic", "settlement_top_lead_posWAON_${controller.checkLanguage.value}"),
                    width: ScreenAdapter.height(820),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              if (controller.payment_method_num.value == "9")
                Container(
                  alignment: Alignment.center,
                  //height: ScreenAdapter.height(940),
                  child: Image.asset(
                    GImage.getImageString(
                        "imgpublic", "settlement_top_lead_posQUICPay_${controller.checkLanguage.value}"),
                    width: ScreenAdapter.height(820),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              if (controller.payment_method_num.value == "10")
                Container(
                  alignment: Alignment.center,
                  //height: ScreenAdapter.height(940),
                  child: Image.asset(
                    GImage.getImageString(
                        "imgpublic", "settlement_top_lead_posIC_${controller.checkLanguage.value}"),
                    width: ScreenAdapter.height(820),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              /*if (controller.payment_method_num.value == "5" || controller.payment_method_num.value == "6"|| controller.payment_method_num.value == "7"|| controller.payment_method_num.value == "8"|| controller.payment_method_num.value == "9"|| controller.payment_method_num.value == "10")
              Container(
                //height: ScreenAdapter.height(940),
                child: Image.asset(
                  GImage.getImageString(
                      "imgpublic", "settlement_top_lead_nfc_${_checkLanguage}"),
                  width: ScreenAdapter.width(1080),
                  fit: BoxFit.fitWidth,
                ),
              ),*/
              Container(
                height: ScreenAdapter.height(5),
                color: ColorsUtil.hexToColor("#D8D8D8"),
              ),
              Expanded(
                child: Container(
                  //width: ScreenAdapter.width(240),
                  //height: ScreenAdapter.height(220),
                  // margin: EdgeInsets.only(left: ScreenAdapter.width(60),top: ScreenAdapter.width(50)),
                  padding: EdgeInsets.only(
                      left: ScreenAdapter.width(200),
                      top: ScreenAdapter.height(35),
                      right: ScreenAdapter.width(200),
                      bottom: ScreenAdapter.height(10)),
                  color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
                  alignment: Alignment.center,

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          top: ScreenAdapter.height(15),
                          bottom: ScreenAdapter.height(15),
                        ),
                        padding:
                        EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                        decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: ColorsUtil.hexToColor("#D8D8D8"),
                                  width: 2.5),
                              //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                            )),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                GString.getToString(
                                    controller.checkLanguage.value, "settlement_orderPrice"),
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(32),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.mainTitleColor),
                                )),
                            SizedBox(height: ScreenAdapter.height(10)),
                            Container(
                              alignment: Alignment.center,
                              child: RichText(
                                text: TextSpan(
                                    text: formatMoney(controller.totalPrice.value),
                                    //GString.getToString(controller.checkLanguage.value, "show_price_front"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(52),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor("#9A5718"),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: " 円", //" 円",
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(28),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor("#000000"),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (controller.payment_method_num.value == "1")
                        Container(
                          margin: EdgeInsets.only(
                            top: ScreenAdapter.height(15),
                            bottom: ScreenAdapter.height(15),
                          ),
                          padding:
                          EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                          decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: ColorsUtil.hexToColor("#D8D8D8"),
                                    width: 2.5),
                                //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                              )),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  GString.getToString(
                                      controller.checkLanguage.value, "settlement_putMoney"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(32),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(
                                        Gcolor.mainTitleColor),
                                  )),
                              SizedBox(height: ScreenAdapter.height(10)),
                              Container(
                                alignment: Alignment.center,
                                child: RichText(
                                  text: TextSpan(
                                      text: formatMoney(controller.getPutMoney.value),
                                      //" 円",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(52),
                                        fontWeight: FontWeight.w600,
                                        color: (int.parse(controller.getPutMoney.value) > 0)
                                            ? ColorsUtil.hexToColor("#FF0000")
                                            : ColorsUtil.hexToColor("#808080"),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: " 円", //" 円",
                                          style: TextStyle(
                                            fontSize: ScreenAdapter.fontSize(28),
                                            fontWeight: FontWeight.w600,
                                            color:
                                            (int.parse(controller.getPutMoney.value) > 0)
                                                ? ColorsUtil.hexToColor(
                                                Gcolor.mainTitleColor)
                                                : ColorsUtil.hexToColor(
                                                "#808080"),
                                          ),
                                        ),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (controller.payment_method_num.value == "1")
                        Container(
                          margin: EdgeInsets.only(
                            top: ScreenAdapter.height(15),
                            bottom: ScreenAdapter.height(15),
                          ),
                          padding:
                          EdgeInsets.only(bottom: ScreenAdapter.height(20)),
                          decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: ColorsUtil.hexToColor("#D8D8D8"),
                                    width: 2.5),
                                //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                              )),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                  GString.getToString(
                                      controller.checkLanguage.value, "settlement_outMoney"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(32),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(
                                        Gcolor.mainTitleColor),
                                  )),
                              SizedBox(height: ScreenAdapter.height(10)),
                              Container(
                                alignment: Alignment.center,
                                child: RichText(
                                  text: TextSpan(
                                      text: formatMoney(controller.showOutMoney.value),
                                      //" 円",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(52),
                                        fontWeight: FontWeight.w600,
                                        color: (int.parse(controller.showOutMoney.value) > 0)
                                            ? ColorsUtil.hexToColor("#008000")
                                            : ColorsUtil.hexToColor("#808080"),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: " 円", //" 円",
                                          style: TextStyle(
                                            fontSize: ScreenAdapter.fontSize(28),
                                            fontWeight: FontWeight.w600,
                                            color:
                                            (int.parse(controller.showOutMoney.value) >
                                                0)
                                                ? ColorsUtil.hexToColor(
                                                Gcolor.mainTitleColor)
                                                : ColorsUtil.hexToColor(
                                                "#808080"),
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
              ),
              if (controller.payment_method_num.value == "1")
                Container(
                  width: ScreenAdapter.width(1080),
                  alignment: Alignment.center,
                  //height: ScreenAdapter.height(940),
                  child: Image.asset(
                    GImage.getImageString("imgpublic",
                        "settlement_bottom_lead_cash_${controller.checkLanguage.value}"),
                    height: ScreenAdapter.height(280),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              if (controller.payment_method_num.value == "0" || controller.payment_method_num.value == "1")
                Container(
                  //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                  height: ScreenAdapter.height(200),
                  color: ColorsUtil.hexToColor("#DCDCDC"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: ScreenAdapter.width(440),
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.only(left: ScreenAdapter.width(40),bottom: ScreenAdapter.height(30)),
                        child: InkWell(
                          onTap: () {
                            try {
                              showCashAlert();
                            } catch (_) {}
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenAdapter.width(180),
                            height: ScreenAdapter.height(80),
                            //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((5.0)),
                            ),
                            child: Text(
                              GString.getToString(controller.checkLanguage.value, "settlement_back"),
                              style: TextStyle(
                                  color: ColorsUtil.hexToColor("#2D2D2D"),
                                  fontWeight: FontWeight.w500,
                                  fontSize: ScreenAdapter.fontSize(34.0)),
                            ),
                          ),
                        ),
                      ),
                      //SizedBox(width: ScreenAdapter.width(80)),
                      controller.showPrintButton.value == true
                          ? (
                          controller.is_allow_receipt.value == "1"
                              ? Container(
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(20),right: ScreenAdapter.width(20)),
                            //width: ScreenAdapter.width(540),
                            alignment: Alignment.centerRight,
                            child: InkWell(
                              onTap: () {
                                if (controller.allowClick.value == true) {
                                    controller.allowClick.value = false;

                                  controller.showEasyLoading();

                                  controller.doPrintOrderMenu("1");
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: ScreenAdapter.width(20)),
                                width: ScreenAdapter.width(270),
                                height: ScreenAdapter.height(140),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color:ColorsUtil.hexToColor("#148DE8"),
                                  //设置圆角
                                  borderRadius:
                                  new BorderRadius.circular((5.0)),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        GString.getToString(
                                            controller.checkLanguage.value,
                                            "settlement_confirmButton"),
                                        style: TextStyle(
                                          fontSize:
                                          ScreenAdapter.fontSize(32),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.settlementBtnColor),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          )
                              : Container(
                            //width: ScreenAdapter.width(540),
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(20),right: ScreenAdapter.width(30)),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (controller.allowClick.value == true) {
                                      controller.allowClick.value = false;

                                      controller.showEasyLoading();

                                      controller.doPrintOrderMenu("1");
                                    }
                                  },
                                  child: Container(
                                    //margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                                    width: ScreenAdapter.width(270),
                                    height: ScreenAdapter.height(140),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:ColorsUtil.hexToColor("#148DE8"),
                                      //设置圆角
                                      borderRadius:
                                      new BorderRadius.circular((5.0)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        /*Text(
                                      GString.getToString(
                                          controller.checkLanguage.value,
                                          "settlement_confirmButton"),
                                      style: TextStyle(
                                        fontSize:
                                        ScreenAdapter.fontSize(
                                            32),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor
                                                .settlementBtnColor),
                                      )),*/
                                        Text(
                                            GString.getToString(
                                                controller.checkLanguage.value,
                                                "settlement_confirmButton_yes"),
                                            style: TextStyle(
                                              fontSize:
                                              ScreenAdapter.fontSize(
                                                  32),
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                            )),
                                        /*Text(
                                      GString.getToString(
                                          controller.checkLanguage.value,
                                          "settlement_confirmButton_yes"),
                                      style: TextStyle(
                                        fontSize:
                                        ScreenAdapter.fontSize(
                                            20),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor
                                                .settlementBtnColor),
                                      )),*/
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: ScreenAdapter.width(30)),
                                InkWell(
                                  onTap: () {
                                    if (controller.allowClick.value == true) {

                                        controller.allowClick.value = false;
                                        controller.is_query_receipt.value = "2";


                                      if (controller.machineMode.value == "1") {
                                        controller.showEasyLoading();
                                      } else {
                                        controller.showSuccessEasyLoading();
                                      }

                                      controller.doPrintOrderMenu("2");
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: ScreenAdapter.width(10)),
                                    width: ScreenAdapter.width(270),
                                    height: ScreenAdapter.height(140),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color:
                                      ColorsUtil.hexToColor("#67c23a"),
                                      //设置圆角
                                      borderRadius:
                                      new BorderRadius.circular((5.0)),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        /*Text(
                                      GString.getToString(
                                          controller.checkLanguage.value,
                                          "settlement_confirmButton"),
                                      style: TextStyle(
                                        fontSize:
                                        ScreenAdapter.fontSize(
                                            32),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor
                                                .settlementBtnColor),
                                      )),*/
                                        Text(
                                            GString.getToString(
                                                controller.checkLanguage.value,
                                                "settlement_confirmButton_no2"),
                                            style: TextStyle(
                                              fontSize:
                                              ScreenAdapter.fontSize(
                                                  32),
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor
                                                      .settlementBtnColor),
                                            )),
                                        /* Text(
                                      GString.getToString(
                                          controller.checkLanguage.value,
                                          "settlement_confirmButton_no"),
                                      style: TextStyle(
                                        fontSize:
                                        ScreenAdapter.fontSize(
                                            20),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor
                                                .settlementBtnColor),
                                      )),*/
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                      )
                          : Container(
                        margin:
                        EdgeInsets.only(left: ScreenAdapter.width(20)),
                        width: ScreenAdapter.width(540),
                        height: ScreenAdapter.height(100),
                      ),
                    ],
                  ),
                ),
              if (controller.payment_method_num.value == "2" ||
                  controller.payment_method_num.value == "3" ||
                  controller.payment_method_num.value == "4" ||
                  controller.payment_method_num.value == "5" ||
                  controller.payment_method_num.value == "6" ||
                  controller.payment_method_num.value == "7" ||
                  controller.payment_method_num.value == "8" ||
                  controller.payment_method_num.value == "9" ||
                  controller.payment_method_num.value == "10")
                Container(
                  //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                  height: ScreenAdapter.height(200),
                  color: ColorsUtil.hexToColor("#DCDCDC"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          try {
                            //showCancelConfirm();
                            EasyLoading.dismiss();
                            var paymentMethod = ["3","4","5","6","7","8","9","10"];
                            if (paymentMethod.contains(controller.payment_method_num.value) == true) {
                              controller.getPaymentCancelPosData();
                            }else{
                              Get.back();
                            }
                            /*if (controller.payment_method_num.value == "3" ||
                              controller.payment_method_num.value == "4") {
                            _getPaymentCancelPosData();
                          } else {
                            Navigator.pop(context);
                          }*/


                          } catch (_) {}
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: ScreenAdapter.width(180),
                          height: ScreenAdapter.height(80),
                          //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((5.0)),
                          ),
                          child: Text(
                            GString.getToString(controller.checkLanguage.value, "settlement_back"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#2D2D2D"),
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(180)),
                      Container(
                        margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                        width: ScreenAdapter.width(270),
                        height: ScreenAdapter.height(100),
                      )
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
