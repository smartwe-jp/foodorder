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

/// 串口通信参数（与 UsbPort 常量一致：parity 0=none, 2=even）
class ScaleSerialParams {
  final int baudRate;
  final int dataBits;
  final int stopBits;
  final int parity;
  final String label;

  const ScaleSerialParams({
    required this.baudRate,
    required this.dataBits,
    required this.stopBits,
    required this.parity,
    required this.label,
  });

  /// App 原默认 / 多数设定：9600 8N1
  static const appStandard = ScaleSerialParams(
    baudRate: 9600,
    dataBits: 8,
    stopBits: 1,
    parity: 0,
    label: '9600 8N1',
  );

  /// A&D EK-L 出厂：2400 7E1（bps0 / btpr0）
  static const andFactory = ScaleSerialParams(
    baudRate: 2400,
    dataBits: 7,
    stopBits: 1,
    parity: 2,
    label: '2400 7E1(A&D出厂)',
  );

  static const presets = <ScaleSerialParams>[
    appStandard,
    andFactory,
    ScaleSerialParams(
      baudRate: 4800,
      dataBits: 8,
      stopBits: 1,
      parity: 0,
      label: '4800 8N1',
    ),
    ScaleSerialParams(
      baudRate: 9600,
      dataBits: 7,
      stopBits: 1,
      parity: 2,
      label: '9600 7E1',
    ),
    ScaleSerialParams(
      baudRate: 2400,
      dataBits: 8,
      stopBits: 1,
      parity: 0,
      label: '2400 8N1',
    ),
  ];

  String get id =>
      '${baudRate}_${dataBits}${parity == 2 ? 'E' : 'N'}$stopBits';

  static ScaleSerialParams? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final p in presets) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  String toString() => label;
}

abstract class ScalePortBackend {
  Future<List<ScalePortItem>> listPorts();
  Future<ScaleOpenResult> open(String id, {required ScaleSerialParams params});
  Stream<Uint8List>? get inputStream;
  /// 向秤发送命令（如 A&D `Q\r\n` 即时要数）
  Future<bool> write(Uint8List data);
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
  // 注意：不包含 0x0403 FTDI —— 现金机 PayCube(D2XX) 使用，电子秤列表需排除
  0x10C4, // CP210x
  0x067B, // PL2303
  0x1A86, // CH340/CH341
  0x2341, // Arduino
  0x2A03, // Arduino.org
  0x04D8, // Microchip
  0x1B4F, // SparkFun
  0x0584, // RATOC / A&D AX-USB 官方 USB-RS232（如 0584:B050）
};

/// 现金机等占用的 USB VID，电子秤禁止列举/打开
const _kCashMachineVids = <int>{
  0x0403, // FTDI — PayCube Android11
};

/// A&D AX-USB（RATOC）等：自动探测常失败，需按驱动类型依次强制尝试
const _kForceDriverVids = <int>{
  0x0584,
};

bool _looksLikeUart(UsbDevice d) {
  final vid = d.vid;
  if (vid != null && _kCashMachineVids.contains(vid)) return false;
  if (vid != null && _kKnownUartVids.contains(vid)) return true;
  final name =
      '${d.productName ?? ''} ${d.manufacturerName ?? ''} ${d.deviceName}'
          .toLowerCase();
  // 名称像 FTDI 的也不给秤用（防误选现金机）
  if (name.contains('ftdi')) return false;
  const keys = [
    'serial',
    'uart',
    'ch340',
    'ch341',
    'cp210',
    'pl2303',
    'cdc',
    'usb-serial',
    'usb serial',
    'usb_serial',
    'ratoc',
    'a&d',
    'a and d',
  ];
  return keys.any(name.contains);
}

bool _isCashMachineUsb(UsbDevice d) {
  final vid = d.vid;
  return vid != null && _kCashMachineVids.contains(vid);
}

/// 为指定设备选择 create() 驱动尝试顺序（空字符串=库自动探测）
List<String> _driverTypesFor(UsbDevice d) {
  final vid = d.vid;
  if (vid != null && _kForceDriverVids.contains(vid)) {
    // A&D AX-USB：现场多为 FTDI/CDC 兼容，PL2303 次之
    return [
      UsbSerial.FTDI,
      UsbSerial.CDC,
      UsbSerial.PL2303,
      UsbSerial.CH34x,
      UsbSerial.CP210x,
      '',
    ];
  }
  return [''];
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
  Future<bool> write(Uint8List data) async {
    final port = _port;
    if (port == null || data.isEmpty) return false;
    try {
      await port.write(data);
      return true;
    } catch (e) {
      logI('电子秤 USB write 失败: $e');
      return false;
    }
  }

  @override
  Future<List<ScalePortItem>> listPorts() async {
    if (!Platform.isAndroid) return [];
    try {
      final all = await UsbSerial.listDevices();
      // 永远排除现金机 FTDI，即使「回退全部」也不列入
      final safe = all.where((d) => !_isCashMachineUsb(d)).toList();
      final uart = safe.where(_looksLikeUart).toList();
      _devices = uart.isNotEmpty ? uart : safe;
      if (uart.isEmpty && safe.isNotEmpty) {
        logI('电子秤：未匹配已知UART VID，回退非现金机USB ${safe.length} 台');
      }
      if (all.length != safe.length) {
        logI(
            '电子秤：已排除现金机FTDI ${all.length - safe.length} 台，剩余 ${_devices.length}');
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

  /// 按 VID 尝试合适驱动；A&D AX-USB(0584) 自动探测会报 Not an Serial device
  Future<UsbPort?> _createUsbPort(UsbDevice device) async {
    Object? lastError;
    for (final type in _driverTypesFor(device)) {
      final typeLabel = type.isEmpty ? 'auto' : type;
      try {
        // 部分驱动对未知芯片会卡住，必须限时
        final port = await device
            .create(type)
            .timeout(const Duration(seconds: 3));
        if (port != null) {
          logI('电子秤 USB create 成功 type=$typeLabel ${_encodeId(device)}');
          return port;
        }
        logI('电子秤 USB create 返回 null type=$typeLabel');
      } on TimeoutException {
        lastError = 'create($typeLabel) 超时';
        logI('电子秤 USB create 超时 type=$typeLabel');
      } catch (e) {
        lastError = e;
        logI('电子秤 USB create 失败 type=$typeLabel: $e');
      }
    }
    if (lastError != null) throw lastError;
    return null;
  }

  @override
  Future<ScaleOpenResult> open(
    String id, {
    required ScaleSerialParams params,
  }) async {
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

      if (_isCashMachineUsb(device)) {
        return const ScaleOpenResult.fail('禁止打开现金机 USB(FTDI 0x0403)');
      }

      // 非 UART 设备强提醒：仍允许试开，但包住异常
      if (!_looksLikeUart(device)) {
        logI('警告：设备可能不是串口芯片 ${_encodeId(device)}');
      }

      UsbPort? port;
      Object? createError;
      try {
        port = await _createUsbPort(device);
      } catch (e) {
        createError = e;
        return ScaleOpenResult.fail('创建失败（可能不是串口设备）: $e');
      }
      if (port == null) {
        return ScaleOpenResult.fail(
            '无法创建端口（权限？）${createError != null ? " $createError" : ""}');
      }

      bool opened = false;
      try {
        opened = await port.open().timeout(const Duration(seconds: 3)) == true;
      } on TimeoutException {
        try {
          await port.close();
        } catch (_) {}
        return const ScaleOpenResult.fail('USB 打开超时');
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
          params.baudRate,
          params.dataBits,
          params.stopBits,
          params.parity,
        );
        logI('电子秤串口参数: ${params.label}');
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

  @override
  Future<bool> write(Uint8List data) async {
    final port = _port;
    if (port == null || data.isEmpty || !port.isOpen) return false;
    try {
      final n = port.write(data);
      return n > 0;
    } catch (e) {
      logI('电子秤 COM write 失败: $e');
      return false;
    }
  }

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
  Future<ScaleOpenResult> open(
    String id, {
    required ScaleSerialParams params,
  }) async {
    await close();
    if (!_isSafeCom(id)) {
      return ScaleOpenResult.fail('不允许打开非 COM 口: $id');
    }
    SerialPort? port;
    try {
      port = SerialPort(id);
      var opened = false;
      // 优先读写：A&D 命令模式需发 Q\r\n
      try {
        opened = port.openReadWrite();
      } catch (e) {
        logI('openReadWrite 失败: $e');
      }
      if (!opened) {
        try {
          opened = port.openRead();
        } catch (e) {
          logI('openRead 失败: $e');
        }
      }
      if (!opened) {
        final err = SerialPort.lastError?.toString() ?? 'unknown';
        _safeDispose(port);
        return ScaleOpenResult.fail('打开失败: $err');
      }

      try {
        final parity = params.parity == 2
            ? SerialPortParity.even
            : params.parity == 1
                ? SerialPortParity.odd
                : SerialPortParity.none;
        final config = SerialPortConfig()
          ..baudRate = params.baudRate
          ..bits = params.dataBits
          ..parity = parity
          ..stopBits = params.stopBits;
        try {
          config.setFlowControl(SerialPortFlowControl.none);
        } catch (_) {}
        port.config = config;
        config.dispose();
        logI('电子秤串口参数: ${params.label}');
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
