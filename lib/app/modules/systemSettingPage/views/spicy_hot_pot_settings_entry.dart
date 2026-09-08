import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/machine_info.dart';
import '../../../routes/app_pages.dart';

class SpicyHotPotSettingsEntry extends StatefulWidget {
  const SpicyHotPotSettingsEntry({super.key});

  @override
  State<SpicyHotPotSettingsEntry> createState() =>
      _SpicyHotPotSettingsEntryState();
}

class _SpicyHotPotSettingsEntryState
    extends State<SpicyHotPotSettingsEntry> {
  final MachineInfoController machineInfo = Get.find<MachineInfoController>();

  Future<void> _openSettings() async {
    await Get.toNamed(Routes.SPICY_HOT_POT_SETTINGS);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final enabled = machineInfo.isSpicyHotPotOn;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: const Text(
          '麻辣湯設定',
          style: TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Text(
          '電子秤・風袋・最低金額・特典などを設定します',
          style: TextStyle(fontFamily: 'NotoSansJP', fontSize: 16),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              enabled ? 'オン' : 'オフ',
              style: TextStyle(
                fontFamily: 'NotoSansJP',
                fontSize: 18,
                color: enabled ? Colors.blue : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 30),
          ],
        ),
        onTap: _openSettings,
      ),
    );
  }
}
