

import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/config/color.dart';
import 'package:foodorder/app/config/colorsUtil.dart';
import 'package:foodorder/app/config/font.dart';
import 'package:foodorder/app/config/fontSize.dart';
import 'package:foodorder/app/config/imageData.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_controller.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_extension.dart';
import 'package:foodorder/app/modules/menuPage/views/widgets/grid_item_view.dart';
import 'package:foodorder/app/services/ScreenAdapter.dart';
import 'package:foodorder/app/services/showImage.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;

extension MenuPageCategory on MenuPageController {

  showCategoryOne(showItemList,context) {
    Offset temp;
    //第一页第一个商品以及剩余商品
    List items = [];
    Map itemsFirst = {};
    List itemsTree = [];

    items = showItemList;
    if (items.length > 0) {
      itemsFirst = items[0];

    }

    if (itemsFirst != null) {
      return Container(
        color: ColorsUtil.hexToColor(Gcolor.mainBackground),
        padding: EdgeInsets.only(top:ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            publicShowMenuImage(imgPath:itemsFirst['homeImage'], imgWidth:1080.0, imgHeight:850.0,subTitle:itemsFirst["subtitle"]),
            Container(
              color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              width: ScreenAdapter.width(1080),
              //height: ScreenAdapter.height(408),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(25),
                  right: ScreenAdapter.width(25),
                  bottom: ScreenAdapter.height(5)),
              child: StatefulBuilder(
                builder: (BuildContext context, setFirstMenuState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (itemsFirst['optionGroupVoList']?.length > 0)
                          ? publicShowMenuOptionGroupWidget(itemsFirst['menuCode'], setFirstMenuState)
                          : Container(
                        height: 0,
                      ),
                      Divider(
                        height: 1,
                        color: Color.fromRGBO(227, 227, 227, 1),
                      ),

                      //标题价格
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: publicShowMenuTitle(itemsFirst['mainTitle'],
                                42.0, Gcolor.mainTitleColor),),
                          //价格展示 //itemsFirst['currentPrice']
                          Container(
                            alignment: Alignment.centerRight,
                            //width: ScreenAdapter.width(200),
                            padding:EdgeInsets.only(right: ScreenAdapter.width(15)),
                            child: publicShowMenuPrice(
                                selectedMenuOptionChangePrice.value[itemsFirst['menuCode']]+addselectedMenuOptionChangePrice.value[itemsFirst['menuCode']],
                                itemsFirst['price'],
                                45.0,
                                Gcolor.mainTitleColor,
                                55.0,
                                Gcolor.priceColor,
                                26.0,
                                Gcolor.mainTitleColor),
                          ),
                          //原价格展示 //itemsFirst['currentPrice']
                          /*Container(
                            width: ScreenAdapter.width(80),
                            child: Text("${itemsFirst['price']}",
                              style: TextStyle(decoration: TextDecoration.lineThrough,fontSize: ScreenAdapter.fontSize(32),fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),),
                            ),
                          ),*/

                          //确认按钮
                          InkWell(
                            enableFeedback: false,

                            onTap: () {

                              var currentPrice = itemsFirst['currentPrice'];
                              var optionCodeList = "";
                              var optionTitle = "";
                              //--------------检测option单选还是多选是否满足
                              var attr = menuOption.value[itemsFirst['menuCode']];
                              var nexOrder = true;
                              for (var i = 0; i < attr.length; i++) {
                                //如果是多选，那么需要判断该组option数量是否超过最大值
                                if(int.parse(attr[i]["smallest"]) >0){
                                  var current_option_checked = 0;
                                  for (var n = 0; n < attr[i]['optionVoList'].length; n++) {
                                    if(attr[i]['optionVoList'][n]["checked"] == true){
                                      current_option_checked++;
                                    }
                                  }
                                  if(current_option_checked <int.parse(attr[i]["smallest"])){
                                    nexOrder = false;
                                    var showTag = GString.getToString(checkLanguage.value, "menu_option_less_smallest");
                                    //showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                    Get.dialog(
                                        DialogUtils.alertOneButton("${showTag.replaceAll("%%", attr[i]["groupName"])}",
                                            title: GString.getToString(checkLanguage.value, "tag_title"),
                                            confirmtitle: GString.getToString(checkLanguage.value,"tag_button_yes"),
                                            confirm: () {
                                              Get.back();
                                            })
                                    );
                                    break;
                                  }
                                }

                              }
                              if(nexOrder == false) return;
                              //--------------end
                              var checkoptionGroupList = {};
                              for (var optionItem in selectedMenuOptionList.value[itemsFirst['menuCode']]) {
                                currentPrice += optionItem['currentPrice'];

                                optionCodeList += (optionCodeList != "")
                                    ? "," + optionItem['optionCode']
                                    : optionItem['optionCode'];
                                var groupKey = optionItem['group'];
                                //整理新数组
                                checkoptionGroupList[groupKey] = {
                                  "optionTitles": (checkoptionGroupList[groupKey] == null) ? optionItem['mainTitle'] : checkoptionGroupList[groupKey]["optionTitles"]+","+optionItem['mainTitle'],
                                  "groupTitle":optionItem['groupTitle']
                                };
                              }

                              checkoptionGroupList.forEach((key, value) {
                                optionTitle += (optionTitle != "")
                                    ? "," + value['groupTitle']+":"+value['optionTitles']
                                    : value['groupTitle']+":"+value['optionTitles'];
                              });


                              var cartItem = {
                                "menuCode": itemsFirst['menuCode'],
                                "mainTitle": itemsFirst['mainTitle'],
                                "image": itemsFirst['homeImage'],
                                "currentPrice": currentPrice,
                                "optionGroupVoList": optionCodeList,
                                "optionVoListMsg": optionTitle,
                                "goodsNum": 1,
                                "qtyBounds": itemsFirst['qtyBounds'],
                                "unitPrice":currentPrice
                              };
                              publicAddCartMenu(cartItem, false).then((val) {
                                //_publicShowAddCart(temp,itemsFirst['homeImage']);
                                //更改显示购物车价格
                                //getCartPriceTotal();
                                if(val != false){
                                  publicShowAddCartNew(context);
                                }


                                changeInitialAllOption(itemsFirst['menuCode']);

                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: ScreenAdapter.height(10)),
                              width: ScreenAdapter.width(270),
                              height: ScreenAdapter.height(75),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorsUtil.hexToColor("#078E42"),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                  GString.getToString(
                                      checkLanguage.value, "add_option_cart"),
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    color: ColorsUtil.hexToColor(Gcolor.settlementBtnColor),
                                    fontSize: 34,
                                    fontWeight: FontWeight.w600,

                                  )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

//获取第一个页面的widget
  __publicShowMenuOptionGroupWidget(menuCode, setFirstMenuState) {
    return Container(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getFirstOptionWidget(menuCode, setFirstMenuState),
      ),
    );
  }
//获取第一个页面的option widget
  _getFirstOptionWidget(menuCode, setFirstState) {
    var optionGroupVoList = menuOption.value[menuCode];

    List<Widget> options = []; //先建一个数组用于存放循环生成的widget


    //Widget labelContent;
    for (var i = 0; i < optionGroupVoList.length; i++) {
      List<Widget> optionSons = [];
      var optionVoList = optionGroupVoList[i]['optionVoList'];
      options.add(
          Container(
            padding: EdgeInsets.only(
                top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                      text: "${optionGroupVoList[i]['groupName']}",
                      //GString.getToString(checkLanguage.value, "show_price_front"),
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: ScreenAdapter.fontSize(24.0),
                        fontWeight: FontWeight.w500,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                      ),
                      children: [
                        TextSpan(
                          text: (optionGroupVoList[i]['remark'] != null &&
                              optionGroupVoList[i]['remark'] != "")
                              ? " ${optionGroupVoList[i]['remark']}"
                              : "",
                          style: TextStyle(
                            fontFamily: GFont.getFontFamily(),
                            fontSize: ScreenAdapter.fontSize(18.0),
                            fontWeight: FontWeight.w200,
                            color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                          ),
                        ),
                      ]),
                )
              ],
            ),
          )
      );


      for (var j = 0; j < optionVoList.length; j++) {
        var optionVolistSon = optionVoList[j];
        var buttonColor = [];
        if (optionVolistSon['buttonColorValue'] != null &&
            optionVolistSon['buttonColorValue'] != "") {
          buttonColor = optionVolistSon['buttonColorValue'].split(',');
        }
        optionSons.add(Container(
          width: ScreenAdapter.width(224),
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              left: ScreenAdapter.width(12),
              top: ScreenAdapter.height(3),
              right: ScreenAdapter.width(12),
              bottom: ScreenAdapter.height(3)),
          child: InkWell(
            //enableFeedback: true,
              onTap: () {
                changeOptionv1(
                    menuCode, optionGroupVoList[i]["groupCode"],
                    optionVolistSon["optionCode"], setFirstState);
              },
              child: badges.Badge(
                showBadge: (optionVolistSon['currentPrice'] != 0) ? true : false,
                badgeContent: Text(
                    (optionVolistSon['currentPrice'] > 0)
                        ? "+${optionVolistSon['currentPrice'].toString()}円"
                        : "${optionVolistSon['currentPrice'].toString()}円",
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(16),
                      color: ColorsUtil.hexToColor(
                          Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position: badges.BadgePosition.topEnd(top: -18, end: -9),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding: EdgeInsets.only(left: 5, top: 3, right: 5, bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil
                      .hexToColor("#ef4136") : ColorsUtil.hexToColor("#1d953f"),

                ),
                child: Container(
                    height: ScreenAdapter.height(60),
                    alignment: Alignment.center,
                    decoration: (optionVolistSon['checked'] == true)
                        ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#C47829"),
                          ColorsUtil.hexToColor("#854610"),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    )
                        : (buttonColor.length > 0) ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      //color: ColorsUtil.hexToColor(optionVolistSon['buttonColorValue']),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor(buttonColor[0]),
                          ColorsUtil.hexToColor(buttonColor[1]),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    ) : BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(14.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#E9CE9B"),
                          ColorsUtil.hexToColor("#CEA062"),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (optionVolistSon['homeImage'] != "" &&
                            optionVolistSon['homeImage'] != null)
                            ? CachedNetworkImage(
                            imageUrl: optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(15),
                            height: ScreenAdapter.height(25),
                            color: (optionVolistSon['checked'] == true)
                                ? ColorsUtil.hexToColor(Gcolor.optionBtnColor)
                                : ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(5),
                        ),

                        Container(
                          //width: ScreenAdapter.width(210),
                          height: ScreenAdapter.height(60),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(170),
                              minHeight: ScreenAdapter.height(30),
                              maxHeight: ScreenAdapter.height(60),
                            ),
                            child: AutoSizeText(
                              optionVolistSon['mainTitle'],
                              style: TextStyle(
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(28.0),
                                color: (optionVolistSon['checked'] == true)
                                    ? ColorsUtil.hexToColor(Gcolor.optionBtnColor)
                                    : ColorsUtil.hexToColor("#914F14"),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    )),
              )
          ),
        ));
      }
      options.add(
          Container(
            padding: EdgeInsets.only(
                left: ScreenAdapter.height(80), right: ScreenAdapter.height(20)),
            child: Wrap(
              alignment: WrapAlignment.start,
              children: optionSons,
            ),
          )
      );
    }
  }

//顶部分类导航
  showTopCategoryMenu() {
    List<Widget> categoryMenus = []; //先建一个数组用于存放循环生成的widget
    int index = 0;
    for (var item in topMenu) {
      categoryMenus.add(InkWell(
        //enableFeedback: false,
        onTap: () {
          changeCategory(item['categoryCode']);
          //classTag.value = item['categoryCode'];
        },
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                  right: ScreenAdapter.width(6), top: ScreenAdapter.height(5)),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
              width: ScreenAdapter.width(165),
              //height: (classTag == item['categoryCode']) ? ScreenAdapter.height(75) : ScreenAdapter.height(65),
              //height: ScreenAdapter.height(90),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                //背景颜色
                color: ColorsUtil.hexToColor(item['showColor']),
                borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
              ),
              child: Center(
                //加上Center让文字居中
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: ScreenAdapter.width(20),
                    maxWidth: ScreenAdapter.width(165),
                    minHeight: ScreenAdapter.height(30),
                    maxHeight: ScreenAdapter.height(65),
                  ),
                  child: AutoSizeText(
                    "${item['categoryName']}",
                    style: TextStyle(
                        fontSize: ScreenAdapter.fontSize(30),
                        fontFamily: GFont.getFontFamily(),
                        color:
                        ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                        fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            (classTag.value == item['categoryCode'])
                ? Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    padding: EdgeInsets.zero,
                    //width: ScreenAdapter.width(10),
                    //color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                    child: Image.asset(
                      GImage.getImageString("imgpublic", "menu_up"),
                      height: ScreenAdapter.width(20),
                      fit: BoxFit.fitHeight,
                      color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                    )),
              ),
            )
                : Container(
              height: 0,
            ),
          ],
        ),
      ));
    }

    //categoryMenus.add();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      //mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Container(
            width: ScreenAdapter.width(900),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: categoryMenus,
                )
              ],
            ),
          ),
        ),
        Container(
          //alignment: Alignment.centerRight,
          child: InkWell(
            enableFeedback: false,
            onTap: () {
              //ordersqlremoveAllFromCart();
              gotoLanguageHome();
            },
            child: Container(
              padding: EdgeInsets.only(top: ScreenAdapter.height(10)),
              margin: EdgeInsets.only(
                left: ScreenAdapter.width(10),
                top: ScreenAdapter.height(10),
                right: ScreenAdapter.width(5),
              ),
              width: ScreenAdapter.width(95),
              height: ScreenAdapter.height(85),
              //alignment: Alignment.center,
              decoration: BoxDecoration(
                image: new DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: AssetImage("assets/images/public/language.png"),
                ),
              ),
              /*decoration: BoxDecoration(
                //color: Color(0x11111111),
                image: DecorationImage(
                  //alignment: Alignment.topCenter,
                    image: AssetImage(GImage.getImageString("imgpublic", "home_button")),
                    fit: BoxFit.fill),
              ),*/
              /*child: Center(
                //加上Center让文字居中
                child: Text(
                  GString.getToString(checkLanguage.value, "top_back_button"),
                  style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(22),
                      color: ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                      fontWeight: FontWeight.w600),
                ),
              ),*/
            ),
          ),
        ),
      ],
    );
  }


  //第一分类页面
  __showCategoryOne(showItemList, context) {
    Offset temp;
    //第一页第一个商品以及剩余商品
    List items = [];
    Map itemsFirst = {};
    List itemsTree = [];

    items = showItemList;
    if (items.length > 0) {
      itemsFirst = items[0];
    }

    if (itemsFirst != null) {
      return Container(
        color: ColorsUtil.hexToColor(Gcolor.mainBackground),
        padding: EdgeInsets.only(
            top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            publicShowMenuImage(
                imgPath: itemsFirst['homeImage'],
                imgWidth: 1080.0,
                imgHeight: 850.0,
                subTitle: itemsFirst["subtitle"]),
            Container(
              color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              width: ScreenAdapter.width(1080),
              //height: ScreenAdapter.height(408),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(25),
                  right: ScreenAdapter.width(25),
                  bottom: ScreenAdapter.height(5)),
              child: StatefulBuilder(
                builder: (BuildContext context, setFirstMenuState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      (itemsFirst['optionGroupVoList']?.length > 0)
                          ? publicShowMenuOptionGroupWidget(
                          itemsFirst['menuCode'], setFirstMenuState)
                          : Container(
                        height: 0,
                      ),
                      Divider(
                        height: 1,
                        color: Color.fromRGBO(227, 227, 227, 1),
                      ),

                      //标题价格
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: publicShowMenuTitle(
                                itemsFirst['mainTitle'],
                                42.0,
                                Gcolor.mainTitleColor),
                          ),
                          //价格展示 //itemsFirst['currentPrice']
                          Container(
                            alignment: Alignment.centerRight,
                            //width: ScreenAdapter.width(200),
                            padding:
                            EdgeInsets.only(right: ScreenAdapter.width(15)),
                            child: publicShowMenuPrice(
                                selectedMenuOptionChangePrice
                                    .value[itemsFirst['menuCode']] +
                                    addselectedMenuOptionChangePrice
                                        .value[itemsFirst['menuCode']],
                                itemsFirst['price'],
                                45.0,
                                Gcolor.mainTitleColor,
                                55.0,
                                Gcolor.priceColor,
                                26.0,
                                Gcolor.mainTitleColor),
                          ),
                          //原价格展示 //itemsFirst['currentPrice']
                          /*Container(
                            width: ScreenAdapter.width(80),
                            child: Text("${itemsFirst['price']}",
                              style: TextStyle(decoration: TextDecoration.lineThrough,fontSize: ScreenAdapter.fontSize(32),fontWeight: FontWeight.w600,
                                color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),),
                            ),
                          ),*/

                          //确认按钮
                          InkWell(
                            enableFeedback: false,
                            onTap: () {
                              var currentPrice = itemsFirst['currentPrice'];
                              var optionCodeList = "";
                              var optionTitle = "";
                              //--------------检测option单选还是多选是否满足
                              var attr = menuOption.value[itemsFirst['menuCode']];
                              var nexOrder = true;
                              for (var i = 0; i < attr.length; i++) {
                                //如果是多选，那么需要判断该组option数量是否超过最大值
                                if (int.parse(attr[i]["smallest"]) > 0) {
                                  var current_option_checked = 0;
                                  for (var n = 0;
                                  n < attr[i]['optionVoList'].length;
                                  n++) {
                                    if (attr[i]['optionVoList'][n]["checked"] ==
                                        true) {
                                      current_option_checked++;
                                    }
                                  }
                                  if (current_option_checked <
                                      int.parse(attr[i]["smallest"])) {
                                    nexOrder = false;
                                    var showTag = GString.getToString(
                                        checkLanguage.value,
                                        "menu_option_less_smallest");
                                    //showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                    Get.dialog(DialogUtils.alertOneButton(
                                        "${showTag.replaceAll("%%", attr[i]["groupName"])}",
                                        title: GString.getToString(
                                            checkLanguage.value,
                                            "tag_title"),
                                        confirmtitle: GString.getToString(
                                            checkLanguage.value,
                                            "tag_button_yes"), confirm: () {
                                      Get.back();
                                    }));
                                    break;
                                  }
                                }
                              }
                              if (nexOrder == false) return;
                              //--------------end
                              var checkoptionGroupList = {};
                              for (var optionItem in selectedMenuOptionList
                                  .value[itemsFirst['menuCode']]) {
                                currentPrice += optionItem['currentPrice'];

                                optionCodeList += (optionCodeList != "")
                                    ? "," + optionItem['optionCode']
                                    : optionItem['optionCode'];
                                var groupKey = optionItem['group'];
                                //整理新数组
                                checkoptionGroupList[groupKey] = {
                                  "optionTitles":
                                  (checkoptionGroupList[groupKey] == null)
                                      ? optionItem['mainTitle']
                                      : checkoptionGroupList[groupKey]
                                  ["optionTitles"] +
                                      "," +
                                      optionItem['mainTitle'],
                                  "groupTitle": optionItem['groupTitle']
                                };
                              }

                              checkoptionGroupList.forEach((key, value) {
                                optionTitle += (optionTitle != "")
                                    ? "," +
                                    value['groupTitle'] +
                                    ":" +
                                    value['optionTitles']
                                    : value['groupTitle'] +
                                    ":" +
                                    value['optionTitles'];
                              });

                              var cartItem = {
                                "menuCode": itemsFirst['menuCode'],
                                "mainTitle": itemsFirst['mainTitle'],
                                "image": itemsFirst['homeImage'],
                                "currentPrice": currentPrice,
                                "optionGroupVoList": optionCodeList,
                                "optionVoListMsg": optionTitle,
                                "goodsNum": 1,
                                "qtyBounds": itemsFirst['qtyBounds'],
                                "unitPrice": currentPrice
                              };
                              publicAddCartMenu(cartItem, false)
                                  .then((val) {
                                //_publicShowAddCart(temp,itemsFirst['homeImage']);
                                //更改显示购物车价格
                                //getCartPriceTotal();
                                if (val != false) {
                                  publicShowAddCartNew(context);
                                }

                                changeInitialAllOption(
                                    itemsFirst['menuCode']);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: ScreenAdapter.height(10)),
                              width: ScreenAdapter.width(270),
                              height: ScreenAdapter.height(75),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: ColorsUtil.hexToColor("#078E42"),
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                  GString.getToString(
                                      checkLanguage.value,
                                      "add_option_cart"),
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    color: ColorsUtil.hexToColor(
                                        Gcolor.settlementBtnColor),
                                    fontSize: 34,
                                    fontWeight: FontWeight.w600,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  //获取第一个页面的widget
  publicShowMenuOptionGroupWidget(menuCode, setFirstMenuState) {
    return Container(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(5)),
      child: Column(
        children: getFirstOptionWidget(menuCode, setFirstMenuState),
      ),
    );
  }

  //获取第一个页面的option widget
  getFirstOptionWidget(menuCode, setFirstState) {
    var optionGroupVoList = menuOption.value[menuCode];

    List<Widget> options = []; //先建一个数组用于存放循环生成的widget

    //Widget labelContent;
    for (var i = 0; i < optionGroupVoList.length; i++) {
      List<Widget> optionSons = [];
      var optionVoList = optionGroupVoList[i]['optionVoList'];
      options.add(Container(
        padding: EdgeInsets.only(
            top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
        child: Row(
          children: [
            RichText(
              text: TextSpan(
                  text: "${optionGroupVoList[i]['groupName']}",
                  //GString.getToString(checkLanguage.value, "show_price_front"),
                  style: TextStyle(
                    fontFamily: GFont.getFontFamily(),
                    fontSize: ScreenAdapter.fontSize(24.0),
                    fontWeight: FontWeight.w500,
                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                  ),
                  children: [
                    TextSpan(
                      text: (optionGroupVoList[i]['remark'] != null &&
                          optionGroupVoList[i]['remark'] != "")
                          ? " ${optionGroupVoList[i]['remark']}"
                          : "",
                      style: TextStyle(
                        fontFamily: GFont.getFontFamily(),
                        fontSize: ScreenAdapter.fontSize(18.0),
                        fontWeight: FontWeight.w200,
                        color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                      ),
                    ),
                  ]),
            )
          ],
        ),
      ));

      for (var j = 0; j < optionVoList.length; j++) {
        var optionVolistSon = optionVoList[j];
        var buttonColor = [];
        if (optionVolistSon['buttonColorValue'] != null &&
            optionVolistSon['buttonColorValue'] != "") {
          buttonColor = optionVolistSon['buttonColorValue'].split(',');
        }
        optionSons.add(Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              left: ScreenAdapter.width(12),
              top: ScreenAdapter.height(3),
              right: ScreenAdapter.width(12),
              bottom: ScreenAdapter.height(3)),
          child: InkWell(
            //enableFeedback: true,
              onTap: () {
                changeOptionv1(
                    menuCode,
                    optionGroupVoList[i]["groupCode"],
                    optionVolistSon["optionCode"],
                    setFirstState);
              },
              child: badges.Badge(
                showBadge:
                (optionVolistSon['currentPrice'] != 0) ? true : false,
                badgeContent: Text(
                    (optionVolistSon['currentPrice'] > 0)
                        ? "+${optionVolistSon['currentPrice'].toString()}円"
                        : "${optionVolistSon['currentPrice'].toString()}円",
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(16),
                      color: ColorsUtil.hexToColor(Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position: badges.BadgePosition.topEnd(top: -18, end: -9),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding:
                  EdgeInsets.only(left: 5, top: 3, right: 5, bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (optionVolistSon['currentPrice'] > 0)
                      ? ColorsUtil.hexToColor("#ef4136")
                      : ColorsUtil.hexToColor("#1d953f"),
                ),
                child: Container(
                    width: ScreenAdapter.width(224),
                    height: ScreenAdapter.height(60),
                    alignment: Alignment.center,
                    decoration: (optionVolistSon['checked'] == true)
                        ? BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(14.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#C47829"),
                          ColorsUtil.hexToColor("#854610"),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    )
                        : (buttonColor.length > 0)
                        ? BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(14.0)),
                      //color: ColorsUtil.hexToColor(optionVolistSon['buttonColorValue']),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor(buttonColor[0]),
                          ColorsUtil.hexToColor(buttonColor[1]),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    )
                        : BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(14.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#E9CE9B"),
                          ColorsUtil.hexToColor("#CEA062"),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (optionVolistSon['homeImage'] != "" &&
                            optionVolistSon['homeImage'] != null)
                            ? CachedNetworkImage(
                            imageUrl: optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(15),
                            height: ScreenAdapter.height(25),
                            color: (optionVolistSon['checked'] == true)
                                ? ColorsUtil.hexToColor(
                                Gcolor.optionBtnColor)
                                : ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(5),
                        ),
                        Container(
                          //width: ScreenAdapter.width(210),
                          height: ScreenAdapter.height(60),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(170),
                              minHeight: ScreenAdapter.height(30),
                              maxHeight: ScreenAdapter.height(60),
                            ),
                            child: AutoSizeText(
                              optionVolistSon['mainTitle'],
                              style: TextStyle(
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(28.0),
                                color: (optionVolistSon['checked'] == true)
                                    ? ColorsUtil.hexToColor(
                                    Gcolor.optionBtnColor)
                                    : ColorsUtil.hexToColor("#914F14"),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    )),
              )),
        ));
      }
      options.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: optionSons,
      ));
    }

    return options;
  }

  //第二个分类 小菜
  showCategoryTwo(showItemList, context, {popupType: "old"}) {
    if (showItemList != null && showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategoryTwoItemList(showItemList, context,
            popupType: popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }


  showCategoryThreeItemList(items) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives: true,
        //addRepaintBoundaries:false,
        itemBuilder: (BuildContext context, int index) {
          return showCategoryThreeItemOne(items[index], index);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryThreeItemOne(item, index) {
    Offset temp;

    var subtitle = "";
    if (item["subtitle"] != null && item["subtitle"]?.length > 0) {
      for (var i = 0; i < item["subtitle"].length; i++) {
        subtitle += item["subtitle"][i];
      }
    }

    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.width(20)),
      padding: EdgeInsets.only(top: ScreenAdapter.height(8)),
      decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ColorsUtil.hexToColor("#c38d4d"), width: 2.0),
          )),
      child: Material(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: ScreenAdapter.height(5),
                  bottom: ScreenAdapter.height(10)),
              margin: EdgeInsets.only(
                  left: ScreenAdapter.width(10),
                  right: ScreenAdapter.width(10)),
              color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              child: StatefulBuilder(
                builder: (BuildContext context, menuindex) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          //top: ScreenAdapter.height(5),
                          bottom: ScreenAdapter.height(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            publicShowMenuImage(
                                imgPath: item['homeImage'],
                                imgWidth: 350.0,
                                imgHeight: 350.0),
                            (item['optionGroupVoList']?.length > 0)
                                ? Expanded(
                                child: publicShowThreeMenuOptionGroupWidget(
                                    item['menuCode'],
                                    menuindex,
                                    item['qtyBounds']))
                                : Container(
                              height: 0,
                            ),
                          ],
                        ),
                      ),

                      Divider(
                        height: 1,
                        color: Color.fromRGBO(227, 227, 227, 1),
                      ),
                      //标题价格
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //菜单Title

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        //菜单Title
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                right: ScreenAdapter.width(15)),
                                            child: publicShowMenuTitle(
                                                item['mainTitle'],
                                                32.0,
                                                Gcolor.mainTitleColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        //副标题
                                        subtitle != ""
                                            ? Expanded(
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '${subtitle}',
                                                style: TextStyle(
                                                    fontFamily:
                                                    GFont.getFontFamily(),
                                                    fontSize: ScreenAdapter
                                                        .fontSize(GFontSize
                                                        .menuThreeListFoodSubtitle),
                                                    fontWeight: FontWeight.w600,
                                                    color: ColorsUtil.hexToColor(
                                                        Gcolor.mainTitleColor)),
                                              ),
                                            ))
                                            : Container(
                                          width: 0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                          //价格展示 item['currentPrice']
                          Container(
                            padding:
                            EdgeInsets.only(right: ScreenAdapter.width(30)),
                            //width: ScreenAdapter.width(200),
                            alignment: Alignment.bottomRight,
                            child: publicShowMenuPrice(
                                selectedMenuOptionChangePrice
                                    .value[item['menuCode']] +
                                    addselectedMenuOptionChangePrice
                                        .value[item['menuCode']],
                                item['price'],
                                35.0,
                                Gcolor.mainTitleColor,
                                54.0,
                                Gcolor.priceColor,
                                28.0,
                                Gcolor.mainTitleColor),
                          ),

                          //确认按钮
                          InkWell(
                            enableFeedback: false,
                            onTap: () async {
                              if (item['qtyBounds'] == 0) {
                                return;
                              } else if (item['qtyBounds'] > 0) {
                                //请求限定接口
                                var cartItemNum = await ordersqlcontroller
                                    .getCartItemNum(item['menuCode']);
                                print(cartItemNum);
                                if (cartItemNum >= item['qtyBounds']) {
                                  var showString = GString.getToString(
                                      checkLanguage.value,
                                      "show_storage_num_error");
                                  //showToast("${showString}");
                                  Get.dialog(DialogUtils.alertOneButton(
                                      showString,
                                      title: GString.getToString(
                                          checkLanguage.value,
                                          "tag_title"),
                                      confirmtitle: GString.getToString(
                                          checkLanguage.value,
                                          "tag_button_yes"), confirm: () {
                                    Get.back();
                                  }));
                                  return;
                                }
                              }

                              //判断选择后option是否与optiongroup相等
                              var currentPrice = item['currentPrice'];
                              var optionCodeList = "";
                              var optionTitle = "";
                              if (item['optionGroupVoList']?.length > 0) {
                                //item['optionGroupVoList'].length

                                //--------------检测option单选还是多选是否满足
                                var attr = menuOption.value[item['menuCode']];
                                var nexOrder = true;
                                for (var i = 0; i < attr.length; i++) {
                                  //如果是多选，那么需要判断该组option数量是否超过最大值
                                  if (int.parse(attr[i]["smallest"]) > 0) {
                                    var current_option_checked = 0;
                                    for (var n = 0;
                                    n < attr[i]['optionVoList'].length;
                                    n++) {
                                      if (attr[i]['optionVoList'][n]
                                      ["checked"] ==
                                          true) {
                                        current_option_checked++;
                                      }
                                    }
                                    if (current_option_checked <
                                        int.parse(attr[i]["smallest"])) {
                                      nexOrder = false;
                                      var showTag = GString.getToString(
                                          checkLanguage.value,
                                          "menu_option_less_smallest");
                                      //showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                      Get.dialog(DialogUtils.alertOneButton(
                                          "${showTag.replaceAll("%%", attr[i]["groupName"])}",
                                          title: GString.getToString(
                                              checkLanguage.value,
                                              "tag_title"),
                                          confirmtitle: GString.getToString(
                                              checkLanguage.value,
                                              "tag_button_yes"), confirm: () {
                                        Get.back();
                                      }));
                                      break;
                                    }
                                  }
                                }
                                if (nexOrder == false) return;
                                //--------------end
                                var checkoptionGroupList = {};
                                for (var optionItem in selectedMenuOptionList
                                    .value[item['menuCode']]) {
                                  currentPrice += optionItem['currentPrice'];

                                  optionCodeList += (optionCodeList != "")
                                      ? "," + optionItem['optionCode']
                                      : optionItem['optionCode'];
                                  var groupKey = optionItem['group'];
                                  //整理新数组
                                  checkoptionGroupList[groupKey] = {
                                    "optionTitles":
                                    (checkoptionGroupList[groupKey] == null)
                                        ? optionItem['mainTitle']
                                        : checkoptionGroupList[groupKey]
                                    ["optionTitles"] +
                                        "," +
                                        optionItem['mainTitle'],
                                    "groupTitle": optionItem['groupTitle']
                                  };
                                }

                                checkoptionGroupList.forEach((key, value) {
                                  optionTitle += (optionTitle != "")
                                      ? "," +
                                      value['groupTitle'] +
                                      ":" +
                                      value['optionTitles']
                                      : value['groupTitle'] +
                                      ":" +
                                      value['optionTitles'];
                                });
                              }

                              var cartItem = {
                                "menuCode": item['menuCode'],
                                "mainTitle": item['mainTitle'],
                                "image": item['homeImage'],
                                "currentPrice": currentPrice,
                                "optionGroupVoList": optionCodeList,
                                "optionVoListMsg": optionTitle,
                                "goodsNum": 1,
                                "qtyBounds": item['qtyBounds'],
                                "unitPrice": currentPrice
                              };
                              publicAddCartMenu(cartItem, false)
                                  .then((val) {
                                //更改显示购物车价格
                                //getCartPriceTotal();
                                if (val != false) {
                                  publicShowAddCartNew(context);
                                }
                                changeInitialAllOption(item['menuCode']);
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: ScreenAdapter.height(15)),
                              width: ScreenAdapter.width(250),
                              height: ScreenAdapter.height(67),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (item['qtyBounds'] != 0)
                                    ? ColorsUtil.hexToColor("#078E42")
                                    : ColorsUtil.hexToColor("#C1C1C1"),
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                  GString.getToString(
                                      checkLanguage.value,
                                      "add_option_cart"),
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(32),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        Gcolor.optionBtnColor),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            //绝对定位 盖章
            publicShowMenuSellOut(item['qtyBounds']),
          ],
        ),
      ),
    );
  }

  getThreeOptionWidget(menuCode, setFirstState, qtyBounds) {
    var optionGroupVoList = menuOption.value[menuCode];
    List<Widget> options = []; //先建一个数组用于存放循环生成的widget
    if (optionGroupVoList != null &&
        optionGroupVoList.length > 0 &&
        optionGroupVoList != "") {
      for (var i = 0; i < optionGroupVoList.length; i++) {
        if (i >= optionGroupMaxNum.value) break;
        List<Widget> optionSons = [];
        var optionVoList = optionGroupVoList[i]['optionVoList'];
        options.add(Container(
          padding: EdgeInsets.only(
              top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                    text: "${optionGroupVoList[i]['groupName']}",
                    //GString.getToString(this._checkLanguage, "show_price_front"),
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(24.0),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                    children: [
                      TextSpan(
                        text: (optionGroupVoList[i]['remark'] != null &&
                            optionGroupVoList[i]['remark'] != "")
                            ? " ${optionGroupVoList[i]['remark']}"
                            : "",
                        style: TextStyle(
                          fontFamily: GFont.getFontFamily(),
                          fontSize: ScreenAdapter.fontSize(18.0),
                          fontWeight: FontWeight.w200,
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ));

        for (var j = 0; j < optionVoList.length; j++) {
          if (j >= optionMaxNum.value) break;
          var optionVolistSon = optionVoList[j];
          var buttonColor = [];
          if (optionVolistSon['buttonColorValue'] != null &&
              optionVolistSon['buttonColorValue'] != "") {
            buttonColor = optionVolistSon['buttonColorValue'].split(',');
          }
          optionSons.add(Container(
            width: ScreenAdapter.width(157),
            height: ScreenAdapter.height(60),
            alignment: Alignment.center,
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(2),
                top: ScreenAdapter.height(2),
                right: ScreenAdapter.width(2),
                bottom: ScreenAdapter.height(2)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                if (qtyBounds != 0) {
                  changeOptionv1(
                      menuCode,
                      optionGroupVoList[i]["groupCode"],
                      optionVolistSon["optionCode"],
                      setFirstState);
                }
              },
              child: badges.Badge(
                showBadge:
                (optionVolistSon['currentPrice'] != 0) ? true : false,
                badgeContent: Text(
                    (optionVolistSon['currentPrice'] > 0)
                        ? "+${optionVolistSon['currentPrice'].toString()}円"
                        : "${optionVolistSon['currentPrice'].toString()}円",
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(16),
                      color: ColorsUtil.hexToColor(Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position: badges.BadgePosition.topEnd(top: -18, end: -9),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding:
                  EdgeInsets.only(left: 5, top: 3, right: 5, bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (optionVolistSon['currentPrice'] > 0)
                      ? ColorsUtil.hexToColor("#ef4136")
                      : ColorsUtil.hexToColor("#1d953f"),
                ),
                child: Container(
                  //width: ScreenAdapter.width(135),
                    height: ScreenAdapter.height(50),
                    alignment: Alignment.center,
                    decoration: (optionVolistSon['checked'] == true)
                        ? BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#C47829"),
                          ColorsUtil.hexToColor("#854610"),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    )
                        : (buttonColor.length > 0)
                        ? BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      //color: ColorsUtil.hexToColor(optionVolistSon['buttonColorValue']),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor(buttonColor[0]),
                          ColorsUtil.hexToColor(buttonColor[1]),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    )
                        : BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#E9CE9B"),
                          ColorsUtil.hexToColor("#CEA062"),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (optionVolistSon['homeImage'] != "" &&
                            optionVolistSon['homeImage'] != null)
                            ? CachedNetworkImage(
                            imageUrl: optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(15),
                            height: ScreenAdapter.height(25),
                            color: (optionVolistSon['checked'] == true)
                                ? ColorsUtil.hexToColor(
                                Gcolor.optionBtnColor)
                                : ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(2),
                        ),
                        Container(
                          //width: ScreenAdapter.width(210),
                          height: ScreenAdapter.height(50),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(125),
                              minHeight: ScreenAdapter.height(24),
                              maxHeight: ScreenAdapter.height(48),
                            ),
                            child: AutoSizeText(
                              optionVolistSon['mainTitle'],
                              style: TextStyle(
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(28.0),
                                color: (optionVolistSon['checked'] == true)
                                    ? ColorsUtil.hexToColor(
                                    Gcolor.optionBtnColor)
                                    : ColorsUtil.hexToColor("#914F14"),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ));
        }

        options.add(Container(
          child: Wrap(
            spacing: ScreenAdapter.width(5), // set spacing here
            runSpacing: ScreenAdapter.height(10),
            alignment: WrapAlignment.start,
            children: optionSons,
          ),
        ));
      }
    }

    return options;
  }

  //获取第三个页面的widget
  publicShowThreeMenuOptionGroupWidget(menuCode, menuindex, qtyBounds) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(8),
          right: ScreenAdapter.width(3),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: getThreeOptionWidget(menuCode, menuindex, qtyBounds),
      ),
    );
  }

  //第四个酒水分类
  showCategoryFour(showItemList, context, {popupType: "old"}) {
    if (showItemList != null && showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategoryFourItemList(showItemList, context,
            popupType: popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryTwoItemOne(item, context, {popupType: "old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {
            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              checkQtyBoundsCount(item, "", popupType, context);
            } else {
              //如果option 存在，则弹出option
              if (item['optionGroupVoList']?.length > 0) {
                if (popupType == "v1") {
                  publicShowOneItemWidgetv1(item);
                } else {
                  publicShowOneItemWidget(item);
                }
              } else {
                publicAddCart(context, item);
              }
            }
          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor("#FFFFFF"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(
                            imgPath: item['homeImage'],
                            imgWidth: 350.0,
                            imgHeight: 350.0,
                            subTitle: item["subtitle"]),
                        Divider(
                          height: 1.5,
                          indent: 0.0,
                          color: ColorsUtil.hexToColor("#DDDDDD"),
                        ),
                        Container(
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(70),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuTitle(
                              item['mainTitle'],
                              GFontSize.menuTwoListTitle,
                              Gcolor.mainTitleColor),
                        ),
                        /*SizedBox(
                          height: ScreenAdapter.height(8),
                        ),*/
                        Container(
                          //width: ScreenAdapter.width(125),
                          //height: ScreenAdapter.height(315),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                              item['currentPrice'],
                              item['price'],
                              GFontSize.menuTwopriceLift,
                              Gcolor.mainTitleColor,
                              GFontSize.menuTwoprice,
                              Gcolor.priceColor,
                              GFontSize.menuTwopriceRight,
                              Gcolor.mainTitleColor),
                        ),
                      ],
                    )),
                //绝对定位 盖章
                publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第三个分类 定食
  showCategoryThree(showItemList) {
    if (showItemList != null && showItemList.length > 0) {
      return Container(
        padding: EdgeInsets.only(
            top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(15)),
        //height: 450,
        child: showCategoryThreeItemList(showItemList),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryFourItemOne(item, context, {popupType: "old"}) {
    Offset temp;

    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {
            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              checkQtyBoundsCount(item, "", popupType, context);
            } else {
              //如果option 存在，则弹出option
              if (item['optionGroupVoList']?.length > 0) {
                //publicShowOneItemWidget(item);
                if (popupType == "v1") {
                  publicShowOneItemWidgetv1(item);
                } else {
                  publicShowOneItemWidget(item);
                }
              } else {
                publicAddCart(context, item);
              }
            }
          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(
                            imgPath: item['homeImage'],
                            imgWidth: 260.0,
                            imgHeight: 380.0,
                            subTitle: item["subtitle"]),
                        Divider(
                          height: 1.5,
                          indent: 0.0,
                          color: ColorsUtil.hexToColor("#DDDDDD"),
                        ),
                        SizedBox(
                          height: ScreenAdapter.height(8),
                        ),
                        Container(
                          //width: ScreenAdapter.width(1080),
                          //height: ScreenAdapter.height(315),
                          height: ScreenAdapter.height(65),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //菜单Title
                              Expanded(
                                  child: publicShowMenuTitle(
                                      item['mainTitle'],
                                      GFontSize.menuFourListTitle,
                                      Gcolor.mainTitleColor)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenAdapter.height(3),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              //top: ScreenAdapter.height(8),
                              right: ScreenAdapter.width(5)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              //价格展示
                              publicShowMenuPrice(
                                  item['currentPrice'],
                                  item['price'],
                                  GFontSize.menuFourpriceLift,
                                  Gcolor.mainTitleColor,
                                  GFontSize.menuFourprice,
                                  Gcolor.priceColor,
                                  GFontSize.menuFourpriceRight,
                                  Gcolor.mainTitleColor),
                            ],
                          ),
                        ),
                      ],
                    )),
                //绝对定位 盖章
                publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第五个分类 期间限定
  showCategoryFive(showItemList) {
    if (showItemList != null && showItemList.length > 0) {
      return Container(
        padding: EdgeInsets.only(
            top: ScreenAdapter.height(8),
            //left: ScreenAdapter.width(8),
            //right: ScreenAdapter.width(8),
            bottom: ScreenAdapter.height(15)),
        //height: 450,
        child: showCategoryFiveItemList(showItemList),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryFiveItemList(items) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives: true,
        //addRepaintBoundaries:false,
        itemBuilder: (BuildContext context, int index) {
          return showCategoryFiveItemOne(items[index], index);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryFiveItemOne(item, index) {
    Offset temp;
    var subtitle = "";
    if (item["subtitle"] != null && item["subtitle"].length > 0) {
      for (var i = 0; i < item["subtitle"].length; i++) {
        subtitle += item["subtitle"][i];
      }
    }

    return Container(
      margin: EdgeInsets.only(top: ScreenAdapter.width(20)),
      padding: EdgeInsets.only(top: ScreenAdapter.height(8)),
      decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: ColorsUtil.hexToColor("#c38d4d"), width: 2.0),
          )),
      child: Material(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: ScreenAdapter.height(10),
                  bottom: ScreenAdapter.height(10)),
              margin: EdgeInsets.only(
                  left: ScreenAdapter.width(10),
                  right: ScreenAdapter.width(10)),
              color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              child: StatefulBuilder(
                builder: (BuildContext context, menuFiveindex) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          bottom: ScreenAdapter.height(5),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            publicShowMenuImage(
                                imgPath: item['homeImage'],
                                imgWidth: 400.0,
                                imgHeight: 260.0),
                            (item['optionGroupVoList']?.length > 0)
                                ? Expanded(
                                child: publicShowFiveMenuOptionGroupWidget(
                                    item['menuCode'],
                                    menuFiveindex,
                                    item['qtyBounds']))
                                : Container(
                              height: 0,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1.5,
                        indent: 0.0,
                        color: ColorsUtil.hexToColor("#DDDDDD"),
                      ),

                      //标题价格
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Container(
                                padding:
                                EdgeInsets.only(left: ScreenAdapter.width(10)),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        //菜单Title
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.only(
                                                right: ScreenAdapter.width(15)),
                                            child: publicShowMenuTitle(
                                                item['mainTitle'],
                                                32.0,
                                                Gcolor.mainTitleColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        //副标题
                                        subtitle != ""
                                            ? Expanded(
                                            child: Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '${subtitle}',
                                                style: TextStyle(
                                                    fontFamily:
                                                    GFont.getFontFamily(),
                                                    fontSize: ScreenAdapter
                                                        .fontSize(GFontSize
                                                        .menuThreeListFoodSubtitle),
                                                    fontWeight: FontWeight.w600,
                                                    color: ColorsUtil.hexToColor(
                                                        Gcolor.mainTitleColor)),
                                              ),
                                            ))
                                            : Container(
                                          width: 0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                          //价格展示 item['currentPrice']
                          Container(
                            padding:
                            EdgeInsets.only(right: ScreenAdapter.width(30)),
                            //width: ScreenAdapter.width(200),
                            alignment: Alignment.bottomRight,
                            //alignment: Alignment.centerRight,
                            child: publicShowMenuPrice(
                                selectedMenuOptionChangePrice
                                    .value[item['menuCode']] +
                                    addselectedMenuOptionChangePrice
                                        .value[item['menuCode']],
                                item['price'],
                                35.0,
                                Gcolor.mainTitleColor,
                                54.0,
                                Gcolor.priceColor,
                                28.0,
                                Gcolor.mainTitleColor),
                          ),
                          //确认按钮
                          InkWell(
                            enableFeedback: false,
                            onTap: () async {
                              if (item['qtyBounds'] == 0) {
                                return;
                              } else if (item['qtyBounds'] > 0) {
                                //请求限定接口
                                var cartItemNum = await ordersqlcontroller
                                    .getCartItemNum(item['menuCode']);
                                print(cartItemNum);
                                if (cartItemNum >= item['qtyBounds']) {
                                  var showString = GString.getToString(
                                      checkLanguage.value,
                                      "show_storage_num_error");
                                  //showToast("${showString}");
                                  Get.dialog(DialogUtils.alertOneButton(
                                      showString,
                                      title: GString.getToString(
                                          checkLanguage.value,
                                          "tag_title"),
                                      confirmtitle: GString.getToString(
                                          checkLanguage.value,
                                          "tag_button_yes"), confirm: () {
                                    Get.back();
                                  }));
                                  return;
                                }
                              }

                              //判断选择后option是否与optiongroup相等
                              var optionCodeList = "";
                              var optionTitle = "";
                              var currentPrice = item['currentPrice'];
                              if (item['optionGroupVoList']?.length > 0) {
                                //item['optionGroupVoList'].length

                                //--------------检测option单选还是多选是否满足
                                var attr = menuOption.value[item['menuCode']];
                                var nexOrder = true;
                                for (var i = 0; i < attr.length; i++) {
                                  //如果是多选，那么需要判断该组option数量是否超过最大值
                                  if (int.parse(attr[i]["smallest"]) > 0) {
                                    var current_option_checked = 0;
                                    for (var n = 0;
                                    n < attr[i]['optionVoList'].length;
                                    n++) {
                                      if (attr[i]['optionVoList'][n]
                                      ["checked"] ==
                                          true) {
                                        current_option_checked++;
                                      }
                                    }
                                    if (current_option_checked <
                                        int.parse(attr[i]["smallest"])) {
                                      nexOrder = false;
                                      var showTag = GString.getToString(
                                          checkLanguage.value,
                                          "menu_option_less_smallest");
                                      //showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                      Get.dialog(DialogUtils.alertOneButton(
                                          "${showTag.replaceAll("%%", attr[i]["groupName"])}",
                                          title: GString.getToString(
                                              checkLanguage.value,
                                              "tag_title"),
                                          confirmtitle: GString.getToString(
                                              checkLanguage.value,
                                              "tag_button_yes"), confirm: () {
                                        Get.back();
                                      }));
                                      break;
                                    }
                                  }
                                }
                                if (nexOrder == false) return;
                                //--------------end
                                var checkoptionGroupList = {};
                                for (var optionItem in selectedMenuOptionList
                                    .value[item['menuCode']]) {
                                  currentPrice += optionItem['currentPrice'];

                                  optionCodeList += (optionCodeList != "")
                                      ? "," + optionItem['optionCode']
                                      : optionItem['optionCode'];
                                  var groupKey = optionItem['group'];
                                  //整理新数组
                                  checkoptionGroupList[groupKey] = {
                                    "optionTitles":
                                    (checkoptionGroupList[groupKey] == null)
                                        ? optionItem['mainTitle']
                                        : checkoptionGroupList[groupKey]
                                    ["optionTitles"] +
                                        "," +
                                        optionItem['mainTitle'],
                                    "groupTitle": optionItem['groupTitle']
                                  };
                                }

                                checkoptionGroupList.forEach((key, value) {
                                  optionTitle += (optionTitle != "")
                                      ? "," +
                                      value['groupTitle'] +
                                      ":" +
                                      value['optionTitles']
                                      : value['groupTitle'] +
                                      ":" +
                                      value['optionTitles'];
                                });
                              }

                              var cartItem = {
                                "menuCode": item['menuCode'],
                                "mainTitle": item['mainTitle'],
                                "image": item['homeImage'],
                                "currentPrice": currentPrice,
                                "optionGroupVoList": optionCodeList,
                                "optionVoListMsg": optionTitle,
                                "goodsNum": 1,
                                "qtyBounds": item['qtyBounds'],
                                "unitPrice": currentPrice
                              };
                              publicAddCartMenu(cartItem, false)
                                  .then((val) {
                                //更改显示购物车价格
                                //getCartPriceTotal();
                                if (val != false) {
                                  publicShowAddCartNew(context);
                                }

                                if (item['optionGroupVoList']?.length > 0) {
                                  changeInitialAllOption(item['menuCode']);
                                }
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                  top: ScreenAdapter.height(15)),
                              width: ScreenAdapter.width(250),
                              height: ScreenAdapter.height(67),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (item['qtyBounds'] != 0)
                                    ? ColorsUtil.hexToColor("#078E42")
                                    : ColorsUtil.hexToColor("#C1C1C1"),
                                borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Text(
                                  GString.getToString(
                                      checkLanguage.value,
                                      "add_option_cart"),
                                  style: TextStyle(
                                    fontFamily: GFont.getFontFamily(),
                                    fontSize: ScreenAdapter.fontSize(32),
                                    fontWeight: FontWeight.w500,
                                    color: ColorsUtil.hexToColor(
                                        Gcolor.optionBtnColor),
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            //绝对定位 盖章
            publicShowMenuSellOut(item['qtyBounds']),
          ],
        ),
      ),
    );
  }

  getFiveOptionWidget(menuCode, setFirstState, qtyBounds) {
    var optionGroupVoList = menuOption.value[menuCode];
    List<Widget> options = []; //先建一个数组用于存放循环生成的widget
    if (optionGroupVoList != null &&
        optionGroupVoList.length > 0 &&
        optionGroupVoList != "") {
      for (var i = 0; i < optionGroupVoList.length; i++) {
        if (i >= optionGroupMaxNum.value) break;
        List<Widget> optionSons = [];
        var optionVoList = optionGroupVoList[i]['optionVoList'];
        options.add(Container(
          padding: EdgeInsets.only(
              top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                    text: "${optionGroupVoList[i]['groupName']}",
                    //GString.getToString(this._checkLanguage, "show_price_front"),
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(24.0),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                    children: [
                      TextSpan(
                        text: (optionGroupVoList[i]['remark'] != null &&
                            optionGroupVoList[i]['remark'] != "")
                            ? " ${optionGroupVoList[i]['remark']}"
                            : "",
                        style: TextStyle(
                          fontFamily: GFont.getFontFamily(),
                          fontSize: ScreenAdapter.fontSize(18.0),
                          fontWeight: FontWeight.w200,
                          color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                        ),
                      ),
                    ]),
              )
            ],
          ),
        ));

        for (var j = 0; j < optionVoList.length; j++) {
          if (j >= optionMaxNum.value) break;
          var optionVolistSon = optionVoList[j];

          var buttonColor = [];
          if (optionVolistSon['buttonColorValue'] != null &&
              optionVolistSon['buttonColorValue'] != "") {
            buttonColor = optionVolistSon['buttonColorValue'].split(',');
          }
          optionSons.add(Container(
            width: ScreenAdapter.width(207),
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(7),
                top: ScreenAdapter.height(5),
                right: ScreenAdapter.width(7),
                bottom: ScreenAdapter.height(5)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                if (qtyBounds != 0) {
                  changeOptionv1(
                      menuCode,
                      optionGroupVoList[i]["groupCode"],
                      optionVolistSon["optionCode"],
                      setFirstState);
                }
              },
              child: badges.Badge(
                showBadge:
                (optionVolistSon['currentPrice'] != 0) ? true : false,
                badgeContent: Text(
                    (optionVolistSon['currentPrice'] > 0)
                        ? "+${optionVolistSon['currentPrice'].toString()}円"
                        : "${optionVolistSon['currentPrice'].toString()}円",
                    style: TextStyle(
                      fontFamily: GFont.getFontFamily(),
                      fontSize: ScreenAdapter.fontSize(16),
                      color: ColorsUtil.hexToColor(Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position: badges.BadgePosition.topEnd(top: -18, end: -9),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding:
                  EdgeInsets.only(left: 5, top: 3, right: 5, bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (optionVolistSon['currentPrice'] > 0)
                      ? ColorsUtil.hexToColor("#ef4136")
                      : ColorsUtil.hexToColor("#1d953f"),
                ),
                child: Container(
                  //width: ScreenAdapter.width(160),
                    height: ScreenAdapter.height(55),
                    alignment: Alignment.center,
                    decoration: (optionVolistSon['checked'] == true)
                        ? BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#C47829"),
                          ColorsUtil.hexToColor("#854610"),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    )
                        : (buttonColor.length > 0)
                        ? BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      //color: ColorsUtil.hexToColor(optionVolistSon['buttonColorValue']),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor(buttonColor[0]),
                          ColorsUtil.hexToColor(buttonColor[1]),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    )
                        : BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(10.0)),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          ColorsUtil.hexToColor("#E9CE9B"),
                          ColorsUtil.hexToColor("#CEA062"),
                        ],
                      ),
                      //设置阴影
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (optionVolistSon['homeImage'] != "" &&
                            optionVolistSon['homeImage'] != null)
                            ? CachedNetworkImage(
                            imageUrl: optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(15),
                            height: ScreenAdapter.height(25),
                            color: (optionVolistSon['checked'] == true)
                                ? ColorsUtil.hexToColor(
                                Gcolor.optionBtnColor)
                                : ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(3),
                        ),
                        Container(
                          //width: ScreenAdapter.width(210),
                          height: ScreenAdapter.height(60),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(160),
                              minHeight: ScreenAdapter.height(26),
                              maxHeight: ScreenAdapter.height(52),
                            ),
                            child: AutoSizeText(
                              optionVolistSon['mainTitle'],
                              style: TextStyle(
                                fontFamily: GFont.getFontFamily(),
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(28.0),
                                color: (optionVolistSon['checked'] == true)
                                    ? ColorsUtil.hexToColor(
                                    Gcolor.optionBtnColor)
                                    : ColorsUtil.hexToColor("#914F14"),
                              ),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    )),
              ),
            ),
          ));
        }

        options.add(Container(
          child: Wrap(
            spacing: ScreenAdapter.width(5), // set spacing here
            runSpacing: ScreenAdapter.height(10),
            alignment: WrapAlignment.start,
            children: optionSons,
          ),
        ));
      }
    }

    return options;
  }

  //获取第五个页面的widget
  publicShowFiveMenuOptionGroupWidget(menuCode, menuindex, qtyBounds) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(8),
          right: ScreenAdapter.width(3),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: getFiveOptionWidget(menuCode, menuindex, qtyBounds),
      ),
    );
  }

  //第六个分类 每页两列一行
  showCategorySix(showItemList, context, {popupType: "old"}) {
    //debugPrint("showItemList:${showItemList}");
    if (showItemList != null && showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategorySixItemList(showItemList, context,
            popupType: popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategorySixItemList(items, context, {popupType: "old"}) {
    List<Widget> children = [];
    for (var item in items) {
      children.add(menuItemView(item, context, popupType: popupType));
    }

    return GridMenuView(children: children, crossAxisCount: 2);
  }

  showCategorySixItemOne(item, context, {popupType: "old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {
            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              checkQtyBoundsCount(item, "", popupType, context);
            } else {
              //如果option 存在，则弹出option
              if (item['optionGroupVoList']?.length > 0) {
                if (popupType == "v1") {
                  publicShowOneItemWidgetv1(item);
                } else {
                  publicShowOneItemWidget(item);
                }
              } else {
                publicAddCart(context, item);
              }
            }
          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(
                            imgPath: item['homeImage'],
                            imgWidth: 530.0,
                            imgHeight: 530.0,
                            subTitle: item["subtitle"]),
                        Divider(
                          height: 1.5,
                          indent: 0.0,
                          color: ColorsUtil.hexToColor("#DDDDDD"),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: ScreenAdapter.height(5)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          height: ScreenAdapter.height(68),
                          child: publicShowMenuTitle(
                              item['mainTitle'],
                              GFontSize.menuTwoListTitle,
                              Gcolor.mainTitleColor),
                        ),
                        Container(
                          //width: ScreenAdapter.width(125),
                          //height: ScreenAdapter.height(315),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                              item['currentPrice'],
                              item['price'],
                              GFontSize.menuTwopriceLift,
                              Gcolor.mainTitleColor,
                              GFontSize.menuTwoprice,
                              Gcolor.priceColor,
                              GFontSize.menuTwopriceRight,
                              Gcolor.mainTitleColor),
                        ),
                      ],
                    )),
                //绝对定位 盖章
                publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第七个分类 每页三列一行  饮品
  showCategorySeven(showItemList, context, {popupType: "old"}) {
    if (showItemList != null && showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategorySevenItemList(showItemList, context, popupType: popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategorySevenItemList(items, context, {popupType: "old"}) {
    List<Widget> children = [];
    for (var item in items) {
      children.add(menuItemView(item, context, popupType: popupType, aspectRatio: 0.63));
    }
    return GridMenuView(children: children, childAspectRatio: 0.5,);
    // return Padding(
    //   padding: EdgeInsets.only(
    //       top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
    //   child: GridView.builder(
    //     padding: EdgeInsets.zero,
    //     shrinkWrap: true,
    //     addAutomaticKeepAlives: true,
    //     //addRepaintBoundaries:false,
    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    //         mainAxisSpacing: ScreenAdapter.height(10),
    //         crossAxisCount: 3,
    //         childAspectRatio: 0.63),
    //     itemBuilder: (BuildContext context, int index) {
    //       return showCategorySevenItemOne(items[index], context,
    //           popupType: popupType);
    //     },
    //     itemCount: items.length,
    //   ),
    // );
  }

  showCategorySevenItemOne(item, context, {popupType: "old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {
            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              checkQtyBoundsCount(item, "", popupType, context);
            } else {
              //如果option 存在，则弹出option
              if (item['optionGroupVoList']?.length > 0) {
                //publicShowOneItemWidget(item);
                if (popupType == "v1") {
                  publicShowOneItemWidgetv1(item);
                } else {
                  publicShowOneItemWidget(item);
                }
              } else {
                publicAddCart(context, item);
              }
            }
          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(
                            imgPath: item['homeImage'],
                            imgWidth: 350.0,
                            imgHeight: 440.0,
                            subTitle: item["subtitle"]),
                        Divider(
                          height: 1.5,
                          indent: 0.0,
                          color: ColorsUtil.hexToColor("#DDDDDD"),
                        ),
                        Container(
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(70),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuTitle(
                              item['mainTitle'],
                              GFontSize.menuTwoListTitle,
                              Gcolor.mainTitleColor),
                        ),
                        Container(
                          //width: ScreenAdapter.width(125),
                          //height: ScreenAdapter.height(315),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                              item['currentPrice'],
                              item['price'],
                              GFontSize.menuTwopriceLift,
                              Gcolor.mainTitleColor,
                              GFontSize.menuTwoprice,
                              Gcolor.priceColor,
                              GFontSize.menuTwopriceRight,
                              Gcolor.mainTitleColor),
                        ),
                      ],
                    )),
                //绝对定位 盖章
                publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第八个分类 混合排列，第一行一大两小，其余三个一行每页三列一行
  showCategoryEight(showItemList, context, {popupType: "old"}) {
    if (showItemList != null && showItemList.length > 0) {
      if (showItemList.length >= 3) {
        var _leftItem = showItemList[0];
        var _rightTop = showItemList[1];
        var _rightBottom = showItemList[2];
        var _newItemList = showItemList.sublist(3);

        return Container(
          padding: EdgeInsets.only(
            top: ScreenAdapter.height(8),
          ),
          child:
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child:
            Column(mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left:ScreenAdapter.width(15),
                        right: ScreenAdapter.width(15),
                        bottom: ScreenAdapter.height(30)
                    ),
                    child: IntrinsicHeight(
                        child:
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 2,
                              child:
                              AspectRatio(
                                aspectRatio: 0.71,
                                child: menuItemView(_leftItem, context, popupType: popupType, aspectRatio: 0.9),
                              ),

                            ),
                            SizedBox(width: 20),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 0.76,
                                        child: menuItemView(_rightTop, context, popupType: popupType, aspectRatio: 1.0),
                                      ),

                                    ),
                                    SizedBox(height: 20),
                                    Expanded(
                                      child: AspectRatio(
                                        aspectRatio: 0.76,
                                        child: menuItemView(_rightBottom, context, popupType: popupType, aspectRatio: 1.0),
                                      ),
                                    ),
                                  ],
                                )
                            )
                          ],
                        )
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_newItemList.length > 0)
                    showCategoryEightItemList(_newItemList, context, popupType: popupType),
                ]
            ),
          ),
        );
      } else {
        return Container(
          child: showCategoryEightItemList(showItemList, context, popupType: popupType),
        );
      }
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryEightItemList(items, context, {popupType: "old"}) {
    List<Widget> children = [];
    for (var item in items) {
      children.add(menuItemView(item, context, popupType: popupType, aspectRatio: 1.0));
    }
    return GridMenuView(children: children, crossAxisCount: 3, childAspectRatio: 0.71, canScroll: false,);
  }

  showCategoryEightItemOne(item, context, {popupType: "old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {
            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              checkQtyBoundsCount(item, "", popupType, context);
            } else {
              //如果option 存在，则弹出option
              if (item['optionGroupVoList']?.length > 0) {
                if (popupType == "v1") {
                  publicShowOneItemWidgetv1(item);
                } else {
                  publicShowOneItemWidget(item);
                }
              } else {
                publicAddCart(context, item);
              }
            }
          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor("#FFFFFF"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(
                            imgPath: item['homeImage'],
                            imgWidth: 350.0,
                            imgHeight: 350.0,
                            subTitle: item["subtitle"]),
                        Divider(
                          height: 1.5,
                          indent: 0.0,
                          color: ColorsUtil.hexToColor("#DDDDDD"),
                        ),
                        Container(
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(68),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuTitle(
                              item['mainTitle'],
                              GFontSize.menuTwoListTitle,
                              Gcolor.mainTitleColor),
                        ),
                        SizedBox(
                          height: ScreenAdapter.height(8),
                        ),
                        Container(
                          //width: ScreenAdapter.width(125),
                          //height: ScreenAdapter.height(315),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                            item['currentPrice'],
                            item['price'],
                            GFontSize.menuTwopriceLift,
                            Gcolor.mainTitleColor,
                            GFontSize.menuTwoprice,
                            Gcolor.priceColor,
                            GFontSize.menuTwopriceRight,
                            Gcolor.mainTitleColor,
                          ),
                        ),
                      ],
                    )),
                //绝对定位 盖章
                publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第九个分类 混合排列，第一行一大两小，其余2个一行每页2列一行
  showCategoryNine(showItemList, context, {popupType: "old"}) {
    if (showItemList.length > 0) {
      if (showItemList.length >= 3) {
        var _leftItem = showItemList[0];
        var _rightTop = showItemList[1];
        var _rightBottom = showItemList[2];
        var _newItemList = showItemList.sublist(3);

        return Container(
          padding: EdgeInsets.only(
            top: ScreenAdapter.height(8),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(
                      left:ScreenAdapter.width(15),
                      right: ScreenAdapter.width(15),
                      bottom: ScreenAdapter.height(30)
                  ),
                  child: IntrinsicHeight(
                      child:
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 2,
                            child:
                            AspectRatio(
                              aspectRatio: 0.71,
                              child: menuItemView(_leftItem, context, popupType: popupType, aspectRatio: 0.9),
                            ),

                          ),
                          SizedBox(width: 20),
                          Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 0.76,
                                      child: menuItemView(_rightTop, context, popupType: popupType, aspectRatio: 1.0),
                                    ),

                                  ),
                                  SizedBox(height: 20),
                                  Expanded(
                                    child: AspectRatio(
                                      aspectRatio: 0.76,
                                      child: menuItemView(_rightBottom, context, popupType: popupType, aspectRatio: 1.0),
                                    ),
                                  ),
                                ],
                              )
                          )
                        ],
                      )
                  ),
                ),
                SizedBox(height: 20),
                if (_newItemList.length > 0)
                  showCategoryNineItemList(_newItemList, context, popupType: popupType)
              ],
            ),
          ),
        );
      } else {
        return Container(
          child: showCategoryNineItemList(showItemList, context, popupType: popupType),
        );
      }
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryNineItemList(items, context ,{popupType: "old"}) {
    List<Widget> children = [];
    for (var item in items) {
      children.add(menuItemView(item, context, popupType: popupType, aspectRatio: 1.0));
    }
    return GridMenuView(children: children, crossAxisCount: 2, childAspectRatio: 0.76, canScroll: false,);
  }

  showCategoryNineItemOne(item, context, {popupType: "old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          onTap: () async {
            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              checkQtyBoundsCount(item, "", popupType, context);
            } else {
              //如果option 存在，则弹出option
              if (item['optionGroupVoList']?.length > 0) {
                //publicShowOneItemWidget(item);
                if (popupType == "v1") {
                  publicShowOneItemWidgetv1(item);
                } else {
                  publicShowOneItemWidget(item);
                }
              } else {
                publicAddCart(context, item);
              }
            }
          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                    color: ColorsUtil.hexToColor("#FFFFFF"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(
                            imgPath: item['homeImage'],
                            imgWidth: 530.0,
                            imgHeight: 530.0,
                            subTitle: item["subtitle"]),
                        Divider(
                          height: 1.5,
                          indent: 0.0,
                          color: ColorsUtil.hexToColor("#DDDDDD"),
                        ),
                        Container(
                          width: ScreenAdapter.width(530),
                          height: ScreenAdapter.height(68),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuTitle(
                              item['mainTitle'],
                              GFontSize.menuTwoListTitle,
                              Gcolor.mainTitleColor),
                        ),
                        Container(
                          //width: ScreenAdapter.width(125),
                          //height: ScreenAdapter.height(315),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              right: ScreenAdapter.width(10)),
                          child: publicShowMenuPrice(
                              item['currentPrice'],
                              item['price'],
                              GFontSize.menuTwopriceLift,
                              Gcolor.mainTitleColor,
                              GFontSize.menuTwoprice,
                              Gcolor.priceColor,
                              GFontSize.menuTwopriceRight,
                              Gcolor.mainTitleColor),
                        ),
                      ],
                    )),
                //绝对定位 盖章
                publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }


}