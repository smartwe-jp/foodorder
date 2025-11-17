import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:foodorder/app/controllers/machine_info.dart';
import 'package:foodorder/app/modules/menuPage/controllers/menu_page_controller.dart';
import 'package:foodorder/app/modules/menuPage/views/menu_page_category.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:get/get.dart';

import '../views/widgets/grid_item_view.dart';

extension MenuPageControllerExtension on MenuPageController {
  void restoreNavigationStatus(String tag, int page) {
    selectIndex = page;
    classTag.value = tag;
    // for (var subElement in sidebarInfo?.sidebarItemList ?? []) {
    //   if (subElement.tag == tag) {
    //     subElement.isSelected = true;
    //     _updateOptionsInfo(subElement.menuData);
    //   } else {
    //     subElement.isSelected = false;
    //   }
    // }
    bgColor.value = topMenu.isNotEmpty && topMenu.length > selectIndex
        ? (topMenu[selectIndex]['background'] ?? "#F9F9F9")
        : "#F9F9F9";

    update(['side_bar']);
    update(['background']);
  }

  _updateOptionsInfo(List menuList) {
    if (menuList.isNotEmpty) {
      for (var menuVoList in menuList) {
        num _addOptionPrice = 0;
        if (menuVoList['optionGroupVoList'] != null &&
            menuVoList['optionGroupVoList']?.length > 0 &&
            menuVoList['optionGroupVoList'] != "") {
          //初始化菜品option选项
          //属性循环相关
          var attr = menuVoList['optionGroupVoList'];
          var nochangeattr = menuVoList['optionGroupVoList'];
          List tempArr = [];
          List initalCode = [];
          var checkNum = 0;

          for (var m = 0; m < attr.length; m++) {
            for (var n = 0; n < attr[m]['optionVoList'].length; n++) {
              /*attr[m]['optionVoList'][n]["checked"] = false;
                      if(n == 0){
                        tempArr.add(attr[m]['optionVoList'][n]);
                      }*/
              if (attr[m]['optionVoList'][n]["standard"] == 1) {
                attr[m]['optionVoList'][n]["checked"] = true;
                nochangeattr[m]['optionVoList'][n]["checked"] = true;
                attr[m]['optionVoList'][n]["groupTitle"] = attr[m]["groupName"];
                tempArr.add(attr[m]['optionVoList'][n]);
                initalCode.add(attr[m]['optionVoList'][n]['optionCode']);

                _addOptionPrice += attr[m]['optionVoList'][n]["currentPrice"];
                checkNum++;
              } else {
                attr[m]['optionVoList'][n]["checked"] = false;
                nochangeattr[m]['optionVoList'][n]["checked"] = false;
              }
            }
          }
          //需要创建的小组件
          menuOption[menuVoList['menuCode']] = attr;
          noChangeinitialmenuOption[menuVoList['menuCode']] = initalCode;
          initialMenuOption[menuVoList['menuCode']] = tempArr; //tempArr;
          selectedMenuOptionList[menuVoList['menuCode']] = tempArr;
          selectedMenuOptionCheckedNum[menuVoList['menuCode']] = checkNum;
          attr = [];
          tempArr = [];
          checkNum = 0;
        }
        selectedMenuOptionChangePrice[menuVoList['menuCode']] =
        menuVoList['currentPrice'];
        addselectedMenuOptionChangePrice[menuVoList['menuCode']] =
            _addOptionPrice;
      }
    }
  }

  List<Widget> getCurrentMenuItems(List menuData) {
    List<Widget> children = [];
    for (var item in menuData) {
      children.add(menuItemView(item, Get.context));
    }
    return children;
  }

  Future<Widget?> getCategoryMenu(
      {firstLoad = false}) async {

    debugPrint("getCategoryMenu:${classTag.value}");
    Widget? menuWidget = null;
    var queryTakeout = "2";
    if (machineInfo.currentMode == MachineMode.takeout) {
      queryTakeout = "0";
    }
    //queryTakeout 0外卖 1都可 2店内
    // switch (machineInfo.diningType) {
    //   case "1":
    //     queryTakeout = "2";
    //     break;
    //   case "2":
    //     queryTakeout = "0";
    //     break;
    //   case "3":
    //     if (machineInfo.mealType == true) {
    //       queryTakeout = "0";
    //     } else {
    //       queryTakeout = "2";
    //     }
    //     break;
    //   default:
    //     queryTakeout = "2";
    // }
    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": checkLanguage.value,
      "takeout": queryTakeout,
      "categoryCode": classTag.value
    };
    debugPrint("formData:${formData}");

    try {
      final val = await request('webBootIndexMenuv3',
          method: 'POST', parameters: formData)
          .timeout(const Duration(seconds: 15));
      var response = json.decode(val.toString());
      if (response != null &&
          response['code'] == 200 &&
          response['data'] != null) {
        showItem[classTag.value] = response['data'];
        _updateOptionsInfo(response['data']);
        menuWidget = showMiddleMenuList(Get.context!);
      }

    } on TimeoutException catch (e) {
      debugPrint('TimeoutException:${e.toString()}');
    } catch (e) {
      debugPrint('error Exception:${e.toString()}');
    }
    return menuWidget;
  }

  itemImage(String? url) {
    if (url == null || url.isEmpty) {
      return AssetImage('assets/images/public/food.png');
    }
    return CachedNetworkImageProvider(url, cacheManager: customCacheManager);

  }

  menuItemView(item, context, {popupType: "old", aspectRatio: 1.0}) {
    //debugPrint("menuItemView: $item");
    return GridItemView(
      title: item['mainTitle'],
      subtitle: publicMenuSubtitle(item['subtitle'] ?? []),
      price: "${item['currentPrice']}",
      originalPrice: "${item['price'] ?? 0}",
      image: itemImage(item['homeImage']),
      option: item['optionGroupVoList']?.length > 0
          ? "select_option".tr
          : "",
      aspectRatio: aspectRatio,
      onTap: () async {
        debugPrint("GridItemView onTap");

        if (item['qtyBounds'] == 0) {
          return;
        } else if (item['qtyBounds'] > 0) {
          //debugPrint("GridItemView onTap qtyBounds $item");
          //请求限定接口
          if (canAddCart.value)
            await checkQtyBoundsCount(item, "", popupType, context);
        } else {
          //如果option 存在，则弹出option
          debugPrint("GridItemView onTap option");
          if (item['optionGroupVoList']?.length > 0) {
            if (popupType == "v1") {
              debugPrint("GridItemView onTap option 1");
              publicShowOneItemWidgetv1(item);
            } else {
              debugPrint("GridItemView onTap option 0");
              publicShowOneItemWidget(item);
            }
          } else {
            if (canAddCart.value) publicAddCart(context, item);
          }
        }
      },
      cover: publicShowMenuSellOut(item['qtyBounds']),
    );
  }

  showMiddleMenuList(BuildContext context) {
    for (var item in topMenu) {
      if (classTag.value == item['categoryCode']) {
        if (item['showType'] == "featured") {
          return showCategoryOne(showItem[classTag.value], context);
        } else if (item['showType'] == "table") {
          //350.0, 350.0
          return showCategoryTwo(showItem[classTag.value], context);
          //return _showCategoryEight(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "table_v1") {
          //350.0, 350.0
          return showCategoryTwo(showItem[classTag.value], context,
              popupType: "v1");
          //return _showCategoryEight(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "block") {
          //350.0, 350.0
          return showCategoryThree(showItem[classTag.value]);
        } else if (item['showType'] == "grid") {
          //260.0, 400.0
          return showCategoryFour(showItem[classTag.value], context);
        } else if (item['showType'] == "grid_v1") {
          //260.0, 400.0
          return showCategoryFour(showItem[classTag.value], context,
              popupType: "v1");
        } else if (item['showType'] == "waterfall") {
          //400.0, 260.0
          return showCategoryFive(showItem[classTag.value]);
        } else if (item['showType'] == "double_column") {
          //530.0, 530.0
          return showCategorySix(showItem[classTag.value], context);
        } else if (item['showType'] == "double_column_v1") {
          //530.0, 530.0
          return showCategorySix(showItem[classTag.value], context,
              popupType: "v1");
        } else if (item['showType'] == "three_column") {
          //350.0, 440.0
          return showCategorySeven(showItem[classTag.value], context);
        } else if (item['showType'] == "three_column_v1") {
          //350.0, 440.0
          return showCategorySeven(showItem[classTag.value], context,
              popupType: "v1");
        } else if (item['showType'] == "mixed_column") {
          //混合模式 底部一行3列710.0, 710.0 350.0, 310.0 350.0, 350.0
          return showCategoryEight(showItem[classTag.value], context);
          //return _showCategoryNine(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "mixed_column_v1") {
          //混合模式 底部一行3列710.0, 710.0 350.0, 310.0 350.0, 350.0
          return showCategoryEight(showItem[classTag.value], context,
              popupType: "v1");
          //return _showCategoryNine(controller.showItem.value[controller.classTag.value]);
        } else if (item['showType'] == "mixed_two_column") {
          //混合模式 底部一行2列 710.0, 710.0 350.0, 310.0 530.0, 530.0
          return showCategoryNine(showItem[classTag.value], context);
        } else if (item['showType'] == "mixed_two_column_v1") {
          //混合模式 底部一行2列 710.0, 710.0 350.0, 310.0 530.0, 530.0
          return showCategoryNine(showItem[classTag.value], context,
              popupType: "v1");
        } else {
          return showCategoryTwo(showItem[classTag.value], context);
        }
      }
    }
  }

  showCategoryTwoItemList(items, context, {popupType: "old"}) {
    List<Widget> children = [];
    for (var item in items) {
      children.add(menuItemView(item, context, popupType: popupType));
    }
    return GridMenuView(children: children, childAspectRatio: 0.71,);
  }

  showCategoryFourItemList(items, context, {popupType: "old"}) {
    List<Widget> children = [];
    for (var item in items) {
      children.add(menuItemView(item, context, popupType: popupType));
    }

    return GridMenuView(children: children, crossAxisCount: 2, childAspectRatio: 0.71,);
  }
}
