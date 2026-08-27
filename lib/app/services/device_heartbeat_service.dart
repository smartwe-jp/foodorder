import 'dart:async';

import 'CustomLogerHandler.dart';
import 'incident_sync_service.dart';
import 'machine_runtime_service.dart';

typedef DeviceHeartbeatEmitter = void Function(
  Map<String, Object?> data,
);

class DeviceHeartbeatService {
  DeviceHeartbeatService({
    this.interval = const Duration(seconds: 60),
    DeviceHeartbeatEmitter? emitter,
  }) : _emitter = emitter ?? _emitToLogger;

  final Duration interval;
  final DeviceHeartbeatEmitter _emitter;

  Timer? _timer;
  Map<String, Object?> _deviceData = const <String, Object?>{};

  bool get isRunning => _timer?.isActive ?? false;

  void startForRuntime(
    MachineRuntimeService runtime, {
    bool? enabled,
  }) {
    if (!(enabled ?? openObserveUploadEnabled)) {
      stop();
      return;
    }

    final activation = runtime.activation;
    CustomLogHandler.configureContext(
      merchantId: activation?.shopCode ?? '',
      machineId: runtime.machineCode,
    );
    logI(
      'Machine monitoring context configured',
      tag: 'Monitoring',
      eventCode: 'MACHINE_CONTEXT_CONFIGURED',
    );
    startOrUpdate(
      shopName: '',
      logoImageUrl: activation?.logoImage ?? '',
      machineType: runtime.machineModelCode,
    );
  }

  void startOrUpdate({
    required String shopName,
    required String logoImageUrl,
    required String machineType,
  }) {
    _deviceData = <String, Object?>{
      // Keep the field stable until the activation API provides a shop name.
      'shop_name': shopName,
      'logo_image_url': logoImageUrl,
      'machine_type': machineType,
      'device_status': 'online',
      'heartbeat_interval_seconds': interval.inSeconds,
    };

    emitNow();
    _timer ??= Timer.periodic(interval, (_) => emitNow());
  }

  void emitNow() {
    if (_deviceData.isEmpty) return;
    _emitter(Map<String, Object?>.from(_deviceData));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static void _emitToLogger(Map<String, Object?> data) {
    logI(
      'Device heartbeat',
      tag: 'Monitoring',
      recordType: 'device_heartbeat',
      eventCode: 'DEVICE_HEARTBEAT',
      data: data,
    );
  }
}

final DeviceHeartbeatService deviceHeartbeatService = DeviceHeartbeatService();
