
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:foodorder/app/services/logUtil.dart';
import 'package:get/get.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../config/colorsUtil.dart';
import '../plugins/flutter_plugin_msprint/lib/flutter_plugin_msprinter.dart';
import '../services/HomeServices.dart';
import '../services/ScreenAdapter.dart';
import '../services/formatMoney.dart';

class CreatePrintImageController extends GetxController {
  RxString machineCode = "".obs;
  RxString machineMode = "1".obs;
  RxString printLogoImage = "".obs;
  String? printLogoImageData;

  final printTitleFont = TextStyle(
    fontFamily: 'NotoSansJP',
    color: Colors.black,
    fontSize: 50,
    fontWeight: FontWeight.w300,
  );
  final printMenuFont = TextStyle(
    fontFamily: 'NotoSansJP',
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.w200,
  );

  final printMenu2Font = TextStyle(
    fontFamily: 'NotoSansJP',
    color: Colors.black,
    fontSize: 26,
    fontWeight: FontWeight.w100,
  );

  final printMenu3Font = TextStyle(
    fontFamily: 'NotoSansJP',
    color: Colors.black,
    fontSize: 28,
    fontWeight: FontWeight.w200,
  );

  @override
  Future<void> onInit() async {
    super.onInit();
    await _getPrintLogoImageData();
  }


  _getPrintLogoImageData() async {
    String logoImageInfo = await HomeServices.getSmartweLogoImagesData();
    if(logoImageInfo != "" && logoImageInfo != null){
      printLogoImage.value = logoImageInfo;
    }
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();
    if(systemSettingInfo != null){

      machineMode.value = systemSettingInfo["machineMode"];
    }

    machineCode.value = await HomeServices.getMachineInfo();

    await getImageDataForPlugin();
    //change(null, status: RxStatus.success());
  }

  Future getImageDataForPlugin() async {
    String logoImageInfo = await HomeServices.getSmartweLogoImage();
    if(logoImageInfo != ""){
      printLogoImageData = logoImageInfo;
    }
  }

  tpPrintnew(print_paper_txt_size, printData, printType) async {
    var takeOut = printData["takeOut"] ?? false;
    var takeoutTag = (takeOut == true) ? "【T】":"";
    var categoryVos = printData["printInfoListStruct"];
    if (categoryVos == null || categoryVos.length == 0) {
      tpPrintReceipt(print_paper_txt_size, printData);
      return;
    }
    var print_menu_txt_size = 28.0;
    var wrapNum = 10;
    int oneRowHeight = 48;
    if(print_paper_txt_size.value == "1"){
      print_menu_txt_size = 28.0;
      wrapNum = 12;
      oneRowHeight = 38;
    }else if(print_paper_txt_size.value == "2"){
      print_menu_txt_size = 33.0;
      wrapNum = 10;
      oneRowHeight = 44;
    }else if(print_paper_txt_size.value == "3"){
      print_menu_txt_size = 40.0;
      wrapNum = 8;
      oneRowHeight = 55;
    }

    List<Widget> categoryMenus = [];
    var lineHight = 125;
    var menuNum = 0;
    var optionNum = 0;
    var addRowHight = 0;

    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("$takeoutTag${printData["numberTip"]}",
                style: TextStyle(
                  fontSize: print_menu_txt_size,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w200,
                  color: ColorsUtil.hexToColor("#000000"),
                ))),
      ),
    );
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text("${printData["serialNumber"]}",
                style: TextStyle(
                  fontSize: print_menu_txt_size,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w200,
                  color: ColorsUtil.hexToColor("#000000"),
                ))),
      ),
    );

    // int categoryNum = categoryVos.length;
    // int categoryshowNum = 0;

    for (var m = 0; m < categoryVos.length; m++) {
      var lineItem = categoryVos[m];
      var optionVoList = lineItem["optionVoListMsgMap"];
      // 计算菜品标题长度
      var menuLength = lineItem["mainTitle"].length;
      var menuLine = menuLength / wrapNum;
      int menuRowNum = menuLine.ceil();
      optionNum = 0;

      categoryMenus.add(
        _publicGoodsTwoColumnsTxt("${lineItem["mainTitle"]}", print_menu_txt_size,
            FontWeight.w100, "${lineItem["qty"]}", print_menu_txt_size, FontWeight.w100),
      );
      if (optionVoList != null && optionVoList.isNotEmpty) {
        optionVoList.forEach((key, value) {
          // 计算菜品标题长度
          var groupNameLength = key.length;
          var optionNameLength = value[0].length;
          var optionLine = (groupNameLength + optionNameLength) / wrapNum;
          var countLine = 0;//optionLine.ceil();

          //处理option 开始-----------
          if((key.length+value[0].length) >(wrapNum-2)){
            var newLineNum = 0.0;
            //if(groupNameLength >wrapNum){
            newLineNum = groupNameLength / (wrapNum-2);
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;
            //if(optionNameLength >wrapNum){
            var newLineNumLength = 0.0;
            newLineNumLength = optionNameLength / (wrapNum-2);
            //}
            countLine += newLineNumLength.ceil();
            optionLine += newLineNum;

            categoryMenus.add(Column(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(
                              child:Text("${key}",
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: print_menu_txt_size,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: 'NotoSansJP',
                                    color: ColorsUtil.hexToColor("#000000"),
                                  ))
                          )
                      ),

                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(50)),
                  child: Row(
                    mainAxisAlignment: (value[0].length >(wrapNum-2) ) ? MainAxisAlignment.start : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(
                            child: Text("${value[0]}",
                                softWrap: true,
                                textAlign: (value[0].length >(wrapNum-2)) ? TextAlign.left : TextAlign.right,
                                style: TextStyle(
                                  fontSize: print_menu_txt_size,
                                  fontWeight: FontWeight.w100,
                                  fontFamily: 'NotoSansJP',
                                  color: ColorsUtil.hexToColor("#000000"),
                                )),
                          )),
                    ],
                  ),
                ),
              ],
            ));
          }else{
            countLine += 1;

            categoryMenus.add(Container(
              height: oneRowHeight.toDouble(),
              padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.ltr,
                children: [
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text("${key}",
                          softWrap: true,
                          style: TextStyle(
                            fontSize: print_menu_txt_size,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000"),
                          ))
                  ),
                  Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text("${value[0]}",
                          softWrap: true,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: print_menu_txt_size,
                            fontWeight: FontWeight.w100,
                            fontFamily: 'NotoSansJP',
                            color: ColorsUtil.hexToColor("#000000"),
                          ))),
                ],
              ),
            ));
          }

          var newOptionSonLine = 0.0;
          if(value.length>1){
            List<Widget> optionSons = [];
            for (var j = 1; j < value.length; j++) {
              //print(value[j]);
              newOptionSonLine += value[j].length / (wrapNum-2);
              var oneOptionlength = 0.0;
              oneOptionlength = value[j].length / (wrapNum-2);
              countLine += oneOptionlength.ceil();

              optionSons.add(
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(50)),
                    child: Row(
                      mainAxisAlignment: (value[j].length >(wrapNum-2)) ? MainAxisAlignment.start : MainAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Expanded(child: Text("${value[j]}",
                            textDirection: TextDirection.ltr,
                            textAlign: (value[j].length >(wrapNum-2)) ? TextAlign.left : TextAlign.right,
                            style: TextStyle(
                              fontSize: print_menu_txt_size,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'NotoSansJP',
                              color: ColorsUtil.hexToColor("#000000"),
                              //fontWeight: FontWeight.w600
                            ))),
                      ],
                    ),
                  )
              );
            }

            categoryMenus.add(Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              textDirection: TextDirection.rtl,
              children: optionSons,
            ));
          }


          //处理option结束-----------
          var optionRowNum = 0.0;
          optionRowNum = optionLine + newOptionSonLine;
          //addRowHight += 52 * optionRowNum;
          addRowHight += oneRowHeight*countLine+(countLine-1)*10;
          menuNum += optionRowNum.ceil();
          optionNum++;
        });

        addRowHight += oneRowHeight * menuRowNum+(menuRowNum-1)*10;
        menuNum += menuRowNum;
      } else {
        addRowHight += oneRowHeight * menuRowNum+(menuRowNum-1)*10;
        menuNum += menuRowNum;
      }

      //分割线
      if (machineMode.value == "1" || machineMode.value == "3") {
        addRowHight += 20;
        categoryMenus.add(
          _publicSplitLine(),
        );
      }
    }

    categoryMenus.add(
      Container(
        alignment: Alignment.bottomRight,
        margin: EdgeInsets.only(top: 10),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(printData["orderDate"],
                style: TextStyle(
                  fontSize: print_menu_txt_size * 0.8,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w200,
                  color: ColorsUtil.hexToColor("#000000"),
                ))),
      ),
    );

    //print("总行数${menuNum}");
    var totalHight = addRowHight + lineHight + 25;
    if (menuNum == 1) {
      totalHight += 15;
    }
    ByteData byteData = await WidgetToImage.widgetToImage(Container(
      width: 385,
      height: totalHight.toDouble(),
      padding: EdgeInsets.only(left: 0.5, right: 0.5),
      color: Colors.white,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        textDirection: TextDirection.rtl,
        children: categoryMenus,
      ),
    ),
        size: Size(385, totalHight.toDouble())
    );

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    //Future.delayed(Duration(milliseconds: 50), () async {
    String base64Image = base64Encode(imageBytes);
    //LogUtil.d(base64Image);
    if (printType == "1") {
      // print("打印小菜来了-开始打印小菜lalala：${DateTime.now()}");
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "0"," ");
      Future.delayed(Duration(milliseconds: 800), () async {
        await FlutterPluginMsprinter.sendPrintCut("1");
        tpPrintReceipt(print_paper_txt_size, printData);
      });
    } else {
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "0", "0"," ");
      Future.delayed(Duration(milliseconds: 800), () async {
        await FlutterPluginMsprinter.sendPrintCut("0");
      });
    }

    //});
  }

  tpPrintReceipt(print_paper_txt_size, printData) async {
    List<Widget> categoryMenus = [];


    if(printLogoImageData != null) {
      //Uint8List imageBytes = base64Decode(printLogoImageData!);
      debugPrint('imagePath:$printLogoImageData');
      categoryMenus.add(
          Container(
            height: 150, // 设置容器宽度，根据需要调整
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(printLogoImageData!)),
                //fit: BoxFit.contain, // 可以根据需要调整fit属性
              ),
            ),
          )
      );
    }



    var menuVos = printData["details"];
    var lineHight = 580;
    var lineZeng = 0;
    int addRowHight = 0;
    // 计算菜品标题长度
    var newAddress = printData["address"].replaceAll("%%", "\n");
    var addressLength = printData["address"].length;//print(printData["address"]);//print(newAddress);
    var addressLine = addressLength / 15;
    var addressRowNum = 0;
    addressRowNum = addressLine.ceil();
    addRowHight += addressRowNum*33+(addressRowNum-1)*10;
    categoryMenus.add(_publicOneColumnTxtNew("${newAddress}", 26.0, FontWeight.w300));

    categoryMenus.add(SizedBox(height: 5,));

    //电话
    if (printData["telNo"] != null && printData["telNo"] != "") {
      addRowHight += 38;
      categoryMenus.add(_publicOneColumnTxtNew("電話番号:${printData["telNo"]}", 26.0, FontWeight.w100));
      categoryMenus.add(SizedBox(height: 5,));
    }

    //登录番号
    if(printData["ntaNo"] != null && printData["ntaNo"] != ""){
      addRowHight += 38;
      categoryMenus.add(_publicOneColumnTxtNew(
          "登録番号:${printData["ntaNo"]}", 26.0, FontWeight.w300));
      categoryMenus.add(SizedBox(height: 5,));
    }
    categoryMenus.add(Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 3),
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text("${printData["orderDate"]}",
            style: printMenuFont,
          )),
    ));
    if (machineMode.value == "1" || machineMode.value == "3") {
      addRowHight += 38;
      categoryMenus.add(_publicOneColumnTxtNew("${printData["numberTip"]}${printData["serialNumber"]}", 26.0, FontWeight.w100));
    }
    //注文番号
    categoryMenus.add(_publicOneColumnTxtNew(
        "注文番号:${printData["order"]}", 26.0, FontWeight.w300));
    //领収书标题
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              padding: EdgeInsets.only(top: ScreenAdapter.height(5.0),bottom: ScreenAdapter.height(5.0),left:ScreenAdapter.width(20.0),right:ScreenAdapter.width(20.0)),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  left: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  bottom: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  right: BorderSide(color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                ),
              ),
              child: Text("領 収 書",
                style: printTitleFont,

              ),
            )),
      ),
    );


    int categoryNum = menuVos.length;
    int linNum = 0;
    for (var i = 0; i < menuVos.length; i++) {

      var lineVosList = menuVos[i];

      // 计算菜品标题长度
      var groupNameLength = lineVosList["menuName"].length;
      var menuLine = groupNameLength / 10;
      var menuRowNum = menuLine.ceil();
      //linNum+=menuRowNum;
      var takeoutTag = (printData["takeOut"] == true) ? "*":"";
      if(groupNameLength>10){
        linNum+=2;
        addRowHight += 76;
        categoryMenus.add(
          Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: 76,
                //margin: EdgeInsets.only(bottom: 3),
                child: Column(
                  textDirection: TextDirection.rtl,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Expanded(
                              child: Text("${lineVosList["menuName"]}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: printMenuFont,

                              ),
                            )
                        ),
                        (printData["takeOut"] == true) ? Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text("${takeoutTag}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: printMenuFont,

                            )
                        ):Container(width: 0,),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      textDirection: TextDirection.ltr,
                      children: [
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              //width: ScreenAdapter.width(30),
                              alignment: Alignment.centerRight,
                              child: Text("${lineVosList["menuQty"]}",
                                style: printMenuFont,

                              ),
                            )
                        ),
                        SizedBox(width: 10,),
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              //width: ScreenAdapter.width(105),
                              alignment: Alignment.centerRight,
                              child: Text("￥${formatMoney(lineVosList["price"])}",
                                style: printMenuFont,//GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),

                              ),
                            )
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        );
      }else{
        addRowHight += 33;
        linNum+=1;
        categoryMenus.add(
          Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                height: 33,
                //margin: EdgeInsets.only(bottom: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  textDirection: TextDirection.ltr,
                  children: [
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Expanded(
                          child: Text("${lineVosList["menuName"]}${takeoutTag}",
                            style: printMenuFont,

                          ),
                        )
                    ),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          width: ScreenAdapter.width(30),
                          alignment: Alignment.centerRight,
                          child: Text("${lineVosList["menuQty"]}",
                            style: printMenuFont,

                          ),
                        )
                    ),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          width: ScreenAdapter.width(105),
                          alignment: Alignment.centerRight,
                          child: Text("￥${formatMoney(lineVosList["price"])}",
                            style: printMenuFont,

                          ),
                        )
                    ),
                  ],
                ),
              )),
        );
      }


    }
    //print("总行数${menuNum}");
    //addRowHight += 33 * linNum;
    categoryMenus.add(SizedBox(height: 10,));
//合计
    categoryMenus.add(
      Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            margin: EdgeInsets.only(bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Expanded(
                      child: Text("合計",
                        style: printMenu2Font,

                      ),
                    )
                ),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Container(
                      width: ScreenAdapter.width(130),
                      alignment: Alignment.centerRight,
                      child: Text("￥${formatMoney(printData["price"])}",
                        style: printMenuFont,

                      ),
                    )
                ),
              ],
            ),
          )),
    );

    categoryMenus.add(
      _publicSplitLine(),
    );


    if (hidePrintTax()) {
      addRowHight -= 152;
    } else {
      //8%
      categoryMenus.add(
        _publicTwoColumnsTxtNew(
            "8%対象",
            24.0,
            FontWeight.w100,
            (printData["takeOut"] == true) ? "${formatMoney(printData["price"])}" : "0",
            24.0,
            FontWeight.w100,
            true),
      );
      //内消费税
      categoryMenus.add(
        _publicTwoColumnsTxtNew(
            "　  (内    消費税",
            24.0,
            FontWeight.w100,
            (printData["takeOut"] == true) ? "${formatMoney(printData["tax"])})" : "0)",
            24.0,
            FontWeight.w100,
            true),
      );

      //10%
      categoryMenus.add(
        _publicTwoColumnsTxtNew(
            "10%対象",
            24.0,
            FontWeight.w100,
            (printData["takeOut"] == false) ? "${formatMoney(printData["price"])}" : "0",
            24.0,
            FontWeight.w100,
            true),
      );
      //内消费税
      categoryMenus.add(
        _publicTwoColumnsTxtNew(
            "　  (内    消費税",
            24.0,
            FontWeight.w100,
            (printData["takeOut"] == false) ? "${formatMoney(printData["tax"])})" : "0)",
            24.0,
            FontWeight.w100,
            true),
      );


      categoryMenus.add(
        _publicSplitLine(),
      );
    }

    if(printData["payMethod"] != "現金支払"){
      lineZeng += 33;
      categoryMenus.add(
        _publicTwoColumnsTxtNew(printData["payMethod"], 26.0, FontWeight.w200,
            "${formatMoney(printData["payPrice"])}", 26.0, FontWeight.w200, true),
      );
    }

    if (printData["memberNo"] != null && printData["memberNo"] != "") {
      lineZeng += 76;
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("カード番号", 26.0, FontWeight.w200,
            printData["memberNo"], 26.0, FontWeight.w100, false),
      );
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("日期", 26.0, FontWeight.w200, printData["payDate"],
            26.0, FontWeight.w100, false),
      );
      categoryMenus.add(_publicSplitLine());
    }
    if (printData["serialNo"] != null && printData["serialNo"] != "") {
      lineZeng += 76;
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("カード取引通番", 26.0, FontWeight.w200,
            printData["serialNo"], 26.0, FontWeight.w100, false),
      );
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("取引日時", 26.0, FontWeight.w200, printData["payDate"],
            26.0, FontWeight.w100, false),
      );
      categoryMenus.add(_publicSplitLine());
    }

    //轻减税率对象
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          textDirection: TextDirection.ltr,
          children: [
            Directionality(
                textDirection: TextDirection.ltr,
                child: Expanded(
                  child: Container(
                    width: ScreenAdapter.width(180),
                    child: Text("*軽減税率対象",
                      style: printMenuFont,

                    ),
                  ),
                )
            ),
            Expanded(child: Column(
              children: [
                if(printData["payMethod"] == "現金支払")
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("お預り",
                            style: printMenuFont,

                          ),
                          Text("￥${formatMoney(printData["payPrice"])}",
                            style: printMenuFont,

                          ),
                        ],
                      )),
                if(printData["payMethod"] == "現金支払" && printData["change"] !=null)
                  Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("お釣",
                            style: printMenuFont,

                          ),
                          Text("￥${formatMoney(printData["change"])}",
                            style: printMenuFont,

                          ),
                        ],
                      )),
              ],
            )),
          ],
        ),
      ),
    );

    //お明細は上記のとおりです。
    categoryMenus.add(_publicOneColumnTxtNew("お明細は上記のとおりです。", 26.0, FontWeight.w100));

    var totalHight = lineZeng + lineHight+addRowHight + 150;

    final printWidget = Container(
      width: 385,
      padding: EdgeInsets.only(left: ScreenAdapter.width(2),right: ScreenAdapter.width(2)),
      height: totalHight.toDouble(),
      color: Colors.white,
      //alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: categoryMenus,
      ),
    );

    ByteData byteData = await WidgetToImage.widgetToImage(printWidget,
        size: Size(385, totalHight.toDouble())
    );

    List<int> imageBytes = byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    String base64Image = base64Encode(imageBytes);

    //_showAndPrint(base64Image, printWidget);

    await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "1", printLogoImageData);
    Future.delayed(Duration(milliseconds: 300), () async {
      await FlutterPluginMsprinter.sendPrintCut("1");
    });

  }


  _showAndPrint(String imageData, Widget widget) {
    Get.dialog(
      Container(
        child: Column(
          children: [
            widget,
            SizedBox(height: 20,),
            ElevatedButton(onPressed: () async {
              await FlutterPluginMsprinter.sendPrintImgNew(imageData, "1", "1", printLogoImageData);
              Future.delayed(Duration(milliseconds: 300), () async {
                await FlutterPluginMsprinter.sendPrintCut("1");
              });
              Get.back();
              Get.back();
            }, child: Text('Print')
            ),

          ],
        ),
      )
    );

  }

  //后续会移除该判断 直接返回true即可
  bool hidePrintTax() {
    if(machineCode.value == "Gtf2AnqKxZJUH6jP93") {
      return true;
    }
    return false;
  }


  //单列文字
  _publicOneColumnTxtNew(txtContext, txtFontSize, txtFontWeight) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 3),
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
                  child: Text("${txtContext}",
                    style: printMenuFont,
                  )
              ),
            ],
          )),
    );
  }

  //两列文字
  _publicTwoColumnsTxtNew(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight, isMoney) {

    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Text("${leftTxtContext}",
                      style: printMenuFont,

                    ),
                  )),
              (isMoney == true)
                  ? Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    width: ScreenAdapter.width(120),
                    alignment: Alignment.centerRight,
                    child: RichText(
                      text: TextSpan(
                          text: "￥",
                          style: printMenuFont,
                          children: [
                            TextSpan(
                              text: "${rightTxtContext}",
                              style: printMenuFont,

                            ),
                          ]),
                    ),
                  ))
                  : Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    width: ScreenAdapter.width(120),
                    alignment: Alignment.centerRight,
                    child: Text("${rightTxtContext}",
                      style: printMenuFont,

                    ),
                  )),
            ],
          ),
        ));
  }

  _publicTwoColumnsTxtNewLine(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight, isMoney) {

    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("${leftTxtContext}",
                    style: printMenuFont,

                  )),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Container(
                      width: ScreenAdapter.width(120),
                      alignment: Alignment.centerRight,
                      child: Text("${rightTxtContext}",
                        style: printMenuFont,

                      ),
                    ),
                  )),
            ],
          ),
        ));
  }
  //商品双列
  _publicGoodsTwoColumnsTxt(leftTxtContext, leftTxtFontSize, leftTxtFontWeight,
      rightTxtContext, rightTxtFontSize, rightTxtFontWeight) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Text("${leftTxtContext}",
                        softWrap: true,
                        style: TextStyle(
                          fontSize: leftTxtFontSize,
                          fontWeight: leftTxtFontWeight,
                          fontFamily: 'NotoSansJP',
                          color: ColorsUtil.hexToColor("#000000"),
                        )),
                  )),
              //Expanded(child: Container()),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text("${rightTxtContext}",
                      style: TextStyle(
                        fontSize: rightTxtFontSize,
                        fontWeight: rightTxtFontWeight,
                        fontFamily: 'NotoSansJP',
                        color: ColorsUtil.hexToColor("#000000"),
                        //fontWeight: FontWeight.w600
                      ))),
            ],
          ),
        ));
  }
  //分割线
  _publicSplitLine() {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          height: 0.5,
          color: ColorsUtil.hexToColor("#000000"),
          width: 375,
        ));
  }


}