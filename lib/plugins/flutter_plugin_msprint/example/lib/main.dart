import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_plugin_msprinter/flutter_plugin_msprinter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _statusTex;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterPluginMsprinter.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  invokNative() async {
    /** 
     * var printdata = [
      {"food":"牛肉面", "fenliang":"普通","xing":"形状", "xingzhuang":"二细","xiangcai":"香菜", "xiangcaifenliang":"加倍","lajiao":"辣椒", "lajiaofenliang":"正常"},
      {"food":"牛肉面", "fenliang":"大","xing":"形状", "xingzhuang":"宽","xiangcai":"香菜", "xiangcaifenliang":"正常","lajiao":"辣椒", "lajiaofenliang":"不要"}
        
    ];
     **/


     List printdataOne =[];
     //printdataOne.add({"food":"牛肉面", "fenliang":"普通","xing":"形状", "xingzhuang":"二细","xiangcai":"香菜", "xiangcaifenliang":"加倍","lajiao":"辣椒", "lajiaofenliang":"正常"});
     //printdataOne.add({"food":"牛肉面", "fenliang":"大","xing":"形状", "xingzhuang":"宽","xiangcai":"香菜", "xiangcaifenliang":"正常","lajiao":"辣椒", "lajiaofenliang":"不要"});
     printdataOne.add({"牛肉面":"普通","形状":"二细","香菜":"加倍","辣椒":"正常"});
     printdataOne.add({"牛肉面":"大","形状":"宽","香菜":"正常","辣椒":"不要"});

    List printdataTwo =[];
    printdataTwo.add({"food":"拌面", "fenliang":"大","spec":"热"});
    printdataTwo.add({"food":"拌面", "fenliang":"特大","spec":"冷"});

    List printdataThree =[];
    printdataThree.add({"food":"拌干豆腐丝", "num":"1","pric":"150","total":"150"});
    printdataThree.add({"food":"爽口木耳", "num":"2","pric":"200","total":"400"});
    //{{"牛肉面","普通"},{"形状","二细"},{"香菜","加倍"},{"辣椒","正常"}},
        //{{"牛肉面","大"},{"形状","宽"},{"香菜","正常"},{"辣椒","不要"}}
        print(printdataOne);
        print(printdataTwo);
        print(printdataThree);

     String operdata = "{\"orderNo\":\"20220119\",\"amount\":\"1900\",\"address\":\"这是一个测试地址\",\"orderDate\":\"20220119\",\"telephone\":\"0612345678\",\"machineNo\":\"001\",\"orderLineList\":[{\"name\":\"牛肉面\",\"qty\":\"1\",\"price\":\"800\",\"orderLineOptionList\":[{\"optionName\":\"形状\",\"optionValue\":\"二细\"},{\"optionName\":\"香菜\",\"optionValue\":\"加倍\"}]},{\"name\":\"拌面\",\"qty\":\"1\",\"price\":\"900\",\"orderLineOptionList\":[{\"optionName\":\"冷/热\",\"optionValue\":\"热\"},{\"optionName\":\"分量\",\"optionValue\":\"大份\"}]}]}";
    //if(printdataOne.length>0){
      //for(int i=0; i<printdataOne.length; i++){
        //print(printdataOne[i]);
         //_statusTex = await FlutterPluginMsprinter.sendPrint(printdataOne[i]);
         _statusTex = await FlutterPluginMsprinter.sendPrint(operdata);
        print(_statusTex);
      //}
      
    //}
      //print(printdata);
      //await FlutterPluginMsprinter.sendPrint(printdata);
    

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
            padding: EdgeInsets.all(20),
            child: InkWell(
              // child: Text("申请提现", style: TextStyle(color: Colors.white)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("打印小票", style: TextStyle(color: Colors.black45,fontSize: 20.0))
                ],
              ),
              onTap: () {
                //var arg = {'operEvent': 'startPrint'};
                Map<dynamic, dynamic> argument = {'operEvent': 'startPrint'};
                /*var argument = Map();
                  argument['operEvent'] = 'startPrint';
                  print(argument);*/
                invokNative();
              },
            ),
          ),
      ),
    );
  }
}
