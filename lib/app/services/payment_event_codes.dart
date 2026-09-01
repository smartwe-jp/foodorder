abstract final class PaymentEventCode {
  static const String flowStarted = 'PAYMENT_FLOW_STARTED';
  static const String flowSucceeded = 'PAYMENT_FLOW_SUCCEEDED';
  static const String flowFailed = 'PAYMENT_FLOW_FAILED';
  static const String cancelRequested = 'PAYMENT_CANCEL_REQUESTED';
  static const String cancelFailed = 'PAYMENT_CANCEL_FAILED';
  static const String cancelled = 'PAYMENT_FLOW_CANCELLED';

  static const String cashDeviceOpenStarted = 'CASH_DEVICE_OPEN_STARTED';
  static const String cashDeviceOpenSucceeded = 'CASH_DEVICE_OPEN_SUCCEEDED';
  static const String cashDeviceOpenFailed = 'CASH_DEVICE_OPEN_FAILED';
  static const String cashDeviceStatusCheckStarted =
      'CASH_DEVICE_STATUS_CHECK_STARTED';
  static const String cashDeviceStatusCheckSucceeded =
      'CASH_DEVICE_STATUS_CHECK_SUCCEEDED';
  static const String cashDeviceStatusCheckFailed =
      'CASH_DEVICE_STATUS_CHECK_FAILED';
  static const String cashDeviceStatusUpdated =
      'CASH_DEVICE_STATUS_UPDATED';
  static const String cashCapacityWarning = 'CASH_CAPACITY_WARNING';
  static const String cashCapacityFull = 'CASH_CAPACITY_FULL';
  static const String cashBalanceReadStarted = 'CASH_BALANCE_READ_STARTED';
  static const String cashBalanceReadSucceeded =
      'CASH_BALANCE_READ_SUCCEEDED';
  static const String cashBalanceReadFailed = 'CASH_BALANCE_READ_FAILED';
  static const String cashDepositAmountUpdated = 'CASH_DEPOSIT_AMOUNT_UPDATED';
  static const String cashDepositDenominationsUpdated =
      'CASH_DEPOSIT_DENOMINATIONS_UPDATED';
  static const String cashPayoutDenominationsUpdated =
      'CASH_PAYOUT_DENOMINATIONS_UPDATED';
  static const String cashDenominationsFinalized =
      'CASH_DENOMINATIONS_FINALIZED';
  static const String cashDenominationsReadStarted =
      'CASH_DENOMINATIONS_READ_STARTED';
  static const String cashDenominationsReadSucceeded =
      'CASH_DENOMINATIONS_READ_SUCCEEDED';
  static const String cashDenominationsReadFailed =
      'CASH_DENOMINATIONS_READ_FAILED';
  static const String cashDepositStopStarted = 'CASH_DEPOSIT_STOP_STARTED';
  static const String cashDepositStopSucceeded = 'CASH_DEPOSIT_STOP_SUCCEEDED';
  static const String cashDepositStopFailed = 'CASH_DEPOSIT_STOP_FAILED';
  static const String cashChangeStarted = 'CASH_CHANGE_STARTED';
  static const String cashChangeCommandAccepted =
      'CASH_CHANGE_COMMAND_ACCEPTED';
  static const String cashChangeSucceeded = 'CASH_CHANGE_SUCCEEDED';
  static const String cashChangeFailed = 'CASH_CHANGE_FAILED';
  static const String cashTransactionCloseStarted =
      'CASH_TRANSACTION_CLOSE_STARTED';
  static const String cashTransactionCloseSucceeded =
      'CASH_TRANSACTION_CLOSE_SUCCEEDED';
  static const String cashTransactionCloseFailed =
      'CASH_TRANSACTION_CLOSE_FAILED';
  static const String cashRefundStarted = 'CASH_REFUND_STARTED';
  static const String cashRefundSucceeded = 'CASH_REFUND_SUCCEEDED';
  static const String cashRefundFailed = 'CASH_REFUND_FAILED';
  static const String cashExchangeReportStarted =
      'CASH_EXCHANGE_REPORT_STARTED';
  static const String cashExchangeReportSucceeded =
      'CASH_EXCHANGE_REPORT_SUCCEEDED';
  static const String cashExchangeReportFailed =
      'CASH_EXCHANGE_REPORT_FAILED';
  static const String cashReimburseNotifyStarted =
      'CASH_REIMBURSE_NOTIFY_STARTED';
  static const String cashReimburseNotifySucceeded =
      'CASH_REIMBURSE_NOTIFY_SUCCEEDED';
  static const String cashReimburseNotifyFailed =
      'CASH_REIMBURSE_NOTIFY_FAILED';

  static const String qrPaymentStarted = 'QR_PAYMENT_STARTED';
  static const String qrPaymentSucceeded = 'QR_PAYMENT_SUCCEEDED';
  static const String qrPaymentFailed = 'QR_PAYMENT_FAILED';
  static const String qrPaymentTimeout = 'QR_PAYMENT_TIMEOUT';

  static const String posConnectStarted = 'POS_CONNECT_STARTED';
  static const String posConnectSucceeded = 'POS_CONNECT_SUCCEEDED';
  static const String posConnectFailed = 'POS_CONNECT_FAILED';
  static const String posConnectTimeout = 'POS_CONNECT_TIMEOUT';
  static const String cardPaymentStarted = 'CARD_PAYMENT_STARTED';
  static const String cardPaymentDeviceSucceeded =
      'CARD_PAYMENT_DEVICE_SUCCEEDED';
  static const String cardPaymentFailed = 'CARD_PAYMENT_FAILED';
  static const String cardPaymentCancelled = 'CARD_PAYMENT_CANCELLED';

  static const String paymentReportStarted = 'PAYMENT_REPORT_STARTED';
  static const String paymentReportSucceeded = 'PAYMENT_REPORT_SUCCEEDED';
  static const String paymentReportFailed = 'PAYMENT_REPORT_FAILED';

  static const String orderFinalizeStarted = 'ORDER_FINALIZE_STARTED';
  static const String orderFinalizeSucceeded = 'ORDER_FINALIZE_SUCCEEDED';
  static const String orderFinalizeFailed = 'ORDER_FINALIZE_FAILED';
  static const String printStarted = 'PRINT_STARTED';
  static const String printDispatched = 'PRINT_DISPATCHED';
}

abstract final class PaymentFailureType {
  static const String network = 'network_error';
  static const String timeout = 'timeout';
  static const String deviceUnavailable = 'device_unavailable';
  static const String deviceRejected = 'device_rejected';
  static const String backendRejected = 'backend_rejected';
  static const String invalidResponse = 'invalid_response';
  static const String print = 'print_error';
  static const String unknown = 'unknown';
  static const String cashCapacity = 'cash_capacity';
}

class PaymentFlowTerminalGuard {
  String? _terminalEventCode;

  String? get terminalEventCode => _terminalEventCode;

  bool trySet(String eventCode) {
    if (_terminalEventCode != null) return false;
    _terminalEventCode = eventCode;
    return true;
  }
}

String paymentMethodName(String paymentMethodCode) {
  switch (paymentMethodCode) {
    case '0':
      return 'legacy';
    case '1':
      return 'cash';
    case '2':
      return 'qr';
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
    case '10':
      return 'credit_card';
    default:
      return 'unknown';
  }
}
