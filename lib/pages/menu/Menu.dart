
import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/fontSize.dart';
import 'package:foodorder/config/index.dart';
import 'package:foodorder/controller/homePageController.dart';
import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/routers/custom_router.dart';
import 'package:foodorder/services/CachedNetworkImageManager.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/SqfliteHelper.dart';
import 'package:foodorder/services/addCartParabola.dart';
import 'package:foodorder/services/itemService.dart';
import 'package:foodorder/services/logUtil.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/widget/LoadState.dart';
import 'package:foodorder/widget/iosAlter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:foodorder/services/Storage.dart';

class MenuPage extends StatefulWidget {
  Map arguments;

  MenuPage({Key key, this.arguments}) : super(key: key);

  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>  with AutomaticKeepAliveClientMixin {

  bool get wantKeepAlive =>true;

  var _alignmentY = -1.0;


  Storage storageService = Storage();

  ItemServices itemServices = ItemServices();
  List topMenu = [];
  Map showItem = {};

  HomePageController controller = Get.put(HomePageController());
  var classTag;

  //默认语言包选择
  var _checkLanguage = "JP";


  //购物车抛物线
  GlobalKey rootKey = GlobalKey();
  Offset floatOffset;

  String _machineCode = "";

  var _menuOption = {}; //牛肉面及定食的option数组
  var _noChangeinitialmenuOption = {}; //牛肉面及定食的option数组，不做改变
  var _initialMenuOption = {}; //牛肉面及定食的初始option数组
  var _selectedMenuOptionList = {}; //牛肉面选中的option组成的数组
  var _selectedMenuOptionCheckedNum = {}; //牛肉面默认选中的option 数量

  var _selectedMenuOptionChangePrice = {}; //牛肉面默认选中的option 价格
  var _addselectedMenuOptionChangePrice = {}; //牛肉面默认选中的option 需要增加的加个


  var _shopCartTotalPrice = "0";
  var cartnum = 6;


  @override
  void initState() {
    super.initState();

    this._checkLanguage = widget.arguments['checkLanguage'];
    _getMachineInfo();


    getCartPriceTotal();



    EasyLoading.dismiss();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    eventBus.fire(new clearCartEvent('支付成功...'));
    super.dispose();

  }




  //页面加载状态，默认为加载中
  LoadState _layoutState = LoadState.State_Loading;

  Widget _listView(BuildContext context) {
    return LoadStateLayout(
      state: _layoutState,
      emptyRetry: () {
        setState(() {
          _layoutState = LoadState.State_Empty;
        });
        this._getBookingBootMenu();
      },
      errorRetry: () {
        setState(() {
          _layoutState = LoadState.State_Error;
        });
        this._getBookingBootMenu();
      }, //错误按钮点击过后进行重新加载
      successWidget: Column(
        key: rootKey,
        children: [
          //顶部导航
          Container(
            width: ScreenAdapter.getScreenWidth(),
            height: ScreenAdapter.height(95),
            padding: EdgeInsets.only(left: ScreenAdapter.width(10), right: ScreenAdapter.width(20)),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: ColorsUtil.hexToColor("#000000"),
              image: new DecorationImage(
                alignment: Alignment.centerRight,
                fit: BoxFit.fitHeight,
                image: AssetImage('assets/images/logo.png'),
              ),
            ),
            child: showTopCategoryMenu(),
          ),

          Expanded(
              child: Container(
            color: ColorsUtil.hexToColor(Gcolor.mainBackground),
            height: ScreenAdapter.height(1480),
            child: showMiddleMenuList(),
          )),

          _showShoppingCart(),
          //_showShoppingCartBottom(),

        ],
      ),
    );
  }

  //获取机器信息
  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      setState(() {
        _machineCode = machineCode;
      });
      _getBookingBootMenu();
    }
  }

  //获取菜单
  _getBookingBootMenu() {
    var formData = {
      "machineCode": _machineCode,
      "language": this._checkLanguage
    };
    request('webBootIndex', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200) {
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
          for (var i = 0; i < myList.length; i++) {
            var categoryVoList = myList[i];
            //配置顶部菜单
            topMenu.add({
              "categoryCode": categoryVoList['categoryCode'],
              "categoryName": categoryVoList['categoryName'],
              "showType": categoryVoList['showType']
            });

            //配置顶部菜单默认项
            if (i == 0) classTag = categoryVoList['categoryCode'];
            showItem[categoryVoList['categoryCode']] =
                categoryVoList['menuVoList'];

            //该分类下有option，先初始化页面数据
            if (categoryVoList['menuVoList']?.length > 0) {
              for (var menuVoList in categoryVoList['menuVoList']) {
                if (menuVoList['optionGroupVoList'] != null &&
                    menuVoList['optionGroupVoList']?.length > 0 &&
                    menuVoList['optionGroupVoList'] != "") {
                  //初始化菜品option选项
                  //属性循环相关
                  var attr = menuVoList['optionGroupVoList'];
                  var nochangeattr = menuVoList['optionGroupVoList'];
                  List tempArr = [];
                  List initalCode = [];
                  var checkNum = 0;

                  for (var m = 0; m < attr.length; m++) {
                    for (var n = 0; n < attr[m]['optionVoList'].length; n++) {
                      /*attr[m]['optionVoList'][n]["checked"] = false;
                      if(n == 0){
                        tempArr.add(attr[m]['optionVoList'][n]);
                      }*/
                      if (attr[m]['optionVoList'][n]["standard"] == 1) {
                        attr[m]['optionVoList'][n]["checked"] = true;
                        nochangeattr[m]['optionVoList'][n]["checked"] = true;
                        tempArr.add(attr[m]['optionVoList'][n]);
                        initalCode.add(attr[m]['optionVoList'][n]['optionCode']);
                        checkNum++;
                      } else {
                        attr[m]['optionVoList'][n]["checked"] = false;
                        nochangeattr[m]['optionVoList'][n]["checked"] = false;
                      }
                    }
                  }
                  //需要创建的小组件
                  _menuOption[menuVoList['menuCode']] = attr;
                  _noChangeinitialmenuOption[menuVoList['menuCode']] = initalCode;
                  _initialMenuOption[menuVoList['menuCode']] = tempArr;//tempArr;
                  _selectedMenuOptionList[menuVoList['menuCode']] = tempArr;
                  _selectedMenuOptionCheckedNum[menuVoList['menuCode']] = checkNum;
                  attr = [];
                  tempArr = [];
                  checkNum = 0;
                }
                _selectedMenuOptionChangePrice[menuVoList['menuCode']] = menuVoList['currentPrice'];
                _addselectedMenuOptionChangePrice[menuVoList['menuCode']] = 0;
              }
            }

            /*if(categoryVoList['showType'] == "featured"){
              showItem[categoryVoList['categoryCode']] = categoryVoList['menuVoList'];
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
              showItem[categoryVoList['categoryCode']] = categoryVoList['menuVoList'];
              //itemstwo = categoryVoList['menuVoList'];
            }else if(categoryVoList['showType'] == "block"){
              showItem[categoryVoList['categoryCode']] = categoryVoList['menuVoList'];
              //itemsthree = categoryVoList['menuVoList'];
            }else if(categoryVoList['showType'] == "grid"){
              showItem[categoryVoList['categoryCode']] = categoryVoList['menuVoList'];
              //itemsfour = categoryVoList['menuVoList'];
            }*/

            //执行完后过 加载动画
            _layoutState = LoadState.State_Success;
          }
        });
      } else {
        setState(() {
          _layoutState = LoadState.State_Empty;
        });
        print('${response["msg"]}');
      }
    });

    //print(_menuOption);
  }


  //限量商品请求接口
  _checkQtyBoundsCount(menuCode, optionCode) {
    var checkResult;
    var formData = {
      "machineCode": _machineCode,
      "menuCode": menuCode,
      "optionCode": optionCode
    };
    request('webStockBooking', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      if (response['code'] == 200 && response["data"] == true) {
        checkResult = true;
      } else {
        checkResult = false;
      }
    });
    return checkResult;
  }

  //顶部分类导航
  showTopCategoryMenu() {
    List<Widget> categoryMenus = []; //先建一个数组用于存放循环生成的widget
    List MenuColor = ["#A61C1C","#894911","#078E42","#E8A854","#4C7FBC"];
    var menuIndex = 0;
    for (var item in topMenu) {
      categoryMenus.add(InkWell(
        onTap: () {
          setState(() {
            classTag = item['categoryCode'];
          });
        },
        child: Container(
          margin: EdgeInsets.only(right: ScreenAdapter.width(10)),
          width: ScreenAdapter.width(161),
          height: ScreenAdapter.height(65),
          /*decoration: BoxDecoration(
            image: new DecorationImage(
              fit: BoxFit.fitWidth,
              image: classTag == item['categoryCode']
                  ? AssetImage('assets/images/category_selected.png')
                  : AssetImage('assets/images/category_unselected.png'),
            ),

          ),*/
          decoration: BoxDecoration(
            //设置边框
            //border: new Border.all(color: ColorsUtil.hexToColor("#F9F9F9"), width: 0.5),
            //背景颜色
            color: ColorsUtil.hexToColor(MenuColor[menuIndex]),
            //设置圆角
            //borderRadius: new BorderRadius.circular((15.0)),
            //设置阴影
            //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#949191"), offset: Offset(1.0, 1.0), blurRadius: 1.5, spreadRadius: 1.5), ],
          ),
          child: Center(
            //加上Center让文字居中
            child: Text(
              item['categoryName'],
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(GFontSize.categoryTitle),
                  /*color: classTag == item['categoryCode']
                      ? ColorsUtil.hexToColor(Gcolor.categoryTitleSelected)
                      : ColorsUtil.hexToColor(Gcolor.categoryTitle),*/
                  color: ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ));

      menuIndex++;
    }

    categoryMenus.add(InkWell(
      onTap: () {


        Future.delayed(Duration(milliseconds: 100), () {
          Navigator.push(context, CustomRoute(HomePage()));
          //Navigator.of(context).pushReplacementNamed('/home');
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.only(left: ScreenAdapter.width(5)),
        width: ScreenAdapter.width(110),
        height: ScreenAdapter.height(55),
        decoration: BoxDecoration(
          image: new DecorationImage(
            fit: BoxFit.fitWidth,
            image: AssetImage('assets/images/backbutton_top.png'),
          ),
        ),
        child: Center(
          //加上Center让文字居中
          child: Text(
            GString.getToString(this._checkLanguage, "top_back_button"),
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(26),
                color: ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                fontWeight: FontWeight.w600),
          ),
        ),
      ),
    ));

    return Row(
      children: categoryMenus,
    );
  }

  //中间分类页面
  showMiddleMenuList() {
    for (var item in topMenu) {
      if (classTag == item['categoryCode']) {
        if (item['showType'] == "featured") {
          return _showCategoryOne(showItem[classTag]);
        } else if (item['showType'] == "table") {
          return _showCategoryTwo(showItem[classTag]);
        } else if (item['showType'] == "block") {
          return _showCategoryThree(showItem[classTag]);
        } else if (item['showType'] == "grid") {
          return _showCategoryFour(showItem[classTag]);
        } else if (item['showType'] == "waterfall") {
          return _showCategoryFive(showItem[classTag]);
        }
      }
    }
  }

  //公共展示加入购物车动画
  _publicShowAddCart(temp,imgUrl){
    Function callback;
    setState(() {
      OverlayEntry entry =
      OverlayEntry(builder: (ctx) {
        return ParabolaAnimateWidget(rootKey,temp,Offset(486.5, 1600.0),imgUrl,callback,duration: 1000,);
      });

      callback = (status) {
        if (status == AnimationStatus.completed) {
          entry?.remove();
        }
      };
      Overlay.of(rootKey.currentContext).insert(entry);
    });
  }
  //公共展示菜品图片
  publicShowMenuImage(imgPath, imgWidth, imgHeight) {
    return Container(
      width: ScreenAdapter.width(imgWidth),
      height: ScreenAdapter.height(imgHeight),
      child: CachedNetworkImage(
        imageUrl: imgPath,
        fit: BoxFit.fill,
        width: ScreenAdapter.width(imgWidth),
        height: ScreenAdapter.height(imgHeight),
        cacheManager: EsoImageCacheManager(),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.colorBurn)
            ),
          ),
        ),
        placeholder: (context, url) => Container(
          width: ScreenAdapter.width(200),
          height: ScreenAdapter.height(200),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Image.network(
          imgPath,fit: BoxFit.fill,
          width: ScreenAdapter.width(imgWidth),
          height: ScreenAdapter.height(imgHeight)
        ),
      ),
    );
  }

  //公共设置价格
  publicShowMenuPrice(currentPrice, priceFrontFontSize, priceFrontFontColor, priceFontSize, priceFontColor, priceBackFontSize, priceBackFontColor) {
    return RichText(
      text: TextSpan(
          text: "¥",//GString.getToString(this._checkLanguage, "show_price_front"),
          style: TextStyle(
            fontSize: ScreenAdapter.fontSize(priceFrontFontSize),
            fontWeight: FontWeight.w600,
            color: ColorsUtil.hexToColor(priceFrontFontColor),
          ),
          children: [
            TextSpan(
              text: currentPrice.toString(),
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(priceFontSize),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor(priceFontColor),
              ),
            ),
            /*TextSpan(
              text: "（${GString.getToString(this._checkLanguage, "show_price_front")}）",//" 円",
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(priceBackFontSize),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor(priceBackFontColor),
              ),
            ),*/
          ]),
    );
  }

  //公共设置菜单Title
  publicShowMenuTitle(mainTitle, mainTitleFontSize, mainTitleFontColor) {
    return Text(
      mainTitle,
      overflow: TextOverflow.ellipsis, //长度溢出后显示省略号
      style: TextStyle(
          fontSize: ScreenAdapter.fontSize(mainTitleFontSize),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(mainTitleFontColor)),
    );
  }

  //公共设置标签 subTitle
  publicShowMenuSubtitle(subtitleList) {
    //标签循环相关
    if (subtitleList.length > 0) {
      var labelSubtitleLength = subtitleList.length;
      List<Widget> labels = []; //先建一个数组用于存放循环生成的widget
      //Widget labelContent;
      for (var i = 0; i < labelSubtitleLength; i++) {
        labels.add(Chip(
          label: Text(subtitleList[i],
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(GFontSize.menuTwoTitleTag),
                  color: ColorsUtil.hexToColor("#000000"))),//Gcolor.foodTagColor
          /*labelPadding: EdgeInsets.only(
              right: ScreenAdapter.width(5),
              bottom: ScreenAdapter.height(0),
              left: ScreenAdapter.width(5),
              top: ScreenAdapter.height(0)),
          padding: EdgeInsets.only(
              right: ScreenAdapter.width(5),
              bottom: ScreenAdapter.height(0),
              left: ScreenAdapter.width(5),
              top: ScreenAdapter.height(0)),*/
          shape: new RoundedRectangleBorder(
            /*side: new BorderSide(
                //设置 界面效果
                color: ColorsUtil.hexToColor(Gcolor.foodTagColor),
                style: BorderStyle.solid,
                width: 0),*/
          ),
          backgroundColor: ColorsUtil.hexToColor("#F9F9F9"),
        ));
      }
      return Wrap(
          spacing: ScreenAdapter.width(5), // set spacing here
          runSpacing: ScreenAdapter.height(-20),
          children: labels);
    } else {
      return Container(
        height: 0,
      );
    }
  }

  //公共设置售罄
  publicShowMenuSellOut(bounds) {
    if (bounds == 0) {
      return Positioned(
        right: ScreenAdapter.width(10),
        top: ScreenAdapter.height(20),
        child: Image.asset(
          'assets/images/shouqing.jpeg',
          width: ScreenAdapter.width(100),
          fit: BoxFit.fitWidth,
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  //公共加入购物车
  publicAddCartMenu(cartItem, checkItem) async {

    var result;
    try {
      result = await controller.addToCart(cartItem, checkItem: checkItem);
      controller.getCardList();


    } catch (e) {
      print(e);
      result = 0;
    }
    return result;
  }

  //改变选项
  _changeOption(menuCode, groupCode, optionCode, setMenuState) {
    var attr = _menuOption[menuCode];
    for (var i = 0; i < attr.length; i++) {
      if (attr[i]["groupCode"] == groupCode) {
        for (var j = 0; j < attr[i]['optionVoList'].length; j++) {
          attr[i]['optionVoList'][j]["checked"] = false;
          if (attr[i]['optionVoList'][j]["optionCode"] == optionCode) {
            attr[i]['optionVoList'][j]["checked"] = !attr[i]['optionVoList'][j]["checked"];

          }
        }
      }
    }
    setMenuState(() {
      _menuOption[menuCode] = attr;
    });

    _getSelectedAttrValue(menuCode, attr, setMenuState);
  }

  //初始化默认option选项
  _changeInitialOption(menuCode, setMenuState) {
    var attr = _menuOption[menuCode];
    var initMenuOption = _noChangeinitialmenuOption[menuCode];
    for (var i = 0; i < attr.length; i++) {
      for (var j = 0; j < attr[i]['optionVoList'].length; j++) {
        var check = initMenuOption.any((e) => e ==attr[i]['optionVoList'][j]["optionCode"]);
         if(true == check){
           attr[i]['optionVoList'][j]["checked"] = true;
         }else{
           attr[i]['optionVoList'][j]["checked"] = false;
         }

      }
    }

    setMenuState(() {
      _menuOption[menuCode] = attr;
      _selectedMenuOptionList[menuCode] = _initialMenuOption[menuCode];
      _addselectedMenuOptionChangePrice[menuCode] = 0;
    });
  }

  //获取选中的值
  _getSelectedAttrValue(menuCode, optionGroupList, setMenuState) {

    var _list = optionGroupList;
    List tempArr = [];
    var selectPrice = 0;
    for (var i = 0; i < _list.length; i++) {
      for (var j = 0; j < _list[i]['optionVoList'].length; j++) {
        if (_list[i]['optionVoList'][j]['checked'] == true) {
          var selectMapItem = {
            "optionCode": _list[i]['optionVoList'][j]["optionCode"],
            "mainTitle": _list[i]['optionVoList'][j]["mainTitle"],
            "currentPrice": _list[i]['optionVoList'][j]["currentPrice"],
          };
          tempArr.add(selectMapItem);


          selectPrice +=_list[i]['optionVoList'][j]["currentPrice"];


        }
      }
    }

    if (tempArr.length > 0) {
      setMenuState(() {
        _selectedMenuOptionList[menuCode] = tempArr;
        _addselectedMenuOptionChangePrice[menuCode] = selectPrice;
      });
      tempArr = [];
    }
  }

  //获取第一个页面的option widget
  _getFirstOptionWidget(menuCode, setFirstState) {
    var optionGroupVoList = _menuOption[menuCode];

    List<Widget> options = []; //先建一个数组用于存放循环生成的widget


    //Widget labelContent;
    for (var i = 0; i < optionGroupVoList.length; i++) {
      List<Widget> optionSons = [];
      var optionVoList = optionGroupVoList[i]['optionVoList'];
      options.add(Container(
        padding: EdgeInsets.only(
            top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
        child: Row(
          children: [
            Text(
              optionGroupVoList[i]['groupName'],
              style: TextStyle(
                fontSize: ScreenAdapter.fontSize(17.0),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
              ),
            ),
          ],
        ),
      ));

      for (var j = 0; j < optionVoList.length; j++) {
        var optionVolistSon = optionVoList[j];

        if (optionVolistSon['buttonColorValue'] != null && optionVolistSon['buttonColorValue'] != "") {
          var buttonColor = optionVolistSon['buttonColorValue'].split(',');
          optionSons.add(Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(14),
                top: ScreenAdapter.height(3),
                right: ScreenAdapter.width(14),
                bottom: ScreenAdapter.height(3)),
            child: InkWell(
              onTap: () {
                _changeOption(menuCode, optionGroupVoList[i]["groupCode"],
                    optionVolistSon["optionCode"], setFirstState);
              },
              child: Stack(
                children: [
                  Container(
                      width: ScreenAdapter.width(224),
                      height: ScreenAdapter.height(60),
                      alignment: Alignment.center,
                      decoration: (optionVolistSon['checked'] == true)
                          ? BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            ColorsUtil.hexToColor("#C47829"),
                            ColorsUtil.hexToColor("#854610"),
                          ],
                        ),
                              //设置阴影
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 3),
                                    blurRadius: 3.0,
                                    spreadRadius: 0),
                              ],
                            )
                          : BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                              //color: ColorsUtil.hexToColor(optionVolistSon['buttonColorValue']),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  ColorsUtil.hexToColor(buttonColor[0]),
                                  ColorsUtil.hexToColor(buttonColor[1]),
                                ],
                              ),
                              //设置阴影
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 3),
                                    blurRadius: 3.0,
                                    spreadRadius: 0),
                              ],
                            ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (optionVolistSon['homeImage'] != "" && optionVolistSon['homeImage'] != null)
                              ? Image.network(optionVolistSon['homeImage'],
                                  width: ScreenAdapter.width(15),
                                  height: ScreenAdapter.height(25),
                                  color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                  fit: BoxFit.fitHeight)
                              : Container(
                                  width: 0,
                                ),
                          SizedBox(
                            width: ScreenAdapter.width(12),
                          ),
                          Text(
                            optionVolistSon['mainTitle'],
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(28.0),
                              fontWeight: FontWeight.w600,
                              color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                              //color: ColorsUtil.hexToColor(Gcolor.optionBtnColor),
                            ),
                          ),
                        ],
                      )),
                  //绝对定位 盖章
                  //绝对定位 盖章
                  (optionVolistSon['currentPrice'] > 0)
                      ? Positioned(
                          right: ScreenAdapter.width(0),
                          top: ScreenAdapter.height(0),
                          child: Container(
                              width: ScreenAdapter.width(60),
                              height: ScreenAdapter.height(60),
                              padding: EdgeInsets.only(
                                  top: ScreenAdapter.height(4),
                                  left: ScreenAdapter.width(30)),
                              //alignment: Alignment.topCenter,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/price_tag.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Container(
                                // 旋转
                                transform: Matrix4.rotationZ(0.8),
                                child: Text(
                                    "+${optionVolistSon['currentPrice'].toString()}",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(13),
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.optionBtnColor),
                                    )),
                              )),
                        )
                      : Container(
                          height: 0,
                        ),
                 /* (optionVolistSon['checked'] == true)
                      ? Positioned(
                          right: ScreenAdapter.width(10),
                          top: ScreenAdapter.height(8),
                          child: Container(
                              width: ScreenAdapter.width(90),
                              height: ScreenAdapter.height(50),
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/optionChecked.png',
                                width: ScreenAdapter.width(50),
                                fit: BoxFit.fitWidth,
                              )),
                        )
                      : Container(
                          height: 0,
                        ),*/
                ],
              ),
            ),
          ));
        } else {
          optionSons.add(Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(5),
                top: ScreenAdapter.height(2),
                right: ScreenAdapter.width(5),
                bottom: ScreenAdapter.height(2)),
            child: InkWell(
              onTap: () {
                _changeOption(menuCode, optionGroupVoList[i]["groupCode"],
                    optionVolistSon["optionCode"], setFirstState);
              },
              child: Stack(
                children: [
                  Container(
                      width: ScreenAdapter.width(220),
                      height: ScreenAdapter.height(60),
                      alignment: Alignment.center,
                      decoration: (optionVolistSon['checked'] == true)
                          ? BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                             // color: ColorsUtil.hexToColor("#BCA48E"),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            ColorsUtil.hexToColor("#C47829"),
                            ColorsUtil.hexToColor("#854610"),
                          ],
                        ),
                              //设置阴影
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 3),
                                    blurRadius: 3.0,
                                    spreadRadius: 0),
                              ],
                            )
                          : BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(14.0)),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  ColorsUtil.hexToColor("#E9CE9B"),
                                  ColorsUtil.hexToColor("#CEA062"),
                                ],
                              ),
                              //设置阴影
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(2, 3),
                                    blurRadius: 3.0,
                                    spreadRadius: 0),
                              ],
                            ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (optionVolistSon['homeImage'] != "" &&
                                  optionVolistSon['homeImage'] != null)
                              ? Image.network(optionVolistSon['homeImage'],
                                  width: ScreenAdapter.width(15),
                                  height: ScreenAdapter.height(25),
                                  color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                  fit: BoxFit.fitHeight)
                              : Container(
                                  width: 0,
                                ),
                          SizedBox(
                            width: ScreenAdapter.width(6),
                          ),
                          Text("${optionVolistSon['mainTitle']}",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(28.0),
                                fontWeight: FontWeight.w600,
                                color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                              )),
                        ],
                      )),
                  //绝对定位 盖章
                  (optionVolistSon['currentPrice'] > 0)
                      ? Positioned(
                          right: ScreenAdapter.width(0),
                          top: ScreenAdapter.height(0),
                          child: Container(
                              width: ScreenAdapter.width(60),
                              height: ScreenAdapter.height(60),
                              padding: EdgeInsets.only(
                                  top: ScreenAdapter.height(3),
                                  left: ScreenAdapter.width(30)),
                              //alignment: Alignment.topCenter,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                image: DecorationImage(
                                  image:
                                      AssetImage("assets/images/price_tag.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Container(
                                // 旋转
                                transform: Matrix4.rotationZ(0.8),
                                child: Text(
                                    "+${optionVolistSon['currentPrice'].toString()}",
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(13),
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.optionBtnColor),
                                    )),
                              )),
                        )
                      : Container(
                          height: 0,
                        ),
                  /*(optionVolistSon['checked'] == true)
                      ? Positioned(
                          right: ScreenAdapter.width(10),
                          top: ScreenAdapter.height(8),
                          child: Container(
                              width: ScreenAdapter.width(100),
                              height: ScreenAdapter.height(50),
                              alignment: Alignment.center,
                              child: Image.asset(
                                'assets/images/optionChecked.png',
                                width: ScreenAdapter.width(50),
                                fit: BoxFit.fitWidth,
                              )),
                        )
                      : Container(
                          height: 0,
                        ),*/
                ],
              ),
            ),
          ));
        }
      }
      options.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: optionSons,
      ));


    }

    return options;
  }

  //获取第一个页面的widget
  publicShowMenuOptionGroupWidget(menuCode, setFirstMenuState) {
    return Container(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(10)),
      child: Column(
        children: _getFirstOptionWidget(menuCode, setFirstMenuState),
      ),
    );
  }

  //定食第三个分类
  //获取第三个页面的option widget
  _getThreeOptionWidget(menuCode, setFirstState) {
    var optionGroupVoList = _menuOption[menuCode];
    List<Widget> options = []; //先建一个数组用于存放循环生成的widget
    if (optionGroupVoList != null &&
        optionGroupVoList.length > 0 &&
        optionGroupVoList != "") {
      for (var i = 0; i < optionGroupVoList.length; i++) {
        List<Widget> optionSons = [];
        var optionVoList = optionGroupVoList[i]['optionVoList'];
        options.add(Container(
          padding: EdgeInsets.only(
              top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
          child: Row(
            children: [
              Text(
                optionGroupVoList[i]['groupName'],
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(16.0),
                    fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                ),
              ),
            ],
          ),
        ));

        for (var j = 0; j < optionVoList.length; j++) {
          var optionVolistSon = optionVoList[j];

          if (optionVolistSon['buttonColorValue'] != null &&
              optionVolistSon['buttonColorValue'] != "") {
            var buttonColor = optionVolistSon['buttonColorValue'].split(',');
            optionSons.add(Container(
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(7),
                  top: ScreenAdapter.height(2),
                  right: ScreenAdapter.width(7),
                  bottom: ScreenAdapter.height(2)),
              child: InkWell(
                onTap: () {
                  _changeOption(menuCode, optionGroupVoList[i]["groupCode"],
                      optionVolistSon["optionCode"], setFirstState);
                },
                child: Stack(
                  children: [
                    Container(
                        width: ScreenAdapter.width(130),
                        height: ScreenAdapter.height(50),
                        alignment: Alignment.center,
                        decoration: (optionVolistSon['checked'] == true)
                            ? BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              ColorsUtil.hexToColor("#C47829"),
                              ColorsUtil.hexToColor("#854610"),
                            ],
                          ),
                          //设置阴影
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 3),
                                blurRadius: 3.0,
                                spreadRadius: 0),
                          ],
                        )
                            : BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          //color: ColorsUtil.hexToColor(optionVolistSon['buttonColorValue']),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              ColorsUtil.hexToColor(buttonColor[0]),
                              ColorsUtil.hexToColor(buttonColor[1]),
                            ],
                          ),
                          //设置阴影
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 3),
                                blurRadius: 3.0,
                                spreadRadius: 0),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (optionVolistSon['homeImage'] != "" &&
                                    optionVolistSon['homeImage'] != null)
                                ? Image.network(optionVolistSon['homeImage'],
                                    width: ScreenAdapter.width(15),
                                    height: ScreenAdapter.height(25),
                                    color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                    fit: BoxFit.fitHeight)
                                : Container(
                                    width: 0,
                                  ),
                            SizedBox(
                              width: ScreenAdapter.width(6),
                            ),
                            Text(optionVolistSon['mainTitle'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: ScreenAdapter.fontSize(25.0),
                                  color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                )),
                          ],
                        )),
                    //绝对定位 盖章
                    (optionVolistSon['currentPrice'] > 0)
                        ? Positioned(
                            right: ScreenAdapter.width(0),
                            top: ScreenAdapter.height(0),
                            child: Container(
                                width: ScreenAdapter.width(50),
                                height: ScreenAdapter.height(50),
                                //padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                                padding: EdgeInsets.only(
                                    left: ScreenAdapter.width(20)),
                                // alignment: Alignment.topRight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/price_tag.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Container(
                                  // 旋转
                                  transform: Matrix4.rotationZ(0.8),
                                  child: Text(
                                      "+${optionVolistSon['currentPrice'].toString()}",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(13),
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.optionBtnColor),
                                      )),
                                )),
                          )
                        : Container(
                            height: 0,
                          ),
                    //绝对定位 盖章
                    /*(optionVolistSon['checked'] == true)
                        ? Positioned(
                            right: ScreenAdapter.width(10),
                            top: ScreenAdapter.height(5),
                            child: Container(
                                width: ScreenAdapter.width(60),
                                height: ScreenAdapter.height(45),
                                //padding: EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/optionChecked.png',
                                  width: ScreenAdapter.width(40),
                                  //height: ScreenAdapter.height(75),
                                  fit: BoxFit.fitWidth,
                                )),
                          )
                        : Container(
                            height: 0,
                          ),*/
                  ],
                ),
              ),
            ));
          } else {
            optionSons.add(Container(
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(5),
                  top: ScreenAdapter.height(2),
                  right: ScreenAdapter.width(5),
                  bottom: ScreenAdapter.height(2)),
              child: InkWell(
                onTap: () {
                  _changeOption(menuCode, optionGroupVoList[i]["groupCode"],
                      optionVolistSon["optionCode"], setFirstState);
                },
                child: Stack(
                  children: [
                    Container(
                        width: ScreenAdapter.width(130),
                        height: ScreenAdapter.height(50),
                        alignment: Alignment.center,
                        decoration: (optionVolistSon['checked'] == true)
                            ? BoxDecoration(
                          // color: ColorsUtil.hexToColor("#BCA48E"),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              ColorsUtil.hexToColor("#C47829"),
                              ColorsUtil.hexToColor("#854610"),
                            ],
                          ),
                          //设置阴影
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 3),
                                blurRadius: 3.0,
                                spreadRadius: 0),
                          ],
                        )
                            : BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              ColorsUtil.hexToColor("#E9CE9B"),
                              ColorsUtil.hexToColor("#CEA062"),
                            ],
                          ),
                          //设置阴影
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 3),
                                blurRadius: 3.0,
                                spreadRadius: 0),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (optionVolistSon['homeImage'] != "" &&
                                    optionVolistSon['homeImage'] != null)
                                ? Image.network(optionVolistSon['homeImage'],
                                    width: ScreenAdapter.width(15),
                                    height: ScreenAdapter.height(25),
                                    color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                    fit: BoxFit.fitHeight)
                                : Container(
                                    width: 0,
                                  ),
                            SizedBox(
                              width: ScreenAdapter.width(6),
                            ),
                            Text("${optionVolistSon['mainTitle']}",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(25.0),
                                  fontWeight: FontWeight.w500,
                                  color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                )),
                          ],
                        )),
                    //绝对定位 盖章
                    (optionVolistSon['currentPrice'] > 0)
                        ? Positioned(
                            right: ScreenAdapter.width(0),
                            top: ScreenAdapter.height(0),
                            child: Container(
                                width: ScreenAdapter.width(50),
                                height: ScreenAdapter.height(50),
                                padding: EdgeInsets.only(
                                    left: ScreenAdapter.width(20)),
                                //alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/price_tag.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Container(
                                  // 旋转
                                  transform: Matrix4.rotationZ(0.8),
                                  child: Text(
                                      "+${optionVolistSon['currentPrice'].toString()}",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(13),
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.optionBtnColor),
                                      )),
                                )),
                          )
                        : Container(
                            height: 0,
                          ),
                    //绝对定位 盖章
                    /*(optionVolistSon['checked'] == true)
                        ? Positioned(
                            right: ScreenAdapter.width(10),
                            top: ScreenAdapter.height(5),
                            child: Container(
                                width: ScreenAdapter.width(60),
                                height: ScreenAdapter.height(45),
                                //padding: EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/optionChecked.png',
                                  width: ScreenAdapter.width(40),
                                  //height: ScreenAdapter.height(75),
                                  fit: BoxFit.fitWidth,
                                )),
                          )
                        : Container(
                            height: 0,
                          ),*/
                  ],
                ),
              ),
            ));
          }
        }
        options.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: optionSons,
        ));
      }
    }

    return options;
  }

  //获取第三个页面的widget
  publicShowThreeMenuOptionGroupWidget(menuCode, menuindex) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(15),
          right: ScreenAdapter.width(5),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getThreeOptionWidget(menuCode, menuindex),
      ),
    );
  }

  //定食第五个分类
  //获取第五个页面的option widget
  _getFiveOptionWidget(menuCode, setFirstState) {
    var optionGroupVoList = _menuOption[menuCode];
    List<Widget> options = []; //先建一个数组用于存放循环生成的widget
    if (optionGroupVoList != null &&
        optionGroupVoList.length > 0 &&
        optionGroupVoList != "") {
      for (var i = 0; i < optionGroupVoList.length; i++) {
        List<Widget> optionSons = [];
        var optionVoList = optionGroupVoList[i]['optionVoList'];
        options.add(Container(
          padding: EdgeInsets.only(
              top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
          child: Row(
            children: [
              Text(
                optionGroupVoList[i]['groupName'],
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(16.0),
                    fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                ),
              ),
            ],
          ),
        ));

        for (var j = 0; j < optionVoList.length; j++) {
          var optionVolistSon = optionVoList[j];

          /*if (optionVolistSon['homeImage'] != "" && optionVolistSon['homeImage'] != null) {
            optionSons.add(Container(
              padding: EdgeInsets.only(left: ScreenAdapter.width(5),top: ScreenAdapter.height(5),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
              child: InkWell(
                onTap: (){
                  _changeOption(menuCode,optionGroupVoList[i]["groupCode"],optionVolistSon["optionCode"],setFirstState);
                },
                child: Stack(
                  children: [
                    Container(
                        width: ScreenAdapter.width(160),
                        height: ScreenAdapter.height(55),
                        decoration: BoxDecoration(
                          image: new DecorationImage(
                            fit: BoxFit.fitWidth,
                            image: NetworkImage(optionVolistSon['homeImage']),
                          ),
                        ),
                    ),
                    //绝对定位 盖章
                    (optionVolistSon['checked'] == true)
                        ? Positioned(
                      left: ScreenAdapter.width(10),
                      top: ScreenAdapter.height(5),
                      child: Container(
                          width: ScreenAdapter.width(160),
                          height: ScreenAdapter.height(45),
                          //padding: EdgeInsets.all(16.0),
                          alignment:Alignment.center,
                          child: Image.asset(
                            'assets/images/optionChecked.png',
                            width: ScreenAdapter.width(45),
                            //height: ScreenAdapter.height(75),
                            fit: BoxFit.fitWidth,
                          )
                      ),
                    )
                        : Container(
                      height: 0,
                    ),
                  ],
                ),
              ),
            ));
          }else */
          if (optionVolistSon['buttonColorValue'] != null &&
              optionVolistSon['buttonColorValue'] != "") {
            var buttonColor = optionVolistSon['buttonColorValue'].split(',');
            optionSons.add(Container(
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(7),
                  top: ScreenAdapter.height(5),
                  right: ScreenAdapter.width(7),
                  bottom: ScreenAdapter.height(5)),
              child: InkWell(
                onTap: () {
                  _changeOption(menuCode, optionGroupVoList[i]["groupCode"],
                      optionVolistSon["optionCode"], setFirstState);
                },
                child: Stack(
                  children: [
                    Container(
                        width: ScreenAdapter.width(160),
                        height: ScreenAdapter.height(55),
                        alignment: Alignment.center,
                        decoration: (optionVolistSon['checked'] == true)
                            ? BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              ColorsUtil.hexToColor("#C47829"),
                              ColorsUtil.hexToColor("#854610"),
                            ],
                          ),
                          //设置阴影
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 3),
                                blurRadius: 3.0,
                                spreadRadius: 0),
                          ],
                        )
                            : BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          //color: ColorsUtil.hexToColor(optionVolistSon['buttonColorValue']),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              ColorsUtil.hexToColor(buttonColor[0]),
                              ColorsUtil.hexToColor(buttonColor[1]),
                            ],
                          ),
                          //设置阴影
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 3),
                                blurRadius: 3.0,
                                spreadRadius: 0),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (optionVolistSon['homeImage'] != "" &&
                                    optionVolistSon['homeImage'] != null)
                                ? Image.network(optionVolistSon['homeImage'],
                                    width: ScreenAdapter.width(15),
                                    height: ScreenAdapter.height(25),
                                    color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                    fit: BoxFit.fitHeight)
                                : Container(
                                    width: 0,
                                  ),
                            SizedBox(
                              width: ScreenAdapter.width(6),
                            ),
                            Text("${optionVolistSon['mainTitle']}",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(25.0),
                                  fontWeight: FontWeight.w500,
                                  color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                )),
                          ],
                        )),
                    //绝对定位 盖章
                    (optionVolistSon['currentPrice'] > 0)
                        ? Positioned(
                            right: ScreenAdapter.width(0),
                            top: ScreenAdapter.height(0),
                            child: Container(
                                width: ScreenAdapter.width(50),
                                height: ScreenAdapter.height(50),
                                padding: EdgeInsets.only(
                                    left: ScreenAdapter.width(20)),
                                //alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  image: DecorationImage(

                                    image: AssetImage(
                                        "assets/images/price_tag.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Container(
                                  // 旋转
                                  transform: Matrix4.rotationZ(0.8),
                                  child: Text(
                                      "+${optionVolistSon['currentPrice'].toString()}",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(13),
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.optionBtnColor),
                                      )),
                                )),
                          )
                        : Container(
                            height: 0,
                          ),
                    //绝对定位 盖章
                    /*(optionVolistSon['checked'] == true)
                        ? Positioned(
                            right: ScreenAdapter.width(10),
                            top: ScreenAdapter.height(5),
                            child: Container(
                                width: ScreenAdapter.width(60),
                                height: ScreenAdapter.height(45),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/optionChecked.png',
                                  width: ScreenAdapter.width(45),
                                  //height: ScreenAdapter.height(75),
                                  fit: BoxFit.fitWidth,
                                )),
                          )
                        : Container(
                            height: 0,
                          ),*/
                  ],
                ),
              ),
            ));
          } else {
            optionSons.add(Container(
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(5),
                  top: ScreenAdapter.height(5),
                  right: ScreenAdapter.width(5),
                  bottom: ScreenAdapter.height(5)),
              child: InkWell(
                onTap: () {
                  _changeOption(menuCode, optionGroupVoList[i]["groupCode"],
                      optionVolistSon["optionCode"], setFirstState);
                },
                child: Stack(
                  children: [
                    Container(
                        width: ScreenAdapter.width(160),
                        height: ScreenAdapter.height(55),
                        alignment: Alignment.center,
                        decoration: (optionVolistSon['checked'] == true)
                            ? BoxDecoration(
                          // color: ColorsUtil.hexToColor("#BCA48E"),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              ColorsUtil.hexToColor("#C47829"),
                              ColorsUtil.hexToColor("#854610"),
                            ],
                          ),
                          //设置阴影
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 3),
                                blurRadius: 3.0,
                                spreadRadius: 0),
                          ],
                        )
                            : BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              ColorsUtil.hexToColor("#E9CE9B"),
                              ColorsUtil.hexToColor("#CEA062"),
                            ],
                          ),
                          //设置阴影
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 3),
                                blurRadius: 3.0,
                                spreadRadius: 0),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            (optionVolistSon['homeImage'] != "" &&
                                    optionVolistSon['homeImage'] != null)
                                ? Image.network(optionVolistSon['homeImage'],
                                    width: ScreenAdapter.width(15),
                                    height: ScreenAdapter.height(25),
                                    color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                    fit: BoxFit.fitHeight)
                                : Container(
                                    width: 0,
                                  ),
                            SizedBox(
                              width: ScreenAdapter.width(6),
                            ),
                            Text("${optionVolistSon['mainTitle']}",
                                style: TextStyle(
                                  fontSize: ScreenAdapter.fontSize(25.0),
                                  fontWeight: FontWeight.w500,
                                  color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                                )),
                          ],
                        )),
                    //绝对定位 盖章
                    (optionVolistSon['currentPrice'] > 0)
                        ? Positioned(
                            right: ScreenAdapter.width(0),
                            top: ScreenAdapter.height(0),
                            child: Container(
                                width: ScreenAdapter.width(50),
                                height: ScreenAdapter.height(50),
                                padding: EdgeInsets.only(
                                    left: ScreenAdapter.width(20)),
                                //alignment: Alignment.topCenter,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/images/price_tag.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                child: Container(
                                  // 旋转
                                  transform: Matrix4.rotationZ(0.8),
                                  child: Text(
                                      "+${optionVolistSon['currentPrice'].toString()}",
                                      style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(13),
                                        color: ColorsUtil.hexToColor(
                                            Gcolor.optionBtnColor),
                                      )),
                                )),
                          )
                        : Container(
                            height: 0,
                          ),
                    //绝对定位 盖章
                    /*(optionVolistSon['checked'] == true)
                        ? Positioned(
                            right: ScreenAdapter.width(10),
                            top: ScreenAdapter.height(5),
                            child: Container(
                                width: ScreenAdapter.width(60),
                                height: ScreenAdapter.height(45),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/optionChecked.png',
                                  width: ScreenAdapter.width(45),
                                  fit: BoxFit.fitWidth,
                                )),
                          )
                        : Container(
                            height: 0,
                          ),*/
                  ],
                ),
              ),
            ));
          }
        }
        options.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: optionSons,
        ));
      }
    }

    return options;
  }

  //获取第五个页面的widget
  publicShowFiveMenuOptionGroupWidget(menuCode, menuindex) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(15),
          right: ScreenAdapter.width(5),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getFiveOptionWidget(menuCode, menuindex),
      ),
    );
  }

  //第一分类页面
  _showCategoryOne(showItemList) {
    Offset temp;
    //第一页第一个商品以及剩余商品
    List items = [];
    Map itemsFirst = {};
    List itemsTree = [];

    items = showItemList;
    if (items.length > 0) {
      itemsFirst = items[0];

      /*if (items.length > 1) {
        for (var m = 0; m < items.length; m++) {
          if (m > 0) {
            itemsTree.add(items[m]);
          }
        }
      }*/
    }

    if (itemsFirst != null) {
      return Container(
        color: ColorsUtil.hexToColor(Gcolor.mainBackground),
        padding: EdgeInsets.only(top:ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
        child: ListView(
          shrinkWrap: true,
          children: [
            publicShowMenuImage(itemsFirst['homeImage'], 1080.0, 875.0),
            Container(
              color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              width: ScreenAdapter.width(1080),
              //height: ScreenAdapter.height(408),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(25),
                  right: ScreenAdapter.width(25),
                  bottom: ScreenAdapter.height(15)),
              child: StatefulBuilder(
                builder: (BuildContext context, setFirstMenuState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (itemsFirst['optionGroupVoList']?.length > 0)
                          ? publicShowMenuOptionGroupWidget(itemsFirst['menuCode'], setFirstMenuState)
                          : Container(
                              height: 0,
                            ),
                      Divider(
                        height: 1,
                        color: Color.fromRGBO(227, 227, 227, 1),
                      ),

                      //标题价格
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //菜单Title
                                publicShowMenuTitle(itemsFirst['mainTitle'],
                                    42.0, Gcolor.mainTitleColor),
                              ],
                            ),
                          )),
                          //价格展示 //itemsFirst['currentPrice']
                          Container(
                            width: ScreenAdapter.width(200),
                            child: publicShowMenuPrice(
                                _selectedMenuOptionChangePrice[itemsFirst['menuCode']]+_addselectedMenuOptionChangePrice[itemsFirst['menuCode']],
                                45.0,
                                Gcolor.mainTitleColor,
                                55.0,
                                Gcolor.priceColor,
                                26.0,
                                Gcolor.mainTitleColor),
                          ),

                          //确认按钮
                          InkWell(
                            onTapDown: (details) {
                              temp = new Offset(details.globalPosition.dx, details.globalPosition.dy);
                            },
                            onTap: () {

                              //判断选择后option是否与optiongroup相等
                              if (_selectedMenuOptionList[itemsFirst['menuCode']].length <_selectedMenuOptionCheckedNum[itemsFirst['menuCode']]) {
                                showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                                return;
                              }
                              var currentPrice = itemsFirst['currentPrice'];
                              var optionCodeList = "";
                              var optionTitle = "";
                              for (var optionItem in _selectedMenuOptionList[itemsFirst['menuCode']]) {
                                if (optionItem['currentPrice'] > 0) {
                                  currentPrice += optionItem['currentPrice'];
                                }
                                optionCodeList += (optionCodeList != "") ? "," + optionItem['optionCode'] : optionItem['optionCode'];
                                optionTitle += (optionTitle != "") ? "," + optionItem['mainTitle'] : optionItem['mainTitle'];
                              }

                              var cartItem = {
                                "menuCode": itemsFirst['menuCode'],
                                "mainTitle": itemsFirst['mainTitle'],
                                "image": itemsFirst['homeImage'],
                                "currentPrice": currentPrice,
                                "optionGroupVoList": optionCodeList,
                                "optionVoListMsg": optionTitle,
                                "goodsNum": 1
                              };
                              publicAddCartMenu(cartItem, false).then((val) {
                                _publicShowAddCart(temp,itemsFirst['homeImage']);

                                _changeInitialOption(itemsFirst['menuCode'], setFirstMenuState);
                                //更改显示购物车价格
                                getCartPriceTotal();
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: ScreenAdapter.height(10)),
                              width: ScreenAdapter.width(270),
                              height: ScreenAdapter.height(75),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorsUtil.hexToColor("#078E42"),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                /*image: new DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: AssetImage(
                                      'assets/images/public_index_submit.png'),
                                ),*/
                                //设置圆角
                                //borderRadius: new BorderRadius.circular((16.0)),
                              ),
                              child: Text(
                                  GString.getToString(
                                      this._checkLanguage, "add_option_cart"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(34),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(
                                        Gcolor.settlementBtnColor),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            //第二三个商品
            //showCategoryOneItemList(itemsTree),
          ],
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryOneItemList(items) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 2,
            childAspectRatio: 1),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryOneItemOne(items[index]);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryOneItemOne(item) {
    Offset temp;
    if (item['optionGroupVoList'].length > 0) {
      //循环option点击事件
      List<Widget> optionButtons = []; //先建一个数组用于存放循环生成的widget
      List optionButtonscount = []; //先建一个数组用于存放循环生成的widget
      for (var itemson in item['optionGroupVoList']) {
        if (itemson['optionVoList'].length > 0) {
          for (var optionSon in itemson['optionVoList']) {
            optionButtonscount.add("test1");
            optionButtons.add(InkWell(
              onTapDown: (details) {
                temp = new Offset(
                    details.globalPosition.dx, details.globalPosition.dy);

              },
              onTap: () async {

                _publicShowAddCart(temp,item['homeImage']);

                var checked_option = {
                  "optionCode": optionSon['optionCode'],
                  "mainTitle": optionSon['mainTitle'],
                  "currentPrice": optionSon['currentPrice'],
                  "bounds": optionSon['bounds'],
                };

                //加入刷新购物车
                var cartItem = {
                  "menuCode": item['menuCode'],
                  "mainTitle": item['mainTitle'],
                  "image": item['homeImage'],
                  "currentPrice": item['currentPrice'],
                  "optionGroupVoList": json.encode(checked_option),
                  "goodsNum": 1
                };
                try {
                  var result =
                      await controller.addToCart(cartItem, checkItem: false);
                  controller.getCardList();

                } catch (e) {
                  print(e);
                }
              },
              child: Container(
                width: ScreenAdapter.width(110),
                height: ScreenAdapter.height(55),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: new DecorationImage(
                    fit: BoxFit.fitWidth,
                    image: AssetImage('assets/images/redPutong.png'),
                  ),
                  //设置圆角
                  borderRadius: new BorderRadius.circular((16.0)),
                ),
                child: Text(optionSon['mainTitle'],
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(29),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                    )),
              ),
            ));
          }
        }
      }

      return Container(
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
                child: Image.asset('assets/images/logo.png',
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
                  //菜单Title
                  publicShowMenuTitle(item['mainTitle'],
                      GFontSize.mainFoodTitle, Gcolor.mainTitleColor),

                  //价格展示
                  publicShowMenuPrice(
                      item['currentPrice'],
                      GFontSize.mainPriceLift,
                      Gcolor.mainTitleColor,
                      GFontSize.mainPrice,
                      Gcolor.priceColor,
                      GFontSize.mainPriceRight,
                      Gcolor.mainTitleColor),
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
                children: optionButtons,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: ScreenAdapter.width(533),
        //height: ScreenAdapter.height(480),
        color: ColorsUtil.hexToColor(Gcolor.whiteColor),
        child: InkWell(
            onTapDown: (details) {
              temp = new Offset(
                  details.globalPosition.dx, details.globalPosition.dy);

            },
            onTap: () async {

              var cartItem = {
                "menuCode": item['menuCode'],
                "mainTitle": item['mainTitle'],
                "image": item['homeImage'],
                "currentPrice": item['currentPrice'],
                "optionGroupVoList": "",
                "optionVoListMsg": "",
                "goodsNum": 1
              };
              publicAddCartMenu(cartItem, false).then((val) {

                _publicShowAddCart(temp,item['homeImage']);
                //更改显示购物车价格
                getCartPriceTotal();
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                publicShowMenuImage(item['homeImage'], 530.0, 360.0),
                Container(
                  padding: EdgeInsets.only(
                    left: ScreenAdapter.width(25),
                    right: ScreenAdapter.width(25),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      //菜单Title
                      publicShowMenuTitle(item['mainTitle'],
                          GFontSize.mainFoodTitle, Gcolor.mainTitleColor),

                      //价格展示
                      publicShowMenuPrice(
                          item['currentPrice'],
                          GFontSize.mainPriceLift,
                          Gcolor.mainTitleColor,
                          GFontSize.mainPrice,
                          Gcolor.priceColor,
                          GFontSize.mainPriceRight,
                          Gcolor.mainTitleColor),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                    left: ScreenAdapter.width(25),
                    right: ScreenAdapter.width(25),
                  ),
                  child: publicShowMenuSubtitle(item["subtitle"]),
                ),
              ],
            )),
      );
    }
  }

  //第二个分类 小菜
  _showCategoryTwo(showItemList) {
    if (showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategoryTwoItemList(showItemList),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryTwoItemList(items) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 3,
            childAspectRatio: 0.97),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryTwoItemOne(items[index]);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryTwoItemOne(item) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: GestureDetector(
          onPanDown: (details) {
            temp = new Offset(
                details.globalPosition.dx, details.globalPosition.dy);

          },
          onTap: () async {

            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              var checkResult = _checkQtyBoundsCount(item['menuCode'], "");
              if (checkResult == false) {
                return;
              }
            }

            var cartItem = {
              "menuCode": item['menuCode'],
              "mainTitle": item['mainTitle'],
              "image": item['homeImage'],
              "currentPrice": item['currentPrice'],
              "optionGroupVoList": "",
              "optionVoListMsg": "",
              "goodsNum": 1
            };
            publicAddCartMenu(cartItem, true).then((val) {

              _publicShowAddCart(temp,item['homeImage']);

              //更改显示购物车价格
              getCartPriceTotal();
            });
          },
          child: Material(
            child: Stack(
              children: [
                Container(
                    //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(item['homeImage'], 350.0, 255.0),
                        SizedBox(
                          height: ScreenAdapter.height(10),
                        ),
                        Container(
                          //width: ScreenAdapter.width(20),
                          //height: ScreenAdapter.height(315),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: publicShowMenuTitle(
                                    item['mainTitle'],
                                    GFontSize.menuTwoListTitle,
                                    Gcolor.mainTitleColor),
                              ),
                              Container(
                                //width: ScreenAdapter.width(125),
                                //height: ScreenAdapter.height(315),
                                alignment: Alignment.centerRight,
                                padding: EdgeInsets.only(
                                    left: ScreenAdapter.width(5),
                                    right: ScreenAdapter.width(0)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    //价格展示
                                    publicShowMenuPrice(
                                        item['currentPrice'],
                                        GFontSize.menuTwopriceLift,
                                        Gcolor.mainTitleColor,
                                        GFontSize.menuTwoprice,
                                        Gcolor.priceColor,
                                        GFontSize.menuTwopriceRight,
                                        Gcolor.mainTitleColor),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenAdapter.height(10),
                        ),
                        Container(
                          //padding: EdgeInsets.only(
                              //left: ScreenAdapter.width(15),
                              //top: ScreenAdapter.height(20),
                              //right: ScreenAdapter.width(15)
                          //),
                          child: publicShowMenuSubtitle(item["subtitle"]),
                        ),
                      ],
                    )),
                //绝对定位 盖章
                publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第三个分类 定食
  _showCategoryThree(showItemList) {
    if (showItemList.length > 0) {
      return Container(
        padding: EdgeInsets.only(
            //left: ScreenAdapter.width(8),
            //right: ScreenAdapter.width(8),
            bottom: ScreenAdapter.height(15)),
        //height: 450,
        child: showCategoryThreeItemList(showItemList),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryThreeItemList(items) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return showCategoryThreeItemOne(items[index], index);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryThreeItemOne(item, index) {
    Offset temp;

    var subtitle = "";
    if (item["subtitle"]?.length > 0) {
      for (var i = 0; i < item["subtitle"].length; i++) {
        subtitle += item["subtitle"][i];
      }
    }

    return Container(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8)),
      child: Material(
        child: Container(
          padding: EdgeInsets.only(top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(10)),
          margin: EdgeInsets.only(left: ScreenAdapter.width(10), right: ScreenAdapter.width(10)),
          color: ColorsUtil.hexToColor(Gcolor.whiteColor),
          child: StatefulBuilder(
            builder: (BuildContext context, menuindex) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      //top: ScreenAdapter.height(5),
                      bottom: ScreenAdapter.height(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        publicShowMenuImage(item['homeImage'], 460.0, 310.0),
                        (item['optionGroupVoList']?.length > 0)
                            ? publicShowThreeMenuOptionGroupWidget(
                                item['menuCode'], menuindex)
                            : Container(
                                height: 0,
                              ),
                      ],
                    ),
                  ),

                  Divider(
                    height: 1,
                    color: Color.fromRGBO(227, 227, 227, 1),
                  ),
                  //标题价格
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //菜单Title
                            Container(
                              padding: EdgeInsets.only(
                                  right: ScreenAdapter.width(15)),
                              alignment: Alignment.center,
                              child: publicShowMenuTitle(item['mainTitle'],
                                  42.0, Gcolor.mainTitleColor),
                            ),
                            //副标题
                            subtitle != ""
                                ? Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${subtitle}',
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(
                                              GFontSize
                                                  .menuThreeListFoodSubtitle),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor)),
                                    ),
                                  )
                                : Container(
                                    width: 0,
                                  ),
                          ],
                        ),
                      )),
                      //价格展示 item['currentPrice']
                      Container(
                        padding: EdgeInsets.only(right: ScreenAdapter.width(30)),
                        width: ScreenAdapter.width(200),
                        alignment: Alignment.bottomRight,
                        child: publicShowMenuPrice(
                            _selectedMenuOptionChangePrice[item['menuCode']]+_addselectedMenuOptionChangePrice[item['menuCode']],
                            35.0,
                            Gcolor.mainTitleColor,
                            54.0,
                            Gcolor.priceColor,
                            28.0,
                            Gcolor.mainTitleColor),
                      ),

                      //确认按钮
                      InkWell(
                        onTapDown: (details) {
                          temp = new Offset(details.globalPosition.dx,
                              details.globalPosition.dy);

                        },
                        onTap: () {

                          //判断选择后option是否与optiongroup相等
                          var currentPrice = item['currentPrice'];
                          var optionCodeList = "";
                          var optionTitle = "";
                          if (item['optionGroupVoList']?.length > 0) {//item['optionGroupVoList'].length
                            if (_selectedMenuOptionList[item['menuCode']].length < _selectedMenuOptionCheckedNum[item['menuCode']]) {
                              showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                              return;
                            }

                            for (var optionItem
                                in _selectedMenuOptionList[item['menuCode']]) {
                              if (optionItem['currentPrice'] > 0) {
                                currentPrice += optionItem['currentPrice'];
                              }
                              optionCodeList += (optionCodeList != "")
                                  ? "," + optionItem['optionCode']
                                  : optionItem['optionCode'];
                              optionTitle += (optionTitle != "")
                                  ? "," + optionItem['mainTitle']
                                  : optionItem['mainTitle'];
                            }
                          }

                          var cartItem = {
                            "menuCode": item['menuCode'],
                            "mainTitle": item['mainTitle'],
                            "image": item['homeImage'],
                            "currentPrice": currentPrice,
                            "optionGroupVoList": optionCodeList,
                            "optionVoListMsg": optionTitle,
                            "goodsNum": 1
                          };
                          publicAddCartMenu(cartItem, false).then((val) {

                            _publicShowAddCart(temp,item['homeImage']);
                            _changeInitialOption(item['menuCode'], menuindex);
                            //更改显示购物车价格
                            getCartPriceTotal();
                          });
                        },
                        child: Container(
                          margin:
                              EdgeInsets.only(top: ScreenAdapter.height(15)),
                          width: ScreenAdapter.width(250),
                          height: ScreenAdapter.height(67),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#078E42"),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            /*image: new DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage(
                                  'assets/images/public_dingshi_submit.png'),
                            ),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((16.0)),*/
                          ),
                          child: Text(
                              GString.getToString(
                                  this._checkLanguage, "add_option_cart"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(32),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor(
                                    Gcolor.optionBtnColor),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  //第四个酒水分类
  _showCategoryFour(showItemList) {
    if (showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategoryFourItemList(showItemList),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryFourItemList(items) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8),
          //left: ScreenAdapter.width(15),
          //right: ScreenAdapter.width(15)
          ),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(7),
            crossAxisCount: 4,
            childAspectRatio: 0.42),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryFourItemOne(items[index]);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryFourItemOne(item) {
    Offset temp;

    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          onTapDown: (details) {
            temp = new Offset(
                details.globalPosition.dx, details.globalPosition.dy);

          },
          onTap: () async {

            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              var checkResult = _checkQtyBoundsCount(item['menuCode'], "");
              if (checkResult == false) {
                return;
              }
            }
            var cartItem = {
              "menuCode": item['menuCode'],
              "mainTitle": item['mainTitle'],
              "image": item['homeImage'],
              "currentPrice": item['currentPrice'],
              "optionGroupVoList": "",
              "optionVoListMsg": "",
              "goodsNum": 1
            };
            publicAddCartMenu(cartItem, true).then((val) {

              _publicShowAddCart(temp,item['homeImage']);
              //更改显示购物车价格
              getCartPriceTotal();
            });
          },
          child: Material(
            child: Stack(
              children: [
                Container(
                    //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(item['homeImage'], 260.0, 525.0),
                        SizedBox(
                          height: ScreenAdapter.height(2),
                        ),
                        Container(
                          //width: ScreenAdapter.width(1080),
                          //height: ScreenAdapter.height(315),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //菜单Title
                              Expanded(child: publicShowMenuTitle(
                                  item['mainTitle'],
                                  GFontSize.menuFourListTitle,
                                  Gcolor.mainTitleColor)),
                            ],
                          ),
                        ),
                        Container(
                          //padding: EdgeInsets.only(
                              //left: ScreenAdapter.width(15),
                              //top: ScreenAdapter.height(20),
                              //right: ScreenAdapter.width(15)),
                          child: publicShowMenuSubtitle(item["subtitle"]),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              //top: ScreenAdapter.height(8),
                              right: ScreenAdapter.width(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //价格展示
                              publicShowMenuPrice(
                                  item['currentPrice'],
                                  GFontSize.menuFourpriceLift,
                                  Gcolor.mainTitleColor,
                                  GFontSize.menuFourprice,
                                  Gcolor.priceColor,
                                  GFontSize.menuFourpriceRight,
                                  Gcolor.mainTitleColor),
                            ],
                          ),
                        ),
                       /* SizedBox(
                          height: ScreenAdapter.height(7),
                        ),*/

                      ],
                    )),
                //绝对定位 盖章
                publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第五个分类 期间限定
  _showCategoryFive(showItemList) {
    if (showItemList.length > 0) {
      return Container(
        padding: EdgeInsets.only(
            //left: ScreenAdapter.width(8),
            //right: ScreenAdapter.width(8),
            bottom: ScreenAdapter.height(15)),
        //height: 450,
        child: showCategoryFiveItemList(showItemList),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryFiveItemList(items) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return showCategoryFiveItemOne(items[index], index);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryFiveItemOne(item, index) {
    Offset temp;
    var subtitle = "";
    if (item["subtitle"].length > 0) {
      for (var i = 0; i < item["subtitle"].length; i++) {
        subtitle += item["subtitle"][i];
      }
    }

    return Container(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8)),
      child: Material(
        child: Container(
          padding: EdgeInsets.only(
              top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(10)),
          margin: EdgeInsets.only(
              left: ScreenAdapter.width(10), right: ScreenAdapter.width(10)),
          color: ColorsUtil.hexToColor(Gcolor.whiteColor),
          child: StatefulBuilder(
            builder: (BuildContext context, menuFiveindex) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      bottom: ScreenAdapter.height(5),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(item['homeImage'], 490.0, 325.0),
                        (item['optionGroupVoList']?.length > 0)
                            ? publicShowFiveMenuOptionGroupWidget(
                                item['menuCode'], menuFiveindex)
                            : Container(
                                height: 0,
                              ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Color.fromRGBO(227, 227, 227, 1),
                  ),

                  //标题价格
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.only(left: ScreenAdapter.width(10)),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            //菜单Title
                            Container(
                              padding: EdgeInsets.only(
                                  right: ScreenAdapter.width(15)),
                              child: publicShowMenuTitle(item['mainTitle'],
                                  42.0, Gcolor.mainTitleColor),
                            ),
                            //副标题
                            subtitle != ""
                                ? Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      '${subtitle}',
                                      style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(
                                              GFontSize
                                                  .menuThreeListFoodSubtitle),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor)),
                                    ),
                                  )
                                : Container(
                                    width: 0,
                                  ),
                          ],
                        ),
                      )),
                      //价格展示 item['currentPrice']
                      Container(
                        padding: EdgeInsets.only(right: ScreenAdapter.width(30)),
                        width: ScreenAdapter.width(200),
                        alignment: Alignment.bottomRight,
                        //alignment: Alignment.centerRight,
                        child: publicShowMenuPrice(
                            _selectedMenuOptionChangePrice[item['menuCode']]+_addselectedMenuOptionChangePrice[item['menuCode']],
                            35.0,
                            Gcolor.mainTitleColor,
                            54.0,
                            Gcolor.priceColor,
                            28.0,
                            Gcolor.mainTitleColor),
                      ),
                      //确认按钮
                      InkWell(
                        onTapDown: (details) {
                          temp = new Offset(details.globalPosition.dx, details.globalPosition.dy);
                        },
                        onTap: () {

                          //判断选择后option是否与optiongroup相等
                          var optionCodeList = "";
                          var optionTitle = "";
                          var currentPrice = item['currentPrice'];
                          if (item['optionGroupVoList']?.length > 0) {//item['optionGroupVoList'].length
                            if (_selectedMenuOptionList[item['menuCode']].length < _selectedMenuOptionCheckedNum[item['menuCode']]) {
                              showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                              return;
                            }

                            for (var optionItem in _selectedMenuOptionList[item['menuCode']]) {
                              if (optionItem['currentPrice'] > 0) {
                                currentPrice += optionItem['currentPrice'];
                              }
                              optionCodeList += (optionCodeList != "") ? "," + optionItem['optionCode'] : optionItem['optionCode'];
                              optionTitle += (optionTitle != "") ? "," + optionItem['mainTitle'] : optionItem['mainTitle'];
                            }
                          }

                          var cartItem = {
                            "menuCode": item['menuCode'],
                            "mainTitle": item['mainTitle'],
                            "image": item['homeImage'],
                            "currentPrice": currentPrice,
                            "optionGroupVoList": optionCodeList,
                            "optionVoListMsg": optionTitle,
                            "goodsNum": 1
                          };
                          publicAddCartMenu(cartItem, false).then((val) {

                            _publicShowAddCart(temp,item['homeImage']);

                            if (item['optionGroupVoList']?.length > 0) {
                              _changeInitialOption(item['menuCode'], menuFiveindex);
                            }
                            //更改显示购物车价格
                            getCartPriceTotal();
                          });
                        },
                        child: Container(
                          margin:
                              EdgeInsets.only(top: ScreenAdapter.height(15)),
                          width: ScreenAdapter.width(250),
                          height: ScreenAdapter.height(67),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ColorsUtil.hexToColor("#078E42"),
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            /*image: new DecorationImage(
                              fit: BoxFit.fitWidth,
                              image: AssetImage(
                                  'assets/images/public_dingshi_submit.png'),
                            ),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((16.0)),*/
                          ),
                          child: Text(
                              GString.getToString(
                                  this._checkLanguage, "add_option_cart"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(32),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor(
                                    Gcolor.optionBtnColor),
                              )),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  //购物车
  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    setState(() {
      _alignmentY = -1 + (metrics.pixels / metrics.maxScrollExtent) * 2;
    });
    return true;
  }

  getItemTotal(List items) {
    int sum = 0;
    items.forEach((e) {
      sum += e.currentPrice;
    });

    return sum.toString();
  }

  getCartPriceTotal() async {

    controller.getCardList();
    var total = await controller.getCartAllPrice();
      setState(() {
        _shopCartTotalPrice = total["totalPrice"] == null ? "0" : total["totalPrice"].toString();
      });

    //return sum.toString();
  }

  //购物车商品循环版本
  _showShoppingCart() {
    return Container(
      height: ScreenAdapter.height(330),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              width: ScreenAdapter.width(1080),
              height: ScreenAdapter.height(340),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(20),
                  top: ScreenAdapter.height(20),
                  right: ScreenAdapter.width(20),
                  bottom: ScreenAdapter.height(10)),
              child: Column(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Container(
                        height: ScreenAdapter.height(300),
                        child: Row(
                          children: [
                            Scrollbar(
                                child: SingleChildScrollView(
                              physics: ClampingScrollPhysics(),
                              child: Container(
                                width: ScreenAdapter.width(690),
                                height: ScreenAdapter.height(300),
                                color:
                                ColorsUtil.hexToColor(Gcolor.cartListColor),
                                child: Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    GetBuilder<HomePageController>(
                                      builder: (_) {
                                        if (controller.cartItems.length == 0) {
                                          return Center(
                                            child: Text(GString.getToString(
                                                this._checkLanguage, "cart_tag")),
                                          );
                                        }
                                        return ListView(
                                          shrinkWrap: true,
                                          children: controller.cartItems
                                              .map(
                                                  (d) => generateCartList(context, d))
                                              .toList(),
                                        );
                                      },
                                    ),
                                    //滚动条
                                    /*Container(
                                    alignment: Alignment(1, _alignmentY),
                                    padding: EdgeInsets.only(right: 0),
                                    child: Container(
                                      width: ScreenAdapter.width(20),
                                      height: ScreenAdapter.height(116),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius: BorderRadius.all(Radius.circular(20)),
                                          color: (controller.cartItems.length>4 ) ? ColorsUtil.hexToColor("#D0D0D0"):ColorsUtil.hexToColor(Gcolor.cartListColor),
                                      ),

                                    ),
                                  ) ,*/
                                  ],
                                ),
                              ),
                            )
                            ),

                            /*Container(
                              width: ScreenAdapter.width(58),
                              height: ScreenAdapter.height(272),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                            ),*/
                          ],
                        ),
                      )),
                      Container(
                        height: ScreenAdapter.height(290),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            /*InkWell(
                              onTap: () {
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
                                    image:
                                        AssetImage('assets/images/btn001.png'),
                                  ),
                                  //设置圆角
                                  borderRadius:
                                      new BorderRadius.circular((16.0)),
                                ),
                                child: Text(
                                    GString.getToString(
                                        this._checkLanguage, "cancle_button"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(36),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.settlementBtnColor),
                                    )),
                              ),
                            ),*/
                            SizedBox(height: ScreenAdapter.height(25)),
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
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.mainTitleColor),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: _shopCartTotalPrice.toString(),
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(
                                              GFontSize
                                                  .menusettlementBottomPrice),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.priceColor),
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "（${GString.getToString(this._checkLanguage, "show_price_front")}）", //" 円",
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(
                                              GFontSize
                                                  .menusettlementBottomPriceRight),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),


                            SizedBox(height: ScreenAdapter.height(18)),
                            InkWell(
                              onTap: () {
                                if (int.parse(_shopCartTotalPrice) ==0) {
                                  return false;
                                }


                               _doSubmitOrder();


                              },
                              child: Container(
                                width: ScreenAdapter.width(319),
                                height: ScreenAdapter.height(117),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(

                                  color: (int.parse(_shopCartTotalPrice) >0) ?ColorsUtil.hexToColor("#A61C1C") :ColorsUtil.hexToColor("#B1B0B0"),
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((16.0)),
                                ),
                                child: Text(
                                    GString.getToString(this._checkLanguage,
                                        "settlement_button"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(48),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.settlementBtnColor),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget generateCartList(BuildContext context, ShopItemModel d) {
    return Padding(
      padding: EdgeInsets.only(left:ScreenAdapter.width(5),top: ScreenAdapter.height(2),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(2)),
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
              onTap: () {
                Get.find<HomePageController>().removeFromCart(d.id ?? 0);
                //print("Item removed from cart successfully");
                controller.getCardList();
                //更改显示购物车价格
                getCartPriceTotal();
              },
              child: Container(
                width: ScreenAdapter.width(40),
                child: Image.asset('assets/images/delOne.png',
                    width: ScreenAdapter.width(30),
                    //height: ScreenAdapter.height(44),
                    fit: BoxFit.fill),
              ),
            ),
            Expanded(
                child: Container(
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(5),
                  top: ScreenAdapter.height(8),
                  bottom: ScreenAdapter.height(8)),
              //width: ScreenAdapter.width(495),
              child: RichText(
                text: TextSpan(
                    text: d.mainTitle,
                    style: TextStyle(
                        fontSize:
                            ScreenAdapter.fontSize(GFontSize.cartListTitle),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor)),
                    children: [
                      TextSpan(
                        text: " X${d.goodsNum}",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(
                              GFontSize.cartListTitleCount),
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                      (d.optionVoListMsg != "")
                          ? TextSpan(
                              text: "（${d.optionVoListMsg}）",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(
                                    GFontSize.cartListTitleTag),
                                color: ColorsUtil.hexToColor(
                                    Gcolor.mainTitleColor),
                              ),
                            )
                          : TextSpan(
                              text: "",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(
                                    GFontSize.cartListTitleTag),
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
                d.currentPrice.toString(),
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

  _showOrderEasyLoading(){
    var _showTag =Text(GString.getToString(this._checkLanguage, "settlement_noprint_tag"),
        style: TextStyle(
          fontSize: ScreenAdapter.fontSize(25),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
        ));
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        decoration: BoxDecoration(
          //设置边框
          border: new Border.all(color: ColorsUtil.hexToColor("#F9F9F9"), width: 0.5),
          //背景颜色
          color: Colors.white,
          //设置圆角
          borderRadius: new BorderRadius.circular((15.0)),
          //设置阴影
          boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#949191"), offset: Offset(1.0, 1.0), blurRadius: 1.5, spreadRadius: 1.5), ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            Container(
              //width: ScreenAdapter.width(400),
              height: ScreenAdapter.height(400),
              child: Image.asset('assets/images/backloading.gif',fit: BoxFit.fitHeight),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );

  }
  //提交订单
  _doSubmitOrder(){
    if(_machineCode !=""){
      _showOrderEasyLoading();
      /*EasyLoading.show(
        //status: 'loading...',
        indicator: Container(
          width: ScreenAdapter.width(400),
          child: Image.asset('assets/images/backloading.gif',fit: BoxFit.fitHeight),
        ),
        maskType: EasyLoadingMaskType.black,
      );*/

      var cartItems = controller.getcartItems;
      List selectedItem = [];


      for(var oneItem in cartItems){
        var optionMap = {};
        if(oneItem["optionGroupVoList"] == ""){
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "qty": oneItem["goodsNum"]
          };
        }else{
          var optionGroupVoList = oneItem["optionGroupVoList"];
          var itemsOption = optionGroupVoList.split(',');
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "optionList": itemsOption,
            "qty": oneItem["goodsNum"]
          };
        }
        selectedItem.add(optionMap);
      }
      var orderTotlaPrice = getItemTotal(controller.cartItems);
      var formData = {
        "language": this._checkLanguage,
        "machineCode": _machineCode,
        "orderLineList": selectedItem,
        "total": orderTotlaPrice
      };
      request('webBootOrder', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());

        if (response['code'] == 200) {
          EasyLoading.dismiss();

          Navigator.pushNamed(context, '/settlement',
              arguments: {
                "checkLanguage": this._checkLanguage,
                "machineCode": this._machineCode,
                "orderId" : response['data'],
                "totalPrice" : orderTotlaPrice.toString(),
              });

        }else{
          showToast(response['msg']);
        }
      });
    }
  }

/*  _showShoppingCartBottom() {
    return Container(
      height: ScreenAdapter.height(160),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              width: ScreenAdapter.width(1080),
              height: ScreenAdapter.height(160),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(20),
                  top: ScreenAdapter.height(10),
                  right: ScreenAdapter.width(20),
                  bottom: ScreenAdapter.height(10)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  this.cartnum != 0 ?
                  Badge(
                    badgeColor:ColorsUtil.hexToColor("#A61C1C"),
                    badgeContent: Text(
                      this.cartnum.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenAdapter.fontSize(36.0)),
                    ),
                    padding: EdgeInsets.all(15),
                    position:BadgePosition.topEnd(top: -4, end: 8),
                    child: Container(
                      //color: Colors.red,
                      width: ScreenAdapter.width(165),
                      height: ScreenAdapter.height(130),
                      key: floatKey,
                      alignment: Alignment.centerLeft,
                      child: Image.asset(
                        'assets/images/cart_bottom.png',
                        width: ScreenAdapter.width(135),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ):
                  Container(
                    //color: Colors.red,
                    width: ScreenAdapter.width(165),
                    height: ScreenAdapter.height(130),
                    key: floatKey,
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/images/cart_bottom.png',
                      width: ScreenAdapter.width(135),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.width(20)),

                  Container(
                    width: ScreenAdapter.width(440),
                    child: RichText(
                      text: TextSpan(
                          text: "¥",//GString.getToString(this._checkLanguage, "settlement_total_price"),
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(GFontSize.menusettlementBottomPriceLeft),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor(Gcolor.mainBottomSettlementColor),
                          ),
                          children: [
                            TextSpan(
                              text: getItemTotal(controller.cartItems),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(GFontSize.menusettlementBottomPrice),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.priceColor),
                              ),
                            ),
                            TextSpan(
                              text: "（${GString.getToString(this._checkLanguage, "show_price_front")}）",//" 円",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(GFontSize.menusettlementBottomPriceRight),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainBottomSettlementColor),
                              ),
                            ),

                          ]),
                    ),
                  ),

                  SizedBox(height: ScreenAdapter.height(30)),
                  InkWell(
                    onTap: () {
                      if (controller.cartItems.length == 0) {
                        showToast("请先选择菜品");
                        return false;
                      }
                      Navigator.pushNamed(context, '/settlement',
                          arguments: {
                            "checkLanguage": this._checkLanguage,
                            "machineCode": this._machineCode
                          });
                    },
                    child: Container(
                      width: ScreenAdapter.width(400),
                      height: ScreenAdapter.height(130),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor("#A61C1C"),
                        //设置圆角
                        borderRadius: new BorderRadius.circular((16.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/settlement_tag.png',
                            width: ScreenAdapter.width(80),
                            fit: BoxFit.fitWidth,
                          ),
                          SizedBox(width: ScreenAdapter.width(10),),
                          Text(
                              GString.getToString(this._checkLanguage,
                                  "settlement_button"),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(48),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(
                                    Gcolor.settlementBtnColor),
                              )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }*/

  //清空购物车弹出提示、
  showDialogTag() {
    AppTool().showCenterTipsAlter(
        context,
        _clearCartList,
        GString.getToString(this._checkLanguage, "tag_title"),
        GString.getToString(this._checkLanguage, "tag_content"),
        GString.getToString(this._checkLanguage, "tag_button_yes"),
        GString.getToString(this._checkLanguage, "tag_button_no"));
  }

  void _clearCartList(value) async {
    Get.find<HomePageController>().removeAllFromCart();

    controller.getCardList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: _listView(context),
      ),
    );
  }
}
