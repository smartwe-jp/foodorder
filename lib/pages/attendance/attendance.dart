import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/config/color.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
class AttendancePage extends StatefulWidget {
  Map arguments;
  AttendancePage({Key key, this.arguments}) : super(key: key);

  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  //创建通道对象，与android端创建的通道对象名称一致
  MethodChannel _channel = MethodChannel("plugins.com.fanxing.foodorder/faceSwipingApi");


  var bytes = null;
  var headBytes;
  String _machineCode = "";

  @override
  void initState() {
    super.initState();
    this._machineCode = widget.arguments['machineCode'];
    //设置此通道上的监听
    _channel.setMethodCallHandler(_handlerMethodCall);
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }
  Future<dynamic> _handlerMethodCall(MethodCall call) async {
    //获取通道监听中调用的函数名称
    String method = call.method;
    if (method == 'clickAndroidButtonAndNoticeFlutter') {
      String androidResultImage = call.arguments['AndroidResultImage'];

      if(androidResultImage.length>0){
        String backString = androidResultImage.replaceAll('\r', '').replaceAll('\n', '');

        var formData = {
          "machineCode":_machineCode,
          "photo": backString,

        };

        request('oldrecognitionSearch', method: 'POST', parameters: formData).then((val) {
          var response = json.decode(val.toString());

          EasyLoading.dismiss();
          if (response['code'] == 200 && null != response['data']['name'] && "" != response['data']['name']) {

            showDialogUser(response['data']['name'],response['data']['employeeNo'],response['data']['avatarUrl'],response['data']['time'],response['data']['message']);


          }else{
            showDialogErrorUser("認証ができません");
          }

        });
      }else{
        showDialogErrorUser("認証ができません");
      }



    }
  }

  showDialogUser(userName,employeeNo,avatarUrl,showTime,showMessage){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            //width: 400,
            child: SimpleDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                //backgroundColor: Colors.transparent,
                /*title: Align(
                    alignment: Alignment.center,
                    child:  Text("温馨提示",style: TextStyle(fontSize: 28,fontWeight: FontWeight.w600))
                ),*/
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(550),
                    height: ScreenAdapter.height(410),

                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width:ScreenAdapter.width(200),
                                height: ScreenAdapter.height(250),
                                padding: EdgeInsets.all(15),
                                child: Image.network("${avatarUrl}",fit: BoxFit.fitHeight,)
                            ),
                            SizedBox(width: 10,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("名前:${userName}", style: TextStyle(fontSize: 28)),
                                //SizedBox(height: 15,),
                                //Text("部署:研发部", style: TextStyle(fontSize: 28)),
                                SizedBox(height: 15,),
                                Text("社員番号:${employeeNo}", style: TextStyle(fontSize: 28)),
                                SizedBox(height: 15,),
                                Text("打刻時間:${showTime}", style: TextStyle(fontSize: 28)),
                              ],
                            )
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("${showMessage}", style: TextStyle(fontSize: 30,color: ColorsUtil.hexToColor("#0000EE"),
                                fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(
                          height: 25,
                        ),

                        Divider(
                          thickness: 1.0,
                          color: Colors.black12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [

                            TextButton(
                              child: Text(
                                "確 認",
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 30),
                              ),
                              onPressed: () async {
                                //widget.confirmCallback('确定');
                                Navigator.pop(context);

                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          );
        });
  }

  showDialogErrorUser(msg){
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: ScreenAdapter.width(650),
            child: SimpleDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: Align(
                    alignment: Alignment.center,
                    child:  Text("お知らせ",style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                ),
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(600),

                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text(msg,
                              style: TextStyle(fontSize: ScreenAdapter.fontSize(28))),
                          alignment: Alignment(0, 0),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1.0,
                          color: Colors.black12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            TextButton(
                              child: Text(
                                "確 認",
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: ScreenAdapter.fontSize(32.0)),
                              ),
                              onPressed: () async {
                                //widget.confirmCallback('确定');
                                Navigator.pop(context);

                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          );
        });
  }

  _showEasyLoading(){
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(500),
        height: ScreenAdapter.height(400),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        decoration: BoxDecoration(
          //设置边框
          border: new Border.all(color: ColorsUtil.hexToColor("#F9F9F9"), width: 0.5),
          //背景颜色
          color: Colors.white,
          //设置圆角
          borderRadius: new BorderRadius.circular((15.0)),
          //设置阴影
          boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#949191"), offset: Offset(1.0, 1.0), blurRadius: 1.5, spreadRadius: 1.5), ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset("assets/images/public/printticketloading.gif",fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("チェックイン",textAlign:TextAlign.center,style: TextStyle(color:Colors.white,fontSize: ScreenAdapter.fontSize(34.0))),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,size: 22,),
          onPressed: (){
            Navigator.pop(context); // 关闭当前页面
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: ScreenAdapter.height(80),),
          Expanded(child: AndroidView(
            //与 Android 原生交互时唯一标识符,与Android端有对应关系
            viewType: 'plugins.com.fanxing.foodorder/android_view',
          )),
          SizedBox(height: 50,),
          Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  /*Container(
                      child: InkWell(
                        onTap: (){
                          //在Flutter端调用执行函数，将Flutter端按钮的点击次数传递到安卓端
                          _channel.invokeMethod("stopPictureButtonAndNoticeAndroid");
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Future.delayed(Duration(milliseconds: 100), () {
                            Navigator.pushNamed(context, '/home');
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: ScreenAdapter.height(30)),
                          width: ScreenAdapter.width(210),
                          height: ScreenAdapter.height(100),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(

                            color: ColorsUtil.hexToColor("#67c23a"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((16.0)),
                          ),
                          child: Text(
                              "戻る",
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )),
                        ),
                      )
                  ),
                  SizedBox(width: 35,),*/
                  Container(
                      child: InkWell(
                        onTap: (){
                          _showEasyLoading();
                          Map<String, String> map = {
                            'takePicture':"1"
                          };
                          //在Flutter端调用执行函数，将Flutter端按钮的点击次数传递到安卓端
                          _channel.invokeMethod("takePictureButtonAndNoticeAndroid", map);
                        },
                        child: Container(
                          width: ScreenAdapter.width(400),
                          height: ScreenAdapter.height(400),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(

                            //color: ColorsUtil.hexToColor("#A61C1C"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((16.0)),
                            image: new DecorationImage(
                              alignment: Alignment.centerRight,
                              fit: BoxFit.fitHeight,
                              image: AssetImage(GImage.getImageString("kanran", "qiandaobutton")),
                            ),
                          ),
                          //打卡
                          child: Text(
                              "スキャン開始",
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                              )),
                        ),
                      )
                  ),
                ],
              )
          ),


        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
