enum CashMachineDriver {
  payCube,
  cashChanger,
  none,
}

class MachineCapabilities {
  const MachineCapabilities({
    required this.machineModelCode,
    required this.cashMachineDriver,
    required this.isKnownModel,
  });

  final String machineModelCode;
  final CashMachineDriver cashMachineDriver;
  final bool isKnownModel;

  bool get supportsCashMachine => cashMachineDriver != CashMachineDriver.none;
}

class MachineCapabilitiesResolver {
  const MachineCapabilitiesResolver();

  MachineCapabilities resolve(String machineModelCode) {
    final normalizedCode = machineModelCode.trim().toUpperCase();
    switch (normalizedCode) {
      case 'SWF1':
      case 'SWF2':
        return MachineCapabilities(
          machineModelCode: normalizedCode,
          cashMachineDriver: CashMachineDriver.payCube,
          isKnownModel: true,
        );
      case 'SWFG':
        return MachineCapabilities(
          machineModelCode: normalizedCode,
          cashMachineDriver: CashMachineDriver.cashChanger,
          isKnownModel: true,
        );
      case 'SWFX':
        return MachineCapabilities(
          machineModelCode: normalizedCode,
          cashMachineDriver: CashMachineDriver.none,
          isKnownModel: true,
        );
      default:
        return MachineCapabilities(
          machineModelCode: normalizedCode,
          cashMachineDriver: CashMachineDriver.none,
          isKnownModel: false,
        );
    }
  }
}
