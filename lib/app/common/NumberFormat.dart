import 'package:intl/intl.dart';

extension NumberFormatting on int {
  String formatSum() {
    final formatter = NumberFormat('#,###');
    return formatter.format(this);
  }



  String formatIntSum() {
    final formatter = NumberFormat('#,###');
    return formatter.format(this);
  }
}

