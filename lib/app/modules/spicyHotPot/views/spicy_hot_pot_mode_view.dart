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
      onLoading: Scaffold(
        backgroundColor: _kBg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(_kRed),
            strokeWidth: 3,
          ),
        ),
      ),
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
                child: const Text('戻る', style: TextStyle(color: _kRed)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(SpicyHotPotCheckoutController ctrl) {
    return Stack(
      children: [
        Container(width: double.infinity, height: double.infinity, color: _kBg),
        Column(
          children: [
            _buildTopBar(ctrl),
            Expanded(child: _buildContent(ctrl)),
          ],
        ),
      ],
    );
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

  Widget _buildContent(SpicyHotPotCheckoutController ctrl) {
    if (ctrl.isNormalMode) return _buildNormalOrderView(ctrl);
    return _buildScanOrderView(ctrl);
  }

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

  Widget _buildNormalOrderView(SpicyHotPotCheckoutController ctrl) {
    return Obx(() {
      if (ctrl.normalStep.value == 1) return _buildNormalOptionView(ctrl);
      return _buildNormalCategoryView(ctrl);
    });
  }

  /// 普通注文第0步：选择称重商品
  Widget _buildNormalCategoryView(SpicyHotPotCheckoutController ctrl) {
    // 单商品：addPostFrameCallback 触发 Get.off(SpicyWeighPage)，此处只是一帧奶油色过渡
    if (ctrl.categoryMenuList.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.showScaleDialogForItem(ctrl.categoryMenuList.first as Map);
      });
      return const Scaffold(backgroundColor: _kBg, body: SizedBox.shrink());
    }
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
                    Obx(() => Text(
                          ctrl.selectedCategoryName.value.isNotEmpty
                              ? ctrl.selectedCategoryName.value
                              : '商品を選んでください',
                          style: TextStyle(
                            color: _kText,
                            fontSize: ScreenAdapter.fontSize(32),
                            fontFamily: GFont.getFontFamily(),
                            fontWeight: FontWeight.w700,
                          ),
                        )),
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
            final items = ctrl.categoryMenuData;
            if (items.isEmpty) {
              return Center(
                child: Text(
                  '称重商品なし',
                  style: TextStyle(
                      color: _kGrey, fontSize: ScreenAdapter.fontSize(28)),
                ),
              );
            }
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
        _buildOptionViewHeader(ctrl),
        Container(height: 1, color: _kBorder),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              ScreenAdapter.width(24),
              ScreenAdapter.height(20),
              ScreenAdapter.width(24),
              ScreenAdapter.height(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部口味商品：仅自身 Obx 刷新选中态
                if (ctrl.optionMenuList.isNotEmpty)
                  _buildOptionItemCards(ctrl.optionMenuList, ctrl),
                // 下方子选项：仅随 selectedOptionMenuCode 变化重建
                _buildNormalSelectedOptionsSection(ctrl),
              ],
            ),
          ),
        ),
        _buildNormalOptionButtons(ctrl),
      ],
    );
  }

  /// 选中口味后的子选项区域（独立 Obx，不牵连顶部卡片）
  /// 使用 optionsDisplayMenuCode：大图先高亮，选项组延后一帧再替换；
  /// 切换时不清空旧内容，避免中间空白闪一下
  Widget _buildNormalSelectedOptionsSection(
      SpicyHotPotCheckoutController ctrl) {
    return Obx(() {
      final selectedCode = ctrl.optionsDisplayMenuCode.value;
      if (selectedCode.isEmpty) return const SizedBox.shrink();

      Map? selectedItem;
      for (final i in ctrl.optionMenuList) {
        if ((i as Map)['menuCode']?.toString() == selectedCode) {
          selectedItem = i;
          break;
        }
      }
      if (selectedItem == null) return const SizedBox.shrink();

      final groups = _flattenOptionGroups([selectedItem]);

      return Column(
        key: ValueKey('options-$selectedCode'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: ScreenAdapter.height(24)),
          Row(
            children: [
              Expanded(child: Divider(color: _kBorder, thickness: 1)),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: ScreenAdapter.width(16)),
                child: Text(
                  '选择口味',
                  style: TextStyle(
                    color: _kGrey,
                    fontSize: ScreenAdapter.fontSize(22),
                    fontFamily: GFont.getFontFamily(),
                  ),
                ),
              ),
              Expanded(child: Divider(color: _kBorder, thickness: 1)),
            ],
          ),
          SizedBox(height: ScreenAdapter.height(20)),
          if (groups.isEmpty)
            Center(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: ScreenAdapter.height(24)),
                child: Text(
                  'このメニューに追加オプションはありません',
                  style: TextStyle(
                    color: _kGrey,
                    fontSize: ScreenAdapter.fontSize(24),
                    fontFamily: GFont.getFontFamily(),
                  ),
                ),
              ),
            )
          else
            ...groups.asMap().entries.map((e) => _buildNormalOptionGroupWidget(
                e.value, e.key + 1, ctrl, selectedCode)),
        ],
      );
    });
  }

  /// 顶部口味商品卡片（optionMenuList，单选）
  /// 按下缩放 + 即时选中高亮，子选项延后加载
  Widget _buildOptionItemCards(List items, SpicyHotPotCheckoutController ctrl) {
    return Obx(() {
      final selectedCode = ctrl.selectedOptionMenuCode.value;
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: ScreenAdapter.height(14),
        crossAxisSpacing: ScreenAdapter.width(14),
        childAspectRatio: 0.95,
        children: items.map((raw) {
          final item = raw as Map;
          final code = item['menuCode']?.toString() ?? '';
          final name = item['mainTitle']?.toString() ?? '';
          final img =
              item['homeImage']?.toString() ?? item['image']?.toString() ?? '';
          final remark = item['remark']?.toString() ?? '';
          final isSelected = selectedCode == code;

          return KioskTap(
            onTap: () => ctrl.selectOptionMenuItem(code),
            debounceDuration: const Duration(milliseconds: 120),
            builder: (context, pressed, child) {
              return Transform.scale(
                scale: pressed ? 0.96 : 1.0,
                child: child,
              );
            },
            child: Container(
              key: ValueKey('option-item-$code'),
              padding: EdgeInsets.all(ScreenAdapter.width(15)),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEAF8F7) : _kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? _kRed : _kBorder,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: img.isNotEmpty
                              ? Image.network(
                                  img,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  gaplessPlayback: true,
                                  errorBuilder: (_, __, ___) =>
                                      _buildOptionItemPlaceholder(isSelected),
                                )
                              : _buildOptionItemPlaceholder(isSelected),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ScreenAdapter.height(12)),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? _kRed : _kText,
                      fontSize: ScreenAdapter.fontSize(28),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (remark.isNotEmpty) ...[
                    SizedBox(height: ScreenAdapter.height(4)),
                    Text(
                      remark,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _kGrey,
                        fontSize: ScreenAdapter.fontSize(20),
                        fontFamily: GFont.getFontFamily(),
                        height: 1.25,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildOptionItemPlaceholder(bool isSelected) {
    return Container(
      color: isSelected ? const Color(0xFFD8F0ED) : const Color(0xFFF0F0F0),
      child: Center(
        child: Icon(
          Icons.ramen_dining,
          size: ScreenAdapter.fontSize(40),
          color: isSelected ? _kRed : const Color(0xFFBDBDBD),
        ),
      ),
    );
  }

  Widget _buildOptionViewHeader(SpicyHotPotCheckoutController ctrl) {
    return Container(
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
                  'STEP 02 · 选择口味',
                  style: TextStyle(
                    color: _kRed,
                    fontSize: ScreenAdapter.fontSize(22),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: ScreenAdapter.height(4)),
                // 称重结果小横幅
                Obx(() {
                  final result = ctrl.normalWeighResult;
                  final weight =
                      (result['weight'] as double? ?? 0).toStringAsFixed(0);
                  final price = result['price'] as int? ?? 0;
                  return Row(
                    children: [
                      Icon(Icons.scale,
                          color: Gcolor.primaryColor,
                          size: ScreenAdapter.fontSize(26)),
                      SizedBox(width: ScreenAdapter.width(6)),
                      Text(
                        '${weight}g',
                        style: TextStyle(
                          color: _kText,
                          fontSize: ScreenAdapter.fontSize(30),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(16)),
                      Text(
                        '¥ $price',
                        style: TextStyle(
                          color: _kPrice,
                          fontSize: ScreenAdapter.fontSize(30),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          _buildStepIndicator(2),
        ],
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
      final code = opt['optionCode']?.toString() ??
          opt['menuCode']?.toString() ??
          '';
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

    final titleLabel = isMulti
        ? '$index. $groupName（可多选）'
        : '$index. $groupName';

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
        onSelected: (gCode, optionCode, optionName, optionPrice, isAdd,
            isSelected) {
          ctrl.updateNormalOptionFromWidget(
              groupKey, optionCode, optionName, isAdd, isMulti);
        },
      ),
    );
  }

  /// 普通注文步骤1底部按钮
  Widget _buildNormalOptionButtons(SpicyHotPotCheckoutController ctrl) {
    return Container(
      color: _kCard,
      padding: EdgeInsets.fromLTRB(
        ScreenAdapter.width(28),
        ScreenAdapter.height(16),
        ScreenAdapter.width(28),
        ScreenAdapter.height(24),
      ),
      child: Row(
        children: [
          SizedBox(
            width: ScreenAdapter.width(220),
            child: KioskTap(
              onTap: () => ctrl.cancelNormalWeigh(),
              child: Container(
                height: ScreenAdapter.height(92),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _kBorder, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back,
                        color: _kGrey, size: ScreenAdapter.fontSize(26)),
                    SizedBox(width: ScreenAdapter.width(6)),
                    Text(
                      'やり直す',
                      style: TextStyle(
                        color: _kGrey,
                        fontSize: ScreenAdapter.fontSize(26),
                        fontFamily: GFont.getFontFamily(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: ScreenAdapter.width(16)),
          Expanded(
            child: Obx(() {
              // 依赖选中汤底 + 子选项，未完成时禁用下一步
              final canNext = ctrl.canConfirmNormalOrder;
              return KioskTap(
                onTap: canNext ? () => ctrl.confirmNormalOrder() : null,
                child: Container(
                  height: ScreenAdapter.height(92),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: canNext ? _kRed : const Color(0xFFBDBDBD),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '他の商品を見る',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenAdapter.fontSize(28),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: ScreenAdapter.width(8)),
                      Icon(Icons.arrow_forward,
                          color: Colors.white,
                          size: ScreenAdapter.fontSize(28)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ==================== 扫码注文模式 ====================

  Widget _buildScanOrderView(SpicyHotPotCheckoutController ctrl) {
    return Focus(
      onFocusChange: (hasFocus) {
        if (!hasFocus) ctrl.itemFocusNode.requestFocus();
      },
      child: Obx(() {
        final hasScannedItem = !ctrl.isScannedItemEmpty;
        final canNext = _hasSelectedOption(ctrl);

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
