
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:foodorder/app/services/HttpService.dart';
import 'package:get/get.dart';

import '../../../config/imageData.dart';
import '../../../controllers/create_printImage_controller.dart';
import '../../../services/ScreenAdapter.dart';
import '../../../services/logUtil.dart';
import '../../../widget/DialogUtils.dart';

class ReceiptQueryController extends GetxController with StateMixin {
  CreatePrintImageController createPrintImageController = Get.find<CreatePrintImageController>();

  RxList receiptList = [].obs;
  RxString machineCode = "".obs;
  RxString orderText = "注文番号の後ろ六桁を入力してください".obs;


  TextEditingController orderIdController=TextEditingController();


  @override
  void onInit() {
    machineCode.value = Get.arguments['machineCode'] ?? "";

    super.onInit();
  }

  @override
  void onReady() {
    change(null, status: RxStatus.success());
    super.onReady();
  }


  Future<void> getReceiptList() async {
    _showEasyLoading();
      if(orderIdController.text == ""){
        EasyLoading.dismiss();
        update();
        change(null, status: RxStatus.success());
        return;
      }
      var formData = {
        "machineCode": machineCode.value,
        "orderIdStr": orderIdController.text,
      };
      debugPrint(formData.toString());
      request('webBootReimburseQuery', method: 'POST', parameters: formData).then((val) {
        EasyLoading.dismiss();
        var response = json.decode(val.toString());
        LogUtil.d(response);
        if (response['code'] == 200 && response['data'] !=null && response['data'].length > 0) {

          receiptList.value = response['data'];
          //print(orderId.value);
          //goToSettlement();
        } else {
          noOrderAlsert();
        }

        update();
      });
  }

  Future<void> getReceiptInfo(orderId) async {
    _showEasyLoading();
    var formData = {
      "orderId": orderId,
    };

    request('webBootReceiptQueryV2', method: 'POST', parameters: formData).then((val) {
      EasyLoading.dismiss();
      var response = json.decode(val.toString());
      LogUtil.d(response);
      if (response !=null && response['data'] !=null) {
        createPrintImageController.tpPrintReceipt(response['data']);
        receiptList.value = [];
        orderIdController.text = "";
        update();
      } else {
        noOrderAlsert();
      }


    })
    .catchError((e) {
      EasyLoading.dismiss();
      noOrderAlsert();
    });
  }

  _showEasyLoading() {
    EasyLoading.show(
      //status: 'loading...',
      indicator: Container(
        width: ScreenAdapter.width(550),
        height: ScreenAdapter.height(480),
        padding: EdgeInsets.only(top: ScreenAdapter.height(15)),
        child: InkWell(
          onLongPress: () {
            EasyLoading.dismiss();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //_showTag,
              Container(
                //width: ScreenAdapter.width(400),
                margin: EdgeInsets.only(top: 60),
                height: ScreenAdapter.height(200),
                child: Image.asset(
                    GImage.getImageString("imgpublic", "printticketloading"),
                    fit: BoxFit.fitHeight),
              ),
            ],
          ),
        ),
      ),
      maskType: EasyLoadingMaskType.black,
    );
  }

  noOrderAlsert() {
    Get.dialog(
        DialogUtils.alertOneButton("指定した取引は存在しません。",
            title: "お知らせ",
            confirmtitle: "はい",
            confirm: () {
              orderIdController.text = "";
              Get.back();
              update();
            }),
        barrierDismissible: false
    );
  }

}