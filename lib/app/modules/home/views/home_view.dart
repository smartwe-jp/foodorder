import 'package:flutter/material.dart';

import 'package:get/get.dart';


import '../controllers/home_controller.dart';

class HomeView extends GetView {
  final HomeController controller = Get.put(HomeController());
  HomeView({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //Text("Loading")
          ],
        ),
      ),
    );
  }
}
