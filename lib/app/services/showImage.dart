
//公共展示菜品图片
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:foodorder/app/config/font.dart';

import '../config/colorsUtil.dart';
import 'ScreenAdapter.dart';

// 菜单页统一图片磁盘缓存（与 MenuPageController 共用）
final CacheManager menuImageCacheManager = CacheManager(
  Config(
    'menu_page',
    stalePeriod: const Duration(days: 7),
    maxNrOfCacheObjects: 500,
  ),
);

int _memCachePixel(BuildContext context, double logicalSize,
    {bool useHeight = false}) {
  final dpr = MediaQuery.devicePixelRatioOf(context);
  final size =
      useHeight ? ScreenAdapter.height(logicalSize) : ScreenAdapter.width(logicalSize);
  return (size * dpr).round();
}

/// 限制解码尺寸，避免大图在 kiosk 上解码失败或 OOM
int _capMemCachePixel(int value) => value.clamp(1, 1400);

class publicShowMenuImage extends StatelessWidget {
  final String imgPath;
  final double imgWidth;
  final double imgHeight;
  final List? subTitle;
  final BoxFit fit;

  publicShowMenuImage({
    Key? key,
    required this.imgPath,
    this.imgWidth = 200.0,
    this.imgHeight = 200.0,
    this.subTitle,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  //公共设置标签 subTitle
  publicShowMenuSubtitle(subtitleList) {
    //标签循环相关
    if (subtitleList != null && subtitleList.length > 0) {
      var subtitle = "";
      if (subtitleList != null && subtitleList?.length > 0) {
        for (var i = 0; i < subtitleList.length; i++) {
          subtitle += subtitleList[i];
        }
      }
      return Container(
        width: ScreenAdapter.width(imgWidth),
        decoration: BoxDecoration(
          color: Colors.blueGrey[50]?.withOpacity(0.65),
        ),
        child: Container(
          padding: EdgeInsets.only(
              left: ScreenAdapter.width(5),
              top: ScreenAdapter.height(5),
              right: ScreenAdapter.width(5),
              bottom: ScreenAdapter.height(5)),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(20),
                      color: ColorsUtil.hexToColor("#000000")),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  Widget _imagePlaceholder() {
    return Container(
      width: ScreenAdapter.width(imgWidth),
      height: ScreenAdapter.height(imgHeight),
      color: ColorsUtil.hexToColor("#F0F0F0"),
      child: Icon(
        Icons.restaurant_menu,
        size: ScreenAdapter.fontSize(imgWidth > 400 ? 80 : 48),
        color: Colors.grey.shade400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = imgPath.trim();
    final memCacheWidth =
        _capMemCachePixel(_memCachePixel(context, imgWidth));
    final memCacheHeight =
        _capMemCachePixel(_memCachePixel(context, imgHeight, useHeight: true));

    return Stack(
      children: [
        Container(
          width: ScreenAdapter.width(imgWidth),
          height: ScreenAdapter.height(imgHeight),
          decoration: BoxDecoration(
            color: ColorsUtil.hexToColor("#FFFFFF"),
          ),
          child: url.isEmpty
              ? _imagePlaceholder()
              : CachedNetworkImage(
                  imageUrl: url,
                  cacheManager: menuImageCacheManager,
                  fit: fit,
                  width: ScreenAdapter.width(imgWidth),
                  height: ScreenAdapter.height(imgHeight),
                  memCacheWidth: memCacheWidth,
                  memCacheHeight: memCacheHeight,
                  placeholder: (context, _) => Container(
                    color: ColorsUtil.hexToColor("#FFFFFF"),
                  ),
                  errorWidget: (context, _, __) => _imagePlaceholder(),
                ),
        ),
        Positioned(
          left: ScreenAdapter.width(0),
          bottom: ScreenAdapter.height(0),
          child: publicShowMenuSubtitle(subTitle),
        )
      ],
    );
  }
}
