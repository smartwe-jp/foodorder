import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/models/machine_activation.dart';
import 'package:foodorder/app/models/machine_capabilities.dart';
import 'package:foodorder/app/repositories/machine_activation_repository.dart';
import 'package:foodorder/app/services/machine_activation_local_service.dart';
import 'package:foodorder/app/services/machine_activation_remote_service.dart';
import 'package:foodorder/app/services/machine_runtime_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => Directory.systemTemp.path,
    );
  });

  group('MachineActivationResponse', () {
    test('parses remote payload into a typed activation model', () {
      final response = MachineActivationResponse.fromPayload({
        'code': '200',
        'data': {
          'machineType': 'SWF1',
          'shopCode': 'shop-001',
          'linePayChannelMap': {
            'Cash': true,
            'Wechat': 1,
            'POS': '1',
            'Discover': false,
          },
          'languages': [
            {'val': 'JP', 'name': '日本語'},
            {'val': 'CH', 'name': '中文'},
            {'val': 'EN', 'name': 'English'},
            {'val': 'KO', 'name': '한국말'},
          ],
          'homeImages': ['home.png'],
          'headerImages': ['header.png'],
          'logoImage': 'logo.png',
          'reimburse': 1,
          'lineup': true,
          'actuarial': false,
          'taxSystem': 'true',
          'cashMachineWithdraw': 0,
        },
      });

      expect(response.code, 200);
      expect(response.activation?.machineModelCode, 'SWF1');
      expect(response.activation?.shopCode, 'shop-001');
      expect(response.activation?.paymentChannels.cash, isTrue);
      expect(response.activation?.paymentChannels.wechat, isTrue);
      expect(response.activation?.paymentChannels.creditCard, isTrue);
      expect(response.activation?.paymentChannels.alipay, isFalse);
      expect(response.activation?.canReimburse, isTrue);
      expect(response.activation?.taxSystem, isTrue);
      expect(response.activation?.cashMachineWithdraw, isFalse);
      expect(response.activation?.languages, ['JP', 'CH', 'EN', 'KO']);
      expect(
        response.activation?.languageOptions.map((item) => item.name),
        ['日本語', '中文', 'English', '한국말'],
      );
    });

    test('represents a missing activation without parsing data', () {
      final response = MachineActivationResponse.fromPayload({
        'code': 200,
        'data': null,
      });

      expect(response.hasData, isFalse);
      expect(response.activation, isNull);
    });
  });

  group('MachineActivationLocalService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('migrates legacy keys into the versioned cache', () async {
      SharedPreferences.setMockInitialValues({
        'smartwe_machineActivateData': json.encode({
          'showCash': true,
          'showPayPay': true,
          'show_visa': true,
          'taxSystem': true,
          'cashMachineWithdraw': true,
        }),
        'smartwe_machineLanguages': json.encode(['JP', 'EN']),
        'smartwe_homeImages': json.encode(['home.png']),
        'smartwe_headerImages': json.encode(['header.png']),
        'smartwe_logoImage': 'logo.png',
        'smartwe_reimburse': '1',
        'smartwe_shopCode': 'legacy-shop',
        'machineSettingData': json.encode({
          'machineLineup': true,
          'machineActuarial': true,
        }),
      });

      final activation = await MachineActivationLocalService().load();

      expect(activation?.shopCode, 'legacy-shop');
      expect(activation?.paymentChannels.cash, isTrue);
      expect(activation?.paymentChannels.payPay, isTrue);
      expect(activation?.paymentChannels.visa, isTrue);
      expect(activation?.languages, ['JP', 'EN']);
      expect(activation?.actuarial, isTrue);

      final preferences = await SharedPreferences.getInstance();
      final cache = json.decode(
        preferences.getString(MachineActivationLocalService.cacheKey)!,
      ) as Map<String, dynamic>;
      expect(
          cache['schemaVersion'], MachineActivationLocalService.schemaVersion);
      expect(cache['data']['shopCode'], 'legacy-shop');
    });

    test('prefers current cache over conflicting legacy values', () async {
      final service = MachineActivationLocalService();
      await service.save(_activation(shopCode: 'current-shop'));

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('smartwe_shopCode', 'stale-shop');

      final activation = await service.load();

      expect(activation?.shopCode, 'current-shop');
    });

    test('upgrades a version 1 cache without losing activation data', () async {
      SharedPreferences.setMockInitialValues({
        MachineActivationLocalService.cacheKey: json.encode({
          'schemaVersion': 1,
          'data': _activation(shopCode: 'version-1-shop').toJson()
            ..remove('machineModelCode'),
        }),
      });

      final activation = await MachineActivationLocalService().load();

      expect(activation?.shopCode, 'version-1-shop');
      expect(activation?.machineModelCode, isEmpty);
      final preferences = await SharedPreferences.getInstance();
      final upgraded = json.decode(
        preferences.getString(MachineActivationLocalService.cacheKey)!,
      ) as Map<String, dynamic>;
      expect(
        upgraded['schemaVersion'],
        MachineActivationLocalService.schemaVersion,
      );
    });

    test('upgrades a version 2 string-language cache', () async {
      final data = _activation(shopCode: 'version-2-shop').toJson();
      data['languages'] = ['JP', 'EN'];
      SharedPreferences.setMockInitialValues({
        MachineActivationLocalService.cacheKey: json.encode({
          'schemaVersion': 2,
          'data': data,
        }),
      });

      final activation = await MachineActivationLocalService().load();

      expect(activation?.languages, ['JP', 'EN']);
      expect(
        activation?.languageOptions.map((item) => item.name),
        ['日本語', 'English'],
      );
      final preferences = await SharedPreferences.getInstance();
      final upgraded = json.decode(
        preferences.getString(MachineActivationLocalService.cacheKey)!,
      ) as Map<String, dynamic>;
      expect(
        upgraded['schemaVersion'],
        MachineActivationLocalService.schemaVersion,
      );
    });

    test('falls back to legacy keys when cache schema is unsupported',
        () async {
      SharedPreferences.setMockInitialValues({
        MachineActivationLocalService.cacheKey: json.encode({
          'schemaVersion': 999,
          'data': {'shopCode': 'future-shop'},
        }),
        'smartwe_shopCode': 'legacy-shop',
      });

      final activation = await MachineActivationLocalService().load();

      expect(activation?.shopCode, 'legacy-shop');
    });

    test('save maintains the legacy projection during migration', () async {
      await MachineActivationLocalService()
          .save(_activation(shopCode: 'shop-002'));

      final preferences = await SharedPreferences.getInstance();
      final legacyPayment = json.decode(
        preferences.getString('smartwe_machineActivateData')!,
      ) as Map<String, dynamic>;

      expect(preferences.getString('smartwe_shopCode'), 'shop-002');
      expect(preferences.getString('smartwe_machineType'), 'SWF1');
      expect(preferences.getString('smartwe_reimburse'), '1');
      expect(legacyPayment['showCash'], isTrue);
      expect(legacyPayment['show_visa'], isTrue);
      expect(legacyPayment['taxSystem'], isTrue);
      expect(
        json.decode(preferences.getString('smartwe_machineLanguages')!),
        ['JP'],
      );
    });

    test('round-trips language names in the current cache', () async {
      final service = MachineActivationLocalService();
      final activation = MachineActivation.fromRemoteJson({
        'languages': [
          {'val': 'JP', 'name': '日本語'},
          {'val': 'KO', 'name': '한국말'},
        ],
      });

      await service.save(activation);
      final cached = await service.load();

      expect(cached?.languages, ['JP', 'KO']);
      expect(
        cached?.languageOptions.map((item) => item.name),
        ['日本語', '한국말'],
      );
    });
  });

  group('MachineActivationRepository', () {
    test('caches a successful remote activation', () async {
      final expected = _activation(shopCode: 'repository-shop');
      final remote = _FakeRemoteService(expected);
      final local = _FakeLocalService();
      final repository = MachineActivationRepository(
        remoteService: remote,
        localService: local,
      );

      final result = await repository.activate(
        machineCode: 'machine-001',
        version: '1.2.3',
      );

      expect(result, same(expected));
      expect(local.saved, same(expected));
      expect(remote.machineCode, 'machine-001');
      expect(remote.version, '1.2.3');
    });

    test('does not overwrite cache when machine is not activated', () async {
      final local = _FakeLocalService();
      final repository = MachineActivationRepository(
        remoteService: _FakeRemoteService(null),
        localService: local,
      );

      final result = await repository.activate(
        machineCode: 'missing-machine',
        version: '1.2.3',
      );

      expect(result, isNull);
      expect(local.saved, isNull);
    });
  });

  group('MachineRuntimeService', () {
    test('hydrates machine state once and serves it from memory', () async {
      SharedPreferences.setMockInitialValues({
        'machineInfo': 'machine-001',
        'smartwe_systemSetting': json.encode({
          'isAllowPos': '1',
          'menuDirection': '2',
        }),
        'machineSettingManagePassword': '1234',
        'smartwe_posSetting': json.encode({
          'posIp': '127.0.0.1',
          'posPort': '9000',
        }),
        'machinePrintWidth': 420.0,
      });
      final activation = _activation(shopCode: 'runtime-shop');
      final runtime = MachineRuntimeService(
        activationRepository: _FakeActivationRepository(activation),
      );

      await runtime.hydrate();

      expect(runtime.machineCode, 'machine-001');
      expect(runtime.systemSettings['isAllowPos'], '1');
      expect(runtime.activation, same(activation));
      expect(runtime.settingPassword, '1234');
      expect(runtime.cashMachineEnabled, isTrue);
      expect(runtime.machineModelCode, 'SWF1');
      expect(runtime.posSettings['posPort'], '9000');
      expect(runtime.machinePrintWidth, 420.0);
      expect(runtime.machineModeInfo, {
        'sell': true,
        'takeout': false,
        'checkout': false,
        'scanbuy': false,
      });

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('machineInfo', 'changed-on-disk');
      expect(runtime.machineCode, 'machine-001');
    });

    test('updates memory and persistence through the same service', () async {
      SharedPreferences.setMockInitialValues({});
      final runtime = MachineRuntimeService(
        activationRepository: _FakeActivationRepository(null),
      );
      await runtime.hydrate();

      await runtime.updateMachineCode('machine-002');
      await runtime.updateSystemSettings({'isAllowPos': '0'});

      expect(runtime.machineCode, 'machine-002');
      expect(runtime.systemSettings['isAllowPos'], '0');
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('machineInfo'), 'machine-002');
    });

    test('uses the local cash-machine switch instead of legacy health state',
        () async {
      SharedPreferences.setMockInitialValues({
        'smartwe_systemSetting': json.encode({
          'cashMachineEnabled': false,
        }),
        'isCashState': json.encode({'isCash': true}),
      });
      final runtime = MachineRuntimeService(
        activationRepository:
            _FakeActivationRepository(_activation(shopCode: 'shop')),
      );

      await runtime.hydrate();

      expect(runtime.cashMachineEnabled, isFalse);
      expect(runtime.shouldCheckCashMachine, isFalse);
      expect(runtime.cashMachineStatus, CashMachineRuntimeStatus.notRequired);
    });
  });

  group('MachineCapabilitiesResolver', () {
    const resolver = MachineCapabilitiesResolver();

    test('maps supported machine models to their cash drivers', () {
      expect(
        resolver.resolve('SWF1').cashMachineDriver,
        CashMachineDriver.payCube,
      );
      expect(
        resolver.resolve('swf2').cashMachineDriver,
        CashMachineDriver.payCube,
      );
      expect(
        resolver.resolve('SWFG').cashMachineDriver,
        CashMachineDriver.cashChanger,
      );
      expect(
        resolver.resolve('SWFX').cashMachineDriver,
        CashMachineDriver.none,
      );
    });

    test('keeps future machine models safe and non-blocking', () {
      final capabilities = resolver.resolve('SWF-FUTURE');

      expect(capabilities.isKnownModel, isFalse);
      expect(capabilities.supportsCashMachine, isFalse);
    });
  });
}

MachineActivation _activation({required String shopCode}) {
  return MachineActivation.fromRemoteJson({
    'machineType': 'SWF1',
    'shopCode': shopCode,
    'linePayChannelMap': {
      'Cash': true,
      'VISA': true,
    },
    'languages': ['JP'],
    'homeImages': ['home.png'],
    'headerImages': ['header.png'],
    'logoImage': 'logo.png',
    'reimburse': true,
    'lineup': false,
    'actuarial': true,
    'taxSystem': true,
    'cashMachineWithdraw': false,
  });
}

class _FakeRemoteService extends MachineActivationRemoteService {
  _FakeRemoteService(this.result);

  final MachineActivation? result;
  String? machineCode;
  String? version;

  @override
  Future<MachineActivation?> activate({
    required String machineCode,
    required String version,
  }) async {
    this.machineCode = machineCode;
    this.version = version;
    return result;
  }
}

class _FakeLocalService extends MachineActivationLocalService {
  MachineActivation? saved;

  @override
  Future<void> save(MachineActivation activation) async {
    saved = activation;
  }
}

class _FakeActivationRepository extends MachineActivationRepository {
  _FakeActivationRepository(this.cached);

  final MachineActivation? cached;

  @override
  Future<MachineActivation?> loadCached() async => cached;

  @override
  Future<MachineActivation?> activate({
    required String machineCode,
    required String version,
  }) async {
    return cached;
  }
}
