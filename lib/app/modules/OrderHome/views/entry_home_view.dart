import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/modules/OrderHome/controllers/order_home_controller.dart';
import 'package:get/get.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../services/ScreenAdapter.dart';
import 'SelectDiningMethod.dart';

class EntryHomeView extends GetView<OrderHomeController> {
  final OrderHomeController controller = Get.put(OrderHomeController());
  EntryHomeView({Key? key}) : super(key: key);


  _showSelectMealTypeDialog(checkedLanguage, menu_direction) async {
    Get.dialog(SelectDiningMethodPage(
      checkLanguage: checkedLanguage,
      dining_type: controller.dining_type.value,
      menu_direction: controller.menu_direction.value,
      onConfrimClick:
          (bool mealType, String dining_type_num, String menuDirection) {
        var jumpUrl = (controller.menu_direction.value == "1")
            ? '/menu-page'
            : '/menuzong-page';

        Get.toNamed(jumpUrl, arguments: {
          "checkLanguage": checkedLanguage,
          "mealType": mealType
        });
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OrderHomeController>(
        builder: (controller) {
          return controller.obx(
          (state) => AnnotatedRegion(
            value: SystemUiOverlayStyle.light,
            child: Center(
              child: 
              Stack(
                children: [

                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: 
                    Column (
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:  <Widget>[  
                      IntrinsicHeight (child: 
                        Row(
                          children: <Widget>[
                            Expanded(
                              flex: 2,
                              child: AspectRatio(
                                aspectRatio: 1.0, // 宽度和高度相等
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    image: DecorationImage(
                                      image: AssetImage('assets/images/gongcha/home.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20), // 图片之间的间距为10像素
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 1.0, // 宽度和高度相等
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/gongcha/home2.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20), // 图片之间的间距为10像素
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 1.0, // 宽度和高度相等
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/gongcha/home4.png'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      
                      
                      SizedBox(height: 20), // 图片之间的间距为10像素
                      Container(
                        height: ScreenAdapter.height(400),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage('assets/images/gongcha/home3.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 150), // 图片之间的间距为10像素
                      Container(
                        //width: ScreenAdapter.width(1080),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            if (controller.machineLanguages_JP.value == true)
                              InkWell(
                                onTap: () {
                                  //_clearCartList();
                                  if (controller.dining_type.value == "1" ||
                                      controller.dining_type.value == "2") {
                                    var mealType =
                                        (controller.dining_type.value == "2")
                                            ? true
                                            : false;
                                    var jumpUrl =
                                        (controller.menu_direction.value == "1")
                                            ? '/menu-page'
                                            : '/menuzong-page';

                                    Get.toNamed(jumpUrl, arguments: {
                                      "checkLanguage": "JP",
                                      "mealType": mealType
                                    });
                                  } else {
                                    _showSelectMealTypeDialog(
                                        "JP", controller.menu_direction.value);
                                  }
                                },
                                child: Container(
                                  width: ScreenAdapter.width(217),
                                  height: ScreenAdapter.height(90),
                                  margin: EdgeInsets.only(
                                      right: ScreenAdapter.width(35)),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 0, 162, 147),
                                    border: Border.all(
                                        color: ColorsUtil.hexToColor("#090909"),
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Center(
                                    //加上Center让文字居中
                                    child: Text(
                                      '日本語',
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(36.0),
                                          color: ColorsUtil.hexToColor("#F9F9F9"),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            //SizedBox(width:ScreenAdapter.width(35)),
                            if (controller.machineLanguages_CH.value == true)
                              InkWell(
                                onTap: () {
                                  if (controller.dining_type.value == "1" ||
                                      controller.dining_type.value == "2") {
                                    var mealType =
                                        (controller.dining_type.value == "2")
                                            ? true
                                            : false;
                                    var jumpUrl =
                                        (controller.menu_direction.value == "1")
                                            ? '/menu-page'
                                            : '/menuzong-page';

                                    Get.toNamed(jumpUrl, arguments: {
                                      "checkLanguage": "CH",
                                      "mealType": mealType
                                    });
                                  } else {
                                    _showSelectMealTypeDialog(
                                        "CH", controller.menu_direction.value);
                                  }
                                },
                                child: Container(
                                  width: ScreenAdapter.width(217),
                                  height: ScreenAdapter.height(90),
                                  margin: EdgeInsets.only(
                                      right: ScreenAdapter.width(35)),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 0, 162, 147),
                                    border: Border.all(
                                        color: ColorsUtil.hexToColor("#090909"),
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Center(
                                    //加上Center让文字居中
                                    child: Text(
                                      '中文',
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(36.0),
                                          color: ColorsUtil.hexToColor("#F9F9F9"),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            //SizedBox(width:ScreenAdapter.width(35)),
                            if (controller.machineLanguages_EN.value == true)
                              InkWell(
                                onTap: () {
                                  if (controller.dining_type.value == "1" ||
                                      controller.dining_type.value == "2") {
                                    var mealType =
                                        (controller.dining_type.value == "2")
                                            ? true
                                            : false;
                                    var jumpUrl =
                                        (controller.menu_direction.value == "1")
                                            ? '/menu-page'
                                            : '/menuzong-page';

                                    Get.toNamed(jumpUrl, arguments: {
                                      "checkLanguage": "EN",
                                      "mealType": mealType
                                    });
                                  } else {
                                    _showSelectMealTypeDialog(
                                        "EN", controller.menu_direction.value);
                                  }
                                },
                                child: Container(
                                  width: ScreenAdapter.width(217),
                                  height: ScreenAdapter.height(90),
                                  margin: EdgeInsets.only(
                                      right: ScreenAdapter.width(35)),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 0, 162, 147),
                                    border: Border.all(
                                        color: ColorsUtil.hexToColor("#090909"),
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Center(
                                    //加上Center让文字居中
                                    child: Text(
                                      'English',
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(36.0),
                                          color: ColorsUtil.hexToColor("#F9F9F9"),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                            //SizedBox(width:ScreenAdapter.width(35)),
                            if (controller.machineLanguages_KO.value == true)
                              InkWell(
                                onTap: () {
                                  if (controller.dining_type.value == "1" ||
                                      controller.dining_type.value == "2") {
                                    var mealType =
                                        (controller.dining_type.value == "2")
                                            ? true
                                            : false;
                                    var jumpUrl =
                                        (controller.menu_direction.value == "1")
                                            ? '/menu-page'
                                            : '/menuzong-page';

                                    Get.toNamed(jumpUrl, arguments: {
                                      "checkLanguage": "KO",
                                      "mealType": mealType
                                    });
                                  } else {
                                    _showSelectMealTypeDialog(
                                        "KO", controller.menu_direction.value);
                                  }
                                  //Get.toNamed("/mw-test");
                                },
                                child: Container(
                                  width: ScreenAdapter.width(217),
                                  height: ScreenAdapter.height(90),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 0, 162, 147),
                                    border: Border.all(
                                        color: ColorsUtil.hexToColor("#090909"),
                                        width: 1.0),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Center(
                                    //加上Center让文字居中
                                    child: Text(
                                      '한국말',
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(36.0),
                                          color: ColorsUtil.hexToColor("#F9F9F9"),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
          
                      ],
                    ),
                  ),
                  Positioned(
                  right: ScreenAdapter.width(0),
                  top: ScreenAdapter.height(20),
                  child: InkWell(
                    onLongPress: () {
                      Get.toNamed('/middlewaresettingpage', arguments: {
                        "machineCode": controller.machineCode.value
                      });
                    },
                    child: Container(
                      height: ScreenAdapter.height(150),
                      width: ScreenAdapter.width(200),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(
                          top: ScreenAdapter.height(20),
                          left: ScreenAdapter.width(20),
                          right: ScreenAdapter.width(20),
                          bottom: ScreenAdapter.height(20)),
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
                ],
              )
              
            )),
          
          );
        },
      )
    );
  }
}
