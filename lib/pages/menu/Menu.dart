import 'package:add_cart_parabola/add_cart_parabola.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/config/index.dart';
import 'package:foodorder/controller/homePageController.dart';
import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/SqfliteHelper.dart';
import 'package:foodorder/services/itemService.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MenuPage extends StatefulWidget {
  MenuPage({Key key}) : super(key: key);

  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  var imgUrl =
      'https://kanran.co.jp/fanxing/sites/6/2021/10/1635210298859_1026-1024x1024.jpg';

  ItemServices itemServices = ItemServices();
  List<ShopItemModel> items = [];
  List<ShopItemModel> itemstwo = [];
  List<ShopItemModel> itemsthree = [];
  List<ShopItemModel> itemsfour = [];
  final HomePageController controller = Get.put(HomePageController());
  int classTag = 1;

  final sqlHelper = SqfliteHelper();

  //购物车抛物线
  GlobalKey floatKey = GlobalKey();
  GlobalKey rootKey = GlobalKey();
  Offset floatOffset;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox renderBox = floatKey.currentContext.findRenderObject();
      floatOffset = renderBox.localToGlobal(Offset.zero);
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
  showItemList(items) {
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
            /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ItemDetailPage(itemId: item.id)));*/
            print(item);
            var result = controller.addToCart(item);
            print("8888888888888----$result");
            controller.getCardList();

            Function callback;
            setState(() {
              OverlayEntry entry = OverlayEntry(builder: (ctx) {
//                RenderBox renderBox = itemKey.currentContext.findRenderObject();
//                Offset itemOffset = renderBox.localToGlobal(Offset.zero,
//                    ancestor: rootKey.currentContext.findRenderObject());
//                print("item offset  :${itemOffset.toString()}    float offset"
//                    " ${floatOffset.toString()}");
                /// root key：根widget key， 主要用于定位
                /// temp:点击坐标，开始位置。floatOffset 结束坐标
                ///Icon：传入想弹出的widget
                ///call back: 会回传一个动画执行状态
                ///duration： 动画时间 可选，默认1秒
                ///
                return ParabolaAnimateWidget(rootKey, temp, floatOffset,
                  Icon(
                    Icons.cancel,
                    color: Colors.greenAccent,
                  ),
                  callback,
                );
              });

              callback = (status) {
                if (status == AnimationStatus.completed) {
                  entry?.remove();
                }
              };

              Overlay.of(rootKey.currentContext).insert(entry);
            });
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
                                width:30,
                                height: 50,
                                child: CachedNetworkImage(
                                  imageUrl: item.image,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
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
                            /*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        "Item removed from cart successfully"))
                                );*/
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*floatingActionButton: FloatingActionButton(
        child: Icon(Icons.http),
        onPressed: (){
          loaddata();
        },

      ),*/
      /*body: FutureBuilder(
        future: getAllPost(),
        builder: (context, snap){
          if(snap.hasData){
            List l = snap.data;
            return ListView.builder(
                itemCount: l.length,
                itemBuilder: (context, idx){
                  return InkWell(
                    onTap: (){
                      deleteitem(l[idx]['id']);
                    },
                    child: ListTile(title: Text(l[idx]['title']),),
                  );
                });
          }
        },),*/
      body: ListView(
        children: [
          Container(
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      classTag = 1;
                    });
                  },
                  child: Container(
                    width: ScreenAdapter.width(145),
                    height: ScreenAdapter.height(60),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: classTag == 1 ? Colors.red : Colors.redAccent),
                    child: Center(
                      //加上Center让文字居中
                      child: Text(
                        '面',
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(40.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      classTag = 2;
                    });
                  },
                  child: Container(
                    width: ScreenAdapter.width(145),
                    height: ScreenAdapter.height(60),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            classTag == 2 ? Colors.green : Colors.greenAccent),
                    child: Center(
                      //加上Center让文字居中
                      child: Text(
                        '料理',
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(40.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      classTag = 3;
                    });
                  },
                  child: Container(
                    width: ScreenAdapter.width(145),
                    height: ScreenAdapter.height(60),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: classTag == 3 ? Colors.blue : Colors.blueAccent),
                    child: Center(
                      //加上Center让文字居中
                      child: Text(
                        '定时',
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(40.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      classTag = 4;
                    });
                  },
                  child: Container(
                    width: ScreenAdapter.width(145),
                    height: ScreenAdapter.height(60),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            classTag == 4 ? Colors.limeAccent : Colors.amber),
                    child: Center(
                      //加上Center让文字居中
                      child: Text(
                        '饮料',
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(40.0),
                            color: Colors.white,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          (classTag == 1)
              ? Container(
                  key: rootKey,
                  height: 450,
                  child: GetBuilder<HomePageController>(
                    init: controller,
                    builder: (_) => showItemList(controller.items),
                  ),
                )
              : Container(
                  height: 0,
                ),
          (classTag == 2)
              ? Container(
                  key: rootKey,
                  height: 450,
                  child: GetBuilder<HomePageController>(
                    init: controller,
                    builder: (_) => showItemList(controller.itemstwo),
                  ),
                )
              : Container(
                  height: 0,
                ),
          (classTag == 3)
              ? Container(
                  key: rootKey,
                  height: 450,
                  child: GetBuilder<HomePageController>(
                    init: controller,
                    builder: (_) => showItemList(controller.itemsthree),
                  ),
                )
              : Container(
                  height: 0,
                ),
          (classTag == 4)
              ? Container(
                  key: rootKey,
                  height: 450,
                  child: GetBuilder<HomePageController>(
                    init: controller,
                    builder: (_) => showItemList(controller.itemsfour),
                  ),
                )
              : Container(
                  height: 0,
                ),
//购物车
          Row(
            children: [
              Container(
                key: floatKey,
                height: 200,
                width: ScreenAdapter.width(550),
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
                          .map((d) => generateCart(context, d))
                          .toList(),
                    );
                  },
                ),
              ),
              Text("加入"),
            ],
          ),

          //购物车价格总数
          Container(
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
                            style: TextStyle(color: Colors.black, fontSize: 18),
                            children: <TextSpan>[
                              TextSpan(
                                  text: getItemTotal(controller.cartItems)
                                      .toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ]),
                      );
                    },
                  )),
                  /*Container(
                    alignment: Alignment.centerLeft,
                    height: 50,
                    color: Colors.white,
                    child: ElevatedButton(
                        onPressed: () {},
                        child: Container(
                          alignment: Alignment.center,
                          height: 40,
                          width: 100,
                          child: Text("Checkout", style: TextStyle(fontSize: 18),),
                        )
                    ),
                  )*/
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
/*
class ShopItemListing extends StatelessWidget {
  final List<ShopItemModel> items;

  ShopItemListing({this.items});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.8),
        itemBuilder: (BuildContext context, int index) {
          return ItemView(
            item: items[index],
          );
        },
        itemCount: items.length,
      ),
    );
  }
}

class ItemView extends StatelessWidget {
  final ShopItemModel item;

  ItemView({this.item});
  final HomePageController controller = Get.put(HomePageController());
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: InkResponse(
          onTap: () async {
            */ /*Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ItemDetailPage(itemId: item.id)));*/ /*

            var result = await controller.addToCart(item);print("8888888888888----$result");
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
                                child: CachedNetworkImage(
                                  imageUrl: item.image,
                                  progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator( value: downloadProgress.progress),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
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
}*/
