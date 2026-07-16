import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/machine_info.dart';
import '../../../controllers/order_sql_controller.dart';
import '../../../services/CustomLogerHandler.dart';
import '../../../services/HttpService.dart';
import '../../../services/showToast.dart';
import '../views/spicy_hot_pot_category_page.dart';
import '../views/spicy_hot_pot_weigh_dialog.dart';
import '../views/spicy_weigh_page.dart';

/// 麻辣烫模式主控制器（Flutter 3.44 初始版本）
///
/// 支持两种注文方式（系统设置 spicyHotPotOrderType）：
/// - scan：扫码注文 — 扫码 → 选口味选项 → 称重 → 入购物车
/// - normal：普通注文 — 称重 → 选汤底/口味 → 按选项组规则校验后入购物车
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
  bool _isSingleWeighPageOpen = false;

  // ==================== getter ====================

  bool get isNormalMode => machineInfo.spicyHotPotOrderType == 'normal';
  bool get isScannedItemEmpty => scannedItem.isEmpty;
  Map get scannedItemData => scannedItem;
  List get categoryMenuData => categoryMenuList;

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    checkLanguage.value = Get.arguments?['checkLanguage'] ?? 'JP';
    if (!isNormalMode) {
      itemFocusNode.requestFocus();
    }
    selectShopCategory();
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

  /// 跳过称重：切到券卖模式，直接进入普通菜单购商品（不入车、不选口味）
  /// 清掉麻辣烫相关页面，保留结账首页，使菜单返回回到首页而非麻辣烫页
  void skipWeighToSellMode() {
    logI('跳过称重，进入券卖模式');
    machineInfo.currentMode = MachineMode.sell;
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
    // optionMenuList 只有1个商品时自动选中，直接展示子选项
    if (optionMenuList.length == 1) {
      final code =
          (optionMenuList.first as Map)['menuCode']?.toString() ?? '';
      selectedOptionMenuCode.value = code;
      optionsDisplayMenuCode.value = code;
    }
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
      String groupKey, String optionCode, String optionName, bool isMulti) {
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
  }

  /// 普通注文：由 OptionListWidget / OptionWidget 回调更新选中状态
  void updateNormalOptionFromWidget(String groupKey, String optionCode,
      String optionName, bool isAdd, bool isMulti) {
    final current = List<String>.from(normalOptionSelections[groupKey] ?? []);
    if (isAdd) {
      if (!isMulti) current.clear();
      if (!current.contains(optionCode)) current.add(optionCode);
      _optionNameCache[optionCode] = optionName;
    } else {
      current.remove(optionCode);
      _optionNameCache.remove(optionCode);
    }
    normalOptionSelections[groupKey] = current;
    normalOptionSelections.refresh();
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

    // --- 1. 口味商品单独入购物车 ---
    final selectedItem = selectedOptionMenuItem;
    if (selectedItem != null) {
      final subCodes = <String>[];
      final subNames = <String>[];
      for (final entry in normalOptionSelections.entries) {
        for (final code in entry.value) {
          subCodes.add(code);
          subNames.add(_optionNameCache[code] ?? code);
        }
      }
      await orderSqlController.addToCart({
        'menuCode': selectedItem['menuCode'] ?? '',
        'mainTitle': selectedItem['mainTitle'] ?? '',
        'image': selectedItem['homeImage'] ?? selectedItem['image'] ?? '',
        'currentPrice': selectedItem['currentPrice'] ?? 0,
        'unitPrice': selectedItem['currentPrice'] ?? 0,
        'optionGroupVoList': subCodes.join(','),
        'optionVoListMsg': subNames.join(','),
        'goodsNum': 1,
        'qtyBounds': selectedItem['qtyBounds'] ?? 0,
        'itemType': 'spicy',
      }, checkItem: false);
      orderSqlController.getCardList();
    }

    // --- 2. 称重商品单独入购物车（无选项） ---
    await _addWeighItemToCart(itemData, weight, price, unitPricePer100g);
    await updateTotalPrice();

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
  Map<String, List<String>> _extractSelectedOptions(Map item) {
    final optionGroupList = item['optionGroupVoList'];
    final List<String> codes = [];
    final List<String> names = [];
    if (optionGroupList is List) {
      for (var group in optionGroupList) {
        if (group is! Map) continue;
        for (var opt in (group['optionVoList'] ?? [])) {
          if (opt is Map && opt['checked'] == true) {
            codes.add(opt['optionCode']?.toString() ?? '');
            names.add(opt['mainTitle']?.toString() ?? '');
          }
        }
      }
    }
    return {'codes': codes, 'names': names};
  }

  // ==================== 购物车 ====================

  Future<void> _addWeighItemToCart(
      Map itemData, double weight, int price, int unitPricePer100g,
      {List<String> optionCodes = const [],
      List<String> optionNames = const []}) async {
    await orderSqlController.addToCart({
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
      'weighUnitPricePer100g': unitPricePer100g.toString(),
    }, checkItem: false);
    orderSqlController.getCardList();
    logI('称重商品入购物车: ${itemData["mainTitle"]}, ${weight}g, ¥$price');
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
      } else {
        change(null, status: RxStatus.error('暂无可用分类'));
      }
    } catch (e) {
      logE('获取分类失败: $e');
      change(null, status: RxStatus.error('获取分类失败'));
    }
  }

  Future<void> getShopCategoryMenu(String categoryCode) async {
    final queryTakeout =
        machineInfo.currentMode == MachineMode.takeout ? "0" : "2";
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
          logI('菜品: ${item['mainTitle']} priceType=${item['priceType']}');
          if (item['priceType'] == "HUNDRED_GRAM") {
            categoryMenuList.add(item);
          } else {
            optionMenuList.add(item);
          }
        }
        logI(
            '称重商品: ${categoryMenuList.length}, 选项商品: ${optionMenuList.length}');
        // 导航由 view 的 _buildNormalCategoryView addPostFrameCallback 触发，此处无需重复
      }

      //change(null, status: RxStatus.success());
    } on TimeoutException catch (_) {
      logE('获取菜品超时');
    } catch (e) {
      logE('获取菜品失败: $e');
    }
  }

  // ==================== 导航 ====================

  void goHome() {
    // Get.lazyPut 下 controller 随路由销毁，无需手动重置状态
    Get.offAllNamed('/checkout-page');
  }
}
