import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';



import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/fontSize.dart';
import '../../../config/imageData.dart';
import '../../../controllers/ImageCacheManager.dart';
import '../../../controllers/machine_info.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../models/ItemModel.dart';
import '../../../services/HomeServices.dart';
import '../../../services/HttpService.dart';
import '../../../services/scale_serial_service.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../services/logUtil.dart';
import '../../../services/showImage.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../views/SelectPayment.dart';
import '../views/option_widgets/option_view.dart';
import '../views/showOneItemOptionWidget.dart';
import '../views/showOneItemOptionWidgetV1.dart';
import 'menu_page_extension.dart';

class MenuPageController extends GetxController with StateMixin {
  //TODO: Implement MenuPageController
  OrderSqlController ordersqlcontroller = Get.find<OrderSqlController>();
  MachineInfoController machineInfo = Get.find();
   FToast? fToast;
  final customCacheManager = menuImageCacheManager;

  //默认语言包选择
  RxString checkLanguage = "JP".obs;

  /// 麻辣烫扫盆码得到的盆号；普通券卖或未开扫码时为空，不传 webBootOrder.tableNo
  String spicyTableNo = '';

  /// 扫码优惠金额（正数＝减免多少円）；码前缀 smartwe 时由优惠接口写入
  /// 接口 key：webBootBarCodeMenuQuery（后续换接口只改 http_conf）
  final RxInt cartDiscountYen = 0.obs;

  RxString classTag = "".obs;
  RxList topMenu = [].obs;
  RxList showCartItems = [].obs;
  RxMap showItem = {}.obs;

  RxMap menuOption = {}.obs; //牛肉面及定食的option数组
  RxMap noChangeinitialmenuOption = {}.obs;//牛肉面及定食的option数组，不做改变
  RxMap initialMenuOption = {}.obs; //牛肉面及定食的初始option数组
  RxMap selectedMenuOptionList = {}.obs; //牛肉面选中的option组成的数组
  RxMap selectedMenuOptionCheckedNum = {}.obs; //牛肉面默认选中的option 数量

  RxMap selectedMenuOptionChangePrice = {}.obs; //牛肉面默认选中的option 价格
  RxMap addselectedMenuOptionChangePrice = {}.obs; //牛肉面默认选中的option 需要增加的加个

  RxString shopCartTotalPrice = "0".obs;
  RxInt showCartTotalGoodsNum = 0.obs;
  RxBool showOpenPayment = false.obs;

  RxInt optionMaxNum = 120.obs;
  RxInt optionGroupMaxNum = 100.obs;

  //如果下单时候报错，则查看是否因为库存不足
  RxMap menuLackMap = {}.obs;
  RxString doSubmitOrderId = "".obs;

  RxBool canAddCart = true.obs;

  bool showShopCart = false;

  List recommendFoods = [];
  List recommendBookList = [];
  bool showRecommend = false;
  bool showCartView = false;
  bool paymentIsShow = false;

  int selectIndex = 0;
  bool isChangingPage = false;
  //MenuSidebarInfo? sidebarInfo;
  late List menuList;
  late List<String> menuCategory;
  final PageController pageController = PageController(viewportFraction: 1.0);
  bool forceUpdate = false;

  RxString bgColor = "#F9F9F9".obs;

  /// 分类菜单网络请求去重（仅内存，不落盘）
  final Map<String, Future<bool>> categoryMenuPrefetchTasks = {};

  /// 每次重新拉分类时递增，忽略过期的菜单响应
  int menuLoadGeneration = 0;

  /// 正在写库的 key（menuCode 或 cart:行 id），防止限购连点超卖
  final Set<String> _cartAddInFlight = {};

  /// 当前已打开的规格弹窗对应商品，防止重复弹窗
  String? _openOptionMenuCode;

  /// 下单请求进行中，防止重复提交
  bool _submitInFlight = false;

  /// 麻辣烫菜单页：扫码枪隐藏输入（仅 spicyHotPot 模式）
  final TextEditingController spicyScanQrController = TextEditingController();
  final FocusNode spicyScanQrFocusNode =
      FocusNode(debugLabel: 'SpicyMenuBarCode');
  bool _spicyBarCodeQueryInFlight = false;

  /// 是否启用菜单页扫码直接加购（麻辣烫选其他菜品页）
  bool get isSpicyHotPotMenuScanEnabled =>
      machineInfo.currentMode == MachineMode.spicyHotPot;

  bool isMenuAddLocked(String menuCode) => _cartAddInFlight.contains(menuCode);

  bool isCartRowLocked(int? cartId) =>
      cartId != null && _cartAddInFlight.contains('cart:$cartId');

  bool _tryLockCartWrite(String lockKey) {
    if (_cartAddInFlight.contains(lockKey)) {
      return false;
    }
    _cartAddInFlight.add(lockKey);
    return true;
  }

  void _unlockCartWrite(String lockKey) {
    _cartAddInFlight.remove(lockKey);
  }

  bool _tryLockCartAdd(String menuCode) => _tryLockCartWrite(menuCode);

  void _unlockCartAdd(String menuCode) => _unlockCartWrite(menuCode);

  void _showStorageLimitDialog() {
    final showString = "show_storage_num_error".tr;
    Get.dialog(
      DialogUtils.alertOneButton(
        showString,
        title: "tag_title".tr,
        confirmtitle: "tag_button_yes".tr,
        confirm: () => Get.back(),
      ),
    );
  }

  @override
  void onInit() {

    readyQueryData();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _checkToCloseLoading();
    _ensureCartToastReady();
    // 麻辣烫菜单：页面就绪后抢扫码焦点
    if (isSpicyHotPotMenuScanEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        requestSpicyMenuScanFocus();
      });
    }
  }

  @override
  void onClose() {
    debugPrint('MenuPageController onClose');
    spicyScanQrController.dispose();
    spicyScanQrFocusNode.dispose();
    _cartSoundPlayer?.dispose();
    _cartSoundPlayer = null;
    _deleteSoundPlayer?.dispose();
    _deleteSoundPlayer = null;
    super.onClose();
  }

  AssetsAudioPlayer? _cartSoundPlayer;
  AssetsAudioPlayer? _deleteSoundPlayer;
  bool _cartToastInited = false;

  _checkToCloseLoading() async {
    if (EasyLoading.isShow) {
      logI('--Dismissing EasyLoading--');
      try {
        await EasyLoading.dismiss();
      } catch (e) {
        logger.warning('EasyLoading.dismiss error: $e');
      }
    }
  }

  readyQueryData(){
    if(Get.arguments != null){
      checkLanguage.value = (Get.arguments['checkLanguage']!= null)?Get.arguments['checkLanguage']:"JP";
      final rawTableNo = Get.arguments['tableNo'];
      if (rawTableNo != null) {
        spicyTableNo = rawTableNo.toString().trim();
      }
    }

    MyImageCacheManager.preloadImages();

    getBookingBootIndexCategory();

    //_getMachineInfo();


    getCartPriceTotal();

  }

  //获取页面分类
  getBookingBootIndexCategory({isReset = false, int retryCount = 0}){
    logI('getBookingBootIndexCategory');
    final currentGeneration = ++menuLoadGeneration;
    categoryMenuPrefetchTasks.clear();
    if (isReset) {
      change(null, status: RxStatus.loading());
      topMenu.value = [];
      showItem.clear();
    } else {
      topMenu.value = [];
      showItem.clear();
    }
    var queryTakeout = "2";
    //queryTakeout 0外卖 1都可 2店内
    if (machineInfo.currentMode == MachineMode.takeout) {
      queryTakeout = "0";
    }
    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": checkLanguage.value,
      "takeout":queryTakeout,
    };
    debugPrint('formData:$formData');
    request('webBootIndexCategoryv2',
        method: 'POST',
        parameters: formData,
        timeout: const Duration(seconds: 15)
    ).then((val) {
      var response = json.decode(val.toString());

        //2、保存商品信息
        List myList = response['data']['categoryVoList'] ?? [];
        recommendFoods = response['data']['recommendMenus'] ?? [];
        //如果菜单为空则返回言语选择页面并给出提示
        if (myList.isEmpty ) {
          change(null, status: RxStatus.error('Failed to load data'));
          return;
        }

        List MenuColor = ["#F05F32","#98b9b3","#ABC251","#89A0F0","#E78BC5","#F05F32"];
        var menuIndex = 0;
        var colorIndex = 0;
        topMenu.value = [];
        for (var i = 0; i < myList.length; i++) {
          if(myList[i]["businessType"] != "SPICY_HOT_POT"){
            if(colorIndex >=5) colorIndex = 0;
            var categoryVoList = myList[i];print(categoryVoList);
            //配置顶部菜单
            topMenu.add({
              "categoryCode": categoryVoList['categoryCode'],
              "categoryName": categoryVoList['categoryName'],
              "showType": categoryVoList['showType'],
              "showColor": categoryVoList['color'] ?? MenuColor[colorIndex],
              "background": categoryVoList['background'],
              "index": menuIndex
            });
            menuIndex++;
            colorIndex++;
          }
        }
        if (topMenu.isNotEmpty) {
          classTag.value = topMenu.first['categoryCode'];
          bgColor.value = topMenu.first['background'] ?? "#F9F9F9";
          // 分类接口返回后立即并行预取首分类菜单，缩短首屏等待
          prefetchCategoryMenu(
            topMenu.first['categoryCode'],
            loadGeneration: currentGeneration,
          );
        }
        change(null, status: RxStatus.success());
    })
    .catchError((e){
      logI('getBookingBootIndexCategory error: $e');
      if (retryCount < 2) {
        retryCount++;
        debugPrint('Retrying getBookingBootIndexCategory, attempt: $retryCount');
        getBookingBootIndexCategory(isReset: isReset, retryCount: retryCount);
      } else {
        FirebaseAnalytics.instance.logEvent(name: 'load_menu_category_failure', parameters: {'machineCode': machineInfo.machineCode});
        change(null, status: RxStatus.error('Failed to load data'));
      }
    });
  }

  forceUpdateUI() {
    forceUpdate = true;
    update();
    forceUpdate = false;
  }

  getCartPriceTotal() async {
    await ordersqlcontroller.getCardList();
    _syncCartSummaryToUi();
  }

  /// 点击加购时先乐观更新购物车数字，避免等 SQLite 才有反馈
  void _bumpCartOptimistically(dynamic item) {
    showCartTotalGoodsNum.value = showCartTotalGoodsNum.value + 1;
    final current = int.tryParse(shopCartTotalPrice.value) ?? 0;
    shopCartTotalPrice.value = '${current + _readItemPrice(item)}';
  }

  int _readItemPrice(dynamic item) {
    if (item is Map) {
      return int.tryParse('${item['currentPrice']}') ?? 0;
    }
    if (item is ShopItemModel) {
      return item.unitPrice ?? item.currentPrice ?? 0;
    }
    return 0;
  }

  void _syncCartSummaryToUi() {
    final items = ordersqlcontroller.cartItems;
    var totalNum = 0;
    var totalPrice = 0;
    for (final raw in items) {
      final item = raw as ShopItemModel;
      totalNum += item.goodsNum;
      totalPrice += item.currentPrice ?? 0;
    }
    shopCartTotalPrice.value = '$totalPrice';
    showCartTotalGoodsNum.value = totalNum;
    showCartItems.value = List<ShopItemModel>.from(items.cast<ShopItemModel>());
    if (totalNum == 0) {
      showShopCart = false;
      // 购物车清空后优惠作废
      cartDiscountYen.value = 0;
    }
    // 购物车弹层、推荐页等仍依赖 GetBuilder 刷新
    update(['shopping_cart']);
  }

  /// 购物车商品合计（未减优惠）
  int get cartItemsTotalYen => int.tryParse(shopCartTotalPrice.value) ?? 0;

  /// 应付合计 = 商品合计 − 优惠（不低于 0）
  int get cartPayableYen {
    final p = cartItemsTotalYen - cartDiscountYen.value;
    return p < 0 ? 0 : p;
  }

  String get displayCartPayable => '$cartPayableYen';

  /// 条码前缀是否为优惠活动码（与后端约定：smartwe）
  static const String _discountBarCodePrefix = 'smartwe';

  bool _isDiscountBarCode(String code) =>
      code.length >= _discountBarCodePrefix.length &&
      code.toLowerCase().startsWith(_discountBarCodePrefix);

  /// 优惠扫码：webBootBarCodeMenuQuery，用返回 data.discount 作为减免额
  Future<void> _applyDiscountBarCode(String code) async {
    final formData = {
      'language': checkLanguage.value,
      'machineCode': machineInfo.machineCode,
      'barCode': code,
    };
    logI('菜单优惠扫码查询: $code');
    final val = await request(
      'webBootBarCodeMenuQuery',
      method: 'POST',
      parameters: formData,
    );
    final response = json.decode(val.toString());
    if (response['code'] != 200 || response['data'] == null) {
      showToast('spicy_menu_scan_not_found'.tr);
      logI('优惠扫码未查询到: $code');
      return;
    }

    final data = response['data'];
    if (data is! Map) {
      showToast('spicy_menu_scan_not_found'.tr);
      return;
    }
    final rawDiscount = data['discount'];
    final parsed = rawDiscount is int
        ? rawDiscount
        : int.tryParse('$rawDiscount') ?? 0;
    // 接口返回正数折扣额（如 100）；展示 -100，下单传正数 discount
    final discount = parsed.abs();
    if (discount <= 0) {
      showToast('spicy_menu_scan_not_found'.tr);
      return;
    }
    // 优惠必须小于购物车商品合计，否则不可用
    await getCartPriceTotal();
    final cartTotal = cartItemsTotalYen;
    if (discount >= cartTotal) {
      Get.dialog(
        DialogUtils.alertOneButton(
          'menu_discount_invalid'.tr,
          title: 'tag_title'.tr,
          confirmtitle: 'tag_button_yes'.tr,
          confirm: () => Get.back(),
        ),
      );
      logI('优惠扫码拒绝: discount=$discount >= cartTotal=$cartTotal');
      return;
    }
    cartDiscountYen.value = discount;
    update(['shopping_cart']);
    //showToast('menu_discount_applied'.trParams({'amount': discount.toString()}));
    logI('优惠扫码生效 name=${data['name']} discount=$discount');
  }

  publicChangeCartItemCreate(ShopItemModel d, isAdd) async {
    final rowLockKey = 'cart:${d.id}';
    if (isCartRowLocked(d.id)) {
      return;
    }

    var cartItem = {
      "cartId": d.id,
      "menuCode": d.menuCode,
      "unitPrice": d.unitPrice,
      "goodsNum": 1,
      "qtyBounds": d.qtyBounds
    };
    if (d.goodsNum <= 1 && isAdd == false) {
      Get.dialog(DialogUtils.alert("show_del_cart_item_tag".tr,
          title: "tag_title".tr,
          canceltitle:"show_del_cart_item_no".tr,
          confirmtitle: "show_del_cart_item_yes".tr, confirm: () async {
        await ordersqlcontroller.removeFromCart(d.id ?? 0);
        deleteItemSound();
        await getCartPriceTotal();
        Get.back();
      }, cancle: () {
        Get.back();
      }));
    } else {
      if (!_tryLockCartWrite(rowLockKey)) {
        return;
      }
      final action = isAdd ? "add" : "reduce";
      try {
        if (isAdd) {
          playQRScannerSound();
        } else {
          deleteItemSound();
        }
        await publicChangeCartMenuCount(cartItem, action);
        await getCartPriceTotal();
      } finally {
        _unlockCartWrite(rowLockKey);
      }
    }
  }

  backToNewHome() async {
    //Get.delete<MenuPageController>(); // 手动删除控制器实例
    Get.back();
  }

  //公共设置菜单Title
  publicShowMenuTitle(mainTitle, mainTitleFontSize, mainTitleFontColor) {
    return AutoSizeText(
      mainTitle,
      textAlign: TextAlign.left,
      overflow: TextOverflow.ellipsis, //长度溢出后显示省略号
      maxLines: 2,
      style: TextStyle(
          fontFamily: GFont.getFontFamily(),
          fontSize: ScreenAdapter.fontSize(mainTitleFontSize),
          fontWeight: FontWeight.w600,
          color: ColorsUtil.hexToColor(mainTitleFontColor)),
    );
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
                  text: "${"show_original_price_front".tr}",//¥GString.getToString(this._checkLanguage, "show_price_front"),
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(priceFontSize)/2.2,
                    fontWeight: FontWeight.w500,
                    fontFamily: GFont.getFontFamily(),
                    color: ColorsUtil.hexToColor("#485460"),
                    //decoration: TextDecoration.lineThrough, // 添加中划线
                    //decorationColor: ColorsUtil.hexToColor("#485460"), // 可以设置中划线的颜色
                    //decorationThickness: 2.0, // 可以设置中划线的厚度
                    textBaseline: TextBaseline.alphabetic,
                  ),
                  children: [
                    TextSpan(
                      text: "¥",
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: ScreenAdapter.fontSize(priceFontSize)/2.2,
                        fontWeight: FontWeight.w500,
                        color: ColorsUtil.hexToColor("#485460"),
                        decoration: TextDecoration.lineThrough, // 添加中划线
                        decorationColor: ColorsUtil.hexToColor("#485460"),// 可以设置中划线的颜色
                        decorationThickness: 2.0, // 可以设置中划线的厚度
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                    TextSpan(
                      text: formatMoney(originalPrice.toString()),
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
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
                      text: "",
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
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
                  fontFamily: GFont.getFontFamily(),
                  fontSize: ScreenAdapter.fontSize(priceFrontFontSize),
                  fontWeight: FontWeight.w600,
                  color: ColorsUtil.hexToColor(priceFrontFontColor),
                  textBaseline: TextBaseline.alphabetic,
                ),

                children: [
                  TextSpan(
                    text: formatMoney(currentPrice.toString()),
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(priceFontSize),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor(priceFontColor),
                      textBaseline: TextBaseline.alphabetic,
                    ),
                  ),
                  TextSpan(
                    text: "（${"show_price_front".tr}）",
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
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
            fontFamily: GFont.getFontFamily(),
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

  publicMenuSubtitle(subtitleList) {
    var subtitle = "";
    if (subtitleList != null && subtitleList.length > 0) {
      if (subtitleList != null && subtitleList?.length > 0) {
        for (var i = 0; i < subtitleList.length; i++) {
          subtitle += subtitleList[i];
        }
      }
    }
    return subtitle;
  }

  //公共设置售罄
  publicShowMenuSellOut(bounds) {
    if (bounds == 0) {
      return Positioned(
        left: ScreenAdapter.width(5),
        top: ScreenAdapter.height(8),
        child: Image.asset(
            //"assets/images/public/shouqing${randomNum.value.toString()}.png",
          GImage.getImageString("imgpublic", "shouqing_png_${checkLanguage.value}"),
          width: ScreenAdapter.width(105),
          fit: BoxFit.fitWidth,
        ),
      );

    } else if(bounds > 0){
      var showString = "show_product_restrictions".tr.replaceAll('%%', bounds.toString());
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
                  fontFamily: GFont.getFontFamily(),
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
  /// [checkItem] true=无规格商品合并到同 menuCode 的无 option 行；
  /// false=每次插入新行（有 option 时每次确认各一行）
  publicAddCartMenu(cartItem, checkItem) async {
    if(cartItem['qtyBounds'] >0){
      var checkresult = await ordersqlcontroller.getCartItemNum(cartItem['menuCode']);
      if(checkresult>=cartItem['qtyBounds']){
        var showString = "show_storage_num_error".tr;
        //showToast("${showString}");
        Get.dialog(
            DialogUtils.alertOneButton(showString,
                title: "tag_title".tr,
                confirmtitle: "tag_button_yes".tr,
                confirm: () {
                  Get.back();
                })
        );
        await getCartPriceTotal();
        return false;
      }
    }

    var result = false;
    try {
      await ordersqlcontroller.addToCart(cartItem, checkItem: checkItem);
      await ordersqlcontroller.getCardList();
      _syncCartSummaryToUi();
      result = true;
    } catch (e) {
      print(e);
      result = false;
      await getCartPriceTotal();
    }
    //update();
    return result;
  }

  Future<void> publicAddCart(BuildContext context, item) async {
    final menuCode = '${item['menuCode']}';
    if (!_tryLockCartAdd(menuCode)) {
      return;
    }

    final cartItem = {
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
    final isLimited = (item['qtyBounds'] ?? -1) > 0;

    try {
      // 限购商品等写库成功后再反馈；无限购仍保留乐观更新
      if (!isLimited) {
        _bumpCartOptimistically(item);
        publicShowAddCartNew(context);
      }
      final ok = await publicAddCartMenu(cartItem, true);
      if (isLimited && ok) {
        publicShowAddCartNew(context);
      } else if (!isLimited && !ok) {
        await getCartPriceTotal();
      }
    } finally {
      _unlockCartAdd(menuCode);
    }
  }

  /// 麻辣烫菜单页：重新抢扫码枪焦点
  void requestSpicyMenuScanFocus() {
    if (!isSpicyHotPotMenuScanEnabled) return;
    try {
      spicyScanQrController.clear();
      spicyScanQrFocusNode.requestFocus();
    } catch (e) {
      logI('麻辣烫菜单扫码抢焦点失败: $e');
    }
  }

  void _resetSpicyMenuScan({bool hideLoading = true, bool restoreFocus = true}) {
    spicyScanQrController.clear();
    if (hideLoading && EasyLoading.isShow) {
      try {
        EasyLoading.dismiss();
      } catch (_) {}
    }
    if (restoreFocus) {
      requestSpicyMenuScanFocus();
    }
  }

  /// 扫码请求中的友好 loading（与自助扫码同款动画）
  void _showSpicyScanEasyLoading() {
    final tag = Text(
      'spicy_menu_scan_loading'.tr,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: GFont.getFontFamily(),
        fontSize: ScreenAdapter.fontSize(28),
        fontWeight: FontWeight.w600,
        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
      ),
    );
    EasyLoading.show(
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            tag,
            Container(
              margin: const EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(
                GImage.getImageString('imgpublic', 'printticketloading'),
                fit: BoxFit.fitHeight,
              ),
            ),
          ],
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  /// 麻辣烫选其他菜品：扫码 → 查询/优惠 → 入车或写入减免。
  /// 码前缀 smartwe → webBootBarCodeMenuQuery（优惠）；否则 webBootBarCodeQuery。
  /// 称重商品（HUNDRED_GRAM）拒绝。
  /// [barCode] 可传入（用法弹窗内扫码）；[restoreFocus] 为 false 时由调用方自行抢焦点。
  Future<void> doSpicyMenuBarCodeQuery({
    String? barCode,
    bool restoreFocus = true,
  }) async {
    if (!isSpicyHotPotMenuScanEnabled) return;
    final code = (barCode ?? spicyScanQrController.text).trim();
    if (code.isEmpty) return;
    if (_spicyBarCodeQueryInFlight) return;
    _spicyBarCodeQueryInFlight = true;
    try {
      _showSpicyScanEasyLoading();

      // 优惠活动码：前缀 smartwe
      if (_isDiscountBarCode(code)) {
        await _applyDiscountBarCode(code);
        return;
      }

      final formData = {
        'language': checkLanguage.value,
        'machineCode': machineInfo.machineCode,
        'barCode': code,
      };
      logI('麻辣烫菜单扫码查询: $code');
      final val =
          await request('webBootBarCodeQuery', method: 'POST', parameters: formData);
      final response = json.decode(val.toString());
      if (response['code'] == 200 &&
          response['data'] != null &&
          response['data'] is Map &&
          (response['data'] as Map).isNotEmpty) {
        final item = Map<String, dynamic>.from(response['data'] as Map);
        final priceType = '${item['priceType'] ?? ''}';
        if (priceType == 'HUNDRED_GRAM') {
          showToast('spicy_menu_scan_weigh_reject'.tr);
          return;
        }
        final ctx = Get.context;
        if (ctx != null) {
          await publicAddCart(ctx, item);
        } else {
          final cartItem = {
            'menuCode': item['menuCode'],
            'mainTitle': item['mainTitle'],
            'image': item['homeImage'],
            'currentPrice': item['currentPrice'],
            'unitPrice': item['currentPrice'],
            'optionGroupVoList': '',
            'optionVoListMsg': '',
            'goodsNum': 1,
            'qtyBounds': item['qtyBounds'],
          };
          await publicAddCartMenu(cartItem, true);
        }
      } else {
        showToast('spicy_menu_scan_not_found'.tr);
        logI('麻辣烫菜单扫码未查询到: $code');
      }
    } catch (e, st) {
      logI('麻辣烫菜单扫码异常: $e\n$st');
      showToast('spicy_menu_scan_not_found'.tr);
    } finally {
      _spicyBarCodeQueryInFlight = false;
      _resetSpicyMenuScan(hideLoading: true, restoreFocus: restoreFocus);
    }
  }

  //公共购物车加减（按 cartId 操作单行；限购按 menuCode 汇总校验）
  publicChangeCartMenuCount(cartItem, changeType) async {
    var result;
    try {
      if (changeType == 'add') {
        if (cartItem['qtyBounds'] > 0) {
          var checkresult =
              await ordersqlcontroller.getCartItemNum(cartItem['menuCode']);
          if (checkresult >= cartItem['qtyBounds']) {
            _showStorageLimitDialog();
            return;
          }
          result = await ordersqlcontroller.addToCartNum(cartItem);
        } else if (cartItem['qtyBounds'] < 0) {
          result = await ordersqlcontroller.addToCartNum(cartItem);
        }
      } else {
        result = await ordersqlcontroller.reduceToCart(cartItem);
      }

      await ordersqlcontroller.getCardList();
    } catch (e) {
      print(e);
      result = 0;
    }
    return result;
  }

  //公共展示加入购物车动画
  publicShowAddCartNew(BuildContext context) {
    _ensureCartToastReady(context);

    final toast = Container(
      color: Colors.transparent,
      child: Image.asset(
        GImage.getImageString("imgpublic", "checked_green"),
        width: ScreenAdapter.width(150),
        height: ScreenAdapter.height(150),
      ),
    );

    fToast?.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: const Duration(milliseconds: 500),
    );
    playQRScannerSound();
  }

  void _ensureCartToastReady([BuildContext? context]) {
    final toastContext = context ?? Get.context;
    if (toastContext == null) {
      return;
    }
    fToast ??= FToast();
    if (!_cartToastInited) {
      fToast!.init(toastContext);
      _cartToastInited = true;
    }
  }

  playQRScannerSound() {
    _cartSoundPlayer ??= AssetsAudioPlayer.newPlayer();
    _cartSoundPlayer!.open(
      Audio("assets/audios/14428.wav"),
      autoStart: true,
      volume: 0.3,
    );
  }

  deleteItemSound() {
    _deleteSoundPlayer ??= AssetsAudioPlayer.newPlayer();
    _deleteSoundPlayer!.open(
      Audio("assets/audios/697.wav"),
      autoStart: true,
      volume: 0.8,
    );
  }
  changeOptionv1(menuCode, groupCode, optionCode, setMenuState) {
    //playQRScannerSound();

    var attr = menuOption.value[menuCode];
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
            var showTag = "menu_option_more_multipleState".tr;
            //showToast("${showTag.replaceAll("%%", attr[i]["multipleState"])}");
            Get.dialog(
                DialogUtils.alertOneButton("${showTag.replaceAll("%%", attr[i]["multipleState"])}",
                    title: "tag_title".tr,
                    confirmtitle: "tag_button_yes".tr,
                    confirm: () {
                      Get.back();
                    })
            );
            break;
          }

          /*if(current_incloud_option_checked < int.parse(attr[i]["smallest"])){
            showToast("该组选项不能小于${attr[i]["smallest"]}个");
            break;
          }*/

        }
        for (var j = 0; j < attr[i]['optionVoList'].length; j++) {
          if(attr[i]["multipleState"] == "1"){
            //attr[i]['optionVoList'][j]["checked"] = false;
            if (attr[i]['optionVoList'][j]["optionCode"] != optionCode) {
              attr[i]['optionVoList'][j]["checked"] = false;
            }else if (attr[i]['optionVoList'][j]["optionCode"] == optionCode) {
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
    menuOption[menuCode] = attr;


    _getSelectedAttrValuev1(menuCode, attr, setMenuState);
    update(['option_view']);
  }

  //获取选中的值
  _getSelectedAttrValuev1(menuCode, optionGroupList, setMenuState) {
    var _list = optionGroupList;
    List tempArr = [];
    num selectPrice = 0;
    for (var i = 0; i < _list.length; i++) {
      for (var j = 0; j < _list[i]['optionVoList'].length; j++) {
        if (_list[i]['optionVoList'][j]['checked'] == true) {
          var selectMapItem = {
            "group": _list[i]["groupCode"],
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

    selectedMenuOptionList[menuCode] = tempArr;
    addselectedMenuOptionChangePrice[menuCode] = selectPrice;
    tempArr = [];
    update(['option_view']);
  }

//限量商品请求接口
  checkQtyBoundsCount(item, optionCode, popupType, context) async {
    if (!canAddCart.value) {
      return;
    }

    final menuCode = '${item['menuCode']}';
    if (item['qtyBounds'] == 0) {
      return;
    }
    if (_cartAddInFlight.contains(menuCode)) {
      return;
    }

    final hasOptions = item['optionGroupVoList']?.length > 0;
    final isLimited = item['qtyBounds'] > 0;

    // 限购：先同步校验库存，再弹规格或写库
    if (isLimited) {
      final count = await ordersqlcontroller.getCartItemNum(menuCode);
      if (count >= item['qtyBounds']) {
        _showStorageLimitDialog();
        return;
      }
    }

    if (hasOptions) {
      _showOptionDialog(item, popupType: popupType);
      return;
    }

    await publicAddCart(context, item);
  }

  void _showOptionDialog(item, {required String popupType}) {
    final menuCode = '${item['menuCode']}';
    if (_openOptionMenuCode != null) {
      return;
    }
    _openOptionMenuCode = menuCode;

    final optionInfo =
        List<dynamic>.from(item['optionGroupVoList'] ?? const []);
    final prepared = OptionView.prepareState(
      itemPrice: item['currentPrice'] ?? 0,
      optionInfo: optionInfo,
    );

    Get.generalDialog(
      pageBuilder: (_, __, ___) => OptionView(
        isLabel: popupType != "v1",
        languageKey: checkLanguage.value,
        itemPrice: item['currentPrice'],
        originalPrice: item['price'],
        optionInfo: optionInfo,
        mainTitle: item['mainTitle'],
        subtitle: item['subtitle'] ?? [],
        preparedState: prepared,
        addToCartCallback: (price, options, optionTitle) {
          _addToCartCallback(item, price, options, optionTitle);
        },
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: Duration.zero,
      transitionBuilder: (_, __, ___, child) => child,
    ).whenComplete(() {
      if (_openOptionMenuCode == menuCode) {
        _openOptionMenuCode = null;
      }
    });
  }

  //展示某带option商品
  publicShowOneItemWidget(item) {
    _showOptionDialog(item, popupType: "old");
  }

  publicShowOneItemWidgetv1(item) {
    _showOptionDialog(item, popupType: "v1");
  }

  /// 带规格加购（featured/内联/弹窗）：每次插入新行，写库锁 + 限购预检
  Future<bool> publicAddCartWithOptions(
    Map cartItem,
    BuildContext context, {
    String? resetOptionMenuCode,
  }) async {
    final menuCode = '${cartItem['menuCode']}';
    if (!_tryLockCartAdd(menuCode)) {
      return false;
    }

    try {
      final qtyBounds = cartItem['qtyBounds'] ?? -1;
      if (qtyBounds > 0) {
        final count = await ordersqlcontroller.getCartItemNum(menuCode);
        if (count >= qtyBounds) {
          _showStorageLimitDialog();
          return false;
        }
      }

      final ok = await publicAddCartMenu(cartItem, false);
      if (ok) {
        publicShowAddCartNew(context);
        if (resetOptionMenuCode != null) {
          changeInitialAllOption(resetOptionMenuCode);
        }
      }
      return ok;
    } finally {
      _unlockCartAdd(menuCode);
    }
  }

  Future<void> _addToCartCallback(item, price, options, optionTitle) async {
    //options 是一个字符串数组，把它转换成字符串逗号分隔
    final optionsString = options.map((e) => e.toString()).toList().join(',');

    final cartItem = {
      "menuCode": item['menuCode'],
      "mainTitle": item['mainTitle'],
      "image": item['homeImage'],
      "currentPrice": price,
      "unitPrice": price,
      "optionGroupVoList": optionsString,
      "optionVoListMsg": optionTitle,
      "goodsNum": 1,
      "qtyBounds": item['qtyBounds']
    };

    Get.back();
    final context = Get.context;
    if (context != null) {
      await publicAddCartWithOptions(cartItem, context);
    }
  }

  //初始化默认option选项
  changeInitialAllOption(menuCode) {
    var attr = menuOption[menuCode];
    var initMenuOption = noChangeinitialmenuOption[menuCode];
    num _addOptionPrice = 0;

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

    menuOption[menuCode] = attr;
    selectedMenuOptionList[menuCode] = initialMenuOption[menuCode];
    addselectedMenuOptionChangePrice[menuCode] = _addOptionPrice;
  }

  //获取选中的值
  getSelectedAttrValue(menuCode, optionGroupList, setMenuState) {

    var _list = optionGroupList;
    List tempArr = [];
    num selectPrice = 0;
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

    selectedMenuOptionList[menuCode] = tempArr;
    addselectedMenuOptionChangePrice[menuCode] = selectPrice;
    tempArr = [];
  }


  _showOrderEasyLoading(){
    var _showTag =Text("settlement_noprint_tag".tr,
        style: TextStyle(
          fontFamily: GFont.getFontFamily(),
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

  //购物车
  getItemTotal(List items) {
    num sum = 0;
    items.forEach((e) {
      sum += e.currentPrice;
    });

    return sum.toString();
  }

  //提交订单
  Future<void> doSubmitOrder({int times = 0}) async {
    if (machineInfo.machineCode == "") {
      FirebaseAnalytics.instance.logEvent(
        name: "submit_order_error",
        parameters: {"machineCode": machineInfo.machineCode},
      );
      return;
    }
    if (_submitInFlight) {
      return;
    }
    if (showCartTotalGoodsNum.value <= 0) {
      return;
    }

    _submitInFlight = true;
    canAddCart.value = false;

    try {
      _showOrderEasyLoading();
      playQRScannerSound();

      // 提交前刷新 DB，保证 orderLineList 与 total 一致
      await ordersqlcontroller.getCardList();

      final rawCartItems = ordersqlcontroller.getcartItems;
      if (rawCartItems.isEmpty) {
        await EasyLoading.dismiss();
        return;
      }

      final selectedItem = <Map<String, dynamic>>[];
      for (var oneItem in rawCartItems) {
        final Map<String, dynamic> optionMap;
        // 称重商品用 spicyGrams（克数）作为 qty；口味商品和普通商品用 goodsNum（=1）
        final grams = oneItem["spicyGrams"] ?? 0;
        final qty = grams > 0 ? grams : oneItem["goodsNum"];
        if (oneItem["optionGroupVoList"] == "") {
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "qty": qty,
          };
        } else {
          var optionGroupVoList = oneItem["optionGroupVoList"];
          var itemsOption = optionGroupVoList.split(',');
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "optionList": itemsOption,
            "qty": qty,
          };
        }
        selectedItem.add(optionMap);
      }
      var orderTotlaPrice = getItemTotal(ordersqlcontroller.cartItems);
      var formData = <String, dynamic>{
        "language": checkLanguage.value,
        "machineCode": machineInfo.machineCode,
        "orderLineList": selectedItem,
        "total": orderTotlaPrice,
        "takeout": machineInfo.isTakeoutMode,
      };
      // 仅麻辣烫且已扫盆号时带 tableNo；普通券卖/未开扫码不传该参数
      if (machineInfo.currentMode == MachineMode.spicyHotPot &&
          spicyTableNo.isNotEmpty) {
        formData['tableNo'] = spicyTableNo;
      }
      // 扫码优惠（smartwe 前缀）：有减免才传 discount
      if (cartDiscountYen.value > 0) {
        formData['discount'] = cartDiscountYen.value;
      }
      LogUtil.d("webBootOrderformData: $formData");

      final val = await request(
        'webBootOrder',
        method: 'POST',
        parameters: formData,
        timeout: const Duration(seconds: 15),
      );

      await EasyLoading.dismiss();
      var response = json.decode(val.toString());
      debugPrint("webBootOrder response: $response");

      if (response['code'] == 200 && response != null) {
        doSubmitOrderId.value = response['data']["orderId"];
        int serverTotal = (response['data']["total"] as num?)?.toInt() ?? 0;
        int tax1 = response['data']["tax1"] ?? 0;
        int tax2 = response['data']["tax2"] ?? 0;

        // 本地兜底：税込=含税应付；税别=未税价（需再加税）
        int localTotal = cartDiscountYen.value > 0
            ? cartPayableYen
            : (int.tryParse(orderTotlaPrice.toString()) ?? 0);

        // 税入/税别统一优先用下单返回 data.total（服务端已含税与优惠）
        int displayTotalYen;
        if (serverTotal > 0) {
          displayTotalYen = serverTotal;
        } else if (!machineInfo.taxSystem && localTotal > 0) {
          displayTotalYen = localTotal + tax1 + tax2;
        } else {
          displayTotalYen = localTotal;
        }

        final displayTotal = displayTotalYen.toString();

        showSelectMealTypeAndPaymentMethodDialog(displayTotal,
            tax1: tax1, tax2: tax2);
      } else {
        FirebaseAnalytics.instance.logEvent(
          name: "submit_order_fail",
          parameters: {"machineCode": machineInfo.machineCode},
        );
        if (response != null &&
            response['data'] != null &&
            response['data']["menuLackMap"] != null) {
          menuLackMap.value = response['data']["menuLackMap"];
        }
        Get.dialog(
          DialogUtils.alertOneButton(
            response['data']["message"],
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () => Get.back(),
          ),
        );
      }
    } catch (e) {
      _handleOrderResultAlert(times: times);
    } finally {
      _submitInFlight = false;
      if (!paymentIsShow) {
        canAddCart.value = true;
      }
    }
  }

  _handleOrderResultAlert({int times= 0}) {
    EasyLoading.dismiss();
    if (times > 2) {
      Get.dialog(
          DialogUtils.alertOneButton(
              "order_network_error".tr,
              title: "tag_title".tr,
              confirmtitle: "tag_button_yes".tr,
              confirm: () {
                Get.back();
                FirebaseAnalytics.instance.logEvent(name: "submit_order_error",parameters: {
                  "machineCode": machineInfo.machineCode,
                });
              })
      );
      return;
    }

    Get.dialog(
        DialogUtils.alert(
            "show_order_error".tr,
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
            confirm: () {
              Get.back();
              doSubmitOrder(times: times + 1);
            },
            cancle: () {
              Get.back();
              //clearCartList();
              FirebaseAnalytics.instance.logEvent(name: "submit_order_error",parameters: {
                "machineCode": machineInfo.machineCode,
              });
            }
            )
    );
  }

  //选择食用方式和支付方式
  showSelectMealTypeAndPaymentMethodDialog(String total,
      {int tax1 = 0, int tax2 = 0}) async {
    paymentIsShow = true;
    machineInfo.showReceiptPage = machineInfo.isReceiptPageShow;
    Get.to(
          () => SelectPaymentPage(
          checkLanguage: checkLanguage.value,
          menuCount: showCartTotalGoodsNum.value,
          tax10: tax1,
          tax8: tax2,

          shopCartTotalPrice: total,
          tableNum: "",
          onConfrimClick: () {
              showOpenPayment.value = true;
              gotoSettlement(total, tax1 + tax2);

          },
          onCancelClick: (String isBack) async {
            debugPrint('onCancelClick');
            paymentIsShow = false;
            canAddCart.value = true;
            if (isBack == "back") {
              CancelOrder();
            }
          }),
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      opaque: false,
    );
  }

  postNewOrderId() {

    var formData = {
      "orderId": doSubmitOrderId.value,
      "machineCode": machineInfo.machineCode,
    };
    request('webBootToPayConfirm', method: 'POST', parameters: formData).then((val) {
      var response = json.decode(val.toString());
      //EasyLoading.dismiss();

      if (response['code'] == 200 && response['data'] !=null && response['data']['orderId'] !=null) {

        doSubmitOrderId.value = response['data']["orderId"];

          //gotoSettlement();

      }else{

        //showToast(response['data']["message"]);
        Get.dialog(
            DialogUtils.alertOneButton(response['data']["message"],
                title: "tag_title".tr,
                confirmtitle: "tag_button_yes".tr,
                confirm: () {
                  Get.back();
                })
        );

      }
    });


  }


  resetToFirstPage() async {
    await getBookingBootIndexCategory(isReset: true);
    debugPrint('getBookingBootIndexCategory done');
    await getCartPriceTotal();
  }



  gotoSettlement(String total, int tax) async {
    logI("gotoSettlement tax:$tax");
    // 麻辣烫+现金机：结算跳转前提前释放电子秤 USB，
    // 让 Android 有足够时间回收句柄再打开 FTDI 现金机
    if (isSpicyHotPotMenuScanEnabled &&
        (machineInfo.paymentMethod == "0" || machineInfo.paymentMethod == "1")) {
      ScaleSerialService.releaseUsbSafely(reason: 'goto_settlement');
    }
    Get.toNamed('/settlement',preventDuplicates: false,
        arguments: {
          "checkLanguage":  checkLanguage.value,
          "orderId" : doSubmitOrderId.value,
          "totalPrice" : total,
          "machineMode":"1",
          "showOpenPayment": showOpenPayment.value
        });
  }

  CancelOrder() {
    var formData = {
      "machineCode": machineInfo.machineCode,
      "orderId": doSubmitOrderId.value,
      "model": "0",
    };
    request('webBootCancelV1', method: 'POST', parameters: formData);

  }

  clearOrderList() async {
    await ordersqlcontroller.removeAllFromCart();
    if (paymentIsShow) {
      Get.back();
      paymentIsShow = false;
    }
    if (Get.isDialogOpen == true) {
      debugPrint('---close dialog---');
      Get.back();
    }
    getCartPriceTotal();
  }

  clearCartList() async {
    logI("clearCartList");
    await ordersqlcontroller.removeAllFromCart();
    await ordersqlcontroller.getCardList();
    //classTag.value = topMenu[0]["categoryCode"];
    menuLackMap.value = {};
    cartDiscountYen.value = 0;
    await getCartPriceTotal();

    if (topMenu.isNotEmpty) {
      selectIndex = 0;
      classTag.value = topMenu[0]["categoryCode"];
      bgColor.value = topMenu[0]["background"] ?? "#F9F9F9";

      if (pageController.hasClients) {
        pageController.jumpToPage(0);
      }

      update(['side_bar']);
      update(['background']);
    }
  }

  gotoLanguageHome(){
    //clearCartList();
    ordersqlcontroller.removeAllFromCart();
    ordersqlcontroller.getCardList();
    // 麻辣烫模式返回首页时重置 currentMode，避免遗留脏状态
    if (machineInfo.currentMode == MachineMode.spicyHotPot) {
      machineInfo.currentMode = MachineMode.sell;
    }
    Get.back();
  }


}
