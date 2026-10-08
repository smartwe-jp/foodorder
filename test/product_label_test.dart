import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/modules/settlement/views/product_label.dart';

void main() {
  test('existing and malformed settings retain legacy compatibility', () {
    expect(LabelPrintSettings.fromPrinter({}).isLegacy, isTrue);
    final invalid = LabelPrintSettings.fromPrinter(
        {'labelSize': 'bad', 'labelFontPreset': 'unknown'});
    expect(invalid.width, 300);
    expect(invalid.height, 225);
    expect(invalid.isLegacy, isTrue);
  });

  testWidgets(
      'all supported papers and presets render at print pixels with enlarged screen text',
      (tester) async {
    const sizes = [
      '460x225',
      '384x225',
      '300x225',
      '460x300',
      '384x300',
      '300x300',
      '460x375',
      '460x460',
      '384x375',
      '384x460',
      '300x375',
      '225x460'
    ];
    for (final size in sizes) {
      for (final preset in ['standard', 'large']) {
        for (final qr in [false, true]) {
          final settings = LabelPrintSettings.fromPrinter({
            'labelSize': size,
            'labelFontPreset': preset,
            'printOptionCode': qr,
            'direction': 1
          });
          final key = GlobalKey();
          await tester.pumpWidget(MaterialApp(
              home: MediaQuery(
                  data: const MediaQueryData(textScaler: TextScaler.linear(2)),
                  child: Center(
                      child: RepaintBoundary(
                          key: key,
                          child: ProductLabel(
                              settings: settings,
                              data: ProductLabelData.sample))))));
          expect(tester.takeException(), isNull,
              reason: '$size $preset qr=$qr');
          final boundary =
              key.currentContext!.findRenderObject() as RenderRepaintBoundary;
          final image =
              (await tester.runAsync(() => boundary.toImage(pixelRatio: 1)))!;
          expect(image.width, settings.width);
          expect(image.height, settings.height);
          image.dispose();
        }
      }
    }
  });

  testWidgets('long preparation instructions warn when truncated',
      (tester) async {
    final label = ProductLabel(
        settings: LabelPrintSettings.fromPrinter(
            {'labelSize': '300x225', 'labelFontPreset': 'large'}),
        data: ProductLabelData(
            name: '商品名' * 30,
            number: '12345',
            options: 'アレルギー対応・ソース別添え' * 30,
            index: '12-3',
            time: '10-08 12:30'));
    await tester.pumpWidget(MaterialApp(home: Center(child: label)));
    expect(tester.takeException(), isNull);
    expect(label.warnings.any((warning) => warning.contains('商品名')), isTrue);
    expect(label.warnings.any((warning) => warning.contains('オプション')), isTrue);
  });
}
