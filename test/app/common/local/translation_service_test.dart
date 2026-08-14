import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/common/local/en_US.dart';
import 'package:foodorder/app/common/local/ja_JP.dart';
import 'package:foodorder/app/common/local/ko_KR.dart';
import 'package:foodorder/app/common/local/translation_service.dart';
import 'package:foodorder/app/common/local/vi_VN.dart';
import 'package:foodorder/app/common/local/zh_CN.dart';

void main() {
  test('registers a complete Vietnamese translation map', () {
    expect(TranslationService().keys['vi_VN'], same(vi_VN));
    final existingKeys = {
      ...ja_JP.keys,
      ...zh_CN.keys,
      ...en_US.keys,
      ...ko_KR.keys,
    };
    expect(vi_VN.keys, containsAll(existingKeys));
    expect(vi_VN['order_start'], 'Đặt món');
    expect(vi_VN['settlement_button'], 'Thanh toán');
    expect(vi_VN['activation_error_tips'], isNotEmpty);
  });
}
