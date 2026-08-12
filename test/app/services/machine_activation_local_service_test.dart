import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/models/machine_activation.dart';
import 'package:foodorder/app/repositories/machine_activation_repository.dart';
import 'package:foodorder/app/services/machine_activation_local_service.dart';
import 'package:foodorder/app/services/machine_activation_remote_service.dart';
import 'package:foodorder/app/services/machine_runtime_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MachineActivationResponse', () {
    test('parses remote payload into a typed activation model', () {
      final response = MachineActivationResponse.fromPayload({
        'code': '200',
        'data': {
          'shopCode': 'shop-001',
          'linePayChannelMap': {
            'Cash': true,
            'Wechat': 1,
            'POS': '1',
            'Discover': false,
          },
          'languages': ['JP', 'EN'],
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
      expect(response.activation?.shopCode, 'shop-001');
      expect(response.activation?.paymentChannels.cash, isTrue);
      expect(response.activation?.paymentChannels.wechat, isTrue);
      expect(response.activation?.paymentChannels.creditCard, isTrue);
      expect(response.activation?.paymentChannels.alipay, isFalse);
      expect(response.activation?.canReimburse, isTrue);
      expect(response.activation?.taxSystem, isTrue);
      expect(response.activation?.cashMachineWithdraw, isFalse);
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
      expect(preferences.getString('smartwe_reimburse'), '1');
      expect(legacyPayment['showCash'], isTrue);
      expect(legacyPayment['show_visa'], isTrue);
      expect(legacyPayment['taxSystem'], isTrue);
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
        'isCashState': json.encode({'isCash': true}),
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
      expect(runtime.cashOn, isTrue);
      expect(runtime.posSettings['posPort'], '9000');
      expect(runtime.machinePrintWidth, 420.0);

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
  });
}

MachineActivation _activation({required String shopCode}) {
  return MachineActivation.fromRemoteJson({
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
