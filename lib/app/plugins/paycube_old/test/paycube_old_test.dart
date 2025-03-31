import 'package:flutter_test/flutter_test.dart';
import 'package:paycube_old/paycube_old.dart';
import 'package:paycube_old/paycube_old_platform_interface.dart';
import 'package:paycube_old/paycube_old_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPaycubeOldPlatform
    with MockPlatformInterfaceMixin
    implements PaycubeOldPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final PaycubeOldPlatform initialPlatform = PaycubeOldPlatform.instance;

  test('$MethodChannelPaycubeOld is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPaycubeOld>());
  });

  test('getPlatformVersion', () async {
    PaycubeOld paycubeOldPlugin = PaycubeOld();
    MockPaycubeOldPlatform fakePlatform = MockPaycubeOldPlatform();
    PaycubeOldPlatform.instance = fakePlatform;

    expect(await paycubeOldPlugin.getPlatformVersion(), '42');
  });
}
