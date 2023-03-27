import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_plugin_msprinter/flutter_plugin_msprinter.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/services/Storage.dart';

import 'package:foodorder/config/string.dart';
import 'package:foodorder/services/HttpService.dart';

import 'package:foodorder/config/color.dart';
import 'package:foodorder/widget/LoadState.dart';
import 'package:widget_to_image/widget_to_image.dart';

import 'package:foodorder/services/GetxStorage.dart';

class AppointmentPage extends StatefulWidget {
  AppointmentPage({Key key}) : super(key: key);

  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {

  String _machineCode = "";
  var _shopInfo = "kanran";

  //预约页面默认值
  var _tableTypeList = [
    {"optionVal":"A","optionTable":"指定なし"},
    {"optionVal":"C","optionTable":"カウンター"},
    {"optionVal":"T","optionTable":"テーブル"},
    {"optionVal":"P","optionTable":"個室"},
  ];
  var _selectTableType = "A";
  var _selectManyPeople = 1;
  var _checkLanguage = "JP";
  var _printLogoImage = "";

  @override
  void initState() {
    super.initState();
    EasyLoading.dismiss();
    //先获取店铺信息已获取路径用
    _getShopInfo();

  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  //页面加载状态，默认为加载中
  LoadDataState _layoutState = LoadDataState.State_Loading;

  Widget _listView(BuildContext context) {
    return LoadStateLayout(
      state: _layoutState,//错误按钮点击过后进行重新加载
      successWidget: SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          /*title: Align(
                  alignment: Alignment.center,
                  child:  Text(GString.getToString(this._checkLanguage, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
              ),*/
          children: <Widget>[
            Container(
              width: ScreenAdapter.width(750),
              padding: EdgeInsets.only(left: ScreenAdapter.width(30),right: ScreenAdapter.width(30)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'お席のタイプ',
                    style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(36.0),
                        //color: ColorsUtil.hexToColor("#F9F9F9"),
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  publicShowTableTypeList(),
                  SizedBox(
                    height: 25,
                  ),
                  Text(
                    '何名様',
                    style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(36.0),
                        //color: ColorsUtil.hexToColor("#F9F9F9"),
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  publicShowPeopleNumber(10),
                  /*Container(
                    padding: EdgeInsets.only(
                      left: ScreenAdapter.width(5),
                      right: ScreenAdapter.width(5),
                    ),
                    child: publicShowPeopleNumber(10),
                  ),*/

                  Container(
                    margin: EdgeInsets.only(top: ScreenAdapter.height(20),bottom: ScreenAdapter.height(15)),
                    width: ScreenAdapter.width(700),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenAdapter.width(180),
                            height: ScreenAdapter.height(85),
                            margin: EdgeInsets.only(top: ScreenAdapter.height(35)),
                            decoration: BoxDecoration(

                              color: ColorsUtil.hexToColor("#A61C1C"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            child: Text(
                              "取消",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenAdapter.fontSize(32.0)),
                            ),
                          ),
                        ),
                        SizedBox(width: ScreenAdapter.width(120),),
                        InkWell(
                          onTap: (){
                            doReserve();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: ScreenAdapter.width(180),
                            height: ScreenAdapter.height(85),
                            margin: EdgeInsets.only(top: ScreenAdapter.height(35)),
                            decoration: BoxDecoration(

                              color: ColorsUtil.hexToColor("#A61C1C"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            child: Text(
                              "確定",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenAdapter.fontSize(32.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]
      ),
    );
  }



  //获取机器信息
  _getShopInfo() async {
    var shopInfo = await HomeServices.getShopInfo();
    if (shopInfo != "") {
      setState(() {
        _shopInfo = shopInfo;
      });
    }else{
      Storage.setString('shopInfo', "kanran");
      GetxStorage.setData('shopInfo', "kanran");
    }

    _getPrintLogoImageData();

  }
  _getPrintLogoImageData() async {
    String logoImageInfo = await HomeServices.getSmartweLogoImagesData();
    if(logoImageInfo != "" && logoImageInfo != null){
      setState(() {
        _printLogoImage = logoImageInfo;
      });
    }
    _getMachineInfo();
  }

//获取机器信息
  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      setState(() {
        _machineCode = machineCode;

        //执行完后过 加载动画
        _layoutState = LoadDataState.State_Success;
      });

    }
  }


  _showOrderEasyLoading(){
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );

  }

  //选择桌类型
  publicShowTableTypeList(){
    return Container(
      padding: EdgeInsets.only(
        left: ScreenAdapter.width(5),
        right: ScreenAdapter.width(5),
      ),
      width: ScreenAdapter.width(750),
      height: ScreenAdapter.height(80),
      child: ListView.builder(
        shrinkWrap: true,
        addAutomaticKeepAlives:false,
        //addRepaintBoundaries:false,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          var tableItem = _tableTypeList[index];
          var tableType = (tableItem["optionVal"] == _selectTableType) ? true :false;
          return InkWell(
            onTap: (){
              setState(() {
                _selectTableType = tableItem["optionVal"];
              });
            },
            child: Container(
                width: ScreenAdapter.width(155),
                height: ScreenAdapter.height(80),
                margin: EdgeInsets.only(left: ScreenAdapter.width(10),right: ScreenAdapter.width(10)),
                alignment: Alignment.center,
                decoration: (tableType == true)
                    ? BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ColorsUtil.hexToColor("#CD950C"),
                      ColorsUtil.hexToColor("#CD8500"),
                    ],
                  ),
                  //设置阴影
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2, 3),
                        blurRadius: 3.0,
                        spreadRadius: 0),
                  ],
                )
                    : BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      ColorsUtil.hexToColor("#F7F7F7"),
                      ColorsUtil.hexToColor("#F4F4F4"),
                    ],
                  ),
                  //设置阴影
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2, 3),
                        blurRadius: 3.0,
                        spreadRadius: 0),
                  ],
                ),
                child: Text("${tableItem["optionTable"]}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: ScreenAdapter.fontSize(30.0),
                      color: (tableType == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                    ))),
          );
        },
        itemCount: _tableTypeList.length,
      ),
    );
  }

  //选择预约人数
  publicShowPeopleNumber(peopNUm){
    return Container(
      padding: EdgeInsets.only(
        left: ScreenAdapter.width(5),
        right: ScreenAdapter.width(5),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        addAutomaticKeepAlives:false,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(5),
            crossAxisCount: 5,
            childAspectRatio: 0.99
        ),
        itemBuilder: (BuildContext context, int index) {
          var showNum = index +1;
          var showPeople = (showNum == 10) ? "10+":showNum.toString();
          return InkWell(
            onTap: (){
              setState(() {
                _selectManyPeople = showNum;
              });
            },
            child: Container(
              margin: EdgeInsets.only(top: ScreenAdapter.height(15),bottom: ScreenAdapter.height(15),left: ScreenAdapter.width(10),right: ScreenAdapter.width(10)),
              width: ScreenAdapter.width(105),
              height: ScreenAdapter.height(75),
              decoration: (showNum == _selectManyPeople)
                  ? BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    ColorsUtil.hexToColor("#CD950C"),
                    ColorsUtil.hexToColor("#CD8500"),
                  ],
                ),
                //设置阴影
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      offset: Offset(2, 3),
                      blurRadius: 3.0,
                      spreadRadius: 0),
                ],
              )
                  : BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    ColorsUtil.hexToColor("#F7F7F7"),
                    ColorsUtil.hexToColor("#F4F4F4"),
                  ],
                ),
                //设置阴影
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      offset: Offset(2, 3),
                      blurRadius: 3.0,
                      spreadRadius: 0),
                ],
              ),
              alignment: Alignment.center,
              child: Text("${showPeople}",
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(32),
                  color: (showNum == _selectManyPeople) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
        itemCount: peopNUm,
      ),
    );

  }

  //提交排队信息
  doReserve(){
    var formData = {
      "machineCode": _machineCode,
      "tableType":_selectTableType,
      "howManyPeople":_selectManyPeople,
    };

    request('webBootReserve', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());print(response);
      if (response['code'] == 200  && response['data'] != null) {
        doPrintReserve(response['data']);
        //showToast("预约排队成功");
        Navigator.pop(context);
      }else{
        showToast(response['msg']);
      }

    });
  }

  //去打印小票
  doPrintReserve(reserveInfo) async {
    var printStatus = await FlutterPluginMsprinter.getPrintStatus();
    if(printStatus == "0" || printStatus == "8"){
      //await FlutterPluginMsprinter.sendPrintReserve(reserveInfo,_shopInfo);
      _tpPrintReserve(reserveInfo);
    }else{
      EasyLoading.dismiss();

      var show_dialog_content = "";
      if(printStatus == "7"){
        show_dialog_content = GString.getToString(this._checkLanguage, "tag_print_content_paper_shortage");
      }else{
        show_dialog_content = GString.getToString(this._checkLanguage, "tag_print_content_paper_error");
      }
      //小票状态
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return Container(
              width: ScreenAdapter.width(950),
              child: SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  title: Align(
                      alignment: Alignment.center,
                      child:  Text(GString.getToString(this._checkLanguage, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                  ),
                  children: <Widget>[
                    Container(
                      width: ScreenAdapter.width(650),

                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Align(
                            child: Text(show_dialog_content,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 70.0),
                                child: TextButton(
                                  child: Text(
                                    GString.getToString(this._checkLanguage, "tag_print_button_no"),
                                    style: TextStyle(
                                        color: Colors.lightBlue,
                                        fontSize: ScreenAdapter.fontSize(32.0)),
                                  ),
                                  onPressed: () {
                                    //sleep(Duration(milliseconds: 3000));
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              //垂直分割线
                              SizedBox(
                                width: 1,
                                height: 40,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(color: Colors.black12),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 70.0),
                                child: TextButton(
                                  child: Text(
                                    GString.getToString(this._checkLanguage, "tag_print_button_yes"),
                                    style: TextStyle(
                                        color: Colors.lightBlue,
                                        fontSize: ScreenAdapter.fontSize(32.0)),
                                  ),
                                  onPressed: () async {
                                    //widget.confirmCallback('确定');
                                    Navigator.pop(context);
                                    doPrintReserve(reserveInfo);
                                  },
                                ),
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


  }

  _tpPrintReserve(printData) async {
    List<Widget> categoryMenus = [];
    var lineHight = 250;

    //时间
    categoryMenus.add(
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(bottom: 3),
          child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(printData["reserveTime"],
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w100,
                      fontFamily: 'NotoSansJP',
                      color: ColorsUtil.hexToColor("#000000")
                  ))),
        )
    );

//领収书标题
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["tableType"]}${printData["reserveNo"]}",
                style: TextStyle(
                  fontSize: 90,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w500,
                  color: ColorsUtil.hexToColor("#000000"),))),
      ),
    );

    ByteData byteData = await WidgetToImage.widgetToImage(
        Container(
          width: 380,
          height: lineHight.toDouble(),
          color: Colors.white,
          //alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: categoryMenus,
          ),
        )
    );

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    //final result = await ImageGallerySaver.saveImage(imageBytes, quality: 100);
    Future.delayed(Duration(milliseconds: 100),() async {
      String base64Image = base64Encode(imageBytes);
      //LogUtil.d(base64Image);
      //await FlutterPluginMsprinter.sendPrintImg(base64Image,"0",_shopInfo,"1");
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "0", _shopInfo, "1",_printLogoImage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
        child: _listView(context),
          ),
    );
  }
}
