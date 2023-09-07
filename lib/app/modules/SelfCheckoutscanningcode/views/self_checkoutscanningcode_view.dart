import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/fontSize.dart';
import '../../../models/ItemModel.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/formatMoney.dart';
import '../controllers/self_checkoutscanningcode_controller.dart';

class SelfCheckoutscanningcodeView
    extends GetView<SelfCheckoutscanningcodeController> {
  const SelfCheckoutscanningcodeView({Key key}) : super(key: key);

  Widget generateCartList(BuildContext context, ShopItemModel d) {
    var tipColor = Gcolor.mainTitleColor;

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
                    //showDialogTag(d.id);
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                        left: ScreenAdapter.width(5),
                        top: ScreenAdapter.height(8),
                        bottom: ScreenAdapter.height(8)),
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
                        //showDialogTag(d.id);
                      }else{
                        /*publicChangeCartMenuCount(cartItem,"reduce").then((val) {

                          //更改显示购物车价格
                          getCartPriceTotal();
                        });*/
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
                      /*if(_totalCount >=_maxtotalCount){
                          //showToast("msg");
                          return;
                        }
                        setState(() {
                          _totalCount++;
                        });
                        _postextraPerson();*/
                      /*if(d.qtyBounds >0){
                        if(d.goodsNum>=d.qtyBounds){
                          var showString = GString.getToString(this._checkLanguage,"show_storage_num_error");
                          showToast("${showString}");
                          return;
                        }
                      }*/

                      var cartItem = {
                        "cartId": d.id,
                        "menuCode": d.menuCode,
                        "unitPrice": d.unitPrice,
                        "goodsNum": 1,
                        "qtyBounds":d.qtyBounds
                      };
                      /*publicChangeCartMenuCount(cartItem,"add").then((val) {

                        //更改显示购物车价格
                        getCartPriceTotal();
                      });*/
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SelfCheckoutscanningcodeController>(builder: (controller){
        return controller.obx((state) => Column(
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
                        onChanged: (value) {
                          //print(value);
                          if(value.length==1){
                            controller.showOrderEasyLoading();
                          }

                        },
                        onSubmitted: (value){
                          Future.delayed(Duration(milliseconds: 150), () {print("精算扫码了");
                          controller.doScanQrCodeQuery();
                          });

                        },

                        /// 扫码密码
                      )
                  ),
                ],
              ),
            ),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500), // 动画持续时间
              child: controller.showCartTotalGoodsNum.value == 0
                  ? Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: Swiper(
                      //itemHeight: 200,
                      itemBuilder: (BuildContext context,int index){
                        // 配置图片地址
                        return publicShowMenuImage(imgPath:controller.homeList.value[index],imgWidth: 1080.0,imgHeight: 1920.0);
                      },
                      // 配置图片数量
                      itemCount: controller.homeList.value.length,
                      // 底部分页器
                      //pagination: new SwiperPagination(margin: EdgeInsets.only(bottom: ScreenAdapter.height(55))),
                      // 左右箭头
                      //control: new SwiperControl(),
                      // 无限循环
                      loop: (controller.homeList.value.length >1) ?true :false,
                      duration: 1000,
                      autoplayDelay:12000,
                      // 自动轮播
                      autoplay: (controller.homeList.value.length >1) ?true :false,
                    ),
                  ),
                  Positioned(
                    right: ScreenAdapter.width(0),
                    top: ScreenAdapter.height(20),
                    child: InkWell(
                      onTap: (){
                        Get.toNamed('/middlewaresettingpage', arguments: {"machineCode": controller.machineCode.value});
                      },
                      child: Container(
                        height: ScreenAdapter.height(150),
                        width: ScreenAdapter.width(200),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(top:ScreenAdapter.height(20),left: ScreenAdapter.width(20),right: ScreenAdapter.width(20),bottom: ScreenAdapter.height(20)),
                        child: Center(
                          //加上Center让文字居中
                          child: Text(
                            "",
                            style: TextStyle(
                                fontSize: ScreenAdapter.fontSize(48.0),
                                color: ColorsUtil.hexToColor("#F9F9F9"),
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: ScreenAdapter.height(1450),
                    child: Container(
                      width: ScreenAdapter.width(1080),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if(controller.machineLanguages_JP.value == true)
                            InkWell(
                              onTap: () {
                                //_clearCartList();
                                Get.toNamed('/self-checkoutscanningcode',arguments: {
                                  "checkLanguage": "JP"
                                });


                              },
                              child: Container(
                                width: ScreenAdapter.width(217),
                                height: ScreenAdapter.height(90),
                                margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                                decoration: BoxDecoration(
                                  //color: Color(0x11111111),
                                  image: DecorationImage(
                                    //alignment: Alignment.topCenter,
                                      image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                      fit: BoxFit.fill),
                                ),
                                child: Center(
                                  //加上Center让文字居中
                                  child: Text(
                                    '日本語',
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(36.0),
                                        color: ColorsUtil.hexToColor("#F9F9F9"),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          //SizedBox(width:ScreenAdapter.width(35)),
                          if(controller.machineLanguages_CH.value == true)
                            InkWell(
                              onTap: () {

                                Get.toNamed('/self-checkoutscanningcode',arguments: {
                                  "checkLanguage": "CH"
                                });
                              },
                              child: Container(
                                width: ScreenAdapter.width(217),
                                height: ScreenAdapter.height(90),
                                margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                                decoration: BoxDecoration(
                                  //color: Color(0x11111111),
                                  image: DecorationImage(
                                    //alignment: Alignment.topCenter,
                                      image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                      fit: BoxFit.fill),
                                ),
                                child: Center(
                                  //加上Center让文字居中
                                  child: Text(
                                    '中文',
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(36.0),
                                        color: ColorsUtil.hexToColor("#F9F9F9"),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          //SizedBox(width:ScreenAdapter.width(35)),
                          if(controller.machineLanguages_EN.value == true)
                            InkWell(
                              onTap: () {
                                Get.toNamed('/self-checkoutscanningcode',arguments: {
                                  "checkLanguage": "EN"
                                });
                              },
                              child: Container(
                                width: ScreenAdapter.width(217),
                                height: ScreenAdapter.height(90),
                                margin: EdgeInsets.only(right: ScreenAdapter.width(35)),
                                decoration: BoxDecoration(
                                  //color: Color(0x11111111),
                                  image: DecorationImage(
                                    //alignment: Alignment.topCenter,
                                      image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                      fit: BoxFit.fill),
                                ),
                                child: Center(
                                  //加上Center让文字居中
                                  child: Text(
                                    'English',
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(36.0),
                                        color: ColorsUtil.hexToColor("#F9F9F9"),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                          //SizedBox(width:ScreenAdapter.width(35)),
                          if(controller.machineLanguages_KO.value == true)
                            InkWell(
                              onTap: () {
                                Get.toNamed('/self-checkoutscanningcode',arguments: {
                                  "checkLanguage": "KO"
                                });
                              },
                              child: Container(
                                width: ScreenAdapter.width(217),
                                height: ScreenAdapter.height(90),
                                decoration: BoxDecoration(
                                  //color: Color(0x11111111),
                                  image: DecorationImage(
                                    //alignment: Alignment.topCenter,
                                      image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                                      fit: BoxFit.fill),
                                ),
                                child: Center(
                                  //加上Center让文字居中
                                  child: Text(
                                    '한국말',
                                    style: TextStyle(
                                        fontSize: ScreenAdapter.fontSize(36.0),
                                        color: ColorsUtil.hexToColor("#F9F9F9"),
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )

                ],
              ) // 没有数据时显示图片
                  : ListView(
                shrinkWrap: true,
                children: controller.ordersqlcontroller.cartItems.map((d) => generateCartList(context, d)).toList(),
              ), // 有数据时显示商品列表
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
