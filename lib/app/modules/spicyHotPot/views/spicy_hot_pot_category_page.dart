import 'package:flutter/material.dart';
import 'package:foodorder/app/services/logUtil.dart';
import 'package:get/get.dart';
import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../../../widget/KioskTap.dart';
import '../controllers/spicy_hot_pot_checkout_controller.dart';

/// 麻辣烫模式 — 分类菜品选择页面
/// 九宫格展示菜品，点击后根据 qtyBounds 决定是否弹出称重
class SpicyHotPotCategoryPage extends StatelessWidget {
  const SpicyHotPotCategoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SpicyHotPotCheckoutController>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: ColorsUtil.hexToColor('#F5F5F5'),
          ),
          Column(
            children: [
              // 顶部导航栏
              _buildTopBar(ctrl),
              // 分类名称
              _buildCategoryTitle(ctrl),
              // 菜品网格
              Expanded(child: _buildMenuGrid(ctrl)),
              // 底部返回
              _buildBottomBar(ctrl),
            ],
          ),
        ],
      ),
    );
  }

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
            onPressed: () => Get.back(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          Expanded(
            child: Text(
              '麻辣烫自助点餐222',
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

  Widget _buildCategoryTitle(SpicyHotPotCheckoutController ctrl) {
    return Container(
      height: ScreenAdapter.height(80),
      color: Colors.white,
      alignment: Alignment.center,
      child: Text(
        ctrl.selectedCategoryName.value,
        style: TextStyle(
          color: ColorsUtil.hexToColor('#333333'),
          fontSize: ScreenAdapter.fontSize(32),
          fontFamily: GFont.getFontFamily(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMenuGrid(SpicyHotPotCheckoutController ctrl) {
    final items = ctrl.categoryMenuData;

    if (items.isEmpty) {
      return Center(
        child: Text(
          '暂无菜品',
          style: TextStyle(
            color: Colors.grey,
            fontSize: ScreenAdapter.fontSize(32),
          ),
        ),
      );
    }

    // 4列九宫格
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenAdapter.width(10),
        vertical: ScreenAdapter.height(8),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: ScreenAdapter.height(7),
        crossAxisSpacing: ScreenAdapter.width(10),
        childAspectRatio: 0.40,
      ),
      itemBuilder: (context, index) {
        final item = items[index] as Map;
        return _buildMenuItem(item, ctrl);
      },
      itemCount: items.length,
    );
  }

  /// 单个菜品卡片（参考 menuzong_page_view 的 CategoryFourItemOne）
  Widget _buildMenuItem(Map item, SpicyHotPotCheckoutController ctrl) {
    final title = item['mainTitle'] ?? '';
    final price = (item['currentPrice'] ?? 0).toString();
    final homeImage = item['homeImage'] ?? '';

    return KioskTap(
      onTap: () {LogUtil.d(item);
        // 安全解析 qtyBounds，兼容 String/int/null
        final rawPriceType = item['priceType'];

        // qtyBounds > 0: 称重商品 → 弹出称重对话框
        if (rawPriceType == "HUNDRED_GRAM") {
          ctrl.showScaleDialogForItem(item);
        }
        // qtyBounds == 0: 普通商品 → 直接加入购物车（暂不实现，后续扩展）
        // qtyBounds < 0: 有限制商品（暂不处理）
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ColorsUtil.hexToColor('#DDDDDD'),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 菜品图片
            Expanded(
              flex: 5,
              child: ClipRRect(

                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: homeImage.isNotEmpty
                    ? publicShowMenuImage(
                        imgPath: homeImage,
                        imgWidth: 450.0,
                        imgHeight: 450.0,
                      )
                    : Container(
                        color: ColorsUtil.hexToColor('#F0F0F0'),
                        child: Icon(
                          Icons.restaurant_menu,
                          size: ScreenAdapter.fontSize(60),
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),
            // 分隔线
            Divider(height: 1, color: ColorsUtil.hexToColor('#DDDDDD')),
            // 菜名
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ScreenAdapter.width(10),
                  vertical: ScreenAdapter.height(5),
                ),
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    fontSize: ScreenAdapter.fontSize(22),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            // 价格
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: ScreenAdapter.width(5),
                    bottom: ScreenAdapter.height(5),
                  ),
                  child: Text(
                    '¥ $price',
                    style: TextStyle(
                      color: ColorsUtil.hexToColor(Gcolor.priceColor),
                      fontSize: ScreenAdapter.fontSize(24),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(SpicyHotPotCheckoutController ctrl) {
    return Container(
      height: ScreenAdapter.height(140),
      color: ColorsUtil.hexToColor('#DCDCDC'),
      child: KioskTap(
        onTap: () => Get.back(),
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
              Icon(
                Icons.arrow_back,
                color: ColorsUtil.hexToColor('#333333'),
                size: ScreenAdapter.fontSize(36),
              ),
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
