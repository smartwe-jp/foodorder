import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widget/PressScaleButton.dart';
import 'logic.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 注入逻辑控制器
    final logic = Get.put(ResultLogic());
    final state = logic.state;

    return Scaffold(
      // 背景颜色，对应HTML中的 bg-slate-50
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 成功图标
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF43A047), // 对应 green-600
                size: 214, // 对应 w-36 h-36
              ),
              const SizedBox(height: 60), // 对应 mb-10

              // 主标题：注文成功
              Text(
                "order_success_title".tr,
                style: TextStyle(
                  fontSize: 98, // 对应 text-5xl
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800], // 对应 green-600
                ),
              ),
              const SizedBox(height: 30), // 对应 mb-5

              // 副标题：感谢语
              Text(
                "order_success_tips".tr,
                style: TextStyle(
                  fontSize: 36, // 对应 text-xl
                  color: Color(0xFF475569), // 对应 slate-600
                ),
              ),
              const SizedBox(height: 120), // 对应 mb-16

              // 倒计时提示 (使用 Obx 进行响应式更新)
              Obx(() {
                if (state.secondsLeft.value > 0) {
                  return RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20, // 对应 text-lg
                        color: Color(0xFF64748B), // 对应 slate-500
                        fontFamily: 'Inter', // 确保字体一致
                      ),
                      children: [
                        TextSpan(
                          text: '${state.secondsLeft.value}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155), // 对应 slate-700
                          ),
                        ),
                        TextSpan(text: state.countdownMessage.value),
                      ],
                    ),
                  );
                } else {
                  return Text(
                    state.countdownMessage.value,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Color(0xFF64748B),
                    ),
                  );
                }
              }),
              const SizedBox(height: 40), // 对应 mb-10

              // 手动返回按钮

              Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 400),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 10),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child:
                  PressScaleButton(
                    onTap: logic.manualBack,
                    width: double.infinity,
                    height: 64,
                    color: Colors.white,
                    borderRadius: 8,
                    child: Text(
                      'origin_home'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155), // 文本颜色
                      ),
                    ),


                  // ElevatedButton(
                  //   // 根据状态判断按钮是否可点击
                  //   onPressed: state.isButtonEnabled.value ? logic.manualBack : null,
                  //   style: ElevatedButton.styleFrom(
                  //     // 按钮样式
                  //     backgroundColor: Colors.white,
                  //     foregroundColor: const Color(0xFF334155), // 点击时的水波纹颜色
                  //     elevation: 2,
                  //     shadowColor: Colors.black.withValues(alpha: 25),
                  //     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8.0),
                  //       side: const BorderSide(color: Color(0xFFCBD5E1)), // 边框
                  //     ),
                  //     disabledBackgroundColor: Colors.white.withValues(alpha: 175),
                  //   ),
                  //   child: Text(
                  //     'origin_home'.tr,
                  //     maxLines: 2,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: TextStyle(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.w600,
                  //       color: Color(0xFF334155), // 文本颜色
                  //     ),
                  //   ),
                  // ),


                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}
