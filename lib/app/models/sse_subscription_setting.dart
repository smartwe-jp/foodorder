enum SseSubscriptionType { smartWe, panda }

class SseSubscriptionSetting {
  const SseSubscriptionSetting({
    required this.type,
    required this.identify,
    this.isEnabled = false,
    this.centerOn = false,
    this.printOption = true,
    this.printSeat = true,
  });

  final SseSubscriptionType type;
  final String identify;
  final bool isEnabled;
  final bool centerOn;
  final bool printOption;
  final bool printSeat;

  String get key => '${type.storageValue}:$identify';
  String get name =>
      type == SseSubscriptionType.smartWe ? 'SmartWe SSE' : 'Panda SSE';
  String get serverKey => type == SseSubscriptionType.smartWe
      ? 'sseSubscribeSmartWe'
      : 'sseSubscribePanda';
  bool get needsIdentifyInput => type == SseSubscriptionType.panda;
  bool get needsCenterPrint => type == SseSubscriptionType.smartWe;

  SseSubscriptionSetting copyWith({
    String? identify,
    bool? isEnabled,
    bool? centerOn,
    bool? printOption,
    bool? printSeat,
  }) {
    return SseSubscriptionSetting(
      type: type,
      identify: identify ?? this.identify,
      isEnabled: isEnabled ?? this.isEnabled,
      centerOn: centerOn ?? this.centerOn,
      printOption: printOption ?? this.printOption,
      printSeat: printSeat ?? this.printSeat,
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': 2,
        'type': type.storageValue,
        // Keep legacy fields during the transition so a downgraded app can
        // still read the setting without crashing.
        'name': name,
        'server': serverKey,
        'identify': identify,
        'isOn': isEnabled,
        'needInput': needsIdentifyInput,
        'needCenterPrint': needsCenterPrint,
        'centerOn': centerOn,
        'printOption': printOption,
        'printSeat': printSeat,
      };

  /// Accepts both the current schema and the map stored by older app versions.
  static SseSubscriptionSetting? fromJson(
    dynamic value, {
    required String machineCode,
  }) {
    if (value is! Map) return null;

    final type = SseSubscriptionTypeParser.fromStoredValue(
      value['type'] ?? value['server'] ?? value['name'],
    );
    if (type == null) return null;

    final storedIdentify = _asString(value['identify']).trim();
    final identify = type == SseSubscriptionType.smartWe
        ? machineCode.trim()
        : storedIdentify;
    if (identify.isEmpty && type == SseSubscriptionType.panda) return null;

    return SseSubscriptionSetting(
      type: type,
      identify: identify,
      isEnabled: _asBool(value['isOn']),
      centerOn: _asBool(value['centerOn']),
      printOption: _asBool(value['printOption'], fallback: true),
      printSeat: _asBool(value['printSeat'], fallback: true),
    );
  }

  static String _asString(dynamic value) => value is String ? value : '';

  static bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return fallback;
  }
}

extension SseSubscriptionTypeParser on SseSubscriptionType {
  String get storageValue =>
      this == SseSubscriptionType.smartWe ? 'smartWe' : 'panda';

  String get displayName =>
      this == SseSubscriptionType.smartWe ? 'SmartWe SSE' : 'Panda SSE';

  static SseSubscriptionType? fromStoredValue(dynamic value) {
    if (value is! String) return null;
    switch (value.toLowerCase()) {
      case 'smartwe':
      case 'smartwe sse':
      case 'ssesubscribesmartwe':
        return SseSubscriptionType.smartWe;
      case 'panda':
      case 'panda sse':
      case 'ssesubscribepanda':
        return SseSubscriptionType.panda;
    }
    return null;
  }
}
