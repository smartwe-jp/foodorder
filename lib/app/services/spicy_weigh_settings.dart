import 'Storage.dart';

/// 麻辣烫称重相关本地设置（手动输入开关、皮重）
class SpicyWeighSettings {
  static const String manualInputKey = 'spicy_weigh_manual_input';
  static const String tareGramsKey = 'spicy_weigh_tare_g';

  /// 是否在称重页显示「手动输入」按钮
  static Future<bool> loadManualAllowed() async {
    final v = await Storage.getString(manualInputKey);
    return v == '1';
  }

  static Future<void> saveManualAllowed(bool allowed) async {
    await Storage.setString(manualInputKey, allowed ? '1' : '0');
  }

  /// 皮重（克），默认 0
  static Future<double> loadTareGrams() async {
    final v = await Storage.getString(tareGramsKey);
    if (v == null || v.isEmpty) return 0;
    return double.tryParse(v) ?? 0;
  }

  static Future<void> saveTareGrams(double grams) async {
    final g = grams < 0 ? 0.0 : grams;
    await Storage.setString(tareGramsKey, g.toString());
  }

  /// 净重 = max(0, 毛重 - 皮重)
  static double netGrams(double grossGrams, double tareGrams) {
    final net = grossGrams - tareGrams;
    return net < 0 ? 0 : net;
  }
}
