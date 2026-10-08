import 'dart:math' as math;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';

/// Dimensions are print pixels, independent of the terminal's screen scale.
class LabelPrintSettings {
  final int width;
  final int height;
  final String preset;
  final bool rotate;
  final bool printQr;

  const LabelPrintSettings(
      {required this.width,
      required this.height,
      this.preset = 'legacy',
      this.rotate = false,
      this.printQr = true});

  factory LabelPrintSettings.fromPrinter(Map printer) {
    final parts = '${printer['labelSize'] ?? '300x225'}'.split('x');
    final width = parts.length == 2 ? int.tryParse(parts[0]) : null;
    final height = parts.length == 2 ? int.tryParse(parts[1]) : null;
    final preset = printer['labelFontPreset'];
    return LabelPrintSettings(
      width: width != null && width > 0 ? width : 300,
      height: height != null && height > 0 ? height : 225,
      preset: preset == 'standard' || preset == 'large' ? preset : 'legacy',
      rotate: printer['direction'] == 1,
      printQr: printer['printOptionCode'] ?? true,
    );
  }

  bool get isLegacy => preset == 'legacy';
  bool get isNarrow => width < 300;
  double get nameSize => preset == 'large' ? 38 : 32;
  double get optionSize => preset == 'large' ? 32 : 28;
  // Keep the existing supported QR size and reserve its own footer region.
  bool get supportsQr => width >= 375 && height >= 450;
}

class ProductLabelData {
  final String name, number, options, index, time, orderId, shopName, qr;
  const ProductLabelData(
      {required this.name,
      required this.number,
      required this.options,
      required this.index,
      required this.time,
      this.orderId = '',
      this.shopName = '',
      this.qr = ''});

  static const sample = ProductLabelData(
      name: '特製チーズハンバーグ弁当,特製チーズハンバーグ弁当',
      number: '12345',
      index: '12-3',
      options: 'ご飯: 大盛り、ソース: 別添え、追加: チーズ x 2、温泉卵、辛さ: 辛口',
      time: '10-08 12:30',
      orderId: 'TEST-12345',
      shopName: 'テスト店舗',
      qr: 'https://example.com/label-test');
}

class _LabelText {
  final String value;
  final double size;
  final int lines;
  final bool clipped;
  final bool bold;
  const _LabelText(this.value, this.size, this.lines, this.clipped, this.bold);

  TextStyle get style => TextStyle(
      fontFamily: 'NotoSansJP',
      fontSize: size,
      height: 1.15,
      color: Colors.black,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal);

  Widget get widget => Text(value,
      style: style,
      maxLines: lines,
      textScaler: TextScaler.noScaling,
      overflow: TextOverflow.ellipsis);
}

class ProductLabel extends StatelessWidget with ATempWidget {
  final LabelPrintSettings settings;
  final ProductLabelData data;
  const ProductLabel({super.key, required this.settings, required this.data});

  @override
  int get pixelPagerWidth => settings.width;
  @override
  int get pixelPagerHeight => settings.height;
  @override
  double get pixelRatio => 1;

  _LabelText _fit(String value, double width, double height, double preferred,
      double minimum, int maxLines,
      {bool bold = false}) {
    final lines =
        math.max(1, math.min(maxLines, (height / (preferred * 1.15)).floor()));
    var size = preferred;
    bool clipped;
    do {
      final text = _LabelText(value, size, lines, false, bold);
      final painter = TextPainter(
          text: TextSpan(text: value, style: text.style),
          textDirection: TextDirection.ltr,
          maxLines: lines)
        ..layout(maxWidth: width);
      clipped = painter.didExceedMaxLines || painter.height > height;
      painter.dispose();
      if (!clipped || size <= minimum) break;
      size -= 1;
    } while (true);
    return _LabelText(value, size, lines, clipped, bold);
  }

  // Fixed budgets keep long titles or metadata from pushing options off paper.
  double get _contentWidth => settings.width - 12.0;
  bool get _showQr =>
      settings.printQr && settings.supportsQr && data.qr.isNotEmpty;
  double get _footerHeight => _showQr ? 144 : (data.orderId.isEmpty ? 24 : 46);
  double get _nameHeight =>
      settings.nameSize * 1.15 * (settings.isNarrow ? 3 : 2);
  double get _numberHeight => settings.isNarrow ? settings.nameSize * 1.15 : 0;
  double get _optionHeight => math.max(0,
      settings.height - 12 - _nameHeight - _numberHeight - 8 - _footerHeight);
  _LabelText get _name => _fit(
      data.name,
      settings.isNarrow ? _contentWidth : _contentWidth * .68,
      _nameHeight,
      settings.nameSize,
      settings.nameSize - 4,
      settings.isNarrow ? 3 : 2,
      bold: true);
  _LabelText get _options => _fit(data.options, _contentWidth, _optionHeight,
      settings.optionSize, settings.optionSize - 2, 100);

  List<String> get warnings => [
        if (_name.clipped) '商品名が省略されています。',
        if (data.options.isNotEmpty &&
            (_optionHeight < settings.optionSize * 1.15 || _options.clipped))
          'オプションが省略されています。標準文字または大きいラベルを選択してください。',
        if (settings.printQr && data.qr.isNotEmpty && !settings.supportsQr)
          'このサイズはQRコードに対応していません（50×60 / 60×60対応）。',
      ];

  @override
  Widget build(BuildContext context) {
    final numberWidth =
        settings.isNarrow ? _contentWidth * .65 : _contentWidth * .32;
    final number = _fit('# ${data.number}', numberWidth,
        settings.nameSize * 1.15, settings.nameSize, settings.nameSize - 4, 1,
        bold: true);
    final index = _fit(
        data.index,
        settings.isNarrow ? _contentWidth * .35 : numberWidth,
        settings.nameSize * 1.15,
        settings.nameSize,
        settings.nameSize - 4,
        1,
        bold: true);
    final header = settings.isNarrow
        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
                height: _numberHeight,
                child: Row(children: [
                  Expanded(flex: 65, child: number.widget),
                  Expanded(flex: 35, child: index.widget)
                ])),
            SizedBox(height: _nameHeight, child: _name.widget)
          ])
        : SizedBox(
            height: _nameHeight,
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 68, child: _name.widget),
              Expanded(
                  flex: 32,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [number.widget, index.widget]))
            ]));
    return SizedBox(
        width: settings.width.toDouble(),
        height: settings.height.toDouble(),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: ClipRect(
                child: ColoredBox(
                    color: Colors.white,
                    child: Transform.rotate(
                        angle: settings.rotate ? math.pi : 0,
                        child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  header,
                                  const SizedBox(
                                      height: 8,
                                      child: Center(
                                          child: Divider(
                                              height: 2,
                                              thickness: 2,
                                              color: Colors.black))),
                                  Expanded(
                                      child: SizedBox(
                                          width: double.infinity,
                                          child: _optionHeight >=
                                                  settings.optionSize * 1.15
                                              ? _options.widget
                                              : const SizedBox.shrink())),
                                  SizedBox(
                                      height: _footerHeight,
                                      child: Row(children: [
                                        if (_showQr) ...[
                                          BarcodeWidget(
                                              width: 140,
                                              height: 140,
                                              barcode: Barcode.qrCode(),
                                              data: data.qr),
                                          const SizedBox(width: 6)
                                        ],
                                        Expanded(
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                              if (_showQr) ...[
                                                _fit(
                                                        data.shopName,
                                                        _contentWidth - 146,
                                                        42,
                                                        18,
                                                        18,
                                                        2)
                                                    .widget,
                                                _fit(
                                                        data.orderId,
                                                        _contentWidth - 146,
                                                        42,
                                                        18,
                                                        18,
                                                        2)
                                                    .widget
                                              ],
                                              if (!_showQr &&
                                                  data.orderId.isNotEmpty)
                                                _fit(
                                                        data.orderId,
                                                        _contentWidth,
                                                        22,
                                                        18,
                                                        18,
                                                        1)
                                                    .widget,
                                              _fit(
                                                      data.time,
                                                      _contentWidth -
                                                          (_showQr ? 146 : 0),
                                                      24,
                                                      18,
                                                      18,
                                                      1)
                                                  .widget,
                                            ])),
                                      ])),
                                ])))))));
  }
}
