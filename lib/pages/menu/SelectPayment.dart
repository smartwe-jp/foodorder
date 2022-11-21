import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/services/ScreenAdapter.dart';

import 'package:foodorder/config/color.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/config/string.dart';
import 'package:foodorder/services/showToast.dart';

import 'package:foodorder/config/fontSize.dart';
import 'package:foodorder/services/formatMoney.dart';

class SelectPaymentPage extends StatefulWidget {
  Map arguments;
  SelectPaymentPage(
      {Key key,
      this.checkLanguage,
      this.dining_type,
        this.dining_type_num,
        this.shopInfo,
        //this.mealType,
        this.isAllowPos,
        this.payment_method_num,
        this.shopCartTotalPrice,
        this.onConfrimClick
      }) : super(key: key);
  final String checkLanguage;
  final String dining_type;
  final String dining_type_num;
  final String shopInfo;
  //final bool mealType;
  final String isAllowPos;
  final String payment_method_num;
  final String shopCartTotalPrice;
  final Function(bool, String, String, String) onConfrimClick;

  @override
  _SelectPaymentPageState createState() => _SelectPaymentPageState();
}

class _SelectPaymentPageState extends State<SelectPaymentPage> {
  String _checkLanguage = "JP";
  String _dining_type = "1"; //1 堂食  2 外袋  3两种都可以支付
  String _dining_type_num = "0"; //就餐类型选择
  String _shopInfo = "kanran";
  bool _mealType = false;
  String _isAllowPos = "0"; //1 使用信用卡刷卡  0 不可使用;
  String _payment_method_num = "0"; //支付类型选择 1现金 2扫码 3pos 4nfc
  String _shopCartTotalPrice="0"; //合计总价

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkLanguage = widget.checkLanguage;
    _dining_type = widget.dining_type;
    _dining_type_num = widget.dining_type_num;
    _shopInfo = widget.shopInfo;
    //_mealType = widget.mealType;
    _isAllowPos = widget.isAllowPos;
    _payment_method_num = widget.payment_method_num;
    _shopCartTotalPrice = widget.shopCartTotalPrice;

  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: EdgeInsets.only(top: 0,bottom: 0,left: 0,right: 0),
      backgroundColor: ColorsUtil.hexToColor("#DCDCDC"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        children: <Widget>[
          Container(
            color: ColorsUtil.hexToColor("#FFFFFF"),
            width: ScreenAdapter.width(1000),
            padding: EdgeInsets.only(top: ScreenAdapter.height(20),bottom: ScreenAdapter.height(0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if(_dining_type =="3")
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(30),top: ScreenAdapter.height(25),right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(30)),
                    //width: ScreenAdapter.width(650),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          //"堂食",
                          GString.getToString(this._checkLanguage, "menu_dingtype_title"),
                          style: TextStyle(
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(34.0)),
                        ),
                        SizedBox(height: ScreenAdapter.height(30),),
                        /*Text(
                              //"堂食",
                              GString.getToString(this._checkLanguage, "menu_dingtype_title_tag"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                  fontWeight: FontWeight.w400,
                                  fontSize: ScreenAdapter.fontSize(22.0)),
                            ),
                            SizedBox(height: ScreenAdapter.height(20),),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _mealType = false;
                                  _dining_type_num = "1";
                                });
                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(320),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                  //背景颜色
                                  //color: (_dining_type_num == "1") ? Colors.blue:Colors.white,
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: (_dining_type_num == "1") ? [
                                      ColorsUtil.hexToColor("#C47829"),
                                      ColorsUtil.hexToColor("#854610"),
                                    ] : [
                                      ColorsUtil.hexToColor("#FFFFFF"),
                                      ColorsUtil.hexToColor("#FFFFFF"),
                                    ],
                                  ),
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: (_dining_type_num == "1") ? ColorsUtil.hexToColor("#844811"):ColorsUtil.hexToColor("#DCDCDC"), offset: Offset(1.0, 1.0), blurRadius: 1.0, spreadRadius: 3.0), ],
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: ScreenAdapter.height(210),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                      child: Image.asset((_dining_type_num == "1") ? GImage.getImageString("imgpublic", "dining_in_checked") : GImage.getImageString("imgpublic", "dining_in_nochecked"),
                                        //width: ScreenAdapter.width(120),
                                        height: ScreenAdapter.height(140),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    //SizedBox(height: ScreenAdapter.height(20),),
                                    Text(
                                      //"堂食",
                                      GString.getToString(this._checkLanguage, "menu_dingtype_eatin"),
                                      style: TextStyle(
                                          color: (_dining_type_num == "1") ? ColorsUtil.hexToColor("#FFFFFF") : ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(34.0)),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _mealType = true;
                                  _dining_type_num = "2";
                                });
                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(320),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                  //背景颜色
                                  //color: (_dining_type_num == "1") ? Colors.blue:Colors.white,
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: (_dining_type_num == "2") ? [
                                      ColorsUtil.hexToColor("#C47829"),
                                      ColorsUtil.hexToColor("#854610"),
                                    ] : [
                                      ColorsUtil.hexToColor("#FFFFFF"),
                                      ColorsUtil.hexToColor("#FFFFFF"),
                                    ],
                                  ),
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: (_dining_type_num == "2") ? ColorsUtil.hexToColor("#844811"):ColorsUtil.hexToColor("#DCDCDC"), offset: Offset(1.0, 1.0), blurRadius: 1.0, spreadRadius: 3.0), ],
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: ScreenAdapter.height(210),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                      child: Image.asset((_dining_type_num == "2") ? GImage.getImageString("imgpublic", "dining_away_checked") : GImage.getImageString("imgpublic", "dining_away_nochecked"),
                                        //width: ScreenAdapter.width(120),
                                        height: ScreenAdapter.height(140),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    //SizedBox(height: ScreenAdapter.height(20),),
                                    Text(
                                      //"外卖",
                                      GString.getToString(this._checkLanguage, "menu_dingtype_takeout"),
                                      style: TextStyle(
                                          color: (_dining_type_num == "2") ? ColorsUtil.hexToColor("#FFFFFF") : ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(34.0)),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                if(_isAllowPos =="1")
                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(50),top: ScreenAdapter.height(25),right: ScreenAdapter.width(50),bottom: ScreenAdapter.height(30)),
                    //width: ScreenAdapter.width(650),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          //GString.getToString(this._checkLanguage, "menu_dingtype_title"),
                          "请选择支付方式",
                          style: TextStyle(
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(34.0)),
                        ),
                        SizedBox(height: ScreenAdapter.height(30),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _payment_method_num = "1";
                                });
                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(320),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                  //背景颜色
                                  color: Colors.white,
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: (_payment_method_num == "1") ? ColorsUtil.hexToColor("#844811"):ColorsUtil.hexToColor("#DCDCDC"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 10.0), ],
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: ScreenAdapter.height(210),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "payment_cash"),
                                        //width: ScreenAdapter.width(150),
                                        height: ScreenAdapter.height(180),
                                        //color:  ColorsUtil.hexToColor(Gcolor.mainBackground),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    //SizedBox(height: ScreenAdapter.height(20),),
                                    Text(
                                      //"现金",
                                      //GString.getToString(this._checkLanguage, "menu_dingtype_eatin"),
                                      "现金",
                                      style: TextStyle(
                                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(34.0)),
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _payment_method_num = "2";
                                });
                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(320),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                  //背景颜色
                                  color: Colors.white,
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: (_payment_method_num == "2") ? ColorsUtil.hexToColor("#844811"):ColorsUtil.hexToColor("#DCDCDC"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 10.0), ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: ScreenAdapter.height(210),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "payment_qr"),
                                        width: ScreenAdapter.width(245),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                    //SizedBox(height: ScreenAdapter.height(10),),
                                    Text(
                                      //"扫码",
                                      //GString.getToString(this._checkLanguage, "menu_dingtype_takeout"),
                                      "扫码",
                                      style: TextStyle(
                                          color:ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(34.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenAdapter.height(50),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _isAllowPos = "1";
                                  _payment_method_num = "3";
                                });
                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(320),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                  //背景颜色
                                  color: Colors.white,
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: (_payment_method_num == "3") ? ColorsUtil.hexToColor("#844811"):ColorsUtil.hexToColor("#DCDCDC"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 10.0), ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: ScreenAdapter.height(210),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "payment_card"),
                                        width: ScreenAdapter.width(220),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                    //SizedBox(height: ScreenAdapter.height(20),),
                                    Text(
                                      //"信用卡",
                                      //GString.getToString(this._checkLanguage, "menu_dingtype_takeout"),
                                      "信用卡",
                                      style: TextStyle(
                                          color:ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(34.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(15),
                            ),
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _isAllowPos = "1";
                                  _payment_method_num = "4";
                                });
                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(320),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                  //背景颜色
                                  color: Colors.white,
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: (_payment_method_num == "4") ? ColorsUtil.hexToColor("#844811"):ColorsUtil.hexToColor("#DCDCDC"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 10.0), ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: ScreenAdapter.height(210),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "payment_nfc"),
                                        width: ScreenAdapter.width(200),
                                        //height: ScreenAdapter.height(200),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                    //SizedBox(height: ScreenAdapter.height(20),),
                                    Text(
                                      //"信用卡",
                                      //GString.getToString(this._checkLanguage, "menu_dingtype_takeout"),
                                      "nfc卡",
                                      style: TextStyle(
                                          color:ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(34.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: ScreenAdapter.height(20),),
                Container(
                  padding: EdgeInsets.only(left: ScreenAdapter.width(50),right: ScreenAdapter.width(50)),
                  height: ScreenAdapter.height(100),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        //GString.getToString(this._checkLanguage, "menu_dingtype_title"),
                        "合计",
                        style: TextStyle(
                            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            fontWeight: FontWeight.w600,
                            fontSize: ScreenAdapter.fontSize(40.0)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white12,
                            border: Border(
                              bottom: BorderSide(color: Colors.black, width: 1.5),
                              //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                            )),
                        child: RichText(
                          text: TextSpan(
                              text: "¥",
                              //GString.getToString(this._checkLanguage, "show_price_front"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(GFontSize
                                    .menusettlementBottomPriceLeft),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              ),
                              children: [
                                TextSpan(
                                  text: formatMoney(_shopCartTotalPrice.toString()),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(GFontSize.menusettlementBottomPrice),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                  "（${GString.getToString(this._checkLanguage, "show_price_front")}）", //" 円",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(GFontSize.menusettlementBottomPriceRight),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(20),),
                Container(
                  //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                  height: ScreenAdapter.height(200),
                  color: ColorsUtil.hexToColor("#DCDCDC"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          try {
                            Navigator.pop(context);
                          } catch (_) {}
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: ScreenAdapter.width(270),
                          height: ScreenAdapter.height(140),
                          //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                          decoration: BoxDecoration(

                            color: ColorsUtil.hexToColor("#FFFFFF"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((5.0)),
                          ),
                          child: Text(
                            "戻る",
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#000000"),
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(180)),
                      InkWell(
                        onTap: (){
                          try {
                            //_doSubmitOrder();
                            if(_dining_type =="3" && _dining_type_num == "0"){
                              showToast("请选择就餐方式");
                              return;
                            }
                            if(_isAllowPos == "1" &&_payment_method_num == "0"){
                              showToast("请选择支付方式");
                              return;
                            }
                            if((_dining_type_num != "0" && _dining_type =="3") || (_isAllowPos == "1" &&_payment_method_num != "0")){
                              widget.onConfrimClick(_mealType, _dining_type_num,_isAllowPos,_payment_method_num);
                              Navigator.pop(context);
                            }
                          } catch (_) {}

                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: ScreenAdapter.width(270),
                          height: ScreenAdapter.height(140),
                          margin: EdgeInsets.only(right: ScreenAdapter.width(20)),
                          decoration: BoxDecoration(

                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                ColorsUtil.hexToColor("#C47829"),
                                ColorsUtil.hexToColor("#854610"),
                              ],
                            ),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((5.0)),
                          ),
                          child: Text(
                            GString.getToString(this._checkLanguage, "tag_button_yes"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenAdapter.fontSize(34.0)),
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
    );
  }
}
