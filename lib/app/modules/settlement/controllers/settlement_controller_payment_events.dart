part of 'settlement_controller.dart';

final class _SettlementPaymentEventState {
  final String flowId = CustomLogHandler.newFlowId();
  final DateTime flowStartedAt = DateTime.now();
  final Map<String, DateTime> stageStartedAt = <String, DateTime>{};
  final PaymentFlowTerminalGuard terminalGuard = PaymentFlowTerminalGuard();
  bool cancelRequestReported = false;
  bool cashDenominationsFinalizedReported = false;
  int qrPaymentAttempt = 0;
  int posConnectAttempt = 0;
  int posConnectedAttempt = 0;
  String lastOrderFinalizeFailureType = PaymentFailureType.unknown;
}

extension SettlementControllerPaymentEvents on SettlementController {
  String get paymentFlowId => _paymentEventState.flowId;

  int get _qrPaymentAttempt => _paymentEventState.qrPaymentAttempt;
  set _qrPaymentAttempt(int value) =>
      _paymentEventState.qrPaymentAttempt = value;

  int get _posConnectAttempt => _paymentEventState.posConnectAttempt;
  set _posConnectAttempt(int value) =>
      _paymentEventState.posConnectAttempt = value;

  int get _posConnectedAttempt => _paymentEventState.posConnectedAttempt;
  set _posConnectedAttempt(int value) =>
      _paymentEventState.posConnectedAttempt = value;

  bool get _cancelRequestReported => _paymentEventState.cancelRequestReported;
  set _cancelRequestReported(bool value) =>
      _paymentEventState.cancelRequestReported = value;

  String get _lastOrderFinalizeFailureType =>
      _paymentEventState.lastOrderFinalizeFailureType;
  set _lastOrderFinalizeFailureType(String value) =>
      _paymentEventState.lastOrderFinalizeFailureType = value;

  Map<String, Object?> _paymentEventData({
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    return <String, Object?>{
      'order_id': orderId.value,
      'payment_method': paymentMethodName(machineInfo.paymentMethod),
      'payment_method_code': machineInfo.paymentMethod,
      'amount': int.tryParse(totalPrice.value),
      'is_scan_checkout': isScanCheckOut,
      ...data,
    };
  }

  void _paymentInfo(
    String eventCode,
    String message, {
    required String status,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    logI(
      message,
      tag: 'PaymentFlow',
      eventCode: eventCode,
      flowId: paymentFlowId,
      data: _paymentEventData(
        data: <String, Object?>{'event_status': status, ...data},
      ),
    );
  }

  void _paymentWarning(
    String eventCode,
    String message, {
    required String failureType,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    logW(
      message,
      tag: 'PaymentFlow',
      eventCode: eventCode,
      flowId: paymentFlowId,
      data: _paymentEventData(
        data: <String, Object?>{
          'event_status': 'failed',
          'failure_type': failureType,
          ...data,
        },
      ),
      error: error,
      stack: stackTrace,
    );
  }

  void _paymentCritical(
    String eventCode,
    String message, {
    required String failureType,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    incidentReporter.capture(
      eventCode: eventCode,
      message: message,
      flowId: paymentFlowId,
      data: _paymentEventData(
        data: <String, Object?>{
          'event_status': 'failed',
          'failure_type': failureType,
          ...data,
        },
      ),
      error: error,
      stackTrace: stackTrace,
    );
  }

  void _paymentStageStarted(
    String stage,
    String eventCode,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    _paymentEventState.stageStartedAt[stage] = DateTime.now();
    _paymentInfo(
      eventCode,
      message,
      status: 'started',
      data: <String, Object?>{'stage': stage, ...data},
    );
  }

  void _paymentStageSucceeded(
    String stage,
    String eventCode,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    final startedAt = _paymentEventState.stageStartedAt.remove(stage);
    _paymentInfo(
      eventCode,
      message,
      status: 'succeeded',
      data: <String, Object?>{
        'stage': stage,
        if (startedAt != null)
          'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
        ...data,
      },
    );
  }

  void _paymentStageFailed(
    String stage,
    String eventCode,
    String message, {
    required String failureType,
    bool critical = false,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    final startedAt = _paymentEventState.stageStartedAt.remove(stage);
    final eventData = <String, Object?>{
      'stage': stage,
      if (startedAt != null)
        'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
      ...data,
    };
    if (critical) {
      _paymentCritical(
        eventCode,
        message,
        failureType: failureType,
        error: error,
        stackTrace: stackTrace,
        data: eventData,
      );
    } else {
      _paymentWarning(
        eventCode,
        message,
        failureType: failureType,
        error: error,
        stackTrace: stackTrace,
        data: eventData,
      );
    }
  }

  void _paymentFlowSucceeded({required String completionStage}) {
    if (!_paymentEventState.terminalGuard.trySet(
      PaymentEventCode.flowSucceeded,
    )) {
      return;
    }
    _paymentInfo(
      PaymentEventCode.flowSucceeded,
      'Payment flow succeeded',
      status: 'succeeded',
      data: <String, Object?>{
        'stage': completionStage,
        'duration_ms': DateTime.now()
            .difference(_paymentEventState.flowStartedAt)
            .inMilliseconds,
      },
    );
  }

  void _paymentFlowFailed({
    required String failedStage,
    required String failureType,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_paymentEventState.terminalGuard.trySet(PaymentEventCode.flowFailed)) {
      return;
    }
    _paymentCritical(
      PaymentEventCode.flowFailed,
      'Payment flow failed',
      failureType: failureType,
      error: error,
      stackTrace: stackTrace,
      data: <String, Object?>{
        'stage': failedStage,
        'duration_ms': DateTime.now()
            .difference(_paymentEventState.flowStartedAt)
            .inMilliseconds,
      },
    );
  }

  void _paymentFlowCancelled({required String cancelledStage}) {
    if (!_paymentEventState.terminalGuard.trySet(PaymentEventCode.cancelled)) {
      return;
    }
    _paymentInfo(
      PaymentEventCode.cancelled,
      'Payment flow cancelled',
      status: 'cancelled',
      data: <String, Object?>{
        'stage': cancelledStage,
        'duration_ms': DateTime.now()
            .difference(_paymentEventState.flowStartedAt)
            .inMilliseconds,
      },
    );
  }

  void _reportPosConnected() {
    if (_posConnectedAttempt == _posConnectAttempt) return;
    _posConnectedAttempt = _posConnectAttempt;
    _paymentStageSucceeded(
      'pos_connect',
      PaymentEventCode.posConnectSucceeded,
      'POS connection succeeded',
      data: <String, Object?>{'attempt': _posConnectAttempt},
    );
  }

  void _reportCashDenominationsFinalized({
    required int operation,
    required String paymentInfo,
    required String changeInfo,
    required int? insertedAmount,
    required int? changeAmount,
  }) {
    if (_paymentEventState.cashDenominationsFinalizedReported) return;
    _paymentEventState.cashDenominationsFinalizedReported = true;

    final cashDevice = switch (machineInfo.cashMachineDriver) {
      CashMachineDriver.payCube => 'paycube',
      CashMachineDriver.cashChanger => 'glory',
      CashMachineDriver.none => 'none',
    };
    _paymentInfo(
      PaymentEventCode.cashDenominationsFinalized,
      'Cash denominations finalized',
      status: 'finalized',
      data: <String, Object?>{
        'cash_device': cashDevice,
        'operation': operation,
        'snapshot_kind': 'final',
        'payment_info': paymentInfo,
        'change_info': changeInfo,
        'inserted_amount': insertedAmount,
        'change_amount': changeAmount,
      },
    );
  }

  void monitorPaymentInfo(
    String eventCode,
    String message, {
    required String status,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    _paymentInfo(eventCode, message, status: status, data: data);
  }

  void monitorPaymentWarning(
    String eventCode,
    String message, {
    required String failureType,
    Object? error,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    _paymentWarning(
      eventCode,
      message,
      failureType: failureType,
      error: error,
      data: data,
    );
  }

  void monitorPaymentCritical(
    String eventCode,
    String message, {
    required String failureType,
    Object? error,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    _paymentCritical(
      eventCode,
      message,
      failureType: failureType,
      error: error,
      data: data,
    );
  }

  void monitorCashDenominationsFinalized({
    required int operation,
    required String paymentInfo,
    required String changeInfo,
    required int? insertedAmount,
    required int? changeAmount,
  }) {
    _reportCashDenominationsFinalized(
      operation: operation,
      paymentInfo: paymentInfo,
      changeInfo: changeInfo,
      insertedAmount: insertedAmount,
      changeAmount: changeAmount,
    );
  }

  void monitorPaymentStageStarted(
    String stage,
    String eventCode,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    _paymentStageStarted(stage, eventCode, message, data: data);
  }

  void monitorPaymentStageSucceeded(
    String stage,
    String eventCode,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    _paymentStageSucceeded(stage, eventCode, message, data: data);
  }

  void monitorPaymentStageFailed(
    String stage,
    String eventCode,
    String message, {
    required String failureType,
    bool critical = false,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    _paymentStageFailed(
      stage,
      eventCode,
      message,
      failureType: failureType,
      critical: critical,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  void monitorPaymentFlowSucceeded({required String completionStage}) {
    _paymentFlowSucceeded(completionStage: completionStage);
  }

  void monitorPaymentFlowFailed({
    required String failedStage,
    required String failureType,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _paymentFlowFailed(
      failedStage: failedStage,
      failureType: failureType,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void monitorPaymentFlowCancelled({required String cancelledStage}) {
    _paymentFlowCancelled(cancelledStage: cancelledStage);
  }
}
