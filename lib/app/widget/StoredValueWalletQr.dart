import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/app_environment.dart';

class StoredValueWalletQr extends StatelessWidget {
  const StoredValueWalletQr({Key? key, required this.size}) : super(key: key);

  final double size;

  static const String walletUrl = AppEnvironmentConfig.isProduction
      ? 'https://wallet-h5.smartwe.jp'
      : 'https://sit-wallet-h5.smartwe.jp';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF9E9E9E), width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: QrImageView(
        data: walletUrl,
        size: size,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
