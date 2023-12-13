import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/modules/OrderHome/controllers/order_home_controller.dart';

import 'package:get/get.dart';

class OPOSAPGView extends GetView<OrderHomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<OrderHomeController>(builder: (controller) {
        return controller.obx(
            (state) => AnnotatedRegion(
                value: SystemUiOverlayStyle.light,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.red,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.blue,
                      ),
                    ),
                  ],
                )),
            onError: (error) => Container());
      }),
    );
  }
}
