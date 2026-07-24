import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../config/font.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../../../widget/KioskTap.dart';

const kSpicyAccent = Color(0xFF44C2B8);
const kSpicyText = Color(0xFF333333);
const kSpicyGrey = Color(0xFF666666);
const kSpicyMuted = Color(0xFF9E9E9E);
const kSpicyBorder = Color(0xFFDCDCDC);
const kSpicyBg = Color(0xFFF5F5F5);

/// 麻辣烫流程 6 步（与设计图对齐，文案走多语）
List<String> get kSpicySteps => [
      'spicy_step_start'.tr,
      'spicy_step_weigh'.tr,
      'spicy_step_soup'.tr,
      'spicy_step_topping'.tr,
      'spicy_step_checkout'.tr,
      'spicy_step_pay'.tr,
    ];

/// 顶栏：可选左侧返回 + 右侧步骤条（白底）
class SpicyHotPotStepHeader extends StatelessWidget {
  /// 当前步骤，1-based（1=開始 … 6=支払い）
  final int currentStep;

  /// 左侧返回；为 null 时不显示返回按钮
  final VoidCallback? onBack;
  final String? backLabel;

  const SpicyHotPotStepHeader({
    Key? key,
    required this.currentStep,
    this.onBack,
    this.backLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(onBack != null ? 16 : 28),
        ScreenAdapter.height(18),
        ScreenAdapter.width(20),
        ScreenAdapter.height(14),
      ),
      child: Row(
        children: [
          if (onBack != null) ...[
            _buildBackButton(),
            SizedBox(width: ScreenAdapter.width(12)),
          ],
          // 暂无店铺 logo / 店名，先隐藏左侧品牌区
          // _buildLogo(),
          // SizedBox(width: ScreenAdapter.width(20)),
          Expanded(child: _buildSteps()),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    final label =
        (backLabel == null || backLabel!.isEmpty) ? 'settlement_back'.tr : backLabel!;
    return KioskTap(
      onTap: onBack,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(16),
          vertical: ScreenAdapter.height(10),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: kSpicyBorder, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_new,
              size: ScreenAdapter.fontSize(22),
              color: kSpicyText,
            ),
            SizedBox(width: ScreenAdapter.width(4)),
            Text(
              label,
              style: TextStyle(
                color: kSpicyText,
                fontSize: ScreenAdapter.fontSize(24),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ScreenAdapter.width(56),
          height: ScreenAdapter.width(56),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: kSpicyAccent,
          ),
          child: Center(
            child: Text(
              '麻',
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenAdapter.fontSize(28),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        SizedBox(width: ScreenAdapter.width(10)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '麻辣烫',
              style: TextStyle(
                color: kSpicyText,
                fontSize: ScreenAdapter.fontSize(28),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            Text(
              'マーラータン',
              style: TextStyle(
                color: kSpicyMuted,
                fontSize: ScreenAdapter.fontSize(16),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSteps() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < kSpicySteps.length; i++) ...[
            if (i > 0)
              Container(
                width: ScreenAdapter.width(18),
                height: 1.5,
                color: kSpicyBorder,
              ),
            _buildStepDot(i + 1, kSpicySteps[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = step == currentStep;
    final isDone = step < currentStep;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ScreenAdapter.width(40),
          height: ScreenAdapter.width(40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone || isActive ? kSpicyAccent : Colors.transparent,
            border: Border.all(
              color: isDone || isActive ? kSpicyAccent : kSpicyBorder,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check,
                    color: Colors.white, size: ScreenAdapter.fontSize(20))
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : kSpicyMuted,
                      fontSize: ScreenAdapter.fontSize(18),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        SizedBox(height: ScreenAdapter.height(4)),
        Text(
          label,
          style: TextStyle(
            color: isActive ? kSpicyAccent : kSpicyMuted,
            fontSize: ScreenAdapter.fontSize(14),
            fontFamily: GFont.getFontFamily(),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 结算页风格底栏：左返回、中跳过（居中醒目色）、右下一步（弹性宽度）
class SpicyHotPotBottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String backLabel;
  final String nextLabel;
  final bool nextEnabled;

  /// 中间可选按钮（如「跳过称重」）——固定居中
  final VoidCallback? onMiddle;
  final String? middleLabel;

  const SpicyHotPotBottomBar({
    Key? key,
    this.onBack,
    this.onNext,
    this.backLabel = '',
    this.nextLabel = '',
    this.nextEnabled = true,
    this.onMiddle,
    this.middleLabel,
  }) : super(key: key);

  /// 跳过等次要操作的醒目色（与主色下一步区分）
  static const Color _middleAccent = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    final resolvedBack =
        backLabel.isEmpty ? 'settlement_back'.tr : backLabel;
    final resolvedNext = nextLabel.isEmpty ? 'next_button'.tr : nextLabel;
    return Container(
      height: ScreenAdapter.height(200),
      color: const Color(0xFFDCDCDC),
      padding: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(40)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 左右：返回 + 下一步（弹性宽度）
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _plainBtn(
                label: resolvedBack,
                onTap: onBack,
                width: ScreenAdapter.width(180),
              ),
              const Spacer(),
              _filledBtn(
                label: resolvedNext,
                onTap: nextEnabled ? onNext : null,
                enabled: nextEnabled,
                minWidth: ScreenAdapter.width(180),
                horizontalPadding: ScreenAdapter.width(20),
              ),
            ],
          ),
          // 中间：跳过称重 — 按内容宽度居中，不可撑满盖住左右按钮
          if (middleLabel != null)
            Align(
              alignment: Alignment.center,
              child: _middleBtn(
                label: middleLabel!,
                onTap: onMiddle,
                minWidth: ScreenAdapter.width(180),
                horizontalPadding: ScreenAdapter.width(20),
              ),
            ),
        ],
      ),
    );
  }

  Widget _plainBtn({
    required String label,
    VoidCallback? onTap,
    double? width,
    double? minWidth,
    double horizontalPadding = 0,
  }) {
    return KioskTap(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width,
        constraints: minWidth != null
            ? BoxConstraints(minWidth: minWidth)
            : null,
        height: ScreenAdapter.height(100),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: const Color(0xFF2D2D2D),
              fontSize: ScreenAdapter.fontSize(34.0),
              fontFamily: GFont.getFontFamily(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _middleBtn({
    required String label,
    VoidCallback? onTap,
    required double minWidth,
    double horizontalPadding = 0,
  }) {
    return KioskTap(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minWidth,
          // 限制最大宽度，避免遮挡左右按钮
          maxWidth: ScreenAdapter.width(280),
        ),
        child: Container(
          alignment: Alignment.center,
          height: ScreenAdapter.height(100),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: _middleAccent,
            borderRadius: BorderRadius.circular(5.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenAdapter.fontSize(34.0),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filledBtn({
    required String label,
    VoidCallback? onTap,
    required bool enabled,
    double? width,
    double? minWidth,
    double horizontalPadding = 0,
  }) {
    return KioskTap(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width,
        constraints: minWidth != null
            ? BoxConstraints(minWidth: minWidth)
            : null,
        height: ScreenAdapter.height(100),
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: enabled ? kSpicyAccent : const Color(0xFFBDBDBD),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: Colors.white,
              fontSize: ScreenAdapter.fontSize(34.0),
              fontFamily: GFont.getFontFamily(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
