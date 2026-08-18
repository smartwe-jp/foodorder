import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/config/app_environment.dart';
import 'package:foodorder/app/config/http_conf.dart';

void main() {
  const expectedEnvironment = String.fromEnvironment('EXPECTED_APP_ENV');

  test('reads the selected compile-time environment', () {
    expect(AppEnvironmentConfig.name, expectedEnvironment);
    expect(
      AppEnvironmentConfig.isDevelopment,
      expectedEnvironment == 'dev',
    );
    expect(
      AppEnvironmentConfig.isProduction,
      expectedEnvironment == 'prod',
    );
    expect(
      base_url,
      expectedEnvironment == 'prod'
          ? 'https://api.smartwe.jp/'
          : 'https://sit-api.smartwe.jp/',
    );
    expect(AppEnvironmentConfig.ensureValid, returnsNormally);
  });
}
