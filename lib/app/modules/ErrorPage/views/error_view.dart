

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/ErrorPage/controllers/error_controller.dart';
import 'package:get/get.dart';


class ErrorPageView extends GetView<ErrorPageController> {

  ErrorPageView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child:
              Container(
                height: 80,
                child: ElevatedButton(
                  onPressed: () {
                    controller.reStartApp();
                  },
                  child: Text("reboot_app".tr,
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      )),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)
                    )),
                  ),
                ),
              ),
          ),

          SizedBox(width: 100),

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
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.teal[700]),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40)
                )),
              ),
            ),
          )),
        ],
      ),
    );
  }

}