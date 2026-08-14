import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/machine_activation.dart';

class MachineActivationLocalService {
  static const int schemaVersion = 3;
  static const String cacheKey = 'machine_activation_cache';

  static const String _legacyPaymentKey = 'smartwe_machineActivateData';
  static const String _legacyLanguagesKey = 'smartwe_machineLanguages';
  static const String _legacyHomeImagesKey = 'smartwe_homeImages';
  static const String _legacyHeaderImagesKey = 'smartwe_headerImages';
  static const String _legacyLogoKey = 'smartwe_logoImage';
  static const String _legacyReimburseKey = 'smartwe_reimburse';
  static const String _legacyShopCodeKey = 'smartwe_shopCode';
  static const String _legacyMachineSettingKey = 'machineSettingData';
  static const String _legacyMachineModelKey = 'smartwe_machineType';

  Future<MachineActivation?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final rawCache = preferences.getString(cacheKey);
    final cached = _readCurrentCache(rawCache);
    if (cached != null) {
      if (_readSchemaVersion(rawCache) != schemaVersion) {
        await _writeCurrentCache(preferences, cached);
      }
      return cached;
    }

    final migrated = _readLegacyCache(preferences);
    if (migrated == null) return null;

    await _writeCurrentCache(preferences, migrated);
    return migrated;
  }

  Future<void> save(MachineActivation activation) async {
    final preferences = await SharedPreferences.getInstance();
    await _writeCurrentCache(preferences, activation);

    // Keep the legacy projection during the migration window. Existing pages
    // and a downgraded app can continue reading the old keys safely.
    await Future.wait([
      preferences.setString(
          _legacyPaymentKey, json.encode(activation.toLegacyPaymentJson())),
      preferences.setString(
          _legacyLanguagesKey, json.encode(activation.languages)),
      preferences.setString(
          _legacyHomeImagesKey, json.encode(activation.homeImages)),
      preferences.setString(
          _legacyHeaderImagesKey, json.encode(activation.headerImages)),
      preferences.setString(_legacyLogoKey, activation.logoImage),
      preferences.setString(
          _legacyReimburseKey, activation.canReimburse ? '1' : '0'),
      preferences.setString(_legacyShopCodeKey, activation.shopCode),
      preferences.setString(_legacyMachineSettingKey,
          json.encode(activation.toLegacyMachineSettingJson())),
      preferences.setString(
          _legacyMachineModelKey, activation.machineModelCode),
    ]);
  }

  MachineActivation? _readCurrentCache(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return null;
    try {
      final envelope = _decodeMap(rawValue);
      final version = envelope['schemaVersion'];
      if (version is! int || version < 1 || version > schemaVersion)
        return null;
      return MachineActivation.fromJson(_asMap(envelope['data']));
    } catch (_) {
      return null;
    }
  }

  MachineActivation? _readLegacyCache(SharedPreferences preferences) {
    final rawValues = <String?>[
      preferences.getString(_legacyPaymentKey),
      preferences.getString(_legacyLanguagesKey),
      preferences.getString(_legacyHomeImagesKey),
      preferences.getString(_legacyHeaderImagesKey),
      preferences.getString(_legacyLogoKey),
      preferences.getString(_legacyReimburseKey),
      preferences.getString(_legacyShopCodeKey),
      preferences.getString(_legacyMachineSettingKey),
      preferences.getString(_legacyMachineModelKey),
    ];
    if (rawValues.every((value) => value == null)) return null;

    return MachineActivation.fromLegacy(
      paymentData: _decodeMapOrEmpty(rawValues[0]),
      languages: _decodeListOrEmpty(rawValues[1]),
      homeImages: _decodeListOrEmpty(rawValues[2]),
      headerImages: _decodeListOrEmpty(rawValues[3]),
      logoImage: rawValues[4] ?? '',
      reimburse: rawValues[5] ?? '0',
      shopCode: rawValues[6] ?? '',
      machineSettingData: _decodeMapOrEmpty(rawValues[7]),
      machineModelCode: rawValues[8] ?? '',
    );
  }

  int? _readSchemaVersion(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) return null;
    try {
      return _decodeMap(rawValue)['schemaVersion'] as int?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCurrentCache(
    SharedPreferences preferences,
    MachineActivation activation,
  ) async {
    await preferences.setString(
      cacheKey,
      json.encode({
        'schemaVersion': schemaVersion,
        'savedAt': DateTime.now().toUtc().toIso8601String(),
        'data': activation.toJson(),
      }),
    );
  }

  Map<String, dynamic> _decodeMap(String value) {
    return _asMap(json.decode(value));
  }

  Map<String, dynamic> _decodeMapOrEmpty(String? value) {
    if (value == null || value.isEmpty) return {};
    try {
      return _decodeMap(value);
    } catch (_) {
      return {};
    }
  }

  List<dynamic> _decodeListOrEmpty(String? value) {
    if (value == null || value.isEmpty) return const [];
    try {
      final decoded = json.decode(value);
      return decoded is List ? decoded : const [];
    } catch (_) {
      return const [];
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const FormatException('Expected a JSON object');
  }
}
