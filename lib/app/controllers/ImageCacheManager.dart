import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'machine_info.dart';


class MyImageCacheManager {
  static Future<void> preloadImages() async {
    final MachineInfoController machineInfo = Get.find();
    final String imageUrl = machineInfo.printLogoImageUrl;

    if (imageUrl.isNotEmpty) {
      try {
        await precacheImage(CachedNetworkImageProvider(imageUrl), Get.context!);
        debugPrint('Image preloaded successfully: $imageUrl');
      } catch (e) {
        debugPrint('Error preloading image: $imageUrl - $e');
      }
    }
  }
}