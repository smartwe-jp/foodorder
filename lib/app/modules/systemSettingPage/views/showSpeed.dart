import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/imageData.dart';
import '../../../services/ScreenAdapter.dart';
import '../controllers/system_setting_page_controller.dart';


class showSpeedView extends GetView {
  final SystemSettingPageController controller = Get.find();
  showSpeedView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      contentPadding: EdgeInsets.all(0),
      children: [
        Stack(
          children: [
            Container(
              width: ScreenAdapter.width(550),
              height:ScreenAdapter.height(450),
              padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("アップデート中……",
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(25),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      )),
                  Obx(() => Text(
                      '${(controller.downloadProgress.value * 100).toStringAsFixed(2)}%',//Download Progress:
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(25),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor("#000000"),
                      )
                  )
                  ),
                  SizedBox(height: ScreenAdapter.height(30),),
                  Container(
                    //width: ScreenAdapter.width(400),
                    height: ScreenAdapter.height(200),
                    child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
                  ),
                ],
              ),
            ),
            Positioned(
              right: ScreenAdapter.width(0),
              top: ScreenAdapter.height(0),
              child: InkWell(
                highlightColor: Colors.transparent, // 透明色
                splashColor: Colors.transparent, // 透明色
                onTap: (){
                  Get.back();
                },
                child: Icon(
                  Icons.close_outlined,
                  color: ColorsUtil.hexToColor("#000000"),
                  size: 28.0,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
