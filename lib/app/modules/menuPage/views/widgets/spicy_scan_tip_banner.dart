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

  /// 扫码用法弹窗：标题/副标题走多语，下方步骤图按语言加载
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
      Dialog(
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
              child: Stack(
                children: [
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
                        assetPath,
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
      barrierDismissible: true,
    );
  }
}
