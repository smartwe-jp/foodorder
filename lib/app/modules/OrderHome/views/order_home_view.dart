import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';


import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../../menuPage/views/menu_page_view.dart';
import '../../menuPage/views/menuzong_page_view.dart';
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
          dining_type: controller.machineInfo.diningType,
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
                    return publicShowMenuImage(imgPath:controller.homeList.value[index],imgWidth: 1080.0,imgHeight: 1920.0);//图片显示报错
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
                top: ScreenAdapter.height(1450),
                child: Container(
                  width: ScreenAdapter.width(1080),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if(controller.machineLanguages_JP.value == true)
                        InkWell(
                          onTap: () {
                            //_clearCartList();
                            if(controller.machineInfo.diningType =="1" || controller.machineInfo.diningType =="2"){
                              var mealType = (controller.machineInfo.diningType == "2") ? true: false;
                              var jumpUrl = (controller.menu_direction.value == "1") ? '/menu-page' :'/menuzong-page';
                              var locale = Locale('jp', 'JP');
                              Get.updateLocale(locale);
                              Get.toNamed(jumpUrl,arguments: {
                                "checkLanguage": "JP",
                                "mealType":mealType
                              });

                            }else{
                              _showSelectMealTypeDialog("JP", controller.menu_direction.value);
                            }


                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                  fit: BoxFit.fill),
                            ),
                            child: Center(
                              //加上Center让文字居中
                              child: Text(
                                '日本語',
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(36.0),
                                    fontFamily: "NotoSansJP",
                                    color: ColorsUtil.hexToColor("#F9F9F9"),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      //SizedBox(width:ScreenAdapter.width(35)),
                      if(controller.machineLanguages_CH.value == true)
                        InkWell(
                          onTap: () {
                            if(controller.machineInfo.diningType =="1" || controller.machineInfo.diningType =="2"){
                              var mealType = (controller.machineInfo.diningType == "2") ? true: false;
                              var jumpUrl = (controller.menu_direction.value == "1") ? '/menu-page' :'/menuzong-page';
                              var locale = Locale('ch', 'CH');
                              Get.updateLocale(locale);
                              Get.toNamed(jumpUrl,arguments: {
                                "checkLanguage": "CH",
                                "mealType":mealType
                              });
                            }else{
                              _showSelectMealTypeDialog("CH", controller.menu_direction.value);
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                  fit: BoxFit.fill),
                            ),
                            child: Center(
                              //加上Center让文字居中
                              child: Text(
                                '中文',
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(36.0),
                                    fontFamily: "NotoSansCN",
                                    color: ColorsUtil.hexToColor("#F9F9F9"),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      //SizedBox(width:ScreenAdapter.width(35)),
                      if(controller.machineLanguages_EN.value == true)
                        InkWell(
                          onTap: () {
                            if(controller.machineInfo.diningType =="1" || controller.machineInfo.diningType =="2"){
                              var mealType = (controller.machineInfo.diningType == "2") ? true: false;
                              var jumpUrl = (controller.menu_direction.value == "1") ? '/menu-page' :'/menuzong-page';
                              var locale = Locale('en', 'US');
                              Get.updateLocale(locale);
                              Get.toNamed(jumpUrl,arguments: {
                                "checkLanguage": "EN",
                                "mealType":mealType
                              });
                            }else{
                              _showSelectMealTypeDialog("EN", controller.menu_direction.value);
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                  fit: BoxFit.fill),
                            ),
                            child: Center(
                              //加上Center让文字居中
                              child: Text(
                                'English',
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(36.0),
                                    fontFamily: "NotoSans",
                                    color: ColorsUtil.hexToColor("#F9F9F9"),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      //SizedBox(width:ScreenAdapter.width(35)),
                      if(controller.machineLanguages_KO.value == true)
                        InkWell(
                          onTap: () {
                            if(controller.machineInfo.diningType =="1" || controller.machineInfo.diningType =="2"){
                              var mealType = (controller.machineInfo.diningType == "2") ? true: false;
                              var jumpUrl = (controller.menu_direction.value == "1") ? '/menu-page' :'/menuzong-page';
                              var locale = Locale('ko', 'KR');
                              Get.updateLocale(locale);
                              Get.toNamed(jumpUrl,arguments: {
                                "checkLanguage": "KO",
                                "mealType":mealType
                              });
                            }else{
                              _showSelectMealTypeDialog("KO", controller.menu_direction.value);
                            }
                          },
                          child: Container(
                            width: ScreenAdapter.width(217),
                            height: ScreenAdapter.height(90),
                            decoration: BoxDecoration(
                              //color: Color(0x11111111),
                              image: DecorationImage(
                                //alignment: Alignment.topCenter,
                                  image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                  fit: BoxFit.fill),
                            ),
                            child: Center(
                              //加上Center让文字居中
                              child: Text(
                                '한국말',
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(36.0),
                                    fontFamily: "NotoSansKR",
                                    color: ColorsUtil.hexToColor("#F9F9F9"),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
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
