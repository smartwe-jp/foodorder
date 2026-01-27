import 'package:animated_widgets/widgets/scale_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/controllers/machine_info.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../../OrderHome/views/widgets/BookingTypeButton.dart';
import '../../OrderHome/views/widgets/languageButton.dart';
import '../controllers/checkout_page_controller.dart';
import 'Appointment.dart';
import 'ScanCode.dart';

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

    if (languages.length == 1) {
      return SizedBox.shrink();
    }

    final buttonList = languages.map((e) {
      return LanguageButton(
        icon: e["icon"] as ImageProvider,
        title: e["text"] as String,
        startColor: controller.themeColor,
        textColor: controller.themeTextColor, //e["language"] == controller.checkLanguage.value,
        onTap: () {
          controller.updateSettingLanguage(e["language"] as String);
        },
      );
    }).toList();

    return Container(
        alignment: Alignment.center,
        height: ScreenAdapter.height(100),
        margin: EdgeInsets.only(
          left: ScreenAdapter.width(40),
          right: ScreenAdapter.width(40),
        ),
        padding: EdgeInsets.only(
          top: ScreenAdapter.height(20),
          left: ScreenAdapter.width(30),
          right: ScreenAdapter.width(30),
          bottom: ScreenAdapter.height(20),
        ),
        child: 
        Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [...buttonList],
        ));
  }



  int get buttonCount => controller.machineInfo.machineModeInfo.entries
      .map((e) {
        if (e.key == 'checkout') {
          return e.value && controller.machineInfo.actuarial;
        } else {
          return e.value;
        }
      })
      .where((value) => value == true)
      .length;

  double _getItemWidth() {
    int trueCount = buttonCount;
    if (trueCount == 1) return 600.0;
    if (trueCount == 2) return 440.0;
    if (trueCount == 3) return 280.0;
    return 400.0;
  }

  _diningSelectArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: ScreenAdapter.width(50),
        ),

        if (controller.machineInfo.isSellOn)
          BookingTypeButton(
            width: _getItemWidth(),
            bgColor: controller.themeColor,
            textColor: controller.themeTextColor,
            icon: Icon(
              Icons.dining,
              color: controller.themeTextColor,
              size: 120,
            ),
            title:  buttonCount == 1 ? 'order_start'.tr : 'menu_dingtype_eatin'.tr,
            selected: true,
            onTap: () {
              controller.machineInfo.currentMode = MachineMode.sell;
              controller.goMenu(controller.selectLanguage);
            },
          ),

        if (controller.machineInfo.isScanbuyOn)
          BookingTypeButton(
            width: _getItemWidth(),
            bgColor: controller.themeColor,
            textColor: controller.themeTextColor,
            icon: Icon(
              Icons.barcode_reader,
              color: controller.themeTextColor,
              size: 120,
            ),
            title: 'settlement_button'.tr,
            selected: buttonCount == 1,
            onTap: () {
              controller.machineInfo.currentMode = MachineMode.scan;
              controller.goMenu(controller.selectLanguage);
            },
          ),

        if (controller.machineInfo.isCheckOn && controller.machineInfo.actuarial)
        ...[
          SizedBox(width: ScreenAdapter.width(50)),
          BookingTypeButton(
            width: _getItemWidth(),
            bgColor: controller.themeColor,
            textColor: controller.themeTextColor,
            icon: Icon(
              Icons.qr_code,
              color: controller.themeTextColor,
              size: 120,
            ),
            title: 'settlement_button'.tr,
            selected: buttonCount == 1,
            onTap: () {
              controller.machineInfo.currentMode = MachineMode.checkout;
              controller.goMenu(controller.selectLanguage);
            },
          ),
        ],

        if (controller.machineInfo.isTakeoutOn)
        ...[SizedBox(width: ScreenAdapter.width(50)),
          BookingTypeButton(
            width: _getItemWidth(),
            bgColor: controller.themeColor,
            textColor: controller.themeTextColor,
            icon: Icon(
              Icons.shopping_bag,
              color: controller.themeTextColor,
              size: 120,
            ),
            title: 'menu_dingtype_takeout'.tr,
            selected: buttonCount == 1,
            onTap: () {
              controller.machineInfo.currentMode = MachineMode.takeout;
              controller.goMenu(controller.selectLanguage);
            },
          ),
        ],

        // if (controller.machineInfo.isScanbuyOn)
        // Expanded(
        //   child: BookingTypeButton(
        //     icon: Icon(
        //       Icons.qr_code,
        //       color: Colors.blueGrey[100],
        //       size: 120,
        //     ),
        //     title: 'settlement_button'.localized(),
        //     selected: false,
        //     onTap: ()=>controller.goSelfCheckout(),
        //   ),
        // ),
        SizedBox(width: ScreenAdapter.width(50)),
      ],
    );
  }

  _startButton() {
    return
        // ScaleAnimatedWidget.tween(
        // enabled: controller.startShake,
        // duration: Duration(milliseconds: 500),
        // scaleDisabled: 0.9,
        // scaleEnabled: 1.0,
        // child:
        InkWell(
      onTap: () => controller.goMenu(controller.selectLanguage),
      child: Container(
        padding: EdgeInsets.all(10),
        height: ScreenAdapter.height(260),
        width: ScreenAdapter.width(600),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: controller.themeColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'order_start'.tr, //'settlement_button'.tr
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: controller.themeTextColor,
            fontSize: 80,
            fontFamily: GFont.getFontFamily(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      //),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<CheckoutPageController>(builder: (controller) {
        return controller.obx(
          (state) => AnnotatedRegion(
            value: SystemUiOverlayStyle.light,
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Swiper(
                    //itemHeight: 200,
                    itemBuilder: (BuildContext context, int index) {
                      // 配置图片地址
                      return publicShowMenuImage(
                          imgPath: controller.machineInfo.homeList[index],
                          imgWidth: 1080.0,
                          imgHeight: 1920.0);
                    },
                    // 配置图片数量
                    itemCount: controller.machineInfo.homeList.length,
                    // 底部分页器
                    //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
                    // 左右箭头
                    //control: new SwiperControl(),
                    // 无限循环
                    loop: (controller.machineInfo.homeList.length > 1)
                        ? true
                        : false,
                    duration: 1000,
                    autoplayDelay: 12000,
                    // 自动轮播
                    autoplay: (controller.machineInfo.homeList.length > 1)
                        ? true
                        : false,
                  ),
                ),
                Positioned(
                  left: ScreenAdapter.width(0),
                  top: ScreenAdapter.height(20),
                  child: InkWell(
                    onLongPress: () {
                      controller.preThemeColor = controller.themeColor;
                      showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('色彩選択'),
                            scrollable: true,
                            titlePadding: const EdgeInsets.all(20),
                            contentPadding: const EdgeInsets.all(20),
                            content: Column(
                              children: [
                                ColorPicker(
                                  pickerColor: controller.themeColor,
                                  onColorChanged: (color) {
                                    controller.updateThemeColor(color);
                                  },
                                  colorPickerWidth: 300,
                                  pickerAreaHeightPercent: 0.7,
                                  displayThumbColor: true,
                                  paletteType: PaletteType.hsvWithHue,
                                  labelTypes: const [],
                                  pickerAreaBorderRadius:
                                      const BorderRadius.only(
                                    topLeft: Radius.circular(2),
                                    topRight: Radius.circular(2),
                                  ),
                                  portraitOnly: true,
                                ),
                                
                                //confirm button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        controller.cancelColorSetting();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('キャンセル'.tr),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        controller.confirmColorSetting(controller.themeColor);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('確認'.tr),
                                    ),
                                  ],
                                ),
                                
                              ],
                            ),
                          );
                        },
                      );
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
                Positioned(
                  right: ScreenAdapter.width(0),
                  top: ScreenAdapter.height(20),
                  child: InkWell(
                    onLongPress: () {
                      Get.toNamed('/middlewaresettingpage', arguments: {
                        "machineCode": controller.machineInfo.machineCode
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
                Positioned(
                    bottom: ScreenAdapter.height(700),
                    child: Container(
                      width: ScreenAdapter.width(1080),
                      child: Column(
                        children: [
                          Text(
                            'menu_dingtype_title'.tr,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: controller
                                  .themeColor, //const Color.fromARGB(255, 53,59,80),
                              fontSize: buttonCount == 1 ? 80 : 60,
                              fontFamily: GFont.getFontFamily(),
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: controller.themeTextColor,
                                  offset: Offset(3.0, -4.0),
                                  blurRadius: 1.0,
                                ),
                              ],
                            ),
                          ),
                          if (buttonCount > 1)
                          Text(
                            'menu_ding_type_tips'.tr,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: controller
                                  .themeColor, //const Color.fromARGB(255, 53,59,80),
                              fontSize: 60,
                              fontFamily: GFont.getFontFamily(),
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: controller.themeTextColor,
                                  offset: Offset(3.0, -4.0),
                                  blurRadius: 1.0,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
                Positioned(
                  bottom: ScreenAdapter.height(350),
                  width: ScreenAdapter.width(1080),
                  child: Center(
                      child:
                          //controller.machineInfo.diningType == "3" ?
                          _diningSelectArea()
                      //: _startButton()

                      ),
                ),
                Positioned(
                  bottom: ScreenAdapter.height(100),
                  child: Container(
                      width: ScreenAdapter.width(1080),
                      height: ScreenAdapter.height(200),
                      child: languageSelectView()),
                ),
                // Positioned(
                //   bottom: ScreenAdapter.height(120),
                //   child: Container(
                //       width: ScreenAdapter.width(1080),
                //       child: Divider(
                //         height: 1,
                //         color: Colors.grey[300],
                //         indent: 50,
                //         endIndent: 50,
                //       )),
                // )
              ],
            ),
          ),
          onLoading: Center(
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: new AlwaysStoppedAnimation<Color>(
                  ColorsUtil.hexToColor("#80B646")),
            ),
          ),
        );
      }),
    );
  }
}
