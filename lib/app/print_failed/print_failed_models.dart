import 'dart:typed_data';

import 'package:hive/hive.dart';

@HiveType(typeId: 63)
class PrintRecord extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  int printerType;

  @HiveField(2)
  String printerIp;

  @HiveField(3)
  List<Uint8List> printData;

  @HiveField(4)
  Map printInfo;

  @HiveField(5)
  int createdAt;

  @HiveField(6)
  int updatedAt;

  @HiveField(7)
  int retryCount;

  @HiveField(8)
  String lastError;

  @HiveField(9)
  String status; // pending/success/failed

  PrintRecord({
    required this.uuid,
    required this.printerType,
    required this.printerIp,
    required this.printData,
    required this.printInfo,
    required this.createdAt,
    required this.updatedAt,
    required this.retryCount,
    required this.lastError,
    required this.status,
  });
}

class PrintRecordAdapter extends TypeAdapter<PrintRecord> {
  @override
  final int typeId = 63;

  @override
  PrintRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrintRecord(
      uuid: fields[0] as String,
      printerType: fields[1] as int,
      printerIp: fields[2] as String,
      printData: (fields[3] as List).cast<Uint8List>(),
      printInfo: (fields[4] as Map),
      createdAt: fields[5] as int,
      updatedAt: fields[6] as int,
      retryCount: fields[7] as int,
      lastError: fields[8] as String,
      status: (fields[9] as String?) ?? 'pending',
    );
  }

  @override
  void write(BinaryWriter writer, PrintRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.printerType)
      ..writeByte(2)
      ..write(obj.printerIp)
      ..writeByte(3)
      ..write(obj.printData)
      ..writeByte(4)
      ..write(obj.printInfo)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.retryCount)
      ..writeByte(8)
      ..write(obj.lastError)
      ..writeByte(9)
      ..write(obj.status);
  }
}
