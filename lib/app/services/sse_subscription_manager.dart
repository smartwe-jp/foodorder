import 'package:foodorder/app/config/http_conf.dart';
import 'package:foodorder/app/models/sse_subscription_setting.dart';
import 'package:foodorder/app/services/HomeServices.dart';
import 'package:foodorder/app/services/sse_service.dart';
import 'package:get/get.dart';

class SseSubscriptionManager extends GetxService {
  SseService get _sseService => Get.find<SseService>();
  final RxList<SseSubscriptionSetting> settings =
      <SseSubscriptionSetting>[].obs;

  String _machineCode = '';

  Future<void> initialize(String machineCode) async {
    _machineCode = machineCode.trim();
    final stored = await HomeServices.getSSESettingList();
    final migrated = normalizeStoredSettings(stored, machineCode: _machineCode);
    settings.assignAll(migrated);
    await _save();
  }

  static List<SseSubscriptionSetting> normalizeStoredSettings(
    Iterable<dynamic> stored, {
    required String machineCode,
  }) {
    final normalized = <SseSubscriptionSetting>[];
    final keys = <String>{};

    for (final raw in stored) {
      final setting = SseSubscriptionSetting.fromJson(
        raw,
        machineCode: machineCode,
      );
      if (setting != null && keys.add(setting.key)) {
        normalized.add(setting);
      }
    }

    final smartWeIndex = normalized.indexWhere(
      (item) => item.type == SseSubscriptionType.smartWe,
    );
    if (smartWeIndex < 0) {
      normalized.insert(
        0,
        SseSubscriptionSetting(
          type: SseSubscriptionType.smartWe,
          identify: machineCode.trim(),
        ),
      );
    } else if (smartWeIndex > 0) {
      final smartWe = normalized.removeAt(smartWeIndex);
      normalized.insert(0, smartWe);
    }
    return normalized;
  }

  Future<bool> add(SseSubscriptionType type, {String identify = ''}) async {
    final normalizedIdentify =
        type == SseSubscriptionType.smartWe ? _machineCode : identify.trim();
    if (normalizedIdentify.isEmpty) return false;

    final candidate = SseSubscriptionSetting(
      type: type,
      identify: normalizedIdentify,
    );
    if (settings.any((item) => item.key == candidate.key)) return false;

    settings.add(candidate);
    await _save();
    return true;
  }

  Future<bool> update(
    String key, {
    String? identify,
    bool? isEnabled,
    bool? centerOn,
    bool? printOption,
    bool? printSeat,
  }) async {
    final index = settings.indexWhere((item) => item.key == key);
    if (index < 0) return false;

    final current = settings[index];
    final nextIdentify = current.type == SseSubscriptionType.smartWe
        ? _machineCode
        : (identify ?? current.identify).trim();
    if (nextIdentify.isEmpty) return false;

    final updated = current.copyWith(
      identify: nextIdentify,
      isEnabled: isEnabled,
      centerOn: centerOn,
      printOption: printOption,
      printSeat: printSeat,
    );
    if (updated.key != key && settings.any((item) => item.key == updated.key)) {
      return false;
    }

    final oldUrl = urlFor(current);
    settings[index] = updated;
    await _save();

    if (current.isEnabled &&
        (!updated.isEnabled || oldUrl != urlFor(updated))) {
      await _sseService.disconnect(oldUrl);
    }
    if (updated.isEnabled) await _sseService.addSseListen(urlFor(updated));
    return true;
  }

  Future<bool> remove(String key) async {
    final index = settings.indexWhere((item) => item.key == key);
    if (index < 0 || settings[index].type == SseSubscriptionType.smartWe) {
      return false;
    }

    final removed = settings.removeAt(index);
    await _save();
    if (removed.isEnabled) await _sseService.disconnect(urlFor(removed));
    return true;
  }

  Future<void> startEnabledSubscriptions() async {
    final desiredUrls =
        settings.where((item) => item.isEnabled).map(urlFor).toSet();
    final activeUrls = _sseService.subscriptions.keys.whereType<String>().toList();
    for (final activeUrl in activeUrls) {
      if (!desiredUrls.contains(activeUrl)) {
        await _sseService.disconnect(activeUrl);
      }
    }
    for (final url in desiredUrls) {
      await _sseService.addSseListen(url);
    }
  }

  bool? connectionStatus(SseSubscriptionSetting setting) {
    final status = _sseService.subscriptions[urlFor(setting)];
    return status is bool ? status : null;
  }

  String urlFor(SseSubscriptionSetting setting) {
    final base = servicePath[setting.serverKey];
    if (base == null || base.isEmpty) {
      throw StateError('Missing SSE endpoint: ${setting.serverKey}');
    }
    return '$base${Uri.encodeComponent(setting.identify)}';
  }

  Future<void> _save() => HomeServices.setSSESettingList(
        settings.map((item) => item.toJson()).toList(),
      );
}
