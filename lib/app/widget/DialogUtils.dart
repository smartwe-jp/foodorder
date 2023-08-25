import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../config/imageData.dart';
import '../services/ScreenAdapter.dart';
/// 封装自定义弹框
class DialogUtils {
  /// 基础弹框
  static alert(
      String content, {
        String title = "提示",
        String canceltitle = "取消",
        String confirmtitle = "确定",
        GestureTapCallback confirm,
        GestureTapCallback cancle,
        List<Widget> actions, // 自定义按钮
      }) {
    return Container(
      width: ScreenAdapter.width(950),
      child: SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    //color: Colors.red,
                    padding: EdgeInsets.only(left: ScreenAdapter.width(40),),
                    child: Icon(
                      Icons.notifications_outlined,
                      //color: ColorsUtil.hexToColor("#2aa515"),
                      size: 50,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: ScreenAdapter.width(10)),
                    child: Text(
                        "${title}          ",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(34),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )),
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: ScreenAdapter.width(650),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(20)),
                          padding: EdgeInsets.only(left: ScreenAdapter.width(20),right: ScreenAdapter.width(20)),
                          child: Align(
                            child: Text(content,
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(32))),
                            alignment: Alignment(0, 0),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    )
                ),
              ],
            ),

            Divider(
              thickness: 3.0,
              color: Colors.black12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Container(
                    padding: EdgeInsets.only(left: 70.0),
                    width: ScreenAdapter.width(400),
                    height: ScreenAdapter.height(75),
                    alignment: Alignment.center,
                    child: Text(canceltitle,
                      style: TextStyle(
                        //color: Colors.lightBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenAdapter.fontSize(34.0)
                      ),
                    ),
                  ),
                  onTap: () {
                    //sleep(Duration(milliseconds: 3000));
                    cancle();

                  },
                ),
                //垂直分割线
                SizedBox(
                  width: 3,
                  height: ScreenAdapter.height(95),
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: Colors.black12),
                  ),
                ),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.only(right: 70.0),
                    width: ScreenAdapter.width(400),
                    height: ScreenAdapter.height(75),
                    alignment: Alignment.center,
                    child: Text(confirmtitle,
                      style: TextStyle(
                        //color: Colors.lightBlue,
                          fontSize: ScreenAdapter.fontSize(34.0),
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  onTap: () {
                    confirm();

                  },
                )
              ],
            ),
          ]),
    );
  }
  /// 显示普通消息
  static alertOneButton(
      String content, {
        String title = "提示",
        String confirmtitle = "确定",
        GestureTapCallback confirm,
        String contentTagImg = "",
        List<Widget> actions, // 自定义按钮
      }) {
    return Container(
      width: ScreenAdapter.width(950),
      child: SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          title: Align(
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    //color: Colors.red,
                    padding: EdgeInsets.only(left: ScreenAdapter.width(40),),
                    child: Icon(
                      Icons.notifications_outlined,
                      //color: ColorsUtil.hexToColor("#2aa515"),
                      size: 50,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: ScreenAdapter.width(10)),
                    child: Text(
                        "${title}          ",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(34),
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              )),
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: ScreenAdapter.width(650),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(20)),
                          padding: EdgeInsets.only(left: ScreenAdapter.width(20),right: ScreenAdapter.width(20)),
                          child: Align(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(contentTagImg != "")
                                  Container(
                                    //width: ScreenAdapter.width(400),
                                    //margin: EdgeInsets.only(top: 60),
                                    margin: EdgeInsets.only(right: ScreenAdapter.width(10)),
                                    height: ScreenAdapter.height(55),
                                    child: Image.asset(GImage.getImageString("imgpublic", contentTagImg),fit: BoxFit.fitHeight),
                                  ),
                                Text(content,
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(32))),
                              ],
                            ),
                            alignment: Alignment(0, 0),
                          ),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                      ],
                    )
                ),
              ],
            ),

            Divider(
              thickness: 3.0,
              color: Colors.black12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                InkWell(
                  child: Container(
                    width: ScreenAdapter.width(600),
                    height: ScreenAdapter.height(75),
                    alignment: Alignment.center,
                    child: Text(confirmtitle,
                      style: TextStyle(
                        //color: Colors.lightBlue,
                          fontSize: ScreenAdapter.fontSize(34.0),
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  onTap: () {
                    confirm();

                  },
                )
              ],
            ),
          ]),
    );
  }

}
