import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/services/scale_serial_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('persists scale port and serial parameters across service instances',
      () async {
    final first = ScaleSerialService();
    await first.savePortName('COM7');
    await first.saveParams(ScaleSerialParams.andFactory);

    final restored = ScaleSerialService();
    expect(await restored.loadSavedPortName(), 'COM7');
    expect(
      (await restored.loadSavedParams()).id,
      ScaleSerialParams.andFactory.id,
    );
  });

  test('restores Android USB port when its transient device path changes',
      () async {
    const oldPort = 'usb|1412|45136|A123|/dev/bus/usb/001/002|1002';
    const currentPort = 'usb|1412|45136|A123|/dev/bus/usb/002/008|2008';
    final service = ScaleSerialService();
    await service.savePortName(oldPort);
    service.portsRx.add(currentPort);

    expect(
      await service.restoreSavedPortName(refresh: false),
      currentPort,
    );
    expect(await service.loadSavedPortName(), currentPort);
  });
}
