
import 'package:intl/intl.dart';


// extension Localization on String {
//   String localized() {
//     final localKey = Get.locale?.languageCode ?? 'JP';
//     return GString.getToString(localKey, this);
//   }
// }

extension NumberFormatting on int {
  String formatSum() {
    final formatter = NumberFormat('#,###');
    return formatter.format(this);
  }
}

extension StringFormatting on String {
  String formatSum() {
    final formatter = NumberFormat('#,###');
    return formatter.format(int.parse(this));
  }
}