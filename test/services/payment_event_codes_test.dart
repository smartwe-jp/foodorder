import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/services/payment_event_codes.dart';

void main() {
  test('maps configured payment method codes to stable names', () {
    expect(paymentMethodName('1'), 'cash');
    expect(paymentMethodName('2'), 'qr');
    expect(paymentMethodName('3'), 'credit_card');
    expect(paymentMethodName('10'), 'credit_card');
    expect(paymentMethodName('unsupported'), 'unknown');
  });

  test('terminal flow event codes are distinct', () {
    expect(
      {
        PaymentEventCode.flowSucceeded,
        PaymentEventCode.flowFailed,
        PaymentEventCode.cancelled,
      },
      hasLength(3),
    );
  });

  test('accepts only one terminal event for a payment flow', () {
    final guard = PaymentFlowTerminalGuard();

    expect(guard.trySet(PaymentEventCode.flowSucceeded), isTrue);
    expect(guard.trySet(PaymentEventCode.flowFailed), isFalse);
    expect(guard.trySet(PaymentEventCode.cancelled), isFalse);
    expect(guard.terminalEventCode, PaymentEventCode.flowSucceeded);
  });
}
