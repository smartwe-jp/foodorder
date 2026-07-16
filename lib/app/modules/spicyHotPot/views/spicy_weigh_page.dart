import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../config/color.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/scale_serial_service.dart';
import '../../../services/showImage.dart';
import '../../../widget/KioskTap.dart';

const _kBg = Color(0xFFF5F5F5);
const _kAccent = Color(0xFF44C2B8);
const _kPrice = Color(0xFFE64340);
const _kText = Color(0xFF333333);
const _kGrey = Color(0xFF666666);
const _kMuted = Color(0xFF9E9E9E);
const _kBorder = Color(0xFFDCDCDC);
const _kCard = Color(0xFFFFFFFF);

/// 麻辣烫全屏称重页面（只有1个称重商品时使用）
///
/// 布局对齐 ModeView：主色顶栏 + STEP 条 + 纵向称重内容 + 三按钮底栏
/// 重量由电子秤实时填入；未稳定不可下一步。建议秤设 232-1 连续发送以便跟屏跳动。
class SpicyWeighPage extends StatefulWidget {
  final Map itemData;
  final int unitPricePer100g;
  final Function(double weight, int price) onConfirm;

  /// 返回/取消回调，不传则默认 Get.back()
  final VoidCallback? onCancel;

  /// 跳过称重：进入券卖模式菜单
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
  /// 有有效重量
  bool get _hasWeight => _weight > 0;
  /// 允许下一步：有重量且已稳定
  bool get _canConfirm => _hasWeight && _stable;

  @override
  void initState() {
    super.initState();
    _hideSystemKeyboard();
    _startScaleListen();
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
    // 实时跟秤：含 0g；稳定标志由服务软件判定
    _scaleWorker = ever<ScaleReading?>(_scale.weightRx, (reading) {
      if (!mounted || reading == null) return;
      setState(() {
        _stable = reading.isStable;
        final g = reading.grams;
        _input = g == g.roundToDouble()
            ? g.toStringAsFixed(0)
            : g.toStringAsFixed(1);
      });
    });
  }

  @override
  void dispose() {
    // 先清秤态（取消稳定计时），再卸 Worker，避免定时器回调 setState 已销毁页
    _scale.clearReading();
    _scaleWorker?.dispose();
    _scaleWorker = null;
    super.dispose();
  }

  void _cancel() => widget.onCancel != null ? widget.onCancel!() : Get.back();

  void _skip() {
    widget.onSkip?.call();
  }

  void _resetWeight() {
    _scale.clearReading();
    setState(() {
      _input = '0';
      _stable = false;
    });
  }

  void _confirm() {
    if (!_canConfirm) return;
    Get.back();
    widget.onConfirm(_weight, _price);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.itemData['mainTitle'] ?? '';
    final img = widget.itemData['homeImage']?.toString() ??
        widget.itemData['image']?.toString() ??
        '';

    return Scaffold(
      backgroundColor: _kBg,
      // 禁止系统软键盘顶起布局
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          _buildTopBar(),
          _buildStepHeader(title),
          Expanded(child: _buildContent(img)),
          _buildButtons(),
        ],
      ),
    );
  }

  // ==================== 主色顶栏（对齐 ModeView） ====================

  Widget _buildTopBar() {
    return Container(
      height: ScreenAdapter.height(100),
      padding: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(30)),
      color: Gcolor.primaryColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white, size: ScreenAdapter.fontSize(44)),
            onPressed: _cancel,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              '麻辣烫自助点餐',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenAdapter.fontSize(40),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: ScreenAdapter.width(60)),
        ],
      ),
    );
  }

  // ==================== STEP 信息条 ====================

  Widget _buildStepHeader(String title) {
    return Container(
      color: _kCard,
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(36),
        ScreenAdapter.height(22),
        ScreenAdapter.width(36),
        ScreenAdapter.height(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP 01 · 取菜称重1',
                  style: TextStyle(
                    color: _kAccent,
                    fontSize: ScreenAdapter.fontSize(22),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(4)),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.isNotEmpty ? title : '把菜放上称重台',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _kText,
                          fontSize: ScreenAdapter.fontSize(32),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenAdapter.width(12)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenAdapter.width(14),
                        vertical: ScreenAdapter.height(5),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F7F5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _kAccent.withAlpha(80)),
                      ),
                      child: Text(
                        '¥${widget.unitPricePer100g} / 100g',
                        style: TextStyle(
                          color: _kAccent,
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
          ),
          SizedBox(width: ScreenAdapter.width(16)),
          _buildStepIndicator(1),
        ],
      ),
    );
  }

  // ==================== 纵向称重内容 ====================

  Widget _buildContent(String img) {
    final displayWeight = _input;

    return Column(
      children: [
        Container(height: 1, color: _kBorder),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              ScreenAdapter.width(36),
              ScreenAdapter.height(28),
              ScreenAdapter.width(36),
              ScreenAdapter.height(12),
            ),
            child: Column(
              children: [
                // 商品图居中
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: img.isNotEmpty
                      ? publicShowMenuImage(
                          imgPath: img, imgWidth: 280, imgHeight: 280)
                      : Container(
                          width: ScreenAdapter.width(280),
                          height: ScreenAdapter.width(280),
                          color: const Color(0xFFF0F0F0),
                          child: Icon(
                            Icons.ramen_dining,
                            size: ScreenAdapter.fontSize(120),
                            color: _kMuted,
                          ),
                        ),
                ),
                SizedBox(height: ScreenAdapter.height(28)),
                // 超大克重
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayWeight,
                      style: TextStyle(
                        color: _hasWeight ? _kText : _kMuted,
                        fontSize: ScreenAdapter.fontSize(120),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: ScreenAdapter.height(14)),
                      child: Text(
                        ' g',
                        style: TextStyle(
                          color: _kGrey,
                          fontSize: ScreenAdapter.fontSize(40),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ScreenAdapter.height(12)),
                // 价格
                Text(
                  _hasWeight ? '¥ $_price' : '¥ ---',
                  style: TextStyle(
                    color: _hasWeight ? _kPrice : _kMuted,
                    fontSize: ScreenAdapter.fontSize(52),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(12)),
                // 实时状态：跳动中 / 已稳定 / 未放菜 / 未连接
                Obx(() {
                  final linked = _scale.connectedRx.value;
                  final showStable = _canConfirm;
                  final settling = _hasWeight && !_stable;
                  String tip;
                  if (!linked) {
                    tip = '电子秤未连接，请检查USB';
                  } else if (showStable) {
                    tip = '重量已稳定，可以下一步';
                  } else if (settling) {
                    tip = '重量跳动中，请等待稳定…';
                  } else {
                    tip = '请将菜品放上称重台';
                  }
                  final tipColor = showStable
                      ? const Color(0xFF4CAF50)
                      : settling
                          ? const Color(0xFFFF9800)
                          : _kGrey;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: ScreenAdapter.width(12),
                        height: ScreenAdapter.width(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: showStable
                              ? const Color(0xFF4CAF50)
                              : settling
                                  ? const Color(0xFFFF9800)
                                  : linked
                                      ? _kAccent
                                      : _kMuted,
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(8)),
                      Flexible(
                        child: Text(
                          tip,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: tipColor,
                            fontSize: ScreenAdapter.fontSize(24),
                            fontFamily: GFont.getFontFamily(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                SizedBox(height: ScreenAdapter.height(20)),
                _buildUnitPriceHint(),
                SizedBox(height: ScreenAdapter.height(16)),
                _buildResetWeightButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnitPriceHint() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(20),
        vertical: ScreenAdapter.height(12),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: _kGrey, size: ScreenAdapter.fontSize(22)),
          SizedBox(width: ScreenAdapter.width(8)),
          Expanded(
            child: Text(
              '単価 ¥${widget.unitPricePer100g} / 100g · 重量は称重台の読み取り値を基準とします',
              style: TextStyle(
                color: _kGrey,
                fontSize: ScreenAdapter.fontSize(22),
                fontFamily: GFont.getFontFamily(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetWeightButton() {
    return KioskTap(
      onTap: _resetWeight,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(24),
          vertical: ScreenAdapter.height(10),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBorder, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              color: _kAccent,
              size: ScreenAdapter.fontSize(28),
            ),
            SizedBox(width: ScreenAdapter.width(6)),
            Text(
              '重新称重',
              style: TextStyle(
                color: _kAccent,
                fontSize: ScreenAdapter.fontSize(24),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 底栏：やり直す | 跳过称重 | 確認して次へ ====================

  Widget _buildButtons() {
    return Container(
      color: _kCard,
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(28),
        ScreenAdapter.height(16),
        ScreenAdapter.width(28),
        ScreenAdapter.height(24),
      ),
      child: Row(
        children: [
          // やり直す
          SizedBox(
            width: ScreenAdapter.width(200),
            child: KioskTap(
              onTap: _cancel,
              child: Container(
                height: ScreenAdapter.height(92),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorder, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back,
                        color: _kGrey, size: ScreenAdapter.fontSize(26)),
                    SizedBox(width: ScreenAdapter.width(6)),
                    Text(
                      'やり直す',
                      style: TextStyle(
                        color: _kGrey,
                        fontSize: ScreenAdapter.fontSize(26),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenAdapter.width(12)),
          // 跳过称重
          SizedBox(
            width: ScreenAdapter.width(200),
            child: KioskTap(
              onTap: widget.onSkip != null ? _skip : null,
              child: Container(
                height: ScreenAdapter.height(92),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorder, width: 1.5),
                ),
                child: Text(
                  '跳过称重',
                  style: TextStyle(
                    color: _kGrey,
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenAdapter.width(12)),
          // 確認して次へ
          Expanded(
            child: KioskTap(
              onTap: _canConfirm ? _confirm : null,
              child: Container(
                height: ScreenAdapter.height(92),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _canConfirm ? _kAccent : const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _hasWeight && !_stable ? '安定待ち…' : '確認して次へ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ScreenAdapter.fontSize(28),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: ScreenAdapter.width(8)),
                    Icon(Icons.arrow_forward,
                        color: Colors.white,
                        size: ScreenAdapter.fontSize(28)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 4; i++) ...[
          if (i > 1)
            Container(
              width: ScreenAdapter.width(40),
              height: 1.5,
              margin: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(2)),
              color: _kBorder,
            ),
          Container(
            width: ScreenAdapter.width(48),
            height: ScreenAdapter.width(48),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < currentStep
                  ? const Color(0xFF4CAF50)
                  : i == currentStep
                      ? _kAccent
                      : Colors.transparent,
              border: (i >= currentStep)
                  ? Border.all(
                      color: i == currentStep ? _kAccent : _kBorder,
                      width: 1.5)
                  : null,
            ),
            child: Center(
              child: i < currentStep
                  ? Icon(Icons.check,
                      color: Colors.white, size: ScreenAdapter.fontSize(22))
                  : Text(
                      '$i',
                      style: TextStyle(
                        color: i == currentStep
                            ? Colors.white
                            : const Color(0xFFAA9E8E),
                        fontSize: ScreenAdapter.fontSize(22),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }
}
