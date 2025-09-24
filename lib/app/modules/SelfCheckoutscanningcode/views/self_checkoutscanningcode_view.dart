import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/fontSize.dart';
import '../../../config/imageData.dart';
import '../../../models/ItemModel.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../widget/DialogUtils.dart';
import '../controllers/self_checkoutscanningcode_controller.dart';

class SelfCheckoutscanningcodeView
    extends GetView<SelfCheckoutscanningcodeController> {
  const SelfCheckoutscanningcodeView({Key? key}) : super(key: key);

  //清空购物车弹出提示、
  showDialogTag(menuId,index) {
    Get.dialog(
        DialogUtils.alert("show_del_cart_item_tag".tr,
            title: "tag_title".tr,
            canceltitle: "show_del_cart_item_no".tr,
            confirmtitle: "show_del_cart_item_yes".tr,
            confirm: () {
              //widget.confirmCallback('确定');
              controller.ordersqlcontroller.removeFromCart(menuId ?? 0);
              //print("Item removed from cart successfully");
              //删除商品声音
              controller.deleteItemSound();
              controller.ordersqlcontroller.getCardList();
              //更改显示购物车价格
              controller.getCartPriceTotal();

              controller.deleteScanCartItems(index);


              Get.back();
            },
            cancle: () {
              Get.back();
            })
    );

    controller.scanQrCodeController.text = "";
    controller.scanQrCodeFocusNode.requestFocus();     // 获取焦点
  }

  Widget generateCartList(item,int index) {
    var tipColor = Gcolor.mainTitleColor;
    return Stack(
      children: [
        Container(
          //height: ScreenAdapter.height(126),
          margin: EdgeInsets.only(left:ScreenAdapter.width(30),right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(15)),
          padding: EdgeInsets.only(left:ScreenAdapter.width(20),top: ScreenAdapter.height(2),right: ScreenAdapter.width(20),bottom: ScreenAdapter.height(12)),
          decoration: BoxDecoration(
            color: Colors.white,
            //设置圆角
            borderRadius: new BorderRadius.circular((15.0)),
            border: Border.all(color: ColorsUtil.hexToColor("#979797"), width: 1.5),
          ),
          //height: ScreenAdapter.height(80),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: InkWell(
                        highlightColor: Colors.transparent, // 透明色
                        splashColor: Colors.transparent, // 透明色
                        onTap: (){
                          //showDialogTag(d.id);
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(5),
                              top: ScreenAdapter.height(4),
                              bottom: ScreenAdapter.height(2)),
                          //width: ScreenAdapter.width(495),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["mainTitle"],
                                style: TextStyle(
                                  fontFamily: GFont.getFontFamily(),
                                    fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitle),
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(tipColor)
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: ScreenAdapter.width(200),
                    //height: ScreenAdapter.height(55.0),
                    margin: EdgeInsets.only(right: ScreenAdapter.width(3)),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(width: 1.0,color: Colors.black)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        //减号
                        //CoustomIconButton(icon: Icons.remove,isAdd: false),
                        InkWell(
                          onTap: (){
                            var cartItem = {
                              "cartId": item["id"],
                              "menuCode": item["menuCode"],
                              "unitPrice": item["unitPrice"],
                              "goodsNum": 1,
                              "qtyBounds":item["qtyBounds"]
                            };
                            if(item["goodsNum"] <=1){
                              showDialogTag(item["id"],index);
                            }else{
                              controller.publicChangeCartMenuCount(cartItem,index,"reduce").then((val) {

                                //更改显示购物车价格
                                controller.getCartPriceTotal();
                              });
                            }

                          },
                          child: Container(

                            width: ScreenAdapter.width(55.0),//是正方形的所以宽和高都是45
                            height: ScreenAdapter.height(50.0),
                            alignment: Alignment.center,//上下左右都居中
                            decoration: BoxDecoration(
                              //color: Colors.white,
                                border: Border(//外层已经有边框了所以这里只设置右边的边框
                                    right:BorderSide(width: 1.0,color: Colors.black12)
                                )
                            ),
                            child: Text(
                              "－",
                              style: TextStyle(
                                fontFamily: GFont.getFontFamily(),
                                fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitleCount),
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        //输入框
                        Container(
                          width: ScreenAdapter.width(85.0),
                          height: ScreenAdapter.height(45.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(width: 1,color: Colors.black12),
                                right: BorderSide(width: 1,color: Colors.black12),
                              )
                          ),
                          child: Text(
                            "${item['goodsNum']}",
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                                fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitleCount),
                                fontWeight: FontWeight.w500,
                                color: ColorsUtil.hexToColor(tipColor)
                            ),
                          ),
                        ),
                        //加号
                        //CoustomIconButton(icon: Icons.add,isAdd: true),
                        InkWell(
                          onTap: (){


                            var cartItem = {
                              "cartId": item["id"],
                              "menuCode": item["menuCode"],
                              "unitPrice": item["unitPrice"],
                              "goodsNum": 1,
                              "qtyBounds":item["qtyBounds"]
                            };
                            controller.publicChangeCartMenuCount(cartItem,index,"add").then((val) {

                              //更改显示购物车价格
                              controller.getCartPriceTotal();

                            });

                          },
                          child: Container(
                            width: ScreenAdapter.width(55.0),//是正方形的所以宽和高都是45
                            height: ScreenAdapter.height(50.0),
                            alignment: Alignment.center,//上下左右都居中

                            child: Text(
                              "＋",
                              style: TextStyle(
                                fontFamily: GFont.getFontFamily(),
                                fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitleCount),
                                fontWeight: FontWeight.w600,
                                color: (item["goodsNum"]==item["qtyBounds"])?Colors.black12:Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: ScreenAdapter.width(15)),
                    //width: ScreenAdapter.width(260),
                    alignment: Alignment.bottomRight,
                    child: Container(
                      //color: Colors.blueGrey,
                      alignment: Alignment.bottomRight,
                      child: RichText(
                        text: TextSpan(
                            text: "¥",//¥GString.getToString(this._checkLanguage, "show_price_front"),
                            style: TextStyle(
                              fontFamily: GFont.getFontFamily(),
                              fontSize: ScreenAdapter.fontSize(30),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              textBaseline: TextBaseline.alphabetic,
                            ),

                            children: [
                              TextSpan(
                                text: formatMoney(item["currentPrice"].toString()),
                                style: TextStyle(
                                  fontFamily: GFont.getFontFamily(),
                                  fontSize: ScreenAdapter.fontSize(40),
                                  fontWeight: FontWeight.w400,
                                  //color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                  textBaseline: TextBaseline.alphabetic,
                                ),
                              ),
                              /*TextSpan(
                                  text: "（${GString.getToString(controller.checkLanguage.value, "show_price_front")}）",
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(50)/2.5,
                                    fontWeight: FontWeight.w600,
                                    color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                    textBaseline: TextBaseline.alphabetic,
                                  ),
                                ),*/
                            ]),
                      ),
                    ),
                  ),


                ],
              ),
            ],
          ),
        ),
        Positioned(
            right: 35,
            top: 2,
            child: InkWell(
              onTap: (){
                showDialogTag(item["id"],index);
              },
              child: Container(
                //width: ScreenAdapter.width(400),
                height: ScreenAdapter.height(50),
                //child: Image.asset(GImage.getImageString("imgpublic", "cartItemCancel"),fit: BoxFit.fitHeight),
                child: Icon(
                  Icons.cancel_outlined,
                  size: 40,
                  color: ColorsUtil.hexToColor('#BF0000'),
                ),
              ),
            )
        )
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsUtil.hexToColor(Gcolor.mainBackground),
      body: GestureDetector(
        onTap: (){
          controller.scanQrCodeController.text = "";
          controller.scanQrCodeFocusNode.requestFocus();     // 获取焦点
        },
        child: GetBuilder<SelfCheckoutscanningcodeController>(builder: (controller){
          return controller.obx((state) => Container(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Container(
                  height: 0,
                  padding: EdgeInsets.only(left: 20),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          child: TextField(
                            keyboardType: TextInputType.text,
                            autofocus: true,
                            showCursor: true, // 显示光标
                            //readOnly: true,
                            controller: controller.scanQrCodeController,
                            focusNode: controller.scanQrCodeFocusNode,
                            decoration: InputDecoration(
                              hintText: "请扫码",
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            style: TextStyle(fontSize: ScreenAdapter.fontSize(21.0)),
                            /*onChanged: (value) {
                            print(value);
                            if(value.length==1){
                              controller.showOrderEasyLoading();
                            }
                          },*/
                            onSubmitted: (value){
                              controller.doScanQrCodeQuery();

                            },

                            /// 扫码密码
                          )
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.only(top: ScreenAdapter.height(20)),
                  width: ScreenAdapter.width(1080),
                  height: ScreenAdapter.height(400),
                  decoration: BoxDecoration(
                    color: ColorsUtil.hexToColor("#FFFFFF"),
                  ),
                  child: FadeInImage(
                    placeholder: AssetImage('assets/images/public/placeholder.png'), // 本地assets中的占位符图像
                    image: AssetImage(GImage.getImageString("imgpublic", "safeScantop_${controller.checkLanguage.value}")),
                    fit: BoxFit.fitHeight,
                    // [占位符] 的淡出动画时间
                    fadeOutDuration: Duration(milliseconds: 100),
                    // [图像] 的渐入动画曲线
                    fadeInCurve: Curves.easeIn,
                    // [图像] 的渐入动画时间
                    fadeInDuration: Duration(milliseconds: 100),
                  ),
                ),
                /*Container(
                padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
                height: ScreenAdapter.height(1250),
                child: ListView(
                  shrinkWrap: true,
                  children: controller.ordersqlcontroller.cartItems.map((d) => generateCartList(context, d)).toList(),
                ),
              ),*/

                Expanded(
                    child: Container(
                      margin: EdgeInsets.only(top: ScreenAdapter.height(10)),
                      padding: EdgeInsets.zero,
                      //padding: EdgeInsets.only(top: ScreenAdapter.height(5),bottom: ScreenAdapter.height(15)),
                      //height: ScreenAdapter.height(1280),
                      //color: Colors.orange,
                      color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                      //alignment: Alignment.topCenter,
                      child: ListView.builder(
                        //key: GlobalKey<AnimatedListState>(),
                        controller: controller.itemscrollController,
                        physics: ClampingScrollPhysics(), // 禁用回弹效果
                        //reverse: true, // 从上往下显示
                        itemCount: controller.showScanCartItems.value.length,//showCartItems
                        itemBuilder: (context, index) {
                          return generateCartList(controller.showScanCartItems.value[index], index);
                        },
                      ),
                    )
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  //padding: EdgeInsets.only(bottom: ScreenAdapter.height(30)),
                  height: ScreenAdapter.height(90),
                  //color: ColorsUtil.hexToColor("#DCDCDC"),
                  decoration: BoxDecoration(
                      //color: ColorsUtil.hexToColor("#DCDCDC"),
                      color: ColorsUtil.hexToColor("#e9e9e9"),
                      border: Border(
                        //bottom: BorderSide(color: Colors.grey.shade400, width: 5.0),
                        bottom: BorderSide(color: ColorsUtil.hexToColor("#efefef"), width: 5.0),
                      )),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                        alignment: Alignment.centerLeft,
                        width: ScreenAdapter.width(400),
                        height: ScreenAdapter.height(90),

                        child: Text(
                          "  ${controller.showCartTotalGoodsNum.value.toString()}  ${"show_selectPay_point".tr}",
                          style: TextStyle(
                            fontFamily: GFont.getFontFamily(),
                              color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(40.0)),
                        ),
                      ),
                      Expanded(
                          child: Container(
                            height: ScreenAdapter.height(90),
                            //width: ScreenAdapter.width(700),
                            margin: EdgeInsets.only(right: ScreenAdapter.width(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: ScreenAdapter.width(200),
                                  margin: EdgeInsets.only(right: ScreenAdapter.width(30)),

                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "${"settlement_total_price".tr}",
                                    style: TextStyle(
                                      fontFamily: GFont.getFontFamily(),
                                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                        fontWeight: FontWeight.w600,
                                        fontSize: ScreenAdapter.fontSize(40.0)),
                                  ),
                                ),
                                Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(right: ScreenAdapter.width(30)),
                                      alignment: Alignment.centerRight,
                                      child: RichText(
                                        text: TextSpan(
                                            text: "¥",
                                            //GString.getToString(controller.checkLanguage.value, "show_price_front"),
                                            style: TextStyle(
                                              fontFamily: GFont.getFontFamily(),
                                              fontSize: ScreenAdapter.fontSize(GFontSize
                                                  .menusettlementBottomPriceLeft),
                                              fontWeight: FontWeight.w600,
                                              color: ColorsUtil.hexToColor(
                                                  Gcolor.mainTitleColor),
                                            ),
                                            children: [
                                              TextSpan(
                                                text: formatMoney(controller.shopCartTotalPrice.value),
                                                style: TextStyle(
                                                  fontFamily: GFont.getFontFamily(),
                                                  fontSize: ScreenAdapter.fontSize(
                                                      GFontSize
                                                          .menusettlementBottomPrice),
                                                  fontWeight: FontWeight.w600,
                                                  color: ColorsUtil.hexToColor(
                                                      Gcolor.priceColor),
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                "(${controller.containTax ? "show_price_front".tr : "tax_out".tr})", //" 円",
                                                style: TextStyle(
                                                  fontFamily: GFont.getFontFamily(),
                                                  fontSize: ScreenAdapter.fontSize(
                                                      GFontSize
                                                          .menusettlementBottomPriceRight),
                                                  fontWeight: FontWeight.w600,
                                                  color: ColorsUtil.hexToColor(
                                                      Gcolor.mainTitleColor),
                                                ),
                                              ),
                                            ]),
                                      ),
                                    )
                                ),
                              ],
                            ),
                          )
                      ),

                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  //padding: EdgeInsets.only(bottom: ScreenAdapter.height(30)),
                  height: ScreenAdapter.height(200),
                  color: ColorsUtil.hexToColor("#DCDCDC"),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: (){
                          controller.gotoLanguageHome();
                        },
                        child: Container(
                          margin: EdgeInsets.only(left: ScreenAdapter.width(20)),
                          alignment: Alignment.center,
                          width: ScreenAdapter.width(260),
                          height: ScreenAdapter.height(140),
                          //margin: EdgeInsets.only(top: ScreenAdapter.height(15), bottom: ScreenAdapter.height(25)),
                          decoration: BoxDecoration(

                            color: ColorsUtil.hexToColor("#FFFFFF"),
                            //设置圆角
                            borderRadius: new BorderRadius.circular((5.0)),
                          ),
                          child: Text("settlement_back".tr,
                            style: TextStyle(
                                color: ColorsUtil.hexToColor("#000000"),
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w500,
                                fontSize: ScreenAdapter.fontSize(34.0)),
                          ),
                        ),
                      ),
                      (controller.showCartItems.length > 0)
                          ?Container(
                        width: ScreenAdapter.width(700),
                        margin: EdgeInsets.only(right: ScreenAdapter.width(20)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            /*Container(
                              margin: EdgeInsets.only(right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(15)),
                              decoration: BoxDecoration(
                                  color: Colors.white12,
                                  border: Border(
                                    bottom: BorderSide(color: Colors.black, width: 1.5),
                                    //top: BorderSide(color: Colors.grey.shade100, width: 1.0),
                                  )),
                              child: RichText(
                                text: TextSpan(
                                    text: "¥",
                                    //GString.getToString(controller.checkLanguage.value, "show_price_front"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(GFontSize
                                          .menusettlementBottomPriceLeft),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.mainTitleColor),
                                    ),
                                    children: [
                                      TextSpan(
                                        text: formatMoney(controller.shopCartTotalPrice.value),
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(
                                              GFontSize
                                                  .menusettlementBottomPrice),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.priceColor),
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                        "(${GString.getToString(controller.checkLanguage.value, "show_price_front")})", //" 円",
                                        style: TextStyle(
                                          fontSize: ScreenAdapter.fontSize(
                                              GFontSize
                                                  .menusettlementBottomPriceRight),
                                          fontWeight: FontWeight.w600,
                                          color: ColorsUtil.hexToColor(
                                              Gcolor.mainTitleColor),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),*/
                            InkWell(
                              enableFeedback: false,
                              onTap: () {
                                if (int.parse(controller.shopCartTotalPrice.value) ==0) {
                                  return;
                                }

                                controller.doSubmitOrder();

                              },
                              child: Container(
                                width: ScreenAdapter.width(300),
                                height: ScreenAdapter.height(165),
                                margin: EdgeInsets.only(bottom: ScreenAdapter.height(10)),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(

                                  color: (int.parse(controller.shopCartTotalPrice.value) >0) ?ColorsUtil.hexToColor("#A61C1C") :ColorsUtil.hexToColor("#B1B0B0"),
                                  //设置圆角
                                  borderRadius: new BorderRadius.circular((5.0)),
                                ),
                                child: Text("settlement_button".tr,
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(48),
                                      fontFamily: GFont.getFontFamily(),
                                      fontWeight: FontWeight.w600,
                                      color: ColorsUtil.hexToColor(
                                          Gcolor.settlementBtnColor),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      )
                          :Container(width: ScreenAdapter.width(700),),

                    ],
                  ),
                ),
              ],
            ),
          ),
            onLoading: Center(
              child: CircularProgressIndicator(
                strokeWidth:6,
                valueColor:new AlwaysStoppedAnimation<Color>(ColorsUtil.hexToColor("#80B646")),
              ),
            ),
          );
        }),
      ),
    );
  }
}
