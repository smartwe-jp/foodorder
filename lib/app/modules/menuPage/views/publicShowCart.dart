import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/fontSize.dart';
import '../../../config/string.dart';
import '../../../models/ItemModel.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../controllers/menu_page_controller.dart';

class publicShowCartView extends GetView {
  final MenuPageController controller = Get.put(MenuPageController());
  publicShowCartView({Key key}) : super(key: key);

  showCartListMenu(BuildContext context){
    if (controller.showCartItems.length == 0) {
      return Center(
        child: Text(GString.getToString(
            controller.checkLanguage.value, "cart_tag")),
      );
    }
    return ListView(
      shrinkWrap: true,
      children: controller.showCartItems.map((d) => generateCartList(context, d)).toList(),
    );
  }
  Widget generateCartList(BuildContext context, ShopItemModel d) {
    var tipColor = (controller.menuLackMap.value.containsKey(d.menuCode) == true) ? "#ff0000":Gcolor.mainTitleColor;

    return Padding(
      padding: EdgeInsets.only(left:ScreenAdapter.width(5),top: ScreenAdapter.height(2),right: ScreenAdapter.width(10),bottom: ScreenAdapter.height(2)),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white12,
            border: Border(
              bottom: BorderSide(color: Colors.grey, width: 1.0),
              top: BorderSide(color: Colors.grey.shade100, width: 1.0),
            )),
        //height: ScreenAdapter.height(80),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            /*Container(
                width: ScreenAdapter.width(30),
                child: Image.asset(GImage.getImageString("imgpublic", "delOne"),
                    width: ScreenAdapter.width(20),
                    //height: ScreenAdapter.height(44),
                    fit: BoxFit.fill),
              ),*/
            Expanded(
                child: InkWell(
                  highlightColor: Colors.transparent, // 透明色
                  splashColor: Colors.transparent, // 透明色
                  onTap: (){
                    showDialogTag(d.id);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        left: ScreenAdapter.width(5),
                        top: ScreenAdapter.height(5),
                        bottom: ScreenAdapter.height(5)),
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
            Container(
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
            ),
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
          ],
        ),
      ),
    );
  }

  //清空购物车弹出提示、
  showDialogTag(menuId) {

    Get.dialog(
        Container(
          width: ScreenAdapter.width(950),
          child: SimpleDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              title: Align(
                  alignment: Alignment.center,
                  child:  Text(GString.getToString(controller.checkLanguage.value, "tag_title"),style: TextStyle(fontSize: ScreenAdapter.fontSize(28),fontWeight: FontWeight.w600))
              ),
              children: <Widget>[
                Container(
                  width: ScreenAdapter.width(650),

                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        child: Text(GString.getToString(controller.checkLanguage.value, "show_del_cart_item_tag"),
                            style: TextStyle(fontSize: ScreenAdapter.fontSize(28))),
                        alignment: Alignment(0, 0),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Divider(
                        thickness: 1.0,
                        color: Colors.black12,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 120.0),
                            child: TextButton(
                              child: Text(
                                GString.getToString(controller.checkLanguage.value, "show_del_cart_item_no"),
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: ScreenAdapter.fontSize(32.0)),
                              ),
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ),
                          //垂直分割线
                          SizedBox(
                            width: 1,
                            height: 40,
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: Colors.black12),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 120.0),
                            child: TextButton(
                              child: Text(
                                GString.getToString(controller.checkLanguage.value, "show_del_cart_item_yes"),
                                style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: ScreenAdapter.fontSize(32.0)),
                              ),
                              onPressed: () async {
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
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ]
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MenuPageController>(builder: (controller){
        return Obx(() => RepaintBoundary(
          child: Container(
            height: ScreenAdapter.height(330),
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: Container(

                    width: ScreenAdapter.width(1080),
                    height: ScreenAdapter.height(330),
                    padding: EdgeInsets.only(
                        left: ScreenAdapter.width(5),
                        top: ScreenAdapter.height(2),
                        right: ScreenAdapter.width(20),
                        bottom: ScreenAdapter.height(2)),
                    decoration: BoxDecoration(
                      //color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                      border: Border(
                        top: BorderSide(color: ColorsUtil.hexToColor("#e5e5e5"), width: 8),
                      ),
                    ),
                    child: Column(
                      children: [

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: Container(
                                  height: ScreenAdapter.height(315),
                                  child: Row(
                                    children: [
                                      Scrollbar(
                                          child: SingleChildScrollView(
                                            physics: ClampingScrollPhysics(),
                                            child: Container(
                                              width: ScreenAdapter.width(720),
                                              height: ScreenAdapter.height(315),
                                              color:
                                              ColorsUtil.hexToColor(Gcolor.cartListColor),
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  showCartListMenu(context),
                                                ],
                                              ),
                                            ),
                                          )
                                      ),

                                    ],
                                  ),
                                )),
                            Container(
                              height: ScreenAdapter.height(310),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [

                                  SizedBox(height: ScreenAdapter.height(25)),
                                  InkWell(
                                      onLongPress: (){
                                        if(int.parse(controller.shopCartTotalPrice.value) >0){
                                          Get.toNamed('/middlewaresettingpage', arguments: {"machineCode": controller.machineCode.value});
                                        }

                                      },
                                      child:Container(
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
                                                  "（${GString.getToString(controller.checkLanguage.value, "show_price_front")}）", //" 円",
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
                                      )
                                  ),


                                  SizedBox(height: ScreenAdapter.height(18)),
                                  InkWell(
                                    enableFeedback: false,
                                    onTap: () {
                                      if (int.parse(controller.shopCartTotalPrice.value) ==0) {
                                        return false;
                                      }

                                      //点餐方式只有一种并且未开pos
                                      /*if(_isAllowPos == "0"){
                                  _doSubmitOrder();
                                }else{*/
                                      controller.doSubmitOrder();
                                      //_showSelectMealTypeAndPaymentMethodDialog();
                                      //}



                                    },
                                    child: Container(
                                      width: ScreenAdapter.width(300),
                                      height: ScreenAdapter.height(115),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(

                                        color: (int.parse(controller.shopCartTotalPrice.value) >0) ?ColorsUtil.hexToColor("#A61C1C") :ColorsUtil.hexToColor("#B1B0B0"),
                                        //设置圆角
                                        borderRadius: new BorderRadius.circular((16.0)),
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
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
      }),
    );
  }
}