import 'dart:ffi';

import 'package:flutter/cupertino.dart';

class MoneyParser {
  static int calculateTotalAmount(String input) {
    //print("input${input}");
    final List<String> parts = input.split(' ');
    int totalAmount = 0;

    for (int i = 0; i < parts.length; i += 3) {
      final String denomination = parts[i];
      final String hexQuantity = parts[i + 1];
      final String hexQuantity2 = parts[
          i + 2]; //print(denomination +"=="+hexQuantity +"=="+hexQuantity2);
      //print(hexQuantity2);break;

      // 解析面额并将其映射到实际金额
      final int amount = _mapDenominationToAmount(denomination);

      // 解析16进制数量并转换为十进制，然后计算总金额
      final int parsedQuantity = _parseHexQuantity(hexQuantity2 + hexQuantity);
      totalAmount += amount * parsedQuantity;
    }

    return totalAmount;
  }

  static int calculateGloryTotalAmount(String input) {
    if (input.length % 3 != 0 || input.length < 30) {
      throw Exception('Invalid input');
    }

    int totalAmount = 0;

    final int en500Amout = int.parse(input.substring(0, 2)) * 500;
    final int en100Amout = int.parse(input.substring(3, 5)) * 100;
    final int en50Amout = int.parse(input.substring(6, 8)) * 50;
    final int en10Amout = int.parse(input.substring(9, 11)) * 10;
    final int en5Amout = int.parse(input.substring(12, 14)) * 5;
    final int en1Amout = int.parse(input.substring(15, 17)) * 1;
    final int en10000Amout = int.parse(input.substring(18, 20)) * 10000;
    final int en5000Amout = int.parse(input.substring(21, 23)) * 5000;
    final int en2000Amout = int.parse(input.substring(24, 26)) * 2000;
    final int en1000Amout = int.parse(input.substring(27, 29)) * 1000;

    totalAmount = en500Amout +
        en100Amout +
        en50Amout +
        en10Amout +
        en5Amout +
        en1Amout +
        en10000Amout +
        en5000Amout +
        en2000Amout +
        en1000Amout;

    return totalAmount;
  }

  static String migrationGloryToHexString(String input,
      {Function(List<int>, Map)? onResult}) {
    debugPrint("glory = ${input}");
    if (input.length % 3 != 0 || input.length < 30) {
      throw Exception('Invalid input');
    }

    String hexString = '';
    List<int> result = [];
    Map details = {};

    final int en500Amout = int.parse(input.substring(0, 3));
    final int en100Amout = int.parse(input.substring(3, 6));
    final int en50Amout = int.parse(input.substring(6, 9));
    final int en10Amout = int.parse(input.substring(9, 12));
    final int en5Amout = int.parse(input.substring(12, 15));
    final int en1Amout = int.parse(input.substring(15, 18));
    final int en10000Amout = int.parse(input.substring(18, 21));
    final int en5000Amout = int.parse(input.substring(21, 24));
    final int en2000Amout = int.parse(input.substring(24, 27));
    final int en1000Amout = int.parse(input.substring(27, 30));
    
    result.add(en10000Amout);
    result.add(en5000Amout);
    result.add(en2000Amout);
    result.add(en1000Amout);
    result.add(en500Amout);
    result.add(en100Amout);
    result.add(en50Amout);
    result.add(en10Amout);
    result.add(en5Amout);
    result.add(en1Amout);

    if (en10000Amout > 0) 
      details['8A'] = en10000Amout;
    
    if (en5000Amout > 0) 
      details['89'] = en5000Amout;
    
    if (en2000Amout > 0) 
      details['88'] = en2000Amout;
    
    if (en1000Amout > 0) 
      details['87'] = en1000Amout;

    if (en500Amout > 0)
      details['66'] = en500Amout;

    if (en100Amout > 0)
      details['65'] = en100Amout;

    if (en50Amout > 0)
      details['64'] = en50Amout;
    
    if (en10Amout > 0)
      details['63'] = en10Amout;

    if (en5Amout > 0)
      details['62'] = en5Amout;

    if (en1Amout > 0)
      details['61'] = en1Amout;
    

    if (onResult != null) {
      onResult(result, details);
    }

    hexString = "61 " +
        bigEndToLittleDnd(en1Amout) +
        " " +
        "62 " +
        bigEndToLittleDnd(en5Amout) +
        " " +
        "63 " +
        bigEndToLittleDnd(en10Amout) +
        " " +
        "64 " +
        bigEndToLittleDnd(en50Amout) +
        " " +
        "65 " +
        bigEndToLittleDnd(en100Amout) +
        " " +
        "66 " +
        bigEndToLittleDnd(en500Amout) +
        " " +
        "87 " +
        bigEndToLittleDnd(en1000Amout) +
        " " +
        "88 " +
        bigEndToLittleDnd(en2000Amout) +
        " " +
        "89 " +
        bigEndToLittleDnd(en5000Amout) +
        " " +
        "8A " +
        bigEndToLittleDnd(en10000Amout);
    debugPrint("hexString = ${hexString}");
    return hexString;
  }

  static String bigEndToLittleDnd(int input) {
    String hex = input.toRadixString(16).padLeft(4, '0');
    List<String> bytes = [
      for (int i = 0; i < hex.length; i += 2) hex.substring(i, i + 2)
    ];
    String littleEndian = bytes.reversed.join(' ');
    return littleEndian;
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
      '98': 2000, //-104
      '99': 5000, //-103
      '9A': 10000, //-102
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
