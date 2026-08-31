import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/controllers/machine_info.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../../OrderHome/views/widgets/BookingTypeButton.dart';
import '../../OrderHome/views/widgets/languageButton.dart';
import '../controllers/checkout_page_controller.dart';

class CheckoutPageView extends GetView<CheckoutPageController> {
  CheckoutPageView({Key? key}) : super(key: key);

  Widget _buildLanguageSelector() {
    final languages = controller.supportedLanguages;

    if (languages.length <= 1) {
      return const SizedBox.shrink();
    }

    final buttonList = languages.map((language) {
      return LanguageButton(
        title: language.name,
        selected: language.code == controller.selectLanguage,
        startColor: controller.themeColor,
        textColor: controller.themeTextColor,
        onTap: () => controller.updateSettingLanguage(language.code),
      );
    }).toList();
    return Container(
        alignment: Alignment.center,
        height: ScreenAdapter.height(100),
        margin: EdgeInsets.only(
          left: ScreenAdapter.width(30),
          right: ScreenAdapter.width(30),
        ),
        padding: EdgeInsets.only(
          top: ScreenAdapter.height(20),
          left: ScreenAdapter.width(30),
          right: ScreenAdapter.width(30),
          bottom: ScreenAdapter.height(20),
        ),
        child: Row(
          spacing: 16,
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
      spacing: 50.w,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
            title:
                buttonCount == 1 ? 'order_start'.tr : 'menu_dingtype_eatin'.tr,
            selected: true,
            onTap: () {
              controller.startDiningOrder(takeout: false);
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
        if (controller.machineInfo.isCheckOn &&
            controller.machineInfo.actuarial)
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
        if (controller.machineInfo.isTakeoutOn)
          BookingTypeButton(
            width: _getItemWidth(),
            bgColor: controller.themeColor,
            textColor: controller.themeTextColor,
            icon: Icon(
              Icons.shopping_bag,
              color: controller.themeTextColor,
              size: 120,
            ),
            title: buttonCount == 1
                ? 'order_start'.tr
                : 'menu_dingtype_takeout'.tr,
            selected: buttonCount == 1,
            onTap: () {
              controller.startDiningOrder(takeout: true);
            },
          ),
      ],
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
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
                                        controller.confirmColorSetting(
                                            controller.themeColor);
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
                      child: _buildLanguageSelector()),
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
