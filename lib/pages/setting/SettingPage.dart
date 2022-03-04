import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/plugins/appset/lib/appset.dart';
import 'package:foodorder/services/ScreenAdapter.dart';

class SettingPage extends StatefulWidget {
  SettingPage({Key key}) : super(key: key);

  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  //监听页面销毁的事件
  dispose() {
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState

  }

  //隐藏状态栏导航栏
  hideBullyScreen() async {
    await Appset.hideBullyScreen;
  }

  //显示状态栏导航栏
  showBullyScreen() async {
    await Appset.showBullyScreen;
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(title:Text("设置")),
        body: ListView(
          children: <Widget>[
            Container(
              height: 0,
            ),

            Container(
              decoration: new BoxDecoration(color: Colors.white),
              margin:EdgeInsets.only(top: ScreenAdapter.height(15.0),),
              alignment: Alignment.center,
              padding: EdgeInsets.only(
                top: ScreenAdapter.height(5.0),
                left: ScreenAdapter.width(20.0),
                right: ScreenAdapter.width(20.0),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        new MaterialPageRoute(
                          builder: (BuildContext context) {
                            return new HomePage();
                          },
                        ),
                            (Route route) => false,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        top: ScreenAdapter.height(20.0),
                        left: ScreenAdapter.width(20.0),
                        //right: ScreenAdapter.width(25.0),
                        bottom: ScreenAdapter.height(20.0),
                      ),
                      child: Text(
                        "回到首页",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(30.0),
                            color: Colors.black),
                      ),
                    ),
                  ),
                  Divider(
                    height: ScreenAdapter.height(10),
                    indent: ScreenAdapter.width(15.0),
                    endIndent: ScreenAdapter.width(15.0),
                  ),
                  InkWell(
                    onTap: () {
                      hideBullyScreen();
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        top: ScreenAdapter.height(20.0),
                        left: ScreenAdapter.width(20.0),
                        //right: ScreenAdapter.width(25.0),
                        bottom: ScreenAdapter.height(20.0),
                      ),
                      child: Text(
                        "隐藏状态栏、导航栏",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(30.0),
                            color: Colors.black),
                      ),
                    ),
                  ),
                  Divider(
                    height: ScreenAdapter.height(10),
                    indent: ScreenAdapter.width(15.0),
                    endIndent: ScreenAdapter.width(15.0),
                  ),
                  InkWell(
                    onTap: (){
                      showBullyScreen();
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        top: ScreenAdapter.height(20.0),
                        left: ScreenAdapter.width(20.0),
                        //right: ScreenAdapter.width(25.0),
                        bottom: ScreenAdapter.height(25.0),
                      ),
                      child: Text(
                        "显示状态栏、导航栏",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(30.0),
                            color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),


            Container(
              decoration: new BoxDecoration(color: Colors.white),
              margin:EdgeInsets.only(top: ScreenAdapter.height(15.0),),
              padding: EdgeInsets.only(
                top: ScreenAdapter.height(10.0),
                left: ScreenAdapter.width(20.0),
                right: ScreenAdapter.width(20.0),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      //退出关闭
                      exit(0);
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        top: ScreenAdapter.height(13.0),
                        left: ScreenAdapter.width(20.0),
                        //right: ScreenAdapter.width(25.0),
                        bottom: ScreenAdapter.height(25.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "退出App",
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(30.0),
                                color: Colors.black),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                right: ScreenAdapter.width(18)),

                          )
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),


          ],
        ));
  }
}
