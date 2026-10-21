import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../widget/StoredValueWalletQr.dart';

class StoredValuePaymentGuide extends StatelessWidget {
  const StoredValuePaymentGuide({super.key});

  Widget _text(String key, double size, {bool bold = false}) {
    return Text(
      key.tr,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: GFont.getFontFamily(),
        fontSize: ScreenAdapter.fontSize(size),
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        color: bold ? Colors.black87 : Colors.black54,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final qrSize =
          math.min<double>(ScreenAdapter.width(200), constraints.maxWidth * .22);
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenAdapter.width(40),
              vertical: ScreenAdapter.height(24),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _text('settlement_stored_value_scan', 34, bold: true),
                      SizedBox(height: ScreenAdapter.height(24)),
                      // Payment-code illustration; the real code is shown on the customer's phone.
                      Container(
                        width: ScreenAdapter.width(105),
                        padding: EdgeInsets.symmetric(
                            vertical: ScreenAdapter.height(14)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black87, width: 3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            Icon(Icons.qr_code, size: ScreenAdapter.width(75)),
                      ),
                      const Icon(Icons.arrow_downward, color: Colors.black54),
                      Icon(Icons.qr_code_scanner,
                          size: ScreenAdapter.width(60)),
                      SizedBox(height: ScreenAdapter.height(18)),
                      _text('settlement_stored_value_scan_hint', 26),
                    ],
                  ),
                ),
                SizedBox(width: ScreenAdapter.width(30)),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.all(ScreenAdapter.width(20)),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _text('settlement_stored_value_open', 28, bold: true),
                        SizedBox(height: ScreenAdapter.height(18)),
                        StoredValueWalletQr(size: qrSize),
                        SizedBox(height: ScreenAdapter.height(18)),
                        _text('settlement_stored_value_open_hint', 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
