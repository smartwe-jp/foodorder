import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/font.dart';
import '../../../modules/systemSettingPage/views/CustomKeyboard.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/KioskTap.dart';

const _kBg = Color(0xFFF5EFDE);
const _kRed = Color(0xFFC82333);
const _kText = Color(0xFF1A1A1A);
const _kGrey = Color(0xFF888888);
const _kBorder = Color(0xFFE0D5C5);

/// 麻辣烫称重输入弹窗（参考效果图：暖奶油背景 + 超大克重显示）
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
  String _input = '';

  double get _weight => double.tryParse(_input) ?? 0;
  int get _price =>
      _weight > 0 ? ((_weight / 100) * widget.unitPricePer100g).ceil() : 0;
  bool get _hasInput => _input.isNotEmpty && _weight > 0;

  void _onKey(String key) {
    setState(() {
      if (key == '削除') {
        if (_input.isNotEmpty) _input = _input.substring(0, _input.length - 1);
        return;
      }
      if (key == '.') {
        if (!_input.contains('.') && _input.isNotEmpty) _input += '.';
        return;
      }
      _input = (_input == '0') ? key : _input + key;
    });
  }

  void _confirm() {
    if (!_hasInput) return;
    Get.back();
    widget.onConfirm(_weight, _price);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.itemData['mainTitle'] ?? '';
    final displayWeight = _input.isEmpty ? '0' : _input;

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
            _buildWeightBlock(displayWeight),
            _buildKeyboard(),
            _buildUnitPriceHint(),
            _buildButtons(),
          ],
        ),
      ),
    );
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
                    color: _hasInput ? _kText : _kGrey,
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
                _hasInput ? '¥ $_price' : '¥ ---',
                style: TextStyle(
                  color: _hasInput ? _kRed : _kGrey,
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

  Widget _buildKeyboard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(20)),
      child: CustomKeyboard(onKeyPressed: _onKey),
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
              onTap: _hasInput ? _confirm : null,
              child: Container(
                height: ScreenAdapter.height(92),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _hasInput ? _kRed : const Color(0xFFBDBDBD),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '重量確認，選口味',
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
