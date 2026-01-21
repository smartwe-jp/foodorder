import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/services/formatMoney.dart';

// =====================
// Data Models
// =====================

class PrintKitchenTicketData {
  final bool takeOut;
  final String numberTip;
  final String serialNumber;
  final String orderDate;
  final List<PrintKitchenItem> items;

  PrintKitchenTicketData({
    required this.takeOut,
    required this.numberTip,
    required this.serialNumber,
    required this.orderDate,
    required this.items,
  });
}

class PrintKitchenItem {
  final String name;
  final int qty;
  final List<itemOptions> options;

  PrintKitchenItem({
    required this.name,
    required this.qty,
    required this.options,
  });
}

class PrintOptionGroup {
  final String groupName;
  final List<PrintOptionItem> items;

  PrintOptionGroup({
    required this.groupName,
    required this.items,
  });
}

class PrintOptionItem {
  final String name;
  final int qty;
  final int price;

  PrintOptionItem({
    required this.name,
    required this.price,
    this.qty = 1,
  });

  String get displayName => qty > 1 ? '$name ×$qty' : name;
}

class PrintReceiptData {
  final String address;
  final String? brandImage;
  final String? telNo;
  final String? ntaNo;
  final String orderDate;
  final String orderNo;
  final String numberTip;
  final String serialNumber;
  final bool takeOut;
  final List<PrintReceiptItem> items;
  final int finalPrice;
  final int discount;
  final int voucherAmount;
  final int baseTax8;
  final int tax8;
  final int baseTax10;
  final int tax10;
  final bool hideTax;
  final String taxLabel;
  //final List<PrintPaymentLine> payments;
  final String paymentMethod;
  final String memberNo;
  final int change;
  final String payDate;
  final String serialNo;

  PrintReceiptData({
    required this.address,
    required this.orderDate,
    required this.orderNo,
    required this.numberTip,
    required this.serialNumber,
    required this.takeOut,
    required this.items,
    required this.finalPrice,
    required this.paymentMethod,
    this.brandImage,
    this.telNo,
    this.ntaNo,
    this.discount = 0,
    this.voucherAmount = 0,
    this.baseTax8 = 0,
    this.tax8 = 0,
    this.baseTax10 = 0,
    this.tax10 = 0,
    this.hideTax = false,
    this.taxLabel = '　  内    消費税',
    this.memberNo = '',
    this.payDate = '',
    this.serialNo = '',
    this.change = 0,
    //this.payments = const [],
  });
}

class PrintReceiptItem {
  final String name;
  final int qty;
  final int price;
  final int initialPrice;
  final List<itemOptions> options;

  PrintReceiptItem({
    required this.name,
    required this.qty,
    required this.price,
    required this.initialPrice,
    this.options = const [],
  });
}

class itemOptions {
  final String name;
  final List<itemOption> items;

  itemOptions({
    required this.name,
    required this.items,
  });
}

class itemOption {
  final String name;
  final int qty;
  final int price;

  itemOption({
    required this.name,
    required this.qty,
    required this.price,
  });
}

class PrintPaymentLine {
  final String label;
  final int amount;

  PrintPaymentLine({
    required this.label,
    required this.amount,
  });
}

class PrintMemberInfo {
  final String memberNo;
  final String serialNo;
  final String payDate;

  PrintMemberInfo({
    required this.memberNo,
    required this.serialNo,
    required this.payDate,
  });
}

// =====================
// Styles
// =====================

class PrintTextStyles {
  static const TextStyle title = TextStyle(
    fontFamily: 'NotoSansJP',
    color: Colors.black,
    fontSize: 50,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle menu = TextStyle(
    fontFamily: 'NotoSansJP',
    color: Colors.black,
    fontSize: 28,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle menBold = TextStyle(
    fontFamily: 'NotoSansJP',
    color: Colors.black,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle menuBold = TextStyle(
    fontFamily: 'NotoSansJP',
    color: Colors.black,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle small = TextStyle(
    fontFamily: 'NotoSansJP',
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.w300,
  );
}

// =====================
// Public Builders
// =====================

Widget buildKitchenTicketWidget(
  Map<String, dynamic> data, {
  double width = 580,
}) {
  final parsed = _kitchenTicketFromMap(data);
  final takeoutTag = parsed.takeOut ? '【T】' : '';
  return Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    color: Colors.white,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrintCenterOneColumnText('$takeoutTag${parsed.numberTip}\n${parsed.serialNumber}', 
          style: PrintTextStyles.menuBold),
          const SizedBox(height: 8),
          ...parsed.items.map((item) => PrintKitchenItemBlock(item: item)),
          const SizedBox(height: 6),
          PrintOneColumnText(parsed.orderDate,
              style: PrintTextStyles.small, align: TextAlign.right),
        ],
      ),
    ),
  );
}

Widget buildReceiptWidget(Map<String, dynamic> data,
    {double width = 580, bool printOptions = false}) {
  final parsed = _receiptFromMap(data);
  final originalPrice = parsed.finalPrice + parsed.discount;
  final takeoutTag = parsed.takeOut ? '*' : '';

  return Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    color: Colors.white,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (parsed.brandImage != null && parsed.brandImage!.isNotEmpty)
            _brandImageWidget(parsed.brandImage!),
          PrintOneColumnText(parsed.address.replaceAll('%%', '\n'),
              style: PrintTextStyles.menu),
          const SizedBox(height: 6),
          if ((parsed.telNo ?? '').isNotEmpty)
            PrintOneColumnText('電話番号:${parsed.telNo}',
                style: PrintTextStyles.menu),
          if ((parsed.ntaNo ?? '').isNotEmpty)
            PrintOneColumnText('登録番号:${parsed.ntaNo}',
                style: PrintTextStyles.menu),
          const SizedBox(height: 6),
          //PrintOneColumnText(parsed.orderDate, style: PrintTextStyles.menu),
          PrintOneColumnText('注文番号:${parsed.orderNo}',
              style: PrintTextStyles.menu),
          if (parsed.numberTip.isNotEmpty || parsed.serialNumber.isNotEmpty)
            PrintOneColumnText('${parsed.numberTip}${parsed.serialNumber}',
                style: PrintTextStyles.menuBold),
          const SizedBox(height: 6),
          PrintReceiptTitle(title: '領 収 書'),
          const SizedBox(height: 8),
          // ...parsed.items.map((item) => PrintTwoColumnRow(
          //       left: '${item.name}$takeoutTag x${item.qty}',
          //       right: '￥${formatMoney(item.price)}',
          //       leftStyle: PrintTextStyles.menu,
          //       rightStyle: PrintTextStyles.menu,
          //     )),

          // 詳細商品リスト
          ...parsed.items.map((item) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PrintTwoColumnRow(
                //   left: '${item.name}$takeoutTag x${item.qty}',
                //   right: '￥${formatMoney(item.price)}',
                //   leftStyle: PrintTextStyles.menu,
                //   rightStyle: PrintTextStyles.menu,
                // ),
                PrintThreeColumnRow(
                  left: '${item.name}$takeoutTag',
                  middle: '${item.qty}',
                  right: '￥${formatMoney(printOptions ? item.initialPrice : item.price)}',
                  leftStyle: printOptions ? PrintTextStyles.menBold : PrintTextStyles.menu,
                  rightStyle: printOptions ? PrintTextStyles.menBold : PrintTextStyles.menu,
                ),
                if (item.options.isNotEmpty && printOptions)
                  ...item.options.map((optionGroup) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(optionGroup.name,
                                  style: PrintTextStyles.menu),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ...optionGroup.items.map((optionItem) {
                                      return Text(
                                        optionItem.name +
                                            (optionItem.qty > 1
                                                ? ' ×${optionItem.qty}'
                                                : ''),
                                        style: PrintTextStyles.menu,
                                        textAlign: TextAlign.right,
                                      );
                                    }).toList()
                                  ]),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    ...optionGroup.items.map((optionItem) {
                                      return Text(
                                        optionItem.price > 0
                                            ? '￥${formatMoney(optionItem.price)}'
                                            : ' ',
                                        style: PrintTextStyles.menu,
                                        textAlign: TextAlign.right,
                                      );
                                    }).toList()
                                  ]),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                SizedBox(height: 10),
              ],
            );
          }).toList(),

          const SizedBox(height: 10),
          const PrintSectionDivider(),
          if (parsed.discount != 0 || parsed.voucherAmount > 0)
            PrintTwoColumnRow(
              left: '定価',
              right: formatMoney(originalPrice),
              leftStyle: PrintTextStyles.small,
              rightStyle: PrintTextStyles.small,
            ),
          if (parsed.discount != 0)
            PrintTwoColumnRow(
              left: '割引',
              right: '-${formatMoney(parsed.discount)}',
              leftStyle: PrintTextStyles.small,
              rightStyle: PrintTextStyles.small,
            ),
          PrintTwoColumnRow(
            left: '合計',
            right: '￥${formatMoney(parsed.finalPrice)}',
            leftStyle: PrintTextStyles.menuBold,
            rightStyle: PrintTextStyles.menu,
          ),
          const PrintSectionDivider(),
          if (!parsed.hideTax) ...[
            PrintTwoColumnRow(
              left: '8%対象',
              right: '￥${formatMoney(parsed.baseTax8)}',
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),
            PrintTwoColumnRow(
              left: parsed.taxLabel,
              right: '￥${formatMoney(parsed.tax8)})',
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),
            PrintTwoColumnRow(
              left: '10%対象',
              right: '￥${formatMoney(parsed.baseTax10)}',
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),
            PrintTwoColumnRow(
              left: parsed.taxLabel,
              right: '￥${formatMoney(parsed.tax10)})',
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),
            const PrintSectionDivider(),
          ],
          if (parsed.voucherAmount > 0)
            PrintTwoColumnRow(
              left: '代金券・売掛',
              right: '￥${formatMoney(parsed.voucherAmount)}',
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),

          if (parsed.paymentMethod != '現金支払')
            PrintTwoColumnRow(
              left: parsed.paymentMethod,
              right: parsed.finalPrice > 0
                  ? '￥${formatMoney(parsed.finalPrice)}'
                  : '',
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),
          if (parsed.memberNo.isNotEmpty) ...[
            PrintTwoColumnRow(
              left: 'カード番号',
              right: parsed.memberNo,
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),
            PrintTwoColumnRow(
              left: '日期',
              right: parsed.payDate,
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),
            const PrintSectionDivider(),
          ],

          if (parsed.serialNo.isNotEmpty) ...[
            PrintTwoColumnRow(
              left: 'カード取引通番',
              right: parsed.serialNo,
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),
            PrintTwoColumnRow(
              left: '取引日時',
              right: parsed.payDate,
              leftStyle: PrintTextStyles.menu,
              rightStyle: PrintTextStyles.menu,
            ),
            const PrintSectionDivider(),
          ],

          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              textDirection: TextDirection.ltr,
              children: [
                Expanded(
                  child: PrintOneColumnText(
                    "*軽減税率対象",
                    style: PrintTextStyles.menu,
                  ),
                ),
                if (parsed.paymentMethod == "現金支払")
                  Expanded(
                      child: Column(
                    children: [
                      PrintTwoRow(
                        left: 'お預り',
                        right: '￥${formatMoney(parsed.finalPrice)}',
                        leftStyle: PrintTextStyles.menu,
                        rightStyle: PrintTextStyles.menu,
                      ),
                      PrintTwoRow(
                        left: 'お釣',
                        right: '￥${formatMoney(parsed.change)}',
                        leftStyle: PrintTextStyles.menu,
                        rightStyle: PrintTextStyles.menu,
                      ),
                    ],
                  )),
              ],
            ),
          ),
          //お明細は上記のとおりです。
          PrintOneColumnText('お明細は上記のとおりです。', style: PrintTextStyles.menu),
        ],
      ),
    ),
  );
}

Widget _brandImageWidget(String imageUrl) {
  return Container(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(10),
          bottom: ScreenAdapter.height(30),
          left: ScreenAdapter.width(30),
          right: ScreenAdapter.width(30)),
      height: ScreenAdapter.height(200),
      decoration: BoxDecoration(
        //color: Colors.green,
        image: DecorationImage(
          image: CachedNetworkImageProvider(imageUrl),
          fit: BoxFit.fitWidth,
        ),
      ));
}

PrintKitchenTicketData _kitchenTicketFromMap(Map<String, dynamic> map) {
  return PrintKitchenTicketData(
    takeOut: _toBool(map['takeOut']),
    numberTip: _toStr(map['numberTip']),
    serialNumber: _toStr(map['serialNumber']),
    orderDate: _toStr(map['orderDate']),
    items: _kitchenItemsFrom(map['printInfo']['orderLines']),
  );
}

List<PrintKitchenItem> _kitchenItemsFrom(dynamic items) {
  final list = items is List ? items : const [];
  return list.map((item) {
    final m = _toMap(item);
    return PrintKitchenItem(
      name: _toStr(m['name']),
      qty: _toInt(m['qty']),
      options: _optionsFrom(m['options']),
    );
  }).toList();
}

PrintReceiptData _receiptFromMap(Map<String, dynamic> map) {
  return PrintReceiptData(
    address: _toStr(map['address']),
    telNo: _toNullableStr(map['telNo']),
    ntaNo: _toNullableStr(map['ntaNo']),
    orderDate: _toStr(map['orderDate']),
    orderNo: _toStr(map['order']),
    numberTip: _toStr(map['numberTip']),
    serialNumber: _toStr(map['serialNumber']),
    takeOut: _toBool(map['takeOut']),
    items: _receiptItemsFrom(map['printInfo']['orderLines']),
    finalPrice: _toInt(map['price']),
    discount: _toInt(map['discount']),
    voucherAmount: _toInt(map['voucherAmount']),
    baseTax8: _toInt(map['baseTax2']),
    tax8: _toInt(map['tax2']),
    baseTax10: _toInt(map['baseTax1']),
    tax10: _toInt(map['tax1']),
    hideTax: _toBool(map['hideTax']),
    taxLabel: _toBool(map['containTax']) ? '　  内    消費税' : "　  内    消費税",
    //payments: _paymentsFrom(map['payments']),
    paymentMethod: _toStr(map['payMethod']),
    brandImage: _toNullableStr(map['brandImage']),
    memberNo: _toStr(map['memberNo']),
    payDate: _toStr(map['payDate']),
    serialNo: _toStr(map['serialNo']),
    change: map['change'] != null ? _toInt(map['change']) : 0,
  );
}

List<PrintReceiptItem> _receiptItemsFrom(dynamic items) {
  final list = items is List ? items : const [];
  return list.map((item) {
    final m = _toMap(item);
    return PrintReceiptItem(
      name: _toStr(m['name']),
      qty: _toInt(m['qty']),
      price: _toInt(m['price']),
      initialPrice: _toInt(m['initialPrice']),
      options: _optionsFrom(m['options']),
    );
  }).toList();
}

//options 为一个Map 不是List 如下：
// "options": {
//               "味": [
//                 {"name": "ココナツ", "price": null, "qty": 1}
//               ]
//             },
List<itemOptions> _optionsFrom(dynamic options) {
  final map = options is Map ? Map<String, dynamic>.from(options) : {};
  return map.entries.map((entry) {
    final groupName = entry.key;
    final items = _optionItemFrom(entry.value);
    return itemOptions(
      name: groupName,
      items: items,
    );
  }).toList();
}

List<itemOption> _optionItemFrom(dynamic items) {
  final list = items is List ? items : const [];
  return list.map((item) {
    final m = _toMap(item);
    final qty = _toInt(m['qty']);
    return itemOption(
      name: _toStr(m['name']),
      price: _toInt(m['price']),
      qty: qty == 0 ? 1 : qty,
    );
  }).toList();
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

String _toStr(dynamic value) => value?.toString() ?? '';

String? _toNullableStr(dynamic value) =>
    value == null ? null : value.toString();

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final v = value.toLowerCase();
    return v == 'true' || v == '1';
  }
  return false;
}

// =====================
// Reusable Widgets
// =====================

class PrintOneColumnText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign align;

  const PrintOneColumnText(
    this.text, {
    Key? key,
    required this.style,
    this.align = TextAlign.left,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: style,
      softWrap: true,
    );
  }
}

class PrintCenterOneColumnText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign align;

  const PrintCenterOneColumnText(
    this.text, {
    Key? key,
    required this.style,
    this.align = TextAlign.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: align,
      style: style,
      softWrap: true,
    );
  }
}

class PrintTwoColumnRow extends StatelessWidget {
  final String left;
  final String right;
  final TextStyle leftStyle;
  final TextStyle rightStyle;

  const PrintTwoColumnRow({
    Key? key,
    required this.left,
    required this.right,
    required this.leftStyle,
    required this.rightStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              left,
              style: leftStyle,
              softWrap: true,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            right,
            style: rightStyle,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class PrintThreeColumnRow extends StatelessWidget {
  final String left;
  final String middle;
  final String right;
  final TextStyle leftStyle;
  final TextStyle rightStyle;

  const PrintThreeColumnRow({
    Key? key,
    required this.left,
    required this.middle,
    required this.right,
    required this.leftStyle,
    required this.rightStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            left,
            maxLines: 2,
            style: leftStyle,
            softWrap: true,
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                middle,
                style: rightStyle,
                softWrap: true,
              ),
              Text(
                right,
                style: rightStyle,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PrintTwoRow extends StatelessWidget {
  final String left;
  final String right;
  final TextStyle leftStyle;
  final TextStyle rightStyle;

  const PrintTwoRow({
    Key? key,
    required this.left,
    required this.right,
    required this.leftStyle,
    required this.rightStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            left,
            style: leftStyle,
            softWrap: true,
          ),
          Text(
            right,
            style: rightStyle,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class PrintSectionDivider extends StatelessWidget {
  const PrintSectionDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      height: 2,
      color: Colors.black,
    );
  }
}

class PrintReceiptTitle extends StatelessWidget {
  final String title;

  const PrintReceiptTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(title,
            style: PrintTextStyles.title, textAlign: TextAlign.center),
      ),
    );
  }
}

class PrintKitchenItemBlock extends StatelessWidget {
  final PrintKitchenItem item;

  const PrintKitchenItemBlock({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrintTwoColumnRow(
            left: item.name,
            right: 'x${item.qty}',
            leftStyle: PrintTextStyles.menBold,
            rightStyle: PrintTextStyles.menBold,
          ),
          if (item.options.isNotEmpty)
            ...item.options.map((g) => PrintOptionGroupBlock(group: g)),
          const PrintSectionDivider(),
        ],
      ),
    );
  }
}

class PrintOptionGroupBlock extends StatelessWidget {
  final itemOptions group;

  const PrintOptionGroupBlock({Key? key, required this.group})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          Text(group.name, style: PrintTextStyles.menu),
          Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:[
          ...group.items.map((o) => Padding(
                padding: const EdgeInsets.only(left: 12, top: 2),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    o.name + (o.qty > 1 ? ' ×${o.qty}' : ''),
                    style: PrintTextStyles.menu,
                    textAlign: TextAlign.right,
                  ),
                ),
              )),
              ])
        ],
      ),
    );
  }
}
