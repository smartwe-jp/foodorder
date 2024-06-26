
//公共展示菜品图片
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:transparent_image/transparent_image.dart';

import '../config/colorsUtil.dart';
import '../config/fontSize.dart';
import 'ScreenAdapter.dart';

class publicShowMenuImage  extends StatelessWidget{
  final String imgPath;
  final double imgWidth;
  final double imgHeight;
  final List? subTitle;
  publicShowMenuImage({Key? key,required this.imgPath,this.imgWidth=200.0,this.imgHeight=200.0,this.subTitle}) : super(key: key);

  //公共设置标签 subTitle
  publicShowMenuSubtitle(subtitleList) {
    //标签循环相关
    if (subtitleList != null && subtitleList.length > 0) {
      var subtitle ="";
      if (subtitleList != null && subtitleList?.length > 0) {
        for (var i = 0; i < subtitleList.length; i++) {
          subtitle += subtitleList[i];
        }
      }
      return Container(
        width: ScreenAdapter.width(imgWidth),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50]?.withOpacity(0.65),
            /*border: Border(
              top: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
              right: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
            ),*/
          ),
        child: Container(
          padding: EdgeInsets.only(left:ScreenAdapter.width(5),top:ScreenAdapter.height(5),right:ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),

          child: Row(
            children: [
              Expanded(
                  child: Text(subtitle,
                style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(20),
                    color: ColorsUtil.hexToColor("#000000")),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
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

  @override
  Widget build(BuildContext context) {
    _checkMemory();
    return Stack(
      children: [
        Container(
          width: ScreenAdapter.width(imgWidth),
          height: ScreenAdapter.height(imgHeight),
          //height: ScreenAdapter.width(imgWidth),
          decoration: new BoxDecoration(
            color: ColorsUtil.hexToColor("#FFFFFF"),
          ),
          child:
          // Stack(
          //   children: <Widget>[
              //const Center(child: CircularProgressIndicator(strokeWidth: 2,)),
              Container(
                width: ScreenAdapter.width(imgWidth),
                height: ScreenAdapter.height(imgHeight),
                child: FadeInImage.memoryNetwork(
                  placeholder: kTransparentImage,
                  image: imgPath,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: ScreenAdapter.width(imgWidth),
                        height: ScreenAdapter.height(imgHeight),
                        decoration: new BoxDecoration(
                          color: ColorsUtil.hexToColor("#FFFFFF"),
                        ),

                        );


                    },
                  // loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                  //   if (loadingProgress == null) return child;
                  //   return Center(
                  //     child: CircularProgressIndicator(
                  //       value: loadingProgress.expectedTotalBytes != null
                  //           ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  //           : null,
                  //       strokeWidth: 2,
                  //     ),
                  //   );
                  // },
                ),
            //   ),
            // ],
          ),

          // CachedNetworkImage(
          //   imageUrl: imgPath,
          //   //fit: BoxFit.contain,
          //   fit: BoxFit.cover,
          //   //fit: BoxFit.fitWidth,
          //   width: ScreenAdapter.width(imgWidth),
          //   height: ScreenAdapter.height(imgHeight),
          //   maxWidthDiskCache: ScreenAdapter.width(imgWidth).toInt(),
          //   maxHeightDiskCache: ScreenAdapter.height(imgHeight).toInt(),
          //   //height: ScreenAdapter.width(imgWidth),
          //   memCacheWidth: ScreenAdapter.width(imgWidth).toInt(),
          //   memCacheHeight: ScreenAdapter.height(imgHeight).toInt(),
          //   imageBuilder: (context, imageProvider) => Container(
          //     decoration: BoxDecoration(
          //       image: DecorationImage(
          //           image: imageProvider,
          //           //fit: BoxFit.contain,
          //           fit: BoxFit.cover,
          //           //fit: BoxFit.fitWidth,
          //           colorFilter: ColorFilter.mode(Colors.white, BlendMode.colorBurn)
          //       ),
          //     ),
          //   ),
          //   placeholder: (context, url) => Container(
          //     width: ScreenAdapter.width(200),
          //     height: ScreenAdapter.height(200),
          //     child: Center(
          //       child: CircularProgressIndicator(
          //         strokeWidth: 2,
          //       ),
          //     ),
          //   ),
          //   errorWidget: (context, url, error) => Image.network(
          //     imgPath,
          //     //fit: BoxFit.contain,
          //     fit: BoxFit.cover,
          //     width: ScreenAdapter.width(imgWidth),
          //     height: ScreenAdapter.height(imgHeight),
          //     //height: ScreenAdapter.width(imgWidth)
          //   ),
          // ),
        ),
        Positioned(
          left: ScreenAdapter.width(0),
          bottom: ScreenAdapter.height(0),
          child: publicShowMenuSubtitle(subTitle),
        )
      ],
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
