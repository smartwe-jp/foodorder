import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/machine_info.dart';
import '../../../services/HomeServices.dart';
import 'spicy_hot_pot_settings_card.dart';

class SpicyHotPotSettingsPage extends StatefulWidget {
  const SpicyHotPotSettingsPage({super.key});

  @override
  State<SpicyHotPotSettingsPage> createState() =>
      _SpicyHotPotSettingsPageState();
}

class _SpicyHotPotSettingsPageState extends State<SpicyHotPotSettingsPage> {
  final MachineInfoController machineInfo = Get.find<MachineInfoController>();
  bool saving = false;

  Future<void> _setEnabled(bool enabled) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      final current = await HomeServices.getSystemSettingInfo();
      final settings = Map<String, dynamic>.from(current as Map);
      settings['spicyHotPotEnabled'] = enabled;
      await HomeServices.updateSystemSettingInfo(settings);
      machineInfo.isSpicyHotPotEnabled = enabled;
      if (!enabled && machineInfo.currentMode == MachineMode.spicyHotPot) {
        machineInfo.currentMode = MachineMode.sell;
        machineInfo.spicyHotPotTakeout = false;
      }
      machineInfo.update();
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!machineInfo.isShopSpicyHotPot) {
      return Scaffold(
        appBar: AppBar(title: const Text('麻辣湯設定')),
        body: const Center(child: Text('この端末では麻辣湯機能を利用できません')),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 242, 246),
      appBar: AppBar(
        title: const Text(
          '麻辣湯設定',
          style: TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 28,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: const Text(
                  '麻辣湯機能',
                  style: TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  machineInfo.isSpicyHotPotEnabled
                      ? '注文画面で麻辣湯フローを使用します'
                      : '通常の注文フローを使用します',
                  style: const TextStyle(
                    fontFamily: 'NotoSansJP',
                    fontSize: 16,
                  ),
                ),
                value: machineInfo.isSpicyHotPotEnabled,
                onChanged: saving ? null : _setEnabled,
              ),
            ),
            if (machineInfo.isSpicyHotPotEnabled)
              const SpicyHotPotSettingsCard(),
          ],
        ),
      ),
    );
  }
}
