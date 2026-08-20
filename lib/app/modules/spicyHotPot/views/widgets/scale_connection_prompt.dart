import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/font.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../../../widget/KioskTap.dart';

const _accent = Color(0xFF44C2B8);
const _titleColor = Color(0xFF242424);
const _bodyColor = Color(0xFF666666);
const _warningColor = Color(0xFFF08A4B);

Future<bool> showScaleConnectionPrompt({required String message}) async {
  return await Get.dialog<bool>(
        _ScaleConnectionPromptDialog(message: message),
        barrierDismissible: false,
        barrierColor: const Color(0x99000000),
      ) ??
      false;
}

class _ScaleConnectionPromptDialog extends StatelessWidget {
  final String message;

  const _ScaleConnectionPromptDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        elevation: 0,
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(48),
          vertical: ScreenAdapter.height(80),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ScreenAdapter.width(760)),
            child: Material(
              color: Colors.white,
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(ScreenAdapter.width(24)),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenAdapter.width(44),
                  ScreenAdapter.height(44),
                  ScreenAdapter.width(44),
                  ScreenAdapter.height(38),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIcon(),
                    SizedBox(height: ScreenAdapter.height(24)),
                    Text(
                      '電子秤の接続を確認してください',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _titleColor,
                        fontSize: ScreenAdapter.fontSize(34),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(16)),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenAdapter.width(24),
                        vertical: ScreenAdapter.height(20),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7F1),
                        borderRadius:
                            BorderRadius.circular(ScreenAdapter.width(14)),
                        border: Border.all(
                          color: const Color(0xFFFFDDC8),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _bodyColor,
                          fontSize: ScreenAdapter.fontSize(23),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w500,
                          height: 1.55,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(14)),
                    Text(
                      '閉じた後も、電子秤への再接続を自動的に続けます。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF999999),
                        fontSize: ScreenAdapter.fontSize(19),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(34)),
                    Row(
                      children: [
                        Expanded(
                          child: _PromptButton(
                            label: '閉じる',
                            icon: Icons.close_rounded,
                            backgroundColor: const Color(0xFFF1F3F4),
                            foregroundColor: _titleColor,
                            onTap: () => Get.back(result: false),
                          ),
                        ),
                        SizedBox(width: ScreenAdapter.width(18)),
                        Expanded(
                          child: _PromptButton(
                            label: '設定へ',
                            icon: Icons.settings_outlined,
                            backgroundColor: _accent,
                            foregroundColor: Colors.white,
                            onTap: () => Get.back(result: true),
                          ),
                        ),
                      ],
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

  Widget _buildIcon() {
    return Container(
      width: ScreenAdapter.width(120),
      height: ScreenAdapter.width(120),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF0E6),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.scale_outlined,
            color: _warningColor,
            size: ScreenAdapter.fontSize(66),
          ),
          Positioned(
            right: ScreenAdapter.width(12),
            top: ScreenAdapter.width(10),
            child: Container(
              width: ScreenAdapter.width(34),
              height: ScreenAdapter.width(34),
              decoration: const BoxDecoration(
                color: _warningColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.priority_high_rounded,
                color: Colors.white,
                size: ScreenAdapter.fontSize(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromptButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _PromptButton({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KioskTap(
      onTap: onTap,
      child: Container(
        height: ScreenAdapter.height(96),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(ScreenAdapter.width(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: foregroundColor,
              size: ScreenAdapter.fontSize(29),
            ),
            SizedBox(width: ScreenAdapter.width(10)),
            Text(
              label,
              style: TextStyle(
                color: foregroundColor,
                fontSize: ScreenAdapter.fontSize(28),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
