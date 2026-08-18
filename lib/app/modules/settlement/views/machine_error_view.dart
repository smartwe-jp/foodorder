
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/common/Extension/StringExtension.dart';
import 'package:get/get.dart';

class PendingCashItem {
  final String denomination;
  final int count;
  final int amount;

  const PendingCashItem({
    required this.denomination,
    required this.count,
    required this.amount,
  });
}

class MachineErrorView extends StatefulWidget {
  final String title;
  final String errorMessage;
  final List<String> faultDetails;
  final List<PendingCashItem> pendingCash;
  final String? settingsPassword;
  final VoidCallback? onGoToSettings;
  final bool enableAlarm;
  final String alarmAsset;

  const MachineErrorView({
    super.key,
    this.title = 'スタッフに緊急確認と対応をお願いします',
    required this.errorMessage,
    this.faultDetails = const [],
    this.pendingCash = const [],
    this.settingsPassword,
    this.onGoToSettings,
    this.enableAlarm = true,
    this.alarmAsset = 'audios/digital-alarm-2.mp3',
  });

  @override
  State<MachineErrorView> createState() => _MachineErrorViewState();

}

class _MachineErrorViewState extends State<MachineErrorView>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final AnimationController _borderController;
  late final Animation<double> _borderPulse;
  bool _isMuted = false;

  int pandingCashTotalAmount() {
    int total = 0;
    for (final item in widget.pendingCash) {
      total += item.amount;
    }
    return total;
  }

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _borderPulse = CurvedAnimation(
      parent: _borderController,
      curve: Curves.easeInOut,
    );
    if (widget.enableAlarm) {
      _playAlarm();
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAlarm() async {
    if (_isMuted) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 1000));
    if (_isMuted) {
      return;
    }
    await _audioPlayer.setVolume(1.8);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource(widget.alarmAsset));
    await _audioPlayer.resume();
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      await _audioPlayer.stop();
    } else if (widget.enableAlarm) {
      await _playAlarm();
    }
  }

  Future<void> _handleGoToSettings() async {
    final password = widget.settingsPassword ?? '';
    if (password.isEmpty) {
      widget.onGoToSettings?.call();
      return;
    }

    final controller = TextEditingController();
    bool invalid = false;

    Widget buildKey(String label, VoidCallback onTap) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: onTap,
            child: Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            void appendDigit(String digit) {
              controller.text = '${controller.text}$digit';
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
              if (invalid) {
                setState(() => invalid = false);
              }
            }

            void deleteDigit() {
              if (controller.text.isEmpty) {
                return;
              }
              controller.text = controller.text
                  .substring(0, controller.text.length - 1);
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: controller.text.length),
              );
              if (invalid) {
                setState(() => invalid = false);
              }
            }

            return AlertDialog(
              title: const Text('Enter Password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    obscureText: true,
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      errorText: invalid ? 'Password Error' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      Row(
                        children: [
                          buildKey('1', () => appendDigit('1')),
                          buildKey('2', () => appendDigit('2')),
                          buildKey('3', () => appendDigit('3')),
                        ],
                      ),
                      Row(
                        children: [
                          buildKey('4', () => appendDigit('4')),
                          buildKey('5', () => appendDigit('5')),
                          buildKey('6', () => appendDigit('6')),
                        ],
                      ),
                      Row(
                        children: [
                          buildKey('7', () => appendDigit('7')),
                          buildKey('8', () => appendDigit('8')),
                          buildKey('9', () => appendDigit('9')),
                        ],
                      ),
                      Row(
                        children: [
                          buildKey('AC', () {
                            controller.clear();
                            if (invalid) {
                              setState(() => invalid = false);
                            }
                          }),
                          buildKey('0', () => appendDigit('0')),
                          buildKey('⌫', () => deleteDigit()),
                          
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text('Cancel'.tr),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text == password) {
                      Navigator.of(dialogContext).pop();
                      widget.onGoToSettings?.call();
                    } else {
                      setState(() => invalid = true);
                    }
                  },
                  child: Text('OK'.tr),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isMuted
                    ? Colors.grey.shade400
                    : Colors.red.shade600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _toggleMute,
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
              //日文 消音/解除消音
              label: Text(
                _isMuted ? '解除消音' : '消音',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Image.asset(
            'assets/images/public/sorry.png',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 100),
          _buildHeader(theme),
          const SizedBox(height: 50),
          _buildSectionTitle('現金機エラー詳細'),
          const SizedBox(height: 8),
          _buildMessageCard(widget.errorMessage),
          if (widget.faultDetails.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...widget.faultDetails.map(_buildDetailLine),
          ],
          const SizedBox(height: 100),
          _buildSectionTitle('未処理の入金があります'.tr),
          const SizedBox(height: 8),
          _buildPendingSection(),
          Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _handleGoToSettings,
            icon: const Icon(Icons.settings, color: Colors.white),
            label: Text(
              '設定に移動して対応する'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 200),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: _borderPulse,
      builder: (context, child) {
        final glow = 4 + (6 * _borderPulse.value);
        final opacity = 0.35 + (0.45 * _borderPulse.value);
        return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            //borderRadius: BorderRadius.circular(26),
            gradient: LinearGradient(
              colors: [
                Colors.redAccent.withOpacity(opacity),
                Colors.red.shade700.withOpacity(opacity),
                Colors.deepOrange.withOpacity(opacity),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withOpacity(opacity),
                blurRadius: 18 + glow,
                spreadRadius: 2 + (_borderPulse.value * 2),
              ),
            ],
          ),
          child: child,
        );
      },
      child: content,
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error,
            size: 48,
            color: Colors.red.shade800,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '現金機に障害が発生しました。直ちに対応が必要です。',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildMessageCard(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 25, color: Colors.red),
      ),
    );
  }

  Widget _buildDetailLine(String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.red),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              detail,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingSection() {
    if (widget.pendingCash.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          '無し',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
      );
    }

    return Column(
      children: [
        // 総額
        if (widget.pendingCash.isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
          ),
          child: Row(
            children: [
              const Text(
                '総額：',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Text(
                '¥${pandingCashTotalAmount().formatIntSum()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        ...widget.pendingCash.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${item.denomination} ${item.count.formatIntSum()} 枚',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
                ),
              ),
              Text(
                '¥${item.amount.formatIntSum()}',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        );
      }).toList()],
    );
  }
}