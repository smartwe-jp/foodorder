import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodorder/app/config/string.dart';
import 'package:foodorder/app/controllers/machine_info_controller.dart';
import 'package:foodorder/app/modules/edit_page/state.dart';
import 'package:foodorder/app/modules/menuPage/views/components/GridItemView.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:get/get.dart';

class EditPageLogic extends GetxController with StateMixin {
  MachineInfoController machineInfo = Get.find();
  final EditPageState state = EditPageState();

  @override
  void onInit() {
    _getBookingBootIndexCagegory();
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  changeCategory(catetoryCode, int page) async {
    state.selectIndex = page;
    await _getBookingBootIndexMenu(catetoryCode);
    update();
  }


  showSetSelloutAlert(menuId, name, bounds) {
    bool isSellOut = bounds == 0;
    String tips = isSellOut
        ? 'このメニュー($name)を販売中に変更してもよろしいですか?'
        : 'このメニュー($name)を本日売り切れに変更してもよろしいですか?';
    Get.dialog(DialogUtils.alert(tips, confirm: () {
      Get.back();
    }, cancle: () {
      Get.back();
    }));
  }

  _getBookingBootIndexCagegory() {
    debugPrint('_getBookingBootIndexCagegory');
    var queryTakeout = "2";
    //queryTakeout 0外卖 1都可 2店内
    switch (machineInfo.diningType) {
      case "1":
        queryTakeout = "2";
        break;
      case "2":
        queryTakeout = "0";
        break;
      case "3":
        if (machineInfo.mealType == true) {
          queryTakeout = "0";
        } else {
          queryTakeout = "2";
        }
        break;
      default:
        queryTakeout = "2";
    }
    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": "JP",
      "takeout": queryTakeout,
    };

    request('webBootIndexCategoryv2', method: 'POST', parameters: formData)
        .then((val) {
      debugPrint("getBookingBootIndexCagegory request done");
      var response = json.decode(val.toString());
      if (response['code'] == 200) {
        //debugPrint("getBookingBootIndexCagegory response: $response");
        //2、保存商品信息
        List myList = response['data']['categoryVoList'];
        //如果菜单为空则返回言语选择页面并给出提示
        if (myList.length == 0 || "" == myList) {
          //showToast("少々お待ちください");
          Get.dialog(DialogUtils.alertOneButton("少々お待ちください",
              title: GString.getToString("JP", "tag_title"),
              confirmtitle: GString.getToString("JP", "tag_button_yes"),
              confirm: () {
            Get.back();
          }));
          return;
        }
        var firstCategory = '';
        for (var i = 0; i < myList.length; i++) {
          var categoryVoList = myList[i];
          //配置顶部菜单
          state.topMenu.add({
            "categoryCode": categoryVoList['categoryCode'],
            "categoryName": categoryVoList['categoryName'],
            "showType": categoryVoList['showType'],
            "showColor": categoryVoList['color']
          });
          if (i == 0) firstCategory = categoryVoList['categoryCode'];
        }

        _getBookingBootIndexMenu(firstCategory);
      } else {
        //showToast(response['msg']);
        Get.dialog(DialogUtils.alertOneButton(response['msg'],
            title: GString.getToString("JP", "tag_title"),
            confirmtitle: GString.getToString("JP", "tag_button_yes"),
            confirm: () {
          Get.back();
        }));
        return;
      }
    }).catchError((e) {
      change(null, status: RxStatus.error('Failed to load data'));
    }).timeout(Duration(seconds: 60), onTimeout: () {
      change(null, status: RxStatus.error('Failed to load data Timeout'));
    });
  }

  _getBookingBootIndexMenu(queryCategoryCode) {
    var queryTakeout = "2";
    //queryTakeout 0外卖 1都可 2店内
    switch (machineInfo.diningType) {
      case "1":
        queryTakeout = "2";
        break;
      case "2":
        queryTakeout = "0";
        break;
      case "3":
        if (machineInfo.mealType == true) {
          queryTakeout = "0";
        } else {
          queryTakeout = "2";
        }
        break;
      default:
        queryTakeout = "2";
    }
    var formData = {
      "machineCode": machineInfo.machineCode,
      "language": 'JP',
      "takeout": queryTakeout,
      "categoryCode": queryCategoryCode
    };

    request('webBootIndexMenuv3', method: 'POST', parameters: formData)
        .then((val) {
      var response = json.decode(val.toString());
      //debugPrint("getBookingBootIndexMenu request :$response");
      if (response['code'] == 200) {
        //2、保存商品信息
        List myList = response['data'];
        //如果菜单为空则返回言语选择页面并给出提示
        if (myList.length == 0 || "" == myList) {
          //showToast("少々お待ちください");
          Get.dialog(DialogUtils.alertOneButton("少々お待ちください",
              title: GString.getToString('JP', "tag_title"),
              confirmtitle: GString.getToString('JP', "tag_button_yes"),
              confirm: () {
            Get.back();
          }));
          return;
        }

        state.currentPageItems = myList;
        change(null, status: RxStatus.success());
        debugPrint("getBookingBootIndexMenu request update");
      } else {
        //showToast(response['msg']);
        Get.dialog(DialogUtils.alertOneButton(response['msg'],
            title: GString.getToString('JP', "tag_title"),
            confirmtitle: GString.getToString('JP', "tag_button_yes"),
            confirm: () {
          Get.back();
        }));
        return;
      }
    }).catchError((e) {
      change(null, status: RxStatus.error('Failed to load data'));
    }).timeout(Duration(seconds: 60), onTimeout: () {
      change(null, status: RxStatus.error('Failed to load data Timeout'));
    });
  }
}
