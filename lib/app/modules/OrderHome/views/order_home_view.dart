import 'package:animated_widgets/widgets/rotation_animated.dart';
import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:animated_widgets/widgets/shake_animated_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/config/localString.dart';
import 'package:foodorder/app/modules/OrderHome/views/widgets/ShakeWidget.dart';
import 'package:foodorder/app/modules/OrderHome/views/widgets/languageButton.dart';

import 'package:get/get.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';


import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../controllers/order_home_controller.dart';
import 'SelectDiningMethod.dart';

class OrderHomeView extends GetView<OrderHomeController> {
  final OrderHomeController controller = Get.put(OrderHomeController());
  OrderHomeView({Key? key}) : super(key: key);

  //选择食用方式和支付方式
  _showSelectMealTypeDialog(checkedLanguage, menu_direction) async {
    Get.dialog(
        SelectDiningMethodPage(
          checkLanguage: checkedLanguage,
          dining_type: controller.dining_type.value,
          menu_direction:controller.menu_direction.value,
          onConfrimClick: (bool mealType, String dining_type_num, String menuDirection) {
            var locale = Locale('$checkedLanguage', '$checkedLanguage');
            Get.updateLocale(locale);
            var jumpUrl = (controller.menu_direction.value == "1") ? '/menu-page' :'/menuzong-page';

            Get.toNamed(jumpUrl,arguments: {
              "checkLanguage": checkedLanguage,
              "mealType":mealType
            });

          },
        )
    );
  }


  languageSelectView() {
    List languages = [];
    if (controller.machineLanguages_JP.value == true)
      languages.add({
        "language": "JP",
        "text": "日本語",
        "selected": controller.machineLanguages_JP.value,
        "icon": AssetImage("assets/images/public/language_Japanese.png"),
      });

    if (controller.machineLanguages_CH.value == true)
      languages.add({
        "language": "CH",
        "text": "中文",
        "selected": controller.machineLanguages_CH.value,
        "icon": AssetImage("assets/images/public/language_Chinese.png"),
      });

    if (controller.machineLanguages_EN.value == true)
      languages.add({
        "language": "EN",
        "text": "English",
        "selected": controller.machineLanguages_EN.value,
        "icon": AssetImage("assets/images/public/language_English.png"),
      });

    if (controller.machineLanguages_KO.value == true)
      languages.add({
        "language": "KO",
        "text": "한국어",
        "selected": controller.machineLanguages_KO.value,
        "icon": AssetImage("assets/images/public/language_Korean.png"),
      });

    final buttonList = languages.map((e) {
      return LanguageButton(
        icon: e["icon"] as ImageProvider,
        title: e["text"] as String,
        selected: e["language"] == controller.selectLanguage,
        onTap: () {
          controller.updateSettingLanguage(e["language"] as String);
          controller.startShake = true;
          Future.delayed(Duration(milliseconds: 600),(){
            controller.startShake = false;
            controller.update();
          });
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
        )
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OrderHomeController>(builder: (controller){
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
              Positioned(
                right: ScreenAdapter.width(0),
                top: ScreenAdapter.height(20),
                child: InkWell(
                  onLongPress: (){
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
                bottom: ScreenAdapter.height(400),
                child: Container(
                  width: ScreenAdapter.width(1080),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleAnimatedWidget.tween(
                          enabled: controller.startShake,
                          duration: Duration(milliseconds: 300),
                          scaleDisabled: 1,
                          scaleEnabled: 0.5,
                          child:
                          InkWell(
                            onTap: (){
                              controller.goMenu(controller.selectLanguage, false);
                            },
                            child:
                            Container(
                              alignment: Alignment.center,
                              height:ScreenAdapter.height(150),
                              width: ScreenAdapter.width(300),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.orange, Colors.red],
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Text('menu_dingtype_eatin'.localized(),style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w600,
                              ),),
                            ),
                          )
                      ),
                      SizedBox(width: ScreenAdapter.width(50),),
                      ScaleAnimatedWidget.tween(
                          enabled: controller.startShake,
                          duration: Duration(milliseconds: 300),
                          scaleDisabled: 1,
                          scaleEnabled: 0.5,
                          child:
                          InkWell(
                            onTap: (){
                              controller.goMenu(controller.selectLanguage, true);
                            },
                            child:
                            Container(
                              alignment: Alignment.center,
                              height:ScreenAdapter.height(150),
                              width: ScreenAdapter.width(300),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Colors.orange, Colors.red],
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: Text('menu_dingtype_takeout'.localized(),style: TextStyle(
                                color: Colors.white,
                                fontSize: 50,
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w600,
                              ),),
                            ),
                          )
                      )
                    ],
                  ),

                ),
              ),


              Positioned(
                bottom: ScreenAdapter.height(150),
                child: Container(
                  width: ScreenAdapter.width(1080),
                  height: ScreenAdapter.height(200),
                  child: languageSelectView()
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
