import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodorder/app/services/logUtil.dart';
import 'package:get/get.dart';
import '../../../controllers/machine_info.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/HttpService.dart';
import '../../../services/showImage.dart';
import '../../../services/showToast.dart';
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

  // 称重商品分类列表（priceType == HUNDRED_GRAM）
  RxList categoryMenuList = [].obs;
  // 选项商品列表（非称重商品，普通注文模式下供用户勾选）
  RxList optionMenuList = [].obs;
  RxString selectedCategoryName = ''.obs;

  // 普通注文模式步骤：0=选择并称重，1=选择选项并确认
  RxInt normalStep = 0.obs;
  // 普通注文模式称重结果：{itemData, weight, price, unitPricePer100g}
  RxMap normalWeighResult = {}.obs;
  // 普通注文：选项页顶部大图卡片的选中商品 menuCode（即时反馈）
  RxString selectedOptionMenuCode = ''.obs;
  // 下方子选项展示用的 menuCode（延后一帧，避免拖慢大图点击）
  RxString optionsDisplayMenuCode = ''.obs;
  // 普通注文选项选择：groupKey → [已选optionCode]
  RxMap<String, List<String>> normalOptionSelections =
      <String, List<String>>{}.obs;
  // optionCode → optionName 映射（入购物车时取名称用）
  final Map<String, String> _optionNameCache = {};
  // groupKey → 分组显示名（入车 optionVoListMsg 用「组名:选项」）
  final Map<String, String> _optionGroupTitleCache = {};
  bool _isSingleWeighPageOpen = false;
  final RxBool normalOrderSubmitting = false.obs;

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
      arguments: {"checkLanguage": checkLanguage.value},
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
      Get.offNamed('/menu-page',
          arguments: {"checkLanguage": checkLanguage.value});
    } else {
      // 多商品用 Dialog，dialog 已自行 Get.back()，此处 push menu page 即可
      Get.toNamed('/menu-page',
          arguments: {"checkLanguage": checkLanguage.value});
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
    // optionMenuList 只有1个商品时自动选中，直接展示子选项
    if (optionMenuList.length == 1) {
      final code = (optionMenuList.first as Map)['menuCode']?.toString() ?? '';
      selectedOptionMenuCode.value = code;
      optionsDisplayMenuCode.value = code;
    }
    // 进入选项页前预拉汤底图，避免首次 Image 请求被重建打断
    _precacheOptionImages();
    normalStep.value = 1;
    // ModeView 始终在路由栈中（Get.to 不替换），设好 normalStep 后
    // 由 SpicyWeighPage._confirm() / SpicyWeighDialog._confirm() 调 Get.back() 返回
    // ModeView 的 Obx 监听到 normalStep=1，自动切换到选项视图
  }

  /// 普通注文：选中 optionMenuList 中的一个商品（顶部大图卡片）
  /// 大图选中态即时更新；子选项延后一帧再挂载，且不先清空，避免闪烁
  void selectOptionMenuItem(String menuCode) {
    if (selectedOptionMenuCode.value == menuCode) return;
    normalOptionSelections.clear();
    _optionNameCache.clear();
    _optionGroupTitleCache.clear();
    // 即时高亮大图；下方选项保留旧内容直到下一帧换新，避免空白闪一下
    selectedOptionMenuCode.value = menuCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedOptionMenuCode.value == menuCode) {
        optionsDisplayMenuCode.value = menuCode;
      }
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
  /// 1. 必须选中汤底（optionMenuList）
  /// 2. 若该汤底下有选项组，按各组规则校验：
  ///    - smallest：最少必选数量（未达则不可下一步）
  ///    - multipleState：最多可选数量（超出则不可下一步）
  bool get canConfirmNormalOrder {
    if (normalOrderSubmitting.value) return false;
    // 显式读取，确保 Obx 能追踪选中态变化
    final selectedCode = selectedOptionMenuCode.value;
    final selections = normalOptionSelections;
    if (selectedCode.isEmpty) return false;

    Map? selectedItem;
    for (final i in optionMenuList) {
      final item = i as Map;
      if (item['menuCode']?.toString() == selectedCode) {
        selectedItem = item;
        break;
      }
    }
    if (selectedItem == null) return false;

    final groups =
        (selectedItem['optionGroupVoList'] as List?)?.whereType<Map>().toList();
    if (groups == null || groups.isEmpty) {
      // 无子选项组：选中汤底即可
      return true;
    }

    for (final group in groups) {
      final options =
          (group['optionVoList'] as List?)?.whereType<Map>().toList() ?? [];
      if (options.isEmpty) continue;

      final groupName = group['groupName']?.toString() ?? '';
      final groupKey = group['groupCode']?.toString().isNotEmpty == true
          ? group['groupCode'].toString()
          : groupName;
      final selectedCount = (selections[groupKey] ?? <String>[]).length;

      // 与菜单页 OptionView 一致：smallest=最少必选，multipleState=最多可选
      final minNum = int.tryParse((group['smallest'] ?? '0').toString()) ?? 0;
      final maxNum =
          int.tryParse((group['multipleState'] ?? '1').toString()) ?? 1;

      if (selectedCount < minNum) return false;
      if (maxNum > 0 && selectedCount > maxNum) return false;
    }
    return true;
  }

  /// 校验失败时返回提示文案；通过返回 null
  String? get normalOrderValidationMessage {
    final selectedCode = selectedOptionMenuCode.value;
    if (selectedCode.isEmpty) return '请先选择汤底';

    Map? selectedItem;
    for (final i in optionMenuList) {
      final item = i as Map;
      if (item['menuCode']?.toString() == selectedCode) {
        selectedItem = item;
        break;
      }
    }
    if (selectedItem == null) return '请先选择汤底';

    final groups =
        (selectedItem['optionGroupVoList'] as List?)?.whereType<Map>().toList();
    if (groups == null || groups.isEmpty) return null;

    for (final group in groups) {
      final options =
          (group['optionVoList'] as List?)?.whereType<Map>().toList() ?? [];
      if (options.isEmpty) continue;

      final groupName = group['groupName']?.toString() ?? '';
      final groupKey = group['groupCode']?.toString().isNotEmpty == true
          ? group['groupCode'].toString()
          : groupName;
      final selectedCount =
          (normalOptionSelections[groupKey] ?? <String>[]).length;
      final minNum = int.tryParse((group['smallest'] ?? '0').toString()) ?? 0;
      final maxNum =
          int.tryParse((group['multipleState'] ?? '1').toString()) ?? 1;

      if (selectedCount < minNum) {
        return 'menu_option_less_smallest'
            .tr
            .replaceAll('%%', groupName.isNotEmpty ? groupName : '选项');
      }
      if (maxNum > 0 && selectedCount > maxNum) {
        return 'menu_option_more_multipleState'
            .tr
            .replaceAll('%%', groupName.isNotEmpty ? groupName : '选项');
      }
    }
    return null;
  }

  /// 普通注文：确认选项，分两条入购物车（对照扫码模式）
  ///   1. 口味商品（optionMenuList 选中项）+ 子选项（辣度、加料等）→ 独立商品
  ///   2. 称重商品（HUNDRED_GRAM）→ 独立商品，无选项
  Future<void> confirmNormalOrder() async {
    if (normalOrderSubmitting.value) return;
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
      final subCodes = <String>[];
      for (final entry in normalOptionSelections.entries) {
        subCodes.addAll(entry.value);
      }
      cartItems.add({
        'menuCode': selectedItem['menuCode'] ?? '',
        'mainTitle': selectedItem['mainTitle'] ?? '',
        'image': selectedItem['homeImage'] ?? selectedItem['image'] ?? '',
        'currentPrice': selectedItem['currentPrice'] ?? 0,
        'unitPrice': selectedItem['currentPrice'] ?? 0,
        'optionGroupVoList': subCodes.join(','),
        // 与普通商品一致：组名:选项名
        'optionVoListMsg': _buildNormalOptionVoListMsg(),
        'goodsNum': 1,
        'qtyBounds': selectedItem['qtyBounds'] ?? 0,
        'itemType': 'spicy',
      });
    }

    // --- 2. 组装称重商品，并与口味商品在同一事务中写入 ---
    cartItems
        .add(_buildWeighCartItem(itemData, weight, price, unitPricePer100g));

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
    Get.offNamed('/menu-page',
        arguments: {"checkLanguage": checkLanguage.value});
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
      'spicyGrams': weight.toInt(),
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
        final items = response['data'] as List;
        for (var item in items) {
          LogUtil.d(item);
          logI('菜品: ${item['mainTitle']} priceType=${item['priceType']}');
          if (item['priceType'] == "HUNDRED_GRAM") {
            categoryMenuList.add(item);
          } else {
            optionMenuList.add(item);
          }
        }
        logI(
            '称重商品: ${categoryMenuList.length}, 选项商品: ${optionMenuList.length}');
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

  void goHome() {
    // Get.lazyPut 下 controller 随路由销毁，无需手动重置状态
    Get.offAllNamed('/checkout-page');
  }
}
