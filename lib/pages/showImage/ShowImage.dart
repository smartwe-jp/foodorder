
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowImagePage extends StatefulWidget {
  ShowImagePage({Key key}) : super(key: key);

  _ShowImagePageState createState() => _ShowImagePageState();
}

class _ShowImagePageState extends State<ShowImagePage> {
  var imgUrl = 'https://kanran.co.jp/fanxing/sites/6/2021/10/1635210298859_1026-1024x1024.jpg';
  @override
  void initState() {
    super.initState();


  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

  }



  @override
  Widget build(BuildContext context) {
    //ScreenAdapter.init(context);
    //显示底部栏(隐藏顶部状态栏)
//    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    //显示顶部栏(隐藏底部栏)
//    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);
    //隐藏底部栏和顶部状态栏
    //SystemChrome.setEnabledSystemUIOverlays([]);

    return Scaffold(
      appBar: AppBar(
        title: Text("图片"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,  //充满屏幕宽度,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,  //居中
          children: [
            CachedNetworkImage(
              imageUrl: imgUrl,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ],
        ),
      ),
    );
  }
}
