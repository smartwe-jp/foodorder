import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../controllers/checkout_page_controller.dart';
import 'Appointment.dart';

class ScanCodeView extends GetView {
  final CheckoutPageController controller = Get.put(CheckoutPageController());
  ScanCodeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CheckoutPageController>(builder: (controller){
        return controller.obx((state) => AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
          child: Container(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  height: 0,
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                            keyboardType: TextInputType.text,
                            autofocus: true,
                            showCursor: false, // 显示光标
                            //readOnly: true,
                            controller: controller.scanQrCodeController,
                            focusNode: controller.scanQrCodeFocusNode,
                            decoration: InputDecoration(
                              hintText: "请扫码",
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: ScreenAdapter.fontSize(11.0)),
                            onChanged: (value) {
                              //print(value);
                              if(value.length==1){
                                controller.showOrderEasyLoading();
                              }

                            },
                            onSubmitted: (value){
                              Future.delayed(Duration(milliseconds: 300), () {
                                controller.doNextPay();
                              });



                            },

                            /// 扫码密码
                          )
                      ),
                    ],
                  ),
                ),
                Container(
                  width: ScreenAdapter.getScreenWidth(),
                  height: ScreenAdapter.height(95),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        ColorsUtil.hexToColor("#C47829"),
                        ColorsUtil.hexToColor("#854610"),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            GImage.getImageString(
                                "imgpublic", "settlement_top_qr"),
                            width: ScreenAdapter.width(40),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(
                            width: ScreenAdapter.width(20),
                          ),
                          Text(
                            GString.getToString(controller.checkLanguage.value, "checkoutScanTitle"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                      //height: ScreenAdapter.height(940),
                      child: Image.asset(
                        GImage.getImageString("imgpublic","jingsuantag"),
                        width: ScreenAdapter.width(1070),
                        fit: BoxFit.fitWidth,
                      ),
                    )
                ),
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
                            Navigator.pop(context);

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
                          child: Text(
                            GString.getToString(controller.checkLanguage.value, "settlement_back"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#000000"),
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
