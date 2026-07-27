import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'CustomLogerHandler.dart';
import 'Storage.dart';
import 'scale_port_backend.dart';
export 'scale_port_backend.dart' show ScaleSerialParams;

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
/// 实时重量：建议秤设为连续发送（A&D: prt=0）；
/// 稳定判定由本服务软件完成（重量在 [settleDuration] 内变化小于阈值），未稳不允许确认。
class ScaleSerialService extends GetxService {
  static const String storageKey = 'scale_serial_port';
  static const String paramsStorageKey = 'scale_serial_params';

  /// 兼容旧常量（等同 [ScaleSerialParams.appStandard]）
  static const int baudRate = 9600;

  /// 重量波动小于该值（克）视为未变
  static const double changeThresholdG = 1.0;

  /// 持续无显著变化多久后视为稳定
  static const Duration settleDuration = Duration(milliseconds: 1000);

  /// 自动探测时，每种参数等待首包的时长
  static const Duration _probeWait = Duration(milliseconds: 1600);

  final ScalePortBackend _backend = createScalePortBackend();

  StreamSubscription<Uint8List>? _sub;
  final StringBuffer _buf = StringBuffer();
  Timer? _settleTimer;

  /// 每次 [disconnect] 递增；用于中止进行中的 connect 探测，避免竞态崩
  int _session = 0;

  final weightRx = Rxn<ScaleReading>();
  final connectedRx = false.obs;
  final portNameRx = ''.obs;
  final lastErrorRx = ''.obs;
  final connectingRx = false.obs;
  final lastRawRx = ''.obs;

  /// 当前生效的通信参数（设置页展示）
  final paramsRx = ScaleSerialParams.appStandard.obs;

  /// 设置页展示的口列表（异步刷新后更新）
  final portsRx = <String>[].obs;

  /// 展示用标签：key -> label
  final portLabelsRx = <String, String>{}.obs;

  Future<String?> loadSavedPortName() => Storage.getString(storageKey);

  Future<void> savePortName(String name) async {
    await Storage.setString(storageKey, name);
    portNameRx.value = name;
  }

  Future<ScaleSerialParams> loadSavedParams() async {
    final id = await Storage.getString(paramsStorageKey);
    return ScaleSerialParams.fromId(id) ?? ScaleSerialParams.appStandard;
  }

  Future<void> saveParams(ScaleSerialParams params) async {
    await Storage.setString(paramsStorageKey, params.id);
    paramsRx.value = params;
  }

  /// 是否像 A&D AX-USB（VID 0584 = 1412）
  bool _isAndUsb(String id) {
    final parts = id.split('|');
    if (parts.length >= 2 && parts[0] == 'usb') {
      final vid = int.tryParse(parts[1]);
      return vid == 0x0584;
    }
    return false;
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

  /// 现金投币 / 结算 / 称重页离开时调用：释放 USB，异常全部吞掉，不抛给 UI。
  static Future<void> releaseUsbSafely({String reason = ''}) async {
    try {
      if (!Get.isRegistered<ScaleSerialService>()) return;
      final s = Get.find<ScaleSerialService>();
      await s
          .disconnect()
          .timeout(const Duration(seconds: 3), onTimeout: () {
        logI('电子秤释放超时($reason)');
      });
      logI('电子秤已释放($reason)');
    } catch (e, st) {
      // 绝不向上抛，避免结算/dispose 崩溃
      logI('电子秤释放异常(忽略)($reason): $e\n$st');
    }
  }

  /// 连接。成功才 persist。
  ///
  /// [params] 指定则只用该参数；否则按保存值 + 预设自动探测（收到数据则锁定）。
  Future<bool> connect({
    String? portName,
    bool persist = true,
    ScaleSerialParams? params,
    bool autoProbe = true,
  }) async {
    if (connectingRx.value) {
      lastErrorRx.value = '正在连接中，请稍候';
      return false;
    }
    connectingRx.value = true;
    lastRawRx.value = '';
    try {
      await disconnect();
      final session = _session;

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

      // 已保存口若是现金机 FTDI，直接拒绝，避免抢口/崩原生
      if (_isCashMachineUsbId(name)) {
        lastErrorRx.value = '该口为现金机(FTDI)，不可作电子秤';
        logI('电子秤拒绝现金机口: $name');
        return false;
      }

      final candidates = <ScaleSerialParams>[];
      if (params != null) {
        candidates.add(params);
      } else {
        final saved = await loadSavedParams();
        candidates.add(saved);
        if (autoProbe) {
          final preferAnd = _isAndUsb(name);
          final order = preferAnd
              ? [
                  ScaleSerialParams.andFactory,
                  ScaleSerialParams.appStandard,
                  ...ScaleSerialParams.presets,
                ]
              : [
                  ScaleSerialParams.appStandard,
                  ScaleSerialParams.andFactory,
                  ...ScaleSerialParams.presets,
                ];
          for (final p in order) {
            if (!candidates.any((e) => e.id == p.id)) {
              candidates.add(p);
            }
          }
        }
      }

      logI(
        '电子秤尝试连接: $name (${_backend.runtimeType}) '
        '候选=${candidates.map((e) => e.label).join(" → ")}',
      );

      ScaleOpenResult? lastFail;
      for (var i = 0; i < candidates.length; i++) {
        if (session != _session) {
          logI('电子秤 connect 已被释放中止');
          return false;
        }
        final p = candidates[i];
        final probing = candidates.length > 1 && i < candidates.length - 1;

        final result = await _backend.open(name, params: p);
        if (session != _session) {
          try {
            await _backend.close();
          } catch (_) {}
          return false;
        }
        if (!result.ok) {
          lastFail = result;
          logI('电子秤打开失败(${p.label}): ${result.error}');
          continue;
        }

        portNameRx.value = name;
        paramsRx.value = p;
        final gotFirst = Completer<bool>();
        try {
          await _sub?.cancel();
        } catch (_) {}
        _sub = _backend.inputStream?.listen(
          (data) {
            try {
              if (data.isNotEmpty && !gotFirst.isCompleted) {
                gotFirst.complete(true);
              }
              _onBytes(data);
            } catch (e) {
              logI('电子秤 listen 回调异常: $e');
            }
          },
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

        if (probing) {
          lastErrorRx.value = '探测中: ${p.label}…';
          final got = await gotFirst.future
              .timeout(_probeWait, onTimeout: () => false);
          if (session != _session) return false;
          if (!got) {
            logI('电子秤探测无数据: ${p.label}，试下一种');
            // 仅关后端，不递增 session，以便继续探测
            try {
              await _sub?.cancel();
            } catch (_) {}
            _sub = null;
            connectedRx.value = false;
            try {
              await _backend.close();
            } catch (_) {}
            continue;
          }
        }

        lastErrorRx.value = '';
        if (persist) {
          await savePortName(name);
          await saveParams(p);
        }
        logI('电子秤已连接: $name @${p.label}');

        // 最后一档：短时仍无数据则提示（不判失败）
        if (!probing && !gotFirst.isCompleted) {
          final tipSession = session;
          // ignore: unawaited_futures
          Future<void>.delayed(_probeWait, () {
            if (tipSession != _session || !connectedRx.value) return;
            if (lastRawRx.value.isNotEmpty) return;
            lastErrorRx.value =
                '未受信。確認: 秤 prt=0、通信パラメータ（現在 ${paramsRx.value.label}）、ケーブル';
          });
        }
        return true;
      }

      lastErrorRx.value = lastFail?.error ?? '打开失败';
      final saved = await loadSavedPortName();
      portNameRx.value = saved ?? '';
      return false;
    } catch (e, st) {
      lastErrorRx.value = '连接异常: $e';
      connectedRx.value = false;
      logI('电子秤 connect 异常: $e\n$st');
      try {
        await disconnect();
      } catch (_) {}
      return false;
    } finally {
      connectingRx.value = false;
    }
  }

  bool _isCashMachineUsbId(String id) {
    final parts = id.split('|');
    if (parts.length >= 2 && parts[0] == 'usb') {
      final vid = int.tryParse(parts[1]);
      return vid == 0x0403;
    }
    return false;
  }

  /// 用于去重与稳定判定
  String? _lastRawLine;
  double? _lastGrams;
  String _lastParsedRaw = '';

  void _onBytes(Uint8List data) {
    try {
      if (data.isEmpty) return;
      final hex =
          data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      logI('电子秤收到 ${data.length}B: $hex');
      // 尚未拼成行时也先显示，便于确认「有字节进来」
      if (lastRawRx.value.isEmpty) {
        lastRawRx.value = 'HEX $hex';
      }

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
    // 清掉「未受信」提示
    if (lastErrorRx.value.startsWith('未受信') ||
        lastErrorRx.value.startsWith('探测中')) {
      lastErrorRx.value = '';
    }

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
    _session++;
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
    try {
      connectedRx.value = false;
      _buf.clear();
      _lastRawLine = null;
      _lastGrams = null;
      _lastParsedRaw = '';
    } catch (_) {}
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
