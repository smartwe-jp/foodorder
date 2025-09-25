import 'package:get/get.dart';

class GFont {
  static String getFontFamily() {
    var locale = Get.locale;
    switch (locale?.languageCode) {
      case 'zh':
        return 'NotoSansCN';
      case 'ko':
        return 'NotoSansKR';
      case 'en':
        return 'NotoSans';
      default:
        return 'NotoSansJP';
    }
  }

}