import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/fontSize.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../controllers/menu_page_controller.dart';


class SelectPaymentPage extends StatefulWidget {
   Map? arguments;
  SelectPaymentPage(
      {Key? key,
        required this.checkLanguage,
        required this.menuCount,
        //this.mealType,
        required this.isAllowPos,
        required this.isAllowReceipt,
        required this.payment_method_num,
        required this.showCash,
        required this.showWechat,
        required this.showAlipay,
        required this.showPayPay,
        required this.showauPay,
        required this.showdPay,
        required this.showrPay,
        required this.showmPay,
        required this.showCreditCard,
        required this.showPosEdy,
        required this.showPosiD,
        required this.showPosIC,
        required this.showPosQUICPay,
        required this.showPosWAON,
        required this.showPosnanaco,
        required this.showVisa,
        required this.showMaster,
        required this.showJcb,
        required this.showUnionPay,
        required this.showAmericanExpress,
        required this.showDinersClub,
        required this.shopCartTotalPrice,
        required this.tableNum,
        required this.onConfrimClick,
        required this.onCancelClick
      }) : super(key: key);
  final String checkLanguage;
  //final bool mealType;
  final String isAllowPos;
  final String isAllowReceipt;
  final String payment_method_num;
  final int menuCount;
  final bool showCash;
  final bool showWechat;
  final bool showAlipay;
  final bool showPayPay;
  final bool showauPay;
  final bool showdPay;
  final bool showrPay;
  final bool showmPay;
  final bool showCreditCard;
  final bool showPosEdy;
  final bool showPosiD;
  final bool showPosIC;
  final bool showPosQUICPay;
  final bool showPosWAON;
  final bool showPosnanaco;
  final bool showVisa;
  final bool showMaster;
  final bool showJcb;
  final bool showUnionPay;
  final bool showAmericanExpress;
  final bool showDinersClub;
  final String shopCartTotalPrice;
  final String tableNum;
  final Function(String, String, String) onConfrimClick;
  final Function(String) onCancelClick;

  @override
  _SelectPaymentPageState createState() => _SelectPaymentPageState();
}

class _SelectPaymentPageState extends State<SelectPaymentPage> {
  String _checkLanguage = "JP";
  bool _mealType = false;
  String _isAllowPos = "0"; //1 使用信用卡刷卡  0 不可使用;
  String _payment_method_num = "0"; //支付类型选择 1现金 2扫码 3pos 4nfc
  String _shopCartTotalPrice="0"; //合计总价
  String _tableNum = "";
  int _menuCount =0;
  var _showWechat = false;
  var _showAlipay = false;
  var _showPayPay = false;
  var _showauPay = false;
  var _showdPay = false;
  var _showrPay = false;
  var _showmPay = false;
  var _showCreditCard = false;
  var _showCash = false;

  var _showPosEdy = false;
  var _showPosiD = false;
  var _showPosIC = false;
  var _showPosQUICPay = false;
  var _showPosWAON = false;
  var _showPosnanaco = false;

  var _showVisa = false;
  var _showMaster = false;
  var _showJcb = false;
  var _showUnionPay = false;
  var _showAmericanExpress = false;
  var _showDinersClub = false;
  var _receiptPrintType = "2"; //1 打印 2 不打印
  var _showReceiptPage = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkLanguage = widget.checkLanguage;
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

    _showPosEdy = widget.showPosEdy;
    _showPosiD = widget.showPosiD;
    _showPosIC = widget.showPosIC;
    _showPosQUICPay = widget.showPosQUICPay;
    _showPosWAON = widget.showPosWAON;
    _showPosnanaco = widget.showPosnanaco;
    _menuCount = widget.menuCount;

    _showVisa = widget.showVisa;
    _showMaster = widget.showMaster;
    _showJcb = widget.showJcb;
    _showUnionPay = widget.showUnionPay;
    _showAmericanExpress = widget.showAmericanExpress;
    _showDinersClub = widget.showDinersClub;

    //初始化领收书显示变量
    _receiptPrintType = widget.isAllowReceipt;
    _showReceiptPage = widget.isAllowReceipt == "1" ? false : true;

  }

  updateCashShow(){
    setState(() {
      _showCash = false;
    });
  }

  Widget selectPrintType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: ScreenAdapter.height(80),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[

            InkWell(
              onTap: () {
                setState(() {
                  _receiptPrintType = "1";
                  _showReceiptPage = false;
                });
              },
              child: Container(
                width: ScreenAdapter.width(320),
                height: ScreenAdapter.height(225),
                padding: EdgeInsets.only(
                    top: ScreenAdapter.height(2)),
                //margin: EdgeInsets.only(left: ScreenAdapter.width(30)),
                decoration: BoxDecoration(
                  //设置边框
                  border: new Border.all(
                      color: ColorsUtil.hexToColor("#9e9e9e"),
                      width: 2.0),
                  //背景颜色
                  color: ColorsUtil.hexToColor("#F3F3F3"),
                  //设置圆角
                  //borderRadius: new BorderRadius.circular((5.0)),
                  borderRadius:
                  new BorderRadius.circular((16.0)),
                  //设置阴影
                  //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                ),
                alignment: Alignment.center,
                child:
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      GString.getToString(
                          this._checkLanguage, "settlement_receipt_title"),
                      style: TextStyle(
                          fontFamily: GFont.getFontFamily(),
                          color: ColorsUtil.hexToColor(
                              Gcolor.mainTitleColor),
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenAdapter.fontSize(34.0)),
                    ),
                    Text(
                      GString.getToString(
                          this._checkLanguage, "settlement_receipt_yes"),
                      style: TextStyle(
                          fontFamily: GFont.getFontFamily(),
                          color: ColorsUtil.hexToColor(
                              Gcolor.mainTitleColor),
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenAdapter.fontSize(54.0)),
                    )
                  ],
                ),
              ),
            ),

            InkWell(
              onTap: () {
                setState(() {
                  _receiptPrintType = "2";
                  _showReceiptPage = false;
                });
              },
              child: Container(
                width: ScreenAdapter.width(320),
                height: ScreenAdapter.height(225),
                padding: EdgeInsets.only(
                    top: ScreenAdapter.height(2)),
                //margin: EdgeInsets.only(left: ScreenAdapter.width(30)),
                decoration: BoxDecoration(
                  //设置边框
                  border: new Border.all(
                      color: ColorsUtil.hexToColor("#9e9e9e"),
                      width: 2.0),
                  //背景颜色
                  color: ColorsUtil.hexToColor("#F3F3F3"),
                  //设置圆角
                  //borderRadius: new BorderRadius.circular((5.0)),
                  borderRadius:
                  new BorderRadius.circular((16.0)),
                  //设置阴影
                  //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      GString.getToString(
                          this._checkLanguage, "settlement_receipt_title"),
                      style: TextStyle(
                          fontFamily: GFont.getFontFamily(),
                          color: ColorsUtil.hexToColor(
                              Gcolor.mainTitleColor),
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenAdapter.fontSize(34.0)),
                    ),
                    Text(
                      GString.getToString(
                          this._checkLanguage, "settlement_receipt_no"),
                      style: TextStyle(
                          fontFamily: GFont.getFontFamily(),
                          color: ColorsUtil.hexToColor(
                              Gcolor.mainTitleColor),
                          fontWeight: FontWeight.w600,
                          fontSize: ScreenAdapter.fontSize(54.0)),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: ScreenAdapter.height(60),
        ),
      ],

    );
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
                    padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(25),right: ScreenAdapter.width(20),bottom: ScreenAdapter.height(30)),
                    //width: ScreenAdapter.width(650),

                    child:
                    _showReceiptPage ? selectPrintType() :
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          //GString.getToString(this._checkLanguage, "menu_dingtype_title"),
                          GString.getToString(this._checkLanguage, "select_payment_type_title"),
                          style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
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
                                widget.onConfrimClick(_isAllowPos,_payment_method_num, _receiptPrintType);

                              },
                              child: Container(
                                width: ScreenAdapter.width(320),
                                height: ScreenAdapter.height(225),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(2)),
                                //margin: EdgeInsets.only(left: ScreenAdapter.width(30)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  border: new Border.all(color: ColorsUtil.hexToColor("#9e9e9e"), width: 2.0),
                                  //背景颜色
                                  color: ColorsUtil.hexToColor("#F3F3F3"),
                                  //设置圆角
                                  //borderRadius: new BorderRadius.circular((5.0)),
                                  borderRadius: new BorderRadius.circular((16.0)),
                                  //设置阴影
                                  //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                ),
                                alignment: Alignment.center,
                                child: Stack(
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: ScreenAdapter.height(65),),
                                        Container(
                                          height: ScreenAdapter.height(150),
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                          child: Image.asset(GImage.getImageString("imgpublic", "payment_cash"),
                                            //width: ScreenAdapter.width(150),
                                            height: ScreenAdapter.height(120),
                                            //color:  ColorsUtil.hexToColor(Gcolor.mainBackground),
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                        //SizedBox(height: ScreenAdapter.height(20),),


                                      ],
                                    ),
                                    Positioned(
                                        //right: ScreenAdapter.width(120),
                                        top: ScreenAdapter.height(2),
                                        child: Container(
                                          width: ScreenAdapter.width(160),
                                          alignment: Alignment.center,
                                          child: Text(
                                            //"现金",
                                            GString.getToString(this._checkLanguage, "settlement_top_title_cash"),
                                            style: TextStyle(
                                              fontFamily: GFont.getFontFamily(),
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
                            if(_showAlipay == true || _showWechat == true || _showPayPay == true)
                              InkWell(
                                onTap: (){
                                  setState(() {
                                    _payment_method_num = "2";
                                  });
                                  //Navigator.pop(pcontext);
                                  widget.onConfrimClick(_isAllowPos,_payment_method_num, _receiptPrintType);

                                },
                                child: Container(
                                  width: ScreenAdapter.width(460),
                                  height: ScreenAdapter.height(225),
                                  padding: EdgeInsets.only(top: ScreenAdapter.height(2)),
                                  //margin: EdgeInsets.only(right: ScreenAdapter.width(30)),
                                  decoration: BoxDecoration(
                                    //设置边框
                                    border: new Border.all(color: ColorsUtil.hexToColor("#9e9e9e"), width: 2.0),
                                    //背景颜色
                                    color: ColorsUtil.hexToColor("#F3F3F3"),
                                    //设置圆角
                                    //borderRadius: new BorderRadius.circular((5.0)),
                                    borderRadius: new BorderRadius.circular((16.0)),
                                    //设置阴影
                                    //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                  ),
                                  child: Stack(
                                    children: [
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(height: ScreenAdapter.height(38),),
                                          Container(
                                            width: ScreenAdapter.width(450),
                                            child: Wrap(
                                                spacing: ScreenAdapter.width(22), // set spacing here
                                                runSpacing: ScreenAdapter.height(2),
                                                alignment: WrapAlignment.center,
                                                children: [
                                                  if (_showPayPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(80),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_paypay"),
                                                        width: ScreenAdapter.width(65),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showAlipay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(80),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_alipay"),
                                                        width: ScreenAdapter.width(65),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showWechat == true)
                                                    Container(
                                                      height: ScreenAdapter.height(80),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_wechat"),
                                                        width: ScreenAdapter.width(65),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showCreditCard == true && _isAllowPos =="1" && _showauPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(80),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_aupay"),
                                                        width: ScreenAdapter.width(65),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showCreditCard == true && _isAllowPos =="1" && _showdPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(80),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_dpay"),
                                                        width: ScreenAdapter.width(65),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showCreditCard == true && _isAllowPos =="1" && _showrPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(80),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_rpay"),
                                                        width: ScreenAdapter.width(65),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),
                                                  if (_showCreditCard == true && _isAllowPos =="1" && _showmPay == true)
                                                    Container(
                                                      height: ScreenAdapter.height(80),
                                                      padding: EdgeInsets.only(
                                                          left: ScreenAdapter.width(5),
                                                          top: ScreenAdapter.height(5),
                                                          right: ScreenAdapter.width(5),
                                                          bottom: ScreenAdapter.height(5)),
                                                      child: Image.asset(
                                                        GImage.getImageString(
                                                            "imgpublic", "settlement_mpay"),
                                                        width: ScreenAdapter.width(65),
                                                        //height: ScreenAdapter.height(100),
                                                        //color: Colors.lightGreen,
                                                        fit: BoxFit.fitWidth,
                                                      ),
                                                    ),

                                                ]),
                                          ),

                                          //SizedBox(height: ScreenAdapter.height(30),),

                                        ],
                                      ),
                                      Positioned(
                                        //right: ScreenAdapter.width(120),
                                        top: ScreenAdapter.height(2),
                                        child: Container(
                                          width: ScreenAdapter.width(420),
                                          alignment: Alignment.center,
                                          child: Text(
                                            //"扫码",
                                            GString.getToString(this._checkLanguage, "settlement_top_title_qr"),
                                            style: TextStyle(
                                              fontFamily: GFont.getFontFamily(),
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
                          height: ScreenAdapter.height(60),
                        ),
                        if(_isAllowPos =="1" && _showCreditCard == true && ( _showVisa== true || _showMaster == true || _showJcb == true || _showUnionPay == true || _showAmericanExpress == true || _showDinersClub == true))
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: (){
                                setState(() {
                                  _isAllowPos = "1";
                                  _payment_method_num = "3";
                                });
                                //Navigator.pop(pcontext);
                                widget.onConfrimClick(_isAllowPos,_payment_method_num, _receiptPrintType);

                              },
                              child: Container(
                                width: ScreenAdapter.width(870),
                                //height: ScreenAdapter.height(335),
                                padding: EdgeInsets.only(left: ScreenAdapter.width(15),top: ScreenAdapter.height(20),right: ScreenAdapter.width(15),bottom: ScreenAdapter.height(20)),
                                decoration: BoxDecoration(
                                  //设置边框
                                  border: new Border.all(color: ColorsUtil.hexToColor("#9e9e9e"), width: 2.0),
                                  //背景颜色
                                  color: ColorsUtil.hexToColor("#F3F3F3"),
                                  //设置圆角
                                  //borderRadius: new BorderRadius.circular((5.0)),
                                  borderRadius: new BorderRadius.circular((16.0)),
                                  //设置阴影
                                  //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      //"信用卡",
                                      GString.getToString(this._checkLanguage, "settlement_top_title_card"),
                                      style: TextStyle(
                                          color:ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                          fontFamily: GFont.getFontFamily(),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(34.0)),
                                    ),
                                    /*Container(
                                      height: ScreenAdapter.height(210),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "payment_card"),
                                        width: ScreenAdapter.width(220),
                                        //height: ScreenAdapter.height(100),
                                        //color: Colors.lightGreen,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),*/
                                    Wrap(
                                      spacing: ScreenAdapter.width(10), // set spacing here
                                      runSpacing: ScreenAdapter.height(20),
                                      alignment: WrapAlignment.center,
                                      //mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if(_showVisa == true)
                                          Container(
                                            width: ScreenAdapter.width(110),
                                            height: ScreenAdapter.height(90),
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                            child: Image.asset(GImage.getImageString("imgpublic", "card_visa"),
                                              width: ScreenAdapter.width(90),
                                              //height: ScreenAdapter.height(100),
                                              //color: Colors.lightGreen,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        if(_showJcb == true)
                                          Container(
                                            width: ScreenAdapter.width(110),
                                            height: ScreenAdapter.height(90),
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                            child: Image.asset(GImage.getImageString("imgpublic", "card_jcb"),
                                              width: ScreenAdapter.width(90),
                                              //height: ScreenAdapter.height(100),
                                              //color: Colors.lightGreen,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        if(_showMaster == true)
                                        Container(
                                          width: ScreenAdapter.width(110),
                                          height: ScreenAdapter.height(90),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                          child: Image.asset(GImage.getImageString("imgpublic", "card_master"),
                                            width: ScreenAdapter.width(90),
                                            //height: ScreenAdapter.height(100),
                                            //color: Colors.lightGreen,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        if(_showUnionPay == true)
                                        Container(
                                          width: ScreenAdapter.width(110),
                                          height: ScreenAdapter.height(90),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                          child: Image.asset(GImage.getImageString("imgpublic", "card_unionp"),
                                            width: ScreenAdapter.width(90),
                                            //height: ScreenAdapter.height(100),
                                            //color: Colors.lightGreen,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        if(_showAmericanExpress == true)
                                        Container(
                                          width: ScreenAdapter.width(110),
                                          height: ScreenAdapter.height(90),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                          child: Image.asset(GImage.getImageString("imgpublic", "card_american"),
                                            width: ScreenAdapter.width(100),
                                            //height: ScreenAdapter.height(100),
                                            //color: Colors.lightGreen,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),

                                        if(_showDinersClub == true)
                                        Container(
                                          width: ScreenAdapter.width(110),
                                          height: ScreenAdapter.height(90),
                                          alignment: Alignment.center,
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
                                          child: Image.asset(GImage.getImageString("imgpublic", "card_diners"),
                                            width: ScreenAdapter.width(100),
                                            //height: ScreenAdapter.height(100),
                                            //color: Colors.lightGreen,
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),

                                      ],
                                    ),
                                    //SizedBox(height: ScreenAdapter.height(20),),

                                  ],
                                ),
                              ),
                            ),

                            /*InkWell(
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
                                  boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
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
                            ),*/
                          ],
                        ),

                        if(_isAllowPos =="1" && (_showPosEdy ==true || _showPosiD == true ||  _showPosIC ==true || _showPosQUICPay == true || _showPosWAON ==true || _showPosnanaco ==true))
                          Container(
                            margin: EdgeInsets.only(top: ScreenAdapter.height(50)),
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  //"电子钱包",
                                  GString.getToString(this._checkLanguage, "settlement_top_title_wallet"),
                                  style: TextStyle(
                                      color:ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w600,
                                      fontSize: ScreenAdapter.fontSize(34.0)),
                                ),
                                SizedBox(height: ScreenAdapter.height(40),),
                                Wrap(
                                  spacing: ScreenAdapter.width(90), // set spacing here
                                  runSpacing: ScreenAdapter.height(40),
                                  alignment: WrapAlignment.center,
                                  children: <Widget>[
                                    if(_showPosEdy ==true)
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            _isAllowPos = "1";
                                            _payment_method_num = "5";
                                          });
                                          //Navigator.pop(pcontext);
                                          widget.onConfrimClick(_isAllowPos,_payment_method_num, _receiptPrintType);

                                        },
                                        child: Container(
                                          width: ScreenAdapter.width(225),
                                          height: ScreenAdapter.height(140),
                                          padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                                          decoration: BoxDecoration(
                                            //设置边框
                                            //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                            //背景颜色
                                            color: Colors.white,
                                            //设置圆角
                                            //borderRadius: new BorderRadius.circular((5.0)),
                                            borderRadius: new BorderRadius.circular((16.0)),
                                            //设置阴影
                                            boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: ScreenAdapter.height(135),
                                                padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                                child: Image.asset(GImage.getImageString("imgpublic", "settlement_edy"),
                                                  height: ScreenAdapter.width(120),
                                                  //height: ScreenAdapter.height(100),
                                                  //color: Colors.lightGreen,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if(_showPosiD ==true)
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            _isAllowPos = "1";
                                            _payment_method_num = "6";
                                          });
                                          //Navigator.pop(pcontext);
                                          widget.onConfrimClick(_isAllowPos,_payment_method_num, _receiptPrintType);

                                        },
                                        child: Container(
                                          width: ScreenAdapter.width(225),
                                          height: ScreenAdapter.height(140),
                                          padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                                          decoration: BoxDecoration(
                                            //设置边框
                                            //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                            //背景颜色
                                            color: Colors.white,
                                            //设置圆角
                                            //borderRadius: new BorderRadius.circular((5.0)),
                                            borderRadius: new BorderRadius.circular((16.0)),
                                            //设置阴影
                                            boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: ScreenAdapter.height(135),
                                                padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                                child: Image.asset(GImage.getImageString("imgpublic", "settlement_id"),
                                                  height: ScreenAdapter.width(120),
                                                  //height: ScreenAdapter.height(100),
                                                  //color: Colors.lightGreen,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if(_showPosnanaco ==true)
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            _isAllowPos = "1";
                                            _payment_method_num = "7";
                                          });
                                          //Navigator.pop(pcontext);
                                          widget.onConfrimClick(_isAllowPos,_payment_method_num, _receiptPrintType);

                                        },
                                        child: Container(
                                          width: ScreenAdapter.width(225),
                                          height: ScreenAdapter.height(140),
                                          padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                                          decoration: BoxDecoration(
                                            //设置边框
                                            //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                            //背景颜色
                                            color: Colors.white,
                                            //设置圆角
                                            //borderRadius: new BorderRadius.circular((5.0)),
                                            borderRadius: new BorderRadius.circular((16.0)),
                                            //设置阴影
                                            boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: ScreenAdapter.height(135),
                                                padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                                child: Image.asset(GImage.getImageString("imgpublic", "settlement_nanaco"),
                                                  height: ScreenAdapter.width(120),
                                                  //height: ScreenAdapter.height(100),
                                                  //color: Colors.lightGreen,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if(_showPosWAON ==true)
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            _isAllowPos = "1";
                                            _payment_method_num = "8";
                                          });
                                          //Navigator.pop(pcontext);
                                          widget.onConfrimClick(_isAllowPos,_payment_method_num, _receiptPrintType);

                                        },
                                        child: Container(
                                          width: ScreenAdapter.width(225),
                                          height: ScreenAdapter.height(140),
                                          padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                                          decoration: BoxDecoration(
                                            //设置边框
                                            //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                            //背景颜色
                                            color: Colors.white,
                                            //设置圆角
                                            //borderRadius: new BorderRadius.circular((5.0)),
                                            borderRadius: new BorderRadius.circular((16.0)),
                                            //设置阴影
                                            boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: ScreenAdapter.height(135),
                                                padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                                child: Image.asset(GImage.getImageString("imgpublic", "settlement_waon"),
                                                  height: ScreenAdapter.width(120),
                                                  //height: ScreenAdapter.height(100),
                                                  //color: Colors.lightGreen,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if(_showPosQUICPay ==true)
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            _isAllowPos = "1";
                                            _payment_method_num = "9";
                                          });
                                          //Navigator.pop(pcontext);
                                          widget.onConfrimClick(_isAllowPos,_payment_method_num, _receiptPrintType);

                                        },
                                        child: Container(
                                          width: ScreenAdapter.width(225),
                                          height: ScreenAdapter.height(140),
                                          padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                                          decoration: BoxDecoration(
                                            //设置边框
                                            //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                            //背景颜色
                                            color: Colors.white,
                                            //设置圆角
                                            //borderRadius: new BorderRadius.circular((5.0)),
                                            borderRadius: new BorderRadius.circular((16.0)),
                                            //设置阴影
                                            boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: ScreenAdapter.height(135),
                                                padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                                child: Image.asset(GImage.getImageString("imgpublic", "settlement_quicpay"),
                                                  height: ScreenAdapter.width(120),
                                                  //height: ScreenAdapter.height(100),
                                                  //color: Colors.lightGreen,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    if(_showPosIC ==true)
                                      InkWell(
                                        onTap: (){
                                          setState(() {
                                            _isAllowPos = "1";
                                            _payment_method_num = "10";
                                          });
                                          //Navigator.pop(pcontext);
                                          widget.onConfrimClick(_isAllowPos,_payment_method_num, _receiptPrintType);

                                        },
                                        child: Container(
                                          width: ScreenAdapter.width(225),
                                          height: ScreenAdapter.height(140),
                                          padding: EdgeInsets.only(top: ScreenAdapter.height(5)),
                                          decoration: BoxDecoration(
                                            //设置边框
                                            //border: new Border.all(color: Color(0xFFFF0000), width: 0.5),
                                            //背景颜色
                                            color: Colors.white,
                                            //设置圆角
                                            //borderRadius: new BorderRadius.circular((5.0)),
                                            borderRadius: new BorderRadius.circular((16.0)),
                                            //设置阴影
                                            boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9e9e9e"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 2.0), ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: ScreenAdapter.height(135),
                                                padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                                child: Image.asset(GImage.getImageString("imgpublic", "settlement_jiaotongxi"),
                                                  height: ScreenAdapter.width(120),
                                                  //height: ScreenAdapter.height(100),
                                                  //color: Colors.lightGreen,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              ],
                            ),
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
                      Row(
                        children: [
                          if(_tableNum != null && _tableNum != "")
                            Text(
                              "${GString.getToString(this._checkLanguage, "show_check_tableno")}${_tableNum}    ",
                              style: TextStyle(
                                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                  fontFamily: GFont.getFontFamily(),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(40.0)),
                            ),
                          Text(
                            GString.getToString(this._checkLanguage, "settlement_total_price"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(40.0)),
                          ),
                          if(_menuCount != null && _menuCount >0)
                            Text(
                              "  ${_menuCount.toString()}  ${GString.getToString(this._checkLanguage, "show_selectPay_point")}",
                              style: TextStyle(
                                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                  fontFamily: GFont.getFontFamily(),
                                  fontWeight: FontWeight.w600,
                                  fontSize: ScreenAdapter.fontSize(40.0)),
                            ),
                        ],
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
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              ),
                              children: [
                                TextSpan(
                                  text: formatMoney(_shopCartTotalPrice.toString()),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(GFontSize.menusettlementBottomPrice),
                                    fontFamily: GFont.getFontFamily(),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                  "（${GString.getToString(this._checkLanguage, "show_price_front")}）", //" 円",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(GFontSize.menusettlementBottomPriceRight),
                                    fontFamily: GFont.getFontFamily(),
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
                                fontFamily: GFont.getFontFamily(),
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
