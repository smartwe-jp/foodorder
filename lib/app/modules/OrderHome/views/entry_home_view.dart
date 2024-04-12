import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/modules/OrderHome/controllers/order_home_controller.dart';
import 'package:foodorder/app/modules/OrderHome/views/components/BookingTypeButton.dart';
import 'package:foodorder/app/modules/OrderHome/views/components/CatagoryButton.dart';
import 'package:foodorder/app/modules/OrderHome/views/components/LanguageButton.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';
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

  languageSelectView() {
    final languages = [
      {
        "language": "JP",
        "selected": controller.machineLanguages_JP.value,
        "icon": AssetImage("assets/images/public/shopping_car.png"),
      },
      {
        "language": "CH",
        "selected": controller.machineLanguages_CH.value,
        "icon": AssetImage("assets/images/public/shopping_car.png"),
      },
      {
        "language": "EN",
        "selected": controller.machineLanguages_EN.value,
        "icon": AssetImage("assets/images/public/shopping_car.png"),
      },
      {
        "language": "KO",
        "selected": controller.machineLanguages_KO.value,
        "icon": AssetImage("assets/images/public/shopping_car.png"),
      }
    ];

    final buttonList = languages.map((e) {
      return LanguageButton(
        icon: e["icon"] as ImageProvider,
        title: e["language"] as String,
        selected: false,
        onTap: () {
          if (controller.dining_type.value == "1" ||
              controller.dining_type.value == "2") {
            var mealType = (controller.dining_type.value == "2") ? true : false;
            var jumpUrl = (controller.menu_direction.value == "1")
                ? '/menu-page'
                : '/menuzong-page';

            Get.toNamed(jumpUrl,
                arguments: {"checkLanguage": e["language"], "mealType": mealType});
          } else {
            _showSelectMealTypeDialog(e["language"], controller.menu_direction.value);
          }
        },
      );
    }).toList();

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(
        top: ScreenAdapter.height(20),
        left: ScreenAdapter.width(70),
        right: ScreenAdapter.width(70),
        bottom: ScreenAdapter.height(20),
      ),
      child:
       GridMenuView(
        children: buttonList,
        crossAxisCount: 4,
        mainAxisSpacing: ScreenAdapter.width(20),
        crossAxisSpacing: ScreenAdapter.height(20),
        childAspectRatio: 3,
      )
       
       
    );
  }

  settingButton() {
    return Positioned(
      right: ScreenAdapter.width(0),
      top: ScreenAdapter.height(20),
      child: InkWell(
        onLongPress: () {
          Get.toNamed('/middlewaresettingpage',
              arguments: {"machineCode": controller.machineCode.value});
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
    );
  }

  catagoryGridView() {
    final catagory = ["推荐", "拉面", "蔬菜", "酒", "甜品", "更多"];
    final buttonList = catagory
        .map(
          (e) => CatagoryButton(
            icon: AssetImage("assets/images/public/shopping_car.png"),
            title: e,
            onTap: () {
              print("点击了$e");
            },
          ),
        )
        .toList();

    return GridMenuView(
      children: buttonList,
      mainAxisSpacing: ScreenAdapter.width(50),
      crossAxisSpacing: ScreenAdapter.height(50),
      childAspectRatio: 0.9,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: GetBuilder<OrderHomeController>(
      builder: (controller) {
        return controller.obx(
          (state) => AnnotatedRegion(
            value: SystemUiOverlayStyle.light,
            child: Center(
              child: Stack(children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/images/gongcha/home3.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: ScreenAdapter.width(70),
                            ),
                            Expanded(
                              child: BookingTypeButton(
                                icon: AssetImage(
                                    "assets/images/public/shopping_car.png"),
                                title: "堂食",
                                selected: true,
                                onTap: () {},
                              ),
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(70),
                            ),
                            Expanded(
                              child: BookingTypeButton(
                                icon: AssetImage(
                                    "assets/images/public/shopping_car.png"),
                                title: "外带",
                                selected: false,
                                onTap: () {},
                              ),
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(70),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 7,
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(
                            top: ScreenAdapter.height(70),
                            left: ScreenAdapter.width(70),
                            right: ScreenAdapter.width(70),
                            bottom: ScreenAdapter.height(70),
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 235, 233, 233),
                          ),
                          child: catagoryGridView(),
                        )),
                    Expanded(
                      flex: 2,
                      child: languageSelectView(),
                    ),
                  ],
                ),
                settingButton(),
              ]),
            ),
          ),
        );
      },
    ));
  }
}
