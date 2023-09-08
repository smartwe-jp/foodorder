// ignore: depend_on_referenced_packages

class PrinterInfo {
  final String? ip;

  PrinterInfo({
    this.ip,
  });

  /*String get name {
    if (ip != null) {
      return '网口打印机: $ip';
    }
  }*/

  bool get isNetPrinter => ip != null;

  factory PrinterInfo.fromIp(String ip) {
    return PrinterInfo(ip: ip);
  }
}
