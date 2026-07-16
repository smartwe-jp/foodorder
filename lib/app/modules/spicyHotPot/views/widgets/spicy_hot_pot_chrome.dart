import 'package:flutter/material.dart';
import '../../../../config/font.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../../../widget/KioskTap.dart';

const kSpicyAccent = Color(0xFF44C2B8);
const kSpicyText = Color(0xFF333333);
const kSpicyGrey = Color(0xFF666666);
const kSpicyMuted = Color(0xFF9E9E9E);
const kSpicyBorder = Color(0xFFDCDCDC);
const kSpicyBg = Color(0xFFF5F5F5);

/// 麻辣烫流程 6 步（与设计图对齐）
const kSpicySteps = [
  '開始',
  '秤重',
  'スープ',
  '具材選択',
  'お会計',
  '支払い',
];

/// 顶栏：左侧 logo + 右侧步骤条（白底）
class SpicyHotPotStepHeader extends StatelessWidget {
  /// 当前步骤，1-based（1=開始 … 6=支払い）
  final int currentStep;

  const SpicyHotPotStepHeader({Key? key, required this.currentStep})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(28),
        ScreenAdapter.height(18),
        ScreenAdapter.width(20),
        ScreenAdapter.height(14),
      ),
      child: Row(
        children: [
          _buildLogo(),
          SizedBox(width: ScreenAdapter.width(20)),
          Expanded(child: _buildSteps()),
        ],
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

/// 结算页风格底栏按钮：灰底、白色返回/跳过、主色下一步
class SpicyHotPotBottomBar extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String backLabel;
  final String nextLabel;
  final bool nextEnabled;

  /// 中间可选按钮（如「跳过称重」）
  final VoidCallback? onMiddle;
  final String? middleLabel;

  const SpicyHotPotBottomBar({
    Key? key,
    this.onBack,
    this.onNext,
    this.backLabel = '戻る',
    this.nextLabel = '次へ',
    this.nextEnabled = true,
    this.onMiddle,
    this.middleLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenAdapter.height(200),
      color: const Color(0xFFDCDCDC),
      padding: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(40)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _plainBtn(
            label: backLabel,
            onTap: onBack,
            width: ScreenAdapter.width(180),
          ),
          const Spacer(),
          if (middleLabel != null) ...[
            _plainBtn(
              label: middleLabel!,
              onTap: onMiddle,
              width: ScreenAdapter.width(180),
            ),
            SizedBox(width: ScreenAdapter.width(20)),
          ],
          _filledBtn(
            label: nextLabel,
            onTap: nextEnabled ? onNext : null,
            enabled: nextEnabled,
            width: ScreenAdapter.width(middleLabel != null ? 180 : 270),
          ),
        ],
      ),
    );
  }

  Widget _plainBtn({
    required String label,
    VoidCallback? onTap,
    required double width,
  }) {
    return KioskTap(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: ScreenAdapter.height(100),
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

  Widget _filledBtn({
    required String label,
    VoidCallback? onTap,
    required bool enabled,
    required double width,
  }) {
    return KioskTap(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: width,
        height: ScreenAdapter.height(100),
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
