import 'package:dio/dio.dart';

import '../models/machine_activation.dart';
import 'HttpService.dart';

class MachineActivationRemoteService {
  Future<MachineActivation?> activate({
    required String machineCode,
    required String version,
  }) async {
    final response = await request(
      'webBootActivatev3',
      method: 'POST',
      parameters: {
        'machineCode': machineCode,
        'version': version,
      },
      timeout: const Duration(seconds: 10),
    );
    final payload = response is Response ? response.data : response;
    final result = MachineActivationResponse.fromPayload(payload);

    if (!result.hasData) return null;
    if (result.code != 200) {
      throw MachineActivationApiException(result.code, result.message);
    }
    return result.activation;
  }
}

class MachineActivationApiException implements Exception {
  const MachineActivationApiException(this.code, this.message);

  final int code;
  final String message;

  @override
  String toString() => 'MachineActivationApiException($code, $message)';
}
