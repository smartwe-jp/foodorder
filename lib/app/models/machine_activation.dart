import 'dart:convert';

class MachineActivationResponse {
  const MachineActivationResponse({
    required this.code,
    required this.hasData,
    required this.activation,
    this.message = '',
  });

  final int code;
  final bool hasData;
  final String message;
  final MachineActivation? activation;

  factory MachineActivationResponse.fromPayload(dynamic payload) {
    final json = _asMap(payload);
    final data = json['data'];
    final code = _asInt(json['code']);
    return MachineActivationResponse(
      code: code,
      hasData: data != null,
      message: _asString(json['message']),
      activation: data == null || code != 200
          ? null
          : MachineActivation.fromRemoteJson(_asMap(data)),
    );
  }
}

class MachineLanguage {
  const MachineLanguage({
    required this.code,
    required this.name,
  });

  static const japanese = MachineLanguage(code: 'JP', name: '日本語');

  final String code;
  final String name;

  factory MachineLanguage.fromJson(dynamic value) {
    if (value is String) {
      final code = value.trim().toUpperCase();
      return MachineLanguage(code: code, name: _fallbackLanguageName(code));
    }

    final json = _asMapOrEmpty(value);
    final code = _asString(json['val']).trim().toUpperCase();
    final name = _asString(json['name']).trim();
    return MachineLanguage(
      code: code,
      name: name.isEmpty ? _fallbackLanguageName(code) : name,
    );
  }

  Map<String, dynamic> toJson() => {
        'val': code,
        'name': name,
      };
}

class MachineActivation {
  const MachineActivation({
    required this.machineModelCode,
    required this.shopCode,
    required this.paymentChannels,
    required this.languageOptions,
    required this.homeImages,
    required this.headerImages,
    required this.logoImage,
    required this.canReimburse,
    required this.lineup,
    required this.actuarial,
    required this.taxSystem,
    required this.cashMachineWithdraw,
  });

  final String machineModelCode;
  final String shopCode;
  final MachinePaymentChannels paymentChannels;
  final List<MachineLanguage> languageOptions;
  List<String> get languages =>
      languageOptions.map((language) => language.code).toList(growable: false);
  final List<String> homeImages;
  final List<String> headerImages;
  final String logoImage;
  final bool canReimburse;
  final bool lineup;
  final bool actuarial;
  final bool taxSystem;
  final bool cashMachineWithdraw;

  factory MachineActivation.fromRemoteJson(Map<String, dynamic> json) {
    return MachineActivation(
      machineModelCode: _asString(json['machineType']),
      shopCode: _asString(json['shopCode']),
      paymentChannels: MachinePaymentChannels.fromRemoteJson(
          _asMapOrEmpty(json['linePayChannelMap'])),
      languageOptions: _asMachineLanguages(json['languages']),
      homeImages: _asStringList(json['homeImages']),
      headerImages: _asStringList(json['headerImages']),
      logoImage: _asString(json['logoImage']),
      canReimburse: _asBool(json['reimburse']),
      lineup: _asBool(json['lineup']),
      actuarial: _asBool(json['actuarial']),
      taxSystem: _asBool(json['taxSystem']),
      cashMachineWithdraw: _asBool(json['cashMachineWithdraw']),
    );
  }

  factory MachineActivation.fromJson(Map<String, dynamic> json) {
    return MachineActivation(
      machineModelCode: _asString(json['machineModelCode']),
      shopCode: _asString(json['shopCode']),
      paymentChannels: MachinePaymentChannels.fromJson(
          _asMapOrEmpty(json['paymentChannels'])),
      languageOptions: _asMachineLanguages(json['languages']),
      homeImages: _asStringList(json['homeImages']),
      headerImages: _asStringList(json['headerImages']),
      logoImage: _asString(json['logoImage']),
      canReimburse: _asBool(json['canReimburse']),
      lineup: _asBool(json['lineup']),
      actuarial: _asBool(json['actuarial']),
      taxSystem: _asBool(json['taxSystem']),
      cashMachineWithdraw: _asBool(json['cashMachineWithdraw']),
    );
  }

  factory MachineActivation.fromLegacy({
    required Map<String, dynamic> paymentData,
    required Map<String, dynamic> machineSettingData,
    required List<dynamic> languages,
    required List<dynamic> homeImages,
    required List<dynamic> headerImages,
    required String logoImage,
    required String reimburse,
    required String shopCode,
    String machineModelCode = '',
  }) {
    return MachineActivation(
      machineModelCode: machineModelCode,
      shopCode: shopCode,
      paymentChannels: MachinePaymentChannels.fromLegacyJson(paymentData),
      languageOptions: _asMachineLanguages(languages),
      homeImages: _asStringList(homeImages),
      headerImages: _asStringList(headerImages),
      logoImage: logoImage,
      canReimburse: _asBool(reimburse),
      lineup: _asBool(machineSettingData['machineLineup']),
      actuarial: _asBool(machineSettingData['machineActuarial']),
      taxSystem: _asBool(paymentData['taxSystem']),
      cashMachineWithdraw: _asBool(paymentData['cashMachineWithdraw']),
    );
  }

  Map<String, dynamic> toJson() => {
        'machineModelCode': machineModelCode,
        'shopCode': shopCode,
        'paymentChannels': paymentChannels.toJson(),
        'languages': languageOptions
            .map((language) => language.toJson())
            .toList(growable: false),
        'homeImages': homeImages,
        'headerImages': headerImages,
        'logoImage': logoImage,
        'canReimburse': canReimburse,
        'lineup': lineup,
        'actuarial': actuarial,
        'taxSystem': taxSystem,
        'cashMachineWithdraw': cashMachineWithdraw,
      };

  Map<String, dynamic> toLegacyPaymentJson() => {
        ...paymentChannels.toLegacyJson(),
        'taxSystem': taxSystem,
        'cashMachineWithdraw': cashMachineWithdraw,
      };

  Map<String, dynamic> toLegacyMachineSettingJson() => {
        'machineLineup': lineup,
        'machineActuarial': actuarial,
      };
}

class MachinePaymentChannels {
  const MachinePaymentChannels({
    required this.cash,
    required this.wechat,
    required this.alipay,
    required this.payPay,
    required this.creditCard,
    required this.auPay,
    required this.dPay,
    required this.rPay,
    required this.mPay,
    required this.edy,
    required this.iD,
    required this.ic,
    required this.quicPay,
    required this.waon,
    required this.nanaco,
    required this.visa,
    required this.master,
    required this.jcb,
    required this.unionPay,
    required this.americanExpress,
    required this.dinersClub,
    required this.discover,
  });

  final bool cash;
  final bool wechat;
  final bool alipay;
  final bool payPay;
  final bool creditCard;
  final bool auPay;
  final bool dPay;
  final bool rPay;
  final bool mPay;
  final bool edy;
  final bool iD;
  final bool ic;
  final bool quicPay;
  final bool waon;
  final bool nanaco;
  final bool visa;
  final bool master;
  final bool jcb;
  final bool unionPay;
  final bool americanExpress;
  final bool dinersClub;
  final bool discover;

  factory MachinePaymentChannels.fromRemoteJson(Map<String, dynamic> json) {
    return MachinePaymentChannels(
      cash: _asBool(json['Cash']),
      wechat: _asBool(json['Wechat']),
      alipay: _asBool(json['Alipay']),
      payPay: _asBool(json['PayPay']),
      creditCard: _asBool(json['POS']),
      auPay: _asBool(json['au_Pay']),
      dPay: _asBool(json['d_Pay']),
      rPay: _asBool(json['R_Pay']),
      mPay: _asBool(json['m_Pay']),
      edy: _asBool(json['Edy']),
      iD: _asBool(json['iD']),
      ic: _asBool(json['IC']),
      quicPay: _asBool(json['QUICPay']),
      waon: _asBool(json['WAON']),
      nanaco: _asBool(json['nanaco']),
      visa: _asBool(json['VISA']),
      master: _asBool(json['MASTER']),
      jcb: _asBool(json['JCB']),
      unionPay: _asBool(json['UnionPay']),
      americanExpress: _asBool(json['AMERICAN_EXPRESS']),
      dinersClub: _asBool(json['Diners_Club']),
      discover: _asBool(json['Discover']),
    );
  }

  factory MachinePaymentChannels.fromJson(Map<String, dynamic> json) {
    return MachinePaymentChannels(
      cash: _asBool(json['cash']),
      wechat: _asBool(json['wechat']),
      alipay: _asBool(json['alipay']),
      payPay: _asBool(json['payPay']),
      creditCard: _asBool(json['creditCard']),
      auPay: _asBool(json['auPay']),
      dPay: _asBool(json['dPay']),
      rPay: _asBool(json['rPay']),
      mPay: _asBool(json['mPay']),
      edy: _asBool(json['edy']),
      iD: _asBool(json['iD']),
      ic: _asBool(json['ic']),
      quicPay: _asBool(json['quicPay']),
      waon: _asBool(json['waon']),
      nanaco: _asBool(json['nanaco']),
      visa: _asBool(json['visa']),
      master: _asBool(json['master']),
      jcb: _asBool(json['jcb']),
      unionPay: _asBool(json['unionPay']),
      americanExpress: _asBool(json['americanExpress']),
      dinersClub: _asBool(json['dinersClub']),
      discover: _asBool(json['discover']),
    );
  }

  factory MachinePaymentChannels.fromLegacyJson(Map<String, dynamic> json) {
    return MachinePaymentChannels(
      cash: _asBool(json['showCash']),
      wechat: _asBool(json['showWechat']),
      alipay: _asBool(json['showAlipay']),
      payPay: _asBool(json['showPayPay']),
      creditCard: _asBool(json['showCreditCard']),
      auPay: _asBool(json['au_Pay']),
      dPay: _asBool(json['d_Pay']),
      rPay: _asBool(json['R_Pay']),
      mPay: _asBool(json['m_Pay']),
      edy: _asBool(json['pos_Edy']),
      iD: _asBool(json['pos_iD']),
      ic: _asBool(json['pos_IC']),
      quicPay: _asBool(json['pos_QUICPay']),
      waon: _asBool(json['pos_WAON']),
      nanaco: _asBool(json['pos_nanaco']),
      visa: _asBool(json['show_visa']),
      master: _asBool(json['show_master']),
      jcb: _asBool(json['show_jcb']),
      unionPay: _asBool(json['show_unionPay']),
      americanExpress: _asBool(json['show_americanExpress']),
      dinersClub: _asBool(json['show_dinersClub']),
      discover: _asBool(json['show_discover']),
    );
  }

  Map<String, dynamic> toJson() => {
        'cash': cash,
        'wechat': wechat,
        'alipay': alipay,
        'payPay': payPay,
        'creditCard': creditCard,
        'auPay': auPay,
        'dPay': dPay,
        'rPay': rPay,
        'mPay': mPay,
        'edy': edy,
        'iD': iD,
        'ic': ic,
        'quicPay': quicPay,
        'waon': waon,
        'nanaco': nanaco,
        'visa': visa,
        'master': master,
        'jcb': jcb,
        'unionPay': unionPay,
        'americanExpress': americanExpress,
        'dinersClub': dinersClub,
        'discover': discover,
      };

  Map<String, dynamic> toLegacyJson() => {
        'showCash': cash,
        'showWechat': wechat,
        'showAlipay': alipay,
        'showPayPay': payPay,
        'showCreditCard': creditCard,
        'au_Pay': auPay,
        'd_Pay': dPay,
        'R_Pay': rPay,
        'm_Pay': mPay,
        'pos_Edy': edy,
        'pos_iD': iD,
        'pos_IC': ic,
        'pos_QUICPay': quicPay,
        'pos_WAON': waon,
        'pos_nanaco': nanaco,
        'show_visa': visa,
        'show_master': master,
        'show_jcb': jcb,
        'show_unionPay': unionPay,
        'show_americanExpress': americanExpress,
        'show_dinersClub': dinersClub,
        'show_discover': discover,
      };
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is String) {
    final decoded = json.decode(value);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected a JSON object');
}

Map<String, dynamic> _asMapOrEmpty(dynamic value) {
  try {
    return _asMap(value);
  } catch (_) {
    return {};
  }
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<String>().toList(growable: false);
}

List<MachineLanguage> _asMachineLanguages(dynamic value) {
  if (value is! List) return const [];

  final languages = <MachineLanguage>[];
  final seenCodes = <String>{};
  for (final item in value) {
    final language = MachineLanguage.fromJson(item);
    if (language.code.isEmpty || !seenCodes.add(language.code)) continue;
    languages.add(language);
  }
  return List.unmodifiable(languages);
}

String _fallbackLanguageName(String code) {
  switch (code) {
    case 'JP':
      return '日本語';
    case 'CH':
      return '中文';
    case 'EN':
      return 'English';
    case 'KO':
      return '한국어';
    default:
      return code;
  }
}

String _asString(dynamic value) => value is String ? value : '';

int _asInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return false;
}
