import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/scale_serial_service.dart';
import '../../../services/spicy_weigh_settings.dart';
import '../../../widget/NumberKeyboard.dart';

class SpicyHotPotSettingsCard extends StatefulWidget {
  const SpicyHotPotSettingsCard({super.key});

  @override
  State<SpicyHotPotSettingsCard> createState() =>
      _SpicyHotPotSettingsCardState();
}

class _SpicyHotPotSettingsCardState extends State<SpicyHotPotSettingsCard> {
  final ScaleSerialService scale = Get.find<ScaleSerialService>();

  bool loading = true;
  bool manualInput = false;
  bool bowlScan = false;
  bool floorToTens = false;
  double tareGrams = 0;
  int minAmount = 0;
  int giftThreshold = 0;
  String selectedPort = '';
  ScaleSerialParams selectedParams = ScaleSerialParams.appStandard;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final values = await Future.wait<dynamic>([
      SpicyWeighSettings.loadManualAllowed(),
      SpicyWeighSettings.loadBowlScanEnabled(),
      SpicyWeighSettings.loadFloorToTensEnabled(),
      SpicyWeighSettings.loadTareGrams(),
      SpicyWeighSettings.loadMinAmountYen(),
      SpicyWeighSettings.loadGiftThresholdYen(),
      scale.loadSavedPortName(),
      scale.loadSavedParams(),
      scale.refreshPorts(),
    ]);
    if (!mounted) return;
    setState(() {
      manualInput = values[0] as bool;
      bowlScan = values[1] as bool;
      floorToTens = values[2] as bool;
      tareGrams = values[3] as double;
      minAmount = values[4] as int;
      giftThreshold = values[5] as int;
      selectedPort = values[6] as String? ?? '';
      selectedParams = values[7] as ScaleSerialParams;
      loading = false;
    });
  }

  Future<void> _editNumber({
    required String title,
    required num value,
    required Future<void> Function(String value) save,
  }) async {
    await Get.dialog(
      NumberKeyboardDialog(
        title: title,
        initialValue: '$value',
        onConfirm: (raw) async {
          await save(raw);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '計量詳細設定',
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  Obx(() => _statusRow()),
                  const SizedBox(height: 8),
                  Obx(() => _portRow()),
                  const SizedBox(height: 8),
                  _paramsRow(),
                  const Divider(),
                  _switchRow(
                    title: '重量の手動入力を許可',
                    value: manualInput,
                    onChanged: (value) async {
                      await SpicyWeighSettings.saveManualAllowed(value);
                      setState(() => manualInput = value);
                    },
                  ),
                  _switchRow(
                    title: 'ボウル番号をスキャン',
                    value: bowlScan,
                    onChanged: (value) async {
                      await SpicyWeighSettings.saveBowlScanEnabled(value);
                      setState(() => bowlScan = value);
                    },
                  ),
                  _switchRow(
                    title: '金額を10円単位で切り捨て',
                    value: floorToTens,
                    onChanged: (value) async {
                      await SpicyWeighSettings.saveFloorToTensEnabled(value);
                      setState(() => floorToTens = value);
                    },
                  ),
                  const Divider(),
                  _numberRow(
                    title: '容器の風袋',
                    value: '${tareGrams.toStringAsFixed(0)} g',
                    onTap: () => _editNumber(
                      title: '容器の風袋（g）',
                      value: tareGrams.toInt(),
                      save: (raw) async {
                        tareGrams = double.tryParse(raw) ?? 0;
                        await SpicyWeighSettings.saveTareGrams(tareGrams);
                      },
                    ),
                  ),
                  _numberRow(
                    title: '最低金額',
                    value: '¥$minAmount',
                    onTap: () => _editNumber(
                      title: '最低金額（円）',
                      value: minAmount,
                      save: (raw) async {
                        minAmount = int.tryParse(raw) ?? 0;
                        await SpicyWeighSettings.saveMinAmountYen(minAmount);
                      },
                    ),
                  ),
                  _numberRow(
                    title: '特典適用金額',
                    value: '¥$giftThreshold',
                    onTap: () => _editNumber(
                      title: '特典適用金額（円）',
                      value: giftThreshold,
                      save: (raw) async {
                        giftThreshold = int.tryParse(raw) ?? 0;
                        await SpicyWeighSettings.saveGiftThresholdYen(
                            giftThreshold);
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _statusRow() {
    final connected = scale.connectedRx.value;
    final busy = scale.connectingRx.value || scale.disconnectingRx.value;
    final error = scale.lastErrorRx.value;
    return Row(
      children: [
        Icon(connected ? Icons.check_circle : Icons.error_outline,
            color: connected ? Colors.green : Colors.orange),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            connected
                ? '電子秤：接続済み'
                : '電子秤：未接続${error.isEmpty ? '' : '（$error）'}',
          ),
        ),
        OutlinedButton(
          onPressed: busy
              ? null
              : () async {
                  if (connected) {
                    await scale.disconnect();
                  } else {
                    await scale.connect(
                      portName: selectedPort,
                      params: selectedParams,
                      autoProbe: false,
                    );
                  }
                },
          child: Text(busy ? '処理中…' : (connected ? '切断' : '接続')),
        ),
      ],
    );
  }

  Widget _portRow() {
    final ports = scale.portsRx.toList();
    final value = ports.contains(selectedPort) ? selectedPort : null;
    return Row(
      children: [
        const SizedBox(width: 150, child: Text('シリアルポート')),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: value,
            hint: const Text('未設定'),
            items: ports
                .map((port) => DropdownMenuItem(
                      value: port,
                      child: Text(scale.portLabel(port)),
                    ))
                .toList(),
            onChanged: (port) async {
              if (port == null) return;
              await scale.savePortName(port);
              setState(() => selectedPort = port);
            },
          ),
        ),
        IconButton(
          onPressed: scale.refreshPorts,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _paramsRow() {
    return Row(
      children: [
        const SizedBox(width: 150, child: Text('通信設定')),
        Expanded(
          child: DropdownButton<ScaleSerialParams>(
            isExpanded: true,
            value: selectedParams,
            items: ScaleSerialParams.presets
                .map((params) => DropdownMenuItem(
                      value: params,
                      child: Text(params.label),
                    ))
                .toList(),
            onChanged: (params) async {
              if (params == null) return;
              await scale.saveParams(params);
              setState(() => selectedParams = params);
            },
          ),
        ),
      ],
    );
  }

  Widget _switchRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _numberRow({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: TextButton(onPressed: onTap, child: Text(value)),
    );
  }
}
