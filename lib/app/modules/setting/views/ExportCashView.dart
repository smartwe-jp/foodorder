
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/grid_item_view.dart';
import 'package:foodorder/app/modules/setting/controllers/exchange_controller_extension.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller.dart';
import 'package:foodorder/app/modules/setting/controllers/setting_controller_extension.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ExportCashView extends StatelessWidget {
  final SettingController controller;
  ExportCashView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          child: exchangeAlert(),
        ));
  }

  cashInfoGrid() {
    final cashItems = controller.cashInfoList.entries
        .where((element) => element.key != '三千円')
        .toList();
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "出金したい金種を選択してください",
            style: TextStyle(
                color: ColorsUtil.hexToColor("#A61C1C"),
                fontSize: ScreenAdapter.fontSize(26),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: ScreenAdapter.height(40),
          ),
          GridMenuView(
            itemCount: cashItems.length,
            itemBuilder: (context, index) {
              final item = cashItems[index];
              return moneyItem(item.key, item.value);
            },
            crossAxisCount: 2,
            childAspectRatio: 4,
          )
        ]);
  }

  //out cash dialog

  outCashDialog(String moneyType, int moneyCount) {
    String inputValue = "0";

    Get.dialog(
      StatefulBuilder(builder: (context, setState) {
        void updateInput(String value) {
          setState(() {
            if (inputValue == "0") {
              inputValue = value;
            } else {
              inputValue += value;
            }
          });
        }

        void deleteInput() {
          setState(() {
            if (inputValue.length > 1) {
              inputValue = inputValue.substring(0, inputValue.length - 1);
            } else {
              inputValue = "0";
            }
          });
        }

        void fillAll() {
          setState(() {
            inputValue = moneyCount.toString();
          });
        }

        bool canConfirm() {
          final parsed = int.tryParse(inputValue) ?? 0;
          return parsed > 0 && parsed <= moneyCount;
        }

        Widget buildKey(String label, {VoidCallback? onTap}) {
          return Expanded(
              child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: SizedBox(
              height: ScreenAdapter.height(80),
              child: ElevatedButton(
                onPressed: onTap,
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                  backgroundColor:
                      WidgetStateProperty.all(ColorsUtil.hexToColor("#f5f5f5")),
                  foregroundColor:
                      WidgetStateProperty.all(ColorsUtil.hexToColor("#333333")),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(26),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ));
        }

        return SimpleDialog(children: [
          Container(
            width: ScreenAdapter.width(680),
            padding: EdgeInsets.symmetric(
                horizontal: ScreenAdapter.width(30),
                vertical: ScreenAdapter.height(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "出金",
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(32),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "(出金可能数量：$moneyCount)",
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(24),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w400,
                          color: Colors.red),
                    ),
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(
                          Icons.close_outlined,
                          color: ColorsUtil.hexToColor("#000000"),
                        ))
                  ],
                ),
                SizedBox(height: ScreenAdapter.height(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("金種：$moneyType",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(26),
                            fontFamily: GFont.getFontFamily(),
                            fontWeight: FontWeight.w600)),
                    Text("数量：$moneyCount",
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(26),
                            fontFamily: GFont.getFontFamily(),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: ScreenAdapter.height(20)),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenAdapter.width(16),
                            vertical: ScreenAdapter.height(18)),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          inputValue,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(32),
                              fontFamily: GFont.getFontFamily(),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    SizedBox(width: ScreenAdapter.width(12)),
                    SizedBox(
                      height: ScreenAdapter.height(68),
                      child: ElevatedButton(
                        onPressed: fillAll,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                              ColorsUtil.hexToColor("#409eff")),
                          shape: WidgetStateProperty.all(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6))),
                        ),
                        child: Text(
                          "全部",
                          style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(24),
                              fontFamily: GFont.getFontFamily(),
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: ScreenAdapter.height(20)),
                Column(
                  children: [
                    for (var row in [
                      ["1", "2", "3"],
                      ["4", "5", "6"],
                      ["7", "8", "9"],
                      ["0", "", "削除"]
                    ])
                      Row(
                        children: row.map((label) {
                          if (label == "") {
                            return Expanded(child: SizedBox());
                          }
                          if (label == "削除") {
                            return buildKey(label, onTap: deleteInput);
                          }
                          return buildKey(label, onTap: () => updateInput(label));
                        }).toList(),
                      ),
                  ],
                ),
                SizedBox(height: ScreenAdapter.height(20)),
                SizedBox(
                  height: ScreenAdapter.height(80),
                  child: ElevatedButton(
                    onPressed: canConfirm() ? () {
                      controller.exportCashFlow(moneyType, int.parse(inputValue));
                    } : null,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          canConfirm()
                              ? ColorsUtil.hexToColor("#409eff")
                              : Colors.grey),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                    ),
                    child: Text(
                      "確認",
                      style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(26),
                          fontFamily: GFont.getFontFamily(),
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          )
        ]);
      }),
      barrierDismissible: false,
    );
  }

  exchangeAlert() {
    return SimpleDialog(children: <Widget>[
      Stack(alignment: Alignment.topCenter, children: <Widget>[
        Container(
            alignment: Alignment.center,
            width: ScreenAdapter.width(680),
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(30),
                right: ScreenAdapter.width(30),
                bottom: ScreenAdapter.height(30)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "出金操作",
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(38),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                cashInfoGrid(),
              ],
            )),
        if (!controller.isStartPutMoney.value)
          Positioned(
            right: ScreenAdapter.width(5),
            child: InkWell(
              highlightColor: Colors.transparent, // 透明色
              splashColor: Colors.transparent, // 透明色
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.close_outlined,
                color: ColorsUtil.hexToColor("#000000"),
                size: 40.0,
              ),
            ),
          ),
      ])
    ]);
  }


  String formatSum(int sum) {
    final formatter = NumberFormat('#,###');
    return formatter.format(sum);
  }

  _canExchange(String moneyType, int moneyCount) {
    switch (moneyType) {
      case '一円':
        return moneyCount > 1;
      case '五円':
        return moneyCount > 1;
      case '十円':
        return moneyCount > 1;
      case '五十円':
        return moneyCount > 1;
      case '百円':
        return moneyCount > 1;
      case '五百円':
        return moneyCount > 1;
      case '千円':
        return moneyCount > 1;
      case '二千円':
        return moneyCount > 1;
      case '五千円':
        return moneyCount > 1;
      case '一万円':
        return moneyCount > 1;
      default:
        return false;
    }
  }

  Color _getButtonColor(String moneyType, int moneyCount) {
    if (_canExchange(moneyType, moneyCount)) {
      return ColorsUtil.hexToColor("#409eff");
    } else {
      return Colors.grey;
    }
  }

  //钱币信息显示Item 显示币种和数量 币种使用圆弧按钮显示 数量使用文本显示
  Widget moneyItem(String moneyType, int moneyCount) {
    return Container(
      width: ScreenAdapter.width(100),
      height: ScreenAdapter.height(100),
      child: Row(
        children: <Widget>[
          Container(
            width: ScreenAdapter.width(200),
            height: ScreenAdapter.height(60),
            child: ElevatedButton(
              onPressed: () {
                if (moneyCount > 0) {
                  outCashDialog(moneyType, moneyCount);
                }
              },
              child: Text(
                moneyType,
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    color: ColorsUtil.hexToColor("#ffffff"),
                    fontWeight: FontWeight.w600),
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    _getButtonColor(moneyType, moneyCount)),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Text(
            moneyCount.toString(),
            style: TextStyle(
                fontSize: ScreenAdapter.fontSize(26),
                fontFamily: GFont.getFontFamily(),
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
