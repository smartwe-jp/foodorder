import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/localString.dart';
import 'package:foodorder/app/modules/OrderHome/views/components/BookingTypeButton.dart';
import 'package:foodorder/app/modules/OrderHome/views/components/CatagoryButton.dart';
import 'package:foodorder/app/modules/OrderHome/views/components/LanguageButton.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';

import 'package:get/get.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../controllers/checkout_page_controller.dart';
import 'Appointment.dart';


class CheckoutPageView extends GetView {
  final CheckoutPageController controller = Get.find();
  CheckoutPageView({Key? key}) : super(key: key);

  languageSelectView() {
    List languages = [];
    if (controller.machineLanguages_JP == true)
      languages.add({
        "language": "JP",
        "text": "日本語",
        "selected": controller.machineLanguages_JP,
        "icon": AssetImage("assets/images/public/language_Japanese.png"),
      });

    if (controller.machineLanguages_CH == true)
      languages.add({
        "language": "CH",
        "text": "中文",
        "selected": controller.machineLanguages_CH,
        "icon": AssetImage("assets/images/public/language_Chinese.png"),
      });

    if (controller.machineLanguages_EN == true)
      languages.add({
        "language": "EN",
        "text": "English",
        "selected": controller.machineLanguages_EN,
        "icon": AssetImage("assets/images/public/language_English.png"),
      });

    if (controller.machineLanguages_KO == true)
      languages.add({
        "language": "KO",
        "text": "한국어",
        "selected": controller.machineLanguages_KO,
        "icon": AssetImage("assets/images/public/language_Korean.png"),
      });

    final buttonList = languages.map((e) {
      return LanguageButton(
        icon: e["icon"] as ImageProvider,
        title: e["text"] as String,
        selected: false,//e["language"] == controller.checkLanguage.value,
        onTap: () {
          controller.updateSettingLanguage(e["language"] as String);
        },
      );
    }).toList();

    return Container(
        alignment: Alignment.center,
        height: ScreenAdapter.height(100),
        padding: EdgeInsets.only(
          top: ScreenAdapter.height(20),
          left: ScreenAdapter.width(30),
          right: ScreenAdapter.width(30),
          bottom: ScreenAdapter.height(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [...buttonList],
        ));
  }

  //展示外带按钮
  _showTakeoutButton() {
    var languagesButton = [
      {"name": "テイクアウト", "value": "JP"},
      {"name": "外卖", "value": "CH"},
      {"name": "Takeout", "value": "EN"},
      {"name": "테이크아웃", "value": "KO"},
    ];

    List<Widget> takeoutMenus = []; //先建一个数组用于存放循环生成的widget
    for (var item in languagesButton) {
      if (controller.machineLanguagesList.contains(item["value"]) ==
          true) {
        takeoutMenus.add(InkWell(
          onTap: () {
            var jumpUrl = (controller.machineInfo.menu_direction == "1")
                ? '/menu-page'
                : '/menuzong-page';
            final locale = Locale('${item["value"]}'.toLowerCase(),
                '${item["value"]}'.toUpperCase());
            Get.updateLocale(locale);
            Get.toNamed(jumpUrl, arguments: {
              "checkLanguage": "${item["value"]}",
              "mealType": true
            });
          },
          child: Container(
            width: ScreenAdapter.width(217),
            height: ScreenAdapter.height(90),
            margin: EdgeInsets.only(
                left: ScreenAdapter.width(15), right: ScreenAdapter.width(15)),
            decoration: BoxDecoration(
              image: DecorationImage(
                  //alignment: Alignment.topCenter,
                  image: AssetImage(
                      GImage.getImageString("imgpublic", "home_button")),
                  fit: BoxFit.fill),
            ),
            child: Center(
              //加上Center让文字居中
              child: Text(
                '${item["name"]}',
                style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
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
      margin: EdgeInsets.only(bottom: ScreenAdapter.height(60)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: takeoutMenus,
      ),
    );
  }

  _showLanguagesButton() {
    var languagesButton = [
      {"name": "お会計", "value": "JP"},
      {"name": "结账", "value": "CH"},
      {"name": "Bill", "value": "EN"},
      {"name": "계산하다", "value": "KO"},
    ];
    if (languagesButton.length > 0) {
      List<Widget> billMenus = []; //先建一个数组用于存放循环生成的widget
      for (var item in languagesButton) {
        if (controller.machineLanguagesList.value.contains(item["value"]) ==
            true) {
          billMenus.add(InkWell(
            onTap: () {
              controller.checkLanguage.value = item["value"]!;
              controller.scanQrCodeController.text = "";
              controller.scanQrCodeFocusNode.requestFocus();
              final locale =
                  Locale('${item["value"]}'.toLowerCase(), '${item["value"]}');
              Get.updateLocale(locale);
              Get.toNamed("/scancode-page",
                  arguments: {"checkLanguage": controller.checkLanguage.value});
            },
            child: Container(
              width: ScreenAdapter.width(217),
              height: ScreenAdapter.height(90),
              margin: EdgeInsets.only(
                  left: ScreenAdapter.width(15),
                  right: ScreenAdapter.width(15)),
              decoration: BoxDecoration(
                image: DecorationImage(
                    //alignment: Alignment.topCenter,
                    image: AssetImage(
                        GImage.getImageString("imgpublic", "home_button")),
                    fit: BoxFit.fill),
              ),
              child: Center(
                //加上Center让文字居中
                child: Text(
                  "${item["name"]}",
                  style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
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
    } else {
      return Container(
        height: 0,
      );
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
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(36),
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                  )),
            ),
          )
        ],
      ),
    );
  }

  ImageProvider _catagroyImage(String url) {
    if (url.isEmpty) {
      return AssetImage("assets/images/public/app_viewmore_icon.png");
    } else {
      return CachedNetworkImageProvider(url);
    }
  }

  catagoryGridView() {
    List<Widget> buttonList = controller.showCatagory
        .map<Widget>(
          (e) => CatagoryButton(
            icon: _catagroyImage(e['image'] ?? ""),
            title: e["categoryName"] ?? "",
            onTap: () async {
              controller.resetTimer?.cancel();
              controller.mealTypeStatus = 0;
              var mealType = true;

              var jumpUrl = (controller.machineInfo.menu_direction == "1")
                  ? '/menu-page'
                  : '/menuzong-page';

              final result = await Get.toNamed(jumpUrl, arguments: {
                "classTag": e["categoryCode"] ?? "",
                "menuList": controller.categoryList,
                "checkLanguage": controller.checkLanguage.value,
                "mealType": mealType
              });
              if (result == true) {
                controller.mealTypeStatus = 0;
                controller.getBookingBootIndexCagegory();
              }
            },
          ),
        )
        .toList();

    return Stack(children: [
      Container(
        padding: EdgeInsets.only(
          top: ScreenAdapter.height(70),
          left: ScreenAdapter.width(70),
          right: ScreenAdapter.width(70),
          bottom: ScreenAdapter.height(70),
        ),
        child: GridMenuView(
          children: buttonList,
          mainAxisSpacing: ScreenAdapter.width(50),
          crossAxisSpacing: ScreenAdapter.height(50),
          childAspectRatio: 0.9,
        ),
      ),
      if (controller.mealTypeStatus == 0)
        ClipRect(
            child: Stack(
          children: [
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(50, 0, 0, 0),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(30),
                  right: ScreenAdapter.width(30)),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: ScreenAdapter.width(150),
                      ),
                      Transform.rotate(
                          angle: pi / 6,
                          child: Container(
                            width: ScreenAdapter.height(150),
                            height: ScreenAdapter.height(150),
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    "assets/images/public/finger_touch.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ))
                    ],
                  ),
                  Text(
                      GString.getToString(
                          controller.checkLanguage.value,
                          "dining_welcome"),
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(80),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 23, 106, 67),
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                      GString.getToString(
                          controller.checkLanguage.value,
                          controller.takeOut ? "checkout_type_tips" : "amount_tips"),
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(56),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 23, 106, 67),
                      )),
                ],
              )),
            )
          ],
        )),
    ]);
  }

  get eatInShopImage => controller.mealTypeStatus == 1
      ? AssetImage("assets/images/public/settlement_top_qr.png")
      : AssetImage("assets/images/public/settlement_top_qr_code_dark.png");

  get eatOutImage => controller.mealTypeStatus == 2
      ? AssetImage("assets/images/public/eat_out_on.png")
      : AssetImage("assets/images/public/eat_out_off.png");

  _mealTyleView() {
    return Expanded(
      flex: 3,
      child: Container(
        decoration: BoxDecoration(
          color: controller.mealTypeStatus == 0
              ? Color.fromARGB(50, 0, 0, 0)
              : Color.fromARGB(0, 0, 0, 0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(
              width: ScreenAdapter.width(70),
            ),
            Expanded(
              child: BookingTypeButtonOld(
                icon: eatInShopImage,
                title: GString.getToString(
                    controller.checkLanguage.value, "settlement_button"),
                selected: controller.mealTypeStatus == 1,
                onTap: () {
                  //controller.updateDingType(1);
                  Get.toNamed("/scancode-page");
                },
              ),
            ),
            SizedBox(
              width: ScreenAdapter.height(70),
            ),

            if (controller.takeOut) 
            Expanded(
              child: BookingTypeButtonOld(
                icon: eatOutImage,
                title: GString.getToString(
                    controller.checkLanguage.value, "take_out"),
                selected: controller.mealTypeStatus == 2,
                onTap: () {
                  controller.updateDingType(2);
                },
              ),
            ),
            if (controller.takeOut) 
            SizedBox(
              width: ScreenAdapter.width(70),
            ),
            
          ],
        ),
      ),
    );
  }

  //预约弹出框
  _showMakeAnAppointmentDialog() async {
    Get.dialog(AppointmentPage());
  }

    _diningSelectArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleAnimatedWidget.tween(
          enabled: controller.startShake,
          duration: Duration(milliseconds: 500),
          scaleDisabled: 1.0,
          scaleEnabled: 0.9,
          child:BookingTypeButton(
            icon: Icon(
              Icons.qr_code,
              color: Colors.blueGrey[100],
              size: 120,
            ),
            title: 'settlement_button'.localized(),
            selected: false,
            onTap: ()=>Get.toNamed("/scancode-page"),
          ),
        ),

        SizedBox(width: ScreenAdapter.width(50),),
        ScaleAnimatedWidget.tween(
          enabled: controller.startShake,
          duration: Duration(milliseconds: 500),
          scaleDisabled: 0.9,
          scaleEnabled: 1.0,
          child:BookingTypeButton(
            icon: Icon(
              Icons.shopping_bag,
              color: Colors.blueGrey[100],
              size: 120,
            ),
            title: 'menu_dingtype_takeout'.localized(),
            selected: false,
            onTap: ()=>controller.goMenu(controller.selectLanguage, true),
          ),
        )
      ],
    );
  }

  _startButton() {
    return ScaleAnimatedWidget.tween(
      enabled: controller.startShake,
      duration: Duration(milliseconds: 500),
      scaleDisabled: 0.9,
      scaleEnabled: 1.0,
      child:
      InkWell(
        onTap: ()=>controller.goMenu(controller.selectLanguage, false),
        child: Container(
          padding: EdgeInsets.all(10),
          height:ScreenAdapter.height(260),
          width: ScreenAdapter.width(600),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'settlement_button'.localized(),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,//const Color.fromARGB(255, 53,59,80),
              fontSize: 80,
              fontFamily: GFont.getFontFamily(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
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
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Swiper(
                  //itemHeight: 200,
                  itemBuilder: (BuildContext context,int index){
                    // 配置图片地址
                    return publicShowMenuImage(imgPath:controller.machineInfo.homeList[index],imgWidth: 1080.0,imgHeight: 1920.0);
                  },
                  // 配置图片数量
                  itemCount: controller.machineInfo.homeList.length,
                  // 底部分页器
                  //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
                  // 左右箭头
                  //control: new SwiperControl(),
                  // 无限循环
                  loop: (controller.machineInfo.homeList.length >1) ?true :false,
                  duration: 1000,
                  autoplayDelay:12000,
                  // 自动轮播
                  autoplay: (controller.machineInfo.homeList.length >1) ?true :false,
                ),
              ),
              Positioned(
                right: ScreenAdapter.width(0),
                top: ScreenAdapter.height(20),
                child: InkWell(
                  onLongPress: (){
                    Get.toNamed('/middlewaresettingpage', arguments: {"machineCode": controller.machineInfo.machineCode});
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
                bottom: ScreenAdapter.height(720),
                child: Container(
                  width: ScreenAdapter.width(1080),
                  child: Column(
                    children: [
                      Text(
                        'menu_dingtype_title'.localized(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.green[900],//const Color.fromARGB(255, 53,59,80),
                          fontSize: 80,
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              offset: Offset(3.0, -4.0),
                              blurRadius: 1.0,
                            ),
                          ],
                        ),
                      ),
                      if (controller.machineInfo.diningType == "3")
                      Text(
                        'menu_ding_type_tips'.localized(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.green[900],//const Color.fromARGB(255, 53,59,80),
                          fontSize: 40,
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.white,
                              offset: Offset(2.0, -2.0),
                              blurRadius: 2.0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ),


              Positioned(
                bottom: ScreenAdapter.height(400),
                width: ScreenAdapter.width(1080),
                child: Center(
                  child:
                    controller.machineInfo.diningType == "3" ?
                      _diningSelectArea()
                    : _startButton()

                ),
              ),


              Positioned(
                bottom: ScreenAdapter.height(150),
                child: Container(
                  width: ScreenAdapter.width(1080),
                  height: ScreenAdapter.height(200),
                  child: languageSelectView()
                ),
              ),

              Positioned(
                bottom: ScreenAdapter.height(120),
                child: Container(
                    width: ScreenAdapter.width(1080),
                    child: Divider(
                      height: 1,
                      color: Colors.grey[300],
                      indent: 50,
                      endIndent: 50,
                    )
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

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: GetBuilder<CheckoutPageController>(builder: (controller) {
  //       return controller.obx(
  //         (state) => AnnotatedRegion(
  //           value: SystemUiOverlayStyle.light,
  //           child: Stack(
  //             children: [
  //               Container(
  //                 //padding: EdgeInsets.zero,
  //                 //height: ScreenAdapter.height(1920),
  //                 child: Column(
  //                   children: [
  //                     Container(
  //                       height: ScreenAdapter.height(400),
  //                       child: Swiper(
  //                         //itemHeight: 200,
  //                         itemBuilder: (BuildContext context, int index) {
  //                           // 配置图片地址
  //                           return publicShowMenuImage(
  //                               imgPath: controller.machineInfo.homeList[index],
  //                               imgWidth: 1080.0,
  //                               imgHeight: 1920.0);
  //                         },
  //                         // 配置图片数量
  //                         itemCount: controller.machineInfo.homeList.length,
  //                         // 底部分页器
  //                         //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
  //                         // 左右箭头
  //                         //control: new SwiperControl(),
  //                         // 无限循环
  //                         loop: (controller.machineInfo.homeList.length > 1)
  //                             ? true
  //                             : false,
  //                         duration: 1000,
  //                         autoplayDelay: 12000,
  //                         // 自动轮播
  //                         autoplay: (controller.machineInfo.homeList.length > 1)
  //                             ? true
  //                             : false,
  //                       ),
  //                     ),
  //                     _mealTyleView(),
  //                     Expanded(
  //                         flex: 7,
  //                         child: Container(
  //                           alignment: Alignment.center,
  //                           decoration: BoxDecoration(
  //                             color: Color.fromARGB(255, 243, 243, 243),
  //                           ),
  //                           child: catagoryGridView(),
  //                         )),
  //                     Expanded(
  //                       flex: 2,
  //                       child: languageSelectView(),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Positioned(
  //                 right: ScreenAdapter.width(0),
  //                 top: ScreenAdapter.height(20),
  //                 child: InkWell(
  //                   onLongPress: () {
  //                     Get.toNamed('/middlewaresettingpage', arguments: {
  //                       "machineCode": controller.machineInfo.machineCode
  //                     });
  //                   },
  //                   child: Container(
  //                     height: ScreenAdapter.height(150),
  //                     width: ScreenAdapter.width(200),
  //                     alignment: Alignment.centerRight,
  //                     padding: EdgeInsets.only(
  //                         top: ScreenAdapter.height(20),
  //                         left: ScreenAdapter.width(20),
  //                         right: ScreenAdapter.width(20),
  //                         bottom: ScreenAdapter.height(20)),
  //                     child: Center(
  //                       //加上Center让文字居中
  //                       child: Text(
  //                         "",
  //                         style: TextStyle(
  //                             fontSize: ScreenAdapter.fontSize(48.0),
  //                             color: ColorsUtil.hexToColor("#F9F9F9"),
  //                             fontWeight: FontWeight.w600),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         onLoading: Center(
  //           child: CircularProgressIndicator(
  //             strokeWidth: 6,
  //             valueColor: new AlwaysStoppedAnimation<Color>(
  //                 ColorsUtil.hexToColor("#80B646")),
  //           ),
  //         ),
  //       );
  //     }),
  //   );
  // }
}
