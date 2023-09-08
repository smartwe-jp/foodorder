import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/fontSize.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../models/ItemModel.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../widget/DialogUtils.dart';
import '../controllers/self_checkoutscanningcode_controller.dart';

class SelfCheckoutscanningcodeView
    extends GetView<SelfCheckoutscanningcodeController> {
  const SelfCheckoutscanningcodeView({Key? key}) : super(key: key);

  //清空购物车弹出提示、
  showDialogTag(menuId) {
    Get.dialog(
        DialogUtils.alert(GString.getToString(controller.checkLanguage.value, "show_del_cart_item_tag"),
            title: GString.getToString(controller.checkLanguage.value, "tag_title"),
            canceltitle: GString.getToString(controller.checkLanguage.value,"show_del_cart_item_no"),
            confirmtitle: GString.getToString(controller.checkLanguage.value,"show_del_cart_item_yes"),
            confirm: () {
              //widget.confirmCallback('确定');
              controller.ordersqlcontroller.removeFromCart(menuId ?? 0);
              //print("Item removed from cart successfully");
              //删除商品声音
              controller.deleteItemSound();
              controller.ordersqlcontroller.getCardList();
              //更改显示购物车价格
              controller.getCartPriceTotal();

              Get.back();
            },
            cancle: () {
              Get.back();
            })
    );

    controller.scanQrCodeController.text = "";
    controller.scanQrCodeFocusNode.requestFocus();     // 获取焦点
  }

  Widget generateCartList(BuildContext context, ShopItemModel d) {
    var tipColor = Gcolor.mainTitleColor;

    return badges.Badge(
      showBadge: true,
      badgeContent: InkWell(
        onTap: (){
          showDialogTag(d.id);
        },
        child: Container(
          //width: ScreenAdapter.width(400),
          height: ScreenAdapter.height(50),
          child: Image.asset(GImage.getImageString("imgpublic", "cartItemCancel"),fit: BoxFit.fitHeight),
        ),
      ),
      //padding: EdgeInsets.all(5),
      position:badges.BadgePosition.topEnd(top: -5, end: -9),
      badgeStyle: badges.BadgeStyle(
        shape: badges.BadgeShape.square,
        padding: EdgeInsets.only(left: 5,top: 1,right: 25,bottom: 3),
        borderRadius: BorderRadius.circular(5),
        badgeColor: Colors.transparent,

      ),
      child: Container(
        margin: EdgeInsets.only(left:ScreenAdapter.width(30),top: ScreenAdapter.height(10),right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(10)),
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
                            bottom: ScreenAdapter.height(4)),
                        //width: ScreenAdapter.width(495),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.mainTitle,
                              style: TextStyle(
                                  fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitle),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(tipColor)
                              ),
                            ),

                            (d.optionVoListMsg != "")? Text(
                              "${d.optionVoListMsg}",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(
                                    GFontSize.cartListTitleTag),
                                color: ColorsUtil.hexToColor(
                                    Gcolor.mainTitleColor),
                              ),
                            )
                                : Text(""),
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
                  height: ScreenAdapter.height(60.0),
                  margin: EdgeInsets.only(right: ScreenAdapter.width(5)),
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
                            "cartId": d.id,
                            "menuCode": d.menuCode,
                            "unitPrice": d.unitPrice,
                            "goodsNum": 1,
                            "qtyBounds":d.qtyBounds
                          };
                          if(d.goodsNum <=1){
                            showDialogTag(d.id);
                          }else{
                            controller.publicChangeCartMenuCount(cartItem,"reduce").then((val) {

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
                          "${d.goodsNum}",
                          style: TextStyle(
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
                            "cartId": d.id,
                            "menuCode": d.menuCode,
                            "unitPrice": d.unitPrice,
                            "goodsNum": 1,
                            "qtyBounds":d.qtyBounds
                          };
                          controller.publicChangeCartMenuCount(cartItem,"add").then((val) {

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
                              fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitleCount),
                              fontWeight: FontWeight.w600,
                              color: (d.goodsNum==d.qtyBounds)?Colors.black12:Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(right: ScreenAdapter.width(10)),
                  //width: ScreenAdapter.width(260),
                  alignment: Alignment.bottomRight,
                  child: Container(
                    //color: Colors.blueGrey,
                    alignment: Alignment.bottomRight,
                    child: RichText(
                      text: TextSpan(
                          text: "¥",//¥GString.getToString(this._checkLanguage, "show_price_front"),
                          style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(30),
                            fontWeight: FontWeight.w600,
                            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                            textBaseline: TextBaseline.alphabetic,
                          ),

                          children: [
                            TextSpan(
                              text: formatMoney(d.currentPrice.toString()),
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(50),
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                textBaseline: TextBaseline.alphabetic,
                              ),
                            ),
                            TextSpan(
                              text: "（${GString.getToString(controller.checkLanguage.value, "show_price_front")}）",
                              style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(50)/2.5,
                                fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                textBaseline: TextBaseline.alphabetic,
                              ),
                            ),
                          ]),
                    ),
                  ),
                ),
                /*Container(
                  width: ScreenAdapter.width(105),
                  padding: EdgeInsets.only(right: ScreenAdapter.width(10)),
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatMoney(d.currentPrice.toString()),
                    style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(GFontSize.mainPriceRight),
                        fontWeight: FontWeight.w600,
                        color: ColorsUtil.hexToColor(tipColor)),
                  ),
                ),*/

              ],
            ),
          ],
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsUtil.hexToColor(Gcolor.mainBackground),
      body: GetBuilder<SelfCheckoutscanningcodeController>(builder: (controller){
        return controller.obx((state) => SingleChildScrollView(
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
                          style: TextStyle(fontSize: ScreenAdapter.fontSize(11.0)),
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
                width: ScreenAdapter.width(1060),
                height: ScreenAdapter.height(520),
                decoration: BoxDecoration(
                  //color: Color(0x11111111),
                  image: DecorationImage(
                    //alignment: Alignment.topCenter,
                      image: AssetImage(GImage.getImageString("imgpublic", "safeScantop_${controller.checkLanguage.value}")),
                      fit: BoxFit.fill),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
                height: ScreenAdapter.height(1200),
                child: ListView(
                  shrinkWrap: true,
                  children: controller.ordersqlcontroller.cartItems.map((d) => generateCartList(context, d)).toList(),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
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
                        child: Text(
                          GString.getToString(controller.checkLanguage.value, "settlement_back"),
                          style: TextStyle(
                              color: ColorsUtil.hexToColor("#000000"),
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
                          Container(
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
                          ),
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
                              child: Text(
                                  GString.getToString(controller.checkLanguage.value,
                                      "settlement_button"),
                                  style: TextStyle(
                                    fontSize: ScreenAdapter.fontSize(48),
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
    );
  }
}
