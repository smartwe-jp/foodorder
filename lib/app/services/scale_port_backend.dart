import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:usb_serial/usb_serial.dart';

import 'CustomLogerHandler.dart';

class ScalePortItem {
  final String id;
  final String label;
  const ScalePortItem({required this.id, required this.label});
}

class ScaleOpenResult {
  final bool ok;
  final String? error;
  const ScaleOpenResult.ok() : ok = true, error = null;
  const ScaleOpenResult.fail(this.error) : ok = false;
}

abstract class ScalePortBackend {
  Future<List<ScalePortItem>> listPorts();
  Future<ScaleOpenResult> open(String id, {required int baudRate});
  Stream<Uint8List>? get inputStream;
  Future<void> close();
}

ScalePortBackend createScalePortBackend() {
  if (Platform.isAndroid) {
    return AndroidUsbScaleBackend();
  }
  return LibSerialScaleBackend();
}

/// 常见 USB 转串口芯片 VID（十进制），降低误开打印机/摄像头导致原生崩溃
const _kKnownUartVids = <int>{
  0x0403, // FTDI
  0x10C4, // CP210x
  0x067B, // PL2303
  0x1A86, // CH340/CH341
  0x2341, // Arduino
  0x2A03, // Arduino.org
  0x04D8, // Microchip
  0x1B4F, // SparkFun
};

bool _looksLikeUart(UsbDevice d) {
  final vid = d.vid;
  if (vid != null && _kKnownUartVids.contains(vid)) return true;
  final name =
      '${d.productName ?? ''} ${d.manufacturerName ?? ''} ${d.deviceName}'
          .toLowerCase();
  const keys = [
    'serial',
    'uart',
    'ch340',
    'ch341',
    'cp210',
    'ft232',
    'pl2303',
    'cdc',
    'usb-serial',
    'usb serial',
  ];
  return keys.any(name.contains);
}

/// Android：UsbManager + usb_serial
class AndroidUsbScaleBackend implements ScalePortBackend {
  UsbPort? _port;
  StreamSubscription<Uint8List>? _pipeSub;
  final _controller = StreamController<Uint8List>.broadcast();
  List<UsbDevice> _devices = [];

  @override
  Stream<Uint8List>? get inputStream => _controller.stream;

  @override
  Future<List<ScalePortItem>> listPorts() async {
    if (!Platform.isAndroid) return [];
    try {
      final all = await UsbSerial.listDevices();
      // 优先只展示串口芯片；过滤后为空再回退全部（部分秤 VID 未知）
      final uart = all.where(_looksLikeUart).toList();
      _devices = uart.isNotEmpty ? uart : all;
      if (uart.isEmpty && all.isNotEmpty) {
        logI('电子秤：未匹配已知UART VID，回退全部USB设备 ${all.length} 台');
      }
      return _devices.map((d) {
        final id = _encodeId(d);
        final name = (d.productName?.trim().isNotEmpty == true)
            ? d.productName!
            : (d.manufacturerName?.trim().isNotEmpty == true)
                ? d.manufacturerName!
                : d.deviceName;
        final vid = d.vid?.toRadixString(16).padLeft(4, '0') ?? '?';
        final pid = d.pid?.toRadixString(16).padLeft(4, '0') ?? '?';
        return ScalePortItem(id: id, label: '$name  VID:$vid PID:$pid');
      }).toList();
    } catch (e) {
      logI('Android USB 列举失败: $e');
      return [];
    }
  }

  String _encodeId(UsbDevice d) {
    final serial = d.serial ?? '';
    return 'usb|${d.vid}|${d.pid}|$serial|${d.deviceName}|${d.deviceId}';
  }

  UsbDevice? _findDevice(String id) {
    for (final d in _devices) {
      if (_encodeId(d) == id) return d;
    }
    final parts = id.split('|');
    if (parts.length >= 5 && parts[0] == 'usb') {
      final vid = int.tryParse(parts[1]);
      final pid = int.tryParse(parts[2]);
      final serial = parts[3];
      final deviceName = parts[4];
      for (final d in _devices) {
        if (vid != null && pid != null && d.vid == vid && d.pid == pid) {
          if (serial.isNotEmpty && d.serial != null && d.serial == serial) {
            return d;
          }
          if (d.deviceName == deviceName) return d;
        }
      }
      if (vid != null && pid != null) {
        final same =
            _devices.where((x) => x.vid == vid && x.pid == pid).toList();
        if (same.length == 1) return same.first;
      }
    }
    return null;
  }

  @override
  Future<ScaleOpenResult> open(String id, {required int baudRate}) async {
    await close();
    try {
      if (_devices.isEmpty) {
        await listPorts();
      }
      var device = _findDevice(id);
      if (device == null && _devices.length == 1) {
        device = _devices.first;
        logI('电子秤：配置口不匹配，回退唯一 USB ${_encodeId(device)}');
      }
      if (device == null) {
        return const ScaleOpenResult.fail('未找到该 USB 设备，请重新选择');
      }

      // 非 UART 设备强提醒：仍允许试开，但包住异常
      if (!_looksLikeUart(device)) {
        logI('警告：设备可能不是串口芯片 ${_encodeId(device)}');
      }

      UsbPort? port;
      try {
        port = await device.create();
      } catch (e) {
        return ScaleOpenResult.fail('创建失败（可能不是串口设备）: $e');
      }
      if (port == null) {
        return const ScaleOpenResult.fail('无法创建端口（权限？）');
      }

      bool opened = false;
      try {
        opened = await port.open() == true;
      } catch (e) {
        try {
          await port.close();
        } catch (_) {}
        return ScaleOpenResult.fail('打开异常: $e');
      }
      if (!opened) {
        try {
          await port.close();
        } catch (_) {}
        return const ScaleOpenResult.fail('USB 打开失败（占用/无权限/非串口）');
      }

      try {
        await port.setDTR(true);
        await port.setRTS(true);
      } catch (_) {}

      try {
        await port.setPortParameters(
          baudRate,
          UsbPort.DATABITS_8,
          UsbPort.STOPBITS_1,
          UsbPort.PARITY_NONE,
        );
      } catch (e) {
        logI('setPortParameters 失败: $e');
      }

      _port = port;
      final stream = port.inputStream;
      if (stream == null) {
        await close();
        return const ScaleOpenResult.fail('无输入流');
      }
      _pipeSub = stream.listen(
        (data) {
          if (!_controller.isClosed) _controller.add(data);
        },
        onError: (e) {
          logI('USB 读错误: $e');
          // 不向下游 addError，避免未监听导致 Zone 崩
        },
        cancelOnError: false,
      );
      return const ScaleOpenResult.ok();
    } catch (e, st) {
      logI('Android USB open 异常: $e\n$st');
      await close();
      return ScaleOpenResult.fail('$e');
    }
  }

  @override
  Future<void> close() async {
    try {
      await _pipeSub?.cancel();
    } catch (_) {}
    _pipeSub = null;
    try {
      await _port?.close();
    } catch (_) {}
    _port = null;
  }
}

/// Windows：仅 COMx
class LibSerialScaleBackend implements ScalePortBackend {
  SerialPort? _port;
  SerialPortReader? _reader;
  StreamSubscription<Uint8List>? _sub;
  final _controller = StreamController<Uint8List>.broadcast();

  @override
  Stream<Uint8List>? get inputStream => _controller.stream;

  static bool _isSafeCom(String name) =>
      RegExp(r'^COM\d+$', caseSensitive: false).hasMatch(name);

  @override
  Future<List<ScalePortItem>> listPorts() async {
    try {
      final all = SerialPort.availablePorts.where(_isSafeCom).toList();
      return all.map((n) => ScalePortItem(id: n, label: n)).toList();
    } catch (e) {
      logI('libserialport 列举失败: $e');
      return [];
    }
  }

  @override
  Future<ScaleOpenResult> open(String id, {required int baudRate}) async {
    await close();
    if (!_isSafeCom(id)) {
      return ScaleOpenResult.fail('不允许打开非 COM 口: $id');
    }
    SerialPort? port;
    try {
      port = SerialPort(id);
      var opened = false;
      try {
        opened = port.openRead();
      } catch (e) {
        logI('openRead 失败: $e');
      }
      if (!opened) {
        try {
          opened = port.openReadWrite();
        } catch (e) {
          logI('openReadWrite 失败: $e');
        }
      }
      if (!opened) {
        final err = SerialPort.lastError?.toString() ?? 'unknown';
        _safeDispose(port);
        return ScaleOpenResult.fail('打开失败: $err');
      }

      try {
        final config = SerialPortConfig()
          ..baudRate = baudRate
          ..bits = 8
          ..parity = SerialPortParity.none
          ..stopBits = 1;
        try {
          config.setFlowControl(SerialPortFlowControl.none);
        } catch (_) {}
        port.config = config;
        config.dispose();
      } catch (e) {
        logI('配置失败: $e');
      }

      _port = port;
      port = null;
      _reader = SerialPortReader(_port!);
      _sub = _reader!.stream.listen(
        (data) {
          if (!_controller.isClosed) _controller.add(data);
        },
        onError: (e) {
          logI('COM 读错误: $e');
        },
        cancelOnError: false,
      );
      return const ScaleOpenResult.ok();
    } catch (e, st) {
      logI('libserialport open 异常: $e\n$st');
      _safeDispose(port);
      await close();
      return ScaleOpenResult.fail('$e');
    }
  }

  void _safeDispose(SerialPort? p) {
    if (p == null) return;
    try {
      if (p.isOpen) p.close();
    } catch (_) {}
    try {
      p.dispose();
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    try {
      await _sub?.cancel();
    } catch (_) {}
    _sub = null;
    _reader = null;
    _safeDispose(_port);
    _port = null;
  }
}
