import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'en_US.dart';
import 'ko_KR.dart';
import 'zh_CN.dart';
import 'ja_JP.dart';

class TranslationService extends Translations {
  static Locale? get locale => Get.deviceLocale;
  static const fallbackLocale = Locale('ja', 'JP');

  @override
  Map<String, Map<String, String>> get keys => {
        'zh_CN': zh_CN,
        'en_US': en_US,
        'ko_KR': ko_KR,
        'ja_JP': ja_JP,
      };
}
