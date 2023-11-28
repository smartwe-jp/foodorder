import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/colorsUtil.dart';
import '../controllers/reimburse_order_controller.dart';

class ReimbursePrintView extends StatelessWidget {

  final Map<String, dynamic> reimburseInfo;
  final GlobalKey containerKey = GlobalKey();
  ReimbursePrintView({Key? key, required this.reimburseInfo})
      : super(key: key);
  final contentStyle = GoogleFonts.zenKakuGothicAntique(
      fontSize: 26, fontWeight: FontWeight.w300, color: Colors.black87);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    List<Widget> categoryMenus = [];

    //reimburse title
    categoryMenus.add(
      Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child:
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text("[売上取消票]",
                    style: contentStyle),
              ),
            ),
          ],
        ),
      ),
    );
    categoryMenus.add(_publicSplitLine());//

    //branch info
    categoryMenus.add(shitenInfoArea());
    categoryMenus.add(_publicSplitLine());//分割线

    //order info
    categoryMenus.add(reimburseInfoArea());
    categoryMenus.add(_publicSplitLine());//分割线

    //reimburse info
    categoryMenus.add(amountInfoArea());

    return
      Directionality(
        textDirection: TextDirection.ltr,
        child:Wrap(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 40),
              width: 385,
              color: Colors.white,
              child: Column(
                children: categoryMenus,
              ),
            ),
          ],
        ),
      );

  }

  //分割线
  _publicSplitLine() {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          margin: EdgeInsets.only(top: 5, bottom: 5),
          height: 0.5,
          color: ColorsUtil.hexToColor("#000000"),
          width: 385,
        ));
  }

  Widget shitenInfoArea() {
    return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child:
        Directionality(
        textDirection: TextDirection.ltr,
        child:
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //店舗名
            hasShopName() ? Container(
              margin: EdgeInsets.only(bottom: 10),
              child: Text(
                "${reimburseInfo["shopName"]}",
                style: GoogleFonts.zenKakuGothicAntique(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ) : Container(),

            hasAddress() ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "住所",
                  style: contentStyle,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    "${reimburseInfo["address"]}",
                    style: contentStyle,
                  ),
                ),
              ],
            ) : Container(),

            hasPhone() ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "電話",
                  style: contentStyle,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "${reimburseInfo["telNo"]}",
                  style: contentStyle,
                ),
              ],
            ) : Container(),
          ],
        )));
  }

  Widget reimburseInfoArea() {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child:
      Directionality(
      textDirection: TextDirection.ltr,
      child:
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "取引時間",
                style: contentStyle,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                _getCurrentTime()
                ,
                style: contentStyle,
              ),
            ],
          ),
          _hasOrderId() ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "注文番号",
                      style: contentStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${reimburseInfo["orderIdStr"]}",
                      style: contentStyle,
                    ),
                  ],
                )
              : Container(),
          _hasSerialNumber() ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "お客様番号",
                      style: contentStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${reimburseInfo["serialNumber"]}",
                      style: contentStyle,
                    ),
                  ],
                )
              : Container(),
          hasPayTime() ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "決済時間",
                      style: contentStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${reimburseInfo["payTime"]}",
                      style: contentStyle,
                    ),
                  ],
                ) : Container(),

          hasPayChannel() ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "決済方法",
                      style: contentStyle,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${reimburseInfo["payChannel"]}",
                      style: contentStyle,
                    ),
                  ],
                ) : Container(),
        ],
      )),
    );
  }
  //

  String _getCurrentTime() {
    DateTime now = DateTime.now();
    String formattedDate = "${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute}";
    return formattedDate;
  }

  Widget amountInfoArea() {
    return Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Directionality(
        textDirection: TextDirection.ltr,
        child:
        Column(
          children: [
            hasPayAmount() ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "決済金額",
                  style: contentStyle,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "¥ ${reimburseInfo["payAmount"]}",
                  style: contentStyle,
                ),
              ],
            ) : Container(),
            hasAmount() ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "返金金額",
                  style: contentStyle,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "¥ ${reimburseInfo["amount"]}",
                  style: contentStyle,
                ),
              ],
            ) : Container(),
          ],
        )));
  }

  bool _hasOrderId() {
    return reimburseInfo["orderId"] != null &&
        reimburseInfo["orderId"].toString().length > 0;
  }

  bool _hasSerialNumber() {
    return reimburseInfo["serialNumber"] != null &&
        reimburseInfo["serialNumber"].toString().length > 0;
  }

  bool hasPayTime() {
    return reimburseInfo["payTime"] != null &&
        reimburseInfo["payTime"].toString().length > 0;
  }

  bool hasPayAmount() {
    return reimburseInfo["payAmount"] != null &&
        reimburseInfo["payAmount"].toString().length > 0;
  }

  bool hasAmount() {
    return reimburseInfo["amount"] != null &&
        reimburseInfo["amount"].toString().length > 0;
  }

  bool hasPayChannel() {
    return reimburseInfo["payChannel"] != null &&
        reimburseInfo["payChannel"].toString().length > 0;
  }

  bool hasPhone() {
    return reimburseInfo["telNo"] != null &&
        reimburseInfo["telNo"].toString().length > 0;
  }

  bool hasAddress() {
    return reimburseInfo["address"] != null &&
        reimburseInfo["address"].toString().length > 0;
  }

  bool hasShopName() {
    return reimburseInfo["shopName"] != null &&
        reimburseInfo["shopName"].toString().length > 0;
  }

}


// {"msg":"success","code":200,"data":[{"machineCode":"","orderId":445538579629932544,
// "executeMark":true,"orderIdStr":"＊＊＊９３２５４４","serialNumber":"０００９","payTime":"１４：４３",
// "payAmount":10,"amount":10,"change":0,"coupon":0,"couponType":0,"payChannel":"CreditCard","requestMessage":"","responseMessage":""}]}

// {"msg":"success","code":200,"data":{"machineCode":"X3V9YPJABVZGAELIZ9",
// "orderId":445538579629932544,"executeMark":true,"orderIdStr":null,"serialNumber":null,
// "payTime":null,"payAmount":null,"amount":null,"change":null,"coupon":null,"couponType":null,
// "payChannel":"CreditCard","requestMessage":"2101516689       0050944553857962993254400000102023111014490904swJJ10","responseMessage":null}}