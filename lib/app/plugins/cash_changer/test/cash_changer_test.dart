import 'package:flutter_test/flutter_test.dart';
import 'package:cash_changer/cash_changer.dart';
import 'package:cash_changer/cash_changer_platform_interface.dart';
import 'package:cash_changer/cash_changer_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCashChangerPlatform
    with MockPlatformInterfaceMixin
    implements CashChangerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final CashChangerPlatform initialPlatform = CashChangerPlatform.instance;

  test('$MethodChannelCashChanger is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelCashChanger>());
  });

  test('getPlatformVersion', () async {
    CashChanger cashChangerPlugin = CashChanger();
    MockCashChangerPlatform fakePlatform = MockCashChangerPlatform();
    CashChangerPlatform.instance = fakePlatform;

    expect(await cashChangerPlugin.getPlatformVersion(), '42');
  });
}
