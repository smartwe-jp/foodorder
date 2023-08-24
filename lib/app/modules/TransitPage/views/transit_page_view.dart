import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:print_image_generate_tool/print_image_generate_tool.dart';


import '../../../services/ScreenAdapter.dart';
import '../controllers/transit_page_controller.dart';

class TransitPageView extends GetView {
  final TransitPageController controller = Get.put(TransitPageController());
  //final TransitPageController controller = Get.find<TransitPageController>();
   TransitPageView({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        color: Colors.white,
        child: Container(
          //height: ScreenUtil().setHeight(400),
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenAdapter.width(385),
                //height: ScreenUtil().setHeight(320),
                child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitWidth,),
              ),
              //Text('拼命加载中...',style: TextStyle(color: Colors.black),)
            ],
          ),
        ),
      ),
    );
  }
}
