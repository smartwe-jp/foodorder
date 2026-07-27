import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/scale_serial_service.dart';
import '../../../services/spicy_weigh_settings.dart';
import '../../../widget/KioskTap.dart';
import '../../../widget/NumberKeyboard.dart';
import 'widgets/spicy_hot_pot_chrome.dart';

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

class _SpicyWeighPageState extends State<SpicyWeighPage> {
  String _input = '0';
  bool _stable = false;
  /// 系统设置「手動入力」为开时显示按钮
  bool _manualInputAllowed = false;
  /// 当前重量是否来自手动键盘（避免串口覆盖；手动值为净重，不再减皮重）
  bool _useManualWeight = false;
  /// 皮重（克），来自设置，默认 0
  double _tareGrams = 0;
  Worker? _scaleWorker;

  ScaleSerialService get _scale {
    if (!Get.isRegistered<ScaleSerialService>()) {
      Get.put(ScaleSerialService(), permanent: true);
    }
    return Get.find<ScaleSerialService>();
  }

  double get _weight => double.tryParse(_input) ?? 0;
  int get _price =>
      _weight > 0 ? ((_weight / 100) * widget.unitPricePer100g).ceil() : 0;
  bool get _hasWeight => _weight > 0;
  bool get _canConfirm => _hasWeight && _stable;

  @override
  void initState() {
    super.initState();
    _hideSystemKeyboard();
    _initWeigh();
  }

  Future<void> _initWeigh() async {
    await _loadWeighSettings();
    await _startScaleListen();
  }

  Future<void> _loadWeighSettings() async {
    final manual = await SpicyWeighSettings.loadManualAllowed();
    final tare = await SpicyWeighSettings.loadTareGrams();
    if (!mounted) return;
    setState(() {
      _manualInputAllowed = manual;
      _tareGrams = tare;
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
    _scale.clearReading();
    try {
      if (!_scale.connectedRx.value) {
        await _scale.connect(persist: false);
      }
    } catch (e) {
      debugPrint('称重页连接电子秤失败: $e');
    }
    _scaleWorker = ever<ScaleReading?>(_scale.weightRx, (reading) {
      if (!mounted || reading == null) return;
      // 手动录入中不覆盖
      if (_useManualWeight) return;
      final net = SpicyWeighSettings.netGrams(reading.grams, _tareGrams);
      setState(() {
        _stable = reading.isStable;
        _input = net == net.roundToDouble()
            ? net.toStringAsFixed(0)
            : net.toStringAsFixed(1);
      });
    });
  }

  @override
  void dispose() {
    try {
      _scaleWorker?.dispose();
      _scaleWorker = null;
      _scale.clearReading();
    } catch (e) {
      debugPrint('称重页 dispose 清理异常: $e');
    }
    // 异步释放 USB，不 await、不抛错，避免 dispose 崩溃
    ScaleSerialService.releaseUsbSafely(reason: 'weigh_page_dispose');
    super.dispose();
  }

  void _cancel() => widget.onCancel != null ? widget.onCancel!() : Get.back();

  void _skip() => widget.onSkip?.call();

  void _resetWeight() {
    _scale.clearReading();
    setState(() {
      _input = '0';
      _stable = false;
      _useManualWeight = false;
    });
  }

  void _confirm() {
    if (!_canConfirm) return;
    Get.back();
    widget.onConfirm(_weight, _price);
  }

  void _openManualInputKeyboard() {
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
          setState(() {
            _useManualWeight = true;
            _stable = true;
            _input = grams == grams.roundToDouble()
                ? grams.toStringAsFixed(0)
                : grams.toStringAsFixed(1);
          });
        },
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSpicyBg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              const SpicyHotPotStepHeader(currentStep: 2),
              Expanded(child: _buildContent()),
              SpicyHotPotBottomBar(
                onBack: _cancel,
                backLabel: 'settlement_back'.tr,
                onMiddle: widget.onSkip != null ? _skip : null,
                middleLabel:
                    widget.onSkip != null ? 'spicy_weigh_skip'.tr : null,
                onNext: _confirm,
                nextLabel: _hasWeight && !_stable
                    ? 'spicy_weigh_waiting_stable'.tr
                    : 'next_button'.tr,
                nextEnabled: _canConfirm,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(40),
        ScreenAdapter.height(28),
        ScreenAdapter.width(40),
        ScreenAdapter.height(16),
      ),
      child: Column(
        children: [
          Text(
            'spicy_weigh_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kSpicyText,
              fontSize: ScreenAdapter.fontSize(42),
              fontFamily: GFont.getFontFamily(),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: ScreenAdapter.height(18)),
          /*Text(
            'spicy_weigh_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: kSpicyGrey,
              fontSize: ScreenAdapter.fontSize(24),
              fontFamily: GFont.getFontFamily(),
            ),
          ),*/
          SizedBox(height: ScreenAdapter.height(42)),
          _buildUnitPriceBadge(),
          SizedBox(height: ScreenAdapter.height(78)),
          _buildScaleVisual(),
          SizedBox(height: ScreenAdapter.height(14)),
          _buildStatusLine(),
          if (_hasWeight) ...[
            SizedBox(height: ScreenAdapter.height(15)),
            Text(
              '¥ $_price',
              style: TextStyle(
                color: const Color(0xFFE64340),
                fontSize: ScreenAdapter.fontSize(86),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ],
          SizedBox(height: ScreenAdapter.height(48)),
          _buildInfoTip(),
          SizedBox(height: ScreenAdapter.height(16)),
          KioskTap(
            onTap: _resetWeight,
            child: Text(
              'spicy_weigh_remeasure'.tr,
              style: TextStyle(
                color: kSpicyAccent,
                fontSize: ScreenAdapter.fontSize(22),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: kSpicyAccent,
              ),
            ),
          ),
          // 系统设置「手動入力」开启后显示
          if (_manualInputAllowed) ...[
            SizedBox(height: ScreenAdapter.height(20)),
            KioskTap(
              onTap: _openManualInputKeyboard,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenAdapter.width(36),
                  vertical: ScreenAdapter.height(16),
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kSpicyAccent, width: 2),
                ),
                child: Text(
                  'spicy_weigh_manual_input'.tr,
                  style: TextStyle(
                    color: kSpicyAccent,
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnitPriceBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(36),
        vertical: ScreenAdapter.height(16),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6EE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFC48A), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'spicy_weigh_unit_price'.tr,
            style: TextStyle(
              color: const Color(0xFF9A5B12),
              fontSize: ScreenAdapter.fontSize(22),
              fontFamily: GFont.getFontFamily(),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: ScreenAdapter.width(14)),
          Text(
            '¥${widget.unitPricePer100g}',
            style: TextStyle(
              color: const Color(0xFF6F461A),
              fontSize: ScreenAdapter.fontSize(52),
              fontFamily: GFont.getFontFamily(),
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
          SizedBox(width: ScreenAdapter.width(6)),
          Padding(
            padding: EdgeInsets.only(bottom: ScreenAdapter.height(4)),
            child: Text(
              '/100g',
              style: TextStyle(
                color: const Color(0xFF9A5B12),
                fontSize: ScreenAdapter.fontSize(24),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
        return SizedBox(
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
                    '${_input} g',
                    key: ValueKey(_input),
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
        );
      },
    );
  }

  Widget _buildStatusLine() {
    return Obx(() {
      // 同时订阅连接态与重量，避免仅依赖本地 bool 时 Obx 判定无订阅
      final linked = _scale.connectedRx.value;
      final _ = _scale.weightRx.value;
      final showStable = _canConfirm;
      final settling = _hasWeight && !_stable;
      String tip;
      if (_useManualWeight) {
        tip = 'spicy_weigh_manual_ready'.tr;
      } else if (!linked) {
        tip = 'spicy_weigh_scale_disconnected'.tr;
      } else if (showStable) {
        tip = 'spicy_weigh_stable'.tr;
      } else if (settling) {
        tip = 'spicy_weigh_settling'.tr;
      } else {
        tip = 'spicy_weigh_subtitle'.tr;
      }
      final color = (_useManualWeight || showStable)
          ? const Color(0xFF4CAF50)
          : settling
              ? const Color(0xFFFF9800)
              : kSpicyGrey;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: ScreenAdapter.width(12),
            height: ScreenAdapter.width(12),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          SizedBox(width: ScreenAdapter.width(8)),
          Flexible(
            child: Text(
              tip,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: ScreenAdapter.fontSize(32),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildInfoTip() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(20),
        vertical: ScreenAdapter.height(14),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF8F7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline,
              color: kSpicyAccent, size: ScreenAdapter.fontSize(24)),
          SizedBox(width: ScreenAdapter.width(10)),
          Text(
            'spicy_weigh_container_tip'.tr,
            style: TextStyle(
              color: kSpicyGrey,
              fontSize: ScreenAdapter.fontSize(24),
              fontFamily: GFont.getFontFamily(),
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
