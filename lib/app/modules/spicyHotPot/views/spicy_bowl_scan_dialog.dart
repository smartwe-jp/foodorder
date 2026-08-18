import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../config/font.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/KioskTap.dart';

/// 扫盆码弹窗结果
enum SpicyBowlScanAction {
  /// 已扫到盆号，或无需扫码
  proceed,

  /// 返回语言/结账首页
  back,

  /// 等同跳过称重，去买配菜/饮料
  skip,
}

class SpicyBowlScanResult {
  final SpicyBowlScanAction action;
  final String? tableNo;

  const SpicyBowlScanResult.proceed([this.tableNo])
      : action = SpicyBowlScanAction.proceed;

  const SpicyBowlScanResult.back()
      : action = SpicyBowlScanAction.back,
        tableNo = null;

  const SpicyBowlScanResult.skip()
      : action = SpicyBowlScanAction.skip,
        tableNo = null;
}

/// 称重页：扫盆边二维码/条码
class SpicyBowlScanDialog extends StatefulWidget {
  const SpicyBowlScanDialog({Key? key}) : super(key: key);

  @override
  State<SpicyBowlScanDialog> createState() => _SpicyBowlScanDialogState();
}

class _SpicyBowlScanDialogState extends State<SpicyBowlScanDialog> {
  static const Color _accent = Color(0xFF2E9E8F);
  static const Color _title = Color(0xFF222222);
  static const Color _sub = Color(0xFF888888);

  final TextEditingController _scanCtrl = TextEditingController();
  final FocusNode _scanFocus = FocusNode(debugLabel: 'SpicyBowlScan');

  @override
  void initState() {
    super.initState();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scanFocus.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _scanFocus.dispose();
    super.dispose();
  }

  void _onScanSubmitted(String raw) {
    final code = raw.trim();
    if (code.isEmpty) {
      _scanCtrl.clear();
      _scanFocus.requestFocus();
      return;
    }
    logI('[麻辣烫] 扫盆码成功 tableNo=$code');
    Get.back(result: SpicyBowlScanResult.proceed(code));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: ScreenAdapter.width(48),
          vertical: ScreenAdapter.height(100),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ScreenAdapter.width(880)),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _scanFocus.requestFocus();
                  SystemChannels.textInput.invokeMethod('TextInput.hide');
                },
                child: Stack(
                  children: [
                    // 隐藏扫码输入，枪扫回车提交
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        ScreenAdapter.width(44),
                        ScreenAdapter.height(48),
                        ScreenAdapter.width(44),
                        ScreenAdapter.height(40),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 扫码引导图标加大，便于远距离辨认
                          Container(
                            width: ScreenAdapter.width(168),
                            height: ScreenAdapter.width(168),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F7F4),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              Icons.qr_code_scanner,
                              color: _accent,
                              size: ScreenAdapter.fontSize(108),
                            ),
                          ),
                          SizedBox(height: ScreenAdapter.height(28)),
                          Text(
                            'spicy_bowl_scan_title'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _title,
                              fontSize: ScreenAdapter.fontSize(38),
                              fontFamily: GFont.getFontFamily(),
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: ScreenAdapter.height(14)),
                          Text(
                            'spicy_bowl_scan_subtitle'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _sub,
                              fontSize: ScreenAdapter.fontSize(24),
                              fontFamily: GFont.getFontFamily(),
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: ScreenAdapter.height(40)),
                          Row(
                            children: [
                              Expanded(
                                child: KioskTap(
                                  onTap: () {
                                    logI('[麻辣烫] 扫盆码弹窗点击返回');
                                    Get.back(
                                      result: const SpicyBowlScanResult.back(),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: ScreenAdapter.height(108),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'spicy_bowl_scan_back'.tr,
                                      style: TextStyle(
                                        color: _title,
                                        fontSize: ScreenAdapter.fontSize(30),
                                        fontFamily: GFont.getFontFamily(),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: ScreenAdapter.width(20)),
                              Expanded(
                                child: KioskTap(
                                  onTap: () {
                                    logI('[麻辣烫] 扫盆码弹窗点击跳过');
                                    Get.back(
                                      result: const SpicyBowlScanResult.skip(),
                                    );
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: ScreenAdapter.height(108),
                                    decoration: BoxDecoration(
                                      color: _accent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'spicy_bowl_scan_skip'.tr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: ScreenAdapter.fontSize(30),
                                        fontFamily: GFont.getFontFamily(),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
}
