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

class PaymentMethodPage extends StatefulWidget {
  Map arguments;
  PaymentMethodPage(
      {Key key,
      this.checkLanguage,
      this.takeOut,
        //this.mealType,
      this.onConfrimClick
      }) : super(key: key);
  final String checkLanguage;
  final bool takeOut;
  //final bool mealType;
  final Function(String) onConfrimClick;

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String _checkLanguage = "JP";
  bool _takeOut = false; //是否有外带


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _checkLanguage = widget.checkLanguage;
    _takeOut = widget.takeOut;
    //_mealType = widget.mealType;

  }

  @override
  Widget build(BuildContext mcontext) {
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
                    padding: EdgeInsets.only(left: ScreenAdapter.width(30),top: ScreenAdapter.height(25),right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(30)),
                    //width: ScreenAdapter.width(650),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          //"堂食",
                          GString.getToString(this._checkLanguage, "select_checkOut_tip_title"),
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
                                //Navigator.pop(mcontext);
                                widget.onConfrimClick("1");

                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(320),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                margin: EdgeInsets.only(right: ScreenAdapter.width(15)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#844811"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: ScreenAdapter.height(210),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "checkOut_checked"),
                                        //width: ScreenAdapter.width(120),
                                        height: ScreenAdapter.height(140),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    //SizedBox(height: ScreenAdapter.height(20),),
                                    Text(
                                      //"お食事後でのお会計",
                                      GString.getToString(this._checkLanguage, "select_checkOut_tip_selected"),
                                      style: TextStyle(
                                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                          fontWeight: FontWeight.w600,
                                          fontSize: ScreenAdapter.fontSize(34.0)),
                                    ),

                                  ],
                                ),
                              ),
                            ),

                            if(_takeOut == true)
                            InkWell(
                              onTap: (){
                                //Navigator.pop(mcontext);
                                widget.onConfrimClick("2");

                              },
                              child: Container(
                                width: ScreenAdapter.width(350),
                                height: ScreenAdapter.height(320),
                                padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                  //设置阴影
                                  boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#844811"), offset: Offset(1.0, 1.0), blurRadius: 2.0, spreadRadius: 6.0), ],
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: ScreenAdapter.height(210),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                                      child: Image.asset(GImage.getImageString("imgpublic", "dining_away_checked"),
                                        //width: ScreenAdapter.width(120),
                                        height: ScreenAdapter.height(140),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                    //SizedBox(height: ScreenAdapter.height(20),),
                                    Text(
                                      //"テイクアウト",
                                      GString.getToString(this._checkLanguage, "menu_dingtype_takeout"),
                                      style: TextStyle(
                                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
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
                            GString.getToString(this._checkLanguage, "settlement_back"),
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#000000"),
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
