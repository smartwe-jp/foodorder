import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/modules/edit_page/state.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:foodorder/app/services/showToast.dart';
import 'package:foodorder/app/widget/DialogUtils.dart';
import 'package:foodorder/app/widget/LoadingWidget.dart';
import 'package:get/get.dart';

import '../../controllers/machine_info.dart';

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
    state.currentCategoryCode = catetoryCode;
    await _getBookingBootIndexMenu(catetoryCode);
    update();
  }

  _startSellingRequest(menuCode) async {
    //Loading
    LoadingUtil.showEasyLoading();

    var formData = {
      "machineCode": machineInfo.machineCode,
      "menuCode": menuCode,
    };

    request('webBootStartSelling', method: 'PUT', parameters: formData)
        .then((val) {
      EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response['code'] == 200) {
        showToast('メニューを販売中に変更しました');
        _getBookingBootIndexMenu(state.currentCategoryCode);
      } else {
        showToast('失敗' + response['msg']);
      }
    }).catchError((e) {
      EasyLoading.dismiss();
      showToast('エラー メニューの販売中の変更に失敗しました');
    }).timeout(Duration(seconds: 60), onTimeout: () {
      EasyLoading.dismiss();
      showToast('エラー メニューの販売中の変更に失敗しました');
    });
  }

  _stopSellingRequest(menuCode) async {
    //Loading
    LoadingUtil.showEasyLoading();

    var formData = {
      "machineCode": machineInfo.machineCode,
      "menuCode": menuCode,
    };

    request('webBootStopSelling', method: 'PUT', parameters: formData)
        .then((val) {
      EasyLoading.dismiss();
      var response = json.decode(val.toString());
      if (response['code'] == 200) {
        showToast('メニューを売り切れに変更しました');
        _getBookingBootIndexMenu(state.currentCategoryCode);
      } else {
        showToast('失敗' + response['msg']);
      }
    }).catchError((e) {
      EasyLoading.dismiss();
      showToast('エラー メニューの売り切れの変更に失敗しました');
    }).timeout(Duration(seconds: 60), onTimeout: () {
      EasyLoading.dismiss();
      showToast('エラー メニューの売り切れの変更に失敗しました');
    });
  }

  showSetSelloutAlert(menuId, name, bounds) {
    bool isSellOut = bounds == 0;
    String tips = isSellOut
        ? 'このメニュー($name)を販売中に変更してもよろしいですか?'
        : 'このメニュー($name)を本日売り切れに変更してもよろしいですか?';
    Get.dialog(DialogUtils.alert(tips, confirm: () {
      Get.back();
      if (isSellOut) {
        _startSellingRequest(menuId);
      } else {
        _stopSellingRequest(menuId);
      }
    }, cancle: () {
      Get.back();
    }));
  }

  _showSetSelloutAlert(menuId, name, bounds, {String time = ""}) {
    bool isSellOut = bounds == 0;
    String tips = isSellOut
        ? 'このメニュー($name)を販売中に変更してもよろしいですか?'
        : 'このメニュー($name)を$timeに完売に変更してもよろしいですか?';
    Get.dialog(DialogUtils.alert(tips, confirm: () {
      Get.back();
      Get.back();
    }, cancle: () {
      Get.back();
    }));
  }

  // 弹出一个设置售罄的对话框，标题设置下架时间，下面有一个列表时间，分别为4小时 6小时 8小时 10小时 12小时 24小时 永久。
  showSetSelloutTimeAlert(menuId, name, bounds) {
    bool isSellOut = bounds == 0;

    if (isSellOut) {
      // 如果是售罄状态，弹出设置售罄时间的对话框
      _showSetSelloutAlert(menuId, name, bounds);
      return;
    }

    List<String> timeOptions = [
      '4 時間',
      '6 時間',
      '8 時間',
      '10 時間',
      '24 時間',
    ];
    _alertWithList(timeOptions, confirm: (selectedTime) {
      // 处理选中的时间
      //Get.back();
      _showSetSelloutAlert(menuId, name, bounds, time: selectedTime);
    });
  }

  // 实现这个Dialog alertWithList
  _alertWithList(List<String> options,
      {Function(String)? confirm, Function()? cancel}) {
    Get.dialog(
      AlertDialog(
        title: Text('完売に変更する時間を設定してください',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
        content: SizedBox(
          width: 600,
          height: 500,
          child: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: ListBody(
                  children: options.map((option) {
                    return GestureDetector(
                        onTap: () {
                          if (confirm != null) {
                            confirm(option);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(vertical: 26.0),
                            ),
                            onPressed: () {
                              if (confirm != null) {
                                confirm(option);
                              }
                            },
                            child: Text(
                              option,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ));
                  }).toList(),
                ),
              ),
            ),

            //cancel button
            Container(
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (cancel != null) {
                    cancel();
                  }
                  Get.back();
                },
                child: Text('キャンセル',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    )),
              ),
            ),
          ]),
        ),
        actions: null,
      ),
    );
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

    request('webBootIndexCategoryEdit', method: 'POST', parameters: formData)
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
              title: "tag_title".tr,
              confirmtitle: "tag_button_yes".tr,
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
        state.currentCategoryCode = firstCategory;
        _getBookingBootIndexMenu(firstCategory);
      } else {
        //showToast(response['msg']);
        Get.dialog(DialogUtils.alertOneButton(response['msg'],
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
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

    request('webBootIndexMenuEdit', method: 'POST', parameters: formData)
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
              title: "tag_title".tr,
              confirmtitle: "tag_button_yes".tr,
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
            title: "tag_title".tr,
            confirmtitle: "tag_button_yes".tr,
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
