import '../models/machine_activation.dart';
import '../services/machine_activation_local_service.dart';
import '../services/machine_activation_remote_service.dart';

class MachineActivationRepository {
  MachineActivationRepository({
    MachineActivationRemoteService? remoteService,
    MachineActivationLocalService? localService,
  })  : _remoteService = remoteService ?? MachineActivationRemoteService(),
        _localService = localService ?? MachineActivationLocalService();

  final MachineActivationRemoteService _remoteService;
  final MachineActivationLocalService _localService;

  Future<MachineActivation?> activate({
    required String machineCode,
    required String version,
  }) async {
    final activation = await _remoteService.activate(
      machineCode: machineCode,
      version: version,
    );
    if (activation != null) {
      await _localService.save(activation);
    }
    return activation;
  }

  Future<MachineActivation?> loadCached() => _localService.load();
}
