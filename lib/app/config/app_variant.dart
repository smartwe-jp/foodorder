abstract final class AppVariantConfig {
  static const String defineKey = 'APP_VARIANT';

  // Keep Android 7 as the compatibility default until CD explicitly passes
  // APP_VARIANT for all three artifacts.
  static const String name = String.fromEnvironment(
    defineKey,
    defaultValue: 'android7',
  );

  static const bool isAndroid7 = name == 'android7';
  static const bool isAndroid11 = name == 'android11';
  static const bool isWindows = name == 'windows';

  static void ensureValid() {
    if (!isAndroid7 && !isAndroid11 && !isWindows) {
      throw StateError(
        'APP_VARIANT must be "android7", "android11", or "windows". '
        'Use a variant run script instead of running Flutter directly.',
      );
    }
  }
}
