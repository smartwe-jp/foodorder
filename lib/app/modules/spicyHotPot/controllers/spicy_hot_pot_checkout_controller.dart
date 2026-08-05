import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodorder/app/modules/menuPage/views/option_widgets/option_view.dart';
import 'package:foodorder/app/services/logUtil.dart';
import 'package:foodorder/app/services/spicy_weigh_settings.dart';
import 'package:get/get.dart';
import '../../../controllers/machine_info.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/HttpService.dart';
import '../../../services/showImage.dart';
import '../../../services/showToast.dart';
import '../views/spicy_bowl_scan_dialog.dart';
import '../views/spicy_hot_pot_category_page.dart';
import '../views/spicy_hot_pot_weigh_dialog.dart';
import '../views/spicy_weigh_page.dart';

/// 麻辣烫模式主控制器（Flutter 3.44 初始版本）
///
/// 当前固定普通注文：称重 → 选汤底/口味 → 选其他菜品。
/// 扫码注文代码保留，设置项已隐藏，以后需要再开放。
///
/// 称重商品 priceType=HUNDRED_GRAM；口味商品入购物车 itemType=spicy
class SpicyHotPotCheckoutController extends GetxController with StateMixin {
  final MachineInfoController machineInfo = Get.find();
  final OrderSqlController orderSqlController = Get.find();

  // 扫码模式输入框焦点
  final FocusNode itemFocusNode = FocusNode();

  RxString checkLanguage = "JP".obs;

  // 购物车
  List get cartItems => orderSqlController.cartItems;
  RxInt totalPrice = 0.obs;

  // 当前扫码/选中的商品（含选项组），两种模式复用
  RxMap scannedItem = {}.obs;

  // 称重商品分类列表（priceType == HUNDRED_GRAM，不含赠品）
  RxList categoryMenuList = [].obs;
  // 选项商品列表（非称重商品，普通注文模式下供用户勾选，不含赠品）
  RxList optionMenuList = [].obs;
  // freeGift=true 的赠品菜（满额后弹窗选择，不进称重/汤底列表）
  RxList freeGiftMenuList = [].obs;
  RxString selectedCategoryName = ''.obs;
  bool _giftDialogShowing = false;

  // 普通注文模式步骤：0=选择并称重，1=选择选项并确认
  RxInt normalStep = 0.obs;
  // 普通注文模式称重结果：{itemData, weight, price, unitPricePer100g}
  RxMap normalWeighResult = {}.obs;
  // 普通注文：选项页顶部大图卡片的选中商品 menuCode（即时反馈）
  RxString selectedOptionMenuCode = ''.obs;
  // 下方子选项展示用的 menuCode（延后一帧，避免拖慢大图点击）
  RxString optionsDisplayMenuCode = ''.obs;
  // 普通注文选项选择：groupKey → [已选optionCode]（旧内联选项；现以弹窗结果为准）
  RxMap<String, List<String>> normalOptionSelections =
      <String, List<String>>{}.obs;
  // optionCode → optionName 映射（入购物车时取名称用）
  final Map<String, String> _optionNameCache = {};
  // groupKey → 分组显示名（入车 optionVoListMsg 用「组名:选项」）
  final Map<String, String> _optionGroupTitleCache = {};
  // 汤底规格弹窗确认后的选项码 / 文案 / 含规格总价
  final RxList<String> selectedSoupOptionCodes = <String>[].obs;
  final RxString selectedSoupOptionMsg = ''.obs;
  final RxInt selectedSoupTotalPrice = 0.obs;
  final RxBool soupOptionsConfirmed = false.obs;
  bool _soupOptionDialogShowing = false;
  bool _isSingleWeighPageOpen = false;
  final RxBool normalOrderSubmitting = false.obs;

  /// 当前会话盆号（扫盆码开启时写入，带到 webBootOrder.tableNo）
  final RxString tableNo = ''.obs;

  // ==================== getter ====================

  // 固定普通注文；扫码模式以后再开放
  bool get isNormalMode => true;
  bool get isScannedItemEmpty => scannedItem.isEmpty;
  Map get scannedItemData => scannedItem;
  List get categoryMenuData => categoryMenuList;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    checkLanguage.value = Get.arguments?['checkLanguage'] ?? 'JP';
    // 延后到帧结束后再切 locale，避免 build 中 updateLocale → forceAppUpdate 崩溃
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyLanguageLocale(checkLanguage.value);
    });
    if (!isNormalMode) {
      itemFocusNode.requestFocus();
    }
    selectShopCategory();
  }

  /// 按首页传入语言同步 GetX locale（驱动 .tr / 字体）
  void _applyLanguageLocale(String language) {
    var locale = const Locale('ja', 'JP');
    if (language == 'CH') {
      locale = const Locale('zh', 'CN');
    } else if (language == 'EN') {
      locale = const Locale('en', 'US');
    } else if (language == 'KO') {
      locale = const Locale('ko', 'KR');
    }
    // 已是目标语言则跳过，减少无意义的全树重建
    if (Get.locale?.languageCode == locale.languageCode &&
        Get.locale?.countryCode == locale.countryCode) {
      return;
    }
    Get.updateLocale(locale);
  }

  @override
  void onClose() {
    itemFocusNode.dispose();
    super.onClose();
  }

  // ==================== 扫码注文模式 ====================

  void onScanSubmitted(String scanText) {
    _handleItemScan(scanText);
  }

  Future<void> _handleItemScan(String scanText) async {
    var formData = {
      "language": checkLanguage.value,
      "machineCode": machineInfo.machineCode,
      "barCode": scanText,
    };
    try {
      request('webBootBarCodeQuery', method: 'POST', parameters: formData)
          .then((val) {
        var response = json.decode(val.toString());
        if (response['code'] == 200 &&
            response["data"] != null &&
            response["data"].isNotEmpty) {
          scannedItem.value = response["data"];
        } else {
          logI('未查询到商品: $scanText');
        }
      });
    } catch (e) {
      logE('查询商品失败: $e');
      showToast('查询失败: $e');
    }
  }

  /// 扫码模式下一步：进入称重商品选择（单品直接弹称重，多品列表选择）
  Future<void> goNextWeighStep() async {
    if (categoryMenuList.isEmpty) await selectShopCategory();

    if (categoryMenuList.length > 1) {
      Get.to(() => SpicyHotPotCategoryPage());
    } else if (categoryMenuList.length == 1) {
      showScaleDialogForItem(categoryMenuList.first as Map);
    } else {
      showToast('暂无称重商品');
    }
  }

  // ==================== 公共称重入口 ====================

  void showScaleDialogForItem(Map itemData) {
    final rawUnitPrice = itemData['unitPrice'] ?? itemData['currentPrice'];
    final unitPricePer100g = rawUnitPrice != null
        ? (rawUnitPrice is int
            ? rawUnitPrice
            : int.tryParse(rawUnitPrice.toString()) ?? 0)
        : 0;

    void onConfirm(double weight, int price) {
      if (isNormalMode) {
        _onWeighConfirmedNormal(itemData, weight, price, unitPricePer100g);
      } else {
        _onWeighConfirmedScan(itemData, weight, price, unitPricePer100g);
      }
    }

    if (categoryMenuList.length == 1) {
      if (_isSingleWeighPageOpen) return;
      _isSingleWeighPageOpen = true;
      Get.to(
        () => SpicyWeighPage(
          itemData: itemData,
          unitPricePer100g: unitPricePer100g,
          onConfirm: onConfirm,
          onCancel: goHome,
          onSkip: skipWeighToSellMode,
        ),
        transition: Transition.fade,
      )?.whenComplete(() {
        _isSingleWeighPageOpen = false;
      });
    } else {
      Get.dialog(
        SpicyWeighDialog(
          itemData: itemData,
          unitPricePer100g: unitPricePer100g,
          onConfirm: onConfirm,
        ),
        barrierDismissible: false,
      );
    }
  }

  /// 跳过称重：直接进入配菜菜单（保留 spicyHotPot mode，菜单页扫码仍可用）
  /// 清掉麻辣烫相关页面，保留结账首页，使菜单返回回到首页而非麻辣烫页
  void skipWeighToSellMode() {
    logI('跳过称重，进入配菜菜单（mode 保持 spicyHotPot）');
    // 不改 currentMode：保留 spicyHotPot，菜单页扫码入车才能正常工作
    Get.offNamedUntil(
      '/menu-page',
      (route) => route.settings.name == '/checkout-page',
      arguments: menuPageArguments(),
    );
  }

  // ==================== 扫码模式称重确认 ====================

  Future<void> _onWeighConfirmedScan(
      Map itemData, double weight, int price, int unitPricePer100g) async {
    logI('扫码模式称重确认: ${itemData["mainTitle"]}, ${weight}g, ¥$price');

    // 扫码商品（带已选选项）入购物车
    final currentScanned = Map.from(scannedItem);
    if (currentScanned.isNotEmpty) {
      final options = _extractSelectedOptions(currentScanned);
      await orderSqlController.addToCart({
        'menuCode': currentScanned['menuCode'] ?? '',
        'mainTitle': currentScanned['mainTitle'] ?? '',
        'image': currentScanned['homeImage'] ?? currentScanned['image'] ?? '',
        'currentPrice': currentScanned['currentPrice'] ?? 0,
        'unitPrice': currentScanned['currentPrice'] ?? 0,
        'optionGroupVoList': options['codes']!.join(','),
        'optionVoListMsg': options['names']!.join(','),
        'goodsNum': 1,
        'qtyBounds': currentScanned['qtyBounds'] ?? 0,
        'itemType': 'spicy',
      }, checkItem: false);
      orderSqlController.getCardList();
    }

    // 称重商品入购物车
    await _addWeighItemToCart(itemData, weight, price, unitPricePer100g);
    await updateTotalPrice();
    scannedItem.clear();

    if (categoryMenuList.length == 1) {
      // 单商品时用 Get.off() 替换了中间页，此处用 offNamed 替换 SpicyWeighPage
      Get.offNamed('/menu-page', arguments: menuPageArguments());
    } else {
      // 多商品用 Dialog，dialog 已自行 Get.back()，此处 push menu page 即可
      Get.toNamed('/menu-page', arguments: menuPageArguments());
    }
  }

  // ==================== 普通注文模式 ====================

  /// 普通注文：称重完成后保存结果，清空选项，进入选项选择步骤
  void _onWeighConfirmedNormal(
      Map itemData, double weight, int price, int unitPricePer100g) {
    logI('普通模式称重确认: ${itemData["mainTitle"]}, ${weight}g, ¥$price');
    normalWeighResult.assignAll({
      'itemData': Map.from(itemData),
      'weight': weight,
      'price': price,
      'unitPricePer100g': unitPricePer100g,
    });
    normalOptionSelections.clear();
    selectedOptionMenuCode.value = '';
    optionsDisplayMenuCode.value = '';
    _optionNameCache.clear();
    _optionGroupTitleCache.clear();
    _clearSoupSelectionExtras();
    // 进入选项页前预拉汤底图，避免首次 Image 请求被重建打断
    _precacheOptionImages();
    normalStep.value = 1;
    // 仅 1 个汤底时：无规格直接选中；有规格延后弹窗（等页面出来）
    if (optionMenuList.length == 1) {
      final code = (optionMenuList.first as Map)['menuCode']?.toString() ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (normalStep.value == 1) {
          selectOptionMenuItem(code);
        }
      });
    }
    // ModeView 始终在路由栈中（Get.to 不替换），设好 normalStep 后
    // 由 SpicyWeighPage._confirm() / SpicyWeighDialog._confirm() 调 Get.back() 返回
    // ModeView 的 Obx 监听到 normalStep=1，自动切换到选项视图
  }

  /// 普通注文：选中汤底
  /// 有规格 → 弹 OptionView（与菜单页一致）；无规格 → 直接选中
  void selectOptionMenuItem(String menuCode) {
    Map? item;
    for (final i in optionMenuList) {
      final m = i as Map;
      if (m['menuCode']?.toString() == menuCode) {
        item = m;
        break;
      }
    }
    if (item == null) return;

    if (_soupHasChoosableOptions(item)) {
      _showSoupOptionDialog(item);
      return;
    }

    _applySoupSelection(
      menuCode,
      totalPrice: item['currentPrice'] ?? 0,
      optionCodes: const [],
      optionTitle: '',
    );
  }

  bool _soupHasChoosableOptions(Map item) {
    final groups =
        (item['optionGroupVoList'] as List?)?.whereType<Map>().toList() ?? [];
    if (groups.isEmpty) return false;
    return groups.any((g) {
      final opts = g['optionVoList'];
      return opts is List && opts.isNotEmpty;
    });
  }

  void _applySoupSelection(
    String menuCode, {
    required dynamic totalPrice,
    required List optionCodes,
    required String optionTitle,
  }) {
    normalOptionSelections.clear();
    _optionNameCache.clear();
    _optionGroupTitleCache.clear();
    selectedOptionMenuCode.value = menuCode;
    optionsDisplayMenuCode.value = menuCode;
    selectedSoupOptionCodes
        .assignAll(optionCodes.map((e) => e.toString()).toList());
    selectedSoupOptionMsg.value = optionTitle;
    final p = totalPrice is int
        ? totalPrice
        : int.tryParse('$totalPrice') ?? 0;
    selectedSoupTotalPrice.value = p;
    soupOptionsConfirmed.value = true;
  }

  void _clearSoupSelectionExtras() {
    selectedSoupOptionCodes.clear();
    selectedSoupOptionMsg.value = '';
    selectedSoupTotalPrice.value = 0;
    soupOptionsConfirmed.value = false;
  }

  /// 底部摘要：只显示已选规格组，去掉空组与竖线占位
  String _formatSoupOptionDisplayTitle(String raw) {
    if (raw.trim().isEmpty) return '';
    return raw
        .replaceAll('｜', '　')
        .replaceAll('|', '　')
        .split(RegExp(r'[　\s]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .join('、');
  }

  /// 汤底规格弹窗（复用菜单页 OptionView）
  void _showSoupOptionDialog(Map item) {
    if (_soupOptionDialogShowing) return;
    _soupOptionDialogShowing = true;

    final optionInfo =
        List<dynamic>.from(item['optionGroupVoList'] ?? const []);
    final itemPrice = item['currentPrice'] ?? 0;
    final priceInt =
        itemPrice is int ? itemPrice : int.tryParse('$itemPrice') ?? 0;
    final prepared = OptionView.prepareState(
      itemPrice: priceInt,
      optionInfo: optionInfo,
    );

    final hasImage = optionInfo.any((g) {
      if (g is! Map) return false;
      final opts = g['optionVoList'];
      if (opts is! List) return false;
      return opts.any((o) {
        if (o is! Map) return false;
        final img =
            o['homeImage']?.toString() ?? o['image']?.toString() ?? '';
        return img.isNotEmpty;
      });
    });

    final subtitle = item['subtitle'];
    final subtitleList = subtitle is List ? subtitle : const [];

    Get.generalDialog(
      pageBuilder: (_, __, ___) => OptionView(
        isLabel: !hasImage,
        languageKey: checkLanguage.value,
        itemPrice: priceInt,
        originalPrice: item['price'] ?? itemPrice,
        optionInfo: optionInfo,
        mainTitle: item['mainTitle'] ?? '',
        subtitle: subtitleList,
        preparedState: prepared,
        addToCartCallback: (price, options, optionTitle) {
          // 先拷贝弹窗结果再关弹窗，避免 dispose 清空同源 list
          final codes = options.map((e) => e.toString()).toList();
          // OptionView 用全角空格拼各组，空组也会占位；只保留有选中的，顿号分隔
          final title = _formatSoupOptionDisplayTitle('$optionTitle');
          _applySoupSelection(
            item['menuCode']?.toString() ?? '',
            totalPrice: price,
            optionCodes: codes,
            optionTitle: title,
          );
          Get.back();
        },
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: Duration.zero,
      transitionBuilder: (_, __, ___, child) => child,
    ).whenComplete(() {
      _soupOptionDialogShowing = false;
    });
  }

  /// 普通注文：切换某分组内某选项的选中状态
  /// groupKey: 分组标识（groupName 或 menuCode）
  /// isMulti: 是否允许多选
  void toggleNormalSectionOption(
      String groupKey, String optionCode, String optionName, bool isMulti,
      {String groupTitle = ''}) {
    final current = List<String>.from(normalOptionSelections[groupKey] ?? []);
    if (current.contains(optionCode)) {
      current.remove(optionCode);
    } else {
      if (!isMulti) current.clear();
      current.add(optionCode);
    }
    normalOptionSelections[groupKey] = current;
    normalOptionSelections.refresh();
    _optionNameCache[optionCode] = optionName;
    if (groupTitle.isNotEmpty) {
      _optionGroupTitleCache[groupKey] = groupTitle;
    }
  }

  /// 普通注文：由 OptionListWidget / OptionWidget 回调更新选中状态
  void updateNormalOptionFromWidget(String groupKey, String optionCode,
      String optionName, bool isAdd, bool isMulti,
      {String groupTitle = ''}) {
    final current = List<String>.from(normalOptionSelections[groupKey] ?? []);
    if (isAdd) {
      if (!isMulti) current.clear();
      if (!current.contains(optionCode)) current.add(optionCode);
      _optionNameCache[optionCode] = optionName;
      if (groupTitle.isNotEmpty) {
        _optionGroupTitleCache[groupKey] = groupTitle;
      }
    } else {
      current.remove(optionCode);
      _optionNameCache.remove(optionCode);
    }
    normalOptionSelections[groupKey] = current;
    normalOptionSelections.refresh();
  }

  /// 组装与普通菜单一致的 optionVoListMsg：`组名:选项1,选项2`
  String _buildNormalOptionVoListMsg() {
    if (selectedSoupOptionMsg.value.isNotEmpty) {
      return selectedSoupOptionMsg.value;
    }
    final parts = <String>[];
    for (final entry in normalOptionSelections.entries) {
      if (entry.value.isEmpty) continue;
      final titles = entry.value
          .map((code) => _optionNameCache[code] ?? code)
          .where((name) => name.isNotEmpty)
          .join(',');
      if (titles.isEmpty) continue;
      final groupTitle = _optionGroupTitleCache[entry.key] ?? '';
      if (groupTitle.isNotEmpty) {
        parts.add('$groupTitle:$titles');
      } else {
        parts.add(titles);
      }
    }
    return parts.join(',');
  }

  /// 当前选中的口味商品（汤底）
  Map? get selectedOptionMenuItem {
    final code = selectedOptionMenuCode.value;
    if (code.isEmpty) return null;
    for (final i in optionMenuList) {
      final item = i as Map;
      if (item['menuCode']?.toString() == code) return item;
    }
    return null;
  }

  /// 普通注文是否可进入下一步：
  /// 1. 必须选中汤底
  /// 2. 有规格时须已在 OptionView 确认（soupOptionsConfirmed）
  bool get canConfirmNormalOrder {
    if (normalOrderSubmitting.value) return false;
    final selectedCode = selectedOptionMenuCode.value;
    // 订阅弹窗确认与选项文案，保证 Obx 刷新
    final confirmed = soupOptionsConfirmed.value;
    final _ = selectedSoupOptionMsg.value;
    final __ = selectedSoupOptionCodes.length;
    if (selectedCode.isEmpty) return false;

    final selectedItem = selectedOptionMenuItem;
    if (selectedItem == null) return false;

    if (_soupHasChoosableOptions(selectedItem)) {
      return confirmed;
    }
    return true;
  }

  /// 校验失败时返回提示文案；通过返回 null
  String? get normalOrderValidationMessage {
    final selectedCode = selectedOptionMenuCode.value;
    if (selectedCode.isEmpty) return '请先选择汤底';

    final selectedItem = selectedOptionMenuItem;
    if (selectedItem == null) return '请先选择汤底';

    if (_soupHasChoosableOptions(selectedItem) &&
        !soupOptionsConfirmed.value) {
      return 'spicy_soup_select_options'.tr;
    }
    return null;
  }

  /// 普通注文：确认选项，分两条入购物车（对照扫码模式）
  ///   1. 口味商品（optionMenuList 选中项）+ 子选项（辣度、加料等）→ 独立商品
  ///   2. 称重商品（HUNDRED_GRAM）→ 独立商品，无选项
  ///   3. 称重金额达到満額贈呈门槛时，弹窗选择 freeGift 赠品（OptionView）
  Future<void> confirmNormalOrder() async {
    if (normalOrderSubmitting.value || _giftDialogShowing) return;
    if (normalWeighResult.isEmpty) return;
    final validationMsg = normalOrderValidationMessage;
    if (validationMsg != null) {
      showToast(validationMsg);
      return;
    }

    final itemData = normalWeighResult['itemData'];
    if (itemData is! Map) {
      showToast('称重数据异常，请重新称重');
      return;
    }
    final weight = (normalWeighResult['weight'] is num)
        ? (normalWeighResult['weight'] as num).toDouble()
        : double.tryParse('${normalWeighResult['weight']}') ?? 0;
    final price = (normalWeighResult['price'] is num)
        ? (normalWeighResult['price'] as num).toInt()
        : int.tryParse('${normalWeighResult['price']}') ?? 0;
    final unitPricePer100g = (normalWeighResult['unitPricePer100g'] is num)
        ? (normalWeighResult['unitPricePer100g'] as num).toInt()
        : int.tryParse('${normalWeighResult['unitPricePer100g']}') ?? 0;
    if (weight <= 0 || price <= 0) {
      showToast('重量无效，请重新称重');
      return;
    }

    final cartItems = <Map<String, dynamic>>[];

    // --- 1. 组装口味商品 ---
    final selectedItem = selectedOptionMenuItem;
    if (selectedItem != null) {
      final subCodes = selectedSoupOptionCodes.isNotEmpty
          ? selectedSoupOptionCodes.toList()
          : <String>[
              for (final entry in normalOptionSelections.entries) ...entry.value
            ];
      final linePrice = selectedSoupTotalPrice.value > 0
          ? selectedSoupTotalPrice.value
          : (selectedItem['currentPrice'] ?? 0);
      cartItems.add({
        'menuCode': selectedItem['menuCode'] ?? '',
        'mainTitle': selectedItem['mainTitle'] ?? '',
        'image': selectedItem['homeImage'] ?? selectedItem['image'] ?? '',
        'currentPrice': linePrice,
        'unitPrice': linePrice,
        'optionGroupVoList': subCodes.join(','),
        'optionVoListMsg': _buildNormalOptionVoListMsg(),
        'goodsNum': 1,
        'qtyBounds': selectedItem['qtyBounds'] ?? 0,
        'itemType': 'spicy',
      });
    }

    // --- 2. 组装称重商品 ---
    cartItems
        .add(_buildWeighCartItem(itemData, weight, price, unitPricePer100g));

    // --- 3. 满额赠品：达到门槛则弹 OptionView（有规格）或直接入车（无规格）---
    if (await _shouldOfferFreeGift(price)) {
      final gift = Map<String, dynamic>.from(freeGiftMenuList.first as Map);
      final groups = gift['optionGroupVoList'];
      if (groups is List && groups.isNotEmpty) {
        _showFreeGiftOptionDialog(gift, cartItems);
        return;
      }
      cartItems.insert(
        0,
        _buildGiftCartItem(
          gift,
          gift['currentPrice'] ?? 0,
          '',
          '',
        ),
      );
    }

    await _finishNormalOrder(cartItems);
  }

  /// 称重金额是否达到満額贈呈门槛，且存在 freeGift 菜品
  Future<bool> _shouldOfferFreeGift(int weighPrice) async {
    if (freeGiftMenuList.isEmpty) return false;
    final threshold = await SpicyWeighSettings.loadGiftThresholdYen();
    if (threshold <= 0) return false;
    return weighPrice >= threshold;
  }

  /// 弹出赠品 OptionView（与菜单页规格弹窗一致）
  void _showFreeGiftOptionDialog(
    Map gift,
    List<Map<String, dynamic>> baseCartItems,
  ) {
    if (_giftDialogShowing) return;
    _giftDialogShowing = true;

    final optionInfo =
        List<dynamic>.from(gift['optionGroupVoList'] ?? const []);
    final itemPrice = gift['currentPrice'] ?? 0;
    final prepared = OptionView.prepareState(
      itemPrice: itemPrice is int ? itemPrice : int.tryParse('$itemPrice') ?? 0,
      optionInfo: optionInfo,
    );

    // 有图用图片选项卡，无图用标签（与菜单页 / 汤底页一致）
    final hasImage = optionInfo.any((g) {
      if (g is! Map) return false;
      final opts = g['optionVoList'];
      if (opts is! List) return false;
      return opts.any((o) {
        if (o is! Map) return false;
        final img =
            o['homeImage']?.toString() ?? o['image']?.toString() ?? '';
        return img.isNotEmpty;
      });
    });

    Get.generalDialog(
      pageBuilder: (_, __, ___) => OptionView(
        isLabel: !hasImage,
        languageKey: checkLanguage.value,
        itemPrice: itemPrice is int ? itemPrice : int.tryParse('$itemPrice') ?? 0,
        originalPrice: gift['price'] ?? itemPrice,
        optionInfo: optionInfo,
        mainTitle: gift['mainTitle'] ?? '',
        subtitle: _giftSubtitle(gift),
        preparedState: prepared,
        addToCartCallback: (price, options, optionTitle) async {
          // 有可选规格却未选时，不入车、不关弹窗
          if (!_giftOptionsSelected(gift, options)) {
            showToast('spicy_gift_select_option'.tr);
            return;
          }
          final optionsString =
              options.map((e) => e.toString()).toList().join(',');
          Get.back();
          final items = List<Map<String, dynamic>>.from(baseCartItems);
          items.insert(
            0,
            _buildGiftCartItem(gift, price, optionsString, optionTitle),
          );
          await _finishNormalOrder(items);
        },
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: Duration.zero,
      transitionBuilder: (_, __, ___, child) => child,
    ).whenComplete(() {
      _giftDialogShowing = false;
    });
  }

  List _giftSubtitle(Map gift) {
    final s = gift['subtitle'];
    if (s is List) return s;
    return const [];
  }

  /// 赠品有可选项时，必须至少选中一个 option 才允许入车
  bool _giftOptionsSelected(Map gift, List options) {
    final groups =
        (gift['optionGroupVoList'] as List?)?.whereType<Map>().toList() ?? [];
    if (groups.isEmpty) return true;

    final hasChoosable = groups.any((g) {
      final opts = g['optionVoList'];
      return opts is List && opts.isNotEmpty;
    });
    if (!hasChoosable) return true;

    return options.isNotEmpty;
  }

  Map<String, dynamic> _buildGiftCartItem(
    Map gift,
    dynamic price,
    String optionCodes,
    String optionTitle,
  ) {
    final p = price is int ? price : int.tryParse('$price') ?? 0;
    return {
      'menuCode': gift['menuCode'] ?? '',
      'mainTitle': gift['mainTitle'] ?? '',
      'image': gift['homeImage'] ?? gift['image'] ?? '',
      'currentPrice': p,
      'unitPrice': p,
      'optionGroupVoList': optionCodes,
      'optionVoListMsg': optionTitle,
      'goodsNum': 1,
      'qtyBounds': gift['qtyBounds'] ?? 0,
      'itemType': 'spicy',
    };
  }

  /// 写入购物车并进入菜单页选其他菜
  Future<void> _finishNormalOrder(List<Map<String, dynamic>> cartItems) async {
    if (normalOrderSubmitting.value) return;
    normalOrderSubmitting.value = true;
    try {
      await orderSqlController.addCartItemsAtomically(cartItems);
      await orderSqlController.getCardList();
      await updateTotalPrice();
    } catch (e, st) {
      logE('麻辣烫组合商品入购物车失败: $e\n$st');
      showToast('加入购物车失败，请重试');
      return;
    } finally {
      normalOrderSubmitting.value = false;
    }

    // offNamed 替换 ModeView（ModeView 出栈，controller 销毁，无需手动清状态）
    // 用 toNamed 的话 ModeView 留在栈中，后续 normalStep=0 的 Obx 重建会触发称重页被压入 MenuPage 上方
    Get.offNamed('/menu-page', arguments: menuPageArguments());
  }

  static bool _isFreeGiftItem(dynamic item) {
    if (item is! Map) return false;
    final v = item['freeGift'];
    return v == true || v == 1 || v == '1' || v == 'true';
  }

  /// 普通注文：取消选项，重新称重
  void cancelNormalWeigh() {
    if (isNormalMode && categoryMenuList.length == 1) {
      // 单商品：清空数据后直接重新打开称重页（不改 normalStep 避免多余 loading 中间页）
      normalWeighResult.clear();
      normalOptionSelections.clear();
      selectedOptionMenuCode.value = '';
      optionsDisplayMenuCode.value = '';
      _optionNameCache.clear();
      _optionGroupTitleCache.clear();
      _clearSoupSelectionExtras();
      showScaleDialogForItem(categoryMenuList.first as Map);
    } else {
      _resetNormalState();
    }
  }

  void _resetNormalState() {
    normalWeighResult.clear();
    normalOptionSelections.clear();
    selectedOptionMenuCode.value = '';
    optionsDisplayMenuCode.value = '';
    _optionNameCache.clear();
    _optionGroupTitleCache.clear();
    _clearSoupSelectionExtras();
    normalStep.value = 0;
  }

  // ==================== 选项相关 ====================

  /// 更新 scannedItem 中某选项组的选中状态
  void updateScannedItemOption(
      String groupKey, String optionCode, String optionName, bool isAdd) {
    final item = scannedItem;
    if (item.isEmpty) return;
    final optionGroupList = item['optionGroupVoList'] ?? [];
    if (optionGroupList is! List) return;

    final updatedGroups = <Map>[];
    for (var group in optionGroupList) {
      if (group is Map) {
        final groupCopy = Map<String, dynamic>.from(group);
        if (groupCopy['groupName'] == groupKey) {
          final optionList = (groupCopy['optionVoList'] ?? []) as List;
          for (var opt in optionList) {
            if (opt is Map && opt['optionCode'] == optionCode) {
              opt['checked'] = isAdd;
              opt['mainTitle'] = optionName;
            }
          }
          groupCopy['optionVoList'] = optionList;
        }
        updatedGroups.add(groupCopy);
      } else {
        updatedGroups.add(group);
      }
    }
    scannedItem['optionGroupVoList'] = updatedGroups;
    scannedItem.refresh();
    logI('选项更新: $groupKey -> $optionName, isAdd: $isAdd');
  }

  /// 从商品 Map 中提取已勾选的选项 codes/names
  /// names 格式与普通菜单一致：`组名:选项1,选项2`
  Map<String, List<String>> _extractSelectedOptions(Map item) {
    final optionGroupList = item['optionGroupVoList'];
    final List<String> codes = [];
    final List<String> nameParts = [];
    if (optionGroupList is List) {
      for (var group in optionGroupList) {
        if (group is! Map) continue;
        final groupTitle = group['groupName']?.toString() ??
            group['groupTitle']?.toString() ??
            '';
        final selectedTitles = <String>[];
        for (var opt in (group['optionVoList'] ?? [])) {
          if (opt is Map && opt['checked'] == true) {
            codes.add(opt['optionCode']?.toString() ?? '');
            final title = opt['mainTitle']?.toString() ?? '';
            if (title.isNotEmpty) selectedTitles.add(title);
          }
        }
        if (selectedTitles.isEmpty) continue;
        final titles = selectedTitles.join(',');
        nameParts.add(groupTitle.isNotEmpty ? '$groupTitle:$titles' : titles);
      }
    }
    return {'codes': codes, 'names': nameParts};
  }

  // ==================== 购物车 ====================

  Future<void> _addWeighItemToCart(
      Map itemData, double weight, int price, int unitPricePer100g,
      {List<String> optionCodes = const [],
      List<String> optionNames = const []}) async {
    await orderSqlController.addToCart(
        _buildWeighCartItem(
          itemData,
          weight,
          price,
          unitPricePer100g,
          optionCodes: optionCodes,
          optionNames: optionNames,
        ),
        checkItem: false);
    orderSqlController.getCardList();
    logI('称重商品入购物车: ${itemData["mainTitle"]}, ${weight}g, ¥$price');
  }

  Map<String, dynamic> _buildWeighCartItem(
      Map itemData, double weight, int price, int unitPricePer100g,
      {List<String> optionCodes = const [],
      List<String> optionNames = const []}) {
    return {
      'menuCode': itemData['menuCode'] ?? '',
      'mainTitle': itemData['mainTitle'] ?? '称重商品',
      'image': itemData['homeImage'] ?? itemData['image'] ?? '',
      'currentPrice': price,
      'unitPrice': unitPricePer100g,
      'optionGroupVoList': optionCodes.join(','),
      'optionVoListMsg': optionNames.join(','),
      'goodsNum': 1,
      'spicyGrams': weight.floor(),
      'qtyBounds': 0,
      'itemType': 'spicy',
    };
  }

  Future<void> updateTotalPrice() async {
    final row = await orderSqlController.getCartAllPrice();
    totalPrice.value =
        row != null ? (row['totalPrice'] as num? ?? 0).toInt() : 0;
  }

  // ==================== 分类与菜品加载 ====================

  Future<void> selectShopCategory() async {
    //change(null, status: RxStatus.loading());
    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": checkLanguage.value,
      "takeout": "2",
    };
    try {
      final val = await request('webBootIndexCategoryv2',
          method: 'POST',
          parameters: formData,
          timeout: const Duration(seconds: 15));
      var response = json.decode(val.toString());
      final categoryVoList = (response['data']['categoryVoList'] ?? []) as List;
      logI(
          '全部分类: ${categoryVoList.map((c) => "${c['categoryName']}/${c['businessType']}/${c['categoryCode']}").toList()}');
      if (categoryVoList.isNotEmpty) {
        // 优先取 businessType == SPICY_HOT_POT 的分类；否则取第一个
        final target = categoryVoList.firstWhere(
          (c) => (c as Map)['businessType'] == 'SPICY_HOT_POT',
          orElse: () => categoryVoList[0],
        ) as Map;
        selectedCategoryName.value = target['categoryName'] ?? '';
        await getShopCategoryMenu(target['categoryCode'] ?? '');
        change(null, status: RxStatus.success());
        // 普通注文单称重商品：success 后再进称重，底层显示准备页而非空白
        if (isNormalMode && categoryMenuList.length == 1) {
          final item = Map<String, dynamic>.from(categoryMenuList.first as Map);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showScaleDialogForItem(item);
          });
        }
      } else {
        change(null, status: RxStatus.error('暂无可用分类'));
      }
    } catch (e) {
      logE('获取分类失败: $e');
      change(null, status: RxStatus.error('获取分类失败'));
    }
  }

  Future<void> getShopCategoryMenu(String categoryCode) async {
    // 外带进麻辣烫时 currentMode 为 spicyHotPot，用 isTakeoutMode 保留外带语义
    final queryTakeout = machineInfo.isTakeoutMode ? "0" : "2";
    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": checkLanguage.value,
      "takeout": queryTakeout,
      "categoryCode": categoryCode,
    };
    try {
      final val = await request('webBootIndexMenuv3',
          method: 'POST',
          parameters: formData,
          timeout: const Duration(seconds: 15));
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          response['data'] != null) {
        categoryMenuList.clear();
        optionMenuList.clear();
        freeGiftMenuList.clear();
        final items = response['data'] as List;
        LogUtil.d(items);
        for (var item in items) {
          LogUtil.d(item);
          logI(
              '菜品: ${item['mainTitle']} priceType=${item['priceType']} freeGift=${item['freeGift']}');
          // 赠品不进称重列表、不进汤底列表，满额后单独弹窗
          if (_isFreeGiftItem(item)) {
            freeGiftMenuList.add(item);
            continue;
          }
          if (item['priceType'] == "HUNDRED_GRAM") {
            categoryMenuList.add(item);
          } else {
            optionMenuList.add(item);
          }
        }
        logI(
            '称重商品: ${categoryMenuList.length}, 选项商品: ${optionMenuList.length}, 赠品: ${freeGiftMenuList.length}');
        // 菜单到手后后台预缓存汤底图
        _precacheOptionImages();
      }

      //change(null, status: RxStatus.success());
    } on TimeoutException catch (_) {
      logE('获取菜品超时');
    } catch (e) {
      logE('获取菜品失败: $e');
    }
  }

  /// 预缓存汤底/选项商品图（磁盘缓存，二次进入更快）
  void _precacheOptionImages() {
    for (final raw in optionMenuList) {
      if (raw is! Map) continue;
      final url = (raw['homeImage'] ?? raw['image'] ?? '').toString().trim();
      if (url.isEmpty) continue;
      menuImageCacheManager.getSingleFile(url).then((_) {}, onError: (e, _) {
        logI('汤底图预缓存失败: $url, $e');
      });
    }
  }

  // ==================== 导航 ====================

  /// 进入菜单页时的路由参数（含盆号）
  Map<String, dynamic> menuPageArguments() {
    final args = <String, dynamic>{
      'checkLanguage': checkLanguage.value,
    };
    if (tableNo.value.isNotEmpty) {
      args['tableNo'] = tableNo.value;
    }
    return args;
  }

  void setTableNo(String code) {
    tableNo.value = code.trim();
    logI('麻辣烫盆号 tableNo=${tableNo.value}');
  }

  /// 称重页/弹窗：若开启扫盆码且尚无盆号，先弹窗扫码
  Future<SpicyBowlScanResult> ensureBowlScanned() async {
    final enabled = await SpicyWeighSettings.loadBowlScanEnabled();
    if (!enabled) return const SpicyBowlScanResult.proceed();
    if (tableNo.value.isNotEmpty) {
      return SpicyBowlScanResult.proceed(tableNo.value);
    }

    final result = await Get.dialog<SpicyBowlScanResult>(
      const SpicyBowlScanDialog(),
      barrierDismissible: false,
    );
    if (result == null) {
      // 异常关闭：视为返回
      return const SpicyBowlScanResult.back();
    }
    if (result.action == SpicyBowlScanAction.proceed &&
        (result.tableNo?.trim().isNotEmpty ?? false)) {
      setTableNo(result.tableNo!);
    }
    return result;
  }

  void goHome() {
    // Get.lazyPut 下 controller 随路由销毁，无需手动重置状态
    Get.offAllNamed('/checkout-page');
  }
}
