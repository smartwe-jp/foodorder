import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/selfservice_page_controller.dart';

class SelfservicePageView extends GetView<SelfservicePageController> {
  const SelfservicePageView({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SelfservicePageView'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'SelfservicePageView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
