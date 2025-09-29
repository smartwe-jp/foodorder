import 'package:get/get.dart';

class ResultState {
  // 剩余秒数
  final RxInt secondsLeft = 5.obs;
  final String successText = 'お支払いが成功しました'.tr;
  // 倒计时下方的提示信息
  final countdownMessage = "秒後に自動で最初の画面に戻ります".obs;
  // 控制按钮是否可点击
  final isButtonEnabled = true.obs;
}
