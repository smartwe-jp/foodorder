// import 'dart:math';
// import 'dart:ui';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:foodorder/app/config/color.dart';
// import 'package:foodorder/app/config/font.dart';
// import 'package:foodorder/app/config/string.dart';
// import 'package:foodorder/app/modules/OrderHome/controllers/order_home_controller.dart';
// import 'package:foodorder/app/modules/OrderHome/views/components/BookingTypeButton.dart';
// import 'package:foodorder/app/modules/OrderHome/views/components/CatagoryButton.dart';
// import 'package:foodorder/app/modules/OrderHome/views/components/LanguageButton.dart';
// import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';
// import 'package:get/get.dart';
// import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
// import '../../../config/colorsUtil.dart';
// import '../../../config/imageData.dart';
// import '../../../services/ScreenAdapter.dart';
// //import 'SelectDiningMethod.dart';
//
// class EntryHomeView extends GetView<OrderHomeController> {
//   final OrderHomeController controller = Get.put(OrderHomeController());
//   EntryHomeView({Key? key}) : super(key: key);
//
//   // _showSelectMealTypeDialog(checkedLanguage, menu_direction) async {
//   //   Get.dialog(SelectDiningMethodPage(
//   //     checkLanguage: checkedLanguage,
//   //     dining_type: controller.machineInfo.diningType,
//   //     menu_direction: controller.menu_direction.value,
//   //     onConfrimClick:
//   //         (bool mealType, String dining_type_num, String menuDirection) {
//   //       var jumpUrl = (controller.menu_direction.value == "1")
//   //           ? '/menu-page'
//   //           : '/menuzong-page';
//
//   //       Get.toNamed(jumpUrl, arguments: {
//   //         "checkLanguage": checkedLanguage,
//   //         "mealType": mealType
//   //       });
//   //     },
//   //   ));
//   // }
//
//   _catagoryLoading() {
//     return Center(
//       // 使用CircularProgressIndicator创建旋转进度条
//       child: CircularProgressIndicator(
//         strokeWidth: 10, // 设置进度条的粗细
//         backgroundColor: Colors.grey[300], // 进度条的背景颜色
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // 进度条的前景色
//       ),
//     );
//   }
//
//   _showEasyLoading(text) {
//     var _showTag;
//     _showTag = Text(text,
//         style: TextStyle(
//           fontSize: ScreenAdapter.fontSize(25),
//           fontFamily: GFont.getFontFamily(),
//           fontWeight: FontWeight.w600,
//           color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
//         ));
//     EasyLoading.show(
//       //status: 'loading...',
//       indicator: Container(
//         width: ScreenAdapter.width(550),
//         height: ScreenAdapter.height(480),
//         padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
//         child: InkWell(
//             onLongPress: () {
//               EasyLoading.dismiss();
//             },
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 _showTag,
//                 Container(
//                   //width: ScreenAdapter.width(400),
//                   margin: EdgeInsets.only(top: 60),
//                   height: ScreenAdapter.height(200),
//                   child: Image.asset(
//                       GImage.getImageString("imgpublic", "printticketloading"),
//                       fit: BoxFit.fitHeight),
//                 ),
//               ],
//             )),
//       ),
//       maskType: EasyLoadingMaskType.black,
//     );
//   }
//
//   languageSelectView() {
//     List languages = [];
//     if (controller.machineLanguages_JP == true)
//       languages.add({
//         "language": "JP",
//         "text": "日本語",
//         "selected": controller.machineLanguages_JP,
//         "icon": AssetImage("assets/images/public/language_Japanese.png"),
//       });
//
//     if (controller.machineLanguages_CH == true)
//       languages.add({
//         "language": "CH",
//         "text": "中文",
//         "selected": controller.machineLanguages_CH,
//         "icon": AssetImage("assets/images/public/language_Chinese.png"),
//       });
//
//     if (controller.machineLanguages_EN == true)
//       languages.add({
//         "language": "EN",
//         "text": "English",
//         "selected": controller.machineLanguages_EN,
//         "icon": AssetImage("assets/images/public/language_English.png"),
//       });
//
//     if (controller.machineLanguages_KO == true)
//       languages.add({
//         "language": "KO",
//         "text": "한국어",
//         "selected": controller.machineLanguages_KO,
//         "icon": AssetImage("assets/images/public/language_Korean.png"),
//       });
//
//     final buttonList = languages.map((e) {
//       return LanguageButton(
//         icon: e["icon"] as ImageProvider,
//         title: e["text"] as String,
//         selected: e["language"] == controller.settingLanguage.value,
//         onTap: () {
//           controller.updateSettingLanguage(e["language"] as String);
//         },
//       );
//     }).toList();
//
//     return Container(
//         alignment: Alignment.center,
//         height: ScreenAdapter.height(100),
//         padding: EdgeInsets.only(
//           top: ScreenAdapter.height(20),
//           left: ScreenAdapter.width(30),
//           right: ScreenAdapter.width(30),
//           bottom: ScreenAdapter.height(20),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [...buttonList],
//         )
//         );
//   }
//
//   settingButton() {
//     return Positioned(
//       right: ScreenAdapter.width(0),
//       top: ScreenAdapter.height(20),
//       child: InkWell(
//         onLongPress: () {
//           Get.toNamed('/middlewaresettingpage',
//               arguments: {"machineCode": controller.machineInfo.machineCode});
//         },
//         child: Container(
//           height: ScreenAdapter.height(150),
//           width: ScreenAdapter.width(200),
//           alignment: Alignment.centerRight,
//           padding: EdgeInsets.only(
//               top: ScreenAdapter.height(20),
//               left: ScreenAdapter.width(20),
//               right: ScreenAdapter.width(20),
//               bottom: ScreenAdapter.height(20)),
//           child: Center(
//             //加上Center让文字居中
//             child: Text(
//               "",
//               style: TextStyle(
//                   fontSize: ScreenAdapter.fontSize(48.0),
//                   color: ColorsUtil.hexToColor("#F9F9F9"),
//                   fontWeight: FontWeight.w600),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   get eatInShopImage => controller.mealTypeStatus == 1
//       ? AssetImage("assets/images/public/eat_in_on.png")
//       : AssetImage("assets/images/public/eat_in_off.png");
//
//   get eatOutImage => controller.mealTypeStatus == 2
//       ? AssetImage("assets/images/public/eat_out_on.png")
//       : AssetImage("assets/images/public/eat_out_off.png");
//
//   ImageProvider _catagroyImage(String url) {
//     if (url.isEmpty) {
//       return AssetImage("assets/images/public/app_viewmore_icon.png");
//     } else {
//       return CachedNetworkImageProvider(url, errorListener: (error) {
//         controller.logger.info('-- CachedNetworkImageProvider Error : $error --');
//       },);
//     }
//   }
//
//   catagoryGridView() {
//     List<Widget> buttonList = controller.showCatagory
//         .map<Widget>(
//           (e) => CatagoryButton(
//             icon: _catagroyImage(e['image'] ?? ""),
//             title: e["categoryName"] ?? "",
//             onTap: () async {
//               controller.resetTimer?.cancel();
//               controller.mealTypeStatus = 0;
//               // var mealType = controller.machineInfo.mealType ||
//               //     controller.machineInfo.diningType == "2";
//
//               var jumpUrl = (controller.menu_direction.value == "1")
//                   ? '/menu-page'
//                   : '/menuzong-page';
//
//               final result = await Get.toNamed(jumpUrl, arguments: {
//                 "classTag": e["categoryCode"] ?? "",
//                 //"menuList": controller.homeList,
//                 "checkLanguage": controller.settingLanguage.value,
//                 //"mealType": mealType
//               });
//               if (result == true) {
//                 controller.mealTypeStatus = 0;
//                 controller.getBookingBootIndexCagegory();
//               }
//             },
//           ),
//         )
//         .toList();
//
//     return Stack(children: [
//       Container(
//         padding: EdgeInsets.only(
//           top: ScreenAdapter.height(70),
//           left: ScreenAdapter.width(70),
//           right: ScreenAdapter.width(70),
//           bottom: ScreenAdapter.height(70),
//         ),
//         child: GridMenuView(
//           children: buttonList,
//           mainAxisSpacing: ScreenAdapter.width(50),
//           crossAxisSpacing: ScreenAdapter.height(50),
//           childAspectRatio: 0.9,
//         ),
//       ),
//       if (controller.machineInfo.diningType == "3" && controller.mealTypeStatus == 0)
//         ClipRect(
//             child: Stack(
//           children: [
//             BackdropFilter(
//               filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color.fromARGB(50, 0, 0, 0),
//                 ),
//               ),
//             ),
//
//             Container(
//               padding: EdgeInsets.only(
//                 left: ScreenAdapter.width(30),
//                 right: ScreenAdapter.width(30)
//               ),
//               child: Center(
//               child:
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       SizedBox(width: ScreenAdapter.width(150),),
//                       Transform.rotate(
//                       angle: pi / 6,
//                       child:
//                       Container(
//                         width: ScreenAdapter.height(150),
//                         height: ScreenAdapter.height(150),
//                         decoration: BoxDecoration(
//                           image: DecorationImage(
//                             image: AssetImage("assets/images/public/finger_touch.png"),
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ))
//
//                     ],
//                   ),
//
//                   Text(GString.getToString(Get.locale?.languageCode.toUpperCase() ?? "JP", "dining_welcome"),
//                         style: TextStyle(
//                           fontSize: ScreenAdapter.fontSize(80),
//                           fontFamily: GFont.getFontFamily(),
//                           fontWeight: FontWeight.w600,
//                           color: const Color.fromARGB(255, 23, 106, 67),
//                         )),
//
//                   SizedBox(height: 20,),
//
//                   Text(GString.getToString(Get.locale?.languageCode.toUpperCase() ?? "JP", "dining_type_tips"),
//                         style: TextStyle(
//                           fontSize: ScreenAdapter.fontSize(56),
//                           fontFamily: GFont.getFontFamily(),
//                           fontWeight: FontWeight.w600,
//                           color: const Color.fromARGB(255, 23, 106, 67),
//                         )),
//                 ],
//               )
//
//               ),
//             )
//           ],
//         )),
//     ]);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: GetBuilder<OrderHomeController>(
//       builder: (controller) {
//         return controller.obx(
//           (state) => AnnotatedRegion(
//             value: SystemUiOverlayStyle.light,
//             child: Center(
//               child: Stack(children: [
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Container(
//                       height: ScreenAdapter.height(400),
//                       alignment: Alignment.center,
//                       child: Swiper(
//                         //itemHeight: 200,
//                         itemBuilder: (BuildContext context, int index) {
//                           // 配置图片地址
//                           return Container(
//                             decoration: BoxDecoration(
//                               //color: Colors.green,
//                               image: DecorationImage(
//                                 image: CachedNetworkImageProvider(
//                                     controller.homeImages.value[index] ?? ""),
//                                 fit: BoxFit.cover,
//                               ),
//                             ),
//                             //child: publicShowMenuImage(imgPath:item['homeImageHttp'], imgWidth:350.0, imgHeight:350.0,subTitle:item["subtitle"]),
//                           );
//                         },
//                         // 配置图片数量
//                         itemCount: controller.homeImages.value.length,
//                         // 底部分页器
//                         //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
//                         // 左右箭头
//                         //control: new SwiperControl(),
//                         // 无限循环
//                         loop: (controller.homeImages.value.length > 1)
//                             ? true
//                             : false,
//                         duration: 1000,
//                         autoplayDelay: 12000,
//                         // 自动轮播
//                         autoplay: (controller.homeImages.value.length > 1)
//                             ? true
//                             : false,
//                       ),
//                     ),
//
//                     // if (controller.dining_type.value == "3" && !controller.isSelect.value)
//                     // SizedBox(
//                     //   height: ScreenAdapter.height(70),
//                     // ),
//
//                     if (controller.machineInfo.diningType == "3")
//                       Expanded(
//                         flex: 3,
//                         child: Container(
//                           decoration:
//                           BoxDecoration(
//                             color: controller.mealTypeStatus == 0 ? Color.fromARGB(50, 0, 0, 0) : Color.fromARGB(0, 0, 0, 0),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(
//                                 width: ScreenAdapter.width(70),
//                               ),
//                               Expanded(
//                                 child: BookingTypeButtonOld(
//                                   icon: eatInShopImage,
//                                   title: GString.getToString(
//                                       controller.settingLanguage.value,
//                                       "in_shop"),
//                                   selected: controller.mealTypeStatus == 1,
//                                   onTap: () {
//                                     controller.updateDingType(1);
//                                   },
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: ScreenAdapter.height(70),
//                               ),
//                               Expanded(
//                                 child: BookingTypeButtonOld(
//                                   icon: eatOutImage,
//                                   title: GString.getToString(
//                                       controller.settingLanguage.value,
//                                       "take_out"),
//                                   selected: controller.mealTypeStatus == 2,
//                                   onTap: () {
//                                     controller.updateDingType(2);
//                                   },
//                                 ),
//                               ),
//                               SizedBox(
//                                 width: ScreenAdapter.width(70),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     //if (controller.dining_type.value != "3" || controller.isSelect.value)
//                     Expanded(
//                         flex: 7,
//                         child: Container(
//                           alignment: Alignment.center,
//                           decoration: BoxDecoration(
//                             color: Color.fromARGB(255, 243, 243, 243),
//                           ),
//                           child: controller.isLoading.value
//                               ? _catagoryLoading()
//                               : catagoryGridView(),
//                         )),
//                     Expanded(
//                       flex: 2,
//                       child: languageSelectView(),
//                     ),
//                   ],
//                 ),
//                 settingButton(),
//               ]),
//             ),
//           ),
//         );
//       },
//     ));
//   }
// }
