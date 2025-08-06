import 'package:get/get.dart';

import '../../../services/HomeServices.dart';
import '../../setting/views/setting_view.dart';
import '../views/VerifyPassword.dart';

class MiddlewareSettingPageController extends GetxController {
  //TODO: Implement MiddlewareSettingPageController
  RxString machineCode = "".obs;

  @override
  void onInit() {
    machineCode.value = Get.arguments['machineCode'];

    jumpSetting();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  jumpSetting() async {
    var smartweMachineSettingPassword = await HomeServices.getMachineSettingManagePasswordInfo();
    if(smartweMachineSettingPassword != null && smartweMachineSettingPassword!= ""){
      showSettingPassword();
    }else{
      Get.offAllNamed('/setting', arguments: {"machineCode": machineCode.value});
      //Get.off(()=>SettingView(), arguments: {"machineCode": machineCode.value});
    }
  }

  showSettingPassword() async {
    Get.dialog(
        VerifyPasswordPage(machineCode: machineCode.value,)
    );
  }
}
