import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import 'package:foodorder/app/modules/menuPage/views/option_widgets/option_list.dart';
import '../../../widget/KioskTap.dart';
import '../controllers/spicy_hot_pot_checkout_controller.dart';
import 'widgets/spicy_hot_pot_chrome.dart';

// 设计色彩常量（参考效果图）
const _kBg = Color(0xFFF5F5F5);
const _kRed = Color(0xFF44C2B8);
const _kPrice = Color(0xFFE64340);
const _kText = Color(0xFF333333);
const _kGrey = Color(0xFF666666);
const _kCard = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFDCDCDC);

/// 麻辣烫模式主视图
///
/// 扫码注文：扫码 → 展示商品+选项 → 下一步 → 称重 → 入购物车
/// 普通注文：展示称重商品列表 → 称重 → 展示选项 → 确认 → 入购物车
///
/// [directCtrl]：当通过 Get.off() 导航（controller 已从 GetX 注册表移除）时
/// 直接传入 controller 实例，避免 Get.find() 抛出异常。
class SpicyHotPotModeView extends StatelessWidget {
  final SpicyHotPotCheckoutController? directCtrl;
  const SpicyHotPotModeView({Key? key, this.directCtrl}) : super(key: key);

  SpicyHotPotCheckoutController get _ctrl =>
      directCtrl ?? Get.find<SpicyHotPotCheckoutController>();

  @override
  Widget build(BuildContext context) {
    final ctrl = _ctrl;
    return ctrl.obx(
      (_) => _buildBody(ctrl),
      onLoading: _buildPreparingPage(),
      onError: (err) => Scaffold(
        backgroundColor: _kBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: _kRed, size: 48),
              const SizedBox(height: 12),
              Text(err ?? '読み込み失敗',
                  style: const TextStyle(color: _kText, fontSize: 16)),
              const SizedBox(height: 16),
              TextButton(
                onPressed: ctrl.goHome,
                child: Text('settlement_back'.tr, style: TextStyle(color: _kRed)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 拉菜单/跳转称重前的过渡页：带步骤条，避免空白白屏
  Widget _buildPreparingPage() {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const SpicyHotPotStepHeader(currentStep: 2),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_kRed),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: ScreenAdapter.height(28)),
                  Text(
                    'spicy_mode_preparing'.tr,
                    style: TextStyle(
                      color: _kGrey,
                      fontSize: ScreenAdapter.fontSize(28),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SpicyHotPotCheckoutController ctrl) {
    // 扫码模式不依赖 normalStep 路由，避免外层 Obx 无意义订阅
    if (!ctrl.isNormalMode) {
      return Scaffold(
        backgroundColor: _kBg,
        body: Column(
          children: [
            _buildTopBar(ctrl),
            Expanded(child: _buildScanOrderView(ctrl)),
          ],
        ),
      );
    }

    // 普通注文：必须先读 .obs，禁止用 && 短路导致 Obx 无订阅崩溃
    return Obx(() {
      final normalStep = ctrl.normalStep.value;
      final menuCount = ctrl.categoryMenuList.length;
      final isOptionStep = normalStep == 1;
      // 单称重商品：控制器已负责跳转称重页，此处只展示准备页，不再画空白 Scaffold
      if (normalStep == 0 && menuCount == 1) {
        return _buildPreparingPage();
      }
      if (isOptionStep) {
        return Scaffold(
          backgroundColor: _kBg,
          body: _buildNormalOptionView(ctrl),
        );
      }
      return Scaffold(
        backgroundColor: _kBg,
        body: Column(
          children: [
            _buildTopBar(ctrl),
            Expanded(child: _buildNormalCategoryView(ctrl)),
          ],
        ),
      );
    });
  }

  // ==================== 顶部导航栏 ====================

  Widget _buildTopBar(SpicyHotPotCheckoutController ctrl) {
    return Container(
      height: ScreenAdapter.height(100),
      padding: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(30)),
      color: Gcolor.primaryColor,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back,
                color: Colors.white, size: ScreenAdapter.fontSize(44)),
            // onPressed 点击时读 normalStep.value（无需 Obx，按钮外观不变）
            // 普通注文选项步骤：返回称重页重新选；其他：回首页
            onPressed: () => (ctrl.isNormalMode && ctrl.normalStep.value == 1)
                ? ctrl.cancelNormalWeigh()
                : ctrl.goHome(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              '麻辣烫自助点餐',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: ScreenAdapter.fontSize(40),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: ScreenAdapter.width(60)),
        ],
      ),
    );
  }

  // ==================== 内容区路由 ====================

  // ==================== 步骤指示器 ====================

  Widget _buildStepIndicator(int currentStep) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 4; i++) ...[
          if (i > 1)
            Container(
              width: ScreenAdapter.width(44),
              height: 1.5,
              margin: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(2)),
              color: _kBorder,
            ),
          Container(
            width: ScreenAdapter.width(50),
            height: ScreenAdapter.width(50),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < currentStep
                  ? const Color(0xFF4CAF50)
                  : i == currentStep
                      ? _kRed
                      : Colors.transparent,
              border: (i >= currentStep)
                  ? Border.all(
                      color: i == currentStep ? _kRed : _kBorder, width: 1.5)
                  : null,
            ),
            child: Center(
              child: i < currentStep
                  ? Icon(Icons.check,
                      color: Colors.white, size: ScreenAdapter.fontSize(22))
                  : Text(
                      '$i',
                      style: TextStyle(
                        color: i == currentStep
                            ? Colors.white
                            : const Color(0xFFAA9E8E),
                        fontSize: ScreenAdapter.fontSize(22),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  // ==================== 普通注文模式 ====================

  /// 普通注文第0步：选择称重商品（多称重商品时展示；单商品由控制器直接进称重页）
  Widget _buildNormalCategoryView(SpicyHotPotCheckoutController ctrl) {
    return Column(
      children: [
        // 步骤提示头部
        Container(
          color: _kCard,
          padding: EdgeInsets.fromLTRB(
            ScreenAdapter.width(36),
            ScreenAdapter.height(22),
            ScreenAdapter.width(36),
            ScreenAdapter.height(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STEP 01 · 取菜称重',
                      style: TextStyle(
                        color: _kRed,
                        fontSize: ScreenAdapter.fontSize(22),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    SizedBox(height: ScreenAdapter.height(4)),
                    Obx(() {
                      // 显式读 .value，保证 Obx 始终有订阅
                      final name = ctrl.selectedCategoryName.value;
                      return Text(
                        name.isNotEmpty ? name : '商品を選んでください',
                        style: TextStyle(
                          color: _kText,
                          fontSize: ScreenAdapter.fontSize(32),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              _buildStepIndicator(1),
            ],
          ),
        ),
        Container(height: 1, color: _kBorder),
        // 商品网格
        Expanded(
          child: Obx(() {
            // 先读 length，确保空列表时也有订阅
            final menuCount = ctrl.categoryMenuList.length;
            if (menuCount == 0) {
              return Center(
                child: Text(
                  '称重商品なし',
                  style: TextStyle(
                      color: _kGrey, fontSize: ScreenAdapter.fontSize(28)),
                ),
              );
            }
            final items = ctrl.categoryMenuList.toList();
            return GridView.builder(
              padding: EdgeInsets.all(ScreenAdapter.width(16)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: ScreenAdapter.height(12),
                crossAxisSpacing: ScreenAdapter.width(12),
                childAspectRatio: 0.68,
              ),
              itemCount: items.length,
              itemBuilder: (_, i) => _buildCategoryCard(items[i] as Map, ctrl),
            );
          }),
        ),
        _buildBottomBar(ctrl),
      ],
    );
  }

  Widget _buildCategoryCard(Map item, SpicyHotPotCheckoutController ctrl) {
    final title = item['mainTitle'] ?? '';
    final price = (item['currentPrice'] ?? 0).toString();
    final img = item['homeImage'] ?? '';

    return KioskTap(
      onTap: () {
        if (item['priceType'] == 'HUNDRED_GRAM') {
          ctrl.showScaleDialogForItem(item);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder, width: 1),
          boxShadow: const [
            BoxShadow(
                color: Color(0x10000000), blurRadius: 6, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: img.isNotEmpty
                    ? publicShowMenuImage(
                        imgPath: img, imgWidth: 300, imgHeight: 380)
                    : Container(
                        color: const Color(0xFFF0EBE0),
                        child: Center(
                          child: Icon(Icons.restaurant_menu,
                              color: _kGrey, size: ScreenAdapter.fontSize(56)),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenAdapter.width(12),
                ScreenAdapter.height(8),
                ScreenAdapter.width(12),
                ScreenAdapter.height(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _kText,
                      fontSize: ScreenAdapter.fontSize(24),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(4)),
                  Text(
                    '¥$price / 100g',
                    style: TextStyle(
                      color: _kPrice,
                      fontSize: ScreenAdapter.fontSize(22),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w700,
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

  /// 普通注文第1步：选项选择
  /// 顶部卡片与下方选项组分开监听，避免选中时整页重建导致卡顿
  Widget _buildNormalOptionView(SpicyHotPotCheckoutController ctrl) {
    return Column(
      children: [
        const SpicyHotPotStepHeader(currentStep: 3),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              ScreenAdapter.width(32),
              ScreenAdapter.height(24),
              ScreenAdapter.width(32),
              ScreenAdapter.height(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'spicy_soup_title'.tr,
                  style: TextStyle(
                    color: _kText,
                    fontSize: ScreenAdapter.fontSize(40),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(6)),
                Text(
                  'spicy_soup_subtitle'.tr,
                  style: TextStyle(
                    color: _kGrey,
                    fontSize: ScreenAdapter.fontSize(22),
                    fontFamily: GFont.getFontFamily(),
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(20)),
                if (ctrl.optionMenuList.isNotEmpty)
                  _buildOptionItemCards(ctrl.optionMenuList, ctrl),
                _buildNormalSelectedOptionsSection(ctrl),
              ],
            ),
          ),
        ),
        _buildNormalOptionButtons(ctrl),
      ],
    );
  }

  /// 选中汤底后的子选项（辣度等）
  Widget _buildNormalSelectedOptionsSection(
      SpicyHotPotCheckoutController ctrl) {
    return Obx(() {
      final selectedCode = ctrl.optionsDisplayMenuCode.value;
      // 订阅选项列表，切换汤底数据时也能刷新
      final optionCount = ctrl.optionMenuList.length;
      if (selectedCode.isEmpty || optionCount == 0) {
        return const SizedBox.shrink();
      }

      Map? selectedItem;
      for (final i in ctrl.optionMenuList) {
        if ((i as Map)['menuCode']?.toString() == selectedCode) {
          selectedItem = i;
          break;
        }
      }
      if (selectedItem == null) return const SizedBox.shrink();

      final groups = _flattenOptionGroups([selectedItem]);
      final soupName = selectedItem['mainTitle']?.toString() ?? '';

      return Column(
        key: ValueKey('options-$selectedCode'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenAdapter.height(28)),
          if (groups.isEmpty)
            Center(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: ScreenAdapter.height(24)),
                child: Text(
                  'spicy_soup_no_extra_option'.tr,
                  style: TextStyle(
                    color: _kGrey,
                    fontSize: ScreenAdapter.fontSize(24),
                    fontFamily: GFont.getFontFamily(),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                ScreenAdapter.width(20),
                ScreenAdapter.height(18),
                ScreenAdapter.width(20),
                ScreenAdapter.height(12),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    soupName.isNotEmpty
                        ? 'spicy_soup_options_for'
                            .trParams({'name': soupName})
                        : 'spicy_soup_select_options'.tr,
                    style: TextStyle(
                      color: _kText,
                      fontSize: ScreenAdapter.fontSize(26),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(12)),
                  ...groups.asMap().entries.map((e) =>
                      _buildNormalOptionGroupWidget(
                          e.value, e.key + 1, ctrl, selectedCode)),
                ],
              ),
            ),
        ],
      );
    });
  }

  /// 汤底卡片：间距减半、每行最多 4 个，图片 BoxFit.cover 填满方格
  Widget _buildOptionItemCards(List items, SpicyHotPotCheckoutController ctrl) {
    return Obx(() {
      final selectedCode = ctrl.selectedOptionMenuCode.value;
      // 保持对选中码的订阅（即使 items 为空也不至于无 obs）
      return LayoutBuilder(
        builder: (context, constraints) {
          final count = items.length;
          // 每行最多 4 个；少于 4 个则按实际数量均分（图更大）
          final columns = count <= 0 ? 1 : (count > 4 ? 4 : count);
          // 原间距 16，减半
          final spacing = ScreenAdapter.width(8);
          final runSpacing = ScreenAdapter.height(8);
          final cardWidth =
              (constraints.maxWidth - spacing * (columns - 1)) / columns;
          // 图片贴满卡片宽，subtitle 才能左右下齐平无空隙
          final hPad = 0.0;
          final imageSize = cardWidth.clamp(100.0, 320.0);

          return Wrap(
            spacing: spacing,
            runSpacing: runSpacing,
            children: List.generate(count, (index) {
              final item = items[index] as Map;
              final code = item['menuCode']?.toString() ?? '';
              final name = item['mainTitle']?.toString() ?? '';
              final subtitle = _optionItemSubtitle(item);
              final img = item['homeImage']?.toString() ??
                  item['image']?.toString() ??
                  '';
              final isSelected = selectedCode == code;
              final isRecommend = index == 0;

              return KioskTap(
                onTap: () => ctrl.selectOptionMenuItem(code),
                debounceDuration: const Duration(milliseconds: 120),
                child: Container(
                  width: cardWidth,
                  padding: EdgeInsets.only(
                    top: ScreenAdapter.height(0),
                    bottom: ScreenAdapter.height(18),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFEAF8F7) : _kCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? _kRed : _kBorder,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 图片顶满；subtitle 贴底左右齐平
                          SizedBox(
                            width: imageSize,
                            height: imageSize,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                img.isNotEmpty
                                    ? CachedNetworkImage(
                                        key: ValueKey(img),
                                        imageUrl: img,
                                        cacheManager: menuImageCacheManager,
                                        fit: BoxFit.cover,
                                        width: imageSize,
                                        height: imageSize,
                                        fadeInDuration: Duration.zero,
                                        fadeOutDuration: Duration.zero,
                                        memCacheWidth:
                                            (imageSize * 2).round().clamp(1, 1400),
                                        memCacheHeight:
                                            (imageSize * 2).round().clamp(1, 1400),
                                        placeholder: (_, __) =>
                                            _buildOptionItemPlaceholder(
                                                isSelected),
                                        errorWidget: (_, __, ___) =>
                                            _buildOptionItemPlaceholder(
                                                isSelected),
                                      )
                                    : _buildOptionItemPlaceholder(isSelected),
                                if (subtitle.isNotEmpty)
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: ScreenAdapter.width(8),
                                        vertical: ScreenAdapter.height(4),
                                      ),
                                      color: const Color.fromARGB(
                                          169, 255, 255, 255),
                                      child: Text(
                                        subtitle,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(18),
                                          fontWeight: FontWeight.w500,
                                          fontFamily: GFont.getFontFamily(),
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.itemSubTitleColor),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: ScreenAdapter.height(16)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenAdapter.width(4),
                            ),
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? _kRed : _kText,
                                fontSize: ScreenAdapter.fontSize(24),
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isRecommend)
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: ScreenAdapter.width(8),
                              vertical: ScreenAdapter.height(3),
                            ),
                            decoration: BoxDecoration(
                              color: _kRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'spicy_soup_recommend'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenAdapter.fontSize(14),
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          );
        },
      );
    });
  }

  /// 解析汤底商品副标题（兼容 string / list，与菜单字段一致）
  String _optionItemSubtitle(Map item) {
    final raw = item['subtitle'] ?? item['subTitle'] ?? item['remark'];
    if (raw == null) return '';
    if (raw is List) {
      return raw
          .map((e) => e?.toString().trim() ?? '')
          .where((e) => e.isNotEmpty)
          .join(' ');
    }
    return raw.toString().trim();
  }

  Widget _buildOptionItemPlaceholder(bool isSelected) {
    return Container(
      color: isSelected ? const Color(0xFFD8F0ED) : const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(
          Icons.ramen_dining,
          size: ScreenAdapter.fontSize(64),
          color: isSelected ? _kRed : const Color(0xFFBDBDBD),
        ),
      ),
    );
  }

  /// 将 optionMenuList 中各 item 的 optionGroupVoList 展平为分组列表
  /// 若 item 无 optionGroupVoList，则将 item 本身包装成一个分组
  List<Map> _flattenOptionGroups(List items) {
    final result = <Map>[];
    for (final item in items) {
      final groups =
          (item['optionGroupVoList'] as List?)?.whereType<Map>().toList();
      if (groups != null && groups.isNotEmpty) {
        for (final g in groups) {
          result.add({...g, '_parentMenuCode': item['menuCode'] ?? ''});
        }
      } else {
        // 没有子选项组：item 本身即为一个可选项，包装成单选组
        result.add({
          'groupName': item['mainTitle'] ?? '',
          'groupCode': item['menuCode'] ?? '',
          'multipleState': '1',
          'optionVoList': [item],
          '_isDirectItem': true,
        });
      }
    }
    return result;
  }

  /// 普通注文选项组：复用 OptionListWidget / OptionWidget 样式
  /// 注意：不在此处读取 normalOptionSelections，避免点子选项时整段 Obx 重建
  Widget _buildNormalOptionGroupWidget(Map group, int index,
      SpicyHotPotCheckoutController ctrl, String selectedMenuCode) {
    final groupName = group['groupName']?.toString() ?? '';
    final groupRemark = group['remark']?.toString() ?? '';
    final groupKey = group['groupCode']?.toString().isNotEmpty == true
        ? group['groupCode'].toString()
        : groupName;
    final options =
        (group['optionVoList'] as List?)?.whereType<Map>().toList() ?? [];
    final multipleState = (group['multipleState'] ?? '1').toString();
    final isMulti = multipleState != '1';

    // 有图用图片选项卡，无图用标签按钮（与菜单页 OptionWidget 一致）
    final hasImage = options.any((o) {
      final img = o['homeImage']?.toString() ?? o['image']?.toString() ?? '';
      return img.isNotEmpty;
    });

    // 初始 checked 一律 false；选中态由 OptionListWidget 内部维护
    final optionListInfo = options.map((opt) {
      final code =
          opt['optionCode']?.toString() ?? opt['menuCode']?.toString() ?? '';
      return {
        ...opt,
        'optionCode': code,
        'group': groupKey,
        'mainTitle': opt['mainTitle'] ?? '',
        'homeImage': opt['homeImage'] ?? opt['image'] ?? '',
        'currentPrice': opt['currentPrice'] ?? 0,
        'checked': false,
      };
    }).toList();

    final titleLabel =
        isMulti ? '$index. $groupName（可多选）' : '$index. $groupName';

    return Container(
      margin: EdgeInsets.only(bottom: ScreenAdapter.height(16)),
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(12),
        vertical: ScreenAdapter.height(10),
      ),
      decoration: BoxDecoration(
        color: ColorsUtil.hexToColor('#FAFAFA'),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorsUtil.hexToColor('#ECEFED'), width: 1),
      ),
      // Key 随选中商品变化，切换口味时重建 OptionListWidget 内部选中态
      child: OptionListWidget(
        key: ValueKey('$selectedMenuCode-$groupKey'),
        isLabel: !hasImage,
        languageKey: ctrl.checkLanguage.value,
        optionListInfo: optionListInfo,
        optionSelectMaxNum: multipleState,
        title: titleLabel,
        subTitle: groupRemark,
        onSelected:
            (gCode, optionCode, optionName, optionPrice, isAdd, isSelected) {
          ctrl.updateNormalOptionFromWidget(
              groupKey, optionCode, optionName, isAdd, isMulti,
              groupTitle: groupName);
        },
      ),
    );
  }

  /// 普通注文步骤1底部按钮
  Widget _buildNormalOptionButtons(SpicyHotPotCheckoutController ctrl) {
    return Obx(() {
      // 强制订阅选中态与选项选择，避免 getter 内部短路导致 Obx 无订阅
      final _ = ctrl.selectedOptionMenuCode.value;
      final __ = ctrl.normalOptionSelections.length;
      final canNext = ctrl.canConfirmNormalOrder;
      return SpicyHotPotBottomBar(
        onBack: () => ctrl.cancelNormalWeigh(),
        backLabel: 'settlement_back'.tr,
        onNext: canNext ? () => ctrl.confirmNormalOrder() : null,
        nextLabel: 'next_button'.tr,
        nextEnabled: canNext,
      );
    });
  }

  // ==================== 扫码注文模式 ====================

  Widget _buildScanOrderView(SpicyHotPotCheckoutController ctrl) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) ctrl.itemFocusNode.requestFocus();
      },
      child: Obx(() {
        // 显式读 length，确保空购物扫码态也有订阅（避免 RxMap.isEmpty 未注册）
        final scannedCount = ctrl.scannedItem.length;
        final hasScannedItem = scannedCount > 0;
        final canNext = hasScannedItem && _hasSelectedOption(ctrl);

        if (!hasScannedItem) {
          return Container(
            color: _kBg,
            child: Center(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenAdapter.width(54)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildEmptyScanPrompt(),
                    SizedBox(height: ScreenAdapter.height(50)),
                    _buildScanInput(ctrl),
                  ],
                ),
              ),
            ),
          );
        }

        return Container(
          color: _kBg,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  ScreenAdapter.width(54),
                  ScreenAdapter.height(24),
                  ScreenAdapter.width(54),
                  ScreenAdapter.height(12),
                ),
                child: _buildScanInput(ctrl),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: ScreenAdapter.width(54),
                      vertical: ScreenAdapter.height(12)),
                  child: Column(
                    children: [
                      _buildScannedItemCard(ctrl),
                      SizedBox(height: ScreenAdapter.height(24)),
                      _buildNextButton(ctrl, canNext),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(ctrl),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEmptyScanPrompt() {
    return Column(
      children: [
        Container(
          width: ScreenAdapter.width(170),
          height: ScreenAdapter.width(170),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border:
                Border.all(color: ColorsUtil.hexToColor('#DDE8E6'), width: 2),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 16,
                  offset: Offset(0, 6))
            ],
          ),
          child: Icon(Icons.qr_code_scanner,
              color: Gcolor.primaryColor, size: ScreenAdapter.fontSize(84)),
        ),
        SizedBox(height: ScreenAdapter.height(34)),
        Text(
          '请扫描商品码',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _kText,
            fontSize: ScreenAdapter.fontSize(48),
            fontFamily: GFont.getFontFamily(),
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: ScreenAdapter.height(14)),
        Text(
          '商品読取後、ここに商品と選択項目が表示されます',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _kGrey,
            fontSize: ScreenAdapter.fontSize(26),
            fontFamily: GFont.getFontFamily(),
          ),
        ),
      ],
    );
  }

  Widget _buildScanInput(SpicyHotPotCheckoutController ctrl) {
    final hasScannedItem = !ctrl.isScannedItemEmpty;
    return Container(
      width: ScreenAdapter.width(760),
      height: ScreenAdapter.height(86),
      padding: EdgeInsets.symmetric(horizontal: ScreenAdapter.width(22)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: hasScannedItem
              ? Gcolor.primaryColor
              : ColorsUtil.hexToColor('#D6DEDC'),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D000000), blurRadius: 12, offset: Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.qr_code_2,
            color: hasScannedItem
                ? Gcolor.primaryColor
                : ColorsUtil.hexToColor('#8A9694'),
            size: ScreenAdapter.fontSize(36),
          ),
          SizedBox(width: ScreenAdapter.width(16)),
          Expanded(
            child: TextField(
              focusNode: ctrl.itemFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '请扫描商品码',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: ScreenAdapter.fontSize(27)),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: ColorsUtil.hexToColor('#263331'),
                fontSize: ScreenAdapter.fontSize(28),
                fontFamily: GFont.getFontFamily(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) ctrl.onScanSubmitted(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(SpicyHotPotCheckoutController ctrl, bool canNext) {
    return KioskTap(
      onTap: canNext ? () => ctrl.goNextWeighStep() : null,
      child: Container(
        width: ScreenAdapter.width(760),
        height: ScreenAdapter.height(96),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              canNext ? Gcolor.primaryColor : ColorsUtil.hexToColor('#BDBDBD'),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('次へ',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: ScreenAdapter.fontSize(34),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w700)),
            SizedBox(width: ScreenAdapter.width(12)),
            Icon(Icons.arrow_forward,
                color: Colors.white, size: ScreenAdapter.fontSize(34)),
          ],
        ),
      ),
    );
  }

  // ==================== 扫码公共组件 ====================

  Widget _buildScannedItemCard(SpicyHotPotCheckoutController ctrl) {
    final item = ctrl.scannedItemData;
    final title = item['mainTitle'] ?? '商品';
    final price = (item['currentPrice'] ?? 0).toString();
    final remark = item['remark'] ?? '';
    final optionGroupList = item['optionGroupVoList'] ?? [];
    List<Map> optionGroups = [];
    if (optionGroupList is List) {
      optionGroups = optionGroupList.whereType<Map>().toList();
    }

    return Container(
      width: ScreenAdapter.width(760),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ColorsUtil.hexToColor('#DCE8E6'), width: 2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x10000000), blurRadius: 18, offset: Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题 + 价格
          Container(
            padding: EdgeInsets.fromLTRB(
              ScreenAdapter.width(28),
              ScreenAdapter.height(22),
              ScreenAdapter.width(24),
              ScreenAdapter.height(20),
            ),
            decoration: BoxDecoration(
              color: ColorsUtil.hexToColor('#F8FBFA'),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Container(
                  width: ScreenAdapter.width(76),
                  height: ScreenAdapter.width(76),
                  decoration: BoxDecoration(
                    color: ColorsUtil.hexToColor('#E9F6F4'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.ramen_dining,
                      color: Gcolor.primaryColor,
                      size: ScreenAdapter.fontSize(42)),
                ),
                SizedBox(width: ScreenAdapter.width(20)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: ColorsUtil.hexToColor('#1F2D2B'),
                            fontSize: ScreenAdapter.fontSize(36),
                            fontFamily: GFont.getFontFamily(),
                            fontWeight: FontWeight.w700,
                          )),
                      if (remark.isNotEmpty) ...[
                        SizedBox(height: ScreenAdapter.height(8)),
                        Text(remark,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ColorsUtil.hexToColor('#687674'),
                              fontSize: ScreenAdapter.fontSize(22),
                              fontFamily: GFont.getFontFamily(),
                            )),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: ScreenAdapter.width(18)),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenAdapter.width(18),
                    vertical: ScreenAdapter.height(10),
                  ),
                  decoration: BoxDecoration(
                    color: ColorsUtil.hexToColor('#FFF4F2'),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('¥ $price',
                      style: TextStyle(
                        color: ColorsUtil.hexToColor(Gcolor.priceColor),
                        fontSize: ScreenAdapter.fontSize(36),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w800,
                      )),
                ),
              ],
            ),
          ),
          // 选项组
          if (optionGroups.isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(
                ScreenAdapter.width(28),
                ScreenAdapter.height(22),
                ScreenAdapter.width(28),
                0,
              ),
              child: Row(
                children: [
                  Container(
                    width: ScreenAdapter.width(8),
                    height: ScreenAdapter.height(32),
                    decoration: BoxDecoration(
                        color: Gcolor.primaryColor,
                        borderRadius: BorderRadius.circular(4)),
                  ),
                  SizedBox(width: ScreenAdapter.width(12)),
                  Text('请选择选项',
                      style: TextStyle(
                        color: ColorsUtil.hexToColor('#1F2D2B'),
                        fontSize: ScreenAdapter.fontSize(28),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          if (optionGroups.isNotEmpty)
            Container(
              constraints: BoxConstraints(
                minHeight: ScreenAdapter.height(120),
                maxHeight: ScreenAdapter.height(560),
              ),
              padding: EdgeInsets.fromLTRB(
                ScreenAdapter.width(22),
                ScreenAdapter.height(16),
                ScreenAdapter.width(22),
                ScreenAdapter.height(22),
              ),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: optionGroups.map((group) {
                    final groupName = group['groupName'] ?? '';
                    final groupRemark = group['remark'] ?? '';
                    final optionList = (group['optionVoList'] ?? []) as List;
                    final multipleState =
                        (group['multipleState'] ?? '1').toString();
                    return Container(
                      margin: EdgeInsets.only(bottom: ScreenAdapter.height(12)),
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenAdapter.width(12),
                        vertical: ScreenAdapter.height(10),
                      ),
                      decoration: BoxDecoration(
                        color: ColorsUtil.hexToColor('#FAFAFA'),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: ColorsUtil.hexToColor('#ECEFED'), width: 1),
                      ),
                      child: OptionListWidget(
                        isLabel: false,
                        languageKey: ctrl.checkLanguage.value,
                        optionListInfo: optionList,
                        optionSelectMaxNum: multipleState,
                        title: groupName,
                        subTitle: groupRemark,
                        onSelected: (groupCode, optionCode, optionName,
                            optionPrice, isAdd, isSelected) {
                          ctrl.updateScannedItemOption(
                              groupName, optionCode, optionName, isAdd);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ScreenAdapter.width(28)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenAdapter.width(18),
                  vertical: ScreenAdapter.height(18),
                ),
                decoration: BoxDecoration(
                  color: ColorsUtil.hexToColor('#F5F7F7'),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: ColorsUtil.hexToColor('#74807E'),
                        size: ScreenAdapter.fontSize(30)),
                    SizedBox(width: ScreenAdapter.width(12)),
                    Text('该商品暂无可选项目',
                        style: TextStyle(
                          color: ColorsUtil.hexToColor('#667270'),
                          fontSize: ScreenAdapter.fontSize(24),
                          fontFamily: GFont.getFontFamily(),
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _hasSelectedOption(SpicyHotPotCheckoutController ctrl) {
    final item = ctrl.scannedItemData;
    if (item.isEmpty) return false;
    final optionGroupList = item['optionGroupVoList'];
    if (optionGroupList is! List || optionGroupList.isEmpty) return true;
    for (final group in optionGroupList) {
      if (group is! Map) continue;
      final optionList = group['optionVoList'];
      if (optionList is! List) continue;
      for (final option in optionList) {
        if (option is Map && option['checked'] == true) return true;
      }
    }
    return false;
  }

  // ==================== 底部导航栏 ====================

  Widget _buildBottomBar(SpicyHotPotCheckoutController ctrl) {
    return Container(
      height: ScreenAdapter.height(140),
      color: ColorsUtil.hexToColor('#DCDCDC'),
      child: KioskTap(
        onTap: () => ctrl.goHome(),
        child: Container(
          margin: EdgeInsets.all(ScreenAdapter.width(15)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back,
                  color: ColorsUtil.hexToColor('#333333'),
                  size: ScreenAdapter.fontSize(36)),
              SizedBox(width: ScreenAdapter.width(10)),
              Text(
                '戻る',
                style: TextStyle(
                  color: ColorsUtil.hexToColor('#333333'),
                  fontSize: ScreenAdapter.fontSize(32),
                  fontFamily: GFont.getFontFamily(),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
