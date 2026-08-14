import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/modules/setting/printList/logic.dart';
import 'package:foodorder/app/modules/setting/printList/state.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

class PrintListPage extends StatelessWidget {
  PrintListPage({Key? key}) : super(key: key);

  final logic = Get.put(PrintListPageLogic());
  final PrintListState state = Get.find<PrintListPageLogic>().state;

  void _showReprintConfirmation(VoidCallback onConfirm) {
    Get.dialog(
      DialogUtils.alert(
        '再印刷しますか？',
        confirm: () {
          Get.back();
          onConfirm();
        },
        cancle: Get.back,
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(theme),
            Expanded(
              child: GetBuilder<PrintListPageLogic>(
                builder: (_) => logic.obx(
                  (s) => _buildRoot(theme),
                  onLoading: _buildLoading(),
                  onEmpty: _buildEmpty(),
                  onError: (e) => _buildError(e, theme),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(ThemeData theme) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 12),
              blurRadius: 8,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 22),
            onPressed: () => Get.back(),
          ),
          //戻る
          //const Text('戻る', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(
            '印刷履歴　(最近の30件)',
            style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '再読み込み',
            onPressed: () {
              final cat = state.selectedCategory ?? 'default';
              logic.loadCategoryItems(cat);
            },
          )
        ],
      ),
    );
  }

  /// 根内容：左侧分类 + 右侧列表
  Widget _buildRoot(ThemeData theme) {
    return Row(
      children: [
        _buildSidebar(theme),
        const VerticalDivider(width: 1),
        Expanded(child: _buildCategoryContent(theme)),
      ],
    );
  }

  /// 左侧 Sidebar 分类
  Widget _buildSidebar(ThemeData theme) {
    final cats = state.categories;
    final selected = state.selectedCategory;
    final primary = ColorsUtil.hexToColor('#80B646');
    return Container(
      width: 220,
      margin: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
      child: ListView.builder(
        padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final cat = cats[index];
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Card(
              elevation: isSelected ? 2 : 0,
              color: isSelected ? primary : Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => logic.changeSelectedCategory(cat),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.folder_open : Icons.folder,
                        size: 18,
                        color: isSelected ? Colors.white : Colors.grey[700],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          logic.getRendererForCategory(cat),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : Colors.grey[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 根据分类渲染列表（更灵活）：仅依赖 state.currentItemsRaw + 映射类型
  Widget _buildCategoryContent(ThemeData theme) {
    final items = state.currentItemsRaw;
    if (items.isEmpty) return _buildEmpty();
    final cat = state.selectedCategory ?? 'default';
    //final renderer = state.categoryRenderer[cat] ?? 'order';
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final map = items[index];
        switch (cat) {
          case 'rejishime':
            final item = PrintSummaryItem.fromMap(map);
            return _buildSummaryItem(item, theme);
          case 'default':
          default:
            final item = PrintOrderItem.fromMap(map);
            return _buildItem(item, theme);
        }
      },
    );
  }

  Widget _buildSummaryItem(PrintSummaryItem item, ThemeData theme) {
    final primary = ColorsUtil.hexToColor('#80B646');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧：店铺名
            SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('店舗',
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(
                    item.shopName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // 中间：时间信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('開始', item.startTime, theme),
                  _infoRow('終了', item.endTime, theme),
                  _infoRow('印刷時間', item.printTime, theme),
                  _infoRow('確認者', item.verifyUserName, theme),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showReprintConfirmation(
                    () => logic.rePrintSummary(item),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.print, size: 22),
                  label: const Text('再印刷'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItem(PrintOrderItem item, ThemeData theme) {
    final primary = ColorsUtil.hexToColor('#80B646');
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 第一部分：注文番号
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('注文番号',
                        style: theme.textTheme.labelMedium
                            ?.copyWith(color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(
                      item.serialNumber,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 第二部分：订单信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('オーダーID', item.orderId, theme),
                    _infoRow('注文日時', item.orderTime, theme),
                    _infoRow('支払い方法', item.payMethod, theme),
                    _infoRow(
                        '金額/お釣り',
                        '${item.payPrice} / ${item.change == 'null' ? '0' : item.change}',
                        theme),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 第三部分：打印按钮
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showReprintConfirmation(
                      () => logic.reprint(item),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    icon: const Icon(Icons.print, size: 22),
                    //日本語
                    label: const Text('再印刷'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey[600])),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() => Center(
        child: CircularProgressIndicator(
          strokeWidth: 5,
          valueColor:
              AlwaysStoppedAnimation<Color>(ColorsUtil.hexToColor('#80B646')),
        ),
      );

  Widget _buildEmpty() => const Center(
        //日本語
        child: Text('印刷履歴がありません'),
      );

  Widget _buildError(String? e, ThemeData theme) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 38),
            const SizedBox(height: 8),
            Text('印刷履歴の読み込みに失敗しました', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => logic.loadPrintList(),
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            )
          ],
        ),
      );
}
//printInfo:
//{shopName: 1A-SE, orderDate: 2025年10月02日(木) 15:39, address: 甘蘭株式会社%%\n〒202-0015%%東京都千代田区飯田橋１丁目９−７池谷ビル1F, telNo: 無し, ntaNo: T5175436899000, orderType: 1, numberTip: お客様番号:, serialNo: , serialNumber: ０２０５, serialNumberText: ０２０５, orderId: 461212794775601152, language: JP, takeOut: false, price: 100, tax: 9, tax1: 9, baseTax1: 100, tax2: 0, baseTax2: 0, order: ＊＊＊６０１１５２, payPrice: 100, change: 0, payDate: null, memberNo: null, payMethod: 現金支払, details: null, discount: 0, orderTime: 15:39, printInfo: {uuid: null, bizId: 461212794775601152, orderTime: 15:39, remark: , from_plate: Shop, order_sn_code: 0205, payment_code: , order_type: Shop_In, pay_type: Paid, orderLinesMap: {10: [{name: Kanran Beef Noodle, price: 100, qty: 1, bizId: 461212794775601153, options: {麺の型: [{name: 👍🏻平麺, qty: 1}], パクチー: [{name: 無し, qty: 1}], 脂・菜・にん: [{name: あり, qty: 1}]}, extend2qr: null}]}, orderLines: [{name: Kanran Beef Noodle, price: 100, qty: 1, bizId: 461212794775601153, options: {麺の型: [{name: 👍🏻平麺, qty: 1}], パクチー: [{name: 無し, qty: 1}], 脂・菜・にん: [{name: あり, qty: 1}]}, extend2qr: null}]}}
