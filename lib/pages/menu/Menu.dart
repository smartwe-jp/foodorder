
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/fontSize.dart';
import 'package:foodorder/config/index.dart';
import 'package:foodorder/controller/homePageController.dart';
import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/SqfliteHelper.dart';
import 'package:foodorder/services/addCartParabola.dart';
import 'package:foodorder/services/itemService.dart';
import 'package:foodorder/widget/iosAlter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:foodorder/services/Storage.dart';

class MenuPage extends StatefulWidget {
  MenuPage({Key key}) : super(key: key);

  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  var imgUrl =
      'https://kanran.co.jp/fanxing/sites/6/2021/10/1635210298859_1026-1024x1024.jpg';

  Storage storageService = Storage();

  ItemServices itemServices = ItemServices();
  List items = [];
  List itemstwo = [];
  List itemsthree = [];
  List itemsfour = [];
  //第一页第一个商品以及剩余商品
  Map itemsFirst = {};
  List itemsTree = [];
  final HomePageController controller = Get.put(HomePageController());
  int classTag = 1;

  final sqlHelper = SqfliteHelper();

  //购物车抛物线
  GlobalKey floatKey = GlobalKey();
  GlobalKey rootKey = GlobalKey();
  Offset floatOffset ;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      RenderBox renderBox = floatKey.currentContext.findRenderObject();
      floatOffset = renderBox.localToGlobal(Offset.zero);
    });

    _getBookingBootMenu();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  //获取菜单
  _getBookingBootMenu(){
    var formData = {
      "machineCode":"S9UINWH2NU8DZIYHCD"
    };
    request('webBootIndex',
        method: 'POST',
        parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200) {
        print('获取菜单成功');
        //1、保存店铺信息
        var shopData = response['data'];
        var ShopInfo = {
          "shopCode": shopData["shopCode"],
          "machineCode": shopData["machineCode"],
          "languages": shopData["languages"],
          "shopName": shopData["shopName"],
          "language": shopData["language"],
          "shopAddress": shopData["shopAddress"],
          "shopTelephone": shopData["shopTelephone"],
          "businessTime": shopData["businessTime"],
        };
        Storage.setString("GanlanshopInfo", json.encode(ShopInfo));
        //2、保存商品信息
        List myList = response['data']['categoryVoList'];

        setState(() {
          for(var i=0; i<myList.length;i++){
            var categoryVoList = myList[i];
            if(categoryVoList['showType'] == "featured"){
              items = categoryVoList['menuVoList'];
              if(items.length >0){
                itemsFirst = items[0];

                if(items.length >1){
                  for(var m=0; m<items.length;m++){
                    if(m>0){
                      itemsTree.add(items[m]);
                    }
                  }

                }

              }
            }else if(categoryVoList['showType'] == "table"){
              itemstwo = categoryVoList['menuVoList'];
            }else if(categoryVoList['showType'] == "block"){
              itemsthree = categoryVoList['menuVoList'];
            }else if(categoryVoList['showType'] == "grid"){
              itemsfour = categoryVoList['menuVoList'];
            }
        }
        });

      } else {
        print('${response["msg"]}');
      }
    });
  }

  getAllPost() async {
    await sqlHelper.open();
    return await sqlHelper.queryAll();
  }

  deleteitem(id) async {
    await sqlHelper.delete(id);
    setState(() {});
  }

  //循环列表
/*  showItemList(items) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.8),
        itemBuilder: (BuildContext context, int index) {
          return showItemOne(items[index]);
        },
        itemCount: items.length,
      ),
    );
  }

  showItemOne(item) {
    Offset temp;

    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkWell(
          onTapDown: (details) {
            temp = new Offset(
                details.globalPosition.dx, details.globalPosition.dy);
          },
          onTap: () {
            //Navigator.push(
                //context,
                //MaterialPageRoute( builder: (context) => ItemDetailPage(itemId: item.id)));
            print(item);
            var result = controller.addToCart(item);
            print("8888888888888----$result");
            controller.getCardList();
          },
          child: Material(
            child: Container(
                height: ScreenAdapter.height(380),
                padding: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.rectangle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8.0)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: ScreenAdapter.height(180),
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                width: 30,
                                height: 50,
                                child: CachedNetworkImage(
                                  imageUrl: item.image,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            Container(
                              child: item.fav
                                  ? Icon(
                                      Icons.favorite,
                                      size: 20.0,
                                      color: Colors.red,
                                    )
                                  : Icon(
                                      Icons.favorite_border,
                                      size: 20.0,
                                    ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Text(
                        "${item.name}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Text(
                              "\$${item.price.toString()}",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )),
          )),
    );
  }

  getItemTotal(List<ShopItemModel> items) {
    double sum = 0.0;
    items.forEach((e) {
      sum += e.price;
    });
    return "\$$sum";
  }

  Widget generateCart(BuildContext context, ShopItemModel d) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white12,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade100, width: 1.0),
              top: BorderSide(color: Colors.grey.shade100, width: 1.0),
            )),
        height: 100.0,
        child: Row(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              height: 100.0,
              width: 100.0,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 5.0)
                  ],
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                  image: DecorationImage(
                      image: NetworkImage(d.image), fit: BoxFit.fitHeight)),
            ),
            Expanded(
                child: Padding(
              padding: EdgeInsets.only(top: 10.0, left: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          d.name,
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15.0),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        child: InkResponse(
                          onTap: () {
                            Get.find<HomePageController>()
                                .removeFromCart(d.shopId ?? 0);
                            print("Item removed from cart successfully");

                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text("Price ${d.price.toString()}"),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }*/

  //第一分类页面
  _showCategoryOne() {
    Offset temp;
    if(items.length >0){
      return Expanded(
          child: Container(
            color: ColorsUtil.hexToColor(Gcolor.mainBackground),
            height: ScreenAdapter.height(1480),
            child: ListView(
              children: [
                InkWell(
                  onTapDown: (details) {
                    temp = new Offset(
                        details.globalPosition.dx, details.globalPosition.dy);
                  },
                  onTap: () {
                    Function callback ;
                    setState(() {
                      OverlayEntry entry = OverlayEntry(
                          builder: (ctx){

                            return ParabolaAnimateWidget(rootKey,temp,floatOffset, Image(image:NetworkImage(itemsFirst['homeImage']),width:ScreenAdapter.width(60),fit: BoxFit.fitWidth,),callback, duration: 1000,);
                          }
                      );

                      callback = (status){
                        if(status == AnimationStatus.completed){
                          entry?.remove();
                        }
                      };
                      Overlay.of(rootKey.currentContext).insert(entry);
                    });


                    //加入刷新购物车
                    print(itemsFirst);
                    //var result = controller.addToCart(item);
                    //controller.getCardList();
                  },
                  child: Container(
                    width: ScreenAdapter.width(1080),
                    height: ScreenAdapter.height(680),
                    child: CachedNetworkImage(
                      imageUrl: itemsFirst['homeImage'],
                      fit: BoxFit.fill,
                      width: ScreenAdapter.width(1080),
                      height: ScreenAdapter.height(680),
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                          CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error),
                    ),
                  ),
                ),

                Container(
                  color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                  width: ScreenAdapter.width(1080),
                  height: ScreenAdapter.height(308),
                  padding: EdgeInsets.only(
                      left: ScreenAdapter.width(25), right: ScreenAdapter.width(25)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: '    STEP 1',
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22.0),
                                    fontWeight: FontWeight.w600,
                                    color:
                                    ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                                children: [
                                  TextSpan(
                                    text: " 麺の型が選び下さい",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(18.0),
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.mainTitleColor),
                                    ),
                                  ),
                                ]),
                          ),
                          RichText(
                            text: TextSpan(
                                text: itemsFirst['mainTitle'],
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(42.0),
                                    fontWeight: FontWeight.w600,
                                    color:
                                    ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                                children: [
                                  TextSpan(
                                    text: "  税込 ",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(35.0),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.mainTitleColor),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${itemsFirst['currentPrice'].toString()}",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(55.0),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                    ),
                                  ),
                                  TextSpan(
                                    text: " 円   ",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(28.0),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                    ),
                                  ),
                                ]),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              width: ScreenAdapter.width(257),
                              height: ScreenAdapter.height(108),
                              child: Image.asset('assets/images/ximian1.png')),
                          Container(
                              width: ScreenAdapter.width(257),
                              height: ScreenAdapter.height(108),
                              child: Image.asset('assets/images/zhongtai2.png')),
                          Container(
                              width: ScreenAdapter.width(257),
                              height: ScreenAdapter.height(108),
                              child: Image.asset('assets/images/sanjiao1.png')),
                          Container(
                              width: ScreenAdapter.width(257),
                              height: ScreenAdapter.height(108),
                              child: Image.asset('assets/images/pingmian1.png')),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: '    STEP 2',
                                style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(22.0),
                                    fontWeight: FontWeight.w600,
                                    color:
                                    ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                                children: [
                                  TextSpan(
                                    text: " 唐辛子無料追加、パクチーは1つ無料で、追加のは100円",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(18.0),
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.mainTitleColor),
                                    ),
                                  ),
                                  TextSpan(
                                      text: '        STEP 3',
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(22.0),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.mainTitleColor),
                                      )),
                                  TextSpan(
                                    text: " 麺の量をお選び下さい",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(18.0),
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.mainTitleColor),
                                    ),
                                  ),
                                ]),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              width: ScreenAdapter.width(257),
                              height: ScreenAdapter.height(108),
                              child: Image.asset('assets/images/xiangcai1.png')),
                          Container(
                              width: ScreenAdapter.width(257),
                              height: ScreenAdapter.height(108),
                              child: Image.asset('assets/images/lajiao1.png')),
                          Container(
                              width: ScreenAdapter.width(257),
                              height: ScreenAdapter.height(108),
                              child: Image.asset('assets/images/putong1.png')),
                          Container(
                              width: ScreenAdapter.width(257),
                              height: ScreenAdapter.height(108),
                              child: Image.asset('assets/images/dafen2.png')),
                        ],
                      ),
                    ],
                  ),
                ),
                //第二三个商品
                showCategoryOneItemList(itemsTree),
                /*Container(
                  color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                  width: ScreenAdapter.width(1080),
                  height: ScreenAdapter.height(482),
                  padding: EdgeInsets.only(
                      top: ScreenAdapter.height(10),
                      bottom: ScreenAdapter.height(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: ScreenAdapter.width(533),
                        //height: ScreenAdapter.height(480),
                        color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: ScreenAdapter.width(533),
                                //height: ScreenAdapter.height(361),
                                child: Image.asset('assets/images/22.png',
                                    width: ScreenAdapter.width(533),
                                    height: ScreenAdapter.height(361),
                                    fit: BoxFit.fill)),
                            Container(
                              padding: EdgeInsets.only(
                                left: ScreenAdapter.width(25),
                                right: ScreenAdapter.width(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '甘蘭拌麵',
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(
                                            GFontSize.mainFoodTitle),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.mainTitleColor)),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                        text: '  税込 ',
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(
                                              GFontSize.mainPriceLift),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "890",
                                            style: TextStyle(
                                              fontSize: ScreenAdapter.fontSize(
                                                  GFontSize.mainPrice),
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.priceColor),
                                            ),
                                          ),
                                          TextSpan(
                                            text: " 円",
                                            style: TextStyle(
                                              fontSize: ScreenAdapter.fontSize(
                                                  GFontSize.mainPriceRight),
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.priceColor),
                                            ),
                                          ),
                                        ]),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: ScreenAdapter.width(25),
                                right: ScreenAdapter.width(25),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                      width: ScreenAdapter.width(120),
                                      height: ScreenAdapter.height(55),
                                      child:
                                      Image.asset('assets/images/redPutong.png')),
                                  Container(
                                      width: ScreenAdapter.width(120),
                                      height: ScreenAdapter.height(55),
                                      child:
                                      Image.asset('assets/images/redDafen.png')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(12)),
                      Container(
                        width: ScreenAdapter.width(533),
                        //height: ScreenAdapter.height(480),
                        color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                width: ScreenAdapter.width(533),
                                //height: ScreenAdapter.height(361),
                                child: Image.asset('assets/images/22.png',
                                    width: ScreenAdapter.width(533),
                                    height: ScreenAdapter.height(361),
                                    fit: BoxFit.fill)),
                            Container(
                              //width: ScreenAdapter.width(1080),
                              //height: ScreenAdapter.height(315),
                              padding: EdgeInsets.only(
                                  left: ScreenAdapter.width(25),
                                  right: ScreenAdapter.width(25)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '甘蘭炒麺',
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(
                                            GFontSize.mainFoodTitle),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.mainTitleColor)),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                        text: '  税込 ',
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(
                                              GFontSize.mainPriceLift),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor),
                                        ),
                                        children: [
                                          TextSpan(
                                            text: "1280",
                                            style: TextStyle(
                                              fontSize: ScreenAdapter.fontSize(
                                                  GFontSize.mainPrice),
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.priceColor),
                                            ),
                                          ),
                                          TextSpan(
                                            text: " 円   ",
                                            style: TextStyle(
                                              fontSize: ScreenAdapter.fontSize(
                                                  GFontSize.mainPriceRight),
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.priceColor),
                                            ),
                                          ),
                                        ]),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: ScreenAdapter.width(25),
                                  //top: ScreenAdapter.height(20),
                                  right: ScreenAdapter.width(25)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: ScreenAdapter.width(80.0),
                                    height: ScreenAdapter.height(25.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      border: new Border.all(
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.foodTagColor),
                                          width: 0.5),
                                      // 边色与边宽度
                                      //设置圆角
                                      borderRadius: new BorderRadius.circular((8.0)),
                                    ),
                                    child: Text("300g",
                                        style: TextStyle(
                                            fontSize: ScreenAdapter.fontSize(16.0),
                                            color: ColorsUtil.hexToColor(
                                                Gcolor.foodTagColor))),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),*/
              ],
            ),
          ));
    }else{
      return Container(height: 0,);
    }

  }

  showCategoryOneItemList(items) {
    return Padding(
      padding: EdgeInsets.only(top:ScreenAdapter.height(8)),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 2, childAspectRatio: 1),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryOneItemOne(items[index]);
        },
        itemCount: itemsTree.length,
      ),
    );
  }

  showCategoryOneItemOne(item) {
    Offset temp;

    return Container(
      width: ScreenAdapter.width(533),
      //height: ScreenAdapter.height(480),
      color: ColorsUtil.hexToColor(Gcolor.whiteColor),
      child: InkWell(
          onTapDown: (details) {
            temp = new Offset(
                details.globalPosition.dx, details.globalPosition.dy);
          },
          onTap: () {
            Function callback ;
            setState(() {
              OverlayEntry entry = OverlayEntry(
                  builder: (ctx){

                    return ParabolaAnimateWidget(rootKey,temp,floatOffset, Image(image:NetworkImage(item['homeImage']),width:ScreenAdapter.width(60),fit: BoxFit.fitWidth,),callback, duration: 1000,);
                  }
              );

              callback = (status){
                if(status == AnimationStatus.completed){
                  entry?.remove();
                }
              };
              Overlay.of(rootKey.currentContext).insert(entry);
            });


            //加入刷新购物车
            print(item);
            //var result = controller.addToCart(item);
            //controller.getCardList();
          },
        child:Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: ScreenAdapter.width(533),
                //height: ScreenAdapter.height(361),
                child: Image.asset('assets/images/22.png',
                    width: ScreenAdapter.width(533),
                    height: ScreenAdapter.height(361),
                    fit: BoxFit.fill)),
            Container(
              padding: EdgeInsets.only(
                left: ScreenAdapter.width(25),
                right: ScreenAdapter.width(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item['mainTitle'],
                    overflow: TextOverflow.ellipsis, //长度溢出后显示省略号
                    style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(
                            GFontSize.mainFoodTitle),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(
                            Gcolor.mainTitleColor)),
                  ),
                  RichText(
                    text: TextSpan(
                        text: '  税込 ',
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.mainPriceLift),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor(
                              Gcolor.mainTitleColor),
                        ),
                        children: [
                          TextSpan(
                            text: item['currentPrice'].toString(),
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(
                                  GFontSize.mainPrice),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  Gcolor.priceColor),
                            ),
                          ),
                          TextSpan(
                            text: " 円",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(
                                  GFontSize.mainPriceRight),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  Gcolor.priceColor),
                            ),
                          ),
                        ]),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                left: ScreenAdapter.width(25),
                right: ScreenAdapter.width(25),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                      width: ScreenAdapter.width(120),
                      height: ScreenAdapter.height(55),
                      child:
                      Image.asset('assets/images/redPutong.png')),
                  Container(
                      width: ScreenAdapter.width(120),
                      height: ScreenAdapter.height(55),
                      child:
                      Image.asset('assets/images/redDafen.png')),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  //第二个分类
  _showCategoryTwo() {
    if(itemstwo.length >0){
      return Expanded(
          child: Container(
            color: ColorsUtil.hexToColor(Gcolor.mainBackground),
            //height: 450,
            child: showCategoryTwoItemList(itemstwo),
          )
      );
    }else{
      return Container(height: 0,);
    }

  }
  showCategoryTwoItemList(items) {
    return Padding(
      padding: EdgeInsets.only(top:ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: ScreenAdapter.height(10),crossAxisCount: 4, childAspectRatio: 0.68),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryTwoItemOne(items[index]);
        },
        itemCount: itemstwo.length,
      ),
    );
  }

  showCategoryTwoItemOne(item) {
    Offset temp;

    //标签循环相关
    var subtitleList = item["subtitle"];
    var labelSubtitleLength = subtitleList.length;
    List<Widget> labels = [];//先建一个数组用于存放循环生成的widget
    Widget labelContent;
    for (var i = 0; i < labelSubtitleLength; i++) {
      labels.add(
          Chip(
            label: Text(subtitleList[i],
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(GFontSize.menuTwoTitleTag),
                    color: ColorsUtil.hexToColor(Gcolor.foodTagColor))),
            labelPadding: EdgeInsets.only(right:ScreenAdapter.width(5), bottom:ScreenAdapter.height(0),left:ScreenAdapter.width(5), top: ScreenAdapter.height(0)),
            padding:EdgeInsets.only(right:ScreenAdapter.width(5), bottom:ScreenAdapter.height(0),left:ScreenAdapter.width(5), top: ScreenAdapter.height(0)),
            shape: new RoundedRectangleBorder(
              side: new BorderSide(
                //设置 界面效果
                  color: ColorsUtil.hexToColor(Gcolor.foodTagColor),
                  style: BorderStyle.solid,
                  width: 0.5
              ),
            ),
            backgroundColor:Colors.white70,
          )
      );
    }
    labelContent = new Wrap(
        spacing: ScreenAdapter.width(5), // set spacing here
        runSpacing: ScreenAdapter.height(-20),
        children: labels
    );

    return Container(
      padding: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
      child: GestureDetector(
          onPanDown: (details){
            temp = new Offset(details.globalPosition.dx, details.globalPosition.dy);
          },
          onTap: () {
            Function callback ;
            setState(() {
              OverlayEntry entry = OverlayEntry(
                  builder: (ctx){

                    return ParabolaAnimateWidget(rootKey,temp,floatOffset, Image(image:NetworkImage(item['homeImage']),width:ScreenAdapter.width(60),fit: BoxFit.fitWidth,),callback, duration: 1000,);
                  }
              );

              callback = (status){
                if(status == AnimationStatus.completed){
                  entry?.remove();
                }
              };
              Overlay.of(rootKey.currentContext).insert(entry);
            });


            //加入刷新购物车
            print(item);
            //var result = controller.addToCart(item);
            //controller.getCardList();
          },
          child: Material(
            child: Container(
                //height: ScreenAdapter.height(280),
                color: ColorsUtil.hexToColor(Gcolor.whiteColor),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: ScreenAdapter.width(350),
                      height: ScreenAdapter.height(255),
                      child: CachedNetworkImage(
                        imageUrl: item['homeImage'],
                        fit: BoxFit.fill,
                        width: ScreenAdapter.width(350),
                        height: ScreenAdapter.height(255),
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error),
                      ),
                    ),
                    SizedBox(
                      height: ScreenAdapter.height(10),
                    ),
                    Container(
                      //width: ScreenAdapter.width(20),
                      //height: ScreenAdapter.height(315),
                      padding: EdgeInsets.only(
                          left: ScreenAdapter.width(15),
                          right: ScreenAdapter.width(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              item['mainTitle'],
                              overflow: TextOverflow.ellipsis, //长度溢出后显示省略号
                              style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(
                                      GFontSize.menuTwoListTitle),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.mainTitleColor)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      //width: ScreenAdapter.width(20),
                      //height: ScreenAdapter.height(315),
                      padding: EdgeInsets.only(
                          left: ScreenAdapter.width(15),
                          right: ScreenAdapter.width(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: '税込 ',
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(
                                      GFontSize.menuTwopriceLift),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.mainTitleColor),
                                ),
                                children: [
                                  TextSpan(
                                    text: item['currentPrice'].toString(),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(
                                          GFontSize.menuTwoprice),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.priceColor),
                                    ),
                                  ),
                                  TextSpan(
                                    text: " 円",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(
                                          GFontSize.menuTwopriceRight),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.priceColor),
                                    ),
                                  ),
                                ]),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: ScreenAdapter.height(7),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: ScreenAdapter.width(15),
                          //top: ScreenAdapter.height(20),
                          right: ScreenAdapter.width(15)),
                      child: labelContent,
                    ),
                  ],
                )),
          )),
    );
  }




  //第三个分类
  _showCategoryThree() {
    if(itemsthree.length>0){
      return Expanded(
          child: Column(
            children: [
              Container(
                width: ScreenAdapter.width(1080),
                alignment: Alignment.bottomLeft,
                color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                padding: EdgeInsets.only(left: ScreenAdapter.width(30), top: ScreenAdapter.height(40), bottom: ScreenAdapter.height(20)),
                child: RichText(
                  text: TextSpan(
                      text: '定食メニュ ',
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(
                            GFontSize.menuThreeListTitle),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(
                            Gcolor.mainTitleColor),
                      ),
                      children: [
                        TextSpan(
                          text: "（11：00-14：00）",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(
                                GFontSize.menuThreeListTag),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor(
                                Gcolor.mainTitleColor),
                          ),
                        ),
                      ]),
                ),
              ),
              Expanded(
                  child: Container(
                    color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                    padding: EdgeInsets.only(left: ScreenAdapter.width(15), right: ScreenAdapter.width(15), bottom: ScreenAdapter.height(20)),
                    //height: 450,
                    child: showCategoryThreeItemList(itemsthree),
                  )
              ),
            ],
          )
      );
    }else{
      return Container(height: 0,);
    }

  }
  showCategoryThreeItemList(items) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return showCategoryThreeItemOne(items[index]);
        },
        itemCount: itemsthree.length,
      ),
    );
  }

  showCategoryThreeItemOne(item) {
    Offset temp;

    var subtitle = "";
    if(item["subtitle"].length > 0){
      for(var i=0; i<item["subtitle"].length;i++){
        subtitle += item["subtitle"][i];
      }
    }


    return Container(
      padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
      child: InkWell(
          onTapDown: (details) {
            temp = new Offset(
                details.globalPosition.dx, details.globalPosition.dy);
          },
          onTap: () {
            Function callback ;
            setState(() {
              OverlayEntry entry = OverlayEntry(
                  builder: (ctx){

                    return ParabolaAnimateWidget(rootKey,temp,floatOffset, Image(image:NetworkImage(item['homeImage']),width:ScreenAdapter.width(60),fit: BoxFit.fitWidth,),callback, duration: 1000,);
                  }
              );

              callback = (status){
                if(status == AnimationStatus.completed){
                  entry?.remove();
                }
              };
              Overlay.of(rootKey.currentContext).insert(entry);
            });


            print(item);
            //var result = controller.addToCart(item);
            //controller.getCardList();
          },
          child: Material(
            child: Container(
              //height: ScreenAdapter.height(280),
                color: ColorsUtil.hexToColor(Gcolor.whiteColor),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: ScreenAdapter.width(485),
                        height: ScreenAdapter.height(315),
                        child: CachedNetworkImage(
                        imageUrl: item['homeImage'],
                          fit: BoxFit.fill,
                          width: ScreenAdapter.width(485),
                          height: ScreenAdapter.height(315),
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error),
                      ),
                    ),

                    Container(
                      //width: ScreenAdapter.width(1080),
                      //height: ScreenAdapter.height(315),
                      //padding: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(10)),
                      child: Column(
                        children: [
                          //标题
                          Container(
                            width: ScreenAdapter.width(560),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item['mainTitle'],
                                  overflow: TextOverflow.ellipsis, //长度溢出后显示省略号
                                  style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(
                                          GFontSize.menuThreeListFoodTitle),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.mainTitleColor)),
                                ),
                                SizedBox(
                                  width: ScreenAdapter.width(150),
                                ),
                                Container(
                                    width: ScreenAdapter.width(80),
                                    height: ScreenAdapter.height(80),
                                    child:Image.asset(
                                      'assets/images/dingshitag11.png',
                                      fit: BoxFit.fitWidth,
                                    )
                                ),
                                SizedBox(
                                  width: ScreenAdapter.width(50),
                                ),
                              ],
                            ),
                          ),
                          //副标题
                          subtitle !="" ?Container(
                            alignment: Alignment.center,
                            child: Text(
                              '（${subtitle}）',
                              style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(
                                      GFontSize.menuThreeListFoodSubtitle),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.mainTitleColor)),
                            ),
                          ):Container(
                            width: 0,
                          ),
                          //价格
                          Container(
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                  text: '税込 ',
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(
                                        GFontSize.menuThreepriceLift),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(
                                        Gcolor.mainTitleColor),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "${item["currentPrice"].toString()}",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(
                                            GFontSize.menuThreeprice),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.priceColor),
                                      ),
                                    ),
                                    TextSpan(
                                      text: " 円",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(
                                            GFontSize.menuThreepriceRight),
                                        fontWeight: FontWeight.w600,
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.priceColor),
                                      ),
                                    ),
                                  ]),
                            ),
                          ),
                          //多选择口味等
                          Container(
                            color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                            width: ScreenAdapter.width(560),
                            height: ScreenAdapter.height(165),
                            //padding: EdgeInsets.only( left: ScreenAdapter.width(25), right: ScreenAdapter.width(25)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                          text: '    STEP 1',
                                          style: TextStyle(
                                              fontSize: ScreenAdapter.fontSize(12.0),
                                              fontWeight: FontWeight.w600,
                                              color:
                                              ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                                          children: [
                                            TextSpan(
                                              text: " 麺の型が選び下さい",
                                              style: TextStyle(
                                                fontSize: ScreenAdapter.fontSize(11.0),
                                                color: ColorsUtil.hexToColor(
                                                    Gcolor.mainTitleColor),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                        width: ScreenAdapter.width(140),
                                        height: ScreenAdapter.height(59),
                                        child: Image.asset('assets/images/dingshiximian1.png')),
                                    Container(
                                        width: ScreenAdapter.width(140),
                                        height: ScreenAdapter.height(59),
                                        child: Image.asset('assets/images/dingshizhongtai2.png')),
                                    Container(
                                        width: ScreenAdapter.width(140),
                                        height: ScreenAdapter.height(59),
                                        child: Image.asset('assets/images/dingshisanjiao1.png')),
                                    Container(
                                        width: ScreenAdapter.width(140),
                                        height: ScreenAdapter.height(59),
                                        child: Image.asset('assets/images/dingshipingmian1.png')),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                          text: '    STEP 2',
                                          style: TextStyle(
                                              fontSize: ScreenAdapter.fontSize(12.0),
                                              fontWeight: FontWeight.w600,
                                              color:
                                              ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                                          children: [
                                            TextSpan(
                                              text: " 唐辛子無料追加、パクチーは1つ無料で、追加のは100円",
                                              style: TextStyle(
                                                fontSize: ScreenAdapter.fontSize(11.0),
                                                color: ColorsUtil.hexToColor(
                                                    Gcolor.mainTitleColor),
                                              ),
                                            ),
                                            TextSpan(
                                                text: '        STEP 3',
                                                style: TextStyle(
                                                  fontSize: ScreenAdapter.fontSize(12.0),
                                                  fontWeight: FontWeight.w600,
                                                  color: ColorsUtil.hexToColor(
                                                      Gcolor.mainTitleColor),
                                                )),
                                            TextSpan(
                                              text: " 麺の量をお選び下さい",
                                              style: TextStyle(
                                                fontSize: ScreenAdapter.fontSize(11.0),
                                                color: ColorsUtil.hexToColor(
                                                    Gcolor.mainTitleColor),
                                              ),
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                        width: ScreenAdapter.width(140),
                                        height: ScreenAdapter.height(59),
                                        child: Image.asset('assets/images/dingshixiangcai1.png')),
                                    Container(
                                        width: ScreenAdapter.width(140),
                                        height: ScreenAdapter.height(59),
                                        child: Image.asset('assets/images/dingshilajiao2.png')),
                                    Container(
                                        width: ScreenAdapter.width(140),
                                        height: ScreenAdapter.height(59),
                                        child: Image.asset('assets/images/dingshiputong2.png')),
                                    Container(
                                        width: ScreenAdapter.width(140),
                                        height: ScreenAdapter.height(59),
                                        child: Image.asset('assets/images/dingshidafen1.png')),
                                  ],
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),

                  ],
                )),
          )),
    );
  }

  //第四个酒水分类
  _showCategoryFour() {
    if(itemsfour.length >0){
      return Expanded(
          child: Container(
            color: ColorsUtil.hexToColor(Gcolor.mainBackground),
            //height: 450,
            child: showCategoryFourItemList(controller.itemsfour),
          )
      );
    }else{
      return Container(height: 0,);
    }

  }
  showCategoryFourItemList(items) {
    return Padding(
      padding: EdgeInsets.only(top:ScreenAdapter.height(8),left: ScreenAdapter.width(45), right: ScreenAdapter.width(45)),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 4, childAspectRatio: 0.42),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryFourItemOne(itemsfour[index]);
        },
        itemCount: itemsfour.length,
      ),
    );
  }

  showCategoryFourItemOne(item) {
    Offset temp;

    return Container(
      padding: EdgeInsets.only(left: ScreenAdapter.width(9),right: ScreenAdapter.width(9)),
      child: InkWell(
          onTapDown: (details) {
            temp = new Offset(
                details.globalPosition.dx, details.globalPosition.dy);
          },
          onTap: () {
            Function callback ;
            setState(() {
              OverlayEntry entry = OverlayEntry(
                  builder: (ctx){

                    return ParabolaAnimateWidget(rootKey,temp,floatOffset, Image(image:NetworkImage(item['homeImage']),width:ScreenAdapter.width(60),fit: BoxFit.fitWidth,),callback, duration: 1000,);
                  }
              );

              callback = (status){
                if(status == AnimationStatus.completed){
                  entry?.remove();
                }
              };
              Overlay.of(rootKey.currentContext).insert(entry);
            });


            print(item);
            //var result = controller.addToCart(item);
            //controller.getCardList();
          },
          child: Material(
            child: Container(
              //height: ScreenAdapter.height(280),
                color: ColorsUtil.hexToColor(Gcolor.whiteColor),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        width: ScreenAdapter.width(230),
                        height: ScreenAdapter.height(523),
                        child: CachedNetworkImage(
                        imageUrl: item['homeImage'],
                          fit: BoxFit.fill,
                          width: ScreenAdapter.width(230),
                          height: ScreenAdapter.height(523),
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                            CircularProgressIndicator(
                                value: downloadProgress.progress),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error),
                      ),
                    ),
                    SizedBox(
                      height: ScreenAdapter.height(10),
                    ),
                    Container(
                      //width: ScreenAdapter.width(1080),
                      //height: ScreenAdapter.height(315),
                      padding: EdgeInsets.only(
                          left: ScreenAdapter.width(15),
                          right: ScreenAdapter.width(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            item['mainTitle'],
                            overflow: TextOverflow.ellipsis, //长度溢出后显示省略号
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(
                                    GFontSize.menuFourListTitle),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(
                                    Gcolor.mainTitleColor)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          left: ScreenAdapter.width(15),
                          //top: ScreenAdapter.height(20),
                          right: ScreenAdapter.width(15)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          RichText(
                            text: TextSpan(
                                text: '税込 ',
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(
                                      GFontSize.menuFourpriceLift),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.mainTitleColor),
                                ),
                                children: [
                                  TextSpan(
                                    text: item['currentPrice'].toString(),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(
                                          GFontSize.menuFourprice),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.priceColor),
                                    ),
                                  ),
                                  TextSpan(
                                    text: " 円",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(
                                          GFontSize.menuFourpriceRight),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.priceColor),
                                    ),
                                  ),
                                ]),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
          )),
    );
  }

  //购物车
  _showShoppingCart() {

    return Container(
      color: ColorsUtil.hexToColor(Gcolor.whiteColor),
      width: ScreenAdapter.width(1080),
      height: ScreenAdapter.height(320),
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(20),
          top: ScreenAdapter.height(10),
          right: ScreenAdapter.width(20),
          bottom: ScreenAdapter.height(10)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container(
            key: floatKey,
            height: ScreenAdapter.height(272),
            child: Row(
              children: [
                Container(
                  width: ScreenAdapter.width(630),
                  height: ScreenAdapter.height(272),
                  color: ColorsUtil.hexToColor(Gcolor.cartListColor),
                  child: GetBuilder<HomePageController>(
                    builder: (_) {
                      if (controller.cartItems.length == 0) {
                        return Center(
                          child: Text("请选择菜品"),
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
                ),
                Container(
                  width: ScreenAdapter.width(58),
                  height: ScreenAdapter.height(272),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset('assets/images/up.png',
                          width: ScreenAdapter.width(58),
                          height: ScreenAdapter.height(58),
                          fit: BoxFit.fitWidth),
                      Image.asset('assets/images/down.png',
                          width: ScreenAdapter.width(58),
                          height: ScreenAdapter.height(58),
                          fit: BoxFit.fitWidth)
                    ],
                  ),
                ),
              ],
            ),
          )),

          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: (){
                    showDialogTag();
                    //Get.find<HomePageController>().removeAllFromCart();
                    print("Item removed from cart successfully");
                  },
                  child: Container(
                    width: ScreenAdapter.width(319),
                    height: ScreenAdapter.height(117),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      image: new DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage('assets/images/btn001.png'),
                      ),
                      //设置圆角
                      borderRadius: new BorderRadius.circular((16.0)),
                    ),
                    child: Text("すべてキャンセル",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(36),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                        )),
                  ),
                ),

                SizedBox(height:ScreenAdapter.height(18)),
                InkWell(
                  onTap:(){
                    Navigator.pushNamed(context, '/settlement');
                  },
                  child: Container(
                    width: ScreenAdapter.width(319),
                    height: ScreenAdapter.height(117),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      image: new DecorationImage(
                        fit: BoxFit.fitWidth,
                        image: AssetImage('assets/images/btn002.png'),
                      ),
                      //设置圆角
                      borderRadius: new BorderRadius.circular((16.0)),
                    ),
                    child: Text("お会計",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(48),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget generateCartList(BuildContext context, ShopItemModel d) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white12,
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 1.0),
              top: BorderSide(color: Colors.grey.shade100, width: 1.0),
            )),
        //height: ScreenAdapter.height(80),
        child: Row(
          children: <Widget>[
            InkResponse(
              onTap: (){
                Get.find<HomePageController>()
                    .removeFromCart(d.shopId ?? 0);
                print("Item removed from cart successfully");
              },
              child: Container(
                width: ScreenAdapter.width(40),
                child: Image.asset('assets/images/delOne.png',
                    width: ScreenAdapter.width(30),
                    //height: ScreenAdapter.height(44),
                    fit: BoxFit.fill),
              ),
            ),
            Expanded(child: Container(
              padding: EdgeInsets.only(left:ScreenAdapter.width(5),top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
              width: ScreenAdapter.width(495),
              child: RichText(
                text: TextSpan(
                    text: d.name,
                    style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(GFontSize.cartListTitle),
                        fontWeight: FontWeight.w600,
                        color:
                        ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                    children: [
                      TextSpan(
                        text: " X1",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(GFontSize.cartListTitleCount),
                          color: ColorsUtil.hexToColor(
                              Gcolor.mainTitleColor),
                        ),
                      ),
                      TextSpan(
                        text: "（中太麵、大盛(130g)、香菜普通、唐辛子無し）",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(GFontSize.cartListTitleTag),
                          color: ColorsUtil.hexToColor(
                              Gcolor.mainTitleColor),
                        ),
                      ),
                    ]),
              ),
            )),
            Container(
              width: ScreenAdapter.width(120),
              child: Text(
                d.price.toString(),
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(GFontSize.mainPriceRight),
                    fontWeight: FontWeight.w600,
                    color:
                    ColorsUtil.hexToColor(Gcolor.mainTitleColor)
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  //清空购物车弹出提示、
  showDialogTag(){
    AppTool().showCenterTipsAlter(context, _clearCartList, "温馨提示", "您确定要清空购物车?", "确定", "取消");
  }

  void _clearCartList(value) async {
    Get.find<HomePageController>().removeAllFromCart();

    controller.getCardList();
    //Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: Column(
          key: rootKey,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: ScreenAdapter.getScreenWidth(),
              height: ScreenAdapter.height(120),
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                color: ColorsUtil.hexToColor("#000000"),
              ),
              child: Row(
                children: [
                  SizedBox(width: ScreenAdapter.width(30)),
                  InkWell(
                    onTap: () {
                      setState(() {
                        classTag = 1;
                      });
                    },
                    child: Container(
                      width: ScreenAdapter.width(161),
                      height: ScreenAdapter.height(65),
                      decoration: BoxDecoration(
                        image: new DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: classTag == 1
                              ? AssetImage(
                                  'assets/images/category_selected.png')
                              : AssetImage(
                                  'assets/images/category_unselected.png'),
                        ),
                      ),
                      child: Center(
                        //加上Center让文字居中
                        child: Text(
                          '麺',
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(
                                  GFontSize.categoryTitle),
                              color: classTag == 1
                                  ? ColorsUtil.hexToColor(
                                      Gcolor.categoryTitleSelected)
                                  : ColorsUtil.hexToColor(Gcolor.categoryTitle),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(10)),
                  InkWell(
                    onTap: () {
                      setState(() {
                        classTag = 2;
                      });
                    },
                    child: Container(
                      width: ScreenAdapter.width(161),
                      height: ScreenAdapter.height(65),
                      decoration: BoxDecoration(
                        image: new DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: classTag == 2
                              ? AssetImage(
                                  'assets/images/category_selected.png')
                              : AssetImage(
                                  'assets/images/category_unselected.png'),
                        ),
                      ),
                      child: Center(
                        //加上Center让文字居中
                        child: Text(
                          '小皿中華',
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(
                                  GFontSize.categoryTitle),
                              color: classTag == 2
                                  ? ColorsUtil.hexToColor(
                                      Gcolor.categoryTitleSelected)
                                  : ColorsUtil.hexToColor(Gcolor.categoryTitle),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(10)),
                  InkWell(
                    onTap: () {
                      setState(() {
                        classTag = 3;
                      });
                    },
                    child: Container(
                      width: ScreenAdapter.width(161),
                      height: ScreenAdapter.height(65),
                      decoration: BoxDecoration(
                        image: new DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: classTag == 3
                              ? AssetImage(
                                  'assets/images/category_selected.png')
                              : AssetImage(
                                  'assets/images/category_unselected.png'),
                        ),
                      ),
                      child: Center(
                        //加上Center让文字居中
                        child: Text(
                          '定食',
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(
                                  GFontSize.categoryTitle),
                              color: classTag == 3
                                  ? ColorsUtil.hexToColor(
                                      Gcolor.categoryTitleSelected)
                                  : ColorsUtil.hexToColor(Gcolor.categoryTitle),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(10)),
                  InkWell(
                    onTap: () {
                      setState(() {
                        classTag = 4;
                      });
                    },
                    child: Container(
                      width: ScreenAdapter.width(161),
                      height: ScreenAdapter.height(65),
                      decoration: BoxDecoration(
                        image: new DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: classTag == 4
                              ? AssetImage(
                                  'assets/images/category_selected.png')
                              : AssetImage(
                                  'assets/images/category_unselected.png'),
                        ),
                      ),
                      child: Center(
                        //加上Center让文字居中
                        child: Text(
                          '飲み物',
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(
                                  GFontSize.categoryTitle),
                              color: classTag == 4
                                  ? ColorsUtil.hexToColor(
                                      Gcolor.categoryTitleSelected)
                                  : ColorsUtil.hexToColor(Gcolor.categoryTitle),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: ScreenAdapter.width(80)),
                  Container(
                    alignment: Alignment.centerRight,
                    width: ScreenAdapter.width(243),
                    height: ScreenAdapter.height(64),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ],
              ),
            ),
            (classTag == 1)
                ? _showCategoryOne()
                /*Container(
                    key: rootKey,
                    height: 450,
                    child: GetBuilder<HomePageController>(
                      init: controller,
                      builder: (_) => showItemList(controller.items),
                    ),
                  )*/
                : Container(
                    height: 0,
                  ),
            (classTag == 2)
                ? _showCategoryTwo()/*Container(
                    height: 450,
                    child: GetBuilder<HomePageController>(
                      init: controller,
                      builder: (_) => showItemList(controller.itemstwo),
                    ),
                  )*/
                : Container(
                    height: 0,
                  ),
            (classTag == 3)
                ? _showCategoryThree()/*Container(
                    height: 450,
                    child: GetBuilder<HomePageController>(
                      init: controller,
                      builder: (_) => showItemList(controller.itemsthree),
                    ),
                  )*/
                : Container(
                    height: 0,
                  ),
            (classTag == 4)
                ? _showCategoryFour()/*Container(
                    height: 450,
                    child: GetBuilder<HomePageController>(
                      init: controller,
                      builder: (_) => showItemList(controller.itemsfour),
                    ),
                  )*/
                : Container(
                    height: 0,
                  ),

            //展示购物车
            _showShoppingCart(),

            //购物车价格总数
            /*Container(
              color: Colors.white,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(child: GetBuilder<HomePageController>(
                      builder: (_) {
                        return RichText(
                          text: TextSpan(
                              text: "Total  ",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                              children: <TextSpan>[
                                TextSpan(
                                    text: getItemTotal(controller.cartItems)
                                        .toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                              ]),
                        );
                      },
                    )),
   
                  ],
                ),
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
