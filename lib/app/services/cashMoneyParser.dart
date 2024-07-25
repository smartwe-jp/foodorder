class MoneyParser {
  static int calculateTotalAmount(String input) {//print("input${input}");
    final List<String> parts = input.split(' ');
    int totalAmount = 0;

    for (int i = 0; i < parts.length; i += 3) {
      final String denomination = parts[i];
      final String hexQuantity = parts[i + 1];
      final String hexQuantity2 = parts[i + 2];//print(denomination +"=="+hexQuantity +"=="+hexQuantity2);
      //print(hexQuantity2);break;

      // 解析面额并将其映射到实际金额
      final int amount = _mapDenominationToAmount(denomination);

      // 解析16进制数量并转换为十进制，然后计算总金额
      final int parsedQuantity = _parseHexQuantity(hexQuantity2+hexQuantity);
      totalAmount += amount * parsedQuantity;
    }

    return totalAmount;
  }

  static int _mapDenominationToAmount(String denomination) {
    // 创建面额到金额的映射关系
    final Map<String, int> denominationToAmount = {
      '61': 1, //97
      '62': 5, //98
      '63': 10, //99
      '64': 50, //100
      '65': 100, //101
      '66': 500, //102
      '87': 1000, //-121
      '88': 2000, //-120
      '89': 5000, //-119
      '8A': 10000, //-118
      // 添加更多面额映射
      'A1': 1, //-95
      'A2': 5, //-94
      'A3': 10, //-93
      'A4': 50, //-92
      'A5': 100, //-91
      'A6': 500, //-90
      '97': 1000, //-105
    };

    // 如果找不到映射则默认为0
    return denominationToAmount[denomination] ?? 0;
  }

  static int _parseHexQuantity(String hexQuantity) {
    // 将16进制数量转换为十进制
    final int decimalQuantity = int.tryParse(hexQuantity, radix: 16) ?? 0;
    return decimalQuantity;
  }
}