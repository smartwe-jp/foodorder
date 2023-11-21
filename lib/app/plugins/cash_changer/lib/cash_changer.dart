
import 'cash_changer_platform_interface.dart';

class CashChanger {
  Future<String?> getPlatformVersion() {
    return CashChangerPlatform.instance.getPlatformVersion();
  }
}
