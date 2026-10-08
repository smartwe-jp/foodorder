import 'package:flutter/material.dart';
import '../../settlement/views/product_label.dart';

class LabelPrintControls extends StatelessWidget {
  final Map printer;
  final ValueChanged<String> onPresetChanged;
  final Widget Function() buildSample;
  final VoidCallback onPrintSample;
  const LabelPrintControls(
      {super.key,
      required this.printer,
      required this.onPresetChanged,
      required this.buildSample,
      required this.onPrintSample});

  @override
  Widget build(BuildContext context) {
    final settings = LabelPrintSettings.fromPrinter(printer);
    return Wrap(
        spacing: 16,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('ラベル文字サイズ'),
          DropdownButton<String>(
              value: settings.preset,
              items: const [
                DropdownMenuItem(value: 'legacy', child: Text('従来')),
                DropdownMenuItem(value: 'standard', child: Text('標準')),
                DropdownMenuItem(value: 'large', child: Text('大きい')),
              ],
              onChanged: (value) {
                if (value != null) onPresetChanged(value);
              }),
          TextButton.icon(
              icon: const Icon(Icons.preview),
              label: const Text('プレビュー・試し印刷'),
              onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) {
                    final sample = buildSample();
                    final warnings =
                        sample is ProductLabel ? sample.warnings : <String>[];
                    return AlertDialog(
                        title: const Text('ラベルプレビュー'),
                        content: SizedBox(
                            width: 520,
                            child: SingleChildScrollView(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  const Text('サンプルデータ（画面上の大きさは実寸ではありません）'),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                      height: settings.height.toDouble(),
                                      width: double.infinity,
                                      child: FittedBox(
                                          fit: BoxFit.contain, child: sample)),
                                  const SizedBox(height: 12),
                                  for (final warning in warnings)
                                    Text(warning,
                                        style: const TextStyle(
                                            color: Colors.deepOrange)),
                                ]))),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('閉じる')),
                          TextButton(
                              onPressed: '${printer['printIp'] ?? ''}'.isEmpty
                                  ? null
                                  : onPrintSample,
                              child: const Text('試し印刷')),
                        ]);
                  })),
        ]);
  }
}
