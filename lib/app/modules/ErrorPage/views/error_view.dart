

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/ErrorPage/controllers/error_controller.dart';
import 'package:get/get.dart';


class ErrorPageView extends GetView<ErrorPageController> {

  ErrorPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return _CashMachineAlarmFrame(
      child: Scaffold(
      body: Center(
        child: 
        Container(
          //padding: EdgeInsets.only(top: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              headView(),
              Expanded(
                flex: 5,
                child:
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/error/cash_${controller.language.value}.png"),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
              ),

              Divider(height: 1, color: Colors.grey),
              Expanded(
                flex: 3,
                child: tipsView(),
              ),

              buttonView(),

            ],
          ),
        )
      
      ),
    ),
    );
  }

  Widget headView() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 30, bottom: 30),
      decoration: BoxDecoration(
        color: ColorsUtil.hexToColor("#08bfa4"),
      ),
      child:Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/public/alarm_icon.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SizedBox(width: 30),

          Text("cash_change_error_title".tr,
              style: TextStyle(
                fontSize: 40,
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
        ],
      )


    )
    ;
  }

  Widget tipsView() {
    return Container(
      padding: EdgeInsets.only(top: 120, left: 50, right: 50),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
            height: 40,
              width: 40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/error/tips_alarm.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10),
            Flexible(  // 使用 Flexible 包裹 Text
              child: Text("cash_change_error_tips_up".tr,
                style: TextStyle(
                  fontFamily: GFont.getFontFamily(),
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            ],
          ),



          SizedBox(height: 50),

          Container(
            margin: EdgeInsets.only(left: 50),
            child:
            Text("cash_change_error_tips_down".tr,
              style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                fontSize: 35,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          )


        ],
      ),
    );
  }

  Widget buttonView() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ColorsUtil.hexToColor("#f3f3f3"),
      ),
      padding: EdgeInsets.only(top: 50, bottom: 50, left: 100, right: 100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Expanded(
          child:
          Container(
            height: 80,
            child: ElevatedButton(
              onPressed: () {
                Get.back();
                Get.back();
                //Get.until(ModalRoute.withName('/menu-page'));
              },
              child: Text("change_payment".tr,
                  style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: 35,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)),
              ),
            ),
          )),
        ],
      ),
    );
  }

}

class _CashMachineAlarmFrame extends StatefulWidget {
  const _CashMachineAlarmFrame({required this.child});

  final Widget child;

  @override
  State<_CashMachineAlarmFrame> createState() => _CashMachineAlarmFrameState();
}

class _CashMachineAlarmFrameState extends State<_CashMachineAlarmFrame>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final AnimationController _borderController;
  late final Animation<double> _borderPulse;
  bool _isMuted = false;

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
    _playAlarm();
  }

  Future<void> _playAlarm() async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted || _isMuted) return;
    await _audioPlayer.setVolume(1.8);
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource('audios/digital-alarm-2.mp3'));
  }

  Future<void> _toggleMute() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      await _audioPlayer.stop();
    } else {
      await _playAlarm();
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _borderPulse,
          child: widget.child,
          builder: (context, child) {
            final glow = 4 + (6 * _borderPulse.value);
            final opacity = 0.35 + (0.45 * _borderPulse.value);
            return Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.withValues(alpha: opacity),
                    Colors.red.shade700.withValues(alpha: opacity),
                    Colors.deepOrange.withValues(alpha: opacity),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: opacity),
                    blurRadius: 18 + glow,
                    spreadRadius: 2 + (_borderPulse.value * 2),
                  ),
                ],
              ),
              child: child,
            );
          },
        ),
        Positioned(
          top: 45,
          right: 45,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isMuted ? Colors.grey.shade400 : Colors.red.shade600,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _toggleMute,
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
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
      ],
    );
  }
}
