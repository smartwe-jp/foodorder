import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/models/sse_subscription_setting.dart';
import 'package:foodorder/app/services/sse_subscription_manager.dart';

void main() {
  group('SSE settings migration', () {
    test('migrates old settings and replaces SmartWe identify', () {
      final settings = SseSubscriptionManager.normalizeStoredSettings(
        [
          {
            'name': 'SmartWe SSE',
            'server': 'sseSubscribeSmartWe',
            'identify': 'OLD_MACHINE',
            'isOn': true,
            'centerOn': true,
          },
          {
            'name': 'Panda SSE',
            'server': 'sseSubscribePanda',
            'identify': 'PANDA_1',
            'isOn': '1',
          },
        ],
        machineCode: 'CURRENT_MACHINE',
      );

      expect(settings, hasLength(2));
      expect(settings.first.type, SseSubscriptionType.smartWe);
      expect(settings.first.identify, 'CURRENT_MACHINE');
      expect(settings.first.isEnabled, isTrue);
      expect(settings.first.centerOn, isTrue);
      expect(settings.last.type, SseSubscriptionType.panda);
      expect(settings.last.identify, 'PANDA_1');
      expect(settings.last.isEnabled, isTrue);
    });

    test('supports multiple Panda ids and removes duplicates', () {
      final settings = SseSubscriptionManager.normalizeStoredSettings(
        [
          {'type': 'panda', 'identify': '100'},
          {'type': 'panda', 'identify': '200'},
          {'type': 'panda', 'identify': '100'},
        ],
        machineCode: 'MACHINE',
      );

      expect(
        settings.where((item) => item.type == SseSubscriptionType.panda)
            .map((item) => item.identify),
        ['100', '200'],
      );
    });

    test('ignores malformed and empty legacy Panda entries', () {
      final settings = SseSubscriptionManager.normalizeStoredSettings(
        [
          null,
          'invalid',
          {'name': 'Panda SSE', 'identify': '', 'isOn': true},
          {'name': 'unknown', 'identify': '123'},
        ],
        machineCode: 'MACHINE',
      );

      expect(settings, hasLength(1));
      expect(settings.single.type, SseSubscriptionType.smartWe);
      expect(settings.single.isEnabled, isFalse);
    });

    test('writes versioned settings with legacy compatibility fields', () {
      const setting = SseSubscriptionSetting(
        type: SseSubscriptionType.panda,
        identify: 'PANDA_1',
        isEnabled: true,
      );

      expect(setting.toJson(), containsPair('schemaVersion', 2));
      expect(setting.toJson(), containsPair('type', 'panda'));
      expect(setting.toJson(), containsPair('name', 'Panda SSE'));
      expect(setting.toJson(), containsPair('server', 'sseSubscribePanda'));
      expect(setting.toJson(), containsPair('needInput', true));
    });
  });
}
