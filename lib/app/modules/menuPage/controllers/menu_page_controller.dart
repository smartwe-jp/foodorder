import 'dart:convert';
import 'dart:io';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
//import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodorder/app/config/localString.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/models/ItemModel.dart';
import 'package:foodorder/app/modules/edit_page/widgets/menu_side_bar.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_extension.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/car_item_view.dart';
import 'package:foodorder/app/services/CustomLogerHandler.dart';

import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/fontSize.dart';
import '../../../config/imageData.dart';
import '../../../controllers/ImageCacheManager.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../services/HttpService.dart';
import '../../../services/scale_serial_service.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/spicy_weigh_settings.dart';
import '../../../services/formatMoney.dart';
import '../../../widget/DialogUtils.dart';
import '../../CheckoutPage/controllers/checkout_page_controller.dart';
import '../views/SelectPayment.dart';
import '../views/option_widgets/option_view.dart';

class MenuPageController extends GetxController with StateMixin {
  //TODO: Implement MenuPageController
  OrderSqlController ordersqlcontroller = Get.find<OrderSqlController>();
  MachineInfoController machineInfo = Get.find();
  FToast? fToast;
  final customCacheManager = CacheManager(
    Config(
      'menu_page', // 限制缓存对象数量
      stalePeriod: Duration(minutes: 1), // 缓存过期时间
      maxNrOfCacheObjects: 100, // 缓存对象数量
    ),
  );

  //默认语言包选择
  RxString checkLanguage = "JP".obs;
  String spicyTableNo = '';
  final RxInt cartDiscountYen = 0.obs;
  final RxInt spicyFloorDiscountYen = 0.obs;

  RxString classTag = "".obs;
  RxList topMenu = [].obs;
  RxList showCartItems = [].obs;
  RxMap showItem = {}.obs;

  RxMap menuOption = {}.obs; //牛肉面及定食的option数组
  RxMap noChangeinitialmenuOption = {}.obs; //牛肉面及定食的option数组，不做改变
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
  RxBool showShopCart = false.obs;

  RxBool canAddCart = true.obs;

  List recommendFoods = [];
  List recommendBookList = [];
  bool showRecommend = false;
  bool showCartView = false;
  String shopCode = '';
  final logger = Logger('MenuPageController');

  AudioPlayer? player;

  bool paymentIsShow = false;
  bool returnFromeCancelOrder = false;

  //for page controller
  bool isChangingPage = false;
  int selectIndex = 0;
  MenuSidebarInfo? sidebarInfo;
  late List menuList;
  late List<String> menuCategory;

  String background = Gcolor.whiteColor;
  final PageController pageController = PageController(viewportFraction: 1.0);
  bool forceUpdate = false;

  RxString bgColor = "#F9F9F9".obs;

  /// 分类菜单网络请求去重（仅内存，不落盘）
  final Map<String, Future<bool>> categoryMenuPrefetchTasks = {};

  /// 每次重新拉分类时递增，忽略刷新前返回的旧菜单响应
  int menuLoadGeneration = 0;

  /// 正在写库的 key（menuCode 或 cart:行 id），防止限购连点超卖
  final Set<String> _cartAddInFlight = {};

  /// 当前已打开的规格弹窗对应商品，防止重复弹窗
  String? _openOptionMenuCode;

  /// 下单请求进行中，防止重复提交
  bool _submitInFlight = false;

  final TextEditingController spicyScanQrController = TextEditingController();
  final FocusNode spicyScanQrFocusNode = FocusNode(debugLabel: 'SpicyMenuBarCode');
  bool _spicyBarCodeQueryInFlight = false;

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
  Future<void> onInit() async {
    print("---MenuPageController onInit");
    await readyQueryData();
    player = AudioPlayer();
    super.onInit();
  }

  @override
  void onReady() {
    print("---MenuPageController onReady");
    super.onReady();
    if (isSpicyHotPotMenuScanEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        requestSpicyMenuScanFocus();
      });
    }
  }

  //获取菜单
  Future<void> onClose() async {
    debugPrint('MenuPageController onClose');
    spicyScanQrController.dispose();
    spicyScanQrFocusNode.dispose();
    //player?.dispose();
    await customCacheManager.emptyCache();
    //await Get.delete<MenuPageController>();
    super.onClose();
  }

  readyQueryData() {
    if (Get.arguments != null) {
      checkLanguage.value = (Get.arguments['checkLanguage'] != null)
          ? Get.arguments['checkLanguage']
          : "JP";
      spicyTableNo = Get.arguments['tableNo']?.toString().trim() ?? '';
    }

    MyImageCacheManager.preloadImages();

    getBookingBootIndexCategory();

    //_getMachineInfo();

    getCartPriceTotal();
  }

  // _getHomeImageList() async {
  //   debugPrint("获取首页图片");
  //   var homeimageList = await HomeServices.getSmartweHomeImagesData();
  //   homeImages.value = homeimageList;
  // }

  changeBackgroundColor(String color) {
    debugPrint("changeBackgroundColor: $color");
    background = color;
    update();
  }

  //获取页面分类
  getBookingBootIndexCategory({isReset = false, int retryCount = 0}) {
    debugPrint('getBookingBootIndexCategory');
    final currentGeneration = ++menuLoadGeneration;
    categoryMenuPrefetchTasks.clear();
    if (isReset) {
      change(null, status: RxStatus.loading());
    }
    topMenu.value = [];
    showItem.clear();
    var queryTakeout = "2";
    if (machineInfo.currentMode == MachineMode.takeout) {
      queryTakeout = "0";
    }
    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": checkLanguage.value,
      "takeout": queryTakeout,
    };
    debugPrint('formData:$formData');
    request('webBootIndexCategoryv2',
        method: 'POST',
        parameters: formData,
        timeout: const Duration(seconds: 15)
    ).then((val) {
      if (currentGeneration != menuLoadGeneration) {
        logI('ignore stale category response: generation=$currentGeneration');
        return;
      }
      var response = json.decode(val.toString());

        //2、保存商品信息
        List myList = response['data']['categoryVoList'] ?? [];
        recommendFoods = response['data']['recommendMenus'] ?? [];
        //如果菜单为空则返回言语选择页面并给出提示
        if (myList.isEmpty ) {
          change(null, status: RxStatus.error('Failed to load data'));
          return;
        }

        List MenuColor = [
          "#F05F32",
          "#98b9b3",
          "#ABC251",
          "#89A0F0",
          "#E78BC5",
          "#F05F32"
        ];
        var menuIndex = 0;
        var colorIndex = 0;
        topMenu.value = [];
        for (var i = 0; i < myList.length; i++) {
          if (myList[i]['businessType'] == 'SPICY_HOT_POT') {
            continue;
          }
          if (colorIndex >= 5) colorIndex = 0;
          var categoryVoList = myList[i];
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
        if (topMenu.isNotEmpty) {
          classTag.value = topMenu.first['categoryCode'];
          bgColor.value = topMenu.first['background'] ?? "#F9F9F9";
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
        debugPrint(
            'Retrying getBookingBootIndexCategory, attempt: $retryCount');
        getBookingBootIndexCategory(isReset: isReset, retryCount: retryCount);
      } else {
        // FirebaseAnalytics.instance.logEvent(
        //     name: 'load_menu_category_failure',
        //     parameters: {'machineCode': machineInfo.machineCode});
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
    debugPrint('getCartPriceTotal');
    try {
      //获取购物车数据
      await ordersqlcontroller.getCardList();
      var total = await ordersqlcontroller.getCartAllPrice();
      if (total != null) {
        shopCartTotalPrice.value =
            total["totalPrice"] == null ? "0" : total["totalPrice"].toString();
      }
      logger.info('-- Cart Total Price: ${shopCartTotalPrice.value} --');

      var totalNum = await ordersqlcontroller.getCartTotalNum();
      showCartTotalGoodsNum.value = totalNum;
      logger.info('-- Cart Total Items: $totalNum --');

      if (showCartTotalGoodsNum.value == 0) {
        showShopCart.value = false;
      }

      showCartItems.value = ordersqlcontroller.cartItems;
      await _refreshSpicyFloorDiscount();
      update(['shopping_cart', 'shoppingCar']);
    } catch (e) {
      print(e);
      logger.info('-- getCartPriceTotal error: $e --');
    }
  }

  int get cartItemsTotalYen => int.tryParse(shopCartTotalPrice.value) ?? 0;
  int get totalCartDiscountYen =>
      spicyFloorDiscountYen.value + cartDiscountYen.value;
  int get cartPayableYen {
    final payable = cartItemsTotalYen - totalCartDiscountYen;
    return payable < 0 ? 0 : payable;
  }
  String get displayCartPayable => '$cartPayableYen';

  Future<void> _refreshSpicyFloorDiscount() async {
    if (!isSpicyHotPotMenuScanEnabled ||
        !await SpicyWeighSettings.loadFloorToTensEnabled()) {
      spicyFloorDiscountYen.value = 0;
      return;
    }
    var discount = 0;
    for (final raw in ordersqlcontroller.cartItems) {
      final item = raw as ShopItemModel;
      if (item.itemType == 'spicy' && item.spicyGrams > 0) {
        discount += (item.currentPrice ?? 0) % 10;
      }
    }
    spicyFloorDiscountYen.value = discount;
  }

  bool _isDiscountBarCode(String code) =>
      code.toLowerCase().startsWith('smartwe');

  Future<void> _applyDiscountBarCode(String code) async {
    final val = await request('webBootBarCodeMenuQuery', method: 'POST', parameters: {
      'language': checkLanguage.value,
      'machineCode': machineInfo.machineCode,
      'barCode': code,
    });
    final response = json.decode(val.toString());
    final data = response['data'];
    final raw = data is Map ? data['discount'] : null;
    final discount = (raw is int ? raw : int.tryParse('$raw') ?? 0).abs();
    await getCartPriceTotal();
    if (response['code'] != 200 || discount <= 0 ||
        discount + spicyFloorDiscountYen.value >= cartItemsTotalYen) {
      Fluttertoast.showToast(msg: 'menu_discount_invalid'.tr);
      return;
    }
    cartDiscountYen.value = discount;
    update(['shopping_cart', 'shoppingCar']);
  }

  void requestSpicyMenuScanFocus() {
    if (!isSpicyHotPotMenuScanEnabled) return;
    try {
      spicyScanQrController.clear();
      spicyScanQrFocusNode.requestFocus();
    } catch (error) {
      logI('麻辣烫菜单扫码抢焦点失败: $error');
    }
  }

  void _resetSpicyMenuScan({bool restoreFocus = true}) {
    spicyScanQrController.clear();
    if (EasyLoading.isShow) {
      EasyLoading.dismiss();
    }
    if (restoreFocus) requestSpicyMenuScanFocus();
  }

  void _showSpicyScanEasyLoading() {
    EasyLoading.show(
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'spicy_menu_scan_loading'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(28),
                fontWeight: FontWeight.w600,
                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
              ),
            ),
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

  Future<void> doSpicyMenuBarCodeQuery({
    String? barCode,
    bool restoreFocus = true,
  }) async {
    if (!isSpicyHotPotMenuScanEnabled || _spicyBarCodeQueryInFlight) return;
    final code = (barCode ?? spicyScanQrController.text).trim();
    if (code.isEmpty) return;
    _spicyBarCodeQueryInFlight = true;
    try {
      _showSpicyScanEasyLoading();
      if (_isDiscountBarCode(code)) {
        await _applyDiscountBarCode(code);
        return;
      }
      final val = await request('webBootBarCodeQuery', method: 'POST', parameters: {
        'language': checkLanguage.value,
        'machineCode': machineInfo.machineCode,
        'barCode': code,
      });
      final response = json.decode(val.toString());
      final data = response['data'];
      if (response['code'] != 200 || data is! Map || data.isEmpty) {
        Fluttertoast.showToast(msg: 'spicy_menu_scan_not_found'.tr);
        return;
      }
      final item = Map<String, dynamic>.from(data);
      if ('${item['priceType']}' == 'HUNDRED_GRAM') {
        Fluttertoast.showToast(msg: 'spicy_menu_scan_weigh_reject'.tr);
        return;
      }

      final context = Get.context;
      if (context != null) {
        await publicAddCart(context, item);
      } else {
        final menuCode = '${item['menuCode']}';
        if (!_tryLockCartAdd(menuCode)) return;
        try {
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
        } finally {
          _unlockCartAdd(menuCode);
        }
      }
    } catch (error, stackTrace) {
      logger.warning(
        'spicy menu barcode query failed',
        error,
        stackTrace,
      );
      Fluttertoast.showToast(msg: 'spicy_menu_scan_not_found'.tr);
    } finally {
      _spicyBarCodeQueryInFlight = false;
      _resetSpicyMenuScan(restoreFocus: restoreFocus);
    }
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
          canceltitle: "show_del_cart_item_no".tr,
          confirmtitle: "show_del_cart_item_yes".tr, confirm: () async {
        if (!_tryLockCartWrite(rowLockKey)) return;
        try {
          await ordersqlcontroller.removeFromCart(d.id ?? 0);
          deleteItemSound();
          await ordersqlcontroller.getCardList();
          await getCartPriceTotal();
          Get.back();
        } finally {
          _unlockCartWrite(rowLockKey);
        }
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

  // backToNewHome() async {
  //   Get.delete<MenuPageController>(); // 手动删除控制器实例
  //
  //   Get.delete<OrderSqlController>(); // 手动删除控制器实例
  //
  //   //Get.toNamed("/order-home");
  //   Get.offNamedUntil('/transit-page', (route) => route.isFirst);
  // }
  backToNewHome() async {
    //Get.delete<MenuPageController>(); // 手动删除控制器实例
    if (!_isCurrentMenuRoute) return;
    Get.back();
  }

  bool get _isCurrentMenuRoute {
    return Get.currentRoute == Routes.MENU_PAGE;
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
  publicShowMenuPrice(
      currentPrice,
      originalPrice,
      priceFrontFontSize,
      priceFrontFontColor,
      priceFontSize,
      priceFontColor,
      priceBackFontSize,
      priceBackFontColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (originalPrice != null &&
            originalPrice != "" &&
            originalPrice != currentPrice)
          Container(
            padding: EdgeInsets.only(bottom: ScreenAdapter.height(3)),
            //color: Colors.red,
            child: RichText(
              text: TextSpan(
                  text:
                      "${"show_original_price_front".tr}", //¥GString.getToString(this._checkLanguage, "show_price_front"),
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(priceFontSize) / 2.2,
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
                        fontSize: ScreenAdapter.fontSize(priceFontSize) / 2.2,
                        fontWeight: FontWeight.w500,
                        color: ColorsUtil.hexToColor("#485460"),
                        decoration: TextDecoration.lineThrough, // 添加中划线
                        decorationColor:
                            ColorsUtil.hexToColor("#485460"), // 可以设置中划线的颜色
                        decorationThickness: 2.0, // 可以设置中划线的厚度
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                    TextSpan(
                      text: formatMoney(originalPrice.toString()),
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: ScreenAdapter.fontSize(priceFontSize) / 1.8,
                        fontWeight: FontWeight.w500,
                        color: ColorsUtil.hexToColor("#485460"),
                        decoration: TextDecoration.lineThrough, // 添加中划线
                        decorationColor:
                            ColorsUtil.hexToColor("#485460"), // 可以设置中划线的颜色
                        decorationThickness: 2.0, // 可以设置中划线的厚度
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                    TextSpan(
                      text: "",
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: ScreenAdapter.fontSize(priceFontSize) / 2.2,
                        fontWeight: FontWeight.w500,
                        color: ColorsUtil.hexToColor("#485460"),
                        decoration: TextDecoration.lineThrough, // 添加中划线
                        decorationColor:
                            ColorsUtil.hexToColor("#485460"), // 可以设置中划线的颜色
                        decorationThickness: 2.0, // 可以设置中划线的厚度
                        textBaseline: TextBaseline.alphabetic,
                      ),
                    ),
                  ]),
            ),
          ),
        SizedBox(
          width: ScreenAdapter.width(15),
        ),
        Container(
          //color: Colors.blueGrey,
          alignment: Alignment.bottomRight,
          child: RichText(
            text: TextSpan(
                text:
                    "¥", //¥GString.getToString(this._checkLanguage, "show_price_front"),
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
                      fontSize: ScreenAdapter.fontSize(priceFontSize) / 2.5,
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

  //公共设置标签 subTitle
  publicShowMenuSubtitle(subtitleList) {
    //标签循环相关
    if (subtitleList != null && subtitleList.length > 0) {
      var subtitle = "";
      if (subtitleList != null && subtitleList?.length > 0) {
        for (var i = 0; i < subtitleList.length; i++) {
          subtitle += subtitleList[i];
        }
      }
      return Container(
        padding: EdgeInsets.only(
            left: ScreenAdapter.width(5),
            top: ScreenAdapter.height(5),
            right: ScreenAdapter.width(5),
            bottom: ScreenAdapter.height(5)),
        child: Text(
          subtitle,
          style: TextStyle(
              fontFamily: GFont.getFontFamily(),
              fontSize: ScreenAdapter.fontSize(GFontSize.menuTwoTitleTag),
              color: ColorsUtil.hexToColor("#000000")),
          //maxLines: 2,
          //overflow: TextOverflow.ellipsis,
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
        left: ScreenAdapter.width(5),
        top: ScreenAdapter.height(8),
        child: Image.asset(
          //"assets/images/public/shouqing${randomNum.value.toString()}.png",
          GImage.getImageString(
              "imgpublic", "shouqing_png_${checkLanguage.value}"),
          width: ScreenAdapter.width(105),
          fit: BoxFit.fitWidth,
        ),
      );
    } else if (bounds > 0) {
      var showString =
          "show_product_restrictions".tr.replaceAll('%%', bounds.toString());
      return Positioned(
        right: ScreenAdapter.width(10),
        top: ScreenAdapter.height(10),
        child: Container(
          //width: ScreenAdapter.width(230),
          height: ScreenAdapter.height(55),
          padding: EdgeInsets.only(
              left: ScreenAdapter.width(5),
              top: ScreenAdapter.height(5),
              right: ScreenAdapter.width(5),
              bottom: ScreenAdapter.height(5)),
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
            child: Text("${showString}",
                style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(24),
                    color: ColorsUtil.hexToColor("#FFFFFF"))),
          ),
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  publicCartView() {
    return Obx(() {
      final discount = totalCartDiscountYen;
      return ListView(
        shrinkWrap: true,
        children: [
          for (final d in showCartItems)
            CarItemView(
                key: ValueKey(d.id),
                title: d.mainTitle,
                subtitle: d.optionVoListMsg,
                image: itemImage(d.image),
                onReduce: (value) {
                  publicChangeCartItemCreate(d, false);
                },
                onIncrease: (value) {
                  publicChangeCartItemCreate(d, true);
                },
                price: d.itemType == 'spicy'
                    ? "${d.currentPrice}"
                    : "${d.unitPrice}",
                quantity: d.itemType == 'spicy' ? 1 : d.goodsNum,
                showQtyControls: d.itemType != 'spicy',
              ),
          if (discount > 0)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: ScreenAdapter.width(16),
                vertical: ScreenAdapter.height(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'settlement_discount'.tr,
                      style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(32),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE64340),
                      ),
                    ),
                  ),
                  Text(
                    '-¥$discount',
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(36),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE64340),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  //公共加入购物车
  publicAddCartMenu(cartItem, checkItem) async {
    if (cartItem['qtyBounds'] > 0) {
      var checkresult =
          await ordersqlcontroller.getCartItemNum(cartItem['menuCode']);
      if (checkresult >= cartItem['qtyBounds']) {
        _showStorageLimitDialog();
        return false;
      }
    }

    var result = false;
    try {
      await ordersqlcontroller.addToCart(cartItem, checkItem: checkItem);
      await ordersqlcontroller.getCardList();
      result = true;
      await getCartPriceTotal();
    } catch (e) {
      print(e);
      logger.info('-- publicAddCartMenu error: $e --');
      result = false;
    }
    //update();
    return result;
  }

  Future<void> publicAddCart(BuildContext context, item) async {
    final menuCode = '${item['menuCode']}';
    if (!_tryLockCartAdd(menuCode)) {
      return;
    }

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
    try {
      final added = await publicAddCartMenu(cartItem, true);
      if (added) {
        await publicShowAddCartNew(context);
      }
    } finally {
      _unlockCartAdd(menuCode);
    }
  }

  //公共购物车加减
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
          } else {
            result = await ordersqlcontroller.addToCartNum(cartItem);
          }
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
  publicShowAddCartNew(BuildContext context) async {
    //_showOrderEasyLoading(tag: false);
    if (canAddCart.value == false) {
      return;
    }
    canAddCart.value = false;

    fToast = FToast();
    await fToast?.init(context);

    Widget toast = await Container(
      color: Colors.transparent,
      child: Image.asset(GImage.getImageString("imgpublic", "checked_green"),
          width: ScreenAdapter.width(150), height: ScreenAdapter.height(150)),
    );

    fToast?.showToast(
      child: toast,
      gravity: ToastGravity.CENTER,
      toastDuration: Duration(milliseconds: 300),
    );

    Future.delayed(Duration(milliseconds: 500), () {
      canAddCart.value = true;
    });

    playQRScannerSound();
    //EasyLoading.dismiss();
  }

  playQRScannerSound() async {
    if (Platform.isAndroid) {
      await AssetsAudioPlayer.newPlayer().open(
        Audio("assets/audios/14428.wav"),
        autoStart: true,
        volume: 0.3,
      );
    } else {
      try {
        if (player == null) {
          player = AudioPlayer();
        }
        await player?.setVolume(1.2);
        //await player.play(DeviceFileSource("assets/audios/14428.wav"));
        await player?.setSource(AssetSource('audios/14428.wav'));
        await player?.resume();
      } catch (e) {
        debugPrint("playQRScannerSound error: $e");
        FToast fToast = FToast();
        if (Get.context != null) {
          fToast.init(Get.context!);
          fToast.showToast(
            child: Text("playQRScannerSound error: $e"),
            gravity: ToastGravity.CENTER,
          );
        }
      }
    }
  }

  deleteItemSound() async {
    debugPrint('---deleteItemSound');
    if (Platform.isAndroid) {
      await AssetsAudioPlayer.newPlayer().open(
        Audio("assets/audios/697.wav"),
        autoStart: true,
        volume: 0.8,
      );
    } else {
      if (player == null) {
        player = AudioPlayer();
      }
      await player?.setVolume(1.2);
      await player?.setSource(AssetSource('audios/697.wav'));
      await player?.resume();
    }
  }

  changeOptionv1(menuCode, groupCode, optionCode, setMenuState) {
    //playQRScannerSound();

    var attr = menuOption[menuCode];
    for (var i = 0; i < attr.length; i++) {
      if (attr[i]["groupCode"] == groupCode) {
        //如果是多选，那么需要判断该组option数量是否超过最大值
        if (int.parse(attr[i]["multipleState"]) > 1) {
          var current_option_checked = 0;
          //var current_incloud_option_checked = 0;
          for (var n = 0; n < attr[i]['optionVoList'].length; n++) {
            if (attr[i]['optionVoList'][n]["checked"] == true &&
                attr[i]['optionVoList'][n]["optionCode"] != optionCode) {
              current_option_checked++;
            }
            /*if((attr[i]['optionVoList'][n]["checked"] == true && attr[i]['optionVoList'][n]["optionCode"] != optionCode )
                || (attr[i]['optionVoList'][n]["optionCode"] == optionCode && attr[i]['optionVoList'][n]["checked"] == false)
            ){
print("加1了");
              current_incloud_option_checked++;
            }*/
          }

          if (current_option_checked >= int.parse(attr[i]["multipleState"])) {
            var showTag = "menu_option_more_multipleState".tr;
            //showToast("${showTag.replaceAll("%%", attr[i]["multipleState"])}");
            Get.dialog(DialogUtils.alertOneButton(
                "${showTag.replaceAll("%%", attr[i]["multipleState"])}",
                title: "tag_title".tr,
                confirmtitle: "tag_button_yes".tr, confirm: () {
              Get.back();
            }));
            break;
          }

          /*if(current_incloud_option_checked < int.parse(attr[i]["smallest"])){
            showToast("该组选项不能小于${attr[i]["smallest"]}个");
            break;
          }*/
        }
        for (var j = 0; j < attr[i]['optionVoList'].length; j++) {
          if (attr[i]["multipleState"] == "1") {
            //attr[i]['optionVoList'][j]["checked"] = false;
            if (attr[i]['optionVoList'][j]["optionCode"] != optionCode) {
              attr[i]['optionVoList'][j]["checked"] = false;
            } else if (attr[i]['optionVoList'][j]["optionCode"] == optionCode) {
              attr[i]['optionVoList'][j]["checked"] =
                  !attr[i]['optionVoList'][j]["checked"];
            }
          } else {
            if (attr[i]['optionVoList'][j]["optionCode"] == optionCode) {
              attr[i]['optionVoList'][j]["checked"] =
                  !attr[i]['optionVoList'][j]["checked"];
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

          selectPrice += _list[i]['optionVoList'][j]["currentPrice"];
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
    if (item['qtyBounds'] == 0 || _cartAddInFlight.contains(menuCode)) {
      return;
    }

    final hasOptions = item['optionGroupVoList']?.length > 0;
    final isLimited = item['qtyBounds'] > 0;
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
  //展示某带option商品
  publicShowOneItemWidget(item) {
    _showOptionDialog(item, popupType: "old");
  }

  publicShowOneItemWidgetv1(item) {
    _showOptionDialog(item, popupType: "v1");
  }

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

      final added = await publicAddCartMenu(cartItem, false);
      if (added) {
        publicShowAddCartNew(context);
        if (resetOptionMenuCode != null) {
          changeInitialAllOption(resetOptionMenuCode);
        }
      }
      return added;
    } finally {
      _unlockCartAdd(menuCode);
    }
  }

  Future<void> _addToCartCallback(item, price, options, optionTitle) async {
    debugPrint("price:$price");
    debugPrint("options:$options");
    debugPrint("optionTitle:$optionTitle");
    //options 是一个字符串数组，把它转换成字符串逗号分隔
    String optionsString = options.map((e) => e.toString()).toList().join(',');

    var cartItem = {
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

    if (attr != null) {
      for (var i = 0; i < attr.length; i++) {
        for (var j = 0; j < attr[i]['optionVoList'].length; j++) {
          var check = initMenuOption
              .any((e) => e == attr[i]['optionVoList'][j]["optionCode"]);
          if (true == check) {
            attr[i]['optionVoList'][j]["checked"] = true;
            _addOptionPrice += attr[i]['optionVoList'][j]["currentPrice"];
          } else {
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

          selectPrice += _list[i]['optionVoList'][j]["currentPrice"];
        }
      }
    }

    selectedMenuOptionList[menuCode] = tempArr;
    addselectedMenuOptionChangePrice[menuCode] = selectPrice;
    tempArr = [];
  }

  showSetSelloutAlert(menuId, name, bounds) {
    bool isSellOut = bounds == 0;
    String tips = isSellOut
        ? 'このメニュー($name)を販売中に変更してもよろしいですか?'
        : 'このメニュー($name)を本日売り切れに変更してもよろしいですか?';
    Get.dialog(DialogUtils.alert(tips, confirm: () {
      Get.back();
    }, cancle: () {
      Get.back();
    }));
  }

  _showOrderEasyLoading({bool tag = true}) {
    var _showTag = Text("settlement_noprint_tag".tr,
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
            tag == true
                ? _showTag
                : Container(
                    height: 0,
                  ),
            Container(
              //width: ScreenAdapter.width(400),
              margin: EdgeInsets.only(top: 60),
              height: ScreenAdapter.height(200),
              child: Image.asset(
                  GImage.getImageString("imgpublic", "printticketloading"),
                  fit: BoxFit.fitHeight),
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

  Future<void> submitOrderFlow() => _doSubmitOrder();

  //提交订单
  Future<void> _doSubmitOrder({int times = 0}) async {
    if (machineInfo.machineCode == "" ||
        _submitInFlight ||
        showCartTotalGoodsNum.value <= 0) {
      return;
    }

    _submitInFlight = true;
    canAddCart.value = false;
    try {
      _showOrderEasyLoading();
      playQRScannerSound();

      // 提交前同步一次 DB，保证明细与总价一致
      await ordersqlcontroller.getCardList();
      var cartItems = ordersqlcontroller.getcartItems;
      if (cartItems.isEmpty) {
        await EasyLoading.dismiss();
        return;
      }
      List selectedItem = [];

      for (var oneItem in cartItems) {
        var optionMap = {};
        final grams = oneItem["spicyGrams"] ?? 0;
        final qty = grams > 0 ? grams : oneItem["goodsNum"];
        if (oneItem["optionGroupVoList"] == "") {
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "qty": qty
          };
        } else {
          var optionGroupVoList = oneItem["optionGroupVoList"];
          var itemsOption = optionGroupVoList.split(',');
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "optionList": itemsOption,
            "qty": qty
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
        //"takeout": (_dining_type == "2") ? true: false,
        "takeout": machineInfo.isTakeoutMode,
      };
      if (isSpicyHotPotMenuScanEnabled && spicyTableNo.isNotEmpty) {
        formData['tableNo'] = spicyTableNo;
      }
      if (totalCartDiscountYen > 0) {
        formData['discount'] = totalCartDiscountYen;
      }
      debugPrint("formData: $formData");
      final val = await request(
        'webBootOrder',
        method: 'POST',
        parameters: formData,
        timeout: const Duration(seconds: 15),
      );
      await EasyLoading.dismiss();
      var response = json.decode(val.toString());
      debugPrint("webBootOrder response: $response");

      if (response != null && response['code'] == 200) {
        doSubmitOrderId.value = response['data']["orderId"];
        final total = response['data']["total"].toString();
        int tax1 = response['data']["tax1"] ?? 0;
        int tax2 = response['data']["tax2"] ?? 0;

        showSelectMealTypeAndPaymentMethodDialog(total,
            tax1: tax1, tax2: tax2);
      } else {
        if (response != null &&
            response['data'] != null &&
            response['data']["menuLackMap"] != null) {
          menuLackMap.value = response['data']["menuLackMap"];
        }
        Get.dialog(DialogUtils.alertOneButton(response['data']["message"],
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr, confirm: () {
          Get.back();
        }));
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

  _handleOrderResultAlert({int times = 0}) {
    EasyLoading.dismiss();
    if (times > 2) {
      Get.dialog(DialogUtils.alertOneButton("order_network_error".tr,
          title: "tag_title".tr,
          confirmtitle: "tag_button_yes".tr, confirm: () {
        Get.back();
        // FirebaseAnalytics.instance.logEvent(name: "submit_order_error",parameters: {
        //   "machineCode": machineInfo.machineCode,
        // });
      }));
      return;
    }

    Get.dialog(DialogUtils.alert("show_order_error".tr,
        title: "tag_title".tr, confirmtitle: "tag_button_yes".tr, confirm: () {
      Get.back();
      _doSubmitOrder(times: times + 1);
    }, cancle: () {
      Get.back();
      //clearCartList();
      // FirebaseAnalytics.instance.logEvent(name: "submit_order_error",parameters: {
      //   "machineCode": machineInfo.machineCode,
      // });
    }));
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
            // if (Platform.isWindows) {//Windows 系统会自动退出结算页面的时候，添加退金操作点。
            //   await CashChanger.endDeposit(DepositAction.repay.index);
            // }
            debugPrint('onCancelClick');
            paymentIsShow = false;
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
    request('webBootToPayConfirm', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      //EasyLoading.dismiss();

      if (response['code'] == 200 &&
          response['data'] != null &&
          response['data']['orderId'] != null) {
        doSubmitOrderId.value = response['data']["orderId"];

        //gotoSettlement();
      } else {
        //showToast(response['data']["message"]);
        Get.dialog(DialogUtils.alertOneButton(response['data']["message"],
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr, confirm: () {
          Get.back();
        }));
      }
    });
  }


  resetToFirstPage() async {
    await getBookingBootIndexCategory(isReset: true);
    debugPrint('getBookingBootIndexCategory done');
    await getCartPriceTotal();
  }

  gotoSettlement(String total, int tax) async {
    if (isSpicyHotPotMenuScanEnabled &&
        (machineInfo.paymentMethod == "0" || machineInfo.paymentMethod == "1")) {
      await ScaleSerialService.releaseUsbSafely(reason: 'goto_settlement');
    }
    Get.toNamed('/settlement', preventDuplicates: false, arguments: {
      "checkLanguage": checkLanguage.value,
      "orderId": doSubmitOrderId.value,
      "totalPrice": total,
      "machineMode": "1",
      "showOpenPayment": showOpenPayment.value
    });
  }

  CancelOrder() {
    logI('---CancelOrder---');
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
    spicyFloorDiscountYen.value = 0;
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

  gotoLanguageHome() {
    if (!_isCurrentMenuRoute) return;

    //clearCartList();
    ordersqlcontroller.removeAllFromCart();
    ordersqlcontroller.getCardList();
    if (machineInfo.currentMode == MachineMode.spicyHotPot) {
      machineInfo.currentMode = MachineMode.sell;
    }
    checkLanguage.value = 'JP';
    if (Get.isRegistered<CheckoutPageController>()) {
      Get.find<CheckoutPageController>().updateSettingLanguage('JP');
    } else {
      Get.updateLocale(const Locale('ja', 'JP'));
    }
    //getBookingBootMenu();
    //Future.delayed(Duration(milliseconds: 100),() async {
    Get.back();
    //});
  }
}
