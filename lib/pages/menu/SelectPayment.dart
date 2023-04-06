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

import '../../services/EventBus.dart';

class SelectPaymentPage extends StatefulWidget {
  Map arguments;
  SelectPaymentPage(
      {Key key,
      this.checkLanguage,
        this.shopInfo,
        //this.mealType,
        this.isAllowPos,
        this.payment_method_num,
        this.showCash,
        this.showWechat,
        this.showAlipay,
        this.showPayPay,
        this.showauPay,
        this.showdPay,
        this.showrPay,
        this.showmPay,
        this.showCreditCard,
        this.shopCartTotalPrice,
        this.tableNum,
        this.onConfrimClick,
        this.onCancelClick
      }) : super(key: key);
  final String checkLanguage;
  final String shopInfo;
  //final bool mealType;
  final String isAllowPos;
  final String payment_method_num;
  final bool showCash;
  final bool showWechat;
  final bool showAlipay;
  final bool showPayPay;
  final bool showauPay;
  final bool showdPay;
  final bool showrPay;
  final bool showmPay;
  final bool showCreditCard;
  final String shopCartTotalPrice;
  final String tableNum;
  final Function(String, String) onConfrimClick;
  final Function(String) onCancelClick;

  @override
  _SelectPaymentPageState createState() => _SelectPaymentPageState();
}

class _SelectPaymentPageState extends State<SelectPaymentPage> {
  String _checkLanguage = "JP";
  String _shopInfo = "kanran";
  bool _mealType = false;
  String _isAllowPos = "0"; //1 使用信用卡刷卡  0 不可使用;
  String _payment_method_num = "0"; //支付类型选择 1现金 2扫码 3pos 4nfc
  String _shopCartTotalPrice="0"; //合计总价
  String _tableNum = "";

  var _showWechat = false;
  var _showAlipay = false;
  var _showPayPay = false;
  var _showauPay = false;
  var _showdPay = false;
  var _showrPay = false;
  var _showmPay = false;
  var _showCreditCard = false;
  var _showCash = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkLanguage = widget.checkLanguage;
    _shopInfo = widget.shopInfo;
    //_mealType = widget.mealType;
    _isAllowPos = widget.isAllowPos;
    _payment_method_num = widget.payment_method_num;
    _shopCartTotalPrice = widget.shopCartTotalPrice;

    _showWechat = widget.showWechat;
    _showAlipay = widget.showAlipay;
    _showPayPay = widget.showPayPay;
    _showauPay = widget.showauPay;
    _showdPay = widget.showdPay;
    _showrPay = widget.showrPay;
    _showmPay = widget.showmPay;
    _showCreditCard = widget.showCreditCard;
    _showCash = widget.showCash;
    _tableNum = widget.tableNum;

    //监听是否展示现金的广播
    eventBus.on<setShowCashEvent>().listen((event) {
     updateCashShow();
    });

  }

  updateCashShow(){
    setState(() {
      _showCash = false;
    });
  }

  @override
  Widget build(BuildContext pcontext) {
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

                  Container(
                    padding: EdgeInsets.only(left: ScreenAdapter.width(50),top: ScreenAdapter.height(25),right: ScreenAdapter.width(50),bottom: ScreenAdapter.height(30)),
                    //width: ScreenAdapter.width(650),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          //GString.getToString(this._checkLanguage, "menu_dingtype_title"),
                          GString.getToString(this._checkLanguage, "select_payment_type_title"),
                          style: TextStyle(
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(34.0)),
                        ),
                        SizedBox(height: ScreenAdapter.height(30),),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            if(_showCash == true)
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _payment_method_num = "1";
                                });
                                //Navigator.pop(pcontext);
                                widget.onConfrimClick(_isAllowPos,_payment_method_num);

                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(335),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                  //背景颜色
                                  color: Colors.white,
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#844811"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
                                ),
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: ScreenAdapter.height(25),),
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


                                      ],
                                    ),
                                    Positioned(
                                        //right: ScreenAdapter.width(120),
                                        bottom: ScreenAdapter.height(10),
                                        child: Container(
                                          width: ScreenAdapter.width(230),
                                          alignment: Alignment.center,
                                          child: Text(
                                            //"现金",
                                            GString.getToString(this._checkLanguage, "settlement_top_title_cash"),
                                            style: TextStyle(
                                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScreenAdapter.fontSize(34.0)),
                                          ),
                                        ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            if(_showAlipay == true || _showWechat == true || _showPayPay == true || _showCreditCard == true)
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    _payment_method_num = "2";
                                  });
                                  //Navigator.pop(pcontext);
                                  widget.onConfrimClick(_isAllowPos,_payment_method_num);

                                },
                                child: Container(
                                  width: ScreenAdapter.width(350),
                                  height: ScreenAdapter.height(335),
                                  padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                  decoration: BoxDecoration(
                                    //设置边框
                                    //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                    //背景颜色
                                    color: Colors.white,
                                    //设置圆角
                                    borderRadius: new BorderRadius.circular((5.0)),
                                    //设置阴影
                                    boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#844811"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: ScreenAdapter.width(350),
                                            child: Wrap(
                                                spacing: ScreenAdapter.width(15), // set spacing here
                                                runSpacing: ScreenAdapter.height(2),
                                                alignment: WrapAlignment.center,
                                                children: [
                                                  if (_showPayPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(90),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_paypay"),
                                                        width: ScreenAdapter.width(75),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showAlipay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(90),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_alipay"),
                                                        width: ScreenAdapter.width(75),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showWechat == true)
                                                    Container(
                                                      height: ScreenAdapter.height(90),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_wechat"),
                                                        width: ScreenAdapter.width(75),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showCreditCard == true && _isAllowPos =="1" && _showauPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(90),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_aupay"),
                                                        width: ScreenAdapter.width(75),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showCreditCard == true && _isAllowPos =="1" && _showdPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(90),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_dpay"),
                                                        width: ScreenAdapter.width(75),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showCreditCard == true && _isAllowPos =="1" && _showrPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(90),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_rpay"),
                                                        width: ScreenAdapter.width(75),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showCreditCard == true && _isAllowPos =="1" && _showmPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(90),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_mpay"),
                                                        width: ScreenAdapter.width(75),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),

                                                ]),
                                          ),

                                          SizedBox(height: ScreenAdapter.height(30),),

                                        ],
                                      ),
                                      Positioned(
                                        //right: ScreenAdapter.width(120),
                                        bottom: ScreenAdapter.height(10),
                                        child: Container(
                                          width: ScreenAdapter.width(350),
                                          alignment: Alignment.center,
                                          child: Text(
                                            //"扫码",
                                            GString.getToString(this._checkLanguage, "settlement_top_title_qr"),
                                            style: TextStyle(
                                                color:ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                                fontWeight: FontWeight.w600,
                                                fontSize: ScreenAdapter.fontSize(34.0)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: ScreenAdapter.height(50),
                        ),
                        if(_showCreditCard == true && _isAllowPos =="1")
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _isAllowPos = "1";
                                  _payment_method_num = "3";
                                });
                                //Navigator.pop(pcontext);
                                widget.onConfrimClick(_isAllowPos,_payment_method_num);

                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(335),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                  //背景颜色
                                  color: Colors.white,
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#844811"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
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
                                      GString.getToString(this._checkLanguage, "settlement_top_title_card"),
                                      style: TextStyle(
                                          color:ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(34.0)),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            InkWell(
                              onTap: (){
                                setState(() {
                                  _isAllowPos = "1";
                                  _payment_method_num = "4";
                                });
                                //Navigator.pop(pcontext);
                                widget.onConfrimClick(_isAllowPos,_payment_method_num);

                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(335),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                  //背景颜色
                                  color: Colors.white,
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#844811"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
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
                                      GString.getToString(this._checkLanguage, "settlement_top_title_nfc"),
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
                      if(_tableNum != null && _tableNum != "")
                      Text(
                        "${GString.getToString(this._checkLanguage, "show_check_tableno")}${_tableNum}",
                        style: TextStyle(
                            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            fontWeight: FontWeight.w600,
                            fontSize: ScreenAdapter.fontSize(40.0)),
                      ),
                      Text(
                        GString.getToString(this._checkLanguage, "settlement_total_price"),
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
                                fontSize: ScreenAdapter.fontSize(GFontSize.menusettlementBottomPriceLeft),
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
                            Navigator.pop(pcontext);
                            widget.onCancelClick("back");
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
                            GString.getToString(this._checkLanguage, "settlement_back"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#000000"),
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ),
                      ),
                      /*SizedBox(width: ScreenAdapter.width(180)),
                      InkWell(
                        onTap: (){
                          try {
                            if(_isAllowPos == "1" &&_payment_method_num == "0"){
                              showToast(GString.getToString(this._checkLanguage, "select_payment_type_title"));
                              return;
                            }
                            if(_isAllowPos == "1" &&_payment_method_num != "0"){
                              widget.onConfrimClick(_isAllowPos,_payment_method_num);
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
                      ),*/
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
