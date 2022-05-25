import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
class AttendancePage extends StatefulWidget {
  AttendancePage({Key key}) : super(key: key);

  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  //创建通道对象，与android端创建的通道对象名称一致
  MethodChannel _channel = MethodChannel("plugins.com.fanxing.foodorder/faceSwipingApi");


  var bytes = null;
  var headBytes;
  var _userName = "";
  @override
  void initState() {
    super.initState();

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
          "photo": backString,
        };



        request('oldrecognitionSearch', method: 'POST', parameters: formData).then((val) {
          var response = json.decode(val.toString());
          print("response-${response}");

          if (response['code'] == 200 && null != response['data']['name'] && "" != response['data']['name']) {

            /*setState(() {
              _userName = response['data']['name'];
            });*/

            showDialogUser(response['data']['name']);
            /*Fluttertoast.showToast(
              msg: "欢迎${response['data']['name']}打卡",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
            );*/

          }else{
            showDialogErrorUser("未找到您");
          }

        });
      }else{
        showDialogErrorUser("请正确打卡");
      }



    }
  }

  showDialogUser(userName){
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
                    child:  Text("温馨提示",style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
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
                          child: Text("欢迎${userName}打卡",
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
                                "确 定",
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
                    child:  Text("温馨提示",style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
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
                                "确 定",
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("考勤打卡"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: AndroidView(
            //与 Android 原生交互时唯一标识符,与Android端有对应关系
            viewType: 'plugins.com.fanxing.foodorder/android_view',
          )),
          SizedBox(height: 25,),
          Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                  child: InkWell(
                    onTap: (){
                      Map<String, String> map = {
                        'takePicture':"1"
                      };
                      //在Flutter端调用执行函数，将Flutter端按钮的点击次数传递到安卓端
                      _channel.invokeMethod("takePictureButtonAndNoticeAndroid", map);
                    },
                    child: Container(
                      width: ScreenAdapter.width(319),
                      height: ScreenAdapter.height(117),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(

                        color: ColorsUtil.hexToColor("#A61C1C"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Text(
                          "打卡",
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w600,
                            color: Colors.blueAccent,
                          )),
                    ),
                  )
          ),
                ],
              )
          ),
SizedBox(height: 15,),
          Container(
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
                  width: 120,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(

                    color: Colors.redAccent,
                    //设置圆角
                    borderRadius: new BorderRadius.circular((16.0)),
                  ),
                  child: Text(
                      "返回",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      )),
                ),
              )
          ),

        ],
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
