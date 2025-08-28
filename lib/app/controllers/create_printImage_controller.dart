import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/controllers/app_config.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'dart:typed_data';

import 'package:foodorder/app/services/logUtil.dart';
import 'package:get/get.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../config/colorsUtil.dart';
import '../modules/settlement/views/receipt_constrained_box.dart';
import '../plugins/flutter_plugin_msprint/lib/flutter_plugin_msprinter.dart';
import '../services/HomeServices.dart';
import '../services/ScreenAdapter.dart';
import '../services/formatMoney.dart';

class CreatePrintImageController extends GetxController {
  MachineInfoController machineInfo = Get.find();
  AppConfig appConfig = Get.find();
  double get printWidth => appConfig.isAndroid11 ? 513:385;

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
  }

  tpPrintnew(print_paper_txt_size, printData, printType) async {
    var takeOut = printData["takeOut"] ?? false;
    var takeoutTag = (takeOut == true) ? "【T】" : "";
    List categoryVos = [];

    // 现在printInfoListStruct没有提供值了，换成了 printInfo 内的 orderLinesMap
    // 提取 orderLinesMap 中的菜品信息转换成原来的 categoryVos 格式
    if (printData["printInfo"] != null) {
      var orderLinesMap = printData["printInfo"]["orderLinesMap"];
      if (orderLinesMap != null && orderLinesMap.isNotEmpty) {
        categoryVos = [];
        for (var key in orderLinesMap.keys) {
          final items = orderLinesMap[key];
          if (items != null && items.isNotEmpty) {
            for (var item in items) {
              categoryVos.add({
                "mainTitle": item["name"],
                "qty": item["qty"],
                "optionVoListMsgMap": item["options"] ?? {},
              });
            }
          }
        }
      }
    }

    if (categoryVos.length == 0) {
      tpPrintReceipt(print_paper_txt_size, printData);
      return;
    }
    var print_menu_txt_size = 28.0;
    var wrapNum = 10;
    int oneRowHeight = 48;
    if (print_paper_txt_size == "1") {
      print_menu_txt_size = 28.0;
      wrapNum = 12;
      oneRowHeight = 48;
    } else if (print_paper_txt_size == "2") {
      print_menu_txt_size = 33.0;
      wrapNum = 10;
      oneRowHeight = 54;
    } else if (print_paper_txt_size == "3") {
      print_menu_txt_size = 40.0;
      wrapNum = 8;
      oneRowHeight = 65;
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
                  fontSize: 34,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w600,
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
                  fontSize: 34,
                  fontFamily: 'NotoSansJP',
                  fontWeight: FontWeight.w600,
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
          SizedBox(height: 20)
      );

      categoryMenus.add(
        _publicGoodsTwoColumnsTxt(
            "${lineItem["mainTitle"]}",
            print_menu_txt_size,
            FontWeight.w100,
            "${lineItem["qty"]}",
            print_menu_txt_size,
            FontWeight.w100),
      );
      if (optionVoList != null && optionVoList.isNotEmpty) {
        optionVoList.forEach((key, value) {
          // 计算菜品标题长度
          var groupNameLength = key.length;
          var optionNameLength = value[0].length;
          var optionLine = (groupNameLength + optionNameLength) / wrapNum;
          var countLine = 0; //optionLine.ceil();
          //value[0] 为Map{name: "optionName", qty: 1} 的形式
          final qtyString = (value[0]["qty"] ?? 1) > 1 ? " ×${value[0]["qty"]}" : "";
          final optionString = (value[0]["name"] ?? "") + qtyString;

          //处理option 开始-----------
          if ((key.length + value[0].length) > (wrapNum - 2)) {
            var newLineNum = 0.0;
            //if(groupNameLength >wrapNum){
            newLineNum = groupNameLength / (wrapNum - 2);
            //}
            countLine += newLineNum.ceil();
            optionLine += newLineNum;
            //if(optionNameLength >wrapNum){
            var newLineNumLength = 0.0;
            newLineNumLength = optionNameLength / (wrapNum - 2);
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
                              child: Text("${key}",
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: print_menu_txt_size,
                                    fontWeight: FontWeight.w100,
                                    fontFamily: 'NotoSansJP',
                                    color: ColorsUtil.hexToColor("#000000"),
                                  )))),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(50)),
                  child: Row(
                    mainAxisAlignment: (optionString.length > (wrapNum - 2))
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.ltr,
                    children: [
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Expanded(
                            child: Text(optionString,
                                softWrap: true,
                                textAlign: (optionString.length > (wrapNum - 2))
                                    ? TextAlign.left
                                    : TextAlign.right,
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
          } else {
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
                          ))),
                  Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(optionString,
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
          if (value.length > 1) {
            List<Widget> optionSons = [];
            for (var j = 1; j < value.length; j++) {
              //print(value[j]);
              final qtyString = (value[j]["qty"] ?? 1) > 1 ? " ×${value[j]["qty"]}" : "";
              final optionString = (value[j]["name"] ?? "") + qtyString;
              newOptionSonLine += optionString.length / (wrapNum - 2);
              var oneOptionlength = 0.0;
              oneOptionlength = optionString.length / (wrapNum - 2);
              countLine += oneOptionlength.ceil();

              optionSons.add(Container(
                padding: EdgeInsets.only(left: ScreenAdapter.width(50)),
                child: Row(
                  mainAxisAlignment: (optionString.length > (wrapNum - 2))
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  textDirection: TextDirection.ltr,
                  children: [
                    Expanded(
                        child: Text(optionString,
                            textDirection: TextDirection.ltr,
                            textAlign: (optionString.length > (wrapNum - 2))
                                ? TextAlign.left
                                : TextAlign.right,
                            style: TextStyle(
                              fontSize: print_menu_txt_size,
                              fontWeight: FontWeight.w100,
                              fontFamily: 'NotoSansJP',
                              color: ColorsUtil.hexToColor("#000000"),
                              //fontWeight: FontWeight.w600
                            )
                        )
                    ),
                  ],
                ),
              ));
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
          addRowHight += oneRowHeight * countLine + (countLine - 1) * 10;
          menuNum += optionRowNum.ceil();
          optionNum++;
        });

        addRowHight += oneRowHeight * menuRowNum + (menuRowNum - 1) * 10;
        menuNum += menuRowNum;
      } else {
        addRowHight += oneRowHeight * menuRowNum + (menuRowNum - 1) * 10;
        menuNum += menuRowNum;
      }

      //分割线
      //if (machineInfo.currentMode != MachineMode.takeout) {
        addRowHight += 8;
        categoryMenus.add(
          _publicSplitLine(),
        );
      //}
    }
    // if(machineInfo.currentMode == MachineMode.takeout)
    //   categoryMenus.add(
    //     _publicSplitLine(),
    //   );

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
    var totalHight = addRowHight + lineHight + 25 + 100;
    if (menuNum == 1) {
      totalHight += 15;
    }
    ByteData byteData = await WidgetToImage.widgetToImage(
        Container(
          width: printWidth,
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
        size: Size(printWidth, totalHight.toDouble()));

    List<int> imageBytes = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    //Future.delayed(Duration(milliseconds: 50), () async {
    String base64Image = base64Encode(imageBytes);
    //LogUtil.d(base64Image);
    if (printType == "1") {
      // print("打印小菜来了-开始打印小菜lalala：${DateTime.now()}");
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "0", "");
      await Future.delayed(Duration(milliseconds: 500));
      await FlutterPluginMsprinter.sendPrintCut("1");
      await Future.delayed(Duration(milliseconds: 300));
      tpPrintReceipt(print_paper_txt_size, printData);
    } else {
      await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "0", "0", "");
      await Future.delayed(Duration(milliseconds: 800));
      await FlutterPluginMsprinter.sendPrintCut("0");
    }

    //});
  }

  tpPrintReceipt(print_paper_txt_size, printData) async {
    List<Widget> categoryMenus = [];

    debugPrint('printData:$printData');
    int discount = printData["discount"] ?? 0;
    int finalPrice = int.parse(printData["price"] ?? '0');
    int originalPrice = finalPrice + discount;

    var menuVos = printData["details"] ?? [];
    // 现在details没有提供值了，换成了 printInfo 内的 orderLinesMap
    // 提取 orderLinesMap 中的菜品信息转换成原来的 menuVos 格式
    if (printData["printInfo"] != null) {
      var orderLinesMap = printData["printInfo"]["orderLinesMap"];
      if (orderLinesMap != null && orderLinesMap.isNotEmpty) {
        menuVos = [];
        for (var key in orderLinesMap.keys) {
          final items = orderLinesMap[key];
          if (items != null && items.isNotEmpty) {
            for (var item in items) {
              menuVos.add({
                "menuName": item["name"],
                "menuQty": item["qty"],
                "price": item["price"] ?? 0,
              });
            }
          }
        }
      }
    }



    var lineHight = 580;
    var lineZeng = 0;
    int addRowHight = 0;
    // 计算菜品标题长度
    var newAddress = printData["address"].replaceAll("%%", "\n");
    var addressLength = printData["address"]
        .length; //print(printData["address"]);//print(newAddress);
    var addressLine = addressLength / 15;
    var addressRowNum = 0;
    addressRowNum = addressLine.ceil();
    addRowHight += addressRowNum * 33 + (addressRowNum - 1) * 10;
    categoryMenus
        .add(_publicOneColumnTxtNew("${newAddress}", 26.0, FontWeight.w300));

    categoryMenus.add(SizedBox(
      height: 5,
    ));

    //电话
    if (printData["telNo"] != null && printData["telNo"] != "") {
      addRowHight += 38;
      categoryMenus.add(_publicOneColumnTxtNew(
          "電話番号:${printData["telNo"]}", 26.0, FontWeight.w100));
      categoryMenus.add(SizedBox(
        height: 5,
      ));
    }

    //登录番号
    if (printData["ntaNo"] != null && printData["ntaNo"] != "") {
      addRowHight += 38;
      categoryMenus.add(_publicOneColumnTxtNew(
          "登録番号:${printData["ntaNo"]}", 26.0, FontWeight.w300));
      categoryMenus.add(SizedBox(
        height: 5,
      ));
    }
    categoryMenus.add(Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.only(bottom: 3),
      child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            "${printData["orderDate"]}",
            style: printMenuFont,
          )),
    ));
    //注文番号
    categoryMenus.add(_publicOneColumnTxtNew(
        "注文番号:${printData["order"]}", 26.0, FontWeight.w300));
    if (machineInfo.machineMode == "1" || machineInfo.machineMode == "3") {
      addRowHight += 48;
      categoryMenus.add(_publicOneColumnText(
          "${printData["numberTip"]}${printData["serialNumber"]}",
          32.0,
          FontWeight.w600));
    }
    //领収书标题
    categoryMenus.add(
      Container(
        margin: EdgeInsets.only(bottom: 3),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              padding: EdgeInsets.only(
                  top: ScreenAdapter.height(5.0),
                  bottom: ScreenAdapter.height(5.0),
                  left: ScreenAdapter.width(20.0),
                  right: ScreenAdapter.width(20.0)),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  left: BorderSide(
                      color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  bottom: BorderSide(
                      color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                  right: BorderSide(
                      color: ColorsUtil.hexToColor("#000000"), width: 0.5),
                ),
              ),
              child: Text(
                "領 収 書",
                style: printTitleFont,
              ),
            )),
      ),
    );

    //int categoryNum = menuVos.length;
    int linNum = 0;
    for (var i = 0; i < menuVos.length; i++) {
      var lineVosList = menuVos[i];

      // 计算菜品标题长度
      var groupNameLength = lineVosList["menuName"].length;
      //var menuLine = groupNameLength / 10;
      //var menuRowNum = menuLine.ceil();
      //linNum+=menuRowNum;
      var takeoutTag = (printData["takeOut"] == true) ? "*" : "";
      if (groupNameLength > 10) {
        linNum += 2;
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
                              child: Text(
                                "${lineVosList["menuName"]}",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: printMenuFont,
                              ),
                            )),
                        (printData["takeOut"] == true)
                            ? Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              "${takeoutTag}",
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: printMenuFont,
                            ))
                            : Container(
                          width: 0,
                        ),
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
                              child: Text(
                                "${lineVosList["menuQty"]}",
                                style: printMenuFont,
                              ),
                            )),
                        SizedBox(
                          width: 10,
                        ),
                        Directionality(
                            textDirection: TextDirection.ltr,
                            child: Container(
                              //width: ScreenAdapter.width(105),
                              alignment: Alignment.centerRight,
                              child: Text(
                                "￥${formatMoney(lineVosList["price"])}",
                                style:
                                printMenuFont, //GoogleFonts.zenKakuGothicAntique(fontSize: 26,fontWeight: FontWeight.w300,color: Colors.black87),
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              )),
        );
      } else {
        addRowHight += 33;
        linNum += 1;
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
                          child: Text(
                            "${lineVosList["menuName"]}${takeoutTag}",
                            style: printMenuFont,
                          ),
                        )),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          width: ScreenAdapter.width(30),
                          alignment: Alignment.centerRight,
                          child: Text(
                            "${lineVosList["menuQty"]}",
                            style: printMenuFont,
                          ),
                        )),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Container(
                          width: ScreenAdapter.width(105),
                          alignment: Alignment.centerRight,
                          child: Text(
                            "￥${formatMoney(lineVosList["price"])}",
                            style: printMenuFont,
                          ),
                        )),
                  ],
                ),
              )),
        );
      }
    }
    //print("总行数${menuNum}");
    //addRowHight += 33 * linNum;
    categoryMenus.add(SizedBox(
      height: 10,
    ));
    //原价

    SizedBox(
      height: 10,
    );
    categoryMenus.add(
      _publicSplitLine(),
    );

    if (discount != 0)
      categoryMenus.add(
        _publicTwoColumnsTxtNew(
            "定価",
            26.0,
            FontWeight.w200,
            "${formatMoney(originalPrice)}",
            26.0,
            FontWeight.w200,
            true),
      );


    if (discount != 0)
      categoryMenus.add(
        _publicTwoColumnsTxtNew(
            "割引",
            26.0,
            FontWeight.w200,
            "${formatMoney(discount)}",
            26.0,
            FontWeight.w200,
            true),
      );


    categoryMenus.add(
      Directionality(
          textDirection: TextDirection.ltr,
          child: Container(
            //margin: EdgeInsets.only(bottom: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Expanded(
                      child: Text(
                        "合計",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    )),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Container(
                      width: ScreenAdapter.width(130),
                      alignment: Alignment.centerRight,
                      child: Text(
                        "￥${formatMoney(finalPrice)}",
                        style: TextStyle(
                          fontFamily: 'NotoSansJP',
                          color: Colors.black,
                          fontSize: 26,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    )),
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
            "${formatMoney(printData["baseTax2"] ?? 0)}",
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
            //(printData["takeOut"] == true) ?
            "${formatMoney(printData["tax2"])})",
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
            "${formatMoney(printData["baseTax1"] ?? 0)}",
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
            "${formatMoney(printData["tax1"] ?? 0)})",
            24.0,
            FontWeight.w100,
            true),
      );

      categoryMenus.add(
        _publicSplitLine(),
      );
    }

    if (printData["payMethod"] != "現金支払") {
      lineZeng += 33;
      categoryMenus.add(
        _publicTwoColumnsTxtNew(
            printData["payMethod"],
            26.0,
            FontWeight.w200,
            "${formatMoney(printData["payPrice"])}",
            26.0,
            FontWeight.w200,
            true),
      );
    }

    if (printData["memberNo"] != null && printData["memberNo"] != "") {
      lineZeng += 76;
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("カード番号", 26.0, FontWeight.w200,
            printData["memberNo"], 26.0, FontWeight.w100, false),
      );
      categoryMenus.add(
        _publicTwoColumnsTxtNewLine("日期", 26.0, FontWeight.w200,
            printData["payDate"], 26.0, FontWeight.w100, false),
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
        _publicTwoColumnsTxtNewLine("取引日時", 26.0, FontWeight.w200,
            printData["payDate"], 26.0, FontWeight.w100, false),
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
                    child: Text(
                      "*軽減税率対象",
                      style: printMenuFont,
                    ),
                  ),
                )),
            Expanded(
                child: Column(
                  children: [
                    if (printData["payMethod"] == "現金支払")
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "お預り",
                                style: printMenuFont,
                              ),
                              Text(
                                "￥${formatMoney(printData["payPrice"])}",
                                style: printMenuFont,
                              ),
                            ],
                          )),
                    if (printData["payMethod"] == "現金支払" &&
                        printData["change"] != null)
                      Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "お釣",
                                style: printMenuFont,
                              ),
                              Text(
                                "￥${formatMoney(printData["change"])}",
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
    categoryMenus
        .add(_publicOneColumnTxtNew("お明細は上記のとおりです。", 26.0, FontWeight.w100));

    var totalHight = lineZeng + lineHight + addRowHight + 180;
    final printLogo = CachedNetworkImageProvider(machineInfo.printLogoImageUrl);

    await ensureImageLoaded(machineInfo.printLogoImageUrl);

    final printWidget = Container(
      width: printWidth,
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(2), right: ScreenAdapter.width(2)),
      height: totalHight.toDouble(),
      color: Colors.white,
      //alignment: Alignment.topCenter,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        children: [
          Image(
              width: double.infinity,
              image: printLogo,
              fit: BoxFit.fitWidth
          ),
          ...categoryMenus
        ],
      ),
    );

    ByteData byteData = await WidgetToImage.widgetToImage(printWidget,
        size: Size(printWidth, totalHight.toDouble()));

    List<int> imageBytes = byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes);

    String base64Image = base64Encode(imageBytes);

    //_showAndPrint(base64Image, printWidget);

    //await Future.delayed(Duration(milliseconds: 800));
    await FlutterPluginMsprinter.sendPrintImgNew(base64Image, "1", "1", "");
    //await Future.delayed(Duration(milliseconds: 300));
    await FlutterPluginMsprinter.sendPrintCut("1");
  }

  Future<void> ensureImageLoaded(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    final provider = CachedNetworkImageProvider(imageUrl);
    final config = ImageConfiguration.empty;
    final Completer<void> completer = Completer<void>();

    provider.resolve(config).addListener(
      ImageStreamListener(
            (ImageInfo image, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
        onError: (Object error, StackTrace? stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      ),
    );

    await completer.future;
  }

  _showAndPrint(String imageData, Widget widget) {
    Get.dialog(Container(
      child: Column(
        children: [
          widget,
          SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () async {
                await FlutterPluginMsprinter.sendPrintImgNew(
                    imageData, "1", "1", "");
                Future.delayed(Duration(milliseconds: 300), () async {
                  await FlutterPluginMsprinter.sendPrintCut("1");
                });
                Get.back();
                Get.back();
              },
              child: Text('Print')),
        ],
      ),
    ));
  }

  //后续会移除该判断 直接返回true即可
  bool hidePrintTax() {
    if (machineInfo.machineCode == "Gtf2AnqKxZJUH6jP93") {
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
                  child: Text(
                    "${txtContext}",
                    style: printMenuFont,
                  )),
            ],
          )),
    );
  }

  _publicOneColumnText(txtContext, txtFontSize, txtFontWeight) {
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
                  child: Text(
                    "${txtContext}",
                    style: TextStyle(
                      fontFamily: 'NotoSansJP',
                      color: Colors.black,
                      fontSize: txtFontSize,
                      fontWeight: txtFontWeight,
                    ),
                  )),
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
          //margin: EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Text(
                      "${leftTxtContext}",
                      style: printMenuFont,
                    ),
                  )),
              (isMoney == true)
                  ? Directionality(
                  textDirection: TextDirection.ltr,
                  child: Container(
                    //width: ScreenAdapter.width(120),
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
                    child: Text(
                      "${rightTxtContext}",
                      style: printMenuFont,
                    ),
                  )),
            ],
          ),
        ));
  }

  _publicTwoColumnsTxtNewLine(
      leftTxtContext,
      leftTxtFontSize,
      leftTxtFontWeight,
      rightTxtContext,
      rightTxtFontSize,
      rightTxtFontWeight,
      isMoney) {
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
                  child: Text(
                    "${leftTxtContext}",
                    style: printMenuFont,
                  )),
              Directionality(
                  textDirection: TextDirection.ltr,
                  child: Expanded(
                    child: Container(
                      width: ScreenAdapter.width(120),
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${rightTxtContext}",
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
        ));
  }
}
