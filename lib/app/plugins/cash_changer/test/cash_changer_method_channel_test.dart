import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cash_changer/cash_changer_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelCashChanger platform = MethodChannelCashChanger();
  const MethodChannel channel = MethodChannel('cash_changer');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        if (methodCall.method == 'setSixDigitDispenseAmount') return 0;
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });

  test('setSixDigitDispenseAmount', () async {
    expect(await platform.setSixDigitDispenseAmount(), 0);
  });
}
