import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodorder/app/modules/menuPage/views/publicShowCart.dart';

import 'package:get/get.dart';
import 'package:badges/badges.dart' as badges;
import 'package:get_storage/get_storage.dart';

import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/fontSize.dart';
import '../../../config/imageData.dart';
import '../../../config/string.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/showImage.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../controllers/menu_page_controller.dart';

class MenuzongPageView extends GetView {
  final MenuPageController controller = Get.put(MenuPageController());
  MenuzongPageView({Key? key}) : super(key: key);

  //左侧分类导航
  showLeftCategoryMenu() {
    List<Widget> categoryMenus = []; //先建一个数组用于存放循环生成的widget
    int _categoryNum = 1;

    for (var item in controller.topMenu.value) {
      categoryMenus.add(InkWell(
        //enableFeedback: false,
        onTap: () {
          controller.changeCategory(item['categoryCode']);
        },
        child: Stack(
          children: [
            Container(
              //margin: EdgeInsets.only(top: ScreenAdapter.height(2),bottom: ScreenAdapter.height(2)),
              //width: ScreenAdapter.width(75), //(classTag == item['categoryCode']) ? ScreenAdapter.width(102) : ScreenAdapter.width(72),
              //height: ScreenAdapter.height(190),
              decoration: (controller.classTag.value == item['categoryCode']) ? BoxDecoration(
                //设置边框
                //border: new Border.all(color: ColorsUtil.hexToColor("#F9F9F9"), width: 0.5),
                //背景颜色
                color: ColorsUtil.hexToColor(item['showColor']),
                border: Border(
                  bottom: BorderSide(color: ColorsUtil.hexToColor("#e5e5e5"), width: 5),
                ),
              ) : BoxDecoration(
                //背景颜色
                color: ColorsUtil.hexToColor(item['showColor']),
                border: Border(
                  bottom: BorderSide(color: ColorsUtil.hexToColor("#e5e5e5"), width: 5),
                ),
              ),
              child: Center(
                //加上Center让文字居中
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: ScreenAdapter.height(10),bottom: ScreenAdapter.height(10)),
                      width: ScreenAdapter.width(35),
                      child: controller.checkLanguage.value != "EN" ?Text(
                        item['categoryName'],
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(28),
                          //color: ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                          color: ColorsUtil.hexToColor("#282828"),
                          fontWeight: FontWeight.w600,
                        ),
                        //maxLines: 2,
                        //overflow: TextOverflow.ellipsis,
                      ):RotatedBox(quarterTurns: 1,child: Text(
                        item['categoryName'],
                        style: TextStyle(
                            fontSize: ScreenAdapter.fontSize(28),
                            //color: ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                            color: ColorsUtil.hexToColor("#282828"),
                            fontWeight: FontWeight.w600),
                        //maxLines: 2,
                        //overflow: TextOverflow.ellipsis,
                      ),),
                    ),
                  ],
                ),
              ),
            ),
            (controller.classTag.value == item['categoryCode'])
                ? Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  //width: ScreenAdapter.width(10),
                  //color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                  child: Image.asset(
                    GImage.getImageString("imgpublic", "zong_menu_up"),
                    width: ScreenAdapter.width(17),
                    fit: BoxFit.fitWidth,
                    color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                  )
                ),
              ),
            )
                : Container(
              height: 0,
            ),
          ],
        ),
      ));

      _categoryNum++;
    }

    //categoryMenus.add();

    return Container(
      //padding: EdgeInsets.only(left: ScreenAdapter.width(5)),
      //width: ScreenAdapter.width(75),
      //height: ScreenAdapter.height(1465),
      alignment: Alignment.topCenter,
      //color: ColorsUtil.hexToColor("#545454"),
      child: ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.zero,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: categoryMenus,
      ),
    );
  }

  //中间分类页面
  showMiddleMenuList(BuildContext context) {
    for (var item in controller.topMenu.value) {
      if (controller.classTag.value == item['categoryCode']) {
        if (item['showType'] == "featured") {
          return _showCategoryOne(controller.showItem.value[controller.classTag.value],context);
        } else if (item['showType'] == "table") { //350.0, 350.0
          return _showCategoryTwo(controller.showItem.value[controller.classTag.value],context);
          //return _showCategoryEight(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "table_v1") { //350.0, 350.0
          return _showCategoryTwo(controller.showItem.value[controller.classTag.value],context,popupType: "v1");
          //return _showCategoryEight(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "block") { //350.0, 350.0
          return _showCategoryThree(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "grid") { //260.0, 400.0
          return _showCategoryFour(controller.showItem.value[controller.classTag.value],context);
        } else if (item['showType'] == "grid_v1") { //260.0, 400.0
          return _showCategoryFour(controller.showItem.value[controller.classTag.value],context,popupType: "v1");
        }else if (item['showType'] == "waterfall") { //400.0, 260.0
          return _showCategoryFive(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "double_column") { //530.0, 530.0
          return _showCategorySix(controller.showItem.value[controller.classTag.value],context);
        } else if (item['showType'] == "double_column_v1") { //530.0, 530.0
          return _showCategorySix(controller.showItem.value[controller.classTag.value],context,popupType: "v1");
        } else if (item['showType'] == "three_column") { //350.0, 440.0
          return _showCategorySeven(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "three_column_v1") { //350.0, 440.0
          return _showCategorySeven(controller.showItem.value[controller.classTag.value],popupType: "v1");
        } else if (item['showType'] == "mixed_column") { //混合模式 底部一行3列710.0, 710.0 350.0, 310.0 350.0, 350.0
          return _showCategoryEight(controller.showItem.value[controller.classTag.value],context);
          //return _showCategoryNine(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "mixed_column_v1") { //混合模式 底部一行3列710.0, 710.0 350.0, 310.0 350.0, 350.0
          return _showCategoryEight(controller.showItem.value[controller.classTag.value],context,popupType: "v1");
          //return _showCategoryNine(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "mixed_two_column") { //混合模式 底部一行2列 710.0, 710.0 350.0, 310.0 530.0, 530.0
          return _showCategoryNine(controller.showItem.value[controller.classTag.value],context);
        } else if (item['showType'] == "mixed_two_column_v1") { //混合模式 底部一行2列 710.0, 710.0 350.0, 310.0 530.0, 530.0
          return _showCategoryNine(controller.showItem.value[controller.classTag.value],context,popupType: "v1");
        }else{
          return _showCategoryTwo(controller.showItem.value[controller.classTag.value],context);
        }
      }
    }
  }

  //第一分类页面
  _showCategoryOne(showItemList,context) {
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
        //color: ColorsUtil.hexToColor(Gcolor.mainBackground),
        padding: EdgeInsets.only(top:ScreenAdapter.height(8), bottom: ScreenAdapter.height(5)),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            publicShowMenuImage(imgPath:itemsFirst['homeImage'], imgWidth: 995.0, imgHeight: 850.0),
            Container(
              color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              width: ScreenAdapter.width(995),
              //height: ScreenAdapter.height(408),
              padding: EdgeInsets.only(
                  left: ScreenAdapter.width(25),
                  right: ScreenAdapter.width(25),
                  bottom: ScreenAdapter.height(15)),
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
                      Container(
                        margin: EdgeInsets.only(top: ScreenAdapter.height(10),bottom: ScreenAdapter.height(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                                child: controller.publicShowMenuTitle(itemsFirst['mainTitle'],
                                    38.0, Gcolor.mainTitleColor)),
                            //价格展示 //itemsFirst['currentPrice']
                            Container(
                              alignment: Alignment.centerRight,
                              //width: ScreenAdapter.width(200),
                              padding:EdgeInsets.only(right: ScreenAdapter.width(15)),
                              child: controller.publicShowMenuPrice(
                                  controller.selectedMenuOptionChangePrice.value[itemsFirst['menuCode']]+controller.addselectedMenuOptionChangePrice.value[itemsFirst['menuCode']],
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
                              /*onTapDown: (details) {
                              temp = new Offset(details.globalPosition.dx, details.globalPosition.dy);
                            },*/
                              onTap: () {

                                //判断选择后option是否与optiongroup相等
                                /*if (_selectedMenuOptionList[itemsFirst['menuCode']].length <_selectedMenuOptionCheckedNum[itemsFirst['menuCode']]) {
                                  showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                                  return;
                                }*/
                                var currentPrice = itemsFirst['currentPrice'];
                                var optionCodeList = "";
                                var optionTitle = "";

                                //--------------检测option单选还是多选是否满足
                                var attr = controller.menuOption.value[itemsFirst['menuCode']];
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
                                      var showTag = GString.getToString(controller.checkLanguage.value, "menu_option_less_smallest");
                                      //showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                      Get.dialog(
                                          DialogUtils.alertOneButton("${showTag.replaceAll("%%", attr[i]["groupName"])}",
                                              title: GString.getToString(controller.checkLanguage.value, "tag_title"),
                                              confirmtitle: GString.getToString(controller.checkLanguage.value,"tag_button_yes"),
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
                                for (var optionItem in controller.selectedMenuOptionList.value[itemsFirst['menuCode']]) {
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


                                /*for (var optionItem in _selectedMenuOptionList[itemsFirst['menuCode']]) {
                                  //if (optionItem['currentPrice'] != 0) {
                                  currentPrice += optionItem['currentPrice'];
                                  //}
                                  optionCodeList += (optionCodeList != "") ? "," + optionItem['optionCode'] : optionItem['optionCode'];
                                  optionTitle += (optionTitle != "") ? "," + optionItem['groupTitle']+":"+optionItem['mainTitle'] : optionItem['groupTitle']+":"+optionItem['mainTitle'];
                                }*/

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
                                controller.publicAddCartMenu(cartItem, false).then((val) {
                                  //_publicShowAddCart(temp,itemsFirst['homeImage']);
                                  if(val != false){
                                    controller.publicShowAddCartNew(context);
                                  }

                                  controller.changeInitialAllOption(itemsFirst['menuCode']);
                                  //更改显示购物车价格
                                  //getCartPriceTotal();
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
                                        controller.checkLanguage.value, "add_option_cart"),
                                    style: TextStyle(
                                      fontSize: ScreenAdapter.fontSize(34),
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
        children: _getFirstOptionWidget(menuCode, setFirstMenuState),
      ),
    );
  }
  //获取第一个页面的option widget
  _getFirstOptionWidget(menuCode, setFirstState) {
    var optionGroupVoList = controller.menuOption.value[menuCode];

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
                  //GString.getToString(controller.checkLanguage.value, "show_price_front"),
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(24.0),
                    fontWeight: FontWeight.w500,
                    color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                  ),
                  children: [
                    TextSpan(
                      text: (optionGroupVoList[i]['remark'] !=null && optionGroupVoList[i]['remark']!="")?" ${optionGroupVoList[i]['remark']}":"",
                      style: TextStyle(
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
        if (optionVolistSon['buttonColorValue'] != null && optionVolistSon['buttonColorValue'] != "") {
          buttonColor = optionVolistSon['buttonColorValue'].split(',');
        }
        optionSons.add(Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(
              left: ScreenAdapter.width(5),
              top: ScreenAdapter.height(10),
              right: ScreenAdapter.width(5),
              bottom: ScreenAdapter.height(8)),
          child: InkWell(
            //enableFeedback: true,
            onTap: () {
              controller.changeOptionv1(menuCode, optionGroupVoList[i]["groupCode"],
                  optionVolistSon["optionCode"], setFirstState);
            },
            child: badges.Badge(
              showBadge: (optionVolistSon['currentPrice'] != 0) ? true : false,
              badgeContent: Text(
                  (optionVolistSon['currentPrice'] > 0) ?"+${optionVolistSon['currentPrice'].toString()}円":"${optionVolistSon['currentPrice'].toString()}円",
                  style: TextStyle(
                    fontSize: ScreenAdapter.fontSize(16),
                    color: ColorsUtil.hexToColor(
                        Gcolor.optionBtnColor),
                  )),
              //padding: EdgeInsets.all(5),
              position:badges.BadgePosition.topEnd(top: -18, end: -9),
              badgeStyle: badges.BadgeStyle(
                shape: badges.BadgeShape.square,
                padding: EdgeInsets.only(left: 5,top: 3,right: 5,bottom: 3),
                borderRadius: BorderRadius.circular(5),
                badgeColor: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),

              ),
              child: Container(
                  width: ScreenAdapter.width(225),
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
                      : (buttonColor.length>0)?BoxDecoration(
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
                  )  :BoxDecoration(
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
                      (optionVolistSon['homeImage'] != "" && optionVolistSon['homeImage'] != null)
                          ? CachedNetworkImage(imageUrl:optionVolistSon['homeImage'],
                          width: ScreenAdapter.width(15),
                          height: ScreenAdapter.height(25),
                          color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                          fit: BoxFit.fitHeight)
                          : Container(
                        width: 0,
                      ),
                      SizedBox(
                        width: ScreenAdapter.width(10),
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
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenAdapter.fontSize(28.0),
                              color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
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
      options.add(Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: optionSons,
      ));


    }

    return options;
  }



  //第二个分类 小菜
  _showCategoryTwo(showItemList,context,{popupType:"old"}) {
    if (showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategoryTwoItemList(showItemList,context,popupType:popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryTwoItemList(items,context,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 3,
            childAspectRatio: 0.72),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryTwoItemOne(items[index],context,popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryTwoItemOne(item,context,{popupType:"old"}) {
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
              controller.checkQtyBoundsCount(item, "",popupType,context);

            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                //_publicShowOneItemWidget(item);
                if(popupType == "v1"){
                  controller.publicShowOneItemWidgetv1(item);
                }else{
                  controller.publicShowOneItemWidget(item);
                }
              }else{
                controller.publicAddCart(context,item);
              }
            }


          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                  //color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                    color: ColorsUtil.hexToColor("#f0f0f0"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 340.0, imgHeight: 340.0, subTitle: item['subtitle'],),

                        Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),

                        Container(
                          height: ScreenAdapter.height(68),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: controller.publicShowMenuTitle(
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
                          child: controller.publicShowMenuPrice(
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
                controller.publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第三个分类 定食
  _showCategoryThree(showItemList) {
    if (showItemList.length > 0) {
      return Container(
        padding: EdgeInsets.only(
            top: ScreenAdapter.height(8),
            bottom: ScreenAdapter.height(15)),
        //height: 450,
        child: showCategoryThreeItemList(showItemList),
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
        addAutomaticKeepAlives:true,
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
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8)),
      child: Material(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(10)),
              margin: EdgeInsets.only(left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
              //color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              color: ColorsUtil.hexToColor("#f0f0f0"),
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
                            publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 350.0, imgHeight: 350.0),
                            (item['optionGroupVoList']?.length > 0)
                                ? Expanded(child: publicShowThreeMenuOptionGroupWidget(
                                item['menuCode'], menuindex,item['qtyBounds']))
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
                                        Expanded(child: Container(
                                          padding: EdgeInsets.only(
                                              right: ScreenAdapter.width(15)),
                                          child: controller.publicShowMenuTitle(item['mainTitle'],
                                              32.0, Gcolor.mainTitleColor),
                                        ),),

                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        //副标题
                                        subtitle != ""
                                            ? Expanded(child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '${subtitle}',
                                            style: TextStyle(
                                                fontSize: ScreenAdapter.fontSize(
                                                    GFontSize
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
                            padding: EdgeInsets.only(right: ScreenAdapter.width(30)),
                            //width: ScreenAdapter.width(200),
                            alignment: Alignment.bottomRight,
                            child: controller.publicShowMenuPrice(
                                controller.selectedMenuOptionChangePrice.value[item['menuCode']]+controller.addselectedMenuOptionChangePrice.value[item['menuCode']],
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
                                var cartItemNum = await controller.ordersqlcontroller.getCartItemNum(item['menuCode']);print(cartItemNum);
                                if(cartItemNum>=item['qtyBounds']){
                                  var showString = GString.getToString(controller.checkLanguage.value,"show_storage_num_error");
                                  //showToast("${showString}");
                                  Get.dialog(
                                      DialogUtils.alertOneButton(showString,
                                          title: GString.getToString(controller.checkLanguage.value, "tag_title"),
                                          confirmtitle: GString.getToString(controller.checkLanguage.value,"tag_button_yes"),
                                          confirm: () {
                                            Get.back();
                                          })
                                  );
                                  return;
                                }
                              }

                              //判断选择后option是否与optiongroup相等
                              var currentPrice = item['currentPrice'];
                              var optionCodeList = "";
                              var optionTitle = "";
                              if (item['optionGroupVoList']?.length > 0) {//item['optionGroupVoList'].length
                                /*if (_selectedMenuOptionList[item['menuCode']].length < _selectedMenuOptionCheckedNum[item['menuCode']]) {
                              showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                              return;
                            }

                            for (var optionItem
                                in _selectedMenuOptionList[item['menuCode']]) {
                              //if (optionItem['currentPrice'] != 0) {
                                currentPrice += optionItem['currentPrice'];
                              //}
                              optionCodeList += (optionCodeList != "")
                                  ? "," + optionItem['optionCode']
                                  : optionItem['optionCode'];
                              optionTitle += (optionTitle != "")
                                  ? "," + optionItem['groupTitle']+":"+optionItem['mainTitle']
                                  : optionItem['groupTitle']+":"+optionItem['mainTitle'];
                            }*/

                                //--------------检测option单选还是多选是否满足
                                var attr = controller.menuOption.value[item['menuCode']];
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
                                      var showTag = GString.getToString(controller.checkLanguage.value, "menu_option_less_smallest");
                                      //showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                      Get.dialog(
                                          DialogUtils.alertOneButton("${showTag.replaceAll("%%", attr[i]["groupName"])}",
                                              title: GString.getToString(controller.checkLanguage.value, "tag_title"),
                                              confirmtitle: GString.getToString(controller.checkLanguage.value,"tag_button_yes"),
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
                                for (var optionItem in controller.selectedMenuOptionList.value[item['menuCode']]) {
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
                                "unitPrice":currentPrice
                              };
                              controller.publicAddCartMenu(cartItem, false).then((val) {
                                //更改显示购物车价格
                                //getCartPriceTotal();
                                if(val != false){
                                  controller.publicShowAddCartNew(context);
                                }
                                controller.changeInitialAllOption(item['menuCode']);

                              });
                            },
                            child: Container(
                              margin:
                              EdgeInsets.only(top: ScreenAdapter.height(15)),
                              width: ScreenAdapter.width(250),
                              height: ScreenAdapter.height(67),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (item['qtyBounds'] != 0) ? ColorsUtil.hexToColor("#078E42"): ColorsUtil.hexToColor("#C1C1C1"),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),

                              ),
                              child: Text(
                                  GString.getToString(
                                      controller.checkLanguage.value, "add_option_cart"),
                                  style: TextStyle(
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
            controller.publicShowMenuSellOut(item['qtyBounds']),
          ],
        ),
      ),
    );
  }

  _getThreeOptionWidget(menuCode, setFirstState,qtyBounds) {
    var optionGroupVoList = controller.menuOption.value[menuCode];
    List<Widget> options = []; //先建一个数组用于存放循环生成的widget
    if (optionGroupVoList != null &&
        optionGroupVoList.length > 0 &&
        optionGroupVoList != "") {
      for (var i = 0; i < optionGroupVoList.length; i++) {
        if(i >= controller.optionGroupMaxNum.value) break;
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
                      fontSize: ScreenAdapter.fontSize(24.0),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                    children: [
                      TextSpan(
                        text: (optionGroupVoList[i]['remark'] !=null && optionGroupVoList[i]['remark']!="")?" ${optionGroupVoList[i]['remark']}":"",
                        style: TextStyle(
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
          if(j >= controller.optionMaxNum.value) break;
          var optionVolistSon = optionVoList[j];
          var buttonColor =[];
          if (optionVolistSon['buttonColorValue'] != null && optionVolistSon['buttonColorValue'] != "") {
            buttonColor = optionVolistSon['buttonColorValue'].split(',');
          }
          optionSons.add(Container(
            width: ScreenAdapter.width(150),
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
                if(qtyBounds !=0){
                  controller.changeOptionv1(menuCode, optionGroupVoList[i]["groupCode"],optionVolistSon["optionCode"], setFirstState);
                }
              },
              child: badges.Badge(
                showBadge: (optionVolistSon['currentPrice'] != 0) ? true : false,
                badgeContent: Text(
                    (optionVolistSon['currentPrice'] > 0) ?"+${optionVolistSon['currentPrice'].toString()}円":"${optionVolistSon['currentPrice'].toString()}円",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(16),
                      color: ColorsUtil.hexToColor(
                          Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position:badges.BadgePosition.topEnd(top: -18, end: -9),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding: EdgeInsets.only(left: 5,top: 3,right: 5,bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),

                ),
                child: Container(
                  //width: ScreenAdapter.width(135),
                    height: ScreenAdapter.height(50),
                    alignment: Alignment.center,
                    decoration: (optionVolistSon['checked'] == true)
                        ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                        : (buttonColor.length>0) ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                    ): BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                            ? CachedNetworkImage(imageUrl:optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(15),
                            height: ScreenAdapter.height(25),
                            color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(2),
                        ),

                        Container(
                          //width: ScreenAdapter.width(130),
                          height: ScreenAdapter.height(50),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(120),
                              minHeight: ScreenAdapter.height(24),
                              maxHeight: ScreenAdapter.height(48),
                            ),
                            child: AutoSizeText(
                              optionVolistSon['mainTitle'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(28.0),
                                color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
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
  publicShowThreeMenuOptionGroupWidget(menuCode, menuindex,qtyBounds) {
    return Container(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getThreeOptionWidget(menuCode, menuindex,qtyBounds),
      ),
    );
  }

  //第四个酒水分类
  _showCategoryFour(showItemList,context,{popupType:"old"}) {
    if (showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategoryFourItemList(showItemList,context,popupType: popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryFourItemList(items,context,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(
        top: ScreenAdapter.height(8),
        //left: ScreenAdapter.width(15),
        //right: ScreenAdapter.width(15)
      ),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(7),
            crossAxisCount: 4,
            childAspectRatio: 0.49),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryFourItemOne(items[index],context,popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryFourItemOne(item,context,{popupType:"old"}) {
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
              controller.checkQtyBoundsCount(item, "",popupType,context);

            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                controller.publicShowOneItemWidget(item);
              }else{
                controller.publicAddCart(context,item);
              }
            }


          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                  //color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                    color: ColorsUtil.hexToColor("#f0f0f0"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 260.0, imgHeight: 390.0, subTitle: item['subtitle'],),
                        Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),
                        SizedBox(
                          height: ScreenAdapter.height(1),
                        ),
                        Container(
                          //width: ScreenAdapter.width(1080),
                          height: ScreenAdapter.height(65),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //菜单Title
                              Expanded(child: controller.publicShowMenuTitle(
                                  item['mainTitle'],
                                  GFontSize.menuFourListTitle,
                                  Gcolor.mainTitleColor)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: ScreenAdapter.height(3),
                        ),
                        /*Container(
                          padding: EdgeInsets.only(left: ScreenAdapter.width(10)),
                          child: publicShowMenuSubtitle(item['subtitle']),
                        ),*/
                        Container(
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(15),
                              //top: ScreenAdapter.height(8),
                              right: ScreenAdapter.width(10)),
                          child: controller.publicShowMenuPrice(
                              item['currentPrice'],
                              item['price'],
                              GFontSize.menuFourpriceLift,
                              Gcolor.mainTitleColor,
                              GFontSize.menuFourprice,
                              Gcolor.priceColor,
                              GFontSize.menuFourpriceRight,
                              Gcolor.mainTitleColor),
                        ),

                      ],
                    )),
                //绝对定位 盖章
                controller.publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第五个分类 期间限定
  _showCategoryFive(showItemList) {
    if (showItemList.length > 0) {
      return Container(
        padding: EdgeInsets.only(
            top: ScreenAdapter.height(8),
            //right: ScreenAdapter.width(8),
            bottom: ScreenAdapter.height(8)),
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
        addAutomaticKeepAlives:true,
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
    if (item["subtitle"]!= null && item["subtitle"].length > 0) {
      for (var i = 0; i < item["subtitle"].length; i++) {
        subtitle += item["subtitle"][i];
      }
    }

    return Container(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8)),
      child: Material(
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: ScreenAdapter.height(10), bottom: ScreenAdapter.height(10)),
              margin: EdgeInsets.only(
                  left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
              //color: ColorsUtil.hexToColor(Gcolor.whiteColor),
              color: ColorsUtil.hexToColor("#f0f0f0"),
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
                            publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 350.0, imgHeight: 350.0),
                            (item['optionGroupVoList']?.length > 0)
                                ? Expanded(child: publicShowFiveMenuOptionGroupWidget(
                                item['menuCode'], menuFiveindex,item['qtyBounds']))
                                : Container(
                              height: 0,
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),

                      //标题价格
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                              child: Container(
                                padding: EdgeInsets.only(left: ScreenAdapter.width(10)),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        //菜单Title
                                        Expanded(child: Container(
                                          padding: EdgeInsets.only(
                                              right: ScreenAdapter.width(15)),
                                          child: controller.publicShowMenuTitle(item['mainTitle'],
                                              32.0, Gcolor.mainTitleColor),
                                        ),),

                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        //副标题
                                        subtitle != ""
                                            ? Expanded(child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '${subtitle}',
                                            style: TextStyle(
                                                fontSize: ScreenAdapter.fontSize(
                                                    GFontSize
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
                            padding: EdgeInsets.only(right: ScreenAdapter.width(30)),
                            //width: ScreenAdapter.width(200),
                            alignment: Alignment.bottomRight,
                            //alignment: Alignment.centerRight,
                            child: controller.publicShowMenuPrice(
                                controller.selectedMenuOptionChangePrice.value[item['menuCode']]+controller.addselectedMenuOptionChangePrice.value[item['menuCode']],
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
                                var cartItemNum = await controller.ordersqlcontroller.getCartItemNum(item['menuCode']);print(cartItemNum);
                                if(cartItemNum>=item['qtyBounds']){
                                  var showString = GString.getToString(controller.checkLanguage.value,"show_storage_num_error");
                                  //showToast("${showString}");
                                  Get.dialog(
                                      DialogUtils.alertOneButton(showString,
                                          title: GString.getToString(controller.checkLanguage.value, "tag_title"),
                                          confirmtitle: GString.getToString(controller.checkLanguage.value,"tag_button_yes"),
                                          confirm: () {
                                            Get.back();
                                          })
                                  );
                                  return;
                                }
                              }
                              //判断选择后option是否与optiongroup相等
                              var optionCodeList = "";
                              var optionTitle = "";
                              var currentPrice = item['currentPrice'];
                              if (item['optionGroupVoList']?.length > 0) {//item['optionGroupVoList'].length
                                /*if (_selectedMenuOptionList[item['menuCode']].length < _selectedMenuOptionCheckedNum[item['menuCode']]) {
                              showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                              return;
                            }

                            for (var optionItem in _selectedMenuOptionList[item['menuCode']]) {
                              //if (optionItem['currentPrice'] > 0) {
                                currentPrice += optionItem['currentPrice'];
                              //}
                              optionCodeList += (optionCodeList != "") ? "," + optionItem['optionCode'] : optionItem['optionCode'];
                              optionTitle += (optionTitle != "") ? "," + optionItem['groupTitle']+":"+optionItem['mainTitle'] : optionItem['groupTitle']+":"+optionItem['mainTitle'];
                            }*/

                                //--------------检测option单选还是多选是否满足
                                var attr = controller.menuOption.value[item['menuCode']];
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
                                      var showTag = GString.getToString(controller.checkLanguage.value, "menu_option_less_smallest");
                                      //showToast("${showTag.replaceAll("%%", attr[i]["groupName"])}");
                                      Get.dialog(
                                          DialogUtils.alertOneButton("${showTag.replaceAll("%%", attr[i]["groupName"])}",
                                              title: GString.getToString(controller.checkLanguage.value, "tag_title"),
                                              confirmtitle: GString.getToString(controller.checkLanguage.value,"tag_button_yes"),
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
                                for (var optionItem in controller.selectedMenuOptionList.value[item['menuCode']]) {
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
                                "unitPrice":currentPrice
                              };
                              controller.publicAddCartMenu(cartItem, false).then((val) {
                                //更改显示购物车价格
                                //getCartPriceTotal();
                                if(val != false){
                                  controller.publicShowAddCartNew(context);
                                }

                                if (item['optionGroupVoList']?.length > 0) {
                                  controller.changeInitialAllOption(item['menuCode']);
                                }
                                //更改显示购物车价格
                                //getCartPriceTotal();
                              });
                            },
                            child: Container(
                              margin:
                              EdgeInsets.only(top: ScreenAdapter.height(15)),
                              width: ScreenAdapter.width(250),
                              height: ScreenAdapter.height(67),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: (item['qtyBounds'] != 0) ? ColorsUtil.hexToColor("#078E42"): ColorsUtil.hexToColor("#C1C1C1"),
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),

                              ),
                              child: Text(
                                  GString.getToString(
                                      controller.checkLanguage.value, "add_option_cart"),
                                  style: TextStyle(
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
            controller.publicShowMenuSellOut(item['qtyBounds']),
          ],
        ),
      ),
    );
  }

  _getFiveOptionWidget(menuCode, setFirstState,qtyBounds) {
    var optionGroupVoList = controller.menuOption.value[menuCode];
    List<Widget> options = []; //先建一个数组用于存放循环生成的widget
    if (optionGroupVoList != null &&
        optionGroupVoList.length > 0 &&
        optionGroupVoList != "") {
      for (var i = 0; i < optionGroupVoList.length; i++) {
        if(i >= controller.optionGroupMaxNum.value) break;
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
                      fontSize: ScreenAdapter.fontSize(24.0),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                    children: [
                      TextSpan(
                        text: (optionGroupVoList[i]['remark'] !=null && optionGroupVoList[i]['remark']!="")?" ${optionGroupVoList[i]['remark']}":"",
                        style: TextStyle(
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
          if(j >= controller.optionMaxNum.value) break;
          var optionVolistSon = optionVoList[j];


          var buttonColor = [];
          if (optionVolistSon['buttonColorValue'] != null && optionVolistSon['buttonColorValue'] != "") {
            buttonColor = optionVolistSon['buttonColorValue'].split(',');
          }
          optionSons.add(Container(
            width: ScreenAdapter.width(200),
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(7),
                top: ScreenAdapter.height(5),
                right: ScreenAdapter.width(7),
                bottom: ScreenAdapter.height(5)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                if(qtyBounds != 0){
                  controller.changeOptionv1(menuCode, optionGroupVoList[i]["groupCode"],optionVolistSon["optionCode"], setFirstState);
                }

              },
              child: badges.Badge(
                showBadge: (optionVolistSon['currentPrice'] != 0) ? true : false,
                badgeContent: Text(
                    (optionVolistSon['currentPrice'] > 0) ?"+${optionVolistSon['currentPrice'].toString()}円":"${optionVolistSon['currentPrice'].toString()}円",
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(16),
                      color: ColorsUtil.hexToColor(
                          Gcolor.optionBtnColor),
                    )),
                //padding: EdgeInsets.all(5),
                position:badges.BadgePosition.topEnd(top: -18, end: -9),
                badgeStyle: badges.BadgeStyle(
                  shape: badges.BadgeShape.square,
                  padding: EdgeInsets.only(left: 5,top: 3,right: 5,bottom: 3),
                  borderRadius: BorderRadius.circular(5),
                  badgeColor: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),

                ),
                child: Container(
                  //width: ScreenAdapter.width(160),
                    height: ScreenAdapter.height(55),
                    alignment: Alignment.center,
                    decoration: (optionVolistSon['checked'] == true)
                        ? BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                        : (buttonColor.length>0)?BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                    ):BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
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
                            ? CachedNetworkImage(imageUrl:optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(15),
                            height: ScreenAdapter.height(25),
                            color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        SizedBox(
                          width: ScreenAdapter.width(6),
                        ),

                        Container(
                          //width: ScreenAdapter.width(190),
                          height: ScreenAdapter.height(60),
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: ScreenAdapter.width(20),
                              maxWidth: ScreenAdapter.width(140),
                              minHeight: ScreenAdapter.height(26),
                              maxHeight: ScreenAdapter.height(55),
                            ),
                            child: AutoSizeText(
                              optionVolistSon['mainTitle'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: ScreenAdapter.fontSize(28.0),
                                color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
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
  publicShowFiveMenuOptionGroupWidget(menuCode, menuindex,qtyBounds) {
    return Container(
      padding: EdgeInsets.only(
          //left: ScreenAdapter.width(8),
          //right: ScreenAdapter.width(3),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: _getFiveOptionWidget(menuCode, menuindex,qtyBounds),
      ),
    );
  }

  //第六个分类 每页两列一行
  _showCategorySix(showItemList,context,{popupType:"old"}) {
    if (showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategorySixItemList(showItemList,popupType:popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategorySixItemList(items,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 2,
            childAspectRatio: 0.76),
        itemBuilder: (BuildContext context, int index) {
          return showCategorySixItemOne(items[index],context,popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategorySixItemOne(item,context,{popupType:"old"}) {
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
              controller.checkQtyBoundsCount(item, "",popupType,context);
            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                //_publicShowOneItemWidget(item);
                if(popupType == "v1"){
                  controller.publicShowOneItemWidgetv1(item);
                }else{
                  controller.publicShowOneItemWidget(item);
                }
              }else{
                controller.publicAddCart(context,item);
              }
            }
          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                  //color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                    color: ColorsUtil.hexToColor("#f0f0f0"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 540.0, imgHeight: 540.0, subTitle: item['subtitle'],),

                        Container(
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(68),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: controller.publicShowMenuTitle(
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
                          child: controller.publicShowMenuPrice(
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
                controller.publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第七个分类 每页三列一行  饮品
  _showCategorySeven(showItemList,{popupType:"old"}) {
    if (showItemList.length > 0) {
      return Container(
        //height: 450,
        child: showCategorySevenItemList(showItemList,popupType:popupType),
      );
    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategorySevenItemList(items,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 3,
            childAspectRatio: 0.595),
        itemBuilder: (BuildContext context, int index) {
          return showCategorySevenItemOne(items[index],context,popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategorySevenItemOne(item,context,{popupType:"old"}) {
    Offset temp;
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5), right: ScreenAdapter.width(5)),
      child: InkWell(
          enableFeedback: false,
          /*onPanDown: (details) {
            temp = new Offset(details.globalPosition.dx, details.globalPosition.dy);

          },*/
          onTap: () async {

            if (item['qtyBounds'] == 0) {
              return;
            } else if (item['qtyBounds'] > 0) {
              //请求限定接口
              controller.checkQtyBoundsCount(item, "",popupType,context);
            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                //controller.publicShowOneItemWidget(item);
                if(popupType == "v1"){
                  controller.publicShowOneItemWidgetv1(item);
                }else{
                  controller.publicShowOneItemWidget(item);
                }
              }else{
                controller.publicAddCart(context,item);
              }
            }

          },
          child: Material(
            child: Stack(
              children: [
                Container(
                  //height: ScreenAdapter.height(280),
                  //color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                    color: ColorsUtil.hexToColor("#f0f0f0"),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 350.0, imgHeight: 440.0,subTitle: item['subtitle'],),

                        Container(
                          margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(68),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: controller.publicShowMenuTitle(
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
                          child: controller.publicShowMenuPrice(
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
                controller.publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第八个分类 混合排列，第一行一大两小，其余三个一行每页三列一行
  _showCategoryEight(showItemList,context,{popupType:"old"}) {
    if (showItemList.length > 0) {
      if(showItemList.length >=3){
        var _leftItem = showItemList[0];
        var _rightTop = showItemList[1];
        var _rightBottom = showItemList[2];
        var _newItemList = showItemList.sublist(3);

        return Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: new AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: ScreenAdapter.height(830),
                          color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                          padding: EdgeInsets.only(left: ScreenAdapter.width(5)),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(10), right: ScreenAdapter.width(4)),
                          child: InkWell(
                              enableFeedback: false,
                              onTap: () async {
                                if (_leftItem['qtyBounds'] == 0) {
                                  return;
                                } else if (_leftItem['qtyBounds'] > 0) {
                                  //请求限定接口
                                  controller.checkQtyBoundsCount(_leftItem, "",popupType,context);
                                }else{
                                  //如果option 存在，则弹出option
                                  if(_leftItem['optionGroupVoList']?.length > 0){
                                    if(popupType == "v1"){
                                      controller.publicShowOneItemWidgetv1(_leftItem);
                                    }else{
                                      controller.publicShowOneItemWidget(_leftItem);
                                    }
                                  }else{

                                    controller.publicAddCart(context,_leftItem);
                                  }
                                }

                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  publicShowMenuImage(imgPath:_leftItem['homeImage'], imgWidth: 580.0, imgHeight: 710.0, subTitle: _leftItem['subtitle'],),
                                  Container(
                                    width: ScreenAdapter.width(580),
                                    height: ScreenAdapter.height(68),
                                    margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        right: ScreenAdapter.width(10)),
                                    child: controller.publicShowMenuTitle(
                                        _leftItem['mainTitle'],
                                        GFontSize.menuTwoListTitle,
                                        Gcolor.mainTitleColor),
                                  ),

                                  Container(
                                    width: ScreenAdapter.width(580),
                                    child: Container(
                                      //width: ScreenAdapter.width(125),
                                      //height: ScreenAdapter.height(315),
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(15),
                                          right: ScreenAdapter.width(10)),
                                      child: controller.publicShowMenuPrice(
                                          _leftItem['currentPrice'],
                                          _leftItem['price'],
                                          GFontSize.menuTwopriceLift,
                                          Gcolor.mainTitleColor,
                                          GFontSize.menuTwoprice,
                                          Gcolor.priceColor,
                                          GFontSize.menuTwopriceRight,
                                          Gcolor.mainTitleColor),
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                        //绝对定位 盖章
                        controller.publicShowMenuSellOut(_leftItem['qtyBounds']),
                      ],
                    ),
                    Expanded(child: Column(
                      children: [
                        Container(
                          height: ScreenAdapter.height(410),
                          color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                          margin: EdgeInsets.only(
                              left: ScreenAdapter.width(5),top: ScreenAdapter.height(10), right: ScreenAdapter.width(5)),
                          child: InkWell(
                              enableFeedback: false,
                              onTap: () async {
                                if (_rightTop['qtyBounds'] == 0) {
                                  return;
                                } else if (_rightTop['qtyBounds'] > 0) {
                                  //请求限定接口
                                  controller.checkQtyBoundsCount(_rightTop, "",popupType,context);

                                }else{
                                  if(_rightTop['optionGroupVoList']?.length > 0){
                                    if(popupType == "v1"){
                                      controller.publicShowOneItemWidgetv1(_rightTop);
                                    }else{
                                      controller.publicShowOneItemWidget(_rightTop);
                                    }
                                  }else{
                                    controller.publicAddCart(context,_rightTop);
                                  }
                                }


                              },
                              child: Stack(
                                children: [
                                  Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          publicShowMenuImage(imgPath:_rightTop['homeImage'], imgWidth: 400.0, imgHeight: 290.0, subTitle: _rightTop["subtitle"],),

                                          Container(
                                            width: ScreenAdapter.width(400),
                                            height: ScreenAdapter.height(68),
                                            padding: EdgeInsets.only(
                                                left: ScreenAdapter.width(10),
                                                right: ScreenAdapter.width(10)),
                                            child: controller.publicShowMenuTitle(
                                                _rightTop['mainTitle'],
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
                                            child: controller.publicShowMenuPrice(
                                                _rightTop['currentPrice'],
                                                _rightTop['price'],
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
                                  controller.publicShowMenuSellOut(_rightTop['qtyBounds']),
                                ],
                              )),
                        ),
                        Container(
                          height: ScreenAdapter.height(410),
                          color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                          margin: EdgeInsets.only(
                              left: ScreenAdapter.width(5), top: ScreenAdapter.height(10), right: ScreenAdapter.width(5)),
                          child: InkWell(
                              enableFeedback: false,
                              onTap: () async {

                                if (_rightBottom['qtyBounds'] == 0) {
                                  return;
                                } else if (_rightBottom['qtyBounds'] > 0) {
                                  //请求限定接口
                                  controller.checkQtyBoundsCount(_rightBottom, "",popupType,context);

                                }else{
                                  if(_rightBottom['optionGroupVoList']?.length > 0){
                                    if(popupType == "v1"){
                                      controller.publicShowOneItemWidgetv1(_rightBottom);
                                    }else{
                                      controller.publicShowOneItemWidget(_rightBottom);
                                    }
                                  }else{
                                    controller.publicAddCart(context,_rightBottom);
                                  }
                                }

                              },
                              child: Stack(
                                children: [
                                  Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          publicShowMenuImage(imgPath:_rightBottom['homeImage'], imgWidth: 400.0, imgHeight: 290.0, subTitle: _rightBottom["subtitle"],),
                                          Container(
                                            width: ScreenAdapter.width(400),
                                            height: ScreenAdapter.height(68),
                                            padding: EdgeInsets.only(
                                                left: ScreenAdapter.width(10),
                                                right: ScreenAdapter.width(10)),
                                            child: controller.publicShowMenuTitle(
                                                _rightBottom['mainTitle'],
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
                                            child: controller.publicShowMenuPrice(
                                                _rightBottom['currentPrice'],
                                                _rightBottom['price'],
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
                                  controller.publicShowMenuSellOut(_rightBottom['qtyBounds']),
                                ],
                              )),
                        ),
                      ],
                    ))
                  ],
                ),
                if(_newItemList.length>0)
                showCategoryEightItemList(_newItemList,popupType:popupType)
              ],
            ),
          ),
        );
      }else{
        return Container(
          child: showCategoryEightItemList(showItemList,popupType:popupType),
        );
      }

    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryEightItemList(items,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(
          top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: new NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(10),
            crossAxisCount: 3,
            childAspectRatio: 0.72),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryEightItemOne(items[index],context,popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryEightItemOne(item,context,{popupType:"old"}) {
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
              controller.checkQtyBoundsCount(item, "",popupType,context);

            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                if(popupType == "v1"){
                  controller.publicShowOneItemWidgetv1(item);
                }else{
                  controller.publicShowOneItemWidget(item);
                }
              }else{
                controller.publicAddCart(context,item);
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
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 340.0, imgHeight: 340.0, subTitle: item["subtitle"],),
                        Container(
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(68),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: controller.publicShowMenuTitle(
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
                          child: controller.publicShowMenuPrice(
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
                controller.publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }

  //第九个分类 混合排列，第一行一大两小，其余2个一行每页2列一行
  _showCategoryNine(showItemList,context,{popupType:"old"}) {
    if (showItemList.length > 0) {
      if(showItemList.length >=3){
        var _leftItem = showItemList[0];
        var _rightTop = showItemList[1];
        var _rightBottom = showItemList[2];
        var _newItemList = showItemList.sublist(3);

        return Container(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: new AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: ScreenAdapter.height(830),
                          color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                          padding: EdgeInsets.only(left: ScreenAdapter.width(6)),
                          margin: EdgeInsets.only(
                              top: ScreenAdapter.height(10), right: ScreenAdapter.width(4)),
                          child: InkWell(
                              enableFeedback: false,
                              onTap: () async {
                                if (_leftItem['qtyBounds'] == 0) {
                                  return;
                                } else if (_leftItem['qtyBounds'] > 0) {
                                  //请求限定接口
                                  controller.checkQtyBoundsCount(_leftItem, "",popupType,context);
                                }else{
                                  //如果option 存在，则弹出option
                                  if(_leftItem['optionGroupVoList']?.length > 0){
                                    //controller.publicShowOneItemWidget(_leftItem);
                                    if(popupType == "v1"){
                                      controller.publicShowOneItemWidgetv1(_leftItem);
                                    }else{
                                      controller.publicShowOneItemWidget(_leftItem);
                                    }
                                  }else{

                                    controller.publicAddCart(context,_leftItem);
                                  }
                                }

                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  publicShowMenuImage(imgPath:_leftItem['homeImage'], imgWidth: 580.0, imgHeight: 710.0, subTitle: _leftItem["subtitle"],),
                                  Container(
                                    width: ScreenAdapter.width(580),
                                    height: ScreenAdapter.height(68),
                                    margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                    padding: EdgeInsets.only(
                                        left: ScreenAdapter.width(10),
                                        right: ScreenAdapter.width(10)),
                                    child: controller.publicShowMenuTitle(
                                        _leftItem['mainTitle'],
                                        GFontSize.menuTwoListTitle,
                                        Gcolor.mainTitleColor),
                                  ),

                                  Container(
                                    width: ScreenAdapter.width(580),
                                    //margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                                    child: Container(
                                      //width: ScreenAdapter.width(125),
                                      //height: ScreenAdapter.height(315),
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(
                                          left: ScreenAdapter.width(5),
                                          right: ScreenAdapter.width(0)),
                                      child: controller.publicShowMenuPrice(
                                          _leftItem['currentPrice'],
                                          _leftItem['price'],
                                          GFontSize.menuTwopriceLift,
                                          Gcolor.mainTitleColor,
                                          GFontSize.menuTwoprice,
                                          Gcolor.priceColor,
                                          GFontSize.menuTwopriceRight,
                                          Gcolor.mainTitleColor),
                                    ),
                                  ),
                                ],
                              )
                          ),
                        ),
                        //绝对定位 盖章
                        controller.publicShowMenuSellOut(_leftItem['qtyBounds']),
                      ],
                    ),
                    Expanded(child: Column(
                      children: [
                        Container(
                          height: ScreenAdapter.height(410),
                          color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                          margin: EdgeInsets.only(
                              left: ScreenAdapter.width(5),top: ScreenAdapter.height(10), right: ScreenAdapter.width(5)),
                          child: InkWell(
                              enableFeedback: false,
                              onTap: () async {
                                if (_rightTop['qtyBounds'] == 0) {
                                  return;
                                } else if (_rightTop['qtyBounds'] > 0) {
                                  //请求限定接口
                                  controller.checkQtyBoundsCount(_rightTop, "",popupType,context);

                                }else{
                                  if(_rightTop['optionGroupVoList']?.length > 0){
                                    //controller.publicShowOneItemWidget(_rightTop);
                                    if(popupType == "v1"){
                                      controller.publicShowOneItemWidgetv1(_rightTop);
                                    }else{
                                      controller.publicShowOneItemWidget(_rightTop);
                                    }
                                  }else{
                                    controller.publicAddCart(context,_rightTop);
                                  }
                                }


                              },
                              child: Stack(
                                children: [
                                  Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          publicShowMenuImage(imgPath:_rightTop['homeImage'], imgWidth: 400.0, imgHeight: 290.0,subTitle:_rightTop["subtitle"]),

                                          Container(
                                            width: ScreenAdapter.width(400),
                                            height: ScreenAdapter.height(68),
                                            padding: EdgeInsets.only(
                                                left: ScreenAdapter.width(10),
                                                right: ScreenAdapter.width(10)),
                                            child: controller.publicShowMenuTitle(
                                                _rightTop['mainTitle'],
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
                                            child: controller.publicShowMenuPrice(
                                                _rightTop['currentPrice'],
                                                _rightTop['price'],
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
                                  controller.publicShowMenuSellOut(_rightTop['qtyBounds']),
                                ],
                              )),
                        ),
                        Container(
                          height: ScreenAdapter.height(410),
                          color: ColorsUtil.hexToColor(Gcolor.whiteColor),
                          margin: EdgeInsets.only(
                              left: ScreenAdapter.width(5), top: ScreenAdapter.height(10), right: ScreenAdapter.width(5)),
                          child: InkWell(
                              enableFeedback: false,
                              onTap: () async {

                                if (_rightBottom['qtyBounds'] == 0) {
                                  return;
                                } else if (_rightBottom['qtyBounds'] > 0) {
                                  //请求限定接口
                                  controller.checkQtyBoundsCount(_rightBottom, "",popupType,context);

                                }else{
                                  if(_rightBottom['optionGroupVoList']?.length > 0){
                                    //controller.publicShowOneItemWidget(_rightBottom);
                                    if(popupType == "v1"){
                                      controller.publicShowOneItemWidgetv1(_rightBottom);
                                    }else{
                                      controller.publicShowOneItemWidget(_rightBottom);
                                    }
                                  }else{
                                    controller.publicAddCart(context,_rightBottom);
                                  }
                                }

                              },
                              child: Stack(
                                children: [
                                  Container(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          publicShowMenuImage(imgPath:_rightBottom['homeImage'], imgWidth: 400.0, imgHeight: 290.0,subTitle: _rightBottom["subtitle"],),
                                          Container(
                                            width: ScreenAdapter.width(400),
                                            height: ScreenAdapter.height(68),
                                            padding: EdgeInsets.only(
                                                left: ScreenAdapter.width(10),
                                                right: ScreenAdapter.width(10)),
                                            child: controller.publicShowMenuTitle(
                                                _rightBottom['mainTitle'],
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
                                            child: controller.publicShowMenuPrice(
                                                _rightBottom['currentPrice'],
                                                _rightBottom['price'],
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
                                  controller.publicShowMenuSellOut(_rightBottom['qtyBounds']),
                                ],
                              )),
                        ),
                      ],
                    ))
                  ],
                ),
                if(_newItemList.length>0)
                showCategoryNineItemList(_newItemList,popupType:popupType)
              ],
            ),
          ),
        );
      }else{
        return Container(
          child: showCategoryNineItemList(showItemList,popupType:popupType),
        );
      }

    } else {
      return Container(
        height: 0,
      );
    }
  }

  showCategoryNineItemList(items,{popupType:"old"}) {
    return Padding(
      padding: EdgeInsets.only(top: ScreenAdapter.height(8), bottom: ScreenAdapter.height(8)),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: new NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        addAutomaticKeepAlives:true,
        //addRepaintBoundaries:false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: ScreenAdapter.height(5),
            crossAxisCount: 2,
            childAspectRatio: 0.75),
        itemBuilder: (BuildContext context, int index) {
          return showCategoryNineItemOne(items[index],context,popupType:popupType);
        },
        itemCount: items.length,
      ),
    );
  }

  showCategoryNineItemOne(item,context,{popupType:"old"}) {
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
              controller.checkQtyBoundsCount(item, "",popupType,context);

            }else{
              //如果option 存在，则弹出option
              if(item['optionGroupVoList']?.length > 0){
                //controller.publicShowOneItemWidget(item);
                if(popupType == "v1"){
                  controller.publicShowOneItemWidgetv1(item);
                }else{
                  controller.publicShowOneItemWidget(item);
                }
              }else{
                controller.publicAddCart(context,item);
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
                        publicShowMenuImage(imgPath:item['homeImage'], imgWidth: 540.0, imgHeight: 538.0,subTitle: item["subtitle"],),
                        Divider(height: 1.5,indent: 0.0,color: ColorsUtil.hexToColor("#DDDDDD"),),

                        Container(
                          //width: ScreenAdapter.width(20),
                          height: ScreenAdapter.height(68),
                          margin: EdgeInsets.only(top: ScreenAdapter.height(3)),
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(10),
                              right: ScreenAdapter.width(10)),
                          child: controller.publicShowMenuTitle(
                              item['mainTitle'],
                              GFontSize.menuTwoListTitle,
                              Gcolor.mainTitleColor),
                        ),
                        Container(
                          //width: ScreenAdapter.width(125),
                          //height: ScreenAdapter.height(315),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(
                              left: ScreenAdapter.width(5),
                              right: ScreenAdapter.width(0)),
                          child: controller.publicShowMenuPrice(
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
                controller.publicShowMenuSellOut(item['qtyBounds']),
              ],
            ),
          )),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MenuPageController>(builder: (controller){
        return controller.obx((state) => AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: ScreenAdapter.height(1585),
                //color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                color: ColorsUtil.hexToColor("#FFFFFF"),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                        height: ScreenAdapter.height(1585),
                        width: ScreenAdapter.width(80),
                        padding: EdgeInsets.only(top: ScreenAdapter.height(8),left: ScreenAdapter.width(2)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              child: InkWell(
                                enableFeedback: false,
                                onTap: () {
                                  controller.gotoLanguageHome();
                                  //controller.ordersqlcontroller.removeAllFromCart();

                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: ScreenAdapter.height(5)),
                                  width: ScreenAdapter.width(75),
                                  height: ScreenAdapter.height(125),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: ColorsUtil.hexToColor("#A61C1C"),

                                  ),
                                  child: Center(
                                    //加上Center让文字居中
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        Container(
                                          width: ScreenAdapter.width(30),
                                          child: RotatedBox(quarterTurns: 1,child: Text(
                                            GString.getToString(controller.checkLanguage.value, "top_back_button"),
                                            style: TextStyle(
                                                fontSize: ScreenAdapter.fontSize(26),
                                                color: ColorsUtil.hexToColor(Gcolor.categoryTitleSelected),
                                                fontWeight: FontWeight.w600),
                                          )),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                                child: showLeftCategoryMenu()
                            ),
                          ],
                        )
                    ),
                    Expanded(child: RepaintBoundary(
                      child: Container(
                        height: ScreenAdapter.height(1585),
                        width: ScreenAdapter.width(1000),
                        color: ColorsUtil.hexToColor(Gcolor.mainBackground),
                        padding: EdgeInsets.only(left: ScreenAdapter.width(5),right: ScreenAdapter.width(5)),
                        alignment: Alignment.center,
                        child: showMiddleMenuList(context),
                      ),
                    )),
                  ],
                ),
              ),

              Container(
                  height: ScreenAdapter.height(330),
                  child: publicShowCartView()
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
