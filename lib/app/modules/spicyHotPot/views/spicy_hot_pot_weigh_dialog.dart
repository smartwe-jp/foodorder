import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../services/scale_serial_service.dart';
import '../../../services/spicy_weigh_settings.dart';
import '../../../widget/KioskTap.dart';
import '../controllers/spicy_hot_pot_checkout_controller.dart';
import 'spicy_bowl_scan_dialog.dart';
import 'widgets/spicy_hot_pot_chrome.dart';

const _kBg = Color(0xFFF5EFDE);
const _kRed = Color(0xFFC82333);
const _kText = Color(0xFF1A1A1A);
const _kGrey = Color(0xFF888888);
const _kBorder = Color(0xFFE0D5C5);

/// 麻辣烫称重输入弹窗（参考效果图：暖奶油背景 + 超大克重显示）
/// 重量实时填入（减皮重）；未稳定不可确认。建议秤 232-1 连续发送以便跟屏跳动。
class SpicyWeighDialog extends StatefulWidget {
  final Map itemData;
  final int unitPricePer100g;
  final Function(double weight, int price) onConfirm;

  const SpicyWeighDialog({
    Key? key,
    required this.itemData,
    required this.unitPricePer100g,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<SpicyWeighDialog> createState() => _SpicyWeighDialogState();
}

class _SpicyWeighDialogState extends State<SpicyWeighDialog> {
  String _input = '0';
  bool _stable = false;
  double _tareGrams = 0;
  /// 最低额度（日元），0＝不限制
  int _minAmountYen = 0;
  Worker? _scaleWorker;

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
  String get _displayWeight => _weight <= 0 ? '0' : _weight.toInt().toString();
  bool get _meetsMinAmount =>
      _minAmountYen <= 0 || _price >= _minAmountYen;
  bool get _canConfirm => _hasWeight && _stable && _meetsMinAmount;

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final result = await _ensureBowlScanIfNeeded();
    if (!mounted) return;
    switch (result.action) {
      case SpicyBowlScanAction.back:
        Get.back();
        if (Get.isRegistered<SpicyHotPotCheckoutController>()) {
          Get.find<SpicyHotPotCheckoutController>().goHome();
        }
        return;
      case SpicyBowlScanAction.skip:
        Get.back();
        if (Get.isRegistered<SpicyHotPotCheckoutController>()) {
          Get.find<SpicyHotPotCheckoutController>().skipWeighToSellMode();
        }
        return;
      case SpicyBowlScanAction.proceed:
        await _loadTareAndStart();
        return;
    }
  }

  Future<SpicyBowlScanResult> _ensureBowlScanIfNeeded() async {
    if (!Get.isRegistered<SpicyHotPotCheckoutController>()) {
      return const SpicyBowlScanResult.proceed();
    }
    return Get.find<SpicyHotPotCheckoutController>().ensureBowlScanned();
  }

  Future<void> _loadTareAndStart() async {
    final tare = await SpicyWeighSettings.loadTareGrams();
    final minYen = await SpicyWeighSettings.loadMinAmountYen();
    if (mounted) {
      setState(() {
        _tareGrams = tare;
        _minAmountYen = minYen;
      });
    }
    await _startScaleListen();
  }

  Future<void> _startScaleListen() async {
    _scale.clearReading();
    try {
      if (!_scale.connectedRx.value) {
        await _scale.connect(persist: false);
      }
    } catch (e) {
      debugPrint('称重弹窗连接电子秤失败: $e');
    }
    _scaleWorker = ever<ScaleReading?>(_scale.weightRx, (reading) {
      if (!mounted || reading == null) return;
      final net = SpicyWeighSettings.netGrams(reading.grams, _tareGrams);
      setState(() {
        _stable = reading.isStable;
        // 实时重量向下取整显示
        _input = net <= 0 ? '0' : net.floor().toString();
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
      debugPrint('称重弹窗 dispose 清理异常: $e');
    }
    ScaleSerialService.releaseUsbSafely(reason: 'weigh_dialog_dispose');
    super.dispose();
  }

  void _confirm() {
    if (!_canConfirm) return;
    Get.back();
    // 传向下取整后的克重与价格，入车/下单与显示一致
    widget.onConfirm(_weight, _price);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.itemData['mainTitle'] ?? '';
    final displayWeight = _displayWeight;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(30),
        vertical: ScreenAdapter.height(50),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(ScreenAdapter.width(20)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x33000000),
                blurRadius: 28,
                offset: Offset(0, 10)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTopArea(title),
            const SpicyTableNoBanner(),
            _buildWeightBlock(displayWeight),
            _buildScaleStatus(),
            _buildUnitPriceHint(),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildScaleStatus() {
    return Obx(() {
      // 同时订阅连接态与重量，保证 Obx 始终有合法订阅
      final linked = _scale.connectedRx.value;
      final _ = _scale.weightRx.value;
      final belowMin = _hasWeight && _stable && !_meetsMinAmount;
      final showStable = _canConfirm;
      final settling = _hasWeight && !_stable;
      String tip;
      if (!linked) {
        tip = '电子秤未连接';
      } else if (belowMin) {
        tip = 'spicy_weigh_below_min_tip'
            .trParams({'amount': '$_minAmountYen'});
      } else if (showStable) {
        tip = '重量已稳定';
      } else if (settling) {
        tip = '重量跳动中，请等待稳定…';
      } else {
        tip = '请将菜品放上称重台';
      }
      return Padding(
        padding: EdgeInsets.only(bottom: ScreenAdapter.height(8)),
        child: Text(
          tip,
          style: TextStyle(
            color: belowMin
                ? const Color(0xFFE64340)
                : showStable
                    ? const Color(0xFF4CAF50)
                    : settling
                        ? const Color(0xFFFF9800)
                        : _kGrey,
            fontSize: ScreenAdapter.fontSize(22),
            fontFamily: GFont.getFontFamily(),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    });
  }

  // 顶部：步骤指示器 + 标题 + 菜名
  Widget _buildTopArea(String title) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(36),
        ScreenAdapter.height(28),
        ScreenAdapter.width(36),
        ScreenAdapter.height(20),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(ScreenAdapter.width(20))),
        border: Border(bottom: BorderSide(color: _kBorder, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 步骤指示器
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _buildStepIndicator(1),
          ),
          SizedBox(height: ScreenAdapter.height(16)),
          // STEP 标签
          Text(
            'STEP 01 · 取菜称重',
            style: TextStyle(
              color: _kRed,
              fontSize: ScreenAdapter.fontSize(22),
              fontFamily: GFont.getFontFamily(),
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: ScreenAdapter.height(6)),
          // 菜名 + 单价
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _kText,
                    fontSize: ScreenAdapter.fontSize(34),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenAdapter.width(14),
                  vertical: ScreenAdapter.height(5),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F4),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kRed.withAlpha(80)),
                ),
                child: Text(
                  '¥${widget.unitPricePer100g} / 100g',
                  style: TextStyle(
                    color: _kRed,
                    fontSize: ScreenAdapter.fontSize(22),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 克重 + 金额大号显示
  Widget _buildWeightBlock(String displayWeight) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(36),
        ScreenAdapter.height(20),
        ScreenAdapter.width(36),
        ScreenAdapter.height(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 重量
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  displayWeight,
                  style: TextStyle(
                    color: _hasWeight ? _kText : _kGrey,
                    fontSize: ScreenAdapter.fontSize(88),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: ScreenAdapter.height(12)),
                  child: Text(
                    ' g',
                    style: TextStyle(
                      color: _kGrey,
                      fontSize: ScreenAdapter.fontSize(34),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 金额
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _hasWeight ? '¥ ${formatMoney(_price)}' : '¥ ---',
                style: TextStyle(
                  color: _hasWeight ? _kRed : _kGrey,
                  fontSize: ScreenAdapter.fontSize(44),
                  fontFamily: GFont.getFontFamily(),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '合計金額',
                style: TextStyle(
                  color: _kGrey,
                  fontSize: ScreenAdapter.fontSize(20),
                  fontFamily: GFont.getFontFamily(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 单价提示（虚线边框）
  Widget _buildUnitPriceHint() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        ScreenAdapter.width(36),
        ScreenAdapter.height(12),
        ScreenAdapter.width(36),
        ScreenAdapter.height(4),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(20),
        vertical: ScreenAdapter.height(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFD4A017),
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline,
              color: Color(0xFFD4A017), size: 18),
          SizedBox(width: ScreenAdapter.width(8)),
          Expanded(
            child: Text(
              '单价 ¥${widget.unitPricePer100g} / 100g · 重量以称重台读数为准',
              style: TextStyle(
                color: const Color(0xFF7A5C00),
                fontSize: ScreenAdapter.fontSize(20),
                fontFamily: GFont.getFontFamily(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 底部按钮
  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(36),
        ScreenAdapter.height(16),
        ScreenAdapter.width(36),
        ScreenAdapter.height(28),
      ),
      child: Row(
        children: [
          // キャンセル
          SizedBox(
            width: ScreenAdapter.width(200),
            child: KioskTap(
              onTap: () => Get.back(),
              child: Container(
                height: ScreenAdapter.height(92),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kBorder, width: 1.5),
                ),
                child: Text(
                  'キャンセル',
                  style: TextStyle(
                    color: _kGrey,
                    fontSize: ScreenAdapter.fontSize(24),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenAdapter.width(16)),
          // 確認 → 選口味
          Expanded(
            child: KioskTap(
              onTap: _canConfirm ? _confirm : null,
              child: Container(
                height: ScreenAdapter.height(92),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _canConfirm ? _kRed : const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _hasWeight && !_stable
                          ? '安定待ち…'
                          : (_hasWeight && _stable && !_meetsMinAmount)
                              ? 'spicy_weigh_below_min'.tr
                              : '重量確認，選口味',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenAdapter.fontSize(28),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: ScreenAdapter.width(8)),
                    Icon(Icons.arrow_forward,
                        color: Colors.white, size: ScreenAdapter.fontSize(28)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 步骤指示器（1=当前，2/3/4=待完成）
  List<Widget> _buildStepIndicator(int currentStep) {
    final widgets = <Widget>[];
    for (int i = 1; i <= 4; i++) {
      if (i > 1) {
        widgets.add(Container(
          width: ScreenAdapter.width(40),
          height: 1.5,
          margin: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(2)),
          color: const Color(0xFFD0C8B8),
        ));
      }
      final isDone = i < currentStep;
      final isActive = i == currentStep;
      widgets.add(Container(
        width: ScreenAdapter.width(48),
        height: ScreenAdapter.width(48),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone
              ? const Color(0xFF4CAF50)
              : isActive
                  ? _kRed
                  : Colors.transparent,
          border: (!isDone && !isActive)
              ? Border.all(color: const Color(0xFFCCC4B4), width: 1.5)
              : null,
        ),
        child: Center(
          child: isDone
              ? Icon(Icons.check,
                  color: Colors.white, size: ScreenAdapter.fontSize(22))
              : Text(
                  '$i',
                  style: TextStyle(
                    color: isActive ? Colors.white : const Color(0xFFAA9E8E),
                    fontSize: ScreenAdapter.fontSize(22),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ));
    }
    return widgets;
  }
}
