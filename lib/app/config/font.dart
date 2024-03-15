

import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class GFont {
  static String getFontFamily() {
    var locale = Get.locale;
    switch (locale?.languageCode) {
      case 'zh':
        return 'NotoSansCN';
      case 'kr':
        return 'NotoSansKR';
      case 'en':
        return 'NotoSans';
      default:
        return 'NotoSansJP';
    }
  }

}