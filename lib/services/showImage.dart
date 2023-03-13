
//公共展示菜品图片
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../config/colorsUtil.dart';
import 'ScreenAdapter.dart';

class publicShowMenuImage  extends StatelessWidget{
  final String imgPath;
  final double imgWidth;
  final double imgHeight;
  publicShowMenuImage({Key key,this.imgPath,this.imgWidth=200.0,this.imgHeight=200.0}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    _checkMemory();
    return Container(
      width: ScreenAdapter.width(imgWidth),
      height: ScreenAdapter.height(imgHeight),
      //height: ScreenAdapter.width(imgWidth),
      decoration: new BoxDecoration(
        color: ColorsUtil.hexToColor("#FFFFFF"),
      ),
      child: CachedNetworkImage(
        imageUrl: imgPath,
        //fit: BoxFit.contain,
        fit: BoxFit.cover,
        //fit: BoxFit.fitWidth,
        width: ScreenAdapter.width(imgWidth),
        height: ScreenAdapter.height(imgHeight),
        maxWidthDiskCache: ScreenAdapter.width(imgWidth).toInt(),
        maxHeightDiskCache: ScreenAdapter.height(imgHeight).toInt(),
        //height: ScreenAdapter.width(imgWidth),
        memCacheWidth: ScreenAdapter.width(imgWidth).toInt(),
        memCacheHeight: ScreenAdapter.height(imgHeight).toInt(),
        //cacheManager: EsoImageCacheManager(),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: imageProvider,
                //fit: BoxFit.contain,
                fit: BoxFit.cover,
                //fit: BoxFit.fitWidth,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.colorBurn)
            ),
          ),
        ),
        placeholder: (context, url) => Container(
          width: ScreenAdapter.width(200),
          height: ScreenAdapter.height(200),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Image.network(
          imgPath,
          //fit: BoxFit.contain,
          fit: BoxFit.cover,
          width: ScreenAdapter.width(imgWidth),
          height: ScreenAdapter.height(imgHeight),
          //height: ScreenAdapter.width(imgWidth)
        ),
      ),
    );
  }

  void _checkMemory(){
    var Image_Maxnum = 200;
    var maxSize = 55 << 20;

    ImageCache _imageCache = PaintingBinding.instance.imageCache;
    if(_imageCache.currentSizeBytes >= maxSize || _imageCache.currentSize >= Image_Maxnum){
      _imageCache.clear();
      _imageCache.clearLiveImages();
    }
  }
}
