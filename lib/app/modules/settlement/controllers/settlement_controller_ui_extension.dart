
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/modules/settlement/controllers/settlement_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/DialogUtils.dart';

extension SettlementControllerUIExtension on SettlementController {

  showCashAlert(){
    print("现金取消");
    Future.delayed(Duration(milliseconds: 50),() async {
      Get.dialog(
          DialogUtils.alert(GString.getToString(checkLanguage.value, "settlement_back_alertcontent"),
              title: GString.getToString(checkLanguage.value, "tag_title"),
              canceltitle: GString.getToString(checkLanguage.value, "tag_button_no"),
              confirmtitle: GString.getToString(checkLanguage.value, "tag_button_yes"),
              confirm: () {
                Get.back();
                showBackEasyLoading();
                CancelOrder();
              },
              cancle: () {
                allowClick.value = true;
                Get.back();
              }),
          barrierDismissible: false
      );

    });
  }

  showCheckLoading(){
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                "取引が不明な状態で終了しました（コード801）。決済結果を確認中ですのでお待ちください。",
                style: TextStyle(
                  fontFamily: GFont.getFontFamily(),
                  fontSize: ScreenAdapter.fontSize(25),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                )),
            InkWell(
              onLongPress: (){
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );

  }


  showPosEasyLoading() {
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(840),
        height: ScreenAdapter.height(790),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: 0,),//_showTag
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onLongPress: () {
                    EasyLoading.dismiss();
                  },
                  child: Container(
                    //width: ScreenAdapter.width(400),
                    margin: EdgeInsets.only(right: ScreenAdapter.width(15)),
                    height: ScreenAdapter.height(40),
                    child: Image.asset(
                        GImage.getImageString("imgpublic", "printticketloading"),
                        fit: BoxFit.fitHeight),
                  ),
                ),
                Expanded(
                  //padding: EdgeInsets.only(left: ScreenAdapter.width(15), right: ScreenAdapter.width(15)),
                  child: Text(
                      GString.getToString(checkLanguage.value,
                          "settlement_posPay_loadint_title"),
                      maxLines: 2,
                      //softWrap: true,
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: ScreenAdapter.fontSize(34),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      )),
                )
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: ScreenAdapter.height(10),bottom: ScreenAdapter.height(20)),
              child: Divider(  // 这是一个分割线
                color: Colors.black,  // 设置分割线的颜色
                thickness: 2,  // 设置分割线的粗细
                indent: 20,  // 设置分割线开始缩进的距离
                endIndent: 20,  // 设置分割线结束缩进的距离
              ),
            ),
            Container(
              //width: ScreenAdapter.width(700),
              alignment: Alignment.center,
              //height: ScreenAdapter.height(940),
              child: FadeInImage(
                placeholder: AssetImage('assets/images/public/placeholder.png'), // 本地assets中的占位符图像
                image: AssetImage(GImage.getImageString("imgpublic", "settlement_pos_loading_${checkLanguage.value}")),
                //width: ScreenAdapter.width(600),
                height: ScreenAdapter.width(600),
                fit: BoxFit.fitHeight,
                // [占位符] 的淡出动画时间
                fadeOutDuration: Duration(milliseconds: 100),
                // [图像] 的渐入动画曲线
                fadeInCurve: Curves.easeIn,
                // [图像] 的渐入动画时间
                fadeInDuration: Duration(milliseconds: 100),
              ),
            )
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }


  showEasyLoadingScan() {
    var _showTag;
    if (int.parse(showOutMoney.value) > 0) {
      //_showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_outprice_tag"),
      _showTag = Text(
          GString.getToString(
              checkLanguage.value, "settlement_print_loading_tag"),
          style: TextStyle(
            fontFamily: GFont.getFontFamily(),
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    } else {
      _showTag = Text(
          GString.getToString(
              checkLanguage.value, "settlement_print_loading_tag"),
          style: TextStyle(
            fontFamily: GFont.getFontFamily(),
            fontSize: ScreenAdapter.fontSize(25),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    }
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            InkWell(
              onLongPress: () {
                ScanCodeConfirmTimer?.cancel();
                doScanCodeTimeOutLastQuery();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  showBackEasyLoading() {
    var _showTag =
    Text(GString.getToString(checkLanguage.value, "settlement_noprint_tag"),
        style: TextStyle(
          fontFamily: GFont.getFontFamily(),
          fontSize: ScreenAdapter.fontSize(25),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  showPosCancelEasyLoading(resultString,{resultPFSString:""}) {
    EasyLoading.dismiss();
    var _showTag;
    var _showTagContent = "";
    if(resultString =="M10"){//需要从端末点击返回
      _showTag = Align(
        child: Text(GString.getToString(checkLanguage.value, "settlement_posPay_error_connect_worker"),
            style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(28))),
        alignment: Alignment(0, 0),
      );
      _showTagContent = GString.getToString(checkLanguage.value, "settlement_posPay_error_connect_worker");
    }else if(resultString =="L06"){//需要从端末点击返回
      _showTag = Align(
        child: Text(GString.getToString(checkLanguage.value, "settlement_posPay_error_connect_worker"),
            style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(28))),
        alignment: Alignment(0, 0),
      );
      _showTagContent = GString.getToString(checkLanguage.value, "settlement_posPay_error_connect_worker");
    }else{
      _showTag = Align(
        child: Text(GString.getToString(checkLanguage.value, "settlement_posPay_error"),
            style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(28))),
        alignment: Alignment(0, 0),
      );
      _showTagContent = GString.getToString(checkLanguage.value, "settlement_posPay_error");

      if (resultString.contains("L10")) {
        gotonewMenuPage(); //返回首页
        return;
      }

      if (resultPFSString.contains("101")
          ||resultPFSString.contains("110")
          ||resultPFSString.contains("118")
      ) {
        CancelOrder(); //取消订单
        return;
      }

    }
    Get.dialog(
        DialogUtils.alertOneButton(_showTagContent+"[${resultString}-${resultPFSString}]",
            title: GString.getToString(checkLanguage.value, "tag_title"),
            confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
            confirm: () {
              if(resultString !="M10" && resultString !="L06" && resultString !="L05"
                  && resultString !="L81" && resultString !="M40"){
                getPaymentCancelPosData();
              }

              Get.back();
              showEasyLoading();
              Future.delayed(Duration(milliseconds: 1500),() async {
                CancelOrder();
              });
            }),
      barrierDismissible: false
    );

  }

  showEasyLoading() {
    var _showTag;
    if (int.parse(showOutMoney.value) > 0) {
      //_showTag = Text(GString.getToString(this._checkLanguage, "settlement_print_outprice_tag"),
      _showTag = Text(
          GString.getToString(
              checkLanguage.value, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontFamily: GFont.getFontFamily(),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    } else {
      _showTag = Text(
          GString.getToString(
              checkLanguage.value, "settlement_print_loading_tag"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(25),
            fontFamily: GFont.getFontFamily(),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
          ));
    }
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ),

          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  showSuccessEasyLoading() {
    var _showTag;

    _showTag =
        Text(GString.getToString(checkLanguage.value, "payment_success_title"),
            style: TextStyle(
              fontFamily: GFont.getFontFamily(),
              fontSize: ScreenAdapter.fontSize(25),
              fontWeight: FontWeight.w600,
              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
            ));

    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            InkWell(
              onLongPress: () {
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "paymentSuccess"),
                    fit: BoxFit.fitHeight),
              ),
            ),

          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }



}