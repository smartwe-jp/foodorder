
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../services/showToast.dart';
import '../../../widget/num_pad.dart';
import '../controllers/receipt_query_controller.dart';

class ReceiptQueryView extends GetView<ReceiptQueryController> {



  ReceiptQueryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ReceiptQueryController>(
        builder: (controller) {
          return controller.obx((state) =>
              ListView(
                children: <Widget>[

                  Container(
                    decoration: new BoxDecoration(color: Colors.white),
                    width: ScreenAdapter.width(820.0),
                    margin: EdgeInsets.only(
                      top: ScreenAdapter.height(30.0),
                    ),
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(
                      top: ScreenAdapter.height(5.0),
                      left: ScreenAdapter.width(20.0),
                      right: ScreenAdapter.width(20.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            /*Navigator.of(context).pushAndRemoveUntil(
                              new MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return new HomePage();
                                },
                              ),
                              (Route route) => false,
                            );*/
                            Get.back();
                            /*Future.delayed(Duration(milliseconds: 100), () {
                              Navigator.pushNamed(context, '/home');
                            });*/
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: ScreenAdapter.width(10),
                                right: ScreenAdapter.width(10)),
                            width: ScreenAdapter.width(120),
                            height: ScreenAdapter.height(65),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ColorsUtil.hexToColor("#67c23a"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            child: Text("戻る",
                                style: TextStyle(
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: ScreenAdapter.fontSize(24),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor("#FFFFFF"),
                                )),
                          ),
                        ),

                      ],
                    ),
                  ),
                  Container(
                    decoration: new BoxDecoration(color: Colors.white),
                    margin: EdgeInsets.only(
                      top: ScreenAdapter.height(10.0),
                    ),
                    padding: EdgeInsets.only(
                        top: ScreenAdapter.height(5.0),
                        left: ScreenAdapter.width(14.0),
                        right: ScreenAdapter.width(14.0),
                        bottom: ScreenAdapter.height(30)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: ScreenAdapter.height(5)),
                          alignment: Alignment.center,
                          child: Text(
                            controller.orderText.value,
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize: ScreenAdapter.fontSize(26),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor("#000000"),
                            ),
                          ),
                        ),
                        Container(
                          width: ScreenAdapter.width(500),
                          padding: const EdgeInsets.all(20),
                          child: SizedBox(
                            height: 70,
                            child: Center(
                                child: TextField(
                                  controller: controller.orderIdController,
                                  textAlign: TextAlign.center,
                                  showCursor: false,
                                  style: const TextStyle(fontSize: 40),
                                  // Disable the default soft keybaord
                                  keyboardType: TextInputType.none,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(fontFamily: GFont.getFontFamily(),fontSize: ScreenAdapter.fontSize(24)),
                                    hintText: "注文番号の後ろ六桁を入力してください",
                                    //border: InputBorder.none
                                  ),
                                )),
                          ),
                        ),
                        Container(
                          width: ScreenAdapter.width(600),
                          margin: EdgeInsets.only(bottom: ScreenAdapter.height(30)),
                          child: NumPad(
                            buttonSize: 70,
                            buttonColor: ColorsUtil.hexToColor("#f1f3f4"),
                            iconColor: ColorsUtil.hexToColor("#9C9C9C"),
                            controller: controller.orderIdController,
                            textLength: 6,
                            delete: () {
                              if(controller.orderIdController.text.length >1){
                                controller.orderIdController.text = controller.orderIdController.text.substring(0, controller.orderIdController.text.length - 1);
                              }else if(controller.orderIdController.text.length ==1){
                                controller.orderIdController.text = "";
                              }
                            },
                            // do something with the input numbers
                            onSubmit: () {
                              if(controller.orderIdController.text.length <6){
                                showToast("注文番号の後ろ六桁を入力してください");
                                return;
                              }
                              if(controller.orderIdController.text.length >6){
                                showToast("最大6位");
                                controller.orderIdController.text = controller.orderIdController.text.substring(0, 5);
                                return;
                              }

                              controller.getReceiptList();

                            },
                          ),
                        ),

                        Divider(
                          thickness: 2.5,
                          color: Colors.black12,
                        ),
                        Container(
                          width: ScreenAdapter.width(710),
                          child: showOrderInfo(),
                        ),



                      ],
                    ),
                  ),
                ],
              ),
            onLoading: Center(child: CircularProgressIndicator()),
          );
        }

      ),

    );
  }

  showOrderInfo(){
    return controller.receiptList.value.length >0 ?ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.only(
            left:ScreenAdapter.width(10),
            top:ScreenAdapter.width(5),
            right:ScreenAdapter.width(5)),
        itemCount: controller.receiptList.value.length,
        itemBuilder: (context, index) {
          var itemDetail = controller.receiptList.value[index];
          //var showexecuteMarkText = (itemDetail["executeMark"] == true) ? "允许":"不允许";
          GlobalKey containerKey = GlobalKey();
          return Container(
            //width: ScreenAdapter.width(800),
            //height: ScreenAdapter.height(200),
            margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
            padding: EdgeInsets.only(left: ScreenAdapter.width(15),right:ScreenAdapter.width(15),top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(10)),
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9d9d9d"), blurRadius: 4)],
              color: ColorsUtil.hexToColor("#FFFFFF"),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Row(
              children: [
                // Container(//退款小票信息，计算大小用，不显示。
                //   child: Offstage(
                //     offstage: true,//不显示
                //     child: Container(
                //       key: containerKey,
                //       alignment: Alignment.centerRight,
                //       child: ReimbursePrintView(reimburseInfo: itemDetail),
                //     ),
                //   ),
                // ),
                //_construtReceiptView(itemDetail),
                Container(
                  width: ScreenAdapter.width(470),
                  child: Table(
                    border: TableBorder.all(width: 0,style: BorderStyle.none),
                    columnWidths: <int, TableColumnWidth>{
                      //0: IntrinsicColumnWidth(),
                      0:FlexColumnWidth(320),
                      1: FixedColumnWidth(320),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          TableCell(
                              child: Container(
                                //color: Colors.blue,
                                //height: ScreenAdapter.height(65),
                                //width: ScreenAdapter.width(235),
                                alignment: Alignment.centerLeft,
                                child: Text("注文番号:",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenAdapter.fontSize(26.0),
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )
                                ),
                              )
                          ),
                          TableCell(
                              child: Container(
                                //height: ScreenAdapter.height(65),
                                alignment: Alignment.centerRight,
                                child: Text("${itemDetail["orderIdStr"]}",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenAdapter.fontSize(26.0),
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )
                                ),
                              )
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          TableCell(
                              child: Container(
                                //color: Colors.blue,
                                //height: ScreenAdapter.height(65),
                                //width: ScreenAdapter.width(335),
                                alignment: Alignment.centerLeft,
                                child: Text("支払時間:",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenAdapter.fontSize(26.0),
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )
                                ),
                              )
                          ),
                          TableCell(
                              child: Container(
                                //height: ScreenAdapter.height(65),
                                alignment: Alignment.centerRight,
                                child: Text("${itemDetail["payTime"]}",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenAdapter.fontSize(26.0),
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )
                                ),
                              )
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          TableCell(
                              child: Container(
                                //color: Colors.blue,
                                //height: ScreenAdapter.height(65),
                                //width: ScreenAdapter.width(335),
                                alignment: Alignment.centerLeft,
                                child: Text("支払金額:",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenAdapter.fontSize(26.0),
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )
                                ),
                              )
                          ),
                          TableCell(
                              child: Container(
                                //height: ScreenAdapter.height(65),
                                alignment: Alignment.centerRight,
                                child: Text(formatMoney(itemDetail["amount"]),
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenAdapter.fontSize(26.0),
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )
                                ),
                              )
                          ),
                        ],
                      ),
                      TableRow(
                        children: <Widget>[
                          TableCell(
                              child: Container(
                                //color: Colors.blue,
                                //height: ScreenAdapter.height(65),
                                //width: ScreenAdapter.width(335),
                                alignment: Alignment.centerLeft,
                                child: Text("支払方法:",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenAdapter.fontSize(26.0),
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )
                                ),
                              )
                          ),
                          TableCell(
                              child: Container(
                                //height: ScreenAdapter.height(65),
                                alignment: Alignment.centerRight,
                                child: Text("${itemDetail["payChannel"]}",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w400,
                                      fontSize: ScreenAdapter.fontSize(26.0),
                                      color: ColorsUtil.hexToColor("#000000"),
                                    )
                                ),
                              )
                          ),
                        ],
                      ),
                      // TableRow(
                      //   children: <Widget>[
                      //     TableCell(
                      //         child: Container(
                      //           //color: Colors.blue,
                      //           //height: ScreenAdapter.height(65),
                      //           //width: ScreenAdapter.width(335),
                      //           alignment: Alignment.centerLeft,
                      //           child: Text("返金額:",
                      //               style: TextStyle(
                      //                 fontFamily: GFont.getFontFamily(),
                      //                 fontWeight: FontWeight.w500,
                      //                 fontSize: ScreenAdapter.fontSize(32.0),
                      //                 color: ColorsUtil.hexToColor("#A61C1C"),
                      //               )
                      //           ),
                      //         )
                      //     ),
                      //     TableCell(
                      //         child: Container(
                      //           //height: ScreenAdapter.height(65),
                      //           alignment: Alignment.centerRight,
                      //           child: Text(formatMoney(itemDetail["amount"]),
                      //               style: TextStyle(
                      //                 fontFamily: GFont.getFontFamily(),
                      //                 fontWeight: FontWeight.w500,
                      //                 fontSize: ScreenAdapter.fontSize(32.0),
                      //                 color: ColorsUtil.hexToColor("#A61C1C"),
                      //               )
                      //           ),
                      //         )
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),


                //if(itemDetail["executeMark"] == true || (itemDetail["executeMark"] == false && itemDetail["requestMessage"] != ""))
                  Container(
                    width: ScreenAdapter.width(190),
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      enableFeedback: false,
                      onTap: () {

                        controller.getReceiptInfo(itemDetail["orderId"]);

                      },
                      child: Container(
                        width: ScreenAdapter.width(160),
                        height: ScreenAdapter.height(145),
                        //margin: EdgeInsets.only(bottom: ScreenAdapter.height(10)),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(

                          color: ColorsUtil.hexToColor("#A61C1C"),
                          //设置圆角
                          borderRadius: new BorderRadius.circular((16.0)),
                        ),
                        child: Text(
                            "再印刷",
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize: ScreenAdapter.fontSize(28),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  Gcolor.settlementBtnColor),
                            )),
                      ),
                    ),
                  )
              ],
            ),
          );
        }): Container();
  }


}