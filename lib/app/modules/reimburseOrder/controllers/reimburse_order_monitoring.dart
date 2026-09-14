part of 'reimburse_order_controller.dart';

final class _RefundEventState {
  String flowId = CustomLogHandler.newFlowId();
  DateTime startedAt = DateTime.now();
  final Map<String, DateTime> stageStartedAt = <String, DateTime>{};
  final PaymentFlowTerminalGuard terminalGuard = PaymentFlowTerminalGuard();
  String? lastDenominationMismatch;
}

extension ReimburseOrderMonitoring on ReimburseOrderController {
  Map<String, Object?> _refundEventData({
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    final amount = refundInfo['amount'];
    return <String, Object?>{
      'order_id': refundInfo['orderId'],
      'refund_method': refundInfo['payChannel']?.toString().toLowerCase(),
      'amount': amount is num ? amount : num.tryParse(amount?.toString() ?? ''),
      ...data,
    };
  }

  void startRefundMonitoring() {
    _refundEventState = _RefundEventState();
    monitorRefundInfo(
      PaymentEventCode.refundFlowStarted,
      'Refund flow started',
      status: 'started',
      data: const <String, Object?>{'stage': 'refund'},
    );
  }

  void monitorRefundInfo(
    String eventCode,
    String message, {
    required String status,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    logI(
      message,
      upload: true,
      tag: 'RefundFlow',
      eventCode: eventCode,
      flowId: _refundEventState.flowId,
      data: _refundEventData(
        data: <String, Object?>{'event_status': status, ...data},
      ),
    );
  }

  void monitorRefundWarning(
    String eventCode,
    String message, {
    required String failureType,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    logW(
      message,
      upload: true,
      tag: 'RefundFlow',
      eventCode: eventCode,
      flowId: _refundEventState.flowId,
      data: _refundEventData(
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

  void monitorRefundCritical(
    String eventCode,
    String message, {
    required String failureType,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    logE(
      message,
      upload: true,
      tag: 'RefundFlow',
      eventCode: eventCode,
      flowId: _refundEventState.flowId,
      data: _refundEventData(
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

  void monitorRefundStageStarted(
    String stage,
    String eventCode,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    _refundEventState.stageStartedAt[stage] = DateTime.now();
    monitorRefundInfo(
      eventCode,
      message,
      status: 'started',
      data: <String, Object?>{'stage': stage, ...data},
    );
  }

  void monitorRefundStageSucceeded(
    String stage,
    String eventCode,
    String message, {
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    final startedAt = _refundEventState.stageStartedAt.remove(stage);
    monitorRefundInfo(
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

  void monitorRefundStageFailed(
    String stage,
    String eventCode,
    String message, {
    required String failureType,
    bool critical = false,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> data = const <String, Object?>{},
  }) {
    final startedAt = _refundEventState.stageStartedAt.remove(stage);
    final eventData = <String, Object?>{
      'stage': stage,
      if (startedAt != null)
        'duration_ms': DateTime.now().difference(startedAt).inMilliseconds,
      ...data,
    };
    if (critical) {
      monitorRefundCritical(
        eventCode,
        message,
        failureType: failureType,
        error: error,
        stackTrace: stackTrace,
        data: eventData,
      );
    } else {
      monitorRefundWarning(
        eventCode,
        message,
        failureType: failureType,
        error: error,
        stackTrace: stackTrace,
        data: eventData,
      );
    }
  }

  void monitorRefundFlowSucceeded({required String completionStage}) {
    if (!_refundEventState.terminalGuard.trySet(
      PaymentEventCode.refundFlowSucceeded,
    )) {
      return;
    }
    monitorRefundInfo(
      PaymentEventCode.refundFlowSucceeded,
      'Refund flow succeeded',
      status: 'succeeded',
      data: <String, Object?>{
        'stage': completionStage,
        'duration_ms': DateTime.now()
            .difference(_refundEventState.startedAt)
            .inMilliseconds,
      },
    );
  }

  void monitorRefundFlowFailed({
    required String failedStage,
    required String failureType,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_refundEventState.terminalGuard.trySet(
      PaymentEventCode.refundFlowFailed,
    )) {
      return;
    }
    monitorRefundCritical(
      PaymentEventCode.refundFlowFailed,
      'Refund flow failed',
      failureType: failureType,
      error: error,
      stackTrace: stackTrace,
      data: <String, Object?>{
        'stage': failedStage,
        'duration_ms': DateTime.now()
            .difference(_refundEventState.startedAt)
            .inMilliseconds,
      },
    );
  }
}
