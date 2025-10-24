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
import 'package:foodorder/app/services/CashChangerService.dart';

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
import '../../../services/HttpService.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../widget/DialogUtils.dart';
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
  }

  //获取菜单
  Future<void> onClose() async {
    debugPrint('MenuPageController onClose');
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
    if (isReset) {
      change(null, status: RxStatus.loading());
    } else {
      topMenu.value = [];
    }
    var queryTakeout = "2";
    if (machineInfo.currentMode == MachineMode.takeout) {
      queryTakeout = "0";
    }

    //queryTakeout 0外卖 1都可 2店内
    // switch (machineInfo.diningType) {
    //   case "1":
    //     queryTakeout = "2";
    //     break;
    //   case "2":
    //     queryTakeout = "0";
    //     break;
    //   case "3":
    //     if (machineInfo.mealType == true) {
    //       queryTakeout = "0";
    //     } else {
    //       queryTakeout = "2";
    //     }
    //     break;
    //   default:
    //     queryTakeout = "2";
    // }

    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": checkLanguage.value,
      "takeout": queryTakeout,
    };
    debugPrint('formData:$formData');
    request('webBootIndexCategoryv2', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());

      if (response['code'] == 200) {
        //2、保存商品信息
        List myList = response['data']['categoryVoList'];
        recommendFoods = response['data']['recommendMenus'] ?? [];
        //如果菜单为空则返回言语选择页面并给出提示
        if (myList.length == 0 || null == myList || "" == myList) {
          //showToast("少々お待ちください");
          Get.dialog(DialogUtils.alertOneButton("少々お待ちください",
              title: "tag_title".tr,
              confirmtitle: "tag_button_yes".tr, confirm: () {
            Get.back();
          }));
          sleep(Duration(milliseconds: 2000));
          Get.back();
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
          if (colorIndex >= 5) colorIndex = 0;
          var categoryVoList = myList[i];
          //配置顶部菜单
          topMenu.add({
            "categoryCode": categoryVoList['categoryCode'],
            "categoryName": categoryVoList['categoryName'],
            "showType": categoryVoList['showType'],
            "showColor": categoryVoList['color'] ?? MenuColor[colorIndex],
            "index": menuIndex
          });
          menuIndex++;
          colorIndex++;
          //配置顶部菜单默认项
          if (i == 0) classTag.value = categoryVoList['categoryCode'];
        }
        // if (isReset) {
        //   _resetToFirstCategory();
        // } else {
        //   //getBookingBootIndexMenu(classTag.value);
        // }

        // update();
        change(null, status: RxStatus.success());
      } else {
        //showToast(response['msg']);
        Get.dialog(DialogUtils.alertOneButton(response['msg'],
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr, confirm: () {
          Get.back();
        }));
        sleep(Duration(milliseconds: 2000));
        Get.back();
      }
    }).catchError((e) {
      if (retryCount < 3) {
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
    }).timeout(Duration(seconds: 8), onTimeout: () {
      //FirebaseAnalytics.instance.logEvent(name: 'load_menu_category_timeout', parameters: {'machineCode': machineInfo.machineCode});
      change(null, status: RxStatus.error('Failed to load data Timeout'));
      // if (retryCount < 3) {
      //   retryCount++;
      //   debugPrint('Retrying getBookingBootIndexCategory on timeout, attempt: $retryCount');
      //   getBookingBootIndexCategory(isReset: isReset, retryCount: retryCount);
      // } else {
      //   FirebaseAnalytics.instance.logEvent(name: 'load_menu_category_timeout', parameters: {'machineCode': machineInfo.machineCode});
      //   change(null, status: RxStatus.error('Failed to load data Timeout'));
      // }
    });
  }

  forceUpdateUI() {
    forceUpdate = true;
    update();
    forceUpdate = false;
  }

  getBookingBootIndexMenu(queryCategoryCode, {int retryCount = 0}) {
    debugPrint('getBookingBootIndexMenu');
    var queryTakeout = "2";
    if (machineInfo.currentMode == MachineMode.takeout) {
      queryTakeout = "0";
    }
    //queryTakeout 0外卖 1都可 2店内
    // switch(machineInfo.diningType){
    //   case "1":
    //     queryTakeout = "2";
    //     break;
    //   case "2":
    //     queryTakeout = "0";
    //     break;
    //   case "3":
    //     if(machineInfo.mealType == true){
    //       queryTakeout = "0";
    //     }else{
    //       queryTakeout = "2";
    //     }
    //     break;
    //   default:
    //     queryTakeout = "2";
    // }
    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": checkLanguage.value,
      "takeout": queryTakeout,
      "categoryCode": queryCategoryCode
    };
    request('webBootIndexMenuv3', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      debugPrint('getBookingBootIndexMenu response:$response');
      if (response['code'] == 200) {
        //2、保存商品信息
        List myList = response['data'];
        //如果菜单为空则返回言语选择页面并给出提示
        if (myList.length == 0 || null == myList || "" == myList) {
          //showToast("少々お待ちください");
          Get.dialog(DialogUtils.alertOneButton("少々お待ちください",
              title: "tag_title".tr,
              confirmtitle: "tag_button_yes".tr, confirm: () {
            Get.back();
          }));
          sleep(Duration(milliseconds: 2000));
          Get.back();
        }

        showItem.value[queryCategoryCode] = myList;

        //该分类下有option，先初始化页面数据
        if (myList.length > 0) {
          for (var menuVoList in myList) {
            num _addOptionPrice = 0;
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
                    attr[m]['optionVoList'][n]["groupTitle"] =
                        attr[m]["groupName"];
                    tempArr.add(attr[m]['optionVoList'][n]);
                    initalCode.add(attr[m]['optionVoList'][n]['optionCode']);

                    _addOptionPrice +=
                        attr[m]['optionVoList'][n]["currentPrice"];
                    checkNum++;
                  } else {
                    attr[m]['optionVoList'][n]["checked"] = false;
                    nochangeattr[m]['optionVoList'][n]["checked"] = false;
                  }
                }
              }
              //需要创建的小组件
              menuOption.value[menuVoList['menuCode']] = attr;
              noChangeinitialmenuOption.value[menuVoList['menuCode']] =
                  initalCode;
              initialMenuOption.value[menuVoList['menuCode']] =
                  tempArr; //tempArr;
              selectedMenuOptionList.value[menuVoList['menuCode']] = tempArr;
              selectedMenuOptionCheckedNum.value[menuVoList['menuCode']] =
                  checkNum;
              attr = [];
              tempArr = [];
              checkNum = 0;
            }
            selectedMenuOptionChangePrice.value[menuVoList['menuCode']] =
                menuVoList['currentPrice'];
            addselectedMenuOptionChangePrice.value[menuVoList['menuCode']] =
                _addOptionPrice;
          }
        }
        classTag.value = queryCategoryCode;
        change(null, status: RxStatus.success());
      } else {
        //showToast(response['msg']);
        Get.dialog(DialogUtils.alertOneButton(response['msg'],
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr, confirm: () {
          Get.back();
        }));
        sleep(Duration(milliseconds: 2000));
        Get.back();
      }
    }).catchError((e) {
      if (retryCount < 3) {
        retryCount++;
        debugPrint('Retrying getBookingBootIndexMenu, attempt: $retryCount');
        getBookingBootIndexMenu(queryCategoryCode, retryCount: retryCount);
      } else {
        // FirebaseAnalytics.instance.logEvent(
        //     name: 'load_menu_failure',
        //     parameters: {'machineCode': machineInfo.machineCode});
        change(null, status: RxStatus.error('Failed to load data'));
      }
    }).timeout(Duration(seconds: 12), onTimeout: () {
      //FirebaseAnalytics.instance.logEvent(name: 'load_menu_timeout', parameters: {'machineCode': machineInfo.machineCode});
      change(null, status: RxStatus.error('Failed to load data Timeout'));
      // if (retryCount < 3) {
      //   retryCount++;
      //   debugPrint('Retrying getBookingBootIndexMenu on timeout, attempt: $retryCount');
      //   getBookingBootIndexMenu(queryCategoryCode, retryCount: retryCount);
      // } else {
      //   FirebaseAnalytics.instance.logEvent(name: 'load_menu_timeout', parameters: {'machineCode': machineInfo.machineCode});
      //   change(null, status: RxStatus.error('Failed to load data Timeout'));
      // }
    });
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
      update(['shopping_cart', 'shoppingCar']);
    } catch (e) {
      print(e);
      logger.info('-- getCartPriceTotal error: $e --');
    }
  }

  publicChangeCartItemCreate(ShopItemModel d, isAdd) async {
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
          confirmtitle: "show_del_cart_item_yes".tr, confirm: () {
        //widget.confirmCallback('确定');
        ordersqlcontroller.removeFromCart(d.id ?? 0);
        //print("Item removed from cart successfully");
        //删除商品声音
        deleteItemSound();
        ordersqlcontroller.getCardList();
        //更改显示购物车价格
        getCartPriceTotal();

        Get.back();
      }, cancle: () {
        Get.back();
      }));
    } else {
      final action = isAdd ? "add" : "reduce";
      if (isAdd) {
        playQRScannerSound();
      } else {
        deleteItemSound();
      }
      publicChangeCartMenuCount(cartItem, action).then((val) {
        //更改显示购物车价格
        getCartPriceTotal();
      });
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
    return ListView(
      shrinkWrap: true,
      children: showCartItems
          .map((d) => CarItemView(
                title: d.mainTitle,
                subtitle: d.optionVoListMsg,
                image: itemImage(d.image),
                onReduce: (value) {
                  publicChangeCartItemCreate(d, false);
                },
                onIncrease: (value) {
                  publicChangeCartItemCreate(d, true);
                },
                price: "${d.unitPrice}",
                quantity: d.goodsNum,
              ))
          .toList(),
    );
  }

  //公共加入购物车
  publicAddCartMenu(cartItem, checkItem) async {
    if (cartItem['qtyBounds'] > 0) {
      var checkresult =
          await ordersqlcontroller.getCartItemNum(cartItem['menuCode']);
      if (checkresult >= cartItem['qtyBounds']) {
        var showString = "show_storage_num_error".tr;
        //showToast("${showString}");
        Get.dialog(DialogUtils.alertOneButton(showString,
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr, confirm: () {
          Get.back();
        }));
        return false;
      }
    }

    var result = false;
    try {
      await ordersqlcontroller.addToCart(cartItem, checkItem: checkItem);
      ordersqlcontroller.getCardList();
      result = true;
      //更改显示购物车价格
      getCartPriceTotal();
    } catch (e) {
      print(e);
      logger.info('-- publicAddCartMenu error: $e --');
      result = false;
    }
    //update();
    return result;
  }

  publicAddCart(BuildContext context, item) async {
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
    publicAddCartMenu(cartItem, true).then((val) async {
      //更改显示购物车价格
      //getCartPriceTotal();
      if (val != false) {
        await publicShowAddCartNew(context);
      }
    });
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
            var showString = "show_storage_num_error".tr;
            //showToast("${showString}");
            Get.dialog(DialogUtils.alertOneButton(showString,
                title: "tag_title".tr,
                confirmtitle: "tag_button_yes".tr, confirm: () {
              Get.back();
            }));
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

      ordersqlcontroller.getCardList();
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
    // if (canAddCart.value == false) {
    //   return;
    // }

    var result = await ordersqlcontroller.getCartItemNum(item['menuCode']);

    if (result >= item['qtyBounds']) {
      var showString = "show_storage_num_error".tr;
      //showToast("${showString}");
      Get.dialog(DialogUtils.alertOneButton(showString,
          title: "tag_title".tr,
          confirmtitle: "tag_button_yes".tr, confirm: () {
        Get.back();
      }));
      return;
    } else {
      //如果option 存在，则弹出option
      if (item['optionGroupVoList']?.length > 0) {
        //publicShowOneItemWidget(item);
        if (popupType == "v1") {
          debugPrint("11111111111111");
          publicShowOneItemWidgetv1(item);
        } else {
          debugPrint("00000000000000");
          publicShowOneItemWidget(item);
        }
      } else {
        await publicAddCart(context, item);
      }
    }
  }

  //展示某带option商品
  //展示某带option商品
  publicShowOneItemWidget(item) {
    //changeInitialAllOption(item['menuCode']);
    //Future.delayed(Duration(milliseconds: 50),() async {
    // Get.dialog(barrierDismissible: false, showOneItemOptionWidgetView(item));
    Get.dialog(
        barrierDismissible: false,
        //showOneItemOptionWidgetView(item)
        OptionView(
          isLabel: true,
          languageKey: checkLanguage.value,
          itemPrice: item['currentPrice'],
          originalPrice: item['price'],
          optionInfo: item['optionGroupVoList'] ?? [],
          mainTitle: item['mainTitle'],
          subtitle: item['subtitle'] ?? [],
          addToCartCallback: (price, options, optionTitle) {
            _addToCartCallback(item, price, options, optionTitle);
          },
        ));
    //});
  }

  publicShowOneItemWidgetv1(item) {
    //changeInitialAllOption(item['menuCode']);
    //Future.delayed(Duration(milliseconds: 50),() async {
    // Get.dialog(
    //     barrierDismissible: false, showOneItemOptionWidgetVOneView(item));
    Get.dialog(
        barrierDismissible: false,
        //showOneItemOptionWidgetVOneView(item)
        OptionView(
          isLabel: false,
          languageKey: checkLanguage.value,
          itemPrice: item['currentPrice'],
          originalPrice: item['price'],
          optionInfo: item['optionGroupVoList'] ?? [],
          mainTitle: item['mainTitle'],
          subtitle: item['subtitle'] ?? [],
          addToCartCallback: (price, options, optionTitle) {
            _addToCartCallback(item, price, options, optionTitle);
          },
        ));
    //});
  }

  _addToCartCallback(item, price, options, optionTitle) async {
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

    await publicAddCartMenu(cartItem, false).then((val) {
      final context = Get.context;
      if (val != false && context != null) {
        publicShowAddCartNew(context);
      }
    });
    Get.back();
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

  submitOrderFlow() async {
    // if (machineInfo.isAllowCash == true && machineInfo.cashOn == false) {
    //   _showOrderEasyLoading();
    //   bool result = await Cashchangerservice.checkMachineFlow();
    //   logger.info('-- checkMachineFlow cash state = $result --');
    //   EasyLoading.dismiss();
    //   if (result) {
    //     machineInfo.cashOn = true;
    //     machineInfo.showCash = true;
    //     update();
    //   }
    // }
    _doSubmitOrder();
  }

  // checkMachineState() async {
  //   if (machineInfo.isAllowCash == true) { // && machineInfo.cashOn == false
  //     machineInfo.isChecking = true;
  //     machineInfo.update(['selectPayment']);
  //     var result = await Cashchangerservice.checkMachineFlow();
  //     logger.info('-- checkMachineState result = $result --');
  //     machineInfo.isChecking = false;
  //     if (result) {
  //       machineInfo.showCash = true;
  //       machineInfo.cashOn = true;
  //     } else {
  //       machineInfo.showCash = false;
  //       machineInfo.cashOn = false;
  //     }
  //     machineInfo.update(['selectPayment']);
  //   }

  // }

  //提交订单
  _doSubmitOrder({int times = 0}) {
    if (machineInfo.machineCode != "") {
      _showOrderEasyLoading();

      //自定义声音
      playQRScannerSound();

      var cartItems = ordersqlcontroller.getcartItems;
      List selectedItem = [];

      for (var oneItem in cartItems) {
        var optionMap = {};
        if (oneItem["optionGroupVoList"] == "") {
          optionMap = {
            "menuCode": oneItem["menuCode"],
            "qty": oneItem["goodsNum"]
          };
        } else {
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
      var orderTotlaPrice = getItemTotal(ordersqlcontroller.cartItems);
      var formData = {
        "language": checkLanguage.value,
        "machineCode": machineInfo.machineCode,
        "orderLineList": selectedItem,
        "total": orderTotlaPrice,
        //"takeout": (_dining_type == "2") ? true: false,
        "takeout": machineInfo.isTakeoutMode,
      };
      debugPrint("formData: $formData");
      request('webBootOrder', method: 'POST', parameters: formData).then((val) {
        EasyLoading.dismiss();
        var response = json.decode(val.toString());
        debugPrint("webBootOrder response: $response");

        if (response['code'] == 200 && response != null) {
          //"paymentMethod" 1，现金 2，扫码 3，刷卡 4nfc

          doSubmitOrderId.value = response['data']["orderId"];
          final total = response['data']["total"].toString();
          //int totalTax = machineInfo.mealType ? (response['data']["tax2"] ?? 0) : (response['data']["tax1"] ?? 0);
          int tax1 = response['data']["tax1"] ?? 0;
          int tax2 = response['data']["tax2"] ?? 0;

          showSelectMealTypeAndPaymentMethodDialog(total, tax1: tax1, tax2: tax2);

        }else{
          //getBookingBootMenu();
          // FirebaseAnalytics.instance
          //     .logEvent(name: "submit_order_fail", parameters: {
          //   "machineCode": machineInfo.machineCode,
          // });
          if (response != null &&
              response['data'] != null &&
              response['data']["menuLackMap"] != null) {
            menuLackMap.value = response['data']["menuLackMap"];
          }
          //showToast(response['data']["message"]);
          Get.dialog(DialogUtils.alertOneButton(response['data']["message"],
              title: "tag_title".tr,
              confirmtitle: "tag_button_yes".tr, confirm: () {
            Get.back();
          }));
        }
      }).timeout(Duration(seconds: 30), onTimeout: () {
        _handleOrderResultAlert(times: times);
      }).catchError((e) {
        _handleOrderResultAlert(times: times);
      });
    } else {
      // FirebaseAnalytics.instance.logEvent(name: "submit_order_error",parameters: {
      //   "machineCode": machineInfo.machineCode,
      // });
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
  showSelectMealTypeAndPaymentMethodDialog(String total, {int tax1 = 0, int tax2 = 0}) async {
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

  // _getPosSettingInfo() async {
  //   Map posSettingInfo = await HomeServices.getPosSettingInfo();
  //   pos_ip.value = posSettingInfo['posIp'];
  //   pos_port.value = posSettingInfo['posPort'];
  //   //postNewOrderId();
  //   gotoSettlement();
  // }

  resetToFirstPage() async {
    await getBookingBootIndexCategory(isReset: true);
    debugPrint('getBookingBootIndexCategory done');
    await getCartPriceTotal();
    //await _resetToFirstCategory();
  }

  gotoSettlement(String total, int tax) async {
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

  _resetToFirstCategory() {
    final firstCategory = topMenu.first['categoryCode'];
    if (firstCategory != null) {
      changeCategory(firstCategory);
    } else {
      changeCategory(classTag.value);
    }
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

  //切换顶部菜单分类
  changeCategory(categoryCode) {
    getBookingBootIndexMenu(categoryCode);
    //update();
  }

  clearCartList() {
    ordersqlcontroller.removeAllFromCart();
    ordersqlcontroller.getCardList();
    classTag.value = topMenu.value[0]["categoryCode"];
    menuLackMap.value = {};
    getCartPriceTotal();
  }

  gotoLanguageHome() {
    //clearCartList();
    ordersqlcontroller.removeAllFromCart();
    ordersqlcontroller.getCardList();
    //getBookingBootMenu();
    //Future.delayed(Duration(milliseconds: 100),() async {
    Get.back();
    //});
  }
}
