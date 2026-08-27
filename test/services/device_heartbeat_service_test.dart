import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/services/device_heartbeat_service.dart';

void main() {
  test('emits immediately and keeps dashboard fields stable', () {
    final events = <Map<String, Object?>>[];
    final service = DeviceHeartbeatService(
      interval: const Duration(minutes: 1),
      emitter: events.add,
    );

    service.startOrUpdate(
      shopName: '',
      logoImageUrl: 'https://example.jp/logo.png',
      machineType: 'SWF1',
    );
    service.stop();

    expect(events, hasLength(1));
    expect(events.single['shop_name'], '');
    expect(events.single['logo_image_url'], 'https://example.jp/logo.png');
    expect(events.single['machine_type'], 'SWF1');
    expect(events.single['device_status'], 'online');
    expect(events.single['heartbeat_interval_seconds'], 60);
  });

  test('updating device data emits the latest values without another timer',
      () {
    final events = <Map<String, Object?>>[];
    final service = DeviceHeartbeatService(
      interval: const Duration(minutes: 1),
      emitter: events.add,
    );

    service.startOrUpdate(
      shopName: '',
      logoImageUrl: 'https://example.jp/old.png',
      machineType: 'SWF1',
    );
    service.startOrUpdate(
      shopName: '',
      logoImageUrl: 'https://example.jp/new.png',
      machineType: 'SWF2',
    );
    service.stop();

    expect(events, hasLength(2));
    expect(events.last['logo_image_url'], 'https://example.jp/new.png');
    expect(events.last['machine_type'], 'SWF2');
  });
}
