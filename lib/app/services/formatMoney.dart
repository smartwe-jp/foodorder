/// 千分位格式化金额
/// [toFixed] 保留多少位小数点 默认保留全部
/// formatMoney(123456) => 123,456
/// formatMoney(123456.1234) => 123,456.1234
/// formatMoney(123456.1234, toFixed: 2) => 123,456.12
String formatMoney(Object val, {int? toFixed}) {
if (toFixed != null) {
val = double.parse(val.toString()).toStringAsFixed(toFixed);
}
List<String> split = val.toString().split('.');
String str = split[0].replaceAll(RegExp(r"\B(?=(\d{3})+(?!\d))"), ",");
if (split.length > 1) return str + '.' + split[1];
return str;
}