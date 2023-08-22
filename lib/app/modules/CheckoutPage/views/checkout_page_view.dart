import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../controllers/checkout_page_controller.dart';
import 'Appointment.dart';

class CheckoutPageView extends GetView {
  final CheckoutPageController controller = Get.put(CheckoutPageController());
  CheckoutPageView({Key key}) : super(key: key);

  //展示外带按钮
  _showTakeoutButton() {
    var languagesButton = [
      {"name":"テイクアウト","value":"JP"},
      {"name":"外卖","value":"CH"},
      {"name":"Takeout","value":"EN"},
      {"name":"테이크아웃","value":"KO"},
    ];

    List<Widget> takeoutMenus = []; //先建一个数组用于存放循环生成的widget
    for (var item in languagesButton) {
      takeoutMenus.add(InkWell(
        onTap: () {
          var jumpUrl = (controller.menu_direction.value == "1") ? '/menu-page' :'/menuzong-page';
          Get.toNamed(jumpUrl,arguments: {"checkLanguage": "${item["value"]}","mealType":true});
        },
        child: Container(
          width: ScreenAdapter.width(217),
          height: ScreenAdapter.height(90),
          margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
          decoration: BoxDecoration(
            image: DecorationImage(
              //alignment: Alignment.topCenter,
                image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                fit: BoxFit.fill),
          ),
          child: Center(
            //加上Center让文字居中
            child: Text(
              '${item["name"]}',
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(36.0),
                  color: ColorsUtil.hexToColor("#F9F9F9"),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ));

    }
    return Container(
      width: ScreenAdapter.width(1080),
      height: ScreenAdapter.height(120),
      margin: EdgeInsets.only(bottom: ScreenAdapter.height(200)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: takeoutMenus,
      ),
    );


  }


  _showLanguagesButton() {
    var languagesButton = [
      {"name":"お会計","value":"JP"},
      {"name":"结账","value":"CH"},
      {"name":"Bill","value":"EN"},
      {"name":"계산하다","value":"KO"},
    ];
    if(languagesButton.length >0){
      List<Widget> billMenus = []; //先建一个数组用于存放循环生成的widget
      for (var item in languagesButton) {
        if(controller.machineLanguagesList.value.contains(item["value"]) == true){
          billMenus.add(InkWell(
            onTap: () {
              controller.checkLanguage.value = item["value"];


              Get.toNamed("/scancode-page",arguments: {"checkLanguage": controller.checkLanguage.value});


            },
            child: Container(
              width: ScreenAdapter.width(217),
              height: ScreenAdapter.height(90),
              margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
              decoration: BoxDecoration(
                image: DecorationImage(
                  //alignment: Alignment.topCenter,
                    image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                    fit: BoxFit.fill),
              ),
              child: Center(
                //加上Center让文字居中
                child: Text(
                  "${item["name"]}",
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(36.0),
                      color: ColorsUtil.hexToColor("#F9F9F9"),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ));
        }

      }
      return Container(
        width: ScreenAdapter.width(1080),
        height: ScreenAdapter.height(120),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: billMenus,
        ),
      );
    }else{
      return Container(height: 0,);
    }

  }

  //展示预约排号按钮
  _showLineUpButton() {
    return Container(
      width: ScreenAdapter.width(1080),
      height: ScreenAdapter.height(120),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          InkWell(
            onTap: () {
              //显示预约弹出框
              controller.showOrderEasyLoading();
              _showMakeAnAppointmentDialog();

            },
            child: Container(
              width: ScreenAdapter.width(460),
              height: ScreenAdapter.height(100),
              alignment: Alignment.center,
              decoration: BoxDecoration(

                color: ColorsUtil.hexToColor("#4876FF"),
                //设置圆角
                borderRadius: new BorderRadius.circular((16.0)),
              ),
              child: Text("番号札発行 / Booking",
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(36),
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor(
                        Gcolor.settlementBtnColor),
                  )),
            ),
          )
        ],
      ),
    );

  }

  //预约弹出框
  _showMakeAnAppointmentDialog() async {
    Get.dialog(
        AppointmentPage()
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CheckoutPageController>(builder: (controller){
        return controller.obx((state) => AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
          child: Stack(
            children: [
              Container(
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
                                showCursor: true, // 显示光标
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
                                  Future.delayed(Duration(milliseconds: 150), () {print("精算扫码了");
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
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      padding: EdgeInsets.zero,
                      child: Swiper(
                        //itemHeight: 200,
                        itemBuilder: (BuildContext context,int index){
                          // 配置图片地址
                          return publicShowMenuImage(imgPath:controller.homeList.value[index],imgWidth: 1080.0,imgHeight: 1920.0);
                        },
                        // 配置图片数量
                        itemCount: controller.homeList.value.length,
                        // 底部分页器
                        //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
                        // 左右箭头
                        //control: new SwiperControl(),
                        // 无限循环
                        loop: (controller.homeList.value.length >1) ?true :false,
                        duration: 1000,
                        autoplayDelay:12000,
                        // 自动轮播
                        autoplay: (controller.homeList.value.length >1) ?true :false,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                right: ScreenAdapter.width(0),
                top: ScreenAdapter.height(20),
                child: InkWell(
                  onTap: (){
                    Get.toNamed('/middlewaresettingpage', arguments: {"machineCode": controller.machineCode.value});
                  },
                  child: Container(
                    height: ScreenAdapter.height(150),
                    width: ScreenAdapter.width(200),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(top:ScreenAdapter.height(20),left: ScreenAdapter.width(20),right: ScreenAdapter.width(20),bottom: ScreenAdapter.height(20)),
                    child: Center(
                      //加上Center让文字居中
                      child: Text(
                        "",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(48.0),
                            color: ColorsUtil.hexToColor("#F9F9F9"),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: ScreenAdapter.height(1300),
                child: Container(
                  width: ScreenAdapter.width(1080),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if(controller.takeOut.value == true)
                        _showTakeoutButton(),

                      _showLanguagesButton(),
                      SizedBox(height: ScreenAdapter.height(60),),
                      //是否展示预定排号
                      if(controller.lineup.value == true && controller.isReservation.value == "1")
                        _showLineUpButton(),
                    ],
                  ),
                ),
              )
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
