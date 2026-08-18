import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cash_machine_check_controller.dart';

class CashMachineCheckView extends GetView<CashMachineCheckController> {
  const CashMachineCheckView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Obx(() {
              final checking = controller.isChecking.value;
              final error = controller.errorMessage.value;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    checking ? Icons.settings_input_component : Icons.warning,
                    size: 96,
                    color: checking ? Colors.green.shade800 : Colors.orange,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    checking ? controller.stepTitle : '現金機を確認できませんでした',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '機種: ${controller.machineModelCode}  /  ${controller.driverName}',
                    style: const TextStyle(fontSize: 22, color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  if (checking) const CircularProgressIndicator(),
                  if (!checking && error.isNotEmpty)
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                  if (!checking) ...[
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: controller.ignore,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(220, 72),
                          ),
                          child: const Text('無視して続行',
                              style: TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: controller.check,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(220, 72),
                            backgroundColor: Colors.green.shade800,
                            foregroundColor: Colors.white,
                          ),
                          child:
                              const Text('再確認', style: TextStyle(fontSize: 24)),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
