import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/font.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../services/scale_serial_service.dart';
import '../../../services/spicy_weigh_settings.dart';
import '../../../routes/app_pages.dart';
import '../../../widget/KioskTap.dart';
import '../../../widget/NumberKeyboard.dart';
import '../controllers/spicy_hot_pot_checkout_controller.dart';
import 'spicy_bowl_scan_dialog.dart';
import 'widgets/spicy_hot_pot_chrome.dart';
import 'widgets/scale_connection_prompt.dart';

/// 麻辣烫全屏称重页面（只有1个称重商品时使用）
///
/// UI 对齐设计图：logo+步骤条 / 计量说明 / 碗+秤示意+实时克重 / 戻る·跳过·次へ
/// 功能：串口实时重量（减皮重）、稳定后才可下一步、跳过称重、重新称重
/// 手动输入：由系统设置「手動入力」开关控制是否显示按钮
class SpicyWeighPage extends StatefulWidget {
  final Map itemData;
  final int unitPricePer100g;
  final Function(double weight, int price) onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onSkip;

  const SpicyWeighPage({
    Key? key,
    required this.itemData,
    required this.unitPricePer100g,
    required this.onConfirm,
    this.onCancel,
    this.onSkip,
  }) : super(key: key);

  @override
  State<SpicyWeighPage> createState() => _SpicyWeighPageState();
}

class _SpicyWeighPageState extends State<SpicyWeighPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tongsAnimation;
  final LayerLink _scaleVisualLink = LayerLink();
  String _input = '0';
  bool _stable = false;

  /// 系统设置「手動入力」为开时显示按钮
  bool _manualInputAllowed = false;

  /// 当前重量是否来自手动键盘（避免串口覆盖；手动值为净重，不再减皮重）
  bool _useManualWeight = false;

  /// 皮重（克），来自设置，默认 0
  double _tareGrams = 0;

  /// 最低额度（日元），来自设置；0＝不限制
  int _minAmountYen = 0;
  Worker? _scaleWorker;
  Worker? _scaleConnectionWorker;
  Timer? _scaleRetryTimer;
  bool _scaleRetrying = false;
  bool _scaleDialogShowing = false;
  bool _openingScaleSettings = false;

  ScaleSerialService get _scale {
    if (!Get.isRegistered<ScaleSerialService>()) {
      Get.put(ScaleSerialService(), permanent: true);
    }
    return Get.find<ScaleSerialService>();
  }

  double get _weight {
    final raw = double.tryParse(_input) ?? 0;
    // 显示、计价、入车均向下取整克重
    if (raw <= 0) return 0;
    return raw.floorToDouble();
  }

  // 价格：按向下取整后的克重 × 单价，再向下取整
  int get _price =>
      _weight > 0 ? ((_weight / 100) * widget.unitPricePer100g).floor() : 0;
  bool get _hasWeight => _weight > 0;

  /// 界面展示：整数克重
  String get _displayWeight => _weight <= 0 ? '0' : _weight.toInt().toString();
  bool get _meetsMinAmount => _minAmountYen <= 0 || _price >= _minAmountYen;
  bool get _canConfirm => _hasWeight && _stable && _meetsMinAmount;

  String get _nextLabel {
    if (_hasWeight && !_stable) return 'spicy_weigh_waiting_stable'.tr;
    if (_hasWeight && _stable && !_meetsMinAmount) {
      return 'spicy_weigh_below_min'.tr;
    }
    return 'next_button'.tr;
  }

  @override
  void initState() {
    super.initState();
    _tongsAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _hideSystemKeyboard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final result = await _ensureBowlScanIfNeeded();
    if (!mounted) return;
    switch (result.action) {
      case SpicyBowlScanAction.back:
        widget.onCancel?.call();
        return;
      case SpicyBowlScanAction.skip:
        if (widget.onSkip != null) {
          widget.onSkip!();
        } else {
          widget.onCancel?.call();
        }
        return;
      case SpicyBowlScanAction.proceed:
        await _initWeigh();
        return;
    }
  }

  /// 设置开启扫盆码时，先弹窗扫码
  Future<SpicyBowlScanResult> _ensureBowlScanIfNeeded() async {
    if (!Get.isRegistered<SpicyHotPotCheckoutController>()) {
      return const SpicyBowlScanResult.proceed();
    }
    return Get.find<SpicyHotPotCheckoutController>().ensureBowlScanned();
  }

  Future<void> _initWeigh() async {
    await _loadWeighSettings();
    await _startScaleListen();
  }

  Future<void> _loadWeighSettings() async {
    final manual = await SpicyWeighSettings.loadManualAllowed();
    final tare = await SpicyWeighSettings.loadTareGrams();
    final minYen = await SpicyWeighSettings.loadMinAmountYen();
    if (!mounted) return;
    setState(() {
      _manualInputAllowed = manual;
      _tareGrams = tare;
      _minAmountYen = minYen;
    });
  }

  void _hideSystemKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  Future<void> _startScaleListen() async {
    _stopScaleRetryLoop();
    _scaleWorker?.dispose();
    _scaleWorker = null;
    _scale.clearReading();
    var ready = false;
    try {
      ready = await _scale.ensureReady();
    } catch (e) {
      debugPrint('称重页连接电子秤失败: $e');
    }
    if (!mounted) return;
    _startScaleConnectionMonitor();
    if (!ready) {
      await _showScaleConnectionIssue(
        _scale.lastErrorRx.value.isEmpty
            ? '電子秤に接続できません。接続ポートと通信設定を確認してください。'
            : _scale.lastErrorRx.value,
      );
      return;
    }
    _attachScaleReadingWorker();
  }

  void _attachScaleReadingWorker() {
    _scaleWorker?.dispose();
    _scaleWorker = ever<ScaleReading?>(_scale.weightRx, _applyScaleReading);
    _applyScaleReading(_scale.weightRx.value);
  }

  void _applyScaleReading(ScaleReading? reading) {
    if (!mounted || reading == null || _useManualWeight) return;
    final net = SpicyWeighSettings.netGrams(reading.grams, _tareGrams);
    setState(() {
      _stable = reading.isStable;
      // 实时重量向下取整显示
      _input = net <= 0 ? '0' : net.floor().toString();
    });
    _updateTongsAnimation();
  }

  /// 放盆后取得正净重才播放；空秤、重新称重或断线时停止。
  void _updateTongsAnimation() {
    if (_hasWeight) {
      if (!_tongsAnimation.isAnimating) _tongsAnimation.repeat();
    } else {
      _tongsAnimation.stop();
      _tongsAnimation.value = 0;
    }
  }

  void _startScaleConnectionMonitor() {
    _scaleConnectionWorker ??=
        ever<String?>(_scale.connectionIssueRx, (message) {
      if (message == null || message.isEmpty) return;
      _showScaleConnectionIssue(message);
    });
  }

  Future<void> _showScaleConnectionIssue(String message) async {
    if (!mounted || _scaleDialogShowing || _openingScaleSettings) return;
    _scaleWorker?.dispose();
    _scaleWorker = null;
    _resetWeighingAfterScaleDisconnect();
    _scaleDialogShowing = true;
    _startScaleRetryLoop();
    final openSettings = await showScaleConnectionPrompt(message: message);
    _scaleDialogShowing = false;
    if (!mounted) return;
    if (!openSettings) {
      if (_scale.hasRecentValidReading) return;
      _startScaleRetryLoop();
      return;
    }

    _stopScaleRetryLoop();
    _openingScaleSettings = true;
    await _scale.disconnect();
    await Get.toNamed(Routes.SPICY_HOT_POT_SETTINGS);
    _openingScaleSettings = false;
    if (mounted) await _startScaleListen();
  }

  void _resetWeighingAfterScaleDisconnect() {
    _scale.clearReading();
    setState(() {
      _input = '0';
      _stable = false;
      _useManualWeight = false;
    });
    _updateTongsAnimation();
    logI('[麻辣烫] 电子秤断开，已重置本次称重');
  }

  void _startScaleRetryLoop() {
    if (!mounted || _openingScaleSettings || _scaleRetryTimer != null) return;
    _scaleRetryTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _retryScaleConnection(),
    );
  }

  Future<void> _retryScaleConnection() async {
    if (!mounted || _scaleRetrying || _openingScaleSettings) {
      return;
    }
    if (_scale.hasRecentValidReading) {
      _handleScaleReconnected();
      return;
    }

    _scaleRetrying = true;
    try {
      final ready = await _scale.ensureReady();
      if (!mounted) return;
      if (!ready) {
        if (!_scaleDialogShowing) {
          await _showScaleConnectionIssue(
            _scale.lastErrorRx.value.isEmpty
                ? '電子秤に接続できません。接続ポートと通信設定を確認してください。'
                : _scale.lastErrorRx.value,
          );
        }
        return;
      }
      _handleScaleReconnected();
    } catch (e) {
      debugPrint('称重页后台重连电子秤失败: $e');
    } finally {
      _scaleRetrying = false;
    }
  }

  void _handleScaleReconnected() {
    _stopScaleRetryLoop();
    _attachScaleReadingWorker();
    logI('[麻辣烫] 电子秤后台重连成功，恢复称重监听');
    if (_scaleDialogShowing && Get.isDialogOpen == true) {
      Get.back(result: false);
    }
  }

  void _stopScaleRetryLoop() {
    _scaleRetryTimer?.cancel();
    _scaleRetryTimer = null;
  }

  @override
  void dispose() {
    _tongsAnimation.dispose();
    try {
      _scaleWorker?.dispose();
      _scaleWorker = null;
      _scaleConnectionWorker?.dispose();
      _scaleConnectionWorker = null;
      _stopScaleRetryLoop();
      _scale.clearReading();
    } catch (e) {
      debugPrint('称重页 dispose 清理异常: $e');
    }
    // 异步释放 USB，不 await、不抛错，避免 dispose 崩溃
    ScaleSerialService.releaseUsbSafely(reason: 'weigh_page_dispose');
    super.dispose();
  }

  void _cancel() {
    logI('[麻辣烫] 称重页点击返回');
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Get.back();
    }
  }

  void _skip() {
    logI('[麻辣烫] 称重页点击跳过');
    widget.onSkip?.call();
  }

  void _resetWeight() {
    logI('[麻辣烫] 称重页点击重新称重');
    _scale.clearReading();
    setState(() {
      _input = '0';
      _stable = false;
      _useManualWeight = false;
    });
    _updateTongsAnimation();
  }

  void _confirm() {
    if (!_canConfirm) {
      logI('[麻辣烫] 称重页下一步不可用 weight=$_weight price=$_price');
      return;
    }
    logI('[麻辣烫] 称重页点击下一步 weight=${_weight}g price=¥$_price');
    Get.back();
    // 传向下取整后的克重与价格，入车/下单与显示一致
    widget.onConfirm(_weight, _price);
  }

  void _openManualInputKeyboard() {
    logI('[麻辣烫] 称重页打开手动输入');
    Get.dialog(
      NumberKeyboardDialog(
        title: 'spicy_weigh_manual_input_title'.tr,
        initialValue: _hasWeight ? _input.split('.').first : '',
        // 称重页：圆角更小、数字更大、输入框更高
        borderRadius: 3,
        inputFontSize: 40,
        inputMinHeight: 72,
        onConfirm: (value) {
          if (value.isEmpty) return;
          final grams = double.tryParse(value);
          if (grams == null || grams <= 0) return;
          logI('[麻辣烫] 手动输入重量 ${grams}g');
          setState(() {
            _useManualWeight = true;
            _stable = true;
            // 手动输入也向下取整
            _input = grams <= 0 ? '0' : grams.floor().toString();
          });
          _updateTongsAnimation();
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAFF),
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              const SpicyHotPotStepHeader(currentStep: 2),
              Expanded(child: _buildContent()),
              _buildWeighBottomBar(),
            ],
          ),
          _buildTongsOverlay(),
        ],
      ),
    );
  }

  /// 页面最上层绘制夹子，跟随盆的位置，避免被局部 Stack/滚动区裁切。
  Widget _buildTongsOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CompositedTransformFollower(
          link: _scaleVisualLink,
          showWhenUnlinked: false,
          child: Align(
            alignment: Alignment.topLeft,
            child: TweenAnimationBuilder<double>(
              tween:
                  Tween<double>(end: math.min(_weight / 900, 1.0).toDouble()),
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              builder: (_, animatedLoad, __) => SizedBox(
                width: ScreenAdapter.width(680),
                height: ScreenAdapter.height(436),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedBuilder(
                      animation: _tongsAnimation,
                      child: Image.asset(
                        'assets/images/public/jiazi.png',
                        fit: BoxFit.contain,
                      ),
                      builder: (_, child) {
                        final progress = _tongsAnimation.value;
                        final lift = Curves.easeInOut.transform(
                          ((progress - 0.18) / 0.52).clamp(0.0, 1.0).toDouble(),
                        );
                        final opacity = progress < 0.12
                            ? progress / 0.12
                            : progress > 0.82
                                ? (1 - progress) / 0.18
                                : 1.0;
                        // 二次贝塞尔：盆内 → 向上抬起 → 右侧落点，不旋转图片。
                        final start = Offset(310, 65 + animatedLoad * 12);
                        final control = Offset(355, -65 + animatedLoad * 12);
                        final end = Offset(485, 35 + animatedLoad * 12);
                        final position = start * ((1 - lift) * (1 - lift)) +
                            control * (2 * (1 - lift) * lift) +
                            end * (lift * lift);
                        return Positioned(
                          left: ScreenAdapter.width(
                              (position.dx - 82.5) * 680 / 560),
                          top: ScreenAdapter.height(
                              (position.dy - 82.5) * 436 / 360),
                          width: ScreenAdapter.width(165 * 680 / 560),
                          height: ScreenAdapter.height(165 * 436 / 360),
                          child: Opacity(opacity: opacity, child: child),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextStyle _weighText(double size, Color color,
          [FontWeight weight = FontWeight.w600]) =>
      TextStyle(
          fontSize: ScreenAdapter.fontSize(size),
          color: color,
          fontFamily: GFont.getFontFamily(),
          fontWeight: weight);

  Widget _buildWeighBottomBar() {
    Widget button(String label, VoidCallback? action, Color background,
            Color foreground, int flex) =>
        Expanded(
            flex: flex,
            child: KioskTap(
                onTap: action,
                child: Container(
                  height: ScreenAdapter.height(110),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                          color: background == Colors.white
                              ? const Color(0xFFE5E7EB)
                              : background)),
                  padding:
                      EdgeInsets.symmetric(horizontal: ScreenAdapter.width(28)),
                  child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(label,
                          style: _weighText(28, foreground, FontWeight.w800))),
                )));
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(16),
          vertical: ScreenAdapter.height(24)),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: SafeArea(
          top: false,
          child: Row(children: [
            button('settlement_back'.tr, _cancel, Colors.white,
                const Color(0xFF222222), 10),
            SizedBox(width: ScreenAdapter.width(100)),
            if (widget.onSkip != null) ...[
              button('spicy_weigh_skip'.tr, _skip, const Color(0xFFFF7100),
                  Colors.white, 14),
            ],
            SizedBox(width: ScreenAdapter.width(20)),
            button(
                _nextLabel,
                _canConfirm ? _confirm : null,
                _canConfirm ? const Color(0xFF00BC88) : const Color(0xFFCBD5E1),
                Colors.white,
                10),
          ])),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (_, constraints) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            ScreenAdapter.width(44),
            ScreenAdapter.height(24),
            ScreenAdapter.width(44),
            ScreenAdapter.height(28)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                math.max(0.0, constraints.maxHeight - ScreenAdapter.height(52)),
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('spicy_weigh_title'.tr,
                    textAlign: TextAlign.center,
                    style: _weighText(
                        46, const Color(0xFF1E293B), FontWeight.w900)),
                SizedBox(height: ScreenAdapter.height(32)),
                Visibility(
                  visible: _hasWeight,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: ScreenAdapter.width(30),
                        vertical: ScreenAdapter.height(24)),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEA),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                            color: const Color(0xFFF00000), width: 3),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 4,
                              offset: Offset(0, 2))
                        ]),
                    child: Row(children: [
                      Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.error,
                              color: const Color(0xFFF00000),
                              size: ScreenAdapter.fontSize(64))),
                      SizedBox(width: ScreenAdapter.width(24)),
                      Expanded(
                          child: Text('spicy_weigh_remove_tongs'.tr,
                              style: _weighText(36, const Color(0xFFF00000),
                                  FontWeight.w900))),
                    ]),
                  ),
                ),
                // 给取出夹子的弧线动画留出空间。
                SizedBox(height: ScreenAdapter.height(106)),
                _buildScaleVisual(),
                SizedBox(height: ScreenAdapter.height(24)),
                _buildPriceCard(),
                SizedBox(height: ScreenAdapter.height(28)),
                KioskTap(
                    onTap: _resetWeight,
                    child: Text('spicy_weigh_remeasure'.tr,
                        style: _weighText(
                                27, const Color(0xFF008580), FontWeight.w800)
                            .copyWith(
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF008580)))),
                if (_minAmountYen > 0) ...[
                  SizedBox(height: ScreenAdapter.height(16)),
                  _buildMinAmountTip(),
                ],
                if (_manualInputAllowed) ...[
                  SizedBox(height: ScreenAdapter.height(20)),
                  OutlinedButton(
                      onPressed: _openManualInputKeyboard,
                      child: Text('spicy_weigh_manual_input'.tr,
                          style: _weighText(24, kSpicyAccent))),
                ],
              ]),
        ),
      ),
    );
  }

  Widget _buildPriceCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(36),
          vertical: ScreenAdapter.height(28)),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 2))
          ]),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_hasWeight && !_stable) ...[
            SizedBox(
                width: ScreenAdapter.width(18),
                height: ScreenAdapter.width(18),
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFF71839E))),
            SizedBox(width: ScreenAdapter.width(12)),
          ],
          Flexible(child: _buildStatusLine()),
        ]),
        SizedBox(height: ScreenAdapter.height(20)),
        FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('¥${formatMoney(_price)}',
                style: _weighText(94, const Color(0xFFF00000), FontWeight.w900)
                    .copyWith(height: 1.1))),
        SizedBox(height: ScreenAdapter.height(22)),
        const Divider(color: Color(0xFFE2E8F0)),
        SizedBox(height: ScreenAdapter.height(10)),
        Wrap(
            alignment: WrapAlignment.center,
            spacing: ScreenAdapter.width(16),
            runSpacing: 6,
            children: [
              Text(
                  '${'spicy_weigh_unit_price'.tr} ¥${widget.unitPricePer100g}/100g',
                  style: _weighText(30.8, const Color(0xFF64748B))),
              Text('×', style: _weighText(33.6, const Color(0xFF94A3B8))),
              Text('${'spicy_weigh_weight_label'.tr} ${_displayWeight}g',
                  style: _weighText(
                      30.8, const Color(0xFF1E293B), FontWeight.w800)),
            ]),
        if (_tareGrams > 0) ...[
          SizedBox(height: ScreenAdapter.height(8)),
          _buildTareTip()
        ],
        if (Get.isRegistered<SpicyHotPotCheckoutController>())
          Obx(() {
            final no =
                Get.find<SpicyHotPotCheckoutController>().tableNo.value.trim();
            return no.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                    child: Text('spicy_bowl_table_no'.trParams({'no': no}),
                        style: _weighText(20, const Color(0xFF64748B))));
          }),
      ]),
    );
  }

  /// 碗 + 秤示意：重量变化时让碗轻微下压，克重实时显示在秤面黑屏上
  Widget _buildScaleVisual() {
    final load = math.min(_weight / 900, 1.0).toDouble();
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: load),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (_, animatedLoad, __) {
        return CompositedTransformTarget(
          link: _scaleVisualLink,
          child: SizedBox(
            width: ScreenAdapter.width(680),
            height: ScreenAdapter.height(436),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(
                    ScreenAdapter.width(680),
                    ScreenAdapter.height(436),
                  ),
                  painter: _CartoonScalePainter(
                    load: animatedLoad,
                    hasWeight: _hasWeight,
                    stable: _stable,
                  ),
                ),
                Positioned(
                  left: ScreenAdapter.width(188),
                  right: ScreenAdapter.width(188),
                  bottom: ScreenAdapter.height(72),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Text(
                      '${_displayWeight} g',
                      key: ValueKey(_displayWeight),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(
                        color: _stable
                            ? const Color(0xFFB8FFD2)
                            : const Color(0xFFFFFFFF),
                        fontSize: ScreenAdapter.fontSize(46),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        shadows: const [
                          Shadow(
                            color: Color(0x9900FF88),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusLine() {
    return Obx(() {
      // 同时订阅连接态与重量，避免仅依赖本地 bool 时 Obx 判定无订阅
      final linked = _scale.hasRecentValidReading;
      final _ = _scale.weightRx.value;
      final belowMin = _hasWeight && _stable && !_meetsMinAmount;
      final showStable = _canConfirm;
      final settling = _hasWeight && !_stable;
      String tip;
      if (_useManualWeight && _meetsMinAmount) {
        tip = 'spicy_weigh_manual_ready'.tr;
      } else if (!linked) {
        tip = 'spicy_weigh_scale_disconnected'.tr;
      } else if (belowMin) {
        tip =
            'spicy_weigh_below_min_tip'.trParams({'amount': '$_minAmountYen'});
      } else if (showStable) {
        tip = 'spicy_weigh_stable'.tr;
      } else if (settling) {
        tip = 'spicy_weigh_settling'.tr;
      } else {
        tip = 'spicy_weigh_subtitle'.tr;
      }
      final color = belowMin
          ? const Color(0xFFE64340)
          : (_useManualWeight || showStable)
              ? const Color(0xFF4CAF50)
              : settling
                  ? const Color(0xFF71839E)
                  : const Color(0xFF71839E);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              tip,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: ScreenAdapter.fontSize(32.2),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      );
    });
  }

  /// 最低金额 > 0 时提示需达到多少才能下一步
  Widget _buildMinAmountTip() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(20),
        vertical: ScreenAdapter.height(14),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC80), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: const Color(0xFFE65100), size: ScreenAdapter.fontSize(26)),
          SizedBox(width: ScreenAdapter.width(10)),
          Flexible(
            child: Text(
              'spicy_weigh_min_amount_hint'
                  .trParams({'amount': '$_minAmountYen'}),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFE65100),
                fontSize: ScreenAdapter.fontSize(24),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 皮重 > 0 时：说明屏幕重量已扣除容器，会比电子秤显示更轻
  Widget _buildTareTip() {
    final tareText = _tareGrams == _tareGrams.roundToDouble()
        ? _tareGrams.toInt().toString()
        : _tareGrams.toStringAsFixed(1);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(20),
        vertical: ScreenAdapter.height(12),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCE93D8), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline,
              color: const Color(0xFF7B1FA2), size: ScreenAdapter.fontSize(24)),
          SizedBox(width: ScreenAdapter.width(10)),
          Flexible(
            child: Text(
              'spicy_weigh_tare_hint'.trParams({'tare': tareText}),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF6A1B9A),
                fontSize: ScreenAdapter.fontSize(22),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartoonScalePainter extends CustomPainter {
  final double load;
  final bool hasWeight;
  final bool stable;

  const _CartoonScalePainter({
    required this.load,
    required this.hasWeight,
    required this.stable,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 560, size.height / 360);

    _drawSoftGround(canvas);
    _drawScaleBody(canvas);
    _drawPlate(canvas);
    _drawBowl(canvas);
    _drawDisplay(canvas);

    canvas.restore();
  }

  void _drawSoftGround(Canvas canvas) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x26000000),
          const Color(0x00000000),
        ],
      ).createShader(const Rect.fromLTWH(70, 300, 420, 52));
    canvas.drawOval(const Rect.fromLTWH(70, 300, 420, 52), paint);
  }

  void _drawScaleBody(Canvas canvas) {
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(66, 186, 428, 132),
      const Radius.circular(28),
    );
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF2F5F6),
          Color(0xFFB9C3C7),
          Color(0xFF7F8C92),
        ],
      ).createShader(body.outerRect);
    canvas.drawRRect(body.shift(const Offset(0, 8)),
        Paint()..color = const Color(0x22000000));
    canvas.drawRRect(body, paint);
    canvas.drawRRect(
      body.deflate(2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF6F7A80),
    );

    final leftFoot = RRect.fromRectAndRadius(
      const Rect.fromLTWH(110, 310, 68, 12),
      const Radius.circular(8),
    );
    final rightFoot = RRect.fromRectAndRadius(
      const Rect.fromLTWH(382, 310, 68, 12),
      const Radius.circular(8),
    );
    final footPaint = Paint()..color = const Color(0xFF69747A);
    canvas.drawRRect(leftFoot, footPaint);
    canvas.drawRRect(rightFoot, footPaint);
  }

  void _drawPlate(Canvas canvas) {
    final y = 160 + load * 12;
    final shadowPaint = Paint()
      ..color =
          Color.lerp(const Color(0x22000000), const Color(0x44000000), load)!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(112, y + 14, 336, 24),
        const Radius.circular(18),
      ),
      shadowPaint,
    );
    final plate = RRect.fromRectAndRadius(
      Rect.fromLTWH(100, y, 360, 30),
      const Radius.circular(16),
    );
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFE8EEF0),
          Color(0xFF9FACB2),
          Color(0xFF657176),
        ],
      ).createShader(plate.outerRect);
    canvas.drawRRect(plate, paint);
    canvas.drawRRect(
      plate.deflate(1.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFFFFFFF),
    );
  }

  void _drawBowl(Canvas canvas) {
    final bowlOffset = load * 12;
    final bowlTop = 45 + bowlOffset;
    final bowlShadow = Paint()..color = const Color(0x1F000000);
    canvas.drawOval(Rect.fromLTWH(154, bowlTop + 110, 252, 40), bowlShadow);

    final bodyPath = Path()
      ..moveTo(136, bowlTop + 42)
      ..cubicTo(154, bowlTop + 138, 190, bowlTop + 166, 280, bowlTop + 166)
      ..cubicTo(370, bowlTop + 166, 406, bowlTop + 138, 424, bowlTop + 42)
      ..close();
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFFFF),
          const Color(0xFFF1E8D8),
          const Color(0xFFD7C9B3),
        ],
      ).createShader(Rect.fromLTWH(126, bowlTop + 38, 308, 132));
    canvas.drawPath(bodyPath.shift(const Offset(0, 8)),
        Paint()..color = const Color(0x16000000));
    canvas.drawPath(bodyPath, bodyPaint);
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFFD3C5AC),
    );

    final rim = Rect.fromLTWH(126, bowlTop, 308, 88);
    canvas.drawOval(
      rim,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF6F1E8),
          ],
        ).createShader(rim),
    );
    canvas.drawOval(
      rim.deflate(12),
      Paint()..color = const Color(0xFFF3ECDF),
    );
    canvas.drawOval(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFE3D6C2),
    );
    canvas.drawArc(
      rim.deflate(14),
      math.pi * 0.05,
      math.pi * 0.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xCCFFFFFF),
    );

    if (hasWeight) {
      _drawIngredients(canvas, bowlTop);
    }
  }

  void _drawIngredients(Canvas canvas, double bowlTop) {
    final colors = [
      const Color(0xFF44C2B8),
      const Color(0xFFE64340),
      const Color(0xFFFFC857),
      const Color(0xFF7AC943),
      const Color(0xFFFF8A3D),
    ];
    final points = [
      const Offset(210, 58),
      const Offset(250, 74),
      const Offset(292, 60),
      const Offset(330, 78),
      const Offset(364, 58),
      const Offset(226, 92),
      const Offset(312, 94),
    ];
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final radius = 8.0 + (i % 3) * 2;
      canvas.drawCircle(
        Offset(p.dx, bowlTop + p.dy),
        radius,
        Paint()..color = colors[i % colors.length],
      );
    }
  }

  void _drawDisplay(Canvas canvas) {
    final display = RRect.fromRectAndRadius(
      const Rect.fromLTWH(116, 234, 328, 78),
      const Radius.circular(14),
    );
    canvas.drawRRect(display, Paint()..color = const Color(0xFF101312));
    canvas.drawRRect(
      display.deflate(2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = stable ? const Color(0xFF44C2B8) : const Color(0xFF393D3B),
    );

    final shine = Path()
      ..moveTo(138, 250)
      ..lineTo(424, 250)
      ..lineTo(390, 272)
      ..lineTo(150, 272)
      ..close();
    canvas.drawPath(shine, Paint()..color = const Color(0x12FFFFFF));
  }

  @override
  bool shouldRepaint(covariant _CartoonScalePainter oldDelegate) {
    return oldDelegate.load != load ||
        oldDelegate.hasWeight != hasWeight ||
        oldDelegate.stable != stable;
  }
}
