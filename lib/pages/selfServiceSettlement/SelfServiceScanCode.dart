import 'dart:async';
import 'dart:convert';
import 'dart:io';


import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_swiper_plus/flutter_swiper_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/config/colorsUtil.dart';
import 'package:foodorder/config/imageData.dart';
import 'package:foodorder/services/HomeServices.dart';
import 'package:foodorder/services/ScreenAdapter.dart';
import 'package:foodorder/services/EventBus.dart';
import 'package:foodorder/services/showToast.dart';
import 'package:paycube/paycube.dart';
import 'package:get/get.dart';
import 'package:foodorder/controller/homePageController.dart';
import 'package:foodorder/services/Storage.dart';

import 'package:foodorder/config/string.dart';
import 'package:foodorder/services/HttpService.dart';

import 'package:foodorder/config/color.dart';
import 'package:foodorder/pages/checkOut/Appointment.dart';

import 'package:foodorder/services/GetxStorage.dart';
import 'package:foodorder/services/showImage.dart';
import '../../config/fontSize.dart';
import '../../models/ItemModel.dart';
import '../../services/formatMoney.dart';
import '../../widget/LoadState.dart';
import '../menu/SelectPayment.dart';


class selfServiceScanCodePage extends StatefulWidget {
  Map arguments;
  selfServiceScanCodePage({Key key, this.arguments}) : super(key: key);

  _selfServiceScanCodePageState createState() => _selfServiceScanCodePageState();
}

class _selfServiceScanCodePageState extends State<selfServiceScanCodePage> {

  TextEditingController _scanQrCodeController = new TextEditingController();
  FocusNode _scanQrCodeFocusNode = FocusNode();
  HomePageController controller = Get.put(HomePageController());

  FToast fToast;

  Timer checkTimer;
  Timer stopChecktimer;
  Timer closetimer;

  var _stopStatus;
  var _closeStatus;
  String _machineCode = "";
  String _tableCode = "";
  var _menu_direction = "1";//1 默认顶部横向  2 左侧纵向
  var _checkLanguage = "JP";
  var _scanQrCode = "";
  var _isReservation = "0";
  var _actuarial = false;
  var _lineup = false;
  var _takeOut = false; //是否允许外带

  var _isAllowPos = "0"; //1 使用信用卡刷卡  0 不可使用
  var _pos_ip = "";
  var _pos_port = "";

  var _payment_method_num = "0"; //支付类型选择

  //顶部展示支付类型
  var _showOpenPayment = false;
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

  var _orderId = "";
  var _totlaPrice = "0";
  var _tableNum = "0";

  var _selectedGoodsList = [];

  var _machineLanguagesList = [];

  var _isBag = "";

  var _shopCartTotalPrice = "0";
  var _showCartTotalGoodsNum = 0;
  var cartnum = 6;
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
    _isBag = widget.arguments["isBag"];

    EasyLoading.dismiss();

    Future.delayed(const Duration(), () => SystemChannels.textInput.invokeMethod('TextInput.hide'));

    _getMachineInfo();


    //监听增加打开现金机的广播
    eventBus.on<PayCubeEvent>().listen((event) {
      CheckPayCube();
    });

    //监听清除购物车的广播
    eventBus.on<clearCartEvent>().listen((event) {
      _clearCartList();
    });

  }

  @override
  void dispose() {
    // TODO: implement dispose
    checkTimer?.cancel();
    stopChecktimer?.cancel();
    closetimer?.cancel();
    eventBus.fire(new clearCartEvent('支付成功...'));
    super.dispose();
  }

  //打开现金机
  OpenPayCube() async {
    String checkStatus = await Paycube.CheckPayCubeStatus;

    //如果检测现金机打开错误，则重新打开一下
    if(checkStatus == "openError"){
      String openStatus = await Paycube.openPayCube;
      //print("机器未打开lib未null，重新打开并连接了");
    }else{
      await Paycube.setReceiveEvent;
      //print("机器已打开，并setreceive");
    }

    //await Paycube.endTrade;
  }

  //检测现金机状态
  CheckPayCube() async {
    String machineStatus = await Paycube.getPayCubeMachineStatus;

    checkTimer?.cancel();
    checkTimer = Timer.periodic(Duration(milliseconds: 600), (Timer checktimer) async {
      String machineStatus = await Paycube.getPayCubeMachineStatus;
      // 循环一定要记得设置取消条件，手动取消
      //待機中(入金不可)正常
      if (machineStatus == "30--10--10--10") {
        checktimer.cancel();
      }else{
        stopPaycube();
        checktimer.cancel();
      }
    });

  }

  stopPaycube() async {
    await Paycube.setReceiveEvent;
    var endStatus = await Paycube.endPayCube;
    stopChecktimer?.cancel();
    stopChecktimer = Timer.periodic(Duration(milliseconds: 500), (Timer stopcheck) async {
      _stopStatus =  await Paycube.getPayCubeStopCashStatus;
      //await Paycube.setReceiveEvent;
      // 循环一定要记得设置取消条件，手动取消
      if (_stopStatus == "StopSuccess") {
        closePaycube();
        stopcheck.cancel();

      }else if(_stopStatus == "Error-A0--02"){
        //处理中
        await Paycube.endPayCube;
      }else{
        await Paycube.endPayCube;
      }
    });
  }

  closePaycube() async {
    //取引终了结束交易
    var endTrade = await Paycube.endTrade;
    await Paycube.setReceiveEvent;
    closetimer?.cancel();
    closetimer = Timer.periodic(Duration(milliseconds: 500), (Timer closecheck) async {
      _closeStatus =  await Paycube.getPayCubeEndTradeStatus;
      // 循环一定要记得设置取消条件，手动取消
      if (_closeStatus == "EndSuccess" || _closeStatus == "Error-A0--02") {
        closecheck.cancel();
      }else{

        await Paycube.endTrade;
      }
    });
  }

//获取机器信息
  _getMachineInfo() async {
    var machineCode = await HomeServices.getMachineInfo();
    if (machineCode != "") {
      setState(() {
        _machineCode = machineCode;
      });

    }

    _getSystemSettingInfo();
  }

  _getSystemSettingInfo() async {
    Map SystemSettingInfo = await HomeServices.getSystemSettingInfo();

    setState(() {
      _isAllowPos = SystemSettingInfo['isAllowPos'];
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

      //执行完后过 加载动画
      _layoutState = LoadDataState.State_Success;
    });
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
        this._getMachineActivateInfo();
      },
      errorRetry: () {
        setState(() {
          _layoutState = LoadDataState.State_Error;
        });
        this._getMachineActivateInfo();
      }, //错误按钮点击过后进行重新加载
      successWidget: Column(
        children: [
          Container(
            height: 0,
            //padding: EdgeInsets.only(left: 20),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                      keyboardType: TextInputType.text,
                      autofocus: true,
                      showCursor: true, // 显示光标
                      //readOnly: true,
                      controller: _scanQrCodeController,
                      focusNode: _scanQrCodeFocusNode,
                      decoration: InputDecoration(
                        hintText: "请扫码",
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: TextStyle(fontSize: ScreenAdapter.fontSize(11.0)),
                      onChanged: (value) {
                        //print(value);
                        if(value.length==1){
                          _showOrderEasyLoading();
                        }

                      },
                      onSubmitted: (value){
                        setState(() {
                          this._tableCode = value;
                        });

                        Future.delayed(Duration(milliseconds: 300), () {
                          _doNextPay();
                        });



                      },

                      /// 扫码密码
                    )
                ),
              ],
            ),
          ),
          Expanded(
              child: RepaintBoundary(
                child: Container(
                  color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                  height: ScreenAdapter.height(1580),
                  child: Row(
                    children: [
                      Scrollbar(
                          child: SingleChildScrollView(
                            physics: ClampingScrollPhysics(),
                            child: Container(
                              width: ScreenAdapter.width(1080),
                              height: ScreenAdapter.height(1580),
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
                ),
              )),

          _showShoppingCart(),

        ],
      ),
    );
  }

  showScanCodeModel(){
    return Container();
  }

  _clearCartList() {
    Get.find<HomePageController>().removeAllFromCart();
    controller.getCardList();
    getCartPriceTotal();
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
                              width: ScreenAdapter.width(440),
                              alignment: Alignment.bottomLeft,
                              padding: EdgeInsets.only(left: ScreenAdapter.width(40),bottom: ScreenAdapter.height(30)),
                              child: InkWell(
                                onTap: () {
                                  try {
                                    controller.removeAllFromCart();
                                    Future.delayed(Duration(milliseconds: 200),() async {
                                      Navigator.of(context).pop();
                                    });
                                  } catch (_) {}
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  width: ScreenAdapter.width(180),
                                  height: ScreenAdapter.height(80),
                                  //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                                  decoration: BoxDecoration(
                                    color: ColorsUtil.hexToColor("#FFFFFF"),
                                    //设置圆角
                                    borderRadius: new BorderRadius.circular((5.0)),
                                  ),
                                  child: Text(
                                    GString.getToString(this._checkLanguage, "settlement_back"),
                                    style: TextStyle(
                                        color: ColorsUtil.hexToColor("#2D2D2D"),
                                        fontWeight: FontWeight.w500,
                                        fontSize: ScreenAdapter.fontSize(34.0)),
                                  ),
                                ),
                              ),
                            ),),
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

                                  _doSubmitOrder();



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
                        /*publicChangeCartMenuCount(cartItem,"reduce").then((val) {

                          //更改显示购物车价格
                          getCartPriceTotal();
                        });*/
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
                      /*publicChangeCartMenuCount(cartItem,"add").then((val) {

                        //更改显示购物车价格
                        getCartPriceTotal();
                      });*/
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

  deleteItemSound() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/697.wav"),
      autoStart: true,
      volume: 0.8,
    );
  }

  playQRScannerSound() async {
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/14428.wav"),
      autoStart: true,
      volume: 0.3,
    );
  }

  getCartPriceTotal() async {

    controller.getCardList();
    var total = await controller.getCartAllPrice();
    if(total != null)
      setState(() {
        _shopCartTotalPrice = total["totalPrice"] == null ? "0" : total["totalPrice"].toString();
      });

    var totalNum = await controller.getCartTotalNum();
    setState(() {
      _showCartTotalGoodsNum = totalNum;
    });

  }


  _doNextPay(){print("扫码进来了");
    var _orderkey = _tableCode;
    print(_tableCode);
    if(_tableCode !=""){

      var formData = {
        "machineCode": _machineCode,
        "barCode":_tableCode
      };print(formData);

      request('webBootBarCodeQuery', method: 'POST', parameters: formData).then((val) {
        var response = json.decode(val.toString()); print(response);
        EasyLoading.dismiss();
        setState(() {
          _scanQrCodeController.text = "";
          _tableCode = "";
        });
        FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点

        //print(response);
        if (response['code'] == 200 && response["data"] !=null && response["data"].isNotEmpty) {
          print(response);
          _publicAddCart(response["data"]);

        }else{
          setState(() {
            _scanQrCodeController.text = "";
            _tableCode = "";
           // FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
          });

          //_showDialogError(response['msg']);
          FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点
        }
      });
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

      /*if(val != false){
        _publicShowAddCartNew();
      }*/

      //更改显示购物车价格
      getCartPriceTotal();
    });
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

  _showOrderEasyLoading(){
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onLongPress: (){
                EasyLoading.dismiss();
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(GImage.getImageString("imgpublic", "printticketloading"),fit: BoxFit.fitHeight),
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );

  }

  //购物车
  getItemTotal(List items) {
    int sum = 0;
    items.forEach((e) {
      sum += e.currentPrice;
    });

    return sum.toString();
  }

  //提交订单
  _doSubmitOrder(){
    setState(() {
      _scanQrCodeController.text = "";
      _tableCode = "";
    });
    FocusScope.of(context).requestFocus(_scanQrCodeFocusNode);     // 获取焦点

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
        "takeout": true,
      };
      request('webBootCalculateOrder', method: 'POST', parameters: formData).then((val) {
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
            _showSelectPaymentMethodDialog();
          }



        }else{
          setState(() {
            _menuLackMap = response['data']["menuLackMap"];
          });
          showToast(response['data']["message"]);
        }
      });
    }
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
          "showOpenPayment":_showOpenPayment
        });
  }

  //选择食用方式和支付方式
  _showSelectPaymentMethodDialog() async {
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


              },
              onCancelClick: (String isBack){
                if(isBack == "back"){
                  CancelOrder();
                }
              }
          );
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

  _getPosSettingInfo() async {
    Map posSettingInfo = await HomeServices.getPosSettingInfo();
    setState(() {
      _pos_ip = posSettingInfo['posIp'];
      _pos_port = posSettingInfo['posPort'];
    });
    gotoSettlement();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.light,
        child: _listView(context),
      ),
    );;
  }
}
