

class PrintListState {
	/// 展示用的最近打印记录（最多30条）
	List<PrintOrderItem> printList = [];
}

class PrintOrderItem {
	final String serialNumber;
	final String orderId;
	final String orderTime;
	final String payMethod;
	final String payPrice;
	final String change;
	final Map<String, dynamic> raw;

	PrintOrderItem({
		required this.serialNumber,
		required this.orderId,
		required this.orderTime,
		required this.payMethod,
		required this.payPrice,
		required this.change,
		required this.raw,
	});

	factory PrintOrderItem.fromMap(Map<String, dynamic> map) {
		String _pickStr(dynamic v) => (v == null || v.toString().trim().isEmpty) ? '-' : v.toString();
		return PrintOrderItem(
			serialNumber: _pickStr(map['serialNumber'] ?? map['serialNumberText']),
			orderId: _pickStr(map['orderId']),
			orderTime: _pickStr(map['orderTime'] ?? map['payDate']),
			payMethod: _pickStr(map['payMethod']),
			payPrice: _pickStr(map['payPrice'] ?? map['price']),
			change: _pickStr(map['change']),
			raw: map,
		);
	}
}