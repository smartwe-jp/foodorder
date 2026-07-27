abstract final class AppEnvironmentConfig {
  static const String defineKey = 'APP_ENV';
  static const String name = String.fromEnvironment(defineKey);

  static const bool isDevelopment = name == 'dev';
  static const bool isProduction = name == 'prod';

  static void ensureValid() {
    if (!isDevelopment && !isProduction) {
      throw StateError(
        'APP_ENV must be explicitly set to "dev" or "prod". '
        'Use the project run scripts instead of running Flutter directly.',
      );
    }
  }
}
