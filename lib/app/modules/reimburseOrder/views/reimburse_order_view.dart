import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/num_pad.dart';
import '../controllers/reimburse_order_controller.dart';

class ReimburseOrderView extends GetView<ReimburseOrderController> {
  final ReimburseOrderController controller = Get.put(ReimburseOrderController());
  ReimburseOrderView({Key? key}) : super(key: key);

  showOrderInfo(){
    return controller.orderList.value.length >0 ?ListView.builder(
      shrinkWrap: true,
        padding: EdgeInsets.only(
            left:ScreenAdapter.width(10),
            top:ScreenAdapter.width(5),
            right:ScreenAdapter.width(5)),
        itemCount: controller.orderList.value.length,
        itemBuilder: (context, index) {
          var itemDetail = controller.orderList.value[index];
          var showexecuteMarkText = (itemDetail["executeMark"] == true) ? "允许":"不允许";

          return Container(
            width: ScreenAdapter.width(600),
            height: ScreenAdapter.height(200),
            margin: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
            padding: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(3), bottom: ScreenAdapter.height(3)),
            decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: ColorsUtil.hexToColor("#9d9d9d"), blurRadius: 4)],
              color: ColorsUtil.hexToColor("#FFFFFF"),
              borderRadius: BorderRadius.all(Radius.circular(4.0)),
            ),
            child: Row(
              children: [
                Container(
                  width: ScreenAdapter.width(400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("注文番号:${itemDetail["orderIdStr"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenAdapter.fontSize(26.0),
                            color: ColorsUtil.hexToColor("#000000"),
                          )
                      ),
                      Text("支付时间:${itemDetail["payTime"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenAdapter.fontSize(26.0),
                            color: ColorsUtil.hexToColor("#000000"),
                          )
                      ),
                      Text("支付金额:${itemDetail["amount"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenAdapter.fontSize(26.0),
                            color: ColorsUtil.hexToColor("#000000"),
                          )
                      ),
                      Text("支付类型:${itemDetail["payChannel"]}",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenAdapter.fontSize(26.0),
                            color: ColorsUtil.hexToColor("#000000"),
                          )
                      ),
                      Text("是否允许支付:${showexecuteMarkText}",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: ScreenAdapter.fontSize(26.0),
                            color: ColorsUtil.hexToColor("#000000"),
                          )
                      )
                    ],
                  ),
                ),
                if(itemDetail["executeMark"] == true || (itemDetail["executeMark"] == false && itemDetail["requestMessage"] != ""))
                InkWell(
                  enableFeedback: false,
                  onTap: () {
                    controller.refoundOrderAlert(itemDetail);
                  },
                  child: Container(
                    width: ScreenAdapter.width(120),
                    height: ScreenAdapter.height(85),
                    //margin: EdgeInsets.only(bottom: ScreenAdapter.height(10)),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(

                      color: ColorsUtil.hexToColor("#A61C1C"),
                      //设置圆角
                      borderRadius: new BorderRadius.circular((16.0)),
                    ),
                    child: Text(
                        "退款",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(28),
                          fontWeight: FontWeight.w600,
                          color: ColorsUtil.hexToColor(
                              Gcolor.settlementBtnColor),
                        )),
                  ),
                )
              ],
            ),
          );
        }): Container(height: 0,);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text("システム設定")),
      body: GetBuilder<ReimburseOrderController>(builder: (controller){
        return controller.obx((state) => ListView(
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
                      controller.reimburseText.value,
                      style: TextStyle(
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
                              hintStyle: TextStyle(fontSize: ScreenAdapter.fontSize(24)),
                              hintText: "请填写6位注文番号",
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
                        controller.orderIdController.text = controller.orderIdController.text.substring(0, controller.orderIdController.text.length - 1);
                      },
                      // do something with the input numbers
                      onSubmit: () {print("5435345");
                      if(controller.orderIdController.text.length <6){
                        showToast("正しいパスワードを入力してください");
                        return;
                      }
                      if(controller.orderIdController.text.length >6){
                        showToast("最大6位");
                        controller.orderIdController.text = controller.orderIdController.text.substring(0, 5);
                        return;
                      }

                      controller.queryOrder();

                      },
                    ),
                  ),

                  Divider(
                    thickness: 2.5,
                    color: Colors.black12,
                  ),
                  Container(
                    width: ScreenAdapter.width(600),
                    child: showOrderInfo(),
                  ),



                ],
              ),
            ),
          ],
        ),
          onLoading: Center(
            child: CircularProgressIndicator(
              strokeWidth:6,
              valueColor:new AlwaysStoppedAnimation<Color>(ColorsUtil.hexToColor("#80B646")),
            ),
          ),
        );
      }),
    );
  }
}
