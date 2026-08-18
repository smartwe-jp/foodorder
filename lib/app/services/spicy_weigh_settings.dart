import 'Storage.dart';

/// 麻辣烫称重相关本地设置（手动输入、皮重、满额赠送、最低额度、盆号扫码、十位取整）
class SpicyWeighSettings {
  static const String manualInputKey = 'spicy_weigh_manual_input';
  static const String tareGramsKey = 'spicy_weigh_tare_g';
  static const String giftThresholdYenKey = 'spicy_weigh_gift_threshold_yen';
  static const String minAmountYenKey = 'spicy_weigh_min_amount_yen';
  static const String bowlScanKey = 'spicy_weigh_bowl_scan';
  static const String floorToTensKey = 'spicy_weigh_floor_to_tens';

  /// 是否在称重页显示「手动输入」按钮
  static Future<bool> loadManualAllowed() async {
    final v = await Storage.getString(manualInputKey);
    return v == '1';
  }

  static Future<void> saveManualAllowed(bool allowed) async {
    await Storage.setString(manualInputKey, allowed ? '1' : '0');
  }

  /// 是否开启称重页「扫盆边二维码/条码」，扫到的盆号带到下单 tableNo
  static Future<bool> loadBowlScanEnabled() async {
    final v = await Storage.getString(bowlScanKey);
    return v == '1';
  }

  static Future<void> saveBowlScanEnabled(bool enabled) async {
    await Storage.setString(bowlScanKey, enabled ? '1' : '0');
  }

  /// 是否开启「十位向下取整」：进菜单后称重金额个位作 discount（与扫码优惠累加）
  static Future<bool> loadFloorToTensEnabled() async {
    final v = await Storage.getString(floorToTensKey);
    return v == '1';
  }

  static Future<void> saveFloorToTensEnabled(bool enabled) async {
    await Storage.setString(floorToTensKey, enabled ? '1' : '0');
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

  /// 称重菜品满额赠送门槛（日元）。0＝关闭；赠送菜品由菜单管理后台配置。
  static Future<int> loadGiftThresholdYen() async {
    final v = await Storage.getString(giftThresholdYenKey);
    if (v == null || v.isEmpty) return 0;
    return int.tryParse(v) ?? 0;
  }

  static Future<void> saveGiftThresholdYen(int yen) async {
    final y = yen < 0 ? 0 : yen;
    await Storage.setString(giftThresholdYenKey, y.toString());
  }

  /// 称重最低额度（日元）。重量×单价须 ≥ 该值才可下一步选汤底；0＝不限制。
  static Future<int> loadMinAmountYen() async {
    final v = await Storage.getString(minAmountYenKey);
    if (v == null || v.isEmpty) return 0;
    return int.tryParse(v) ?? 0;
  }

  static Future<void> saveMinAmountYen(int yen) async {
    final y = yen < 0 ? 0 : yen;
    await Storage.setString(minAmountYenKey, y.toString());
  }
}
