
extension CashString on String {
    String findMaxCash() {
    final currencies = this.split(',');
    final reachedMax = <String>[];

    bool getCashReachMax(String type, String count) {
      switch (type) {
        case "10000":
        case "5000":
          return count == '100' || count =='90';
        case "2000":
        case "1000":
          return count == '200' || count =='190';
        case "500":
          return count == '105' || count =='95';
        case "100":
        case "10":
        case "1":
          return count == '160' || count =='150';
        case "50":
        case "5":
          return count == '120' || count =='110';
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
}