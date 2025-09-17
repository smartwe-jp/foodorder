import 'package:flutter/material.dart';
import 'package:foodorder/app/config/font.dart';

import 'package:get/get.dart';

import '../../../services/ScreenAdapter.dart';
import '../controllers/transit_page_controller.dart';

class TransitPageView extends GetView<TransitPageController> {
  TransitPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 未加载完：保留原有 UI（加载 GIF）
      if (!controller.showStartButton.value) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            color: Colors.white,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: ScreenAdapter.width(385),
                    child: Image.asset(
                      "assets/images/public/printticketloading.gif",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // 已加载完：背景图 + 大按钮“ご注文”
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: (controller.heroImageUrl != null &&
                  controller.heroImageUrl!.isNotEmpty)
                  ? Image.network(
                controller.heroImageUrl!,
                fit: BoxFit.fitWidth,
              )
                  : Container(color: Colors.white),
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  spacing: 60,
                  children: [
                    Spacer(),
                    Text(
                      'menu_dingtype_title'.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.green[900],//const Color.fromARGB(255, 53,59,80),
                        fontSize: 80,
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            color: Colors.white,
                            offset: Offset(3.0, -4.0),
                            blurRadius: 1.0,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 420,
                      height: 200,
                      child: ElevatedButton(
                        onPressed: controller.startOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(
                                "ご注文",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 80,
                                  fontFamily: GFont.getFontFamily(),
                                  fontWeight: FontWeight.bold,
                                )
                            ),
                            Icon(
                              Icons.touch_app,
                              color: Colors.white,
                              size: 80,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 260),
                  ],
                )
            ),
          ],
        ),
      );
    });
  }
}