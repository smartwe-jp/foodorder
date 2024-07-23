
import 'package:flutter/material.dart';

import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';

class RejishimePrintView extends StatelessWidget {

  final bool isPrint;

  const RejishimePrintView({super.key, this.isPrint = false});



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return isPrint ? printView() : showView();
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
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
        child: _miroWidget()
    );
  }

  Widget showView() {
    return SingleChildScrollView(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 80),
        child: _miroWidget()
    );
  }

  Widget _miroWidget() {

    return  Column(
            children: [
              _mainTitle("甘蘭牛肉麺 大阪日本橋店"),
              _normalTitle("精算期間：2024年7月1日10:00~2024年7月1日23:00"),

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

                          _twoContentRow("総売上", "¥ 200,000"),
                          _twoContentRow("税抜", "¥ 190,000"),
                          _twoContentRow("消費税", "¥ 10,000"),
                          _twoContentRow("8%对象", "¥ 1000",leading: 45.0),
                          _twoContentRow("10%对象", "¥ 9000",leading: 45.0),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            height: 1,
                            color: ColorsUtil.hexToColor("#9C9C9C"),
                          ),
                          _twoContentRow("現金", "¥ 10,000"),
                          _twoContentRow("クレジットカード", "¥ 1000"),
                          _twoContentRow("電子マネー", "¥ 100"),
                          _twoContentRow("その他", "¥ 100,000"),
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
              _cashInfoTable(
                  {
                    '万円': [
                      ['入金',  '1', '¥ 1000'],
                      ['出金', '1', '¥ 500'],
                    ],
                    '五千円': [
                      ['入金',  '1', '¥ 1000'],
                      ['出金', '1', '¥ 500'],
                    ],
                    '二千円': [
                      ['入金',  '1', '¥ 1000'],
                      ['出金', '1', '¥ 500'],
                    ],
                    '千円': [
                      ['入金',  '1', '¥ 1000'],
                      ['出金', '1', '¥ 500'],
                    ],
                    '百円': [
                      ['入金',  '1', '¥ 1000'],
                      ['出金', '1', '¥ 500'],
                    ],
                    '五十円': [
                      ['入金',  '1', '¥ 1000'],
                      ['出金', '1', '¥ 500'],
                    ],
                    '十円': [
                      ['入金',  '1', '¥ 1000'],
                      ['出金', '1', '¥ 500'],
                    ],
                    '五円': [
                      ['入金',  '1', '¥ 1000'],
                      ['出金', '1', '¥ 500'],
                    ],
                    '一円': [
                      ['入金',  '1', '¥ 1000'],
                      ['出金', '1', '¥ 500'],
                    ],
                  }
              ),
              // Container(
              //   margin: EdgeInsets.only(top: 20, left: 40,right: 40),
              //   height: 1,
              //   color: ColorsUtil.hexToColor("#9C9C9C"),
              // ),

              // _normalTitle("メニュー別売上情報"),
              // _menuSaleInfoTable([
              //   ["メニュー1", "10", "¥ 1000"],
              //   ["メニュー2", "10", "¥ 1000"],
              //   ["メニュー3", "10", "¥ 1000"],
              //   ["メニュー4", "10", "¥ 1000"],
              //   ["メニュー5", "10", "¥ 1000"],
              //   ["メニュー6", "10", "¥ 1000"],
              //   ["メニュー7", "10", "¥ 1000"],
              //   ["メニュー8", "10", "¥ 1000"],
              //   ["メニュー9", "10", "¥ 1000"],
              //   ["メニュー10", "10", "¥ 1000"],
              // ]),


            ],

    );
  }

  Widget _normalTitle(String title) {
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


  _cashInfoTableHeader() {
    return Table(
      border: TableBorder.all(width: 1.0, color: Colors.grey.shade400),
      columnWidths: const <int, TableColumnWidth>{
        0: FixedColumnWidth(100.0),
        1: FlexColumnWidth(150.0),
        2: FixedColumnWidth(100.0),
        3: FlexColumnWidth(200.0),
      },
      children: <TableRow>[
        _tableRow(['金種', '科目', '枚数', '金額'], backgroundColor:  isPrint ? Colors.white : Colors.grey[200]),
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
      child:Column(
          children: [
            _cashInfoTableHeader(),
            _cashInfoTableBody(cashInfo),
          ],
        ),
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

  TableRow _tableRow(List<String> contentList, {backgroundColor = Colors.white}) {
    return TableRow(
      children: contentList
          .map((content) => _tableItem(content, backgroundColor: backgroundColor ))
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

  Widget _tableItem(String content, {backgroundColor = Colors.white}) {
    return Container(
      padding: EdgeInsets.all(8.0),
      height: 60,
      alignment: Alignment.centerLeft,
      color: backgroundColor,
      child: Directionality(
      textDirection: TextDirection.ltr,
      child:Text(content,
            style: TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: ScreenAdapter.fontSize(24),
              fontWeight: FontWeight.w500,
              color: Colors.black,
            )),
    ));
  }

}