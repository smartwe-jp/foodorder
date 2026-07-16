import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'CustomLogerHandler.dart';
import 'Storage.dart';
import 'scale_port_backend.dart';

/// 电子秤读数（统一为克）
class ScaleReading {
  final double grams;
  /// 软件判定稳定（或协议 ST）；未稳时禁止点「下一步」
  final bool isStable;
  final String raw;

  const ScaleReading({
    required this.grams,
    required this.isStable,
    required this.raw,
  });
}

/// 电子秤串口服务
///
/// Android：只用 USB Host（usb_serial），避免 libserialport 选错口原生闪退。
/// Windows：用 libserialport，且只允许 COMx。
///
/// 实时重量：建议秤设为 **232-1 连续发送**，屏上即可跟秤面跳动；
/// 稳定判定由本服务软件完成（重量在 [settleDuration] 内变化小于阈值），未稳不允许确认。
class ScaleSerialService extends GetxService {
  static const String storageKey = 'scale_serial_port';
  static const int baudRate = 9600;

  /// 重量波动小于该值（克）视为未变
  static const double changeThresholdG = 1.0;

  /// 持续无显著变化多久后视为稳定
  static const Duration settleDuration = Duration(milliseconds: 1000);

  final ScalePortBackend _backend = createScalePortBackend();

  StreamSubscription<Uint8List>? _sub;
  final StringBuffer _buf = StringBuffer();
  Timer? _settleTimer;

  final weightRx = Rxn<ScaleReading>();
  final connectedRx = false.obs;
  final portNameRx = ''.obs;
  final lastErrorRx = ''.obs;
  final connectingRx = false.obs;
  final lastRawRx = ''.obs;

  /// 设置页展示的口列表（异步刷新后更新）
  final portsRx = <String>[].obs;

  /// 展示用标签：key -> label
  final portLabelsRx = <String, String>{}.obs;

  Future<String?> loadSavedPortName() => Storage.getString(storageKey);

  Future<void> savePortName(String name) async {
    await Storage.setString(storageKey, name);
    portNameRx.value = name;
  }

  /// 刷新可用设备列表（设置页进入 / 再検索 时调用）
  Future<List<String>> refreshPorts() async {
    try {
      final items = await _backend.listPorts();
      portsRx.assignAll(items.map((e) => e.id).toList());
      portLabelsRx.assignAll({for (final e in items) e.id: e.label});
      logI('电子秤可用口: ${portsRx.join(", ")}');
      return portsRx.toList();
    } catch (e) {
      logI('列举串口失败: $e');
      lastErrorRx.value = '列举失败: $e';
      portsRx.clear();
      return [];
    }
  }

  /// 兼容旧同步调用：返回缓存；若空请先 await refreshPorts()
  List<String> listPorts({bool onlyLikely = true}) => portsRx.toList();

  String portLabel(String id) => portLabelsRx[id] ?? id;

  /// 连接。成功才 persist。Android 失败返回 false，不闪退。
  Future<bool> connect({String? portName, bool persist = true}) async {
    if (connectingRx.value) {
      lastErrorRx.value = '正在连接中，请稍候';
      return false;
    }
    connectingRx.value = true;
    lastRawRx.value = '';
    try {
      await disconnect();

      var name = (portName?.isNotEmpty == true)
          ? portName!
          : (await loadSavedPortName() ?? '');

      if (name.isEmpty) {
        if (portsRx.isEmpty) await refreshPorts();
        if (portsRx.isEmpty) {
          lastErrorRx.value = '未找到串口设备';
          logI('电子秤: 未找到串口');
          return false;
        }
        name = portsRx.first;
      }

      logI('电子秤尝试连接: $name (${_backend.runtimeType})');
      final result = await _backend.open(name, baudRate: baudRate);
      if (!result.ok) {
        lastErrorRx.value = result.error ?? '打开失败';
        logI('电子秤打开失败: ${lastErrorRx.value}');
        final saved = await loadSavedPortName();
        portNameRx.value = saved ?? '';
        return false;
      }

      portNameRx.value = name;
      _sub = _backend.inputStream?.listen(
        _onBytes,
        onError: (Object e, StackTrace st) {
          lastErrorRx.value = '读错误: $e';
          logI('电子秤读流错误: $e\n$st');
          connectedRx.value = false;
        },
        onDone: () {
          logI('电子秤读流结束');
          connectedRx.value = false;
        },
        cancelOnError: false,
      );

      connectedRx.value = true;
      lastErrorRx.value = '';
      if (persist) await savePortName(name);
      logI('电子秤已连接: $name @$baudRate');
      return true;
    } catch (e, st) {
      lastErrorRx.value = '连接异常: $e';
      connectedRx.value = false;
      logI('电子秤 connect 异常: $e\n$st');
      await disconnect();
      return false;
    } finally {
      connectingRx.value = false;
    }
  }

  /// 用于去重与稳定判定
  String? _lastRawLine;
  double? _lastGrams;
  String _lastParsedRaw = '';

  void _onBytes(Uint8List data) {
    try {
      _buf.write(utf8.decode(data, allowMalformed: true));
      var s = _buf.toString();
      while (true) {
        final match = RegExp(r'\r\n|\n|\r').firstMatch(s);
        if (match == null) break;
        final line = s.substring(0, match.start).trim();
        s = s.substring(match.end);
        if (line.isNotEmpty) _parseLine(line);
      }
      _buf
        ..clear()
        ..write(s);
    } catch (e) {
      logI('电子秤解析字节异常: $e');
    }
  }

  /// 解析一帧：实时推送跳动克重；变化后重启稳定计时。
  void _parseLine(String line) {
    // 完全相同的原始帧：不刷 log，但若尚未稳定且计时器已关则补一轮稳重计时
    if (line == _lastRawLine) {
      if (_lastGrams != null &&
          !(weightRx.value?.isStable ?? false) &&
          _settleTimer == null) {
        _armSettleTimer(_lastGrams!, _lastParsedRaw);
      }
      return;
    }
    _lastRawLine = line;
    lastRawRx.value = line;

    final m = RegExp(
      r'(ST|US)?[^\d\-+]*([+\-]?\d+(?:\.\d+)?)\s*(kg|g)?',
      caseSensitive: false,
    ).firstMatch(line);
    if (m == null) {
      debugPrint('[Scale] raw(未识别): $line');
      return;
    }

    var v = double.tryParse(m.group(2) ?? '') ?? 0;
    final unit = (m.group(3) ?? 'g').toLowerCase();
    if (unit == 'kg') v *= 1000;
    if (v < 0) v = 0;

    final status = m.group(1)?.toUpperCase();
    final protocolUnstable = status == 'US';

    final prev = _lastGrams;
    final changed =
        prev == null || (v - prev).abs() >= changeThresholdG;

    if (!changed && !protocolUnstable) {
      // 微小抖动：不改显示，继续等稳定计时
      if (!(weightRx.value?.isStable ?? false) && _settleTimer == null) {
        _armSettleTimer(v, line);
      }
      return;
    }

    _lastGrams = v;
    _lastParsedRaw = line;
    debugPrint('[Scale] raw: $line -> ${v}g');

    // 重量变化或协议报 US：立即实时刷新，标记未稳
    _settleTimer?.cancel();
    _settleTimer = null;
    weightRx.value = ScaleReading(
      grams: v,
      isStable: false,
      raw: line,
    );

    if (protocolUnstable) {
      // 协议明确不稳时暂不定稳，等后续非 US 帧再计时
      return;
    }
    _armSettleTimer(v, line);
  }

  void _armSettleTimer(double grams, String raw) {
    _settleTimer?.cancel();
    _settleTimer = Timer(settleDuration, () {
      _settleTimer = null;
      // 若这段时间内又变了，以最新 _lastGrams 为准
      final g = _lastGrams ?? grams;
      if ((g - grams).abs() >= changeThresholdG) return;
      weightRx.value = ScaleReading(
        grams: g,
        isStable: true,
        raw: raw,
      );
      logI('电子秤重量已稳定: ${g}g');
    });
  }

  Future<void> disconnect() async {
    _settleTimer?.cancel();
    _settleTimer = null;
    try {
      await _sub?.cancel();
    } catch (_) {}
    _sub = null;
    try {
      await _backend.close();
    } catch (e) {
      logI('电子秤关闭异常: $e');
    }
    connectedRx.value = false;
    _buf.clear();
    _lastRawLine = null;
    _lastGrams = null;
    _lastParsedRaw = '';
  }

  void clearReading() {
    _settleTimer?.cancel();
    _settleTimer = null;
    weightRx.value = null;
    lastRawRx.value = '';
    _lastRawLine = null;
    _lastGrams = null;
    _lastParsedRaw = '';
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
}
