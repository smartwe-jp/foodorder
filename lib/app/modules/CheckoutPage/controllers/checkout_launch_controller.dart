
// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:foodorder/app/config/string.dart';
// import 'package:foodorder/app/controllers/machine_info_controller.dart';
// import 'package:foodorder/app/services/HomeServices.dart';
// import 'package:foodorder/app/services/HttpService.dart';
// import 'package:foodorder/app/widget/DialogUtils.dart';
// import 'package:get/get.dart';

// class CheckoutLaunchController extends GetxController with StateMixin {

//   MachineInfoController machineInfo = Get.find();

//   bool machineLanguages_JP = false;
//   bool machineLanguages_CH = false;
//   bool machineLanguages_EN = false;
//   bool machineLanguages_KO = false;

  
//   bool startShake = false;
//   bool isAnimating = false;

//   RxList categoryList = [].obs;

//   get takeOut => machineInfo.diningType == "2" || machineInfo.diningType == "3";

//   int mealTypeStatus = 0;
//   int resetTime = 30;
//   Timer? resetTimer;

//   String selectLanguage = 'JP';

//   @override
//   void onInit() {
//     super.onInit();
//     // Initialize any necessary data or services here
//     getMenchineLanguages();
//     startRepeatingAnimation();
//   }

//   @override
//   void onReady() {
//     super.onReady();
//     // Perform any actions needed when the controller is ready
//   }

//   @override
//   void onClose() {
//     // Clean up resources or subscriptions here
    
//     super.onClose();
//   }

//   getMenchineLanguages() async {
//     debugPrint("获取机器语言");

//     machineLanguages_JP = machineInfo.supportLanguages.contains('JP');
//     machineLanguages_CH = machineInfo.supportLanguages.contains('CH');
//     machineLanguages_EN = machineInfo.supportLanguages.contains('EN');
//     machineLanguages_KO = machineInfo.supportLanguages.contains('KO');
//     debugPrint("获取机器语言结束");
//     //update();
//     change(null, status: RxStatus.success());
//   }

//   updateSettingLanguage(String language) async {
//     print(" updateSetting Language = $language");
//     await HomeServices.updateSettingLanguage(language);
//     selectLanguage = language;
//     var locale = Locale('${language.toLowerCase()}', '$language');
//     Get.updateLocale(locale);
//     //reload catagory...
//     //await getBookingBootIndexCagegory();
//   }

//   void startRepeatingAnimation() {
//     debugPrint('startRepeatingAnimation');
//     isAnimating = true;
//     Timer.periodic(Duration(milliseconds: 1200), (timer) {
//       if (!isAnimating) {
//         timer.cancel();
//         return;
//       }
//       startShake = !startShake;
//       update();
//     });
//   }

//   void stopRepeatingAnimation() {
//     debugPrint('stopRepeatingAnimation');
//     isAnimating = false;
//     startShake = false;
//     update();
//   }

//     get showCatagory {
//     if (categoryList.length == 0) {
//       debugPrint("homeList.length == 0");
//       return [];
//     }
//     debugPrint("homeList.length > 0");

//     int showItemCount = 6;

//     if (categoryList.length >= showItemCount - 1) {
//       // 获取前8个
//       var newList = List.from(categoryList.sublist(0, showItemCount - 1));
//       newList.add({
//         "categoryCode": categoryList.first["categoryCode"],
//         "image": null,
//         "categoryName": GString.getToString(selectLanguage, "more_title"),
//         "showType": "1"
//       });
//       return newList;
//     } else {
//       var newList = List.from(categoryList);
//       newList.add({
//         "categoryCode": categoryList.first["categoryCode"],
//         "image": null,
//         "categoryName": GString.getToString(selectLanguage, "more_title"),
//         "showType": "1"
//       });
//       return newList;
//     }
//   }

//   updateDingType(int type) async {
//     debugPrint("updateDingType $type");
//     startResetTimer(); // Restart the timer when updating the dining type
//     mealTypeStatus = type;
//     update();

//     //await getBookingBootIndexCagegory(); // Uncommenting to fetch categories after updating the dining type
//   }

//   startResetTimer() async {
//     debugPrint("startResetTimer");
//     resetTimer?.cancel();
//     resetTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
//       resetTime--;
//       if (resetTime == 0) {
//         resetTimer?.cancel();
//         resetTime = 30;
//         mealTypeStatus = 0;
//         debugPrint("startResetTimer end");
//         update();
//       }
//     });
//   }

//   goMenu(String lan, bool mealType) {
//     machineInfo.mealType = mealType;
//     var jumpUrl =
//         (machineInfo.menu_direction == "1") ? '/menu-page' : '/menuzong-page';
//     startShake = false;
//     Get.toNamed(jumpUrl,
//         arguments: {"checkLanguage": lan, "mealType": mealType});
//   }

//   getBookingBootIndexCagegory() async {
//     debugPrint("获取页面分类");

//     var formData = {
//       "machineCode": machineInfo.machineCode,
//       "language": selectLanguage,
//       "takeout": "0",
//     };
//     request('webBootIndexCategoryv2', method: 'POST', parameters: formData)
//         .then((val) {
//       var response = json.decode(val.toString());
//       //isLoading.value = false;
//       if (response['code'] == 200) {
//         List myList = response['data']['categoryVoList'];
//         categoryList.clear();
//         for (var i = 0; i < myList.length; i++) {
//           //if(menuIndex >=5) menuIndex = 0;
//           var categoryVoList = myList[i];
//           //配置顶部菜单
//           categoryList.add({
//             "categoryCode": categoryVoList['categoryCode'],
//             "categoryName": categoryVoList['categoryName'],
//             "showType": categoryVoList['showType'],
//             "image": categoryVoList['image'],
//             "color": categoryVoList['color'],
//           });
//         }
//         update();
//         change(null, status: RxStatus.success());
//       } else {
//         //showToast(response['msg']);
//         Get.dialog(DialogUtils.alertOneButton(response['msg'],
//             title: GString.getToString(selectLanguage, "tag_title"),
//             confirmtitle: GString.getToString(selectLanguage, "tag_button_yes"),
//             confirm: () {
//           getBookingBootIndexCagegory();
//         }));
//         Future.delayed(Duration(milliseconds: 2000), () {
//           getBookingBootIndexCagegory();
//         });

//         //Get.back();
//       }
//     });
//   }

// }