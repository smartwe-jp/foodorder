import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/printer_failed_list_controller.dart';

class PrinterFailedListPage extends GetView<PrinterFailedListController> {
  const PrinterFailedListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final name = controller.printerName.value.trim();
          final titlePrefix = name.isEmpty ? 'プリンター' : name;
          return Text('$titlePrefix 印刷失敗一覧');
        }),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              Get.defaultDialog(
                title: '確認',
                middleText: '失敗記録をクリアしますか？',
                textCancel: 'キャンセル',
                textConfirm: 'クリア',
                confirmTextColor: Colors.white,
                onConfirm: () async {
                  Get.back();
                  await controller.clearCurrentPrinterFailed();
                },
              );
            },
            label: const Text('クリア', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final twoPane = constraints.maxWidth >= 900;
          if (twoPane) {
            return Row(
              children: [
                SizedBox(
                  width: 380,
                  child: _LeftListPane(),
                ),
                const VerticalDivider(width: 1),
                const Expanded(child: _RightDetailPane()),
              ],
            );
          }
          return Column(
            children: const [
              Expanded(child: _LeftListPane()),
              Divider(height: 1),
              SizedBox(height: 280, child: _RightDetailPane()),
            ],
          );
        },
      ),
    );
  }
}

class _LeftListPane extends GetView<PrinterFailedListController> {
  const _LeftListPane();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.failedRecords;
      if (list.isEmpty) {
        return const Center(child: Text('失敗記録なし'));
      }
      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final record = list[index];
          final info = record.printInfo;
          final orderSnCode =
              (info['orderSnCode'] ?? info['order_sn_code'] ?? '').toString();
          final fromPlate =
              (info['fromPlate'] ?? info['from_plate'] ?? '').toString();
          final orderTime = (info['orderTime'] ?? '').toString();
          return Obx(() {
            final selected = controller.selected.value?.uuid == record.uuid;
            return Material(
              color: selected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.selectRecord(record),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderSnCode.isEmpty ? '注文番号：-' : '注文番号：$orderSnCode',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              fromPlate.isEmpty ? '注文元：-' : '注文元：$fromPlate',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ),
                          Text(
                            orderTime.isEmpty ? '-' : orderTime,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'UUID：${record.uuid}',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black45),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      );
    });
  }
}

class _RightDetailPane extends GetView<PrinterFailedListController> {
  const _RightDetailPane();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final record = controller.selected.value;
      if (record == null) {
        return const Center(child: Text('左側から記録を選択してください'));
      }
      final info = record.printInfo;
      final items = _extractItems(info);
      bool isCenter = record.printerType == 11; // 中央キッチンプリンター

      return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '詳細',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        _kv(
                            '注文番号',
                            (info['orderSnCode'] ??
                                    info['order_sn_code'] ??
                                    '-')
                                .toString()),
                        _kv(
                            '注文元',
                            (info['fromPlate'] ?? info['from_plate'] ?? '-')
                                .toString()),
                        _kv('注文時間', (info['orderTime'] ?? '-').toString()),
                        _kv('プリンターType', record.printerType.toString()),
                        _kv('IP', record.printerIp),
                        const SizedBox(height: 14),
                        Text(
                          '品目',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          Get.defaultDialog(
                            title: '確認',
                            middleText: 'この印刷失敗記録を削除しますか？',
                            textCancel: 'キャンセル',
                            textConfirm: '削除',
                            confirmTextColor: Colors.white,
                            onConfirm: () async {
                              Get.back();
                              await controller
                                  .deleteSelectedRecordByUuid(record.uuid);
                            },
                          );
                        },
                        icon: const Icon(Icons.delete),
                        label: const Text('削除'),
                      ),
                      //print button
                      SizedBox(height: 100),
                      if (isCenter)
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.retrySelectedRecord(record);
                          },
                          icon: const Icon(Icons.print, size: 18),
                          label: const Text('印刷'),
                        )
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Column(
                children: [
                  if (items.isEmpty)
                    const Text('注文なし')
                  else
                    ...items
                        .map((e) => _ItemCard(item: e, isCenter: isCenter, rePrint: () => controller.retrySelectedRecord(record)))
                        .toList(),
                ],
              ),
            ],
          ));
    });
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
              width: 90,
              child: Text(k, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _extractItems(Map info) {
    final raw = info['items'] ?? [];

    if (raw is List) {
      return raw
          .map((e) {
            if (e is Map) {
              return e.map((key, value) => MapEntry(key.toString(), value));
            }
            return <String, dynamic>{};
          })
          .where((m) => m.isNotEmpty)
          .toList();
    }
    return [];
  }
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item, this.isCenter = false, required this.rePrint});

  final Map<String, dynamic> item;
  final bool isCenter;
  final Function rePrint;

  @override
  Widget build(BuildContext context) {
    final categoryName = (item['categoryName'] ?? '').toString();
    final name = (item['name'] ?? '').toString();
    final qty = item['qty']?.toString() ?? '1';
    final price = item['price']?.toString() ?? '';
    final options = item['options'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name.isEmpty ? '-' : name,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              Text('x $qty',
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  categoryName.isEmpty ? '' : categoryName,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
              if (price.isNotEmpty)
                Text('¥ $price',
                    style:
                        const TextStyle(fontSize: 12, color: Colors.black87)),
            ],
          ),
          if (options is Map && options.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _formatOptions(options),
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
          const SizedBox(height: 10),
          if (!isCenter)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  rePrint();
                },
                icon: const Icon(Icons.print, size: 18),
                label: const Text('印刷'),
              ),
            ),
        ],
      ),
    );
  }

  String _formatOptions(Map options) {
    // options: {"トッピング": [{"name":"うどん","price":null,"qty":1}]}
    final parts = <String>[];
    options.forEach((key, value) {
      if (value is List) {
        final v = value.map((e) {
          if (e is Map) {
            final n = (e['name'] ?? '').toString();
            final q = e['qty'];
            final qs =
                (q == null || q.toString() == '1') ? '' : ' x${q.toString()}';
            return '$n$qs';
          }
          return e.toString();
        }).join('、');
        parts.add('$key：$v');
      } else {
        parts.add('$key：${value.toString()}');
      }
    });
    return parts.join(' / ');
  }
}
