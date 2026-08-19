import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../config/font.dart';
import '../../../../config/imageData.dart';
import '../../../../services/ScreenAdapter.dart';
import '../../../../widget/KioskTap.dart';
import '../../controllers/menu_page_controller.dart';

/// 麻辣烫模式菜单页：分类与菜品之间的扫码提示条（参考 cankao.png）
class SpicyScanTipBanner extends StatelessWidget {
  const SpicyScanTipBanner({Key? key}) : super(key: key);

  static const Color _border = Color(0xFFB8E0D8);
  static const Color _accent = Color(0xFF2E9E8F);
  static const Color _title = Color(0xFF222222);
  static const Color _sub = Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(
        ScreenAdapter.width(12),
        ScreenAdapter.height(4),
        ScreenAdapter.width(12),
        ScreenAdapter.height(10),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(30),
        vertical: ScreenAdapter.height(30),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: ScreenAdapter.width(56),
            height: ScreenAdapter.width(56),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7F4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.qr_code_scanner,
              color: _accent,
              size: ScreenAdapter.fontSize(34),
            ),
          ),
          SizedBox(width: ScreenAdapter.width(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'spicy_menu_scan_title'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _title,
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(4)),
                Text(
                  'spicy_menu_scan_subtitle'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _sub,
                    fontSize: ScreenAdapter.fontSize(20),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: ScreenAdapter.width(8)),
          KioskTap(
            onTap: _showHowToUse,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'spicy_menu_scan_howto'.tr,
                  style: TextStyle(
                    color: _accent,
                    fontSize: ScreenAdapter.fontSize(22),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: _accent,
                  size: ScreenAdapter.fontSize(26),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHowToUse() {
    var lang = 'JP';
    if (Get.isRegistered<MenuPageController>()) {
      lang = Get.find<MenuPageController>().checkLanguage.value;
    }
    if (!const {'JP', 'CH', 'EN', 'KO'}.contains(lang)) {
      lang = 'JP';
    }
    final assetPath =
        GImage.getImageString('imgpublic', 'spicy_scan_howto_$lang');
    Get.dialog(
      SpicyScanHowToDialog(assetPath: assetPath),
      barrierDismissible: true,
    ).whenComplete(() {
      // 关闭用法弹窗后，把扫码焦点还给菜单页
      if (Get.isRegistered<MenuPageController>()) {
        Get.find<MenuPageController>().requestSpicyMenuScanFocus();
      }
    });
  }
}

/// 使用方法弹窗：打开期间仍可扫码入车（内置隐藏输入框抢焦点）
class SpicyScanHowToDialog extends StatefulWidget {
  final String assetPath;

  const SpicyScanHowToDialog({Key? key, required this.assetPath})
      : super(key: key);

  @override
  State<SpicyScanHowToDialog> createState() => _SpicyScanHowToDialogState();
}

class _SpicyScanHowToDialogState extends State<SpicyScanHowToDialog> {
  static const Color _title = Color(0xFF222222);
  static const Color _sub = Color(0xFF888888);

  final TextEditingController _scanCtrl = TextEditingController();
  final FocusNode _scanFocus = FocusNode(debugLabel: 'SpicyHowToScan');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scanFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _scanFocus.dispose();
    super.dispose();
  }

  Future<void> _onScanSubmitted(String value) async {
    if (!Get.isRegistered<MenuPageController>()) return;
    final menu = Get.find<MenuPageController>();
    await menu.doSpicyMenuBarCodeQuery(
      barCode: value,
      restoreFocus: false,
    );
    if (!mounted) return;
    _scanCtrl.clear();
    _scanFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(40),
        vertical: ScreenAdapter.height(80),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ScreenAdapter.width(960),
          ),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => _scanFocus.requestFocus(),
              child: Stack(
              children: [
                // 弹窗内隐藏扫码框，保证用法说明打开时仍可扫码入车
                SizedBox(
                  height: 0,
                  child: TextField(
                    controller: _scanCtrl,
                    focusNode: _scanFocus,
                    autofocus: true,
                    showCursor: false,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: _onScanSubmitted,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: ScreenAdapter.height(36)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenAdapter.width(72),
                      ),
                      child: Text(
                        'spicy_menu_scan_howto_title'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _title,
                          fontSize: ScreenAdapter.fontSize(36),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(12)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenAdapter.width(48),
                      ),
                      child: Text(
                        'spicy_menu_scan_howto_body'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _sub,
                          fontSize: ScreenAdapter.fontSize(22),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(8)),
                    Image.asset(
                      widget.assetPath,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  ],
                ),
                Positioned(
                  top: ScreenAdapter.height(8),
                  right: ScreenAdapter.width(8),
                  child: KioskTap(
                    onTap: () => Get.back(),
                    child: Padding(
                      padding: EdgeInsets.all(ScreenAdapter.width(12)),
                      child: Icon(
                        Icons.close,
                        size: ScreenAdapter.fontSize(36),
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}
