
import 'paycube_old_platform_interface.dart';

class PaycubeOld {
  Future<String?> getPlatformVersion() {
    return PaycubeOldPlatform.instance.getPlatformVersion();
  }
}
