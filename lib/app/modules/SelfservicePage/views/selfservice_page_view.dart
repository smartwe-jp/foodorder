import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/localString.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../../OrderHome/views/SelectDiningMethod.dart';
import '../../OrderHome/views/widgets/BookingTypeButton.dart';
import '../../OrderHome/views/widgets/languageButton.dart';
import '../controllers/selfservice_page_controller.dart';

class SelfservicePageView extends GetView {
  final SelfservicePageController controller = Get.put(SelfservicePageController());
  SelfservicePageView({Key? key}) : super(key: key);

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
            title: 'settlement_button'.tr,
            selected: false,
            onTap: ()=>controller.goSelfCheckout(),
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
            title: 'menu_dingtype_takeout'.tr,
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
        onTap: ()=>controller.goSelfCheckout(),
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
            'settlement_button'.tr,
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
      body: GetBuilder<SelfservicePageController>(builder: (controller){
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
                          'menu_dingtype_title'.tr,
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
                            'menu_ding_type_tips'.tr,
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
}
