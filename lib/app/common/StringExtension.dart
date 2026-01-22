
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension CashString on String {
  String findMaxCash() {
    final currencies = this.split(',');
    final reachedMax = <String>[];
    

    bool getCashReachMax(String type, String count) {
      int intValue = int.parse(count);
      switch (type) {
        case "10000":
          return count == '100' || intValue >= 90;
        case "5000":
          return count == '100' || intValue >= 90;
        case "2000":
        case "1000":
          return count == '200' || intValue >= 190;
        case "500":
          return count == '105' || intValue >= 95;
        case "100":
          return count == '160' || intValue >= 10;
        case "10":
          return count == '160' || intValue >= 40;
        case "1":
          return count == '160' || intValue >= 150;
        case "50":
          return count == '120' || intValue >= 110;
        case "5":
          return count == '120' || intValue >= 110;
        default:
          return false;
      }
    }

    for (final currency in currencies) {
      final parts = currency.split(':');
      if (parts.length == 2 && getCashReachMax(parts[0], parts[1])) {
        reachedMax.add(_getCashName(parts[0]));
      }
    }

    return reachedMax.join(' ');
  }

  bool cashReachMax(int count) {
      switch (this) {
        case "一万円":
          return count == 100 || count >= 90;
        case "五千円":
          return count == 100 || count >= 90;
        case "二千円":
        case "千円":
          return count == 200 || count >= 190;
        case "五百円":
          return count == 105 || count >= 95;
        case "百円":
          return count == 160 || count >= 150;
        case "十円":
          return count == 160 || count >= 150;
        case "一円":
          return count == 160 || count >= 150;
        case "五十円":
          return count == 120 || count >= 110;
        case "五円":
          return count == 120 || count >= 110;
        default:
          return false;
      }
    }

  String _getCashName(String value) {
    switch (value) {
      case '1':
        return '一円';
      case '5':
        return '五円';
      case '10':
        return '十円';
      case '50':
        return '五十円';
      case '100':
        return '百円';
      case '500':
        return '五百円';
      case '1000':
        return '千円';
      case '2000':
        return '二千円';
      case '5000':
        return '五千円';
      case '10000':
        return '一万円';
      default:
        return '';
    }
  }

  String getHexCashName() {
    switch (this) {
      case '61':
        return '一円';
      case '62`':
        return '五円';
      case '63':
        return '十円';
      case '64':
        return '五十円';
      case '65':
        return '百円';
      case '66':
        return '五百円';
      case '87':
        return '千円';
      case '88':
        return '二千円';
      case '89':
        return '五千円';
      case '8A':
        return '一万円';
      default:
        return '';
    }
  }

  int getHexCashValue() {
    switch (this) {
      case '61':
        return 1;
      case '62`':
        return 5;
      case '63':
        return 10;
      case '64':
        return 50;
      case '65':
        return 100;
      case '66':
        return 500;
      case '87':
        return 1000;
      case '88':
        return 2000;
      case '89':
        return 5000;
      case '8A':
        return 10000;
      default:
        return 0;
    }
  }


  String formatSum() {
    final formatter = NumberFormat('#,###');
    return formatter.format(int.parse(this));
  }

  urlImage() {
    if (this.isEmpty) {
      return AssetImage('assets/images/public/food.png');
    }
    return CachedNetworkImageProvider(this);
  }

}