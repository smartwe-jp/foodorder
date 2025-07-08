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

class Exchangeview extends StatelessWidget {
  final SettingController controller;
  Exchangeview({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          child: exchangeAlert(context),
        ));
  }

  cashInfoGrid() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "両替したい金種を選択してください",
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
            children: [
              ...controller.cashInfoList.entries.where((element) {
                return element.key != '二千円';
              }).map((element) {
                return moneyItem(element.key, element.value);
              }).toList()
            ],
            crossAxisCount: 2,
            childAspectRatio: 4,
          )
        ]);
  }

  exchangeView() {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          //提示両替只可以替换出一千，五千，一万的纸币
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "両替金種：${controller.exchangeFromInfo.keys.first}",
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              Text(
                "在庫数：${controller.exchangeFromInfo.values.first}",
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          SizedBox(
            height: 20,
          ),

          //请投入金额
          if (controller.isStartPutMoney.value)
            Text(
              controller.tipsTitle(),
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(26),
                  fontFamily: GFont.getFontFamily(),
                  color: ColorsUtil.hexToColor("#ff0000"),
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),

          SizedBox(
            height: 20,
          ),
          //创建一个双列显示moneyItem的grid 列表，使用 cashInfo map value 作为数据源

          if (controller.canExchange())
            Column(
              children: [
                if (controller.getExchange().length == 3)
                  exchangeItem(controller.getExchange()[0].toString(),
                      controller.getExchange()[1], controller.getExchange()[2])
              ],
            ),

          if (!controller.canExchange())
            Text(
              "両替できるお金がありません",
              style: TextStyle(
                  fontSize: ScreenAdapter.fontSize(26),
                  fontFamily: GFont.getFontFamily(),
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),

          //补充金额总和显示
          //if (controller.canExchange())
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "投入金額：",
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              Text(
                "${formatSum(controller.getPutMoney.value)} 円",
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          SizedBox(
            height: 20,
          ),
          //取消按钮
          if (!controller.canExchange())
            Container(
              width: ScreenAdapter.width(680),
              height: ScreenAdapter.height(80),
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                child: Text("キャンセル",
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(26),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#ffffff"),
                    )),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(ColorsUtil.hexToColor("#A61C1C")),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
            ),

          //开始补钱按钮controller.startDeposit();

          if (!controller.isStartPutMoney.value && controller.canExchange())
            Container(
              width: ScreenAdapter.width(680),
              height: ScreenAdapter.height(80),
              child: ElevatedButton(
                onPressed: () async {
                  await controller.startPutExchangeMoney();
                },
                child: Text("投入開始",
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(26),
                      fontWeight: FontWeight.w600,
                      color: ColorsUtil.hexToColor("#ffffff"),
                    )),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(ColorsUtil.hexToColor("#A61C1C")),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0))),
                ),
              ),
            ),

          if (controller.isStartPutMoney.value)
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: ScreenAdapter.height(80),
                    child: ElevatedButton(
                      onPressed: () async {
                        //await controller.cancelReplanish();
                        controller.cancelTimer(shouldBack: false);
                      },
                      // onLongPress: () async {
                      //   controller.clearTask();
                      //   Get.back();
                      // },
                      child: Text("キャンセル",
                          style: TextStyle(
                            fontFamily: GFont.getFontFamily(),
                            fontSize: ScreenAdapter.fontSize(26),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor("#ffffff"),
                          )),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            ColorsUtil.hexToColor("#A61C1C")),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),
                  ),
                ),
                // SizedBox(
                //   width: 20,
                // ),
                // Expanded(
                //     child: Container(
                //   height: ScreenAdapter.height(80),
                //   child: ElevatedButton(
                //     onPressed: () {
                //       if (controller.getPutMoney.value > 0) {
                //         controller.reportReplanishInfo(
                //             controller.moneyMap.value, context);
                //       }
                //     },
                //     child: Text("確認",
                //         style: TextStyle(
                //           fontFamily: GFont.getFontFamily(),
                //           fontSize: ScreenAdapter.fontSize(26),
                //           fontWeight: FontWeight.w600,
                //           color: ColorsUtil.hexToColor("#ffffff"),
                //         )),
                //     style: ButtonStyle(
                //       backgroundColor: WidgetStateProperty.all(
                //           controller.getPutMoney.value > 0
                //               ? ColorsUtil.hexToColor("#409eff")
                //               : Colors.grey),
                //       shape: WidgetStateProperty.all(
                //           RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(5.0))),
                //     ),
                //   ),
                // )),
              ],
            )
        ]);
  }

  exchangeAlert(context) {
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
                  "両替",
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(38),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 20,
                ),
                if (!controller.isStartPutMoney.value) cashInfoGrid(),
                if (controller.isStartPutMoney.value) exchangeView(),
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
        // if (controller.isStartPutMoney.value)
        //   Positioned(
        //     left: ScreenAdapter.width(5),
        //     child: InkWell(
        //       highlightColor: Colors.transparent, // 透明色
        //       splashColor: Colors.transparent, // 透明色
        //       onTap: () {
        //         controller.isStartPutMoney.value = false;
        //       },
        //       child: Icon(
        //         Icons.arrow_back,
        //         color: ColorsUtil.hexToColor("#000000"),
        //         size: 40.0,
        //       ),
        //     ),
        //   )
      ])
    ]);
  }

  Widget exchangeItem(String moneyType, int moneyCount, int changeCount) {
    return Container(
      height: ScreenAdapter.height(100),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: ScreenAdapter.width(200),
            height: ScreenAdapter.height(60),
            child: ElevatedButton(
              onPressed: () {},
              child: Text(
                moneyType,
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    color: ColorsUtil.hexToColor("#ffffff"),
                    fontWeight: FontWeight.w600),
              ),
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(ColorsUtil.hexToColor("#00cc9e")),
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
          ),
          Container(
            //width: ScreenAdapter.width(100),
            height: ScreenAdapter.height(60),
            child: ElevatedButton(
              onPressed: () async {
                //if (changeCount == 0) {
                await controller.exchangeFlow(
                    moneyType, moneyCount, changeCount);
                //}
              },
              child: Text(
                "両替",
                style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(26),
                    fontFamily: GFont.getFontFamily(),
                    color: ColorsUtil.hexToColor("#ffffff"),
                    fontWeight: FontWeight.w600),
              ),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(changeCount == 0
                    ? ColorsUtil.hexToColor("#409eff")
                    : ColorsUtil.hexToColor("#409eff")),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
          ),
        ],
      ),
    );
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
        return moneyCount > 10000;
      case '五千円':
        return moneyCount > 0;
      case '一万円':
        return moneyCount > 0;
      default:
        return false;
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
                if (_canExchange(moneyType, moneyCount)) {
                  controller.exchangeFromInfo = {moneyType: moneyCount};
                  controller.startPutExchangeMoney();
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
                    _canExchange(moneyType, moneyCount)
                        ? ColorsUtil.hexToColor("#409eff")
                        : Colors.grey),
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
