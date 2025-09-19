import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/recommend_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/font.dart';
import '../../../config/fontSize.dart';
import '../../../models/ItemModel.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../../../widget/DialogUtils.dart';
import '../controllers/menu_page_controller.dart';

class publicShowCartView extends GetView {
  final MenuPageController controller = Get.find();
  publicShowCartView({Key? key}) : super(key: key);

  showCartListMenu(BuildContext context){
    if (controller.showCartItems.length == 0) {
      return Center(
        child: Text("cart_tag".tr,
          style: TextStyle(
            fontFamily: GFont.getFontFamily(),
            fontSize: ScreenAdapter.fontSize(18),
            color: ColorsUtil.hexToColor("#000000"),
          ),
        ),
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
                            fontFamily: GFont.getFontFamily(),
                              fontSize:ScreenAdapter.fontSize(GFontSize.cartListTitle),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(tipColor)
                          ),
                        ),

                        (d.optionVoListMsg != "")? Text(
                          "${d.optionVoListMsg}",
                          style: TextStyle(
                            fontFamily: GFont.getFontFamily(),
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
                  fontFamily: GFont.getFontFamily(),
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

              Get.back();
            },
            cancle: () {
              Get.back();
            })
    );
  }

  Widget priceTitle() {
    return InkWell(
        onLongPress: (){
          if(int.parse(controller.shopCartTotalPrice.value) >0){
            Get.toNamed('/middlewaresettingpage', arguments: {"machineCode": controller.machineInfo.machineCode});
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
                    "(${"show_price_front".tr})", //" 円",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MenuPageController>(
        id: 'shopping_cart',
        builder: (controller){
        return Obx(() => RepaintBoundary(
          child: Container(
            //height: ScreenAdapter.height(330),
            child: Container(

              //width: ScreenAdapter.width(1080),
              //height: ScreenAdapter.height(330),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(5),
                  top: ScreenAdapter.height(2),
                  right: ScreenAdapter.width(5),
                  bottom: ScreenAdapter.height(2)),
              // decoration: BoxDecoration(
              //   //color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              //   border: Border(
              //     top: BorderSide(color: ColorsUtil.hexToColor("#e5e5e5"), width: 8),
              //   ),
              // ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 9,
                    child: InkWell(
                        onTap: () {
                          print("controller.showCartTotalGoodsNum.value = ${controller.showCartTotalGoodsNum.value}");
                          if (controller.showCartTotalGoodsNum.value <= 0) {
                            //_showEmptyTips();
                            return;
                          }
                          // controller.showShopCart = !controller.showShopCart;
                          // controller.update(['shopping_cart']);
                          controller.showCarPopView();
                          //controller.update();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: ScreenAdapter.width(10),
                            ),
                            Stack(
                              children: [
                                Container(
                                    width: ScreenAdapter.width(160),
                                    height: ScreenAdapter.height(160),
                                    padding: EdgeInsets.all(15),
                                    alignment: Alignment.center,
                                    child:
                                    Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                              'assets/images/public/shopping-cart.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                ),


                                if (controller.showCartTotalGoodsNum.value > 0)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: ScreenAdapter.width(60),
                                      height: ScreenAdapter.width(60),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                      child: AutoSizeText(
                                        "${controller.showCartTotalGoodsNum}",
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 38,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(
                              width: ScreenAdapter.width(60),
                            ),
                            if (controller.showCartTotalGoodsNum.value > 0)
                              Text("settlement_total_price".tr,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: GFont.getFontFamily(),
                                    color: Colors.black,
                                  )),

                            if (controller.showCartTotalGoodsNum.value > 0)
                              Align(
                                  alignment: Alignment.center,
                                  child:
                                  RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(text: '￥', style: TextStyle(
                                          fontFamily: GFont.getFontFamily(),
                                          fontSize: 36,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),),
                                        TextSpan(text: "${formatMoney(controller.shopCartTotalPrice.value)}",style: TextStyle(
                                          fontFamily: GFont.getFontFamily(),
                                          fontSize: 50,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),),
                                        TextSpan(
                                          text: "（${controller.machineInfo.taxSystem ? "show_price_front".tr : "tax_out".tr}）",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontFamily: GFont.getFontFamily(),
                                            fontWeight: FontWeight.w600,
                                            color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                            textBaseline: TextBaseline.alphabetic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                              ),
                            SizedBox(
                              width: ScreenAdapter.width(40),
                            ),
                          ],
                        )),
                  ),

                  Container(
                    width: ScreenAdapter.width(340),
                    //height: ScreenAdapter.height(310),
                    child:
                        InkWell(
                          enableFeedback: false,
                          onTap: () {
                            if (int.parse(controller.shopCartTotalPrice.value) < 0) {
                              return;
                            }

                            //点餐方式只有一种并且未开pos
                            /*if(_isAllowPos == "0"){
                                  _doSubmitOrder();
                                }else{*/
                            //
                            if (controller.recommendFoods.isNotEmpty) {
                              controller.showRecommendView();
                            } else {
                              controller.submitOrderFlow();
                            }
                            //_showSelectMealTypeAndPaymentMethodDialog();
                            //}

                          },
                          child: Container(
                            width: ScreenAdapter.width(300),
                            height: ScreenAdapter.height(145),
                            //margin: EdgeInsets.only(bottom: ScreenAdapter.height(10)),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(

                              color: (int.parse(controller.shopCartTotalPrice.value) >=0) ?ColorsUtil.hexToColor("#A61C1C") :ColorsUtil.hexToColor("#B1B0B0"),
                              //设置圆角
                              borderRadius: new BorderRadius.circular((16.0)),
                            ),
                            child: Text("settlement_button".tr,
                                style:

                                TextStyle(
                                  fontSize: ScreenAdapter.fontSize(48),
                                  fontFamily: GFont.getFontFamily(),
                                  fontWeight: FontWeight.w600,
                                  color: ColorsUtil.hexToColor(
                                      Gcolor.settlementBtnColor),
                                )
                            ),
                          ),
                        ),

                  ),
                  SizedBox(width: 20.w,)
                ],
              ),
            ),
          ),
        ));
      }),
    );
  }
}