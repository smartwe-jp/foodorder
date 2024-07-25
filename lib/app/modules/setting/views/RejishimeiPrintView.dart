
import 'package:flutter/material.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';

class RejishimePrintView extends StatefulWidget {

  final Map printInfo;
  final bool isPrint;
  final Function(double)? lengthUpdate;
  RejishimePrintView({super.key, this.isPrint = false, required this.printInfo, this.lengthUpdate});
  @override
  RejishimePrintViewState createState() => RejishimePrintViewState();
}

class RejishimePrintViewState extends State<RejishimePrintView> {


  ScrollController _scrollController = ScrollController();
  double contentLength = 0.0;
  Map printInfo = {};
  bool isPrint = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return isPrint ? printView() : showView();
  }


  @override
  void initState() {
    printInfo = widget.printInfo;
    isPrint = widget.isPrint;
    super.initState();
    // 在布局完成后获取内容长度
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

  Widget _mainTitle(String title) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Directionality(
      textDirection: TextDirection.ltr,
      child:Text(title,
          style:
          TextStyle(fontSize:
          ScreenAdapter.fontSize(28),
              fontFamily: GFont.getFontFamily(),
              color: Colors.black,
              fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ));
  }


  Widget printView() {
    return Container(
        padding: EdgeInsets.only(left: 0, right: 0, top: 20, bottom: 80),
        child: _miroWidget()
    );
  }

  Widget showView() {
    return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
        child: _miroWidget()
    );
  }

  String formatSum(sum) {
    if (sum == null) return "Unknown";
    List<String> parts = sum.toString().split('.');
    parts[0] = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');
    return parts.join('.');
  }

  Widget _miroWidget() {

    return  Column(
            children: [
              _mainTitle( printInfo['shopName'] ?? "Unknown"),
              _normalTitle("レジ番号 : ${printInfo['machineCode'] ?? "Unknown"}", alignment: Alignment.centerLeft),
              _normalTitle("印字日時 : ", alignment: Alignment.centerLeft),
              _normalTitle("${printInfo['printTime'] ?? "Unknown"}", alignment: Alignment.centerRight),
              _normalTitle("スターフ : ${printInfo['verifyUserName'] ?? "Unknown"}", alignment: Alignment.centerLeft),
              _normalTitle("${printInfo['startTime'] ?? "Unknown"}　から　\n ${printInfo['endTime'] ?? "Unknown"}　まで"),
              //分割线
              Container(
                margin: EdgeInsets.only(top: 20, left: 40,right: 40),
                height: 1,
                color: ColorsUtil.hexToColor("#9C9C9C"),
              ),

              Container(
                //padding: EdgeInsets.only(left: 80,right: 80),
                child:Directionality(
                    textDirection: TextDirection.ltr,
                    child:
                      Column(
                        children: [
                          _normalTitle("販売実績"),

                          _twoContentRow("総売上", "¥ ${formatSum(printInfo['total'])}"),
                          _twoContentRow("税抜", "¥ ${formatSum(printInfo['noTaxTotal'])}"),
                          _twoContentRow("消費税", "¥ ${formatSum(printInfo['taxTotal'])}"),
                          _twoContentRow("8%对象", "¥ ${formatSum(printInfo['taxTotalA'])}",leading: 45.0),
                          _twoContentRow("10%对象", "¥ ${formatSum(printInfo['taxTotalB'])}",leading: 45.0),
                          _twoContentRow("販売数量", "${formatSum(printInfo['qty'])}"),
                          _twoContentRow("8%对象", "${formatSum(printInfo['qtyA'])}",leading: 45.0),
                          _twoContentRow("10%对象", "${formatSum(printInfo['qtyB'])}",leading: 45.0),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            height: 1,
                            color: ColorsUtil.hexToColor("#9C9C9C"),
                          ),
                          _twoContentRow("現金", "¥ ${formatSum(printInfo['cashTotal'])}"),
                          _twoContentRow("クレジット", "¥ ${formatSum(printInfo['creditCardTotal'])}"),
                          _twoContentRow("PayPay", "¥ ${formatSum(printInfo['payPayTotal'])}"),
                          _twoContentRow("AliPay", "¥ ${formatSum(printInfo['aliPayTotal'])}"),
                          _twoContentRow("WeChatPay", "¥ ${formatSum(printInfo['wechatTotal'])}"),
                          _twoContentRow("r_Pay", "¥ ${formatSum(printInfo['r_PayTotal'])}"),
                          _twoContentRow("au_Pay", "¥ ${formatSum(printInfo['au_PayTotal'])}"),
                          _twoContentRow("d_Pay", "¥ ${formatSum(printInfo['d_PayTotal'])}"),
                          _twoContentRow("m_Pay", "¥ ${formatSum(printInfo['m_PayTotal'])}"),
                          _twoContentRow("交通系", "¥ ${formatSum(printInfo['trafficTotal'])}"),
                        ],
                      )
                ),

              ),

              Container(
                margin: EdgeInsets.only(top: 20, left: 40,right: 40),
                height: 1,
                color: ColorsUtil.hexToColor("#9C9C9C"),
              ),

              _normalTitle("現金入出金情報"),
              _cashInfoTable( printInfo['cashInfo'] ?? {}),
            ],

    );
  }

  Widget _normalTitle(String title, {alignment = Alignment.center}) {
    return Container(
      alignment: alignment,
      margin: EdgeInsets.only(top: 20),
      child: Directionality(
      textDirection: TextDirection.ltr,
      child:Text(title,
          style:
          TextStyle(fontSize:
          ScreenAdapter.fontSize(28),
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
      child:
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
            child:
            Directionality(
              textDirection: TextDirection.ltr,
              child:Text(title,
              style:
              TextStyle(fontSize:
              ScreenAdapter.fontSize(24),
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
            child:Text(content,
                      style:
                      TextStyle(fontSize:
                      ScreenAdapter.fontSize(24),
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


  _cashInfoTables(cashInfo) {

    final displayInfo = cashInfo.entries.map((entry) {
      String key = entry.key;
      Map value = entry.value;
      return [
        key,
        value['backup'] ?? '',
        value['income'] ?? '',
        value['remain'] ?? '',
      ];
    }).toList();

    return Table(
      border: TableBorder.all(width: 1.0, color: Colors.grey.shade400),
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(100.0),
        1: FlexColumnWidth(150.0),
        2: FlexColumnWidth(150.0),
        3: FlexColumnWidth(150.0),
      },
      children: <TableRow>[
        _tableRow(['金種', '备份', '入金', '出金'], backgroundColor:  isPrint ? Colors.white : Colors.grey[200]),
        ...displayInfo.map((content) => _tableRow(content, alignment: Alignment.centerRight)).toList(growable: false),

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
        ...cashInfoList.entries.map((entry) => _oneWithMultipleSubTableRows(entry.key, entry.value)).toList(growable: false),
      ],
    );
  }

  Widget _cashInfoTable(Map cashInfo) {

    return Container(
      padding: EdgeInsets.only(top: 20,),
      child: Directionality(
      textDirection: TextDirection.ltr,
      child: _cashInfoTables(cashInfo),
      ));
  }


  _menuSaleInfoTable(List<List<String>> contentList) {
    return Container(
      padding: EdgeInsets.only(top: 20, ),
      child:
    Directionality(
    textDirection: TextDirection.ltr,
    child:
      Table(
        border: TableBorder.all(width: 1.0, color: Colors.grey.shade400),
        columnWidths: const <int, TableColumnWidth>{
          0: FlexColumnWidth(180.0),
          1: FixedColumnWidth(150.0),
          2: FlexColumnWidth(200.0),
        },
        children: <TableRow>[
          _tableRow(['メニュー名', '売数', '金額'], backgroundColor: isPrint ? Colors.white : Colors.grey[200]),
          ...contentList.map((content) => _tableRow(content)).toList(growable: false),

        ],
      ),
    ));
  }

  TableRow _tableRow(List<dynamic> contentList, {backgroundColor = Colors.white, alignment = Alignment.center}) {
    return TableRow(
      children: contentList
          .map((content) => _tableItem(content, backgroundColor: backgroundColor, alignment: alignment))
          .toList(growable: false),
    );
  }

  TableRow _oneWithMultipleSubTableRows(String title, List<List<String>> contentList, {backgroundColor = Colors.white}) {
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

  Widget _tableItem(String content, {backgroundColor = Colors.white, alignment = Alignment.center}) {
    return Container(
      padding: EdgeInsets.all(8.0),
      height: 60,
      alignment: alignment,
      color: backgroundColor,
      child: Directionality(
      textDirection: TextDirection.ltr,
      child:Text(content,
            style: TextStyle(
              fontFamily: GFont.getFontFamily(),
              fontSize: ScreenAdapter.fontSize(24),
              fontWeight: FontWeight.w400,
              color: Colors.black,
            )),
    ));
  }

}