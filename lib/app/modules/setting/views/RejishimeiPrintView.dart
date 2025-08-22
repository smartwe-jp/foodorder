import 'dart:io';

import 'package:flutter/material.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';

enum PrintType {
  REJISHIME,
  SUPPLY,
}

class PrintView extends StatefulWidget {
  final PrintType? printType;
  final Map printInfo;
  final bool isPrint;
  final Function(double)? lengthUpdate;
  PrintView(
      {super.key,
      this.isPrint = false,
      required this.printInfo,
      this.lengthUpdate,
      this.printType = PrintType.REJISHIME});
  @override
  RejishimePrintViewState createState() => RejishimePrintViewState();
}

class RejishimePrintViewState extends State<PrintView> {
  ScrollController _scrollController = ScrollController();
  double contentLength = 0.0;
  late Map _printInfo;
  bool isPrint = false;

  @override
  Widget build(BuildContext context) {
    switch (widget.printType ?? PrintType.REJISHIME) {
      case PrintType.REJISHIME:
        return isPrint ? printView() : showView();
      case PrintType.SUPPLY:
        return isPrint
            ? _supplyPrintView(_printInfo)
            : _supplyShowView(_printInfo);
    }
  }

  @override
  void initState() {
    
    super.initState();
    // 在布局完成后获取内容长度
    isPrint = widget.isPrint;
    _printInfo = widget.printInfo;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        setState(() {
          contentLength = _scrollController.position.maxScrollExtent +
              _scrollController.position.viewportDimension;
        });
      }
      if (widget.lengthUpdate != null) {
        widget.lengthUpdate!(contentLength);
      }
    });
  }

    @override
  void didUpdateWidget(PrintView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当Widget更新时，更新内部状态
    if (widget.printInfo != oldWidget.printInfo) {
      _printInfo = widget.printInfo;
      debugPrint('RejishimePrintViewState didUpdateWidget: $_printInfo, type: ${widget.printType}');
    }
    isPrint = widget.isPrint;
  }

  Widget _mainTitle(String title) {
    return Container(
        margin: EdgeInsets.only(top: 20),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            title,
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(28),
                fontFamily: GFont.getFontFamily(),
                color: Colors.black,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ));
  }

  Widget printView() {
    return Container(
        padding: EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 20),
        child: _miroWidget());
  }

  Widget _supplyPrintView(cashInfo) {
    return Container(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
        child: Column(
          children: [
            _normalTitle("お釣り金補充情報"),
            SizedBox(height: 30),
            _supplyTable(cashInfo)
          ],
        ));
  }

  Widget _supplyShowView(cashInfo) {
    return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
        child: Column(
          children: [
            _normalTitle("お預かり金補充情報"),
            SizedBox(height: 30),
            _supplyTable(cashInfo)
          ],
        ));
  }

  int getCatVal(String value) {
    switch (value) {
      case '一円':
        return 1;
      case '五円':
        return 5;
      case '十円':
        return 10;
      case '五十円':
        return 50;
      case '百円':
        return 100;
      case '五百円':
        return 500;
      case '千円':
        return 1000;
      case '二千円':
        return 2000;
      case '五千円':
        return 5000;
      case '一万円':
        return 10000;
      default:
        return 0;
    }
  }

  Widget _supplyTable(cashInfo) {
    num orginCount = 0;
    num supplyCount = 0;
    num remainCount = 0;

    final displayInfo = cashInfo.entries.map((entry) {
      String key = entry.key;
      Map value = entry.value;
      orginCount += (value['origin'] ?? 0) * getCatVal(key);
      supplyCount += (value['supply'] ?? 0) * getCatVal(key);
      remainCount += (value['remain'] ?? 0) * getCatVal(key);
      return [
        key,
        value['origin'] ?? 0,
        value['supply'] ?? 0,
        value['remain'] ?? 0,
      ];
    }).toList();

    return Table(
      border: TableBorder.all(
          width: 2.0, color: const Color.fromARGB(255, 43, 42, 42)),
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(100.0),
        1: FlexColumnWidth(150.0),
        2: FlexColumnWidth(150.0),
        3: FlexColumnWidth(150.0),
      },
      children: <TableRow>[
        _tableRow(['金種', '補充前', '補充', '補充後'],
            backgroundColor: isPrint ? Colors.white : Colors.grey[200]),
        ...displayInfo
            .map((content) => _tableRow(content, alignment: Alignment.center))
            .toList(growable: false),
        _tableRow([
          '総額',
          '¥ ${formatSum(orginCount)}',
          '¥ ${formatSum(supplyCount)}',
          '¥ ${formatSum(remainCount)}'
        ])
      ],
    );
  }

  Widget showView() {
    return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
        child: _miroWidget());
  }

  String formatSum(sum) {
    if (sum == null) return "0";
    List<String> parts = sum.toString().split('.');
    parts[0] = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return parts.join('.');
  }

  Widget _miroWidget() {
    return Column(
      children: [
        _mainTitle(_printInfo['shopName'] ?? "0"),
        _normalTitle("レジ番号 : ${_printInfo['machineCode'] ?? "0"}",
            alignment: Alignment.centerLeft),
        _normalTitle("印字日時 : ", alignment: Alignment.centerLeft),
        _normalTitle("${_printInfo['printTime'] ?? "0"}",
            alignment: Alignment.centerRight),
        _normalTitle("スタッフ : ${_printInfo['verifyUserName'] ?? "0"}",
            alignment: Alignment.centerLeft),
        _normalTitle(
            "${_printInfo['startTime'] ?? "0"}　から　\n ${_printInfo['endTime'] ?? "0"}　まで"),
        //分割线
        Container(
          margin: EdgeInsets.only(top: 20, left: 40, right: 40),
          height: 2,
          color: Colors.black,
        ),

        Container(
          //padding: EdgeInsets.only(left: 80,right: 80),
          child: Directionality(
              textDirection: TextDirection.ltr,
              child: Column(
                children: [
                  _normalTitle("精算情報"),

                  _twoContentRow("売上", "¥ ${formatSum(_printInfo['total'])}"),
                  _twoContentRow(
                      "税抜", "¥ ${formatSum(_printInfo['noTaxTotal'])}"),
                  _twoContentRow(
                      "消費税", "¥ ${formatSum(_printInfo['taxTotal'])}"),
                  _twoContentRow(
                      "8%対象", "¥ ${formatSum(_printInfo['taxTotalA'])}",
                      leading: 45.0),
                  _twoContentRow(
                      "10%対象", "¥ ${formatSum(_printInfo['taxTotalB'])}",
                      leading: 45.0),
                  // _twoContentRow("注文件数", "${formatSum(_printInfo['qty'])}"),
                  // _twoContentRow("8%対象", "${formatSum(_printInfo['qtyA'])}",
                  //     leading: 45.0),
                  // _twoContentRow("10%対象", "${formatSum(_printInfo['qtyB'])}",
                  //     leading: 45.0),
                  //_twoContentRow("返金額", "¥ ${formatSum(printInfo['repaymentTotal'])}"),
                  _twoContentRow(
                      "返金件数", "${formatSum(_printInfo['repaymentQty'])}"),

                  Container(
                    margin: EdgeInsets.only(top: 20),
                    height: 2,
                    color: Colors.black,
                  ),
                  _twoContentRow(
                      "現金", "¥ ${formatSum(_printInfo['cashTotal'])}"),
                  _twoContentRow(
                      "クレジット", "¥ ${formatSum(_printInfo['creditCardTotal'])}"),
                  _twoContentRow(
                      "PayPay", "¥ ${formatSum(_printInfo['payPayTotal'])}"),
                  _twoContentRow(
                      "AliPay", "¥ ${formatSum(_printInfo['aliPayTotal'])}"),
                  _twoContentRow(
                      "WeChatPay", "¥ ${formatSum(_printInfo['wechatTotal'])}"),
                  _twoContentRow(
                      "r_Pay", "¥ ${formatSum(_printInfo['r_PayTotal'])}"),
                  _twoContentRow(
                      "au_Pay", "¥ ${formatSum(_printInfo['au_PayTotal'])}"),
                  _twoContentRow(
                      "d_Pay", "¥ ${formatSum(_printInfo['d_PayTotal'])}"),
                  _twoContentRow(
                      "m_Pay", "¥ ${formatSum(_printInfo['m_PayTotal'])}"),
                  // _twoContentRow(
                  //     "交通系", "¥ ${formatSum(printInfo['trafficTotal'])}"),
                ],
              )),
        ),

        // Container(
        //   margin: EdgeInsets.only(top: 20, left: 40, right: 40),
        //   height: 2,
        //   color: Colors.black,
        // ),

        // if (printInfo['cashInfo'] != null &&
        //     (printInfo['cashInfo'] is Map && !printInfo['cashInfo'].isEmpty))
        //   _normalTitle("釣銭機情報"),

        // if (printInfo['cashInfo'] != null &&
        //     (printInfo['cashInfo'] is Map && !printInfo['cashInfo'].isEmpty))
        //   _cashInfoTable(printInfo['cashInfo']),

        // if (printInfo['cashInfoGlory'] != null &&
        //     (printInfo['cashInfoGlory'] is Map &&
        //         !printInfo['cashInfoGlory'].isEmpty))
        //   _normalTitle("釣銭機情報"),

        // if (printInfo['cashInfoGlory'] != null &&
        //     (printInfo['cashInfoGlory'] is Map &&
        //         !printInfo['cashInfoGlory'].isEmpty))
        //   _cashInfoTable(printInfo['cashInfoGlory']),
      ],
    );
  }

  Widget _normalTitle(String title, {alignment = Alignment.center}) {
    return Container(
        alignment: alignment,
        margin: EdgeInsets.only(top: 20),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            title,
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(28),
                fontFamily: GFont.getFontFamily(),
                color: Colors.black,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ));
  }

  Widget _twoContentRow(String title, String content, {leading = 0.0}) {
    return Container(
      padding: EdgeInsets.only(left: leading),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              margin: EdgeInsets.only(top: 20),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(26),
                      fontFamily: GFont.getFontFamily(),
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              )),
          Container(
              margin: EdgeInsets.only(top: 20),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  content,
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(26),
                      fontFamily: GFont.getFontFamily(),
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              )),
        ],
      ),
    );
  }

  _cashInfoGloryTables(cashInfo) {
    var displayInfo = [];
    num totalCount = 0;
    num totalAmount = 0;

    cashInfo.forEach((key, value) {
      // String key = entry.key;
      // Map value = entry.value;
      totalCount += value;
      totalAmount += value * getCatVal(key);
      displayInfo.add([key, value, formatSum(value * getCatVal(key))]);
    });

    debugPrint('displayInfo: $displayInfo');

    return Table(
      border: TableBorder.all(
          width: 2.0, color: const Color.fromARGB(255, 43, 42, 42)),
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(100.0),
        1: FlexColumnWidth(150.0),
        2: FlexColumnWidth(150.0),
      },
      children: <TableRow>[
        _tableRow(['金種', '残り', '金額'],
            backgroundColor: isPrint ? Colors.white : Colors.grey[200]),
        ...displayInfo
            .map((content) => _tableRow(content, alignment: Alignment.center))
            .toList(growable: false),
        _tableRow(['合計', '$totalCount', '¥ ${formatSum(totalAmount)}'])
      ],
    );
  }

  _cashInfoTables(cashInfo) {
    int totalOrigin = 0;
    int totalIncome = 0;
    int totalRemain = 0;
    final displayInfo = cashInfo.entries.map((entry) {
      String key = entry.key;
      Map value = entry.value;
      final cashValue = getCatVal(key);
      totalOrigin += (int.tryParse(value['backup']) ?? 0)*cashValue;
      totalIncome += (int.tryParse(value['income']) ?? 0)*cashValue;
      totalRemain += (int.tryParse(value['remain']) ?? 0)*cashValue;
      return [
        key,
        value['backup'] ?? '',
        value['income'] ?? '',
        value['remain'] ?? '',
      ];
    }).toList();

    return Table(
      border: TableBorder.all(
          width: 2.0, color: const Color.fromARGB(255, 43, 42, 42)),
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(100.0),
        1: FlexColumnWidth(150.0),
        2: FlexColumnWidth(150.0),
        3: FlexColumnWidth(150.0),
      },
      children: <TableRow>[
        _tableRow(['金種', '予備', '入金', '残り'],
            backgroundColor: isPrint ? Colors.white : Colors.grey[200]),
        ...displayInfo
            .map((content) => _tableRow(content, alignment: Alignment.center))
            .toList(growable: false),
        _tableRow([
          '総額',
          '${formatSum(totalOrigin)}',
          '${formatSum(totalIncome)}',
          '${formatSum(totalRemain)}'
        ], alignment: Alignment.centerRight)

      ],
    );
  }

  _cashInfoTableBody(Map cashInfoList) {
    return Table(
      border: TableBorder.all(width: 1.0, color: Colors.grey.shade400),
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(100.0),
        // 1: FlexColumnWidth(150.0),
        // 2: FixedColumnWidth(100.0),
        // 3: FlexColumnWidth(200.0),
      },
      children: <TableRow>[
        //使用 cashInfoList 初始化 _oneWithMultipleSubTableRows
        ...cashInfoList.entries
            .map(
                (entry) => _oneWithMultipleSubTableRows(entry.key, entry.value))
            .toList(growable: false),
      ],
    );
  }

  Widget _cashInfoTable(Map cashInfo) {
    return Container(
        padding: EdgeInsets.only(
          top: 20,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Platform.isAndroid
              ? _cashInfoTables(cashInfo)
              : _cashInfoGloryTables(cashInfo),
        ));
  }

  _menuSaleInfoTable(List<List<String>> contentList) {
    return Container(
        padding: EdgeInsets.only(
          top: 20,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Table(
            border: TableBorder.all(width: 1.0, color: Colors.grey.shade400),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(180.0),
              1: FixedColumnWidth(150.0),
              2: FlexColumnWidth(200.0),
            },
            children: <TableRow>[
              _tableRow(['メニュー名', '売数', '金額'],
                  backgroundColor: isPrint ? Colors.white : Colors.grey[200]),
              ...contentList
                  .map((content) => _tableRow(content))
                  .toList(growable: false),
            ],
          ),
        ));
  }

  TableRow _tableRow(List<dynamic> contentList,
      {backgroundColor = Colors.white, alignment = Alignment.center}) {
    return TableRow(
      children: contentList
          .map((content) => _tableItem(content,
              backgroundColor: backgroundColor, alignment: alignment))
          .toList(growable: false),
    );
  }

  TableRow _oneWithMultipleSubTableRows(
      String title, List<List<String>> contentList,
      {backgroundColor = Colors.white}) {
    return TableRow(
      children: [
        _tableItem(title),
        _subTable(contentList),
      ],
    );
  }

  Table _subTable(List<List<String>> contentList) {
    return Table(
      border: TableBorder.all(width: 1.0, color: Colors.grey.shade400),
      columnWidths: const <int, TableColumnWidth>{
        0: FlexColumnWidth(150.0),
        1: FixedColumnWidth(100.0),
        2: FlexColumnWidth(200.0),
      },
      children: contentList
          .map((content) => _tableRow(content))
          .toList(growable: false),
    );
  }

  Widget _tableItem(content,
      {backgroundColor = Colors.white, alignment = Alignment.center}) {
    return Container(
        padding: EdgeInsets.all(8.0),
        height: 60,
        alignment: alignment,
        color: backgroundColor,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Text("$content",
              style: TextStyle(
                fontFamily: GFont.getFontFamily(),
                fontSize: ScreenAdapter.fontSize(24),
                fontWeight: FontWeight.w400,
                color: Colors.black,
              )),
        ));
  }
}
