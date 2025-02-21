import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../config/color.dart';
import '../../../config/colorsUtil.dart';
import '../../../config/fontSize.dart';
import '../../../config/font.dart';
import '../../../config/string.dart';
import '../../../services/formatMoney.dart';
import '../../../services/screenAdapter.dart';
import '../../../services/showToast.dart';
import '../../../widget/DialogUtils.dart';
import '../controllers/menu_page_controller.dart';

class showOneItemOptionWidgetVOneView extends GetView {
  @override
  final MenuPageController controller = Get.find();
  final Map item;
  showOneItemOptionWidgetVOneView(this.item,{Key? key}) : super(key: key);

  publicShowOneItemOptionGroupWidgetv1(menuCode, menuindex) {
    return Container(
      padding: EdgeInsets.only(
          left: ScreenAdapter.width(5),
          right: ScreenAdapter.width(3),
          top: ScreenAdapter.height(5),
          bottom: ScreenAdapter.height(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: _getOneItemOptionWidgetv1(menuCode, menuindex),
      ),
    );
  }
  _getOneItemOptionWidgetv1(menuCode, setFirstState) {
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
          padding: EdgeInsets.only(left:ScreenAdapter.width(5),top: ScreenAdapter.height(5), bottom: ScreenAdapter.height(2)),
          child: Row(
            children: [
              RichText(
                text: TextSpan(
                    text: "${optionGroupVoList[i]['groupName']}",
                    //GString.getToString(this._checkLanguage, "show_price_front"),
                    style: TextStyle(
                      fontSize: ScreenAdapter.fontSize(24.0),
                      fontFamily: GFont.getFontFamily(),
                      fontWeight: FontWeight.w500,
                      color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                    ),
                    children: [
                      TextSpan(
                        text: (optionGroupVoList[i]['remark'] !=null && optionGroupVoList[i]['remark']!="")?" ${optionGroupVoList[i]['remark']}":"",
                        style: TextStyle(
                          fontSize: ScreenAdapter.fontSize(18.0),
                          fontFamily: GFont.getFontFamily(),
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
            width: ScreenAdapter.width(196),
            padding: EdgeInsets.only(
                left: ScreenAdapter.width(5),
                top: ScreenAdapter.height(5),
                right: ScreenAdapter.width(5),
                bottom: ScreenAdapter.height(5)),
            child: InkWell(
              //enableFeedback: false,
              onTap: () {
                controller.changeOptionv1(menuCode, optionGroupVoList[i]["groupCode"],
                    optionVolistSon["optionCode"], setFirstState);
              },
              child: Stack(
                children: [
                  Container(
                    height: ScreenAdapter.height(180),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      //color: ColorsUtil.hexToColor("#FFFFFF"),
                      border: Border.all(
                        color: ColorsUtil.hexToColor("#c9c9c9"),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: ColorsUtil.hexToColor("#F9F9F9"),
                            offset: Offset(2, 3),
                            blurRadius: 3.0,
                            spreadRadius: 0),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (optionVolistSon['homeImage'] != "" &&
                            optionVolistSon['homeImage'] != null)
                            ? CachedNetworkImage(imageUrl:optionVolistSon['homeImage'],
                            width: ScreenAdapter.width(160),
                            height: ScreenAdapter.height(110),
                            //color: (optionVolistSon['checked'] == true) ?ColorsUtil.hexToColor(Gcolor.optionBtnColor) :ColorsUtil.hexToColor("#914F14"),
                            fit: BoxFit.fitHeight)
                            : Container(
                          width: 0,
                        ),
                        Container(
                            width: ScreenAdapter.width(185),
                            height: ScreenAdapter.height(60),
                            alignment: Alignment.center,

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minWidth: ScreenAdapter.width(20),
                                    maxWidth: ScreenAdapter.width(175),
                                    minHeight: ScreenAdapter.height(30),
                                    maxHeight: ScreenAdapter.height(60),
                                  ),
                                  child: AutoSizeText(
                                      optionVolistSon['mainTitle'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontFamily: GFont.getFontFamily(),
                                        fontSize: ScreenAdapter.fontSize(24.0),
                                        color: ColorsUtil.hexToColor("#914F14"),
                                      ),
                                      softWrap: true,
                                      //minFontSize: 10,
                                      //maxFontSize: 12,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                  ),
                  (optionVolistSon['currentPrice'] != 0)
                      ? Positioned(
                    right: ScreenAdapter.width(0),
                    top: ScreenAdapter.height(0),
                    child: Container(
                      //width: ScreenAdapter.width(46),
                        height: ScreenAdapter.height(32),
                        alignment: Alignment.center,
                        //padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                        padding: EdgeInsets.only(
                          //top:ScreenAdapter.height(2),
                            left: ScreenAdapter.width(10),
                            right: ScreenAdapter.width(10)
                        ),
                        // alignment: Alignment.topRight,
                        decoration: BoxDecoration(
                          color: (optionVolistSon['currentPrice'] > 0) ? ColorsUtil.hexToColor("#ef4136"): ColorsUtil.hexToColor("#1d953f"),
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        ),
                        child: Text(
                            (optionVolistSon['currentPrice'] > 0) ?"¥${formatSum(optionVolistSon['currentPrice']).toString()}":"-¥${formatSum(-optionVolistSon['currentPrice']).toString()}",
                            style: TextStyle(
                              fontSize: ScreenAdapter.fontSize(20),
                              fontFamily: GFont.getFontFamily(),
                              fontWeight: FontWeight.w600,
                              color: ColorsUtil.hexToColor(
                                  Gcolor.optionBtnColor),
                            ))),
                  )
                      : Container(
                    height: 0,
                  ),
                  (optionVolistSon['checked'] == true)
                      ? Positioned(
                    right: ScreenAdapter.width(0),
                    top: ScreenAdapter.height(30),
                    child: Container(
                        width: ScreenAdapter.width(180),
                        height: ScreenAdapter.height(150),
                        alignment: Alignment.center,

                        child: Icon(
                          Icons.check,
                          color: ColorsUtil.hexToColor("#2aa515"),
                          size: 120,
                        )/*Image.asset(
                          GImage.getImageString("imgpublic", "menu_option_check"),
                          width: ScreenAdapter.width(90),
                          fit: BoxFit.fitWidth,
                          color: Colors.green,
                        )*/
                    ),
                  )
                      : Container(
                    height: 0,
                  ),
                ],
              ),
            ),
          ));

        }

        options.add(Container(
          child: Wrap(
            spacing: ScreenAdapter.width(10), // set spacing here
            runSpacing: ScreenAdapter.height(10),
            alignment: WrapAlignment.start,
            children: optionSons,
          ),
        ));

      }
    }

    return options;
  }

  String formatSum(int sum) {
    final formatter = NumberFormat('#,###');
    return formatter.format(sum);
  }

  @override
  Widget build(BuildContext context) {
    var itemPrice = controller.selectedMenuOptionChangePrice.value[item['menuCode']];
    controller.paymentIsShow = true;
    return GetBuilder<MenuPageController>(
        id: 'option_view',
        builder: (controller) {
          return RepaintBoundary(
            child: UnconstrainedBox(
              child: Container(
                width: ScreenAdapter.width(1060),
                //height: ScreenAdapter.height(1000),
                child: Dialog(
                  insetPadding: EdgeInsets.zero,
                  child: Container(
                    // width: ScreenAdapter.width(1060),
                    width: ScreenAdapter.width(1060),
                    padding: EdgeInsets.only(top: ScreenAdapter.height(20)),
                    child: StatefulBuilder(
                      builder: (BuildContext context, menuindex) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //标题价格
                            Container(
                              padding: EdgeInsets.only(bottom: ScreenAdapter.height(15)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.only(left: ScreenAdapter.width(20)),
                                                  child: controller.publicShowMenuTitle(
                                                      item['mainTitle'],
                                                      GFontSize.cartListTitleCount,
                                                      Gcolor.mainTitleColor),
                                                )
                                            ),
                                          ],
                                        ),

                                        Container(
                                          padding: EdgeInsets.only(left: ScreenAdapter.width(10)),
                                          child: Row(
                                            children: [
                                              Expanded(child: controller.publicShowMenuSubtitle(item["subtitle"])),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  //价格展示 item['currentPrice']
                                  Container(
                                    padding: EdgeInsets.only(right: ScreenAdapter.width(20)),
                                    //width: ScreenAdapter.width(260),
                                    alignment: Alignment.bottomRight,
                                    child: controller.publicShowMenuPrice(
                                        itemPrice,
                                        item['price'],
                                        GFontSize.menuTwopriceLift,
                                        Gcolor.mainTitleColor,
                                        GFontSize.mainPrice,
                                        Gcolor.mainTitleColor,
                                        GFontSize.menuTwopriceRight,
                                        Gcolor.mainTitleColor),
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              height: 1,
                              color: Color.fromRGBO(227, 227, 227, 1),
                            ),
                            if(item['optionGroupVoList']?.length > 0)
                            Container(
                              constraints: BoxConstraints(minHeight: ScreenAdapter.height(400),maxHeight: ScreenAdapter.height(1500),),
                              padding: EdgeInsets.only(left: ScreenAdapter.width(15),top: ScreenAdapter.height(10),right: ScreenAdapter.width(15),bottom: ScreenAdapter.height(10)),
                              child: Scrollbar(
                                  child: SingleChildScrollView(
                                    physics: ClampingScrollPhysics(),
                                    child: publicShowOneItemOptionGroupWidgetv1(item['menuCode'], menuindex),
                                  )
                              ),
                            ),

                            Divider(
                              height: 1,
                              color: Color.fromRGBO(227, 227, 227, 1),
                            ),
                            //标题价格
                            Container(
                              //padding: EdgeInsets.only(right: ScreenAdapter.width(50)),
                              height: ScreenAdapter.height(200),
                              color: ColorsUtil.hexToColor("#DCDCDC"),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: (){
                                      controller.paymentIsShow = false;
                                      Get.back();
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(left: ScreenAdapter.width(20),top: ScreenAdapter.height(20)),
                                      alignment: Alignment.center,
                                      width: ScreenAdapter.width(240),
                                      height: ScreenAdapter.height(120),
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
                                            fontFamily: GFont.getFontFamily(),
                                            fontWeight: FontWeight.w500,
                                            fontSize: ScreenAdapter.fontSize(34.0)),
                                      ),
                                    ),
                                  ),
                                  //标题价格
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [

                                      //价格展示 item['currentPrice']
                                      Container(
                                        padding: EdgeInsets.only(right: ScreenAdapter.width(30),bottom: ScreenAdapter.height(30)),
                                        //width: ScreenAdapter.width(260),
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          //color: Colors.blueGrey,
                                          alignment: Alignment.bottomRight,
                                          child: RichText(
                                            text: TextSpan(
                                                text: "¥",//¥GString.getToString(this._checkLanguage, "show_price_front"),
                                                style: TextStyle(
                                                  fontSize: ScreenAdapter.fontSize(50),
                                                  fontFamily: GFont.getFontFamily(),
                                                  fontWeight: FontWeight.w600,
                                                  color: ColorsUtil.hexToColor(Gcolor.mainTitleColor),
                                                  textBaseline: TextBaseline.alphabetic,
                                                ),

                                                children: [
                                                  TextSpan(
                                                    text: formatMoney((
                                                        controller.selectedMenuOptionChangePrice.value[item['menuCode']] +
                                                        controller.addselectedMenuOptionChangePrice.value[item['menuCode']]
                                                        ).toString()),
                                                    style: TextStyle(
                                                      fontSize: ScreenAdapter.fontSize(70),
                                                      fontFamily: GFont.getFontFamily(),
                                                      fontWeight: FontWeight.w600,
                                                      color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                                      textBaseline: TextBaseline.alphabetic,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: "（${GString.getToString(controller.checkLanguage.value, "show_price_front")}）",
                                                    style: TextStyle(
                                                      fontSize: ScreenAdapter.fontSize(70)/2.5,
                                                      fontFamily: GFont.getFontFamily(),
                                                      fontWeight: FontWeight.w600,
                                                      color: ColorsUtil.hexToColor(Gcolor.priceColor),
                                                      textBaseline: TextBaseline.alphabetic,
                                                    ),
                                                  ),
                                                ]),
                                          ),
                                        ),
                                      ),
                                      //确认按钮
                                      InkWell(
                                        enableFeedback: false,
                                        onTap: () {
                                          controller.paymentIsShow = false;
                                          //判断选择后option是否与optiongroup相等
                                          var currentPrice = item['currentPrice'];
                                          var optionCodeList = "";
                                          var optionTitle = "";
                                          if (item['optionGroupVoList']?.length > 0) {//item['optionGroupVoList'].length
                                            /*if (_selectedMenuOptionList[item['menuCode']].length < _selectedMenuOptionCheckedNum[item['menuCode']]) {
                                        showToast(GString.getToString(this._checkLanguage, "show_please_select_error"));
                                        Navigator.pop(context);
                                        return;
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
                                            //controller.changeInitialAllOption(item['menuCode']);

                                            Future.delayed(Duration(milliseconds: 50),() async {
                                              Get.back();
                                            });
                                          });
                                        },
                                        child: Container(
                                          margin:EdgeInsets.only(right: ScreenAdapter.width(20),),
                                          width: ScreenAdapter.width(260),
                                          height: ScreenAdapter.height(140),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: ColorsUtil.hexToColor("#078E42"),
                                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                          ),
                                          child: Text(
                                              GString.getToString(
                                                  controller.checkLanguage.value, "add_option_cart"),
                                              style: TextStyle(
                                                fontFamily: GFont.getFontFamily(),
                                                fontSize: ScreenAdapter.fontSize(40),
                                                fontWeight: FontWeight.w500,
                                                color: ColorsUtil.hexToColor(
                                                    Gcolor.optionBtnColor),
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
