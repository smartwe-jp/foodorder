
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/services/ScreenAdapter.dart';

class ToastCompoent {
  static OverlayEntry _overlayEntry; // toast靠它加到屏幕上
  static bool _showing = false; // toast是否正在showing
  static DateTime _startedTime; // 开启一个新toast的当前时间，用于对比是否已经展示了足够时间
  static String _msg; // 提示内容
  static int _showTime; // toast显示时间
  static Color _bgColor; // 背景颜色
  static Color _textColor; // 文本颜色
  static double _textSize; // 文字大小
  static String _toastPosition; // 显示位置
  static double _pdHorizontal; // 左右边距
  static double _pdVertical; // 上下边距
  static String _img; //图片
  static String _sound; //声音 1确定 2删除
  static void toast(
      BuildContext context, {
        String img,
        String sound,
        String msg,
        int showTime = 1000,
        Color bgColor = Colors.transparent,
        Color textColor = Colors.white,
        double textSize = 14.0,
        String position = 'center',
        double pdHorizontal = 20.0,
        double pdVertical = 10.0,
      }) async {
    assert(msg != null);
    assert(img != null);
    _msg = msg;
    _img = img;
    _sound = sound;
    _startedTime = DateTime.now();
    _showTime = showTime;
    _bgColor = bgColor;
    _textColor = textColor;
    _textSize = textSize;
    _toastPosition = position;
    _pdHorizontal = pdHorizontal;
    _pdVertical = pdVertical;
    //获取OverlayState
    OverlayState overlayState = Overlay.of(context);
    _showing = true;
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
          builder: (BuildContext context) => Positioned(
            //top值，可以改变这个值来改变toast在屏幕中的位置
            top: _calToastPosition(context),
            child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0),
                  child: AnimatedOpacity(
                    opacity: _showing ? 1.0 : 0.0, //目标透明度
                    duration: _showing
                        ? Duration(milliseconds: 100)
                        : Duration(milliseconds: 300),
                    child: _buildToastWidget(),
                  ),
                )),
          ));
      _sound=="1"?_playQRScannerSound():_deleteItemSound();
      overlayState.insert(_overlayEntry);
    } else {
      //重新绘制UI，类似setState
      _overlayEntry.markNeedsBuild();
    }
    await Future.delayed(Duration(milliseconds: _showTime)); // 等待时间

    //2秒后 到底消失不消失
    if (DateTime.now().difference(_startedTime).inMilliseconds >= _showTime) {
      _showing = false;
      _overlayEntry.markNeedsBuild();
      await Future.delayed(Duration(milliseconds: 200));
      _overlayEntry.remove();
      _overlayEntry = null;
    }
  }

  static _playQRScannerSound() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/14428.wav"),
      autoStart: true,
      volume: 0.3,
    );
  }

  static _deleteItemSound() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/697.wav"),
      autoStart: true,
      volume: 0.8,
    );
  }

  //toast绘制
  static _buildToastWidget() {
    return Center(
      child: Container(
        color: _bgColor,
        child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: _pdHorizontal, vertical: _pdVertical),
            child: Column(
              children: <Widget>[
                SizedBox(height: 40,),
                Image.asset(_img,width: ScreenAdapter.width(150),height: ScreenAdapter.height(150)),
                Text(
                  _msg,
                  style: TextStyle(
                    fontSize: _textSize,
                    color: _textColor,
                  ),
                ),
              ],
            )),
      ),
    );
  }

//  设置toast位置
  static _calToastPosition(context) {
    var backResult;
    if (_toastPosition == 'top') {
      backResult = MediaQuery.of(context).size.height * 1 / 4;
    } else if (_toastPosition == 'center') {
      backResult = MediaQuery.of(context).size.height * 2 / 5;
    } else {
      backResult = MediaQuery.of(context).size.height * 3 / 4;
    }
    return backResult;
  }
}

