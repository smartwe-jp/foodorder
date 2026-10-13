import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/modules/settlement/views/product_label.dart';
import 'package:foodorder/app/modules/systemSettingPage/views/label_print_controls.dart';

void main() {
  testWidgets('preview print receives the displayed template without rebuilding', (tester) async {
    final printer = {'printIp': '192.0.2.1', 'labelSize': '300x225', 'labelFontPreset': 'small'};
    final sample = ProductLabel(settings: LabelPrintSettings.fromPrinter(printer), data: ProductLabelData.sample);
    Widget? printed;
    var builds = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: LabelPrintControls(
      printer: printer, onPresetChanged: (_) {},
      buildSample: () { builds++; return sample; },
      onPrintSample: (widget) { printed = widget; },
    ))));
    await tester.tap(find.text('プレビュー'));
    await tester.pumpAndSettle();
    expect(find.byWidget(sample), findsOneWidget);
    await tester.tap(find.text('試し印刷'));
    expect(identical(printed, sample), isTrue);
    expect(builds, 1);
  });
}
