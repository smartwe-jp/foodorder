import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/fontSize.dart';
import 'package:foodorder/config/index.dart';
import 'package:foodorder/controller/homePageController.dart';
import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:get/get.dart';

import 'SettlementCashPage.dart';
import 'SettlementQrCodePage.dart';

class SettlementPage extends StatefulWidget {
  SettlementPage({Key key}) : super(key: key);

  _SettlementPageState createState() => _SettlementPageState();
}

class _SettlementPageState extends State<SettlementPage> {
  final HomePageController controller = Get.put(HomePageController());

  bool checkboxSelected = true;

  @override
  void initState() {
    super.initState();
print("获取购物车商品方法");
    print(controller.getcartItems);
    /*
    * [{id: 31, shop_id: 17, name: Shoefly 99999, image: https://rukminim1.flixcart.com/image/612/612/j95y4cw0/shoe/d/p/8/sho-black-303-9-shoefly-black-original-imaechtbjzqbhygf.jpeg?q=70, price: 200.0, fav: 0, rating: 4.9, classid: 4, datetime: null}, {id: 33, shop_id: 4, name: Running Shoe Brooks Highly, image: https://cdn.pixabay.com/photo/2014/06/18/18/42/running-shoe-371625_960_720.jpg, price: 3001.0, fav: 0, rating: 3.5, classid: 2, datetime: null}]*/
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  //购物车
  _showShoppingCart() {

    return Container(
      //width: ScreenAdapter.width(1080),
      //height: ScreenAdapter.height(680),
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(30),
          top: ScreenAdapter.height(40),
          right: ScreenAdapter.width(30),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: Container(
            width: ScreenAdapter.width(930),
            child: GetBuilder<HomePageController>(
              builder: (_) {
                if (controller.cartItems.length == 0) {
                  return Center(
                    child: Text("No item found"),
                  );
                }
                return ListView(
                  shrinkWrap: true,
                  children: controller.cartItems
                      .map((d) => generateCartList(context, d))
                      .toList(),
                );
              },
            ),
          )),
          Container(
            height: ScreenAdapter.height(180),
              child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('合計',
                  style: TextStyle(
                      fontSize:
                          ScreenAdapter.fontSize(GFontSize.menusettlementHeji),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor))),
              Text('¥1,480',
                  style: TextStyle(
                      fontSize:
                          ScreenAdapter.fontSize(GFontSize.menusettlementHeji),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor))),
            ],
          )),

          Container(
              height: ScreenAdapter.height(80),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: checkboxSelected,
                      onChanged: (value){
                        checkboxSelected = !checkboxSelected;

                        setState(() {

                        });
                      }
                  ),
                  Text('領収書が必要ですのでこちらをご注文ください',
                      style: TextStyle(
                          fontSize:
                          ScreenAdapter.fontSize(GFontSize.menusettlementLingshoushu),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor))),
                ],
              )),
        ],
      ),
    );
  }

  Widget generateCartList(BuildContext context, ShopItemModel d) {
    return Container(
      padding: EdgeInsets.all(ScreenAdapter.height(10)),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white12,
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 1.0),
              top: BorderSide(color: Colors.grey.shade100, width: 1.0),
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
                child: Container(
              padding: EdgeInsets.only(left: ScreenAdapter.width(5)),
              //width: ScreenAdapter.width(495),
              child: RichText(
                text: TextSpan(
                    text: d.name,
                    style: TextStyle(
                        fontSize:
                            ScreenAdapter.fontSize(GFontSize.cartListTitle),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                    children: [
                      TextSpan(
                        text: " X1",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.cartListTitleCount),
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                      TextSpan(
                        text: "（中太麵、大盛(130g)、香菜普通、唐辛子無し）",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.cartListTitleTag),
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                    ]),
              ),
            )),
            Container(
              width: ScreenAdapter.width(140),
              child: Text(
                d.price.toString(),
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(GFontSize.mainPriceRight),
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //弹窗加载新widget页面
  doShowSettlementCashPage() async {
    var result = await showDialog(
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (context) {
          return SettlementCashPage();
        });
  }

  doShowSettlementQrCodePage(paymentMethod) async {
    var result = await showDialog(
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (context) {
          return SettlementQrCodePage(
              arguments: {"paymentMethod": paymentMethod});
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsUtil.hexToColor("#D8D8D8"),
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
                width: ScreenAdapter.getScreenWidth(),
                height: ScreenAdapter.height(120),
                alignment: Alignment.bottomRight,
                decoration: BoxDecoration(
                  color: ColorsUtil.hexToColor("#000000"),
                ),
                padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                child: Image.asset('assets/images/logo.png')),

            //展示购物车
            Expanded(
                child: Container(
              /*padding: EdgeInsets.only(
                  left: ScreenAdapter.width(40),
                  top: ScreenAdapter.height(20),
                  right: ScreenAdapter.width(40)),*/
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              alignment: Alignment.center,
              child: _showShoppingCart(),
            )),

            SizedBox(
              height: ScreenAdapter.height(15),
            ),
            //选择结算方式
            Container(
              height: ScreenAdapter.height(750),
              padding: EdgeInsets.only(
              left: ScreenAdapter.width(40),
              top: ScreenAdapter.height(20),
              right: ScreenAdapter.width(40)),
              color: ColorsUtil.hexToColor(Gcolor.settlementBackgroundColor),
              child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: ScreenAdapter.height(20),
                    bottom: ScreenAdapter.height(35)),
                alignment: Alignment.centerLeft,
                child: Text("支払方法の選択",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(48),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    )),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      doShowSettlementCashPage();
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                          top: ScreenAdapter.height(30),
                          bottom: ScreenAdapter.height(25)),
                      width: ScreenAdapter.width(386),
                      height: ScreenAdapter.height(352),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#A61C1C"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("現金",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(48),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(
                                    Gcolor.settlementBtnColor),
                              )),
                          SizedBox(
                            height: ScreenAdapter.height(30),
                          ),
                          Container(
                              width: ScreenAdapter.width(280),
                              height: ScreenAdapter.height(120),
                              child: Image.asset(
                                  'assets/images/settlement_cash.png')),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ScreenAdapter.width(60),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(30),
                        bottom: ScreenAdapter.height(25)),
                    width: ScreenAdapter.width(386),
                    height: ScreenAdapter.height(352),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorsUtil.hexToColor("#A61C1C"),
                      //设置圆角
                      borderRadius: new BorderRadius.circular((16.0)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("QRコード決済",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(48),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  Gcolor.settlementBtnColor),
                            )),
                        SizedBox(
                          height: ScreenAdapter.height(30),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                doShowSettlementQrCodePage("paypay");
                              },
                              child: Container(
                                  width: ScreenAdapter.width(120),
                                  height: ScreenAdapter.height(120),
                                  child: Image.asset(
                                      'assets/images/settlement_paypay.png')),
                            ),
                            InkWell(
                              onTap: () {
                                doShowSettlementQrCodePage("alipay");
                              },
                              child: Container(
                                  width: ScreenAdapter.width(120),
                                  height: ScreenAdapter.height(120),
                                  child: Image.asset(
                                      'assets/images/settlement_alipay.png')),
                            ),
                            InkWell(
                              onTap: () {
                                doShowSettlementQrCodePage("wechat");
                              },
                              child: Container(
                                  width: ScreenAdapter.width(120),
                                  height: ScreenAdapter.height(120),
                                  child: Image.asset(
                                      'assets/images/settlement_wechat.png')),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: InkWell(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.only(
                      top: ScreenAdapter.height(20),
                      bottom: ScreenAdapter.height(35)),
                  alignment: Alignment.center,
                  child: Text("戻る",
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(48),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
