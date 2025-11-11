

class PrintListState {
	/// 展示用的最近打印记录（最多30条）
	List<PrintOrderItem> printList = [];

	/// 分类列表（来自 PrintInfoService.listCategories）
	List<String> categories = [];

	/// 当前选中的分类
	String? selectedCategory;

	/// 是否当前分类为“汇总/交班”等摘要数据类型（与订单不同的数据结构）
	bool showingSummary = false;

	/// 摘要类数据列表（仅当 showingSummary=true 时使用）
	List<PrintSummaryItem> summaryList = [];

	/// 通用：当前分类的原始数据（更灵活的渲染入口）
	List<Map<String, dynamic>> currentItemsRaw = [];

	/// 每个分类对应的渲染类型（order/summary/自定义）。
	/// 例如：{'default': 'order', 'rejishime': 'summary'}
	Map<String, String> categoryRenderer = {
    'default': '注文レシート',
    'rejishime': 'レジ締め',
  };

  double printLength = 0.0;
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
			change: _pickStr(map['change'] ?? 0),
			raw: map,
		);
	}
}

/// 摘要/交班/营业汇总等打印数据的展示结构
class PrintSummaryItem {
	final String shopName;
	final String startTime;
	final String endTime;
	final String printTime;
	final String verifyUserName;
	final Map<String, dynamic> raw;

	PrintSummaryItem({
		required this.shopName,
		required this.startTime,
		required this.endTime,
		required this.printTime,
		required this.verifyUserName,
		required this.raw,
	});

	factory PrintSummaryItem.fromMap(Map<String, dynamic> map) {
		String _pickStr(dynamic v) => (v == null || v.toString().trim().isEmpty) ? '-' : v.toString();
		return PrintSummaryItem(
			shopName: _pickStr(map['shopName']),
			startTime: _pickStr(map['startTime']),
			endTime: _pickStr(map['endTime']),
			printTime: _pickStr(map['printTime']),
			verifyUserName: _pickStr(map['verifyUserName'] ?? map['verifyEmail'] ?? map['verifyCode']),
			raw: map,
		);
	}
}