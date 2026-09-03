import 'package:flutter_test/flutter_test.dart';
import 'package:foodorder/app/services/cash_monitoring_events.dart';

void main() {
  group('CashMonitoringEvents', () {
    test('normalizes input and payout codes into yen denominations', () {
      expect(
        CashMonitoringEvents.normalizeCodeCounts(<String, Object>{
          '61': 6,
          '65': '2',
          '87': 1,
          'A1': 4,
          'A5': 3,
          'invalid': 10,
        }),
        <String, int>{
          '1': 10,
          '100': 5,
          '1000': 1,
        },
      );
    });

    test('builds a signed delta from inserted and dispensed movements', () {
      expect(
        CashMonitoringEvents.movementDelta(
          puts: const <Map<String, Object>>[
            <String, Object>{'catVal': '65', 'val': 2},
            <String, Object>{'catVal': '87', 'val': 1},
          ],
          pops: const <Map<String, Object>>[
            <String, Object>{'catVal': 'A1', 'val': 6},
            <String, Object>{'catVal': 'A5', 'val': 1},
          ],
        ),
        <String, int>{
          '100': 1,
          '1000': 1,
          '1': -6,
        },
      );
    });
  });
}
