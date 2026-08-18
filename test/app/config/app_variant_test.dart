import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/config/app_variant.dart';

void main() {
  const expectedVariant = String.fromEnvironment('EXPECTED_APP_VARIANT');

  test('reads the selected compile-time app variant', () {
    expect(AppVariantConfig.name, expectedVariant);
    expect(AppVariantConfig.isAndroid7, expectedVariant == 'android7');
    expect(AppVariantConfig.isAndroid11, expectedVariant == 'android11');
    expect(AppVariantConfig.isWindows, expectedVariant == 'windows');
    expect(AppVariantConfig.ensureValid, returnsNormally);
  });
}
