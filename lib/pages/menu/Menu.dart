
import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:auto_size_text/auto_size_text.dart';
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
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/fontSize.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/config/index.dart';
import 'package:foodorder/controller/homePageController.dart';
import 'package:foodorder/models/ItemModel.dart';
import 'package:foodorder/pages/home/Home.dart';
import 'package:foodorder/routers/custom_router.dart';
import 'package:foodorder/services/CachedNetworkImageManager.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/HttpService.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/NetWorkImageSSL.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/SqfliteHelper.dart';
import 'package:foodorder/services/addCartParabola.dart';
import 'package:foodorder/services/formatMoney.dart';
import 'package:foodorder/services/itemService.dart';
import 'package:foodorder/services/logUtil.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:foodorder/services/showImage.dart';
import 'package:foodorder/widget/LoadState.dart';
import 'package:foodorder/widget/ToastCompoent.dart';
import 'package:foodorder/widget/iosAlter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:foodorder/services/Storage.dart';
import 'package:badges/badges.dart' as badges;

import 'package:foodorder/services/GetxStorage.dart';
import 'SelectPayment.dart';

class MenuPage extends StatefulWidget {
  Map arguments;

  MenuPage({Key key, this.arguments}) : super(key: key);

  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage>  with AutomaticKeepAliveClientMixin {

  bool get wantKeepAlive =>true;

  Storage storageService = Storage();

  FToast fToast;

  ItemServices itemServices = ItemServices();
  List topMenu = [];
  Map showItem = {};

  HomePageController controller = Get.put(HomePageController());
  var classTag;

  //默认语言包选择
  var _checkLanguage = "JP";

  //购物车抛物线

  String _machineCode = "";

  var _menuOption = {}; //牛肉面及定食的option数组
  var _noChangeinitialmenuOption = {}; //牛肉面及定食的option数组，不做改变
  var _initialMenuOption = {}; //牛肉面及定食的初始option数组
  var _selectedMenuOptionList = {}; //牛肉面选中的option组成的数组
  var _selectedMenuOptionCheckedNum = {}; //牛肉面默认选中的option 数量

  var _selectedMenuOptionChangePrice = {}; //牛肉面默认选中的option 价格
  var _addselectedMenuOptionChangePrice = {}; //牛肉面默认选中的option 需要增加的加个


  var _shopCartTotalPrice = "0";
  var _showCartTotalGoodsNum = 0;
  var cartnum = 6;

  //就餐类型
  var _dining_type = "1"; //1 堂食  2 外袋  3两种都可以支付
  var _mealType = false; //用于判断下单
  var _isAllowPos = "0"; //1 使用信用卡刷卡  0 不可使用
  var _pos_ip = "";
  var _pos_port = "";

  var _payment_method_num = "0"; //支付类型选择


  //顶部展示支付类型
  var _showWechat = false;
  var _showAlipay = false;
  var _showPayPay = false;
  var _showCreditCard = false;
  var _showCash = false;

  var _showauPay = false;
  var _showdPay = false;
  var _showrPay = false;
  var _showmPay = false;

  var _showPosEdy = false;
  var _showPosiD = false;
  var _showPosIC = false;
  var _showPosQUICPay = false;
  var _showPosWAON = false;
  var _showPosnanaco = false;
  var _showOpenPayment = false;

  var _showVisa = false;
  var _showMaster = false;
  var _showJcb = false;
  var _showUnionPay = false;
  var _showAmericanExpress = false;
  var _showDinersClub = false;

  var _optionMaxNum = 12;
  var _optionGroupMaxNum = 10;

  //如果下单时候报错，则查看是否因为库存不足
  var _menuLackMap = {};
  var _doSubmitOrderId = "";



  @override
  void initState() {
    super.initState();
    fToast = FToast();
    // if you want to use context from globally instead of content we need to pass navigatorKey.currentContext!
    fToast.init(context);

    this._checkLanguage = widget.arguments['checkLanguage'];
    _mealType = widget.arguments["mealType"];
    _getMachineInfo();


    getCartPriceTotal();

    EasyLoading.dismiss();

    //监听是否展示现金的广播
    eventBus.on<setShowCashEvent>().listen((event) {
      _listenGetMachineActivateInfo();
    });

    //监听清除购物车的广播
    eventBus.on<clearCartEvent>().listen((event) {
      _clearCartList();
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    eventBus.fire(new clearCartEvent('支付成功...'));

    ImageCache _imageCache = PaintingBinding.instance.imageCache;

    _imageCache.clear();

    _imageCache.clearLiveImages();
    AssetsAudioPlayer.newPlayer().dispose();

    super.dispose();

  }




  //页面加载状态，默认为加载中
  LoadDataState _layoutState = LoadDataState.State_Loading;

  Widget _listView(BuildContext context) {
    return LoadStateLayout(
      state: _layoutState,
      emptyRetry: () {
        setState(() {
          _layoutState = LoadDataState.State_Empty;
        });
        this._getBookingBootMenu();
      },
      errorRetry: () {
        setState(() {
          _layoutState = LoadDataState.State_Error;
        });
        this._getBookingBootMenu();
      }, //错误按钮点击过后进行重新加载
      successWidget: Column(
        children: [
          //顶部导航
          Container(
            width: ScreenAdapter.getScreenWidth(),
            height: ScreenAdapter.height(95),
            padding: EdgeInsets.only(left: ScreenAdapter.width(10), right: ScreenAdapter.width(20)),
            alignment: Alignment.bottomLeft,
            decoration: BoxDecoration(
              color: ColorsUtil.hexToColor("#000000"),
              /*image: new DecorationImage(
                alignment: Alignment.centerRight,
                fit: BoxFit.fitHeight,
                image: AssetImage(GImage.getImageString(_shopInfo, "logo")),
              ),*/
            ),
            child: showTopCategoryMenu(),
          ),

          Expanded(
              child: RepaintBoundary(
                child: Container(
                  color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                  height: ScreenAdapter.height(1480),
                  child: showMiddleMenuList(),
                ),
              )),

          _showShoppingCart(),

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

      _getSystemSettingInfo();
    }
  }

  _getSystemSettingInfo() async {
    Map systemSettingInfo = await HomeServices.getSystemSettingInfo();

    setState(() {
      _dining_type = systemSettingInfo['diningType'];
      _isAllowPos = systemSettingInfo['isAllowPos'];
    });
    _getMachineActivateInfo();

  }

  //获取展示支付方式
  _getMachineActivateInfo() async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();

    setState(() {
      this._showCash = systemSettingInfo['showCash'];
      this._showWechat = systemSettingInfo['showWechat'];
      this._showAlipay = systemSettingInfo['showAlipay'];
      this._showPayPay = systemSettingInfo['showPayPay'];
      this._showCreditCard = systemSettingInfo['showCreditCard'];

      _showauPay = systemSettingInfo['au_Pay'];
      _showdPay = systemSettingInfo['d_Pay'];
      _showrPay = systemSettingInfo['R_Pay'];
      _showmPay = systemSettingInfo['m_Pay'];

      _showPosEdy = systemSettingInfo['pos_Edy'];
      _showPosiD = systemSettingInfo['pos_iD'];
      _showPosIC = systemSettingInfo['pos_IC'];
      _showPosQUICPay = systemSettingInfo['pos_QUICPay'];
      _showPosWAON = systemSettingInfo['pos_WAON'];
      _showPosnanaco = systemSettingInfo['pos_nanaco'];

      _showVisa = systemSettingInfo['show_visa'];
      _showMaster = systemSettingInfo['show_master'];
      _showJcb = systemSettingInfo['show_jcb'];
      _showUnionPay = systemSettingInfo['show_unionPay'];
      _showAmericanExpress = systemSettingInfo['show_americanExpress'];
      _showDinersClub = systemSettingInfo['show_dinersClub'];
    });
    _getBookingBootMenu();
  }

  _listenGetMachineActivateInfo() async {
    Map systemSettingInfo = await HomeServices.getMachineActivateData();
    var machineActivateData = {
      "showCash":false,
      "showWechat":systemSettingInfo['showWechat'],
      "showAlipay":systemSettingInfo['showAlipay'],
      "showPayPay":systemSettingInfo['showPayPay'],
      "showCreditCard":systemSettingInfo['showCreditCard'],
      "au_Pay":systemSettingInfo['au_Pay'],
      "d_Pay":systemSettingInfo['d_Pay'],
      "R_Pay":systemSettingInfo['R_Pay'],
      "m_Pay":systemSettingInfo['m_Pay'],
    };
    Storage.setString('smartwe_machineActivateData', json.encode(machineActivateData));
    GetxStorage.setData('smartwe_machineActivateData', json.encode(machineActivateData));
    if(mounted){
      setState(() {
        this._showCash = false;
        this._showWechat = systemSettingInfo['showWechat'];
        this._showAlipay = systemSettingInfo['showAlipay'];
        this._showPayPay = systemSettingInfo['showPayPay'];
        this._showCreditCard = systemSettingInfo['showCreditCard'];

        _showauPay = systemSettingInfo['au_Pay'];
        _showdPay = systemSettingInfo['d_Pay'];
        _showrPay = systemSettingInfo['R_Pay'];
        _showmPay = systemSettingInfo['m_Pay'];

        _showPosEdy = systemSettingInfo['pos_Edy'];
        _showPosiD = systemSettingInfo['pos_iD'];
        _showPosIC = systemSettingInfo['pos_IC'];
        _showPosQUICPay = systemSettingInfo['pos_QUICPay'];
        _showPosWAON = systemSettingInfo['pos_WAON'];
        _showPosnanaco = systemSettingInfo['pos_nanaco'];

        _showVisa = systemSettingInfo['show_visa'];
        _showMaster = systemSettingInfo['show_master'];
        _showJcb = systemSettingInfo['show_jcb'];
        _showUnionPay = systemSettingInfo['show_unionPay'];
        _showAmericanExpress = systemSettingInfo['show_americanExpress'];
        _showDinersClub = systemSettingInfo['show_dinersClub'];
      });
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
        //2、保存商品信息
        List myList = response['data']['categoryVoList'];
        //如果菜单为空则返回言语选择页面并给出提示
        if(myList.length == 0 || null == myList || "" == myList){
          showToast("少々お待ちください");
          sleep(Duration(milliseconds: 2000));
          Navigator.of(context).pop();
        }

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
            showItem[categoryVoList['categoryCode']] = categoryVoList['menuVoList'];

            //该分类下有option，先初始化页面数据
            if (categoryVoList['menuVoList']?.length > 0) {
              for (var menuVoList in categoryVoList['menuVoList']) {
                var _addOptionPrice = 0;
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
                        attr[m]['optionVoList'][n]["groupTitle"]=attr[m]["groupName"];
                        tempArr.add(attr[m]['optionVoList'][n]);
                        initalCode.add(attr[m]['optionVoList'][n]['optionCode']);

                        _addOptionPrice += attr[m]['optionVoList'][n]["currentPrice"];
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
                _addselectedMenuOptionChangePrice[menuVoList['menuCode']] = _addOptionPrice;
              }
            }


            //执行完后过 加载动画
            _layoutState = LoadDataState.State_Success;
          }
        });
      } else {
        showToast(response['msg']);
        sleep(Duration(milliseconds: 2000));
        Navigator.of(context).pop();
      }
    });

    //print(_menuOption);
  }


  //限量商品请求接口
  _checkQtyBoundsCount(item, optionCode) async {

    var result = await controller.getCartItemNum(item['menuCode']);

    if(result>=item['qtyBounds']){
      var showString = GString.getToString(this._checkLanguage,"show_storage_num_error");
      showToast("${showString}");
      return;
    }else{
      //如果option 存在，则弹出option
      if(item['optionGroupVoList']?.length > 0){
        _publicShowOneItemWidget(item);
      }else{
        _publicAddCart(item);
      }
    }

  }

  _publicAddCart(item) async {
    var cartItem = {
      "menuCode": item['menuCode'],
      "mainTitle": item['mainTitle'],
      "image": item['homeImage'],
      "currentPrice": item['currentPrice'],
      "unitPrice": item['currentPrice'],
      "optionGroupVoList": "",
      "optionVoListMsg": "",
      "goodsNum": 1,
      "qtyBounds": item['qtyBounds']
    };
    publicAddCartMenu(cartItem, true).then((val) {

      if(val != false){
        _publicShowAddCartNew();
      }

      //更改显示购物车价格
      getCartPriceTotal();
    });
  }


  //顶部分类导航
  showTopCategoryMenu() {
    List<Widget> categoryMenus = []; //先建一个数组用于存放循环生成的widget
    List MenuColor = ["#A61C1C","#894911","#078E42","#E8B854","#4C7FBC","#B5C99A"];
    var menuIndex = 0;
    for (var item in topMenu) {
      if(menuIndex >5) menuIndex = 0;

      categoryMenus.add(InkWell(
        //enableFeedback: false,
        onTap: () {
          setState(() {
            classTag = item['categoryCode'];
          });
        },
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(right: ScreenAdapter.width(6)),
              padding: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
              width: ScreenAdapter.width(165),
              //height: (classTag == item['categoryCode']) ? ScreenAdapter.height(75) : ScreenAdapter.height(65),
              height: ScreenAdapter.height(65),
              alignment: Alignment.center,
              decoration: (classTag == item['categoryCode']) ? BoxDecoration(
                //设置边框
                //border: new Border.all(color: ColorsUtil.hexToColor("#F9F9F9"), width: 0.5),
                //背景颜色
                color: ColorsUtil.hexToColor(MenuColor[menuIndex]),
                //设置圆角
                //borderRadius: new BorderRadius.circular((15.0)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                //设置阴影
                //boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#949191"), offset: Offset(1.0, 1.0), blurRadius: 1.5, spreadRadius: 1.5), ],
              ) : BoxDecoration(
                //背景颜色
                color: ColorsUtil.hexToColor(MenuColor[menuIndex]),
              ),
              child: Center(
                //加上Center让文字居中
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: ScreenAdapter.width(20),
                    maxWidth: ScreenAdapter.width(165),
                    minHeight: ScreenAdapter.height(30),
                    maxHeight: ScreenAdapter.height(65),
                  ),
                  child: AutoSizeText(
                    item['categoryName'],
                    style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(30),
                        color: ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                        fontWeight: FontWeight.w600
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            (classTag == item['categoryCode'])
                ? Positioned(
                right: ScreenAdapter.width(71),
                bottom: 0,
                child: Container(
                  alignment: Alignment.center,
                  child: Image.asset(
                    GImage.getImageString("imgpublic", "menu_up"),
                    width: ScreenAdapter.width(35),
                    fit: BoxFit.fitWidth,
                    color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                  ),
                ))
                : Container(
              height: 0,
            ),
          ],
        ),
      ));

      menuIndex++;
    }

    //categoryMenus.add();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Container(
            width: ScreenAdapter.width(900),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: categoryMenus,
                )
              ],
            ),
          ),
        ),
        Container(
          //alignment: Alignment.centerRight,
          child: InkWell(
            enableFeedback: false,
            onTap: () {
              controller.removeAllFromCart();
              Future.delayed(Duration(milliseconds: 200),() async {
                Navigator.of(context).pop();
              });

            },
            child: Container(
              padding: EdgeInsets.only(bottom: ScreenAdapter.height(5)),
              margin: EdgeInsets.only(left: ScreenAdapter.width(15),bottom: ScreenAdapter.height(5),right: ScreenAdapter.width(5),),
              width: ScreenAdapter.width(115),
              height: ScreenAdapter.height(55),
              //alignment: Alignment.center,
              /*decoration: BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.fitWidth,
                  image: AssetImage(GImage.getImageString("imgpublic", "backbutton_top")),
                ),
              ),*/
              decoration: BoxDecoration(
                //color: Color(0x11111111),
                image: DecorationImage(
                  //alignment: Alignment.topCenter,
                    image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                    fit: BoxFit.fill),
              ),
              child: Center(
                //加上Center让文字居中
                child: Text(
                  GString.getToString(this._checkLanguage, "top_back_button"),
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(22),
                      color: ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }

  //中间分类页面
  showMiddleMenuList() {
    for (var item in topMenu) {
      if (classTag == item['categoryCode']) {
        if (item['showType'] == "featured") {
          return _showCategoryOne(showItem[classTag]);
        } else if (item['showType'] == "table") { //350.0, 350.0
          return _showCategoryTwo(showItem[classTag]);
          //return _showCategoryEight(showItem[classTag]);
        } else if (item['showType'] == "table_v1") { //350.0, 350.0
          return _showCategoryTwo(showItem[classTag],popupType: "v1");
          //return _showCategoryEight(showItem[classTag]);
        } else if (item['showType'] == "block") { //350.0, 350.0
          return _showCategoryThree(showItem[classTag]);
        } else if (item['showType'] == "grid") { //260.0, 400.0
          return _showCategoryFour(showItem[classTag]);
        }else if (item['showType'] == "waterfall") { //400.0, 260.0
          return _showCategoryFive(showItem[classTag]);
        } else if (item['showType'] == "double_column") { //530.0, 530.0
          return _showCategorySix(showItem[classTag]);
        } else if (item['showType'] == "double_column_v1") { //530.0, 530.0
          return _showCategorySix(showItem[classTag],popupType: "v1");
        } else if (item['showType'] == "three_column") { //350.0, 440.0
          return _showCategorySeven(showItem[classTag]);
        } else if (item['showType'] == "three_column_v1") { //350.0, 440.0
          return _showCategorySeven(showItem[classTag],popupType: "v1");
        } else if (item['showType'] == "mixed_column") { //混合模式 底部一行3列710.0, 710.0 350.0, 310.0 350.0, 350.0
          return _showCategoryEight(showItem[classTag]);
          //return _showCategoryNine(showItem[classTag]);
        } else if (item['showType'] == "mixed_column_v1") { //混合模式 底部一行3列710.0, 710.0 350.0, 310.0 350.0, 350.0
          return _showCategoryEight(showItem[classTag],popupType: "v1");
          //return _showCategoryNine(showItem[classTag]);
        } else if (item['showType'] == "mixed_two_column") { //混合模式 底部一行2列 710.0, 710.0 350.0, 310.0 530.0, 530.0
          return _showCategoryNine(showItem[classTag]);
        } else if (item['showType'] == "mixed_two_column_v1") { //混合模式 底部一行2列 710.0, 710.0 350.0, 310.0 530.0, 530.0
          return _showCategoryNine(showItem[classTag],popupType: "v1");
        }else{
          return _showCategoryTwo(showItem[classTag]);
        }
      }
    }
  }

  playQRScannerSound() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/14428.wav"),
      autoStart: true,
      volume: 0.3,
    );
  }

  deleteItemSound() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/697.wav"),
      autoStart: true,
      volume: 0.8,
    );
  }
  //公共展示加入购物车动画
  _publicShowAddCartNew(){

    //ToastCompoent.toast(context,msg: "",img: GImage.getImageString("imgpublic", "checked_green"),showTime:400,sound: "1");

    Widget toast = Container(
      color: Colors.transparent,
      child: Image.asset(GImage.getImageString("imgpublic", "checked_green"),width: ScreenAdapter.width(150),height: ScreenAdapter.height(150)),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(milliseconds: 500),
    );
    playQRScannerSound();


  }


  //公共设置价格
  publicShowMenuPrice(currentPrice,originalPrice, priceFrontFontSize, priceFrontFontColor, priceFontSize, priceFontColor, priceBackFontSize, priceBackFontColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if(originalPrice!= null && originalPrice !="" && originalPrice != currentPrice)
        Container(
          padding: EdgeInsets.only(bottom: ScreenAdapter.height(3)),
          //color: Colors.red,
          child: RichText(
            text: TextSpan(
                text: "${GString.getToString(this._checkLanguage, "show_original_price_front")}",//¥GString.getToString(this._checkLanguage, "show_price_front"),
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(priceFrontFontSize)/1.8,
                  fontWeight: FontWeight.w500,
                  color: ColorsUtil.hexToColor("#485460"),
                  decoration: TextDecoration.lineThrough, // 添加中划线
                  decorationColor: ColorsUtil.hexToColor("#485460"), // 可以设置中划线的颜色
                  decorationThickness: 2.0, // 可以设置中划线的厚度
                  textBaseline: TextBaseline.alphabetic,
                ),
                children: [
                  TextSpan(
                    text: formatMoney(originalPrice.toString()),
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(priceFontSize)/1.8,
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor("#485460"),
                      decoration: TextDecoration.lineThrough, // 添加中划线
                      decorationColor: ColorsUtil.hexToColor("#485460"), // 可以设置中划线的颜色
                      decorationThickness: 2.0, // 可以设置中划线的厚度
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  TextSpan(
                    text: "円",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(priceFontSize)/2.2,
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor("#485460"),
                      decoration: TextDecoration.lineThrough, // 添加中划线
                      decorationColor: ColorsUtil.hexToColor("#485460"),// 可以设置中划线的颜色
                      decorationThickness: 2.0, // 可以设置中划线的厚度
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ]),
          ),
        ),
        SizedBox(width: ScreenAdapter.width(15),),
        Container(
          //color: Colors.blueGrey,
          alignment: Alignment.bottomRight,
          child: RichText(
            text: TextSpan(
                text: "¥",//¥GString.getToString(this._checkLanguage, "show_price_front"),
                style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(priceFrontFontSize),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(priceFrontFontColor),
                  textBaseline: TextBaseline.alphabetic,
                ),

                children: [
                  TextSpan(
                    text: formatMoney(currentPrice.toString()),
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(priceFontSize),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(priceFontColor),
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  TextSpan(
                    text: "（${GString.getToString(this._checkLanguage, "show_price_front")}）",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(priceFontSize)/2.5,
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(priceFontColor),
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                ]),
          ),
        ),
      ],
    );
  }

  //公共设置菜单Title
  publicShowMenuTitle(mainTitle, mainTitleFontSize, mainTitleFontColor) {
    return Text(
      mainTitle,
      overflow: TextOverflow.ellipsis, //长度溢出后显示省略号
      maxLines: 2,
      style: TextStyle(
          fontSize: ScreenAdapter.fontSize(mainTitleFontSize),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(mainTitleFontColor)),
    );
  }

  //公共设置标签 subTitle
  publicShowMenuSubtitle(subtitleList) {
    //标签循环相关
    if (subtitleList != null && subtitleList.length > 0) {
      var subtitle ="";
      if (subtitleList != null && subtitleList?.length > 0) {
        for (var i = 0; i < subtitleList.length; i++) {
          subtitle += subtitleList[i];
        }
      }
      return Container(
        padding: EdgeInsets.only(left:ScreenAdapter.width(5),top:ScreenAdapter.height(5),right:ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),

        child: Text(subtitle,
          style: TextStyle(
              fontSize: ScreenAdapter.fontSize(GFontSize.menuTwoTitleTag),
              color: ColorsUtil.hexToColor("#000000")),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
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
          GImage.getImageString("imgpublic", "shouqing_png"),
          width: ScreenAdapter.width(120),
          fit: BoxFit.fitWidth,
        ),
      );
    } else if(bounds > 0){
      var showString = GString.getToString(this._checkLanguage, "show_product_restrictions").replaceAll('%%', bounds.toString());
      return Positioned(
        right: ScreenAdapter.width(10),
        top: ScreenAdapter.height(10),
        child: Container(
          //width: ScreenAdapter.width(230),
          height: ScreenAdapter.height(55),
          padding: EdgeInsets.only(left:ScreenAdapter.width(5),top:ScreenAdapter.height(5),right:ScreenAdapter.width(5),bottom: ScreenAdapter.height(5)),
          decoration: BoxDecoration(
            color: ColorsUtil.hexToColor("#A61C1C"),
            //borderRadius: BorderRadius.all(Radius.circular(8.0)),
            border: Border.all(
              color: ColorsUtil.hexToColor("#A61C1C"),
              width: 1,
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
                "${showString}",
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(24),
                    color: ColorsUtil.hexToColor("#FFFFFF"))
            ),
          ),
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
    if(cartItem['qtyBounds'] >0){
      var checkresult = await controller.getCartItemNum(cartItem['menuCode']);
      if(checkresult>=cartItem['qtyBounds']){
        var showString = GString.getToString(this._checkLanguage,"show_storage_num_error");
        showToast("${showString}");
        return false;
      }
    }

    var result = false;
    try {
      result = await controller.addToCart(cartItem, checkItem: checkItem);
      controller.getCardList();


    } catch (e) {
      print(e);
      result = false;
    }
    return result;
  }

  //公共购物车加减
  publicChangeCartMenuCount(cartItem, changeType) async {

    var result;
    try {
      if(changeType == 'add'){
        if(cartItem['qtyBounds'] >0){
          var checkresult = await controller.getCartItemNum(cartItem['menuCode']);
          if(checkresult>=cartItem['qtyBounds']){
            var showString = GString.getToString(this._checkLanguage,"show_storage_num_error");
            showToast("${showString}");
            return;
          }else{
            result = await controller.addToCartNum(cartItem);
          }
        }else if(cartItem['qtyBounds'] <0){
          result = await controller.addToCartNum(cartItem);
        }

      }else{
        result = await controller.reduceToCart(cartItem);
      }

      controller.getCardList();


    } catch (e) {
      print(e);
      result = 0;
    }
    return result;
  }

  //改变选项
  _changeOption(menuCode, groupCode, optionCode, setMenuState) {
    //playQRScannerSound();

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

  _changeOptionv1(menuCode, groupCode, optionCode, setMenuState) {
    //playQRScannerSound();

    var attr = _menuOption[menuCode];
    for (var i = 0; i < attr.length; i++) {
      if (attr[i]["groupCode"] == groupCode) {
        //如果是多选，那么需要判断该组option数量是否超过最大值
        if(int.parse(attr[i]["multipleState"]) >1){
          var current_option_checked = 0;
          var current_incloud_option_checked = 0;
          for (var n = 0; n < attr[i]['optionVoList'].length; n++) {
            if(attr[i]['optionVoList'][n]["checked"] == true && attr[i]['optionVoList'][n]["optionCode"] != optionCode){
              current_option_checked++;
            }
            /*if((attr[i]['optionVoList'][n]["checked"] == true && attr[i]['optionVoList'][n]["optionCode"] != optionCode )
                || (attr[i]['optionVoList'][n]["optionCode"] == optionCode && attr[i]['optionVoList'][n]["checked"] == false)
            ){
print("加1了");
              current_incloud_option_checked++;
            }*/
          }

          if(current_option_checked >=int.parse(attr[i]["multipleState"])){
            var showTag = GString.getToString(this._checkLanguage, "menu_option_more_multipleState");
            showToast("${showTag.replaceAll("%%", attr[i]["multipleState"])}");
            //showToast("该组选项不能超过${attr[i]["multipleState"]}个");
            break;
          }

          /*if(current_incloud_option_checked < int.parse(attr[i]["smallest"])){
            showToast("该组选项不能小于${attr[i]["smallest"]}个");
            break;
          }*/

        }
        for (var j = 0; j < attr[i]['optionVoList'].length; j++) {
          if(attr[i]["multipleState"] == "1"){
            attr[i]['optionVoList'][j]["checked"] = false;
            if (attr[i]['optionVoList'][j]["optionCode"] == optionCode) {
              attr[i]['optionVoList'][j]["checked"] = !attr[i]['optionVoList'][j]["checked"];
            }
          }else{
            if (attr[i]['optionVoList'][j]["optionCode"] == optionCode) {
              attr[i]['optionVoList'][j]["checked"] = !attr[i]['optionVoList'][j]["checked"];
            }
          }

        }
      }
    }
    setMenuState(() {
      _menuOption[menuCode] = attr;
    });

    _getSelectedAttrValuev1(menuCode, attr, setMenuState);
  }

  //获取选中的值
  _getSelectedAttrValuev1(menuCode, optionGroupList, setMenuState) {
    var _list = optionGroupList;
    List tempArr = [];
    var selectPrice = 0;
    for (var i = 0; i < _list.length; i++) {
      for (var j = 0; j < _list[i]['optionVoList'].length; j++) {
        if (_list[i]['optionVoList'][j]['checked'] == true) {
          var selectMapItem = {
            "groupCode": _list[i]["groupCode"],
            "groupTitle": _list[i]["groupName"],
            "optionCode": _list[i]['optionVoList'][j]["optionCode"],
            "mainTitle": _list[i]['optionVoList'][j]["mainTitle"],
            "currentPrice": _list[i]['optionVoList'][j]["currentPrice"],
          };
          tempArr.add(selectMapItem);


          selectPrice +=_list[i]['optionVoList'][j]["currentPrice"];


        }
      }
    }

    setMenuState(() {
      _selectedMenuOptionList[menuCode] = tempArr;
      _addselectedMenuOptionChangePrice[menuCode] = selectPrice;
    });
    tempArr = [];
  }

  //初始化默认option选项
  _changeInitialOption(menuCode, setMenuState) {
    var attr = _menuOption[menuCode];
    var initMenuOption = _noChangeinitialmenuOption[menuCode];
    var _addOptionPrice = 0;

    if(attr != null){
      for (var i = 0; i < attr.length; i++) {
        for (var j = 0; j < attr[i]['optionVoList'].length; j++) {
          var check = initMenuOption.any((e) => e ==attr[i]['optionVoList'][j]["optionCode"]);
          if(true == check){
            attr[i]['optionVoList'][j]["checked"] = true;
            _addOptionPrice += attr[i]['optionVoList'][j]["currentPrice"];
          }else{
            attr[i]['optionVoList'][j]["checked"] = false;
          }

        }
      }
    }

    setMenuState(() {
      _menuOption[menuCode] = attr;
      _selectedMenuOptionList[menuCode] = _initialMenuOption[menuCode];
      _addselectedMenuOptionChangePrice[menuCode] = _addOptionPrice;
    });
  }
  _changeInitialAllOption(menuCode) {
    var attr = _menuOption[menuCode];
    var initMenuOption = _noChangeinitialmenuOption[menuCode];
    var _addOptionPrice = 0;

    if(attr != null){
      for (var i = 0; i < attr.length; i++) {
        for (var j = 0; j < attr[i]['optionVoList'].length; j++) {
          var check = initMenuOption.any((e) => e ==attr[i]['optionVoList'][j]["optionCode"]);
          if(true == check){
            attr[i]['optionVoList'][j]["checked"] = true;
            _addOptionPrice += attr[i]['optionVoList'][j]["currentPrice"];
          }else{
            attr[i]['optionVoList'][j]["checked"] = false;
          }

        }
      }
    }

    setState(() {
      _menuOption[menuCode] = attr;
      _selectedMenuOptionList[menuCode] = _initialMenuOption[menuCode];
      _addselectedMenuOptionChangePrice[menuCode] = _addOptionPrice;
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
            "groupTitle": _list[i]["groupName"],
            "optionCode": _list[i]['optionVoList'][j]["optionCode"],
            "mainTitle": _list[i]['optionVoList'][j]["mainTitle"],
            "currentPrice": _list[i]['optionVoList'][j]["currentPrice"],
          };
          tempArr.add(selectMapItem);


          selectPrice +=_list[i]['optionVoList'][j]["currentPrice"];


        }
      }
    }

    setMenuState(() {
      _selectedMenuOptionList[menuCode] = tempArr;
      _addselectedMenuOptionChangePrice[menuCode] = selectPrice;
    });
    tempArr = [];
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
            RichText(
              text: TextSpan(
                  text: "${optionGroupVoList[i]['groupName']}",
                  //GString.getToString(this._checkLanguage, "show_price_front"),
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(24.0),
                    fontWeight: FontWeight.w500,
                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                  ),
                  children: [
                    TextSpan(
                      text: (optionGroupVoList[i]['remark'] !=null && optionGroupVoList[i]['remark']!="")?" ${optionGroupVoList[i]['remark']}":"",
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(18.0),
                        fontWeight: FontWeight.w200,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                      ),
                    ),
                  ]),
            )
          ],
        ),
      ));

      for (var j = 0; j < optionVoList.length; j++) {
        var optionVolistSon = optionVoList[j];
        var buttonColor = [];
        if (optionVolistSon['buttonColorValue'] != null && optionVolistSon['buttonColorValue'] != "") {
          buttonColor = optionVolistSon['buttonColorValue'].split(',');
        }
        optionSons.add(Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              left: ScreenAdapter.width(12),
              top: ScreenAdapter.height(3),
              right: ScreenAdapter.width(12),
              bottom: ScreenAdapter.height(3)),
          child: InkWell(
            //enableFeedback: true,
            onTap: () {
              _changeOptionv1(menuCode, optionGroupVoList[i]["groupCode"],
                  optionVolistSon["optionCode"], setFirstState);
            },
            child: badges.Badge(
              showBadge: (optionVolistSon['currentPrice'] != 0) ? true : false,
              badgeContent: Text(
                  (optionVolistSon['currentPrice'] > 0) ?"+${optionVolistSon['currentPrice'].toString()}円":"${optionVolistSon['currentPrice'].toString()}円",
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(16),
                    color: ColorsUtil.hexToColor(
                        Gcolor.optionBtnColor),
                  )),
              //padding: EdgeInsets.all(5),
              position:badges.BadgePosition.topEnd(top: -18, end: -9),
              badgeStyle: badges.BadgeStyle(
                shape: badges.BadgeShape.square,
                padding: EdgeInsets.only(left: 5,top: 3,right: 5,bottom: 3),
                borderRadius: BorderRadius.circular(5),
                badgeColor: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),

              ),
              child: Container(
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
                      : (buttonColor.length>0)?BoxDecoration(
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
                  )  :BoxDecoration(
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
                      (optionVolistSon['homeImage'] != "" && optionVolistSon['homeImage'] != null)
                          ? CachedNetworkImage(imageUrl:optionVolistSon['homeImage'],
                          width: ScreenAdapter.width(15),
                          height: ScreenAdapter.height(25),
                          color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                          fit: BoxFit.fitHeight)
                          : Container(
                        width: 0,
                      ),
                      SizedBox(
                        width: ScreenAdapter.width(5),
                      ),

                      Container(
                        //width: ScreenAdapter.width(210),
                        height: ScreenAdapter.height(60),
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: ScreenAdapter.width(20),
                            maxWidth: ScreenAdapter.width(170),
                            minHeight: ScreenAdapter.height(30),
                            maxHeight: ScreenAdapter.height(60),
                          ),
                          child: AutoSizeText(
                            optionVolistSon['mainTitle'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(28.0),
                              color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                            ),
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  )),
            )
          ),
        ));
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
          top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(5)),
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
        if(i >= _optionGroupMaxNum) break;
        List<Widget> optionSons = [];
        var optionVoList = optionGroupVoList[i]['optionVoList'];
        options.add(Container(
          padding: EdgeInsets.only(
              top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                    text: "${optionGroupVoList[i]['groupName']}",
                    //GString.getToString(this._checkLanguage, "show_price_front"),
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(24.0),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                    children: [
                      TextSpan(
                        text: (optionGroupVoList[i]['remark'] !=null && optionGroupVoList[i]['remark']!="")?" ${optionGroupVoList[i]['remark']}":"",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(18.0),
                          fontWeight: FontWeight.w200,
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ));

        for (var j = 0; j < optionVoList.length; j++) {
          if(j >= _optionMaxNum) break;
          var optionVolistSon = optionVoList[j];
          var buttonColor =[];
          if (optionVolistSon['buttonColorValue'] != null && optionVolistSon['buttonColorValue'] != "") {
            buttonColor = optionVolistSon['buttonColorValue'].split(',');
          }
          optionSons.add(Container(
            width: ScreenAdapter.width(157),
            height: ScreenAdapter.height(60),
            alignment: Alignment.center,
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(2),
                top: ScreenAdapter.height(2),
                right: ScreenAdapter.width(2),
                bottom: ScreenAdapter.height(2)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                _changeOptionv1(menuCode, optionGroupVoList[i]["groupCode"],
                    optionVolistSon["optionCode"], setFirstState);
              },
              child: badges.Badge(
                showBadge: (optionVolistSon['currentPrice'] != 0) ? true : false,
                badgeContent: Text(
                    (optionVolistSon['currentPrice'] > 0) ?"+${optionVolistSon['currentPrice'].toString()}円":"${optionVolistSon['currentPrice'].toString()}円",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(16),
                      color: ColorsUtil.hexToColor(
                          Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position:badges.BadgePosition.topEnd(top: -18, end: -9),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding: EdgeInsets.only(left: 5,top: 3,right: 5,bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),

                ),
                child: Container(
                  //width: ScreenAdapter.width(135),
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
                        : (buttonColor.length>0) ? BoxDecoration(
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
                    ): BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                            ? CachedNetworkImage(imageUrl:optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(15),
                            height: ScreenAdapter.height(25),
                            color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(2),
                        ),

                        Container(
                          //width: ScreenAdapter.width(210),
                          height: ScreenAdapter.height(50),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(125),
                              minHeight: ScreenAdapter.height(24),
                              maxHeight: ScreenAdapter.height(48),
                            ),
                            child: AutoSizeText(
                              optionVolistSon['mainTitle'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(28.0),
                                color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ));

        }

        options.add(Container(
          child: Wrap(
            spacing: ScreenAdapter.width(5), // set spacing here
            runSpacing: ScreenAdapter.height(10),
            alignment: WrapAlignment.start,
            children: optionSons,
          ),
        ));
      }
    }

    return options;
  }

  //获取第三个页面的widget
  publicShowThreeMenuOptionGroupWidget(menuCode, menuindex) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(8),
          right: ScreenAdapter.width(3),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getThreeOptionWidget(menuCode, menuindex),
      ),
    );
  }

  //期间限定第五个分类
  //获取第五个页面的option widget
  _getFiveOptionWidget(menuCode, setFirstState) {
    var optionGroupVoList = _menuOption[menuCode];
    List<Widget> options = []; //先建一个数组用于存放循环生成的widget
    if (optionGroupVoList != null &&
        optionGroupVoList.length > 0 &&
        optionGroupVoList != "") {
      for (var i = 0; i < optionGroupVoList.length; i++) {
        if(i >= _optionGroupMaxNum) break;
        List<Widget> optionSons = [];
        var optionVoList = optionGroupVoList[i]['optionVoList'];
        options.add(Container(
          padding: EdgeInsets.only(
              top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                    text: "${optionGroupVoList[i]['groupName']}",
                    //GString.getToString(this._checkLanguage, "show_price_front"),
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(24.0),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                    children: [
                      TextSpan(
                        text: (optionGroupVoList[i]['remark'] !=null && optionGroupVoList[i]['remark']!="")?" ${optionGroupVoList[i]['remark']}":"",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(18.0),
                          fontWeight: FontWeight.w200,
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ));

        for (var j = 0; j < optionVoList.length; j++) {
          if(j >= _optionMaxNum) break;
          var optionVolistSon = optionVoList[j];


          var buttonColor = [];
          if (optionVolistSon['buttonColorValue'] != null && optionVolistSon['buttonColorValue'] != "") {
            buttonColor = optionVolistSon['buttonColorValue'].split(',');
          }
          optionSons.add(Container(
            width: ScreenAdapter.width(207),
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(7),
                top: ScreenAdapter.height(5),
                right: ScreenAdapter.width(7),
                bottom: ScreenAdapter.height(5)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                _changeOptionv1(menuCode, optionGroupVoList[i]["groupCode"],
                    optionVolistSon["optionCode"], setFirstState);
              },
              child: badges.Badge(
                showBadge: (optionVolistSon['currentPrice'] != 0) ? true : false,
                badgeContent: Text(
                    (optionVolistSon['currentPrice'] > 0) ?"+${optionVolistSon['currentPrice'].toString()}円":"${optionVolistSon['currentPrice'].toString()}円",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(16),
                      color: ColorsUtil.hexToColor(
                          Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position:badges.BadgePosition.topEnd(top: -18, end: -9),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding: EdgeInsets.only(left: 5,top: 3,right: 5,bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),

                ),
                child: Container(
                  //width: ScreenAdapter.width(160),
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
                        : (buttonColor.length>0)?BoxDecoration(
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
                    ):BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                            ? CachedNetworkImage(imageUrl:optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(15),
                            height: ScreenAdapter.height(25),
                            color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(3),
                        ),

                        Container(
                          //width: ScreenAdapter.width(210),
                          height: ScreenAdapter.height(60),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(160),
                              minHeight: ScreenAdapter.height(26),
                              maxHeight: ScreenAdapter.height(52),
                            ),
                            child: AutoSizeText(
                              optionVolistSon['mainTitle'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(28.0),
                                color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ));

        }

        options.add(Container(
          child: Wrap(
            spacing: ScreenAdapter.width(5), // set spacing here
            runSpacing: ScreenAdapter.height(10),
            alignment: WrapAlignment.start,
            children: optionSons,
          ),
        ));
      }
    }

    return options;
  }

  //获取第五个页面的widget
  publicShowFiveMenuOptionGroupWidget(menuCode, menuindex) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(8),
          right: ScreenAdapter.width(3),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
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

    }

    if (itemsFirst != null) {
      return Container(
        color: ColorsUtil.hexToColor(Gcolor.mainBackground),
        padding: EdgeInsets.only(top:ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            publicShowMenuImage(imgPath:itemsFirst['homeImage'], imgWidth:1080.0, imgHeight:870.0,subTitle:itemsFirst["subtitle"]),
            Container(
              color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              width: ScreenAdapter.width(1080),
              //height: ScreenAdapter.height(408),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(25),
                  right: ScreenAdapter.width(25),
                  bottom: ScreenAdapter.height(5)),
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
                              child: publicShowMenuTitle(itemsFirst['mainTitle'],
                                  42.0, Gcolor.mainTitleColor),),
                          //价格展示 //itemsFirst['currentPrice']
                          Container(
                            alignment: Alignment.centerRight,
                            //width: ScreenAdapter.width(200),
                            padding:EdgeInsets.only(right: ScreenAdapter.width(15)),
                            child: publicShowMenuPrice(
                                _selectedMenuOptionChangePrice[itemsFirst['menuCode']]+_addselectedMenuOptionChangePrice[itemsFirst['menuCode']],
                                itemsFirst['price'],
                                45.0,
                                Gcolor.mainTitleColor,
                                55.0,
                                Gcolor.priceColor,
                                26.0,
                                Gcolor.mainTitleColor),
                          ),
                          //原价格展示 //itemsFirst['currentPrice']
                          /*Container(
                            width: ScreenAdapter.width(80),
                            child: Text("${itemsFirst['price']}",
                              style: TextStyle(decoration: TextDecoration.lineThrough,fontSize: ScreenAdapter.fontSize(32),fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),),
                            ),
                          ),*/

                          //确认按钮
                          InkWell(
                            enableFeedback: false,

                            onTap: () {

                              //判断选择后option是否与optiongroup相等
                              /*if (_selectedMenuOptionList[itemsFirst['menuCode']].length <_selectedMenuOptionCheckedNum[itemsFirst['menuCode']]) {
                                showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                                return;
                              }*/

                              var currentPrice = itemsFirst['currentPrice'];
                              var optionCodeList = "";
                              var optionTitle = "";
                              //--------------检测option单选还是多选是否满足
                              var attr = _menuOption[itemsFirst['menuCode']];
                              var nexOrder = true;
                              for (var i = 0; i < attr.length; i++) {
                                //如果是多选，那么需要判断该组option数量是否超过最大值
                                if(int.parse(attr[i]["smallest"]) >0){
                                  var current_option_checked = 0;
                                  for (var n = 0; n < attr[i]['optionVoList'].length; n++) {
                                    if(attr[i]['optionVoList'][n]["checked"] == true){
                                      current_option_checked++;
                                    }
                                  }
                                  if(current_option_checked <int.parse(attr[i]["smallest"])){
                                    nexOrder = false;
                                    var showTag = GString.getToString(this._checkLanguage, "menu_option_less_smallest");
                                    showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                    break;
                                  }
                                }

                              }
                              if(nexOrder == false) return;
                              //--------------end
                              var checkoptionGroupList = {};
                              for (var optionItem in _selectedMenuOptionList[itemsFirst['menuCode']]) {
                                currentPrice += optionItem['currentPrice'];

                                optionCodeList += (optionCodeList != "")
                                    ? "," + optionItem['optionCode']
                                    : optionItem['optionCode'];
                                var groupKey = optionItem['groupCode'];
                                //整理新数组
                                checkoptionGroupList[groupKey] = {
                                  "optionTitles": (checkoptionGroupList[groupKey] == null) ? optionItem['mainTitle'] : checkoptionGroupList[groupKey]["optionTitles"]+","+optionItem['mainTitle'],
                                  "groupTitle":optionItem['groupTitle']
                                };
                              }

                              checkoptionGroupList.forEach((key, value) {
                                optionTitle += (optionTitle != "")
                                    ? "," + value['groupTitle']+":"+value['optionTitles']
                                    : value['groupTitle']+":"+value['optionTitles'];
                              });



                              /*for (var optionItem in _selectedMenuOptionList[itemsFirst['menuCode']]) {
                                //if (optionItem['currentPrice'] != 0) {
                                currentPrice += optionItem['currentPrice'];
                                //}
                                optionCodeList += (optionCodeList != "") ? "," + optionItem['optionCode'] : optionItem['optionCode'];
                                optionTitle += (optionTitle != "") ? "," + optionItem['groupTitle']+":"+optionItem['mainTitle'] : optionItem['groupTitle']+":"+optionItem['mainTitle'];
                              }*/

                              var cartItem = {
                                "menuCode": itemsFirst['menuCode'],
                                "mainTitle": itemsFirst['mainTitle'],
                                "image": itemsFirst['homeImage'],
                                "currentPrice": currentPrice,
                                "optionGroupVoList": optionCodeList,
                                "optionVoListMsg": optionTitle,
                                "goodsNum": 1,
                                "qtyBounds": itemsFirst['qtyBounds'],
                                "unitPrice":currentPrice
                              };
                              publicAddCartMenu(cartItem, false).then((val) {
                                //_publicShowAddCart(temp,itemsFirst['homeImage']);
                                if(val != false){
                                  _publicShowAddCartNew();
                                }


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
          ],
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  //第二个分类 小菜
  _showCategoryTwo(showItemList,{popupType:"old"}) {
    if (showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategoryTwoItemList(showItemList,popupType:popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryTwoItemList(items,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 3,
            childAspectRatio: 0.76),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryTwoItemOne(items[index],popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryTwoItemOne(item,{popupType:"old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,

          onTap: () async {

            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              _checkQtyBoundsCount(item, "");

            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                if(popupType == "v1"){
                  _publicShowOneItemWidgetv1(item);
                }else{
                  _publicShowOneItemWidget(item);
                }

              }else{
                _publicAddCart(item);
              }
            }


          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor("#FFFFFF"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth:350.0, imgHeight:350.0,subTitle:item["subtitle"]),

                        Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),

                        Container(
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(70),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuTitle(
                              item['mainTitle'],
                              GFontSize.menuTwoListTitle,
                              Gcolor.mainTitleColor),
                        ),
                        /*SizedBox(
                          height: ScreenAdapter.height(8),
                        ),*/
                        Container(
                          //width: ScreenAdapter.width(125),
                          //height: ScreenAdapter.height(315),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                              item['currentPrice'],
                              item['price'],
                              GFontSize.menuTwopriceLift,
                              Gcolor.mainTitleColor,
                              GFontSize.menuTwoprice,
                              Gcolor.priceColor,
                              GFontSize.menuTwopriceRight,
                              Gcolor.mainTitleColor),
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
            top: ScreenAdapter.height(8),
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
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
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
    if (item["subtitle"] != null && item["subtitle"]?.length > 0) {
      for (var i = 0; i < item["subtitle"].length; i++) {
        subtitle += item["subtitle"][i];
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width,
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
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth:350.0, imgHeight:350.0),
                        (item['optionGroupVoList']?.length > 0)
                            ? Expanded(child: publicShowThreeMenuOptionGroupWidget(
                            item['menuCode'], menuindex))
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                //菜单Title

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    //菜单Title
                                    Expanded(child: Container(
                                      padding: EdgeInsets.only(
                                          right: ScreenAdapter.width(15)),
                                      child: publicShowMenuTitle(item['mainTitle'],
                                          32.0, Gcolor.mainTitleColor),
                                    ),),

                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    //副标题
                                    subtitle != ""
                                        ? Expanded(child: Container(
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
                                    ))
                                        : Container(
                                      width: 0,
                                    ),

                                  ],
                                ),

                              ],
                            ),
                          )),
                      //价格展示 item['currentPrice']
                      Container(
                        padding: EdgeInsets.only(right: ScreenAdapter.width(30)),
                        //width: ScreenAdapter.width(200),
                        alignment: Alignment.bottomRight,
                        child: publicShowMenuPrice(
                            _selectedMenuOptionChangePrice[item['menuCode']]+_addselectedMenuOptionChangePrice[item['menuCode']],
                            item['price'],
                            35.0,
                            Gcolor.mainTitleColor,
                            54.0,
                            Gcolor.priceColor,
                            28.0,
                            Gcolor.mainTitleColor),
                      ),

                      //确认按钮
                      InkWell(
                        enableFeedback: false,
                        onTap: () {

                          //判断选择后option是否与optiongroup相等
                          var currentPrice = item['currentPrice'];
                          var optionCodeList = "";
                          var optionTitle = "";
                          if (item['optionGroupVoList']?.length > 0) {//item['optionGroupVoList'].length
                            /*if (_selectedMenuOptionList[item['menuCode']].length < _selectedMenuOptionCheckedNum[item['menuCode']]) {
                              showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                              return;
                            }

                            for (var optionItem in _selectedMenuOptionList[item['menuCode']]) {
                              //if (optionItem['currentPrice'] != 0) {
                              currentPrice += optionItem['currentPrice'];
                              //}
                              optionCodeList += (optionCodeList != "")
                                  ? "," + optionItem['optionCode']
                                  : optionItem['optionCode'];
                              optionTitle += (optionTitle != "")
                                  ? "," + optionItem['groupTitle']+":"+optionItem['mainTitle']
                                  : optionItem['groupTitle']+":"+optionItem['mainTitle'];
                            }*/

                            //--------------检测option单选还是多选是否满足
                            var attr = _menuOption[item['menuCode']];
                            var nexOrder = true;
                            for (var i = 0; i < attr.length; i++) {
                              //如果是多选，那么需要判断该组option数量是否超过最大值
                              if(int.parse(attr[i]["smallest"]) >0){
                                var current_option_checked = 0;
                                for (var n = 0; n < attr[i]['optionVoList'].length; n++) {
                                  if(attr[i]['optionVoList'][n]["checked"] == true){
                                    current_option_checked++;
                                  }
                                }
                                if(current_option_checked <int.parse(attr[i]["smallest"])){
                                  nexOrder = false;
                                  var showTag = GString.getToString(this._checkLanguage, "menu_option_less_smallest");
                                  showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                  break;
                                }
                              }

                            }
                            if(nexOrder == false) return;
                            //--------------end
                            var checkoptionGroupList = {};
                            for (var optionItem in _selectedMenuOptionList[item['menuCode']]) {
                              currentPrice += optionItem['currentPrice'];

                              optionCodeList += (optionCodeList != "")
                                  ? "," + optionItem['optionCode']
                                  : optionItem['optionCode'];
                              var groupKey = optionItem['groupCode'];
                              //整理新数组
                              checkoptionGroupList[groupKey] = {
                                "optionTitles": (checkoptionGroupList[groupKey] == null) ? optionItem['mainTitle'] : checkoptionGroupList[groupKey]["optionTitles"]+","+optionItem['mainTitle'],
                                "groupTitle":optionItem['groupTitle']
                              };

                            }

                            checkoptionGroupList.forEach((key, value) {
                              optionTitle += (optionTitle != "")
                                  ? "," + value['groupTitle']+":"+value['optionTitles']
                                  : value['groupTitle']+":"+value['optionTitles'];
                            });
                          }

                          var cartItem = {
                            "menuCode": item['menuCode'],
                            "mainTitle": item['mainTitle'],
                            "image": item['homeImage'],
                            "currentPrice": currentPrice,
                            "optionGroupVoList": optionCodeList,
                            "optionVoListMsg": optionTitle,
                            "goodsNum": 1,
                            "qtyBounds": item['qtyBounds'],
                            "unitPrice":currentPrice
                          };
                          publicAddCartMenu(cartItem, false).then((val) {

                            if(val != false){
                              _publicShowAddCartNew();
                            }
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
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(7),
            crossAxisCount: 4,
            childAspectRatio: 0.55),
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
          enableFeedback: false,
          onTap: () async {

            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              _checkQtyBoundsCount(item, "");

            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                _publicShowOneItemWidget(item);
              }else{
                _publicAddCart(item);
              }
            }


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
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth:260.0, imgHeight: 400.0,subTitle:item["subtitle"]),
                        Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),
                        SizedBox(
                          height: ScreenAdapter.height(8),
                        ),
                        Container(
                          //width: ScreenAdapter.width(1080),
                          //height: ScreenAdapter.height(315),
                          height: ScreenAdapter.height(65),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //菜单Title
                              Expanded(child: publicShowMenuTitle(
                                  item['mainTitle'],
                                  GFontSize.menuFourListTitle,
                                  Gcolor.mainTitleColor)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenAdapter.height(3),
                        ),
                        /*Container(
                          padding: EdgeInsets.only(left: ScreenAdapter.width(10)),
                          child: publicShowMenuSubtitle(item["subtitle"]),
                        ),*/
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
                                  item['price'],
                                  GFontSize.menuFourpriceLift,
                                  Gcolor.mainTitleColor,
                                  GFontSize.menuFourprice,
                                  Gcolor.priceColor,
                                  GFontSize.menuFourpriceRight,
                                  Gcolor.mainTitleColor),
                            ],
                          ),
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

  //第五个分类 期间限定
  _showCategoryFive(showItemList) {
    if (showItemList.length > 0) {
      return Container(
        padding: EdgeInsets.only(
            top: ScreenAdapter.height(8),
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
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
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
    if (item["subtitle"]!= null && item["subtitle"].length > 0) {
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
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 400.0, imgHeight: 260.0),
                        (item['optionGroupVoList']?.length > 0)
                            ? Expanded(
                            child: publicShowFiveMenuOptionGroupWidget(
                                item['menuCode'], menuFiveindex)
                        )
                            : Container(
                          height: 0,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),

                  //标题价格
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                          child: Container(
                            padding: EdgeInsets.only(left: ScreenAdapter.width(10)),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    //菜单Title
                                    Expanded(child: Container(
                                      padding: EdgeInsets.only(
                                          right: ScreenAdapter.width(15)),
                                      child: publicShowMenuTitle(item['mainTitle'],
                                          32.0, Gcolor.mainTitleColor),
                                    ),),

                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    //副标题
                                    subtitle != ""
                                        ? Expanded(child: Container(
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
                                    ))
                                        : Container(
                                      width: 0,
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          )),
                      //价格展示 item['currentPrice']
                      Container(
                        padding: EdgeInsets.only(right: ScreenAdapter.width(30)),
                        //width: ScreenAdapter.width(200),
                        alignment: Alignment.bottomRight,
                        //alignment: Alignment.centerRight,
                        child: publicShowMenuPrice(
                            _selectedMenuOptionChangePrice[item['menuCode']]+_addselectedMenuOptionChangePrice[item['menuCode']],
                            item['price'],
                            35.0,
                            Gcolor.mainTitleColor,
                            54.0,
                            Gcolor.priceColor,
                            28.0,
                            Gcolor.mainTitleColor),
                      ),
                      //确认按钮
                      InkWell(
                        enableFeedback: false,
                        onTap: () {

                          //判断选择后option是否与optiongroup相等
                          var optionCodeList = "";
                          var optionTitle = "";
                          var currentPrice = item['currentPrice'];
                          if (item['optionGroupVoList']?.length > 0) {//item['optionGroupVoList'].length
                            /*if (_selectedMenuOptionList[item['menuCode']].length < _selectedMenuOptionCheckedNum[item['menuCode']]) {
                              showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                              return;
                            }*/

                            /*for (var optionItem in _selectedMenuOptionList[item['menuCode']]) {
                              //if (optionItem['currentPrice'] > 0) {
                              currentPrice += optionItem['currentPrice'];
                              //}
                              optionCodeList += (optionCodeList != "") ? "," + optionItem['optionCode'] : optionItem['optionCode'];
                              optionTitle += (optionTitle != "") ? "," + optionItem['groupTitle']+":"+optionItem['mainTitle'] : optionItem['groupTitle']+":"+optionItem['mainTitle'];
                            }*/

                            //--------------检测option单选还是多选是否满足
                            var attr = _menuOption[item['menuCode']];
                            var nexOrder = true;
                            for (var i = 0; i < attr.length; i++) {
                              //如果是多选，那么需要判断该组option数量是否超过最大值
                              if(int.parse(attr[i]["smallest"]) >0){
                                var current_option_checked = 0;
                                for (var n = 0; n < attr[i]['optionVoList'].length; n++) {
                                  if(attr[i]['optionVoList'][n]["checked"] == true){
                                    current_option_checked++;
                                  }
                                }
                                if(current_option_checked <int.parse(attr[i]["smallest"])){
                                  nexOrder = false;
                                  var showTag = GString.getToString(this._checkLanguage, "menu_option_less_smallest");
                                  showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                  break;
                                }
                              }

                            }
                            if(nexOrder == false) return;
                            //--------------end
                            var checkoptionGroupList = {};
                            for (var optionItem in _selectedMenuOptionList[item['menuCode']]) {
                              currentPrice += optionItem['currentPrice'];

                              optionCodeList += (optionCodeList != "")
                                  ? "," + optionItem['optionCode']
                                  : optionItem['optionCode'];
                              var groupKey = optionItem['groupCode'];
                              //整理新数组
                              checkoptionGroupList[groupKey] = {
                                "optionTitles": (checkoptionGroupList[groupKey] == null) ? optionItem['mainTitle'] : checkoptionGroupList[groupKey]["optionTitles"]+","+optionItem['mainTitle'],
                                "groupTitle":optionItem['groupTitle']
                              };
                            }

                            checkoptionGroupList.forEach((key, value) {
                              optionTitle += (optionTitle != "")
                                  ? "," + value['groupTitle']+":"+value['optionTitles']
                                  : value['groupTitle']+":"+value['optionTitles'];
                            });

                          }

                          var cartItem = {
                            "menuCode": item['menuCode'],
                            "mainTitle": item['mainTitle'],
                            "image": item['homeImage'],
                            "currentPrice": currentPrice,
                            "optionGroupVoList": optionCodeList,
                            "optionVoListMsg": optionTitle,
                            "goodsNum": 1,
                            "qtyBounds": item['qtyBounds'],
                            "unitPrice":currentPrice
                          };
                          publicAddCartMenu(cartItem, false).then((val) {

                            if(val != false){
                              _publicShowAddCartNew();
                            }

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

  //第六个分类 每页两列一行
  _showCategorySix(showItemList,{popupType:"old"}) {
    if (showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategorySixItemList(showItemList,popupType:popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategorySixItemList(items,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 2,
            childAspectRatio: 0.83),
        itemBuilder: (BuildContext context, int index) {
          return showCategorySixItemOne(items[index],popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategorySixItemOne(item,{popupType:"old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {

            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              _checkQtyBoundsCount(item, "");
            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                if(popupType == "v1"){
                  _publicShowOneItemWidgetv1(item);
                }else{
                  _publicShowOneItemWidget(item);
                }
              }else{
                _publicAddCart(item);
              }
            }



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
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 530.0, imgHeight: 530.0,subTitle:item["subtitle"]),
                        Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),

                        Container(
                          margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          height: ScreenAdapter.height(68),
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
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                              item['currentPrice'],
                              item['price'],
                              GFontSize.menuTwopriceLift,
                              Gcolor.mainTitleColor,
                              GFontSize.menuTwoprice,
                              Gcolor.priceColor,
                              GFontSize.menuTwopriceRight,
                              Gcolor.mainTitleColor),
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

  //第七个分类 每页三列一行  饮品
  _showCategorySeven(showItemList,{popupType:"old"}) {
    if (showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategorySevenItemList(showItemList,popupType:popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategorySevenItemList(items,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 3,
            childAspectRatio: 0.64),
        itemBuilder: (BuildContext context, int index) {
          return showCategorySevenItemOne(items[index],popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategorySevenItemOne(item,{popupType:"old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {

            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              _checkQtyBoundsCount(item, "");
            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                //_publicShowOneItemWidget(item);
                if(popupType == "v1"){
                  _publicShowOneItemWidgetv1(item);
                }else{
                  _publicShowOneItemWidget(item);
                }
              }else{
                _publicAddCart(item);
              }
            }



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
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 350.0, imgHeight: 440.0,subTitle:item["subtitle"]),
                        Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),

                        Container(
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(70),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
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
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                              item['currentPrice'],
                              item['price'],
                              GFontSize.menuTwopriceLift,
                              Gcolor.mainTitleColor,
                              GFontSize.menuTwoprice,
                              Gcolor.priceColor,
                              GFontSize.menuTwopriceRight,
                              Gcolor.mainTitleColor),
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

  //第八个分类 混合排列，第一行一大两小，其余三个一行每页三列一行
  _showCategoryEight(showItemList,{popupType:"old"}) {
    if (showItemList.length > 0) {
      if(showItemList.length >=3){
        var _leftItem = showItemList[0];
        var _rightTop = showItemList[1];
        var _rightBottom = showItemList[2];
        var _newItemList = showItemList.sublist(3);

        return Container(
          padding: EdgeInsets.only(top: ScreenAdapter.height(8), ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: new AlwaysScrollableScrollPhysics(),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: ScreenAdapter.height(835),
                            color: ColorsUtil.hexToColor("#FFFFFF"),
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                            child: InkWell(
                                enableFeedback: false,
                                onTap: () async {

                                  if (_leftItem['qtyBounds'] == 0) {
                                    return;
                                  } else if (_leftItem['qtyBounds'] > 0) {
                                    //请求限定接口
                                    _checkQtyBoundsCount(_leftItem, "");
                                  }else{
                                    //如果option 存在，则弹出option
                                    if(_leftItem['optionGroupVoList']?.length > 0){
                                      if(popupType == "v1"){
                                        _publicShowOneItemWidgetv1(_leftItem);
                                      }else{
                                        _publicShowOneItemWidget(_leftItem);
                                      }

                                    }else{

                                      _publicAddCart(_leftItem);
                                    }
                                  }


                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            width: 1,
                                            color: ColorsUtil.hexToColor("#DDDDDD"),
                                          ),
                                        ),
                                      ),
                                      child: publicShowMenuImage(imgPath:_leftItem['homeImage'], imgWidth: 710.0, imgHeight: 710.0,subTitle:_leftItem["subtitle"]),
                                    ),

                                    Container(
                                      width: ScreenAdapter.width(710),
                                      height: ScreenAdapter.height(68),
                                      margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(10),
                                          right: ScreenAdapter.width(10)),
                                      child: publicShowMenuTitle(
                                          _leftItem['mainTitle'],
                                          GFontSize.menuTwoListTitle,
                                          Gcolor.mainTitleColor),
                                    ),

                                    Container(
                                      width: ScreenAdapter.width(710),
                                      //margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                      padding: EdgeInsets.only(left: ScreenAdapter.width(10),right: ScreenAdapter.width(10)),
                                      child: Container(
                                        //width: ScreenAdapter.width(125),
                                        //height: ScreenAdapter.height(315),
                                        alignment: Alignment.centerRight,
                                        padding: EdgeInsets.only(
                                            left: ScreenAdapter.width(15),
                                            right: ScreenAdapter.width(10)),
                                        child: publicShowMenuPrice(
                                            _leftItem['currentPrice'],
                                            _leftItem['price'],
                                            GFontSize.menuTwopriceLift,
                                            Gcolor.mainTitleColor,
                                            GFontSize.menuTwoprice,
                                            Gcolor.priceColor,
                                            GFontSize.menuTwopriceRight,
                                            Gcolor.mainTitleColor),
                                      ),
                                    ),
                                  ],
                                )
                            ),
                          ),
                          //绝对定位 盖章
                          publicShowMenuSellOut(_leftItem['qtyBounds']),
                        ],
                      ),
                      Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: ScreenAdapter.height(412),
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                margin: EdgeInsets.only(
                                    left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                                child: InkWell(
                                    enableFeedback: false,
                                    onTap: () async {

                                      if (_rightTop['qtyBounds'] == 0) {
                                        return;
                                      } else if (_rightTop['qtyBounds'] > 0) {
                                        //请求限定接口
                                        _checkQtyBoundsCount(_rightTop, "");

                                      }else{
                                        if(_rightTop['optionGroupVoList']?.length > 0){
                                          //_publicShowOneItemWidget(_rightTop);
                                          if(popupType == "v1"){
                                            _publicShowOneItemWidgetv1(_rightTop);
                                          }else{
                                            _publicShowOneItemWidget(_rightTop);
                                          }
                                        }else{
                                          _publicAddCart(_rightTop);
                                        }
                                      }




                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                  alignment: Alignment.center,
                                                  width: ScreenAdapter.width(350),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        width: 1,
                                                        color: ColorsUtil.hexToColor("#DDDDDD"),
                                                      ),
                                                    ),
                                                  ),
                                                  child:publicShowMenuImage(imgPath:_rightTop['homeImage'], imgWidth: 350.0, imgHeight: 300.0,subTitle:_rightTop["subtitle"]),
                                                ),


                                                Container(
                                                  width: ScreenAdapter.width(350),
                                                  height: ScreenAdapter.height(68),
                                                  //margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                                  padding: EdgeInsets.only(
                                                      left: ScreenAdapter.width(10),
                                                      right: ScreenAdapter.width(10)),
                                                  child: publicShowMenuTitle(
                                                      _rightTop['mainTitle'],
                                                      GFontSize.menuTwoListTitle,
                                                      Gcolor.mainTitleColor),
                                                ),
                                                Container(
                                                  //width: ScreenAdapter.width(125),
                                                  //height: ScreenAdapter.height(315),
                                                  alignment: Alignment.centerRight,
                                                  padding: EdgeInsets.only(
                                                      left: ScreenAdapter.width(15),
                                                      right: ScreenAdapter.width(10)),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      //价格展示
                                                      publicShowMenuPrice(
                                                          _rightTop['currentPrice'],
                                                          _rightTop['price'],
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
                                            )),
                                        //绝对定位 盖章
                                        publicShowMenuSellOut(_rightTop['qtyBounds']),
                                      ],
                                    )),
                              ),
                              Container(
                                height: ScreenAdapter.height(412),
                                color: ColorsUtil.hexToColor("#FFFFFF"),
                                margin: EdgeInsets.only(
                                    left: ScreenAdapter.width(5), top: ScreenAdapter.height(10), right: ScreenAdapter.width(5)),
                                child: InkWell(
                                    enableFeedback: false,
                                    onTap: () async {

                                      if (_rightBottom['qtyBounds'] == 0) {
                                        return;
                                      } else if (_rightBottom['qtyBounds'] > 0) {
                                        //请求限定接口
                                        _checkQtyBoundsCount(_rightBottom, "");

                                      }else{
                                        if(_rightBottom['optionGroupVoList']?.length > 0){
                                          //_publicShowOneItemWidget(_rightBottom);
                                          if(popupType == "v1"){
                                            _publicShowOneItemWidgetv1(_rightBottom);
                                          }else{
                                            _publicShowOneItemWidget(_rightBottom);
                                          }
                                        }else{
                                          _publicAddCart(_rightBottom);
                                        }
                                      }



                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Container(
                                                    alignment: Alignment.center,
                                                    width: ScreenAdapter.width(350),
                                                    decoration: BoxDecoration(
                                                      border: Border(
                                                        bottom: BorderSide(
                                                          width: 1,
                                                          color: ColorsUtil.hexToColor("#DDDDDD"),
                                                        ),
                                                      ),
                                                    ),
                                                    child:publicShowMenuImage(imgPath:_rightBottom['homeImage'], imgWidth: 350.0, imgHeight: 300.0,subTitle:_rightBottom["subtitle"])
                                                ),


                                                Container(
                                                  width: ScreenAdapter.width(350),
                                                  height: ScreenAdapter.height(68),
                                                  //margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                                  padding: EdgeInsets.only(
                                                      left: ScreenAdapter.width(10),
                                                      right: ScreenAdapter.width(10)),
                                                  child: publicShowMenuTitle(
                                                      _rightBottom['mainTitle'],
                                                      GFontSize.menuTwoListTitle,
                                                      Gcolor.mainTitleColor),
                                                ),
                                                Container(
                                                  //width: ScreenAdapter.width(125),
                                                  //height: ScreenAdapter.height(315),
                                                  alignment: Alignment.centerRight,
                                                  padding: EdgeInsets.only(
                                                      left: ScreenAdapter.width(15),
                                                      right: ScreenAdapter.width(10)),
                                                  child: publicShowMenuPrice(
                                                      _rightBottom['currentPrice'],
                                                      _rightBottom['price'],
                                                      GFontSize.menuTwopriceLift,
                                                      Gcolor.mainTitleColor,
                                                      GFontSize.menuTwoprice,
                                                      Gcolor.priceColor,
                                                      GFontSize.menuTwopriceRight,
                                                      Gcolor.mainTitleColor),
                                                ),
                                              ],
                                            )),
                                        //绝对定位 盖章
                                        publicShowMenuSellOut(_rightBottom['qtyBounds']),
                                      ],
                                    )),
                              ),
                            ],
                          )
                      )
                    ],
                  ),
                  showCategoryEightItemList(_newItemList,popupType:popupType)
                ]
            ),
          ),
        );
      }else{
        return Container(
          child: showCategoryEightItemList(showItemList,popupType:popupType),
        );
      }

    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryEightItemList(items,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: new NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 3,
            childAspectRatio: 0.76),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryEightItemOne(items[index],popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryEightItemOne(item,{popupType:"old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {

            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              _checkQtyBoundsCount(item, "");

            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                if(popupType == "v1"){
                  _publicShowOneItemWidgetv1(item);
                }else{
                  _publicShowOneItemWidget(item);
                }
              }else{
                _publicAddCart(item);
              }
            }



          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor("#FFFFFF"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 350.0, imgHeight: 350.0,subTitle:item["subtitle"]),
                        Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),
                        Container(
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(68),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuTitle(
                              item['mainTitle'],
                              GFontSize.menuTwoListTitle,
                              Gcolor.mainTitleColor),
                        ),
                        SizedBox(
                          height: ScreenAdapter.height(8),
                        ),
                        Container(
                          //width: ScreenAdapter.width(125),
                          //height: ScreenAdapter.height(315),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                            item['currentPrice'],
                            item['price'],
                            GFontSize.menuTwopriceLift,
                            Gcolor.mainTitleColor,
                            GFontSize.menuTwoprice,
                            Gcolor.priceColor,
                            GFontSize.menuTwopriceRight,
                            Gcolor.mainTitleColor,
                          ),
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

  //第九个分类 混合排列，第一行一大两小，其余2个一行每页2列一行
  _showCategoryNine(showItemList,{popupType:"old"}) {
    if (showItemList.length > 0) {
      if(showItemList.length >=3){
        var _leftItem = showItemList[0];
        var _rightTop = showItemList[1];
        var _rightBottom = showItemList[2];
        var _newItemList = showItemList.sublist(3);

        return Container(
          padding: EdgeInsets.only(top: ScreenAdapter.height(8), ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: new AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: ScreenAdapter.height(835),
                          color: ColorsUtil.hexToColor("#FFFFFF"),
                          margin: EdgeInsets.only(
                              left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                          child: InkWell(
                              enableFeedback: false,
                              onTap: () async {

                                if (_leftItem['qtyBounds'] == 0) {
                                  return;
                                } else if (_leftItem['qtyBounds'] > 0) {
                                  //请求限定接口
                                  _checkQtyBoundsCount(_leftItem, "");
                                }else{
                                  //如果option 存在，则弹出option
                                  if(_leftItem['optionGroupVoList']?.length > 0){
                                    //_publicShowOneItemWidget(_leftItem);
                                    if(popupType == "v1"){
                                      _publicShowOneItemWidgetv1(_leftItem);
                                    }else{
                                      _publicShowOneItemWidget(_leftItem);
                                    }
                                  }else{

                                    _publicAddCart(_leftItem);
                                  }
                                }


                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: ColorsUtil.hexToColor("#DDDDDD"),
                                        ),
                                      ),
                                    ),
                                    child: publicShowMenuImage(imgPath:_leftItem['homeImage'], imgWidth: 710.0, imgHeight: 710.0,subTitle:_leftItem["subtitle"]),
                                  ),

                                  Container(
                                    width: ScreenAdapter.width(710),
                                    height: ScreenAdapter.height(68),
                                    margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        right: ScreenAdapter.width(10)),
                                    child: publicShowMenuTitle(
                                        _leftItem['mainTitle'],
                                        GFontSize.menuTwoListTitle,
                                        Gcolor.mainTitleColor),
                                  ),

                                  Container(
                                    width: ScreenAdapter.width(710),
                                    //margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                    padding: EdgeInsets.only(left: ScreenAdapter.width(10),right: ScreenAdapter.width(10)),
                                    child: Container(
                                      //width: ScreenAdapter.width(125),
                                      //height: ScreenAdapter.height(315),
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(15),
                                          right: ScreenAdapter.width(10)),
                                      child: publicShowMenuPrice(
                                          _leftItem['currentPrice'],
                                          _leftItem['price'],
                                          GFontSize.menuTwopriceLift,
                                          Gcolor.mainTitleColor,
                                          GFontSize.menuTwoprice,
                                          Gcolor.priceColor,
                                          GFontSize.menuTwopriceRight,
                                          Gcolor.mainTitleColor),
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                        //绝对定位 盖章
                        publicShowMenuSellOut(_leftItem['qtyBounds']),
                      ],
                    ),
                    Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: ScreenAdapter.height(412),
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                              child: InkWell(
                                  enableFeedback: false,
                                  onTap: () async {

                                    if (_rightTop['qtyBounds'] == 0) {
                                      return;
                                    } else if (_rightTop['qtyBounds'] > 0) {
                                      //请求限定接口
                                      _checkQtyBoundsCount(_rightTop, "");

                                    }else{
                                      if(_rightTop['optionGroupVoList']?.length > 0){
                                        //_publicShowOneItemWidget(_rightTop);
                                        if(popupType == "v1"){
                                          _publicShowOneItemWidgetv1(_rightTop);
                                        }else{
                                          _publicShowOneItemWidget(_rightTop);
                                        }
                                      }else{
                                        _publicAddCart(_rightTop);
                                      }
                                    }

                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                alignment: Alignment.center,
                                                width: ScreenAdapter.width(350),
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                      width: 1,
                                                      color: ColorsUtil.hexToColor("#DDDDDD"),
                                                    ),
                                                  ),
                                                ),
                                                child:publicShowMenuImage(imgPath:_rightTop['homeImage'], imgWidth: 350.0, imgHeight: 300.0,subTitle:_rightTop["subtitle"]),
                                              ),


                                              Container(
                                                width: ScreenAdapter.width(350),
                                                height: ScreenAdapter.height(68),
                                                //margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                                padding: EdgeInsets.only(
                                                    left: ScreenAdapter.width(10),
                                                    right: ScreenAdapter.width(10)),
                                                child: publicShowMenuTitle(
                                                    _rightTop['mainTitle'],
                                                    GFontSize.menuTwoListTitle,
                                                    Gcolor.mainTitleColor),
                                              ),
                                              Container(
                                                //width: ScreenAdapter.width(125),
                                                //height: ScreenAdapter.height(315),
                                                alignment: Alignment.centerRight,
                                                padding: EdgeInsets.only(
                                                    left: ScreenAdapter.width(15),
                                                    right: ScreenAdapter.width(10)),
                                                child: publicShowMenuPrice(
                                                    _rightTop['currentPrice'],
                                                    _rightTop['price'],
                                                    GFontSize.menuTwopriceLift,
                                                    Gcolor.mainTitleColor,
                                                    GFontSize.menuTwoprice,
                                                    Gcolor.priceColor,
                                                    GFontSize.menuTwopriceRight,
                                                    Gcolor.mainTitleColor),
                                              ),
                                            ],
                                          )),
                                      //绝对定位 盖章
                                      publicShowMenuSellOut(_rightTop['qtyBounds']),
                                    ],
                                  )),
                            ),
                            Container(
                              height: ScreenAdapter.height(412),
                              color: ColorsUtil.hexToColor("#FFFFFF"),
                              margin: EdgeInsets.only(
                                  left: ScreenAdapter.width(5), top: ScreenAdapter.height(10), right: ScreenAdapter.width(5)),
                              child: InkWell(
                                  enableFeedback: false,
                                  onTap: () async {

                                    if (_rightBottom['qtyBounds'] == 0) {
                                      return;
                                    } else if (_rightBottom['qtyBounds'] > 0) {
                                      //请求限定接口
                                      _checkQtyBoundsCount(_rightBottom, "");

                                    }else{
                                      if(_rightBottom['optionGroupVoList']?.length > 0){
                                        //_publicShowOneItemWidget(_rightBottom);
                                        if(popupType == "v1"){
                                          _publicShowOneItemWidgetv1(_rightBottom);
                                        }else{
                                          _publicShowOneItemWidget(_rightBottom);
                                        }
                                      }else{
                                        _publicAddCart(_rightBottom);
                                      }
                                    }



                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                  alignment: Alignment.center,
                                                  width: ScreenAdapter.width(350),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      bottom: BorderSide(
                                                        width: 1,
                                                        color: ColorsUtil.hexToColor("#DDDDDD"),
                                                      ),
                                                    ),
                                                  ),
                                                  child:publicShowMenuImage(imgPath:_rightBottom['homeImage'], imgWidth: 350.0, imgHeight: 300.0,subTitle:_rightBottom["subtitle"])
                                              ),


                                              Container(
                                                width: ScreenAdapter.width(350),
                                                height: ScreenAdapter.height(68),
                                                //margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                                padding: EdgeInsets.only(
                                                    left: ScreenAdapter.width(10),
                                                    right: ScreenAdapter.width(10)),
                                                child: publicShowMenuTitle(
                                                    _rightBottom['mainTitle'],
                                                    GFontSize.menuTwoListTitle,
                                                    Gcolor.mainTitleColor),
                                              ),
                                              Container(
                                                //width: ScreenAdapter.width(125),
                                                //height: ScreenAdapter.height(315),
                                                alignment: Alignment.centerRight,
                                                padding: EdgeInsets.only(
                                                    left: ScreenAdapter.width(15),
                                                    right: ScreenAdapter.width(10)),
                                                child: publicShowMenuPrice(
                                                    _rightBottom['currentPrice'],
                                                    _rightBottom['price'],
                                                    GFontSize.menuTwopriceLift,
                                                    Gcolor.mainTitleColor,
                                                    GFontSize.menuTwoprice,
                                                    Gcolor.priceColor,
                                                    GFontSize.menuTwopriceRight,
                                                    Gcolor.mainTitleColor),
                                              ),
                                            ],
                                          )),
                                      //绝对定位 盖章
                                      publicShowMenuSellOut(_rightBottom['qtyBounds']),
                                    ],
                                  )),
                            ),
                          ],
                        )
                    )
                  ],
                ),
                showCategoryNineItemList(_newItemList,popupType:popupType)
              ],
            ),
          ),
        );
      }else{
        return Container(
          child: showCategoryNineItemList(showItemList,popupType:popupType),
        );
      }

    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryNineItemList(items,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: new NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(5),
            crossAxisCount: 2,
            childAspectRatio: 0.83),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryNineItemOne(items[index],popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryNineItemOne(item,{popupType:"old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {

            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              _checkQtyBoundsCount(item, "");

            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                //_publicShowOneItemWidget(item);
                if(popupType == "v1"){
                  _publicShowOneItemWidgetv1(item);
                }else{
                  _publicShowOneItemWidget(item);
                }
              }else{
                _publicAddCart(item);
              }
            }



          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor("#FFFFFF"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 530.0, imgHeight: 530.0,subTitle:item["subtitle"]),
                        Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),
                        Container(
                          width: ScreenAdapter.width(530),
                          height: ScreenAdapter.height(68),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
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
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                              item['currentPrice'],
                              item['price'],
                              GFontSize.menuTwopriceLift,
                              Gcolor.mainTitleColor,
                              GFontSize.menuTwoprice,
                              Gcolor.priceColor,
                              GFontSize.menuTwopriceRight,
                              Gcolor.mainTitleColor),
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

  //展示某带option商品
  _publicShowOneItemWidget(item){
    _changeInitialAllOption(item['menuCode']);
    Future.delayed(Duration(milliseconds: 200),() async {
      var subtitle = "";
      if (item["subtitle"] != null && item["subtitle"]?.length > 0) {
        for (var i = 0; i < item["subtitle"].length; i++) {
          subtitle += item["subtitle"][i];
        }
      }
      showDialog(
          context: context,
          //barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
          builder: (BuildContext context) {
            return RepaintBoundary(
              child: UnconstrainedBox(
                child: Container(
                  width: ScreenAdapter.width(1060),
                  //height: ScreenAdapter.height(1000),
                  child: Dialog(
                    insetPadding: EdgeInsets.zero,
                    child: Container(
                      width: ScreenAdapter.width(1060),
                      padding: EdgeInsets.only(bottom: ScreenAdapter.height(10)),
                      child: StatefulBuilder(
                        builder: (BuildContext context, menuindex) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 250.0, imgHeight: 250.0),
                                    (item['optionGroupVoList']?.length > 0)
                                        ? Expanded(
                                      child: publicShowOneItemOptionGroupWidget(
                                          item['menuCode'], menuindex),
                                    )
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
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                                                  child: publicShowMenuTitle(
                                                      item['mainTitle'],
                                                      GFontSize.cartListTitleCount,
                                                      Gcolor.mainTitleColor),
                                                )
                                            ),
                                          ],
                                        ),

                                        Container(
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                                          child: Row(
                                            children: [
                                              Expanded(child: publicShowMenuSubtitle(item["subtitle"])),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //价格展示 item['currentPrice']
                                  Container(
                                    padding: EdgeInsets.only(right: ScreenAdapter.width(30)),
                                    //width: ScreenAdapter.width(260),
                                    alignment: Alignment.bottomRight,
                                    child: publicShowMenuPrice(
                                        _selectedMenuOptionChangePrice[item['menuCode']]+_addselectedMenuOptionChangePrice[item['menuCode']],
                                        item['price'],
                                        GFontSize.menuTwopriceLift,
                                        Gcolor.mainTitleColor,
                                        GFontSize.mainPrice,
                                        Gcolor.priceColor,
                                        GFontSize.menuTwopriceRight,
                                        Gcolor.mainTitleColor),
                                  ),
                                  //确认按钮
                                  InkWell(
                                    enableFeedback: false,
                                    onTap: () {

                                      //判断选择后option是否与optiongroup相等
                                      var currentPrice = item['currentPrice'];
                                      var optionCodeList = "";
                                      var optionTitle = "";
                                      if (item['optionGroupVoList']?.length > 0) {//item['optionGroupVoList'].length
                                        /*if (_selectedMenuOptionList[item['menuCode']].length < _selectedMenuOptionCheckedNum[item['menuCode']]) {
                                        showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                                        Navigator.pop(context);
                                        return;
                                      }*/

                                        //--------------检测option单选还是多选是否满足
                                        var attr = _menuOption[item['menuCode']];
                                        var nexOrder = true;
                                        for (var i = 0; i < attr.length; i++) {
                                          //如果是多选，那么需要判断该组option数量是否超过最大值
                                          if(int.parse(attr[i]["smallest"]) >0){
                                            var current_option_checked = 0;
                                            for (var n = 0; n < attr[i]['optionVoList'].length; n++) {
                                              if(attr[i]['optionVoList'][n]["checked"] == true){
                                                current_option_checked++;
                                              }
                                            }
                                            if(current_option_checked <int.parse(attr[i]["smallest"])){
                                              nexOrder = false;
                                              var showTag = GString.getToString(this._checkLanguage, "menu_option_less_smallest");
                                              showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                              break;
                                            }
                                          }

                                        }
                                        if(nexOrder == false) return;
                                        //--------------end
                                        var checkoptionGroupList = {};
                                        for (var optionItem in _selectedMenuOptionList[item['menuCode']]) {
                                          currentPrice += optionItem['currentPrice'];

                                          optionCodeList += (optionCodeList != "")
                                              ? "," + optionItem['optionCode']
                                              : optionItem['optionCode'];
                                          var groupKey = optionItem['groupCode'];
                                          //整理新数组
                                          checkoptionGroupList[groupKey] = {
                                            "optionTitles": (checkoptionGroupList[groupKey] == null) ? optionItem['mainTitle'] : checkoptionGroupList[groupKey]["optionTitles"]+","+optionItem['mainTitle'],
                                            "groupTitle":optionItem['groupTitle']
                                          };
                                        }

                                        checkoptionGroupList.forEach((key, value) {
                                          optionTitle += (optionTitle != "")
                                              ? "," + value['groupTitle']+":"+value['optionTitles']
                                              : value['groupTitle']+":"+value['optionTitles'];
                                        });

                                      }

                                      var cartItem = {
                                        "menuCode": item['menuCode'],
                                        "mainTitle": item['mainTitle'],
                                        "image": item['homeImage'],
                                        "currentPrice": currentPrice,
                                        "optionGroupVoList": optionCodeList,
                                        "optionVoListMsg": optionTitle,
                                        "goodsNum": 1,
                                        "qtyBounds": item['qtyBounds'],
                                        "unitPrice":currentPrice
                                      };
                                      publicAddCartMenu(cartItem, false).then((val) {

                                        if(val != false){
                                          _publicShowAddCartNew();
                                        }
                                        _changeInitialOption(item['menuCode'], menuindex);
                                        //更改显示购物车价格
                                        getCartPriceTotal();

                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      margin:EdgeInsets.only(top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),),
                                      width: ScreenAdapter.width(200),
                                      height: ScreenAdapter.height(75),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: ColorsUtil.hexToColor("#078E42"),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      child: Text(
                                          GString.getToString(
                                              this._checkLanguage, "add_option_cart"),
                                          style: TextStyle(
                                            fontSize: ScreenAdapter.fontSize(30),
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
                ),
              ),
            );
          });
    });
  }
  _publicShowOneItemWidgetv1(item){
    _changeInitialAllOption(item['menuCode']);
    Future.delayed(Duration(milliseconds: 200),() async {
      var subtitle = "";
      if (item["subtitle"] != null && item["subtitle"]?.length > 0) {
        for (var i = 0; i < item["subtitle"].length; i++) {
          subtitle += item["subtitle"][i];
        }
      }
      showDialog(
          context: context,
          //barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
          builder: (BuildContext context) {
            return RepaintBoundary(
              child: UnconstrainedBox(
                child: Container(
                  width: ScreenAdapter.width(1060),
                  //height: ScreenAdapter.height(1000),
                  child: Dialog(
                    insetPadding: EdgeInsets.zero,
                    child: Container(
                      // width: ScreenAdapter.width(1060),
                      width: ScreenAdapter.width(1060),
                      padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(10)),
                      child: StatefulBuilder(
                        builder: (BuildContext context, menuindex) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.only(left: ScreenAdapter.width(10),top: ScreenAdapter.height(10),right: ScreenAdapter.width(5),bottom: ScreenAdapter.height(10)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    (item['optionGroupVoList']?.length > 0)
                                        ? Expanded(
                                      child: publicShowOneItemOptionGroupWidgetv1(
                                          item['menuCode'], menuindex),
                                    )
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Container(
                                              padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                                              child: publicShowMenuTitle(
                                                  item['mainTitle'],
                                                  GFontSize.cartListTitleCount,
                                                  Gcolor.mainTitleColor),
                                            )
                                            ),
                                          ],
                                        ),

                                        Container(
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(30)),
                                          child: Row(
                                            children: [
                                              Expanded(child: publicShowMenuSubtitle(item["subtitle"])),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //价格展示 item['currentPrice']
                                  Container(
                                    padding: EdgeInsets.only(right: ScreenAdapter.width(30)),
                                    //width: ScreenAdapter.width(260),
                                    alignment: Alignment.bottomRight,
                                    child: publicShowMenuPrice(
                                        _selectedMenuOptionChangePrice[item['menuCode']]+_addselectedMenuOptionChangePrice[item['menuCode']],
                                        item['price'],
                                        GFontSize.menuTwopriceLift,
                                        Gcolor.mainTitleColor,
                                        GFontSize.mainPrice,
                                        Gcolor.priceColor,
                                        GFontSize.menuTwopriceRight,
                                        Gcolor.mainTitleColor),
                                  ),

                                  //确认按钮
                                  InkWell(
                                    enableFeedback: false,
                                    onTap: () {

                                      //判断选择后option是否与optiongroup相等
                                      var currentPrice = item['currentPrice'];
                                      var optionCodeList = "";
                                      var optionTitle = "";
                                      if (item['optionGroupVoList']?.length > 0) {//item['optionGroupVoList'].length
                                        /*if (_selectedMenuOptionList[item['menuCode']].length < _selectedMenuOptionCheckedNum[item['menuCode']]) {
                                          showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                                          return;
                                        }*/

                                        //--------------检测option单选还是多选是否满足
                                        var attr = _menuOption[item['menuCode']];
                                        var nexOrder = true;
                                        for (var i = 0; i < attr.length; i++) {
                                          //如果是多选，那么需要判断该组option数量是否超过最大值
                                          if(int.parse(attr[i]["smallest"]) >0){
                                            var current_option_checked = 0;
                                            for (var n = 0; n < attr[i]['optionVoList'].length; n++) {
                                              if(attr[i]['optionVoList'][n]["checked"] == true){
                                                current_option_checked++;
                                              }
                                            }
                                            if(current_option_checked <int.parse(attr[i]["smallest"])){
                                              nexOrder = false;
                                              var showTag = GString.getToString(this._checkLanguage, "menu_option_less_smallest");
                                              showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                              break;
                                            }
                                          }

                                        }
                                        if(nexOrder == false) return;
                                        //--------------end
                                        var checkoptionGroupList = {};
                                        for (var optionItem in _selectedMenuOptionList[item['menuCode']]) {
                                          currentPrice += optionItem['currentPrice'];

                                          optionCodeList += (optionCodeList != "")
                                              ? "," + optionItem['optionCode']
                                              : optionItem['optionCode'];
                                          var groupKey = optionItem['groupCode'];
                                          //整理新数组
                                          checkoptionGroupList[groupKey] = {
                                            "optionTitles": (checkoptionGroupList[groupKey] == null) ? optionItem['mainTitle'] : checkoptionGroupList[groupKey]["optionTitles"]+","+optionItem['mainTitle'],
                                            "groupTitle":optionItem['groupTitle']
                                          };
                                        }

                                        checkoptionGroupList.forEach((key, value) {
                                          optionTitle += (optionTitle != "")
                                              ? "," + value['groupTitle']+":"+value['optionTitles']
                                              : value['groupTitle']+":"+value['optionTitles'];
                                        });

                                      }

                                      var cartItem = {
                                        "menuCode": item['menuCode'],
                                        "mainTitle": item['mainTitle'],
                                        "image": item['homeImage'],
                                        "currentPrice": currentPrice,
                                        "optionGroupVoList": optionCodeList,
                                        "optionVoListMsg": optionTitle,
                                        "goodsNum": 1,
                                        "qtyBounds": item['qtyBounds'],
                                        "unitPrice":currentPrice
                                      };
                                      publicAddCartMenu(cartItem, false).then((val) {

                                        if(val != false){
                                          _publicShowAddCartNew();
                                        }
                                        _changeInitialOption(item['menuCode'], menuindex);
                                        //更改显示购物车价格
                                        getCartPriceTotal();

                                      });
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      margin:EdgeInsets.only(top: ScreenAdapter.height(10),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(15),),
                                      width: ScreenAdapter.width(200),
                                      height: ScreenAdapter.height(75),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: ColorsUtil.hexToColor("#078E42"),
                                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                      ),
                                      child: Text(
                                          GString.getToString(
                                              this._checkLanguage, "add_option_cart"),
                                          style: TextStyle(
                                            fontSize: ScreenAdapter.fontSize(30),
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
                ),
              ),
            );
          });
    });
  }

  //获取带option的widget
  publicShowOneItemOptionGroupWidget(menuCode, menuindex) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5),
          right: ScreenAdapter.width(3),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: _getOneItemOptionWidget(menuCode, menuindex),
      ),
    );
  }
  publicShowOneItemOptionGroupWidgetv1(menuCode, menuindex) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5),
          right: ScreenAdapter.width(3),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: _getOneItemOptionWidgetv1(menuCode, menuindex),
      ),
    );
  }

  //获取option widget
  _getOneItemOptionWidget(menuCode, setFirstState) {
    var optionGroupVoList = _menuOption[menuCode];
    List<Widget> options = []; //先建一个数组用于存放循环生成的widget
    if (optionGroupVoList != null &&
        optionGroupVoList.length > 0 &&
        optionGroupVoList != "") {
      for (var i = 0; i < optionGroupVoList.length; i++) {
        if(i >= _optionGroupMaxNum) break;
        List<Widget> optionSons = [];
        var optionVoList = optionGroupVoList[i]['optionVoList'];
        options.add(Container(
          padding: EdgeInsets.only(left:ScreenAdapter.width(5),top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                    text: "${optionGroupVoList[i]['groupName']}",
                    //GString.getToString(this._checkLanguage, "show_price_front"),
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(24.0),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                    children: [
                      TextSpan(
                        text: (optionGroupVoList[i]['remark'] !=null && optionGroupVoList[i]['remark']!="")?" ${optionGroupVoList[i]['remark']}":"",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(18.0),
                          fontWeight: FontWeight.w200,
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ));

        for (var j = 0; j < optionVoList.length; j++) {
          if(j >= _optionMaxNum) break;
          var optionVolistSon = optionVoList[j];
          var buttonColor =[];
          if (optionVolistSon['buttonColorValue'] != null && optionVolistSon['buttonColorValue'] != "") {
            buttonColor = optionVolistSon['buttonColorValue'].split(',');
          }
          optionSons.add(Container(
            width: ScreenAdapter.width(180),
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(5),
                top: ScreenAdapter.height(5),
                right: ScreenAdapter.width(5),
                bottom: ScreenAdapter.height(5)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                _changeOptionv1(menuCode, optionGroupVoList[i]["groupCode"],
                    optionVolistSon["optionCode"], setFirstState);
              },
              child: badges.Badge(
                showBadge: (optionVolistSon['currentPrice'] != 0) ? true : false,
                badgeContent: Text(
                    (optionVolistSon['currentPrice'] > 0) ?"+${optionVolistSon['currentPrice'].toString()}円":"${optionVolistSon['currentPrice'].toString()}円",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(16),
                      color: ColorsUtil.hexToColor(
                          Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position:badges.BadgePosition.topEnd(top: -18, end: -9),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding: EdgeInsets.only(left: 5,top: 3,right: 5,bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),

                ),
                child: Container(
                    width: ScreenAdapter.width(170),
                    height: ScreenAdapter.height(65),
                    alignment: Alignment.center,
                    decoration: (optionVolistSon['checked'] == true)
                        ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
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
                        : (buttonColor.length>0) ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
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
                    ): BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        (optionVolistSon['homeImage'] != "" &&
                            optionVolistSon['homeImage'] != null)
                            ? CachedNetworkImage(imageUrl:optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(18),
                            height: ScreenAdapter.height(30),
                            color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(4),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: ScreenAdapter.width(20),
                            maxWidth: ScreenAdapter.width(145),
                            minHeight: ScreenAdapter.height(30),
                            maxHeight: ScreenAdapter.height(58),
                          ),
                          child: AutoSizeText(
                              optionVolistSon['mainTitle'],
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenAdapter.fontSize(24.0),
                                color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                              ),
                              softWrap: true,
                              //minFontSize: 10,
                              //maxFontSize: 12,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center
                          ),
                        ),
                      ],
                    )
                ),
              ),
            ),
          ));

        }

        options.add(Container(
          child: Wrap(
            spacing: ScreenAdapter.width(2), // set spacing here
            runSpacing: ScreenAdapter.height(10),
            alignment: WrapAlignment.start,
            children: optionSons,
          ),
        ));

      }
    }

    return options;
  }
  _getOneItemOptionWidgetv1(menuCode, setFirstState) {
    var optionGroupVoList = _menuOption[menuCode];
    List<Widget> options = []; //先建一个数组用于存放循环生成的widget
    if (optionGroupVoList != null &&
        optionGroupVoList.length > 0 &&
        optionGroupVoList != "") {
      for (var i = 0; i < optionGroupVoList.length; i++) {
        if(i >= _optionGroupMaxNum) break;
        List<Widget> optionSons = [];
        var optionVoList = optionGroupVoList[i]['optionVoList'];
        options.add(Container(
          padding: EdgeInsets.only(left:ScreenAdapter.width(5),top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                    text: "${optionGroupVoList[i]['groupName']}",
                    //GString.getToString(this._checkLanguage, "show_price_front"),
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(24.0),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                    children: [
                      TextSpan(
                        text: (optionGroupVoList[i]['remark'] !=null && optionGroupVoList[i]['remark']!="")?" ${optionGroupVoList[i]['remark']}":"",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(18.0),
                          fontWeight: FontWeight.w200,
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ));

        for (var j = 0; j < optionVoList.length; j++) {
          if(j >= _optionMaxNum) break;
          var optionVolistSon = optionVoList[j];
          var buttonColor =[];
          if (optionVolistSon['buttonColorValue'] != null && optionVolistSon['buttonColorValue'] != "") {
            buttonColor = optionVolistSon['buttonColorValue'].split(',');
          }
          optionSons.add(Container(
            width: ScreenAdapter.width(190),
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(5),
                top: ScreenAdapter.height(5),
                right: ScreenAdapter.width(5),
                bottom: ScreenAdapter.height(5)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                _changeOptionv1(menuCode, optionGroupVoList[i]["groupCode"],
                    optionVolistSon["optionCode"], setFirstState);
              },
              child: Stack(
                children: [
                  Container(
                    height: ScreenAdapter.height(200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //color: ColorsUtil.hexToColor("#FFFFFF"),
                      border: Border.all(
                        color: ColorsUtil.hexToColor("#c9c9c9"),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: ColorsUtil.hexToColor("#F9F9F9"),
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (optionVolistSon['homeImage'] != "" &&
                            optionVolistSon['homeImage'] != null)
                            ? CachedNetworkImage(imageUrl:optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(180),
                            height: ScreenAdapter.height(135),
                            //color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        Container(
                            width: ScreenAdapter.width(180),
                            height: ScreenAdapter.height(60),
                            alignment: Alignment.center,

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: ScreenAdapter.width(20),
                                    maxWidth: ScreenAdapter.width(170),
                                    minHeight: ScreenAdapter.height(30),
                                    maxHeight: ScreenAdapter.height(60),
                                  ),
                                  child: AutoSizeText(
                                      optionVolistSon['mainTitle'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenAdapter.fontSize(24.0),
                                        color: ColorsUtil.hexToColor("#914F14"),
                                      ),
                                      softWrap: true,
                                      //minFontSize: 10,
                                      //maxFontSize: 12,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                  (optionVolistSon['currentPrice'] != 0)
                      ? Positioned(
                    right: ScreenAdapter.width(0),
                    top: ScreenAdapter.height(0),
                    child: Container(
                      //width: ScreenAdapter.width(46),
                        height: ScreenAdapter.height(24),
                        alignment: Alignment.center,
                        //padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                        padding: EdgeInsets.only(
                          //top:ScreenAdapter.height(2),
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)
                        ),
                        // alignment: Alignment.topRight,
                        decoration: BoxDecoration(
                          color: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          /*image: DecorationImage(
                                image: (optionVolistSon['currentPrice'] > 0) ? AssetImage(GImage.getImageString("imgpublic", "price_tag")) :AssetImage(GImage.getImageString("imgpublic", "price_subtraction_tag")),
                                fit: BoxFit.fill,
                              ),*/
                        ),
                        child: Text(
                            (optionVolistSon['currentPrice'] > 0) ?"+${optionVolistSon['currentPrice'].toString()}円":"${optionVolistSon['currentPrice'].toString()}円",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(16),
                              color: ColorsUtil.hexToColor(
                                  Gcolor.optionBtnColor),
                            ))/*Container(
                              alignment: Alignment.topRight,
                              // 旋转
                              transform: Matrix4.rotationZ(0.78),
                              child: Text(
                                  "${optionVolistSon['currentPrice'].toString()}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(14),
                                    color: ColorsUtil.hexToColor(
                                        Gcolor.optionBtnColor),
                                  )),
                            )*/),
                  )
                      : Container(
                    height: 0,
                  ),
                  (optionVolistSon['checked'] == true)
                      ? Positioned(
                    right: ScreenAdapter.width(0),
                    top: ScreenAdapter.height(40),
                    child: Container(
                        width: ScreenAdapter.width(180),
                        height: ScreenAdapter.height(150),
                        alignment: Alignment.center,

                        child: Image.asset(
                          GImage.getImageString("imgpublic", "menu_option_check"),
                          width: ScreenAdapter.width(90),
                          fit: BoxFit.fitWidth,
                          color: Colors.green,
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

        }

        options.add(Container(
          child: Wrap(
            spacing: ScreenAdapter.width(10), // set spacing here
            runSpacing: ScreenAdapter.height(10),
            alignment: WrapAlignment.start,
            children: optionSons,
          ),
        ));

      }
    }

    return options;
  }

  _clearCartList() {
    Get.find<HomePageController>().removeAllFromCart();
    controller.getCardList();
    getCartPriceTotal();
  }

  //购物车
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
    if(total != null)
      if(mounted) {
        setState(() {
          _shopCartTotalPrice =
          total["totalPrice"] == null ? "0" : total["totalPrice"].toString();
        });
      }

    var totalNum = await controller.getCartTotalNum();
    if(mounted) {
      setState(() {
        _showCartTotalGoodsNum = totalNum;
      });
    }


    //return sum.toString();
  }

  //购物车商品循环版本
  _showShoppingCart() {
    return RepaintBoundary(
      child: Container(
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
                    left: ScreenAdapter.width(5),
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
                                          width: ScreenAdapter.width(720),
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
                                                    children: controller.cartItems.map((d) => generateCartList(context, d)).toList(),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  ),

                                ],
                              ),
                            )),
                        Container(
                          height: ScreenAdapter.height(290),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              SizedBox(height: ScreenAdapter.height(25)),
                              InkWell(
                                  onLongPress: (){
                                    if(int.parse(_shopCartTotalPrice) >0){
                                      Navigator.pushNamed(context, '/middlewareSettingPage', arguments: {"machineCode": this._machineCode});
                                    }

                                  },
                                  child:Container(
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
                                              text: formatMoney(_shopCartTotalPrice.toString()),
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
                                  )
                              ),


                              SizedBox(height: ScreenAdapter.height(18)),
                              InkWell(
                                enableFeedback: false,
                                onTap: () {
                                  if (int.parse(_shopCartTotalPrice) ==0) {
                                    return false;
                                  }

                                  //点餐方式只有一种并且未开pos
                                  /*if(_isAllowPos == "0"){
                                  _doSubmitOrder();
                                }else{*/
                                  _doSubmitOrder();
                                  //_showSelectMealTypeAndPaymentMethodDialog();
                                  //}



                                },
                                child: Container(
                                  width: ScreenAdapter.width(300),
                                  height: ScreenAdapter.height(115),
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
      ),
    );
  }

  Widget generateCartList(BuildContext context, ShopItemModel d) {
    var tipColor = (_menuLackMap.containsKey(d.menuCode) == true) ? "#ff0000":Gcolor.mainTitleColor;

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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            /*Container(
                width: ScreenAdapter.width(30),
                child: Image.asset(GImage.getImageString("imgpublic", "delOne"),
                    width: ScreenAdapter.width(20),
                    //height: ScreenAdapter.height(44),
                    fit: BoxFit.fill),
              ),*/
            Expanded(
                child: InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: (){
                    showDialogTag(d.id);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        left: ScreenAdapter.width(5),
                        top: ScreenAdapter.height(8),
                        bottom: ScreenAdapter.height(8)),
                    //width: ScreenAdapter.width(495),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.mainTitle,
                          style: TextStyle(
                              fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitle),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(tipColor)
                          ),
                        ),
                        /*RichText(
                          text: TextSpan(
                              text: d.mainTitle,
                              style: TextStyle(
                                  fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitle),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(tipColor)
                              ),
                              children: [
                                d.goodsNum>1?TextSpan(
                                  text: " X${d.goodsNum}",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(
                                        GFontSize.cartListTitleCount),
                                    color: ColorsUtil.hexToColor(tipColor),
                                  ),
                                ):TextSpan(
                                  text: "",
                                ),

                              ]),
                        ),*/
                        (d.optionVoListMsg != "")? Text(
                          "${d.optionVoListMsg}",
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(
                                GFontSize.cartListTitleTag),
                            color: ColorsUtil.hexToColor(
                                Gcolor.mainTitleColor),
                          ),
                        )
                            : Text(""),
                      ],
                    ),
                  ),
                )
            ),
            Container(
              width: ScreenAdapter.width(105),
              padding: EdgeInsets.only(right: ScreenAdapter.width(10)),
              alignment: Alignment.centerRight,
              child: Text(
                formatMoney(d.currentPrice.toString()),
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(GFontSize.mainPriceRight),
                    fontWeight: FontWeight.w600,
                    color: ColorsUtil.hexToColor(tipColor)),
              ),
            ),
            Container(
              width: ScreenAdapter.width(200),
              height: ScreenAdapter.height(60.0),
              margin: EdgeInsets.only(right: ScreenAdapter.width(5)),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(width: 1.0,color: Colors.black)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //减号
                  //CoustomIconButton(icon: Icons.remove,isAdd: false),
                  InkWell(
                    onTap: (){
                      var cartItem = {
                        "cartId": d.id,
                        "menuCode": d.menuCode,
                        "unitPrice": d.unitPrice,
                        "goodsNum": 1,
                        "qtyBounds":d.qtyBounds
                      };
                      if(d.goodsNum <=1){
                        showDialogTag(d.id);
                      }else{
                        publicChangeCartMenuCount(cartItem,"reduce").then((val) {

                          //更改显示购物车价格
                          getCartPriceTotal();
                        });
                      }

                    },
                    child: Container(

                      width: ScreenAdapter.width(55.0),//是正方形的所以宽和高都是45
                      height: ScreenAdapter.height(50.0),
                      alignment: Alignment.center,//上下左右都居中
                      decoration: BoxDecoration(
                        //color: Colors.white,
                          border: Border(//外层已经有边框了所以这里只设置右边的边框
                              right:BorderSide(width: 1.0,color: Colors.black12)
                          )
                      ),
                      child: Text(
                        "－",
                        style: TextStyle(
                          fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitleCount),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  //输入框
                  Container(
                    width: ScreenAdapter.width(85.0),
                    height: ScreenAdapter.height(45.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(width: 1,color: Colors.black12),
                          right: BorderSide(width: 1,color: Colors.black12),
                        )
                    ),
                    child: Text(
                      "${d.goodsNum}",
                      style: TextStyle(
                          fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitleCount),
                          fontWeight: FontWeight.w500,
                          color: ColorsUtil.hexToColor(tipColor)
                      ),
                    ),
                  ),
                  //加号
                  //CoustomIconButton(icon: Icons.add,isAdd: true),
                  InkWell(
                    onTap: (){
                      /*if(_totalCount >=_maxtotalCount){
                          //showToast("msg");
                          return;
                        }
                        setState(() {
                          _totalCount++;
                        });
                        _postextraPerson();*/
                      /*if(d.qtyBounds >0){
                        if(d.goodsNum>=d.qtyBounds){
                          var showString = GString.getToString(this._checkLanguage,"show_storage_num_error");
                          showToast("${showString}");
                          return;
                        }
                      }*/

                      var cartItem = {
                        "cartId": d.id,
                        "menuCode": d.menuCode,
                        "unitPrice": d.unitPrice,
                        "goodsNum": 1,
                        "qtyBounds":d.qtyBounds
                      };
                      publicChangeCartMenuCount(cartItem,"add").then((val) {

                        //更改显示购物车价格
                        getCartPriceTotal();
                      });
                    },
                    child: Container(
                      width: ScreenAdapter.width(55.0),//是正方形的所以宽和高都是45
                      height: ScreenAdapter.height(50.0),
                      alignment: Alignment.center,//上下左右都居中

                      child: Text(
                        "＋",
                        style: TextStyle(
                          fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitleCount),
                          fontWeight: FontWeight.w600,
                          color: (d.goodsNum==d.qtyBounds)?Colors.black12:Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
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
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _showTag,
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
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

      //自定义声音
      playQRScannerSound();

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
        "total": orderTotlaPrice,
        //"takeout": (_dining_type == "2") ? true: false,
        "takeout": _mealType,
      };
      request('webBootOrder', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString());
        EasyLoading.dismiss();
        //LogUtil.d(response);
        if (response['code'] == 200) {
          //"paymentMethod" 1，现金 2，扫码 3，刷卡 4nfc

          setState(() {
            _doSubmitOrderId = response['data']["orderId"];
          });

          //只有现金，并且其余都为false的时候，直接跳转支付
          if(_showCash == true &&
              _isAllowPos == "0" &&
              _showAlipay == false &&
              _showWechat == false &&
              _showPayPay == false
          ){
            setState(() {
              _payment_method_num = "1";
            });
            gotoSettlement();
          }else{
            _showSelectMealTypeAndPaymentMethodDialog();
          }



        }else{
          _getBookingBootMenu();
          setState(() {
            _menuLackMap = response['data']["menuLackMap"];
          });
          showToast(response['data']["message"]);
        }
      });
    }
  }

  //选择食用方式和支付方式
  _showSelectMealTypeAndPaymentMethodDialog() async {
    await showDialog(
        barrierDismissible: false, //表示点击灰色背景的时候是否消失弹出框
        context: context,
        builder: (BuildContext context) {

          return SelectPaymentPage(
              checkLanguage: _checkLanguage,
              menuCount: _showCartTotalGoodsNum,
              //mealType:_mealType,
              isAllowPos:_isAllowPos,
              payment_method_num:_payment_method_num,
              showCash:this._showCash,
              showWechat:this._showWechat,
              showAlipay:this._showAlipay,
              showPayPay:this._showPayPay,
              showauPay:this._showauPay,
              showdPay:this._showdPay,
              showrPay:this._showrPay,
              showmPay:this._showmPay,
              showCreditCard:this._showCreditCard,
              showPosEdy:this._showPosEdy,
              showPosiD:this._showPosiD,
              showPosIC:this._showPosIC,
              showPosQUICPay:this._showPosQUICPay,
              showPosWAON:this._showPosWAON,
              showPosnanaco:this._showPosnanaco,
              showVisa:this._showVisa,
              showMaster:this._showMaster,
              showJcb:this._showJcb,
              showUnionPay:this._showUnionPay,
              showAmericanExpress:this._showAmericanExpress,
              showDinersClub:this._showDinersClub,
              shopCartTotalPrice:_shopCartTotalPrice,
              tableNum: "",
              onConfrimClick: (String isAllowPos, String payment_method_num) {

                setState(() {
                  _isAllowPos = isAllowPos;
                  _payment_method_num = payment_method_num;
                  _showOpenPayment = true;
                });
                //230629点击弹出支付方式后，需要重新请求下后台获得orderid
                postNewOrderId();
                /*var paymentMethod = ["3","4","5","6","7","8","9","10"];
                if (paymentMethod.contains(_payment_method_num) == true) {
                  _getPosSettingInfo();
                }else{
                  gotoSettlement();
                }*/
                /*if(_payment_method_num == "3" || _payment_method_num == "4"){
                  _getPosSettingInfo();
                }else{
                  gotoSettlement();
                }*/

              },
              onCancelClick: (String isBack){
                if(isBack == "back"){
                  CancelOrder();
                }
              }
          );
        });
  }

  postNewOrderId() {

    var formData = {
      "orderId": _doSubmitOrderId,
    };
    request('webBootToPayConfirm', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      EasyLoading.dismiss();

      if (response['code'] == 200 && response['data'] !=null && response['data']['orderId'] !=null) {

        setState(() {
          _doSubmitOrderId = response['data']["orderId"];
        });

        var paymentMethod = ["3","4","5","6","7","8","9","10"];
        if (paymentMethod.contains(_payment_method_num) == true) {
          _getPosSettingInfo();
        }else{
          gotoSettlement();
        }
      }else{

        showToast(response['data']["message"]);
      }
    });


  }



  gotoSettlement() {
    Navigator.pushNamed(context, '/settlement',
        arguments: {
          "checkLanguage": this._checkLanguage,
          "machineCode": this._machineCode,
          "orderId" : _doSubmitOrderId,
          "totalPrice" : _shopCartTotalPrice,
          "machineMode":"1",
          "isAllowPos":_isAllowPos,
          "posIp":_pos_ip,
          "posPort":_pos_port,
          "paymentMethod":_payment_method_num,
          "showWechat":this._showWechat,
          "showAlipay":this._showAlipay,
          "showPayPay":this._showPayPay,
          "showCreditCard":_showCreditCard,
          "showauPay":this._showauPay,
          "showdPay":this._showdPay,
          "showrPay":this._showrPay,
          "showmPay":this._showmPay,
          "showPosEdy":this._showPosEdy,
          "showPosiD":this._showPosiD,
          "showPosIC":this._showPosIC,
          "showPosQUICPay":this._showPosQUICPay,
          "showPosWAON":this._showPosWAON,
          "showPosnanaco":this._showPosnanaco,
          "showVisa":this._showVisa,
          "showMaster":this._showMaster,
          "showJcb":this._showJcb,
          "showUnionPay":this._showUnionPay,
          "showAmericanExpress":this._showAmericanExpress,
          "showDinersClub":this._showDinersClub,
          "showOpenPayment":_showOpenPayment
        });
  }

  CancelOrder() {
    var formData = {
      "machineCode": _machineCode,
      "orderId": _doSubmitOrderId,
      "model": "0",
    };
    request('webBootCancelV1', method: 'POST', parameters: formData);

  }

  _getPosSettingInfo() async {
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    setState(() {
      _pos_ip = posSettingInfo['posIp'];
      _pos_port = posSettingInfo['posPort'];
    });
    gotoSettlement();
  }


  //清空购物车弹出提示、
  showDialogTag(menuId) {

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Container(
            width: ScreenAdapter.width(950),
            child: SimpleDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                title: Align(
                    alignment: Alignment.center,
                    child:  Text(GString.getToString(this._checkLanguage, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
                ),
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(650),

                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          child: Text(GString.getToString(this._checkLanguage, "show_del_cart_item_tag"),
                              style: TextStyle(fontSize: ScreenAdapter.fontSize(28))),
                          alignment: Alignment(0, 0),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Divider(
                          thickness: 1.0,
                          color: Colors.black12,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 120.0),
                              child: TextButton(
                                child: Text(
                                  GString.getToString(this._checkLanguage, "show_del_cart_item_no"),
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: ScreenAdapter.fontSize(32.0)),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                            //垂直分割线
                            SizedBox(
                              width: 1,
                              height: 40,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.black12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 120.0),
                              child: TextButton(
                                child: Text(
                                  GString.getToString(this._checkLanguage, "show_del_cart_item_yes"),
                                  style: TextStyle(
                                      color: Colors.lightBlue,
                                      fontSize: ScreenAdapter.fontSize(32.0)),
                                ),
                                onPressed: () async {
                                  //widget.confirmCallback('确定');
                                  Get.find<HomePageController>().removeFromCart(menuId ?? 0);
                                  //print("Item removed from cart successfully");
                                  //删除商品声音
                                  deleteItemSound();
                                  controller.getCardList();
                                  //更改显示购物车价格
                                  getCartPriceTotal();

                                  Navigator.pop(context);
                                },
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ]
            ),
          );
        });
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
