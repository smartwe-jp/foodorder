import 'package:hive/hive.dart';

@HiveType(typeId: 61)
class PrintJob extends HiveObject {
  @HiveField(0)
  String jobBizId;

  @HiveField(1)
  String orderSnCode;

  @HiveField(2)
  String orderTime;

  @HiveField(3)
  String fromPlate;

  @HiveField(4)
  String orderType;

  @HiveField(5)
  List<String> taskIds;

  @HiveField(6)
  String status;

  @HiveField(7)
  int createdAt;

  @HiveField(8)
  int updatedAt;

  PrintJob({
    required this.jobBizId,
    required this.orderSnCode,
    required this.orderTime,
    required this.fromPlate,
    required this.orderType,
    required this.taskIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}

@HiveType(typeId: 62)
class PrintTask extends HiveObject {
  @HiveField(0)
  String taskId;

  @HiveField(1)
  String jobBizId;

  @HiveField(2)
  String itemBizId;

  @HiveField(3)
  String batchKey;

  @HiveField(4)
  int printerType;

  @HiveField(5)
  String printerIp;

  @HiveField(6)
  String mode; // label/continuous/single/center

  @HiveField(7)
  String taskKind; // item/center/label

  @HiveField(8)
  Map payload;

  @HiveField(9)
  String status; // pending/printing/success/failed

  @HiveField(10)
  int retryCount;

  @HiveField(11)
  String lastError;

  @HiveField(12)
  int createdAt;

  @HiveField(13)
  int updatedAt;

  PrintTask({
    required this.taskId,
    required this.jobBizId,
    required this.itemBizId,
    required this.batchKey,
    required this.printerType,
    required this.printerIp,
    required this.mode,
    required this.taskKind,
    required this.payload,
    required this.status,
    required this.retryCount,
    required this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
}

class PrintJobAdapter extends TypeAdapter<PrintJob> {
  @override
  final int typeId = 61;

  @override
  PrintJob read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrintJob(
      jobBizId: fields[0] as String,
      orderSnCode: fields[1] as String,
      orderTime: fields[2] as String,
      fromPlate: fields[3] as String,
      orderType: fields[4] as String,
      taskIds: (fields[5] as List).cast<String>(),
      status: fields[6] as String,
      createdAt: fields[7] as int,
      updatedAt: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PrintJob obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.jobBizId)
      ..writeByte(1)
      ..write(obj.orderSnCode)
      ..writeByte(2)
      ..write(obj.orderTime)
      ..writeByte(3)
      ..write(obj.fromPlate)
      ..writeByte(4)
      ..write(obj.orderType)
      ..writeByte(5)
      ..write(obj.taskIds)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }
}

class PrintTaskAdapter extends TypeAdapter<PrintTask> {
  @override
  final int typeId = 62;

  @override
  PrintTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PrintTask(
      taskId: fields[0] as String,
      jobBizId: fields[1] as String,
      itemBizId: fields[2] as String,
      batchKey: fields[3] as String,
      printerType: fields[4] as int,
      printerIp: fields[5] as String,
      mode: fields[6] as String,
      taskKind: fields[7] as String,
      payload: (fields[8] as Map),
      status: fields[9] as String,
      retryCount: fields[10] as int,
      lastError: fields[11] as String,
      createdAt: fields[12] as int,
      updatedAt: fields[13] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PrintTask obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.taskId)
      ..writeByte(1)
      ..write(obj.jobBizId)
      ..writeByte(2)
      ..write(obj.itemBizId)
      ..writeByte(3)
      ..write(obj.batchKey)
      ..writeByte(4)
      ..write(obj.printerType)
      ..writeByte(5)
      ..write(obj.printerIp)
      ..writeByte(6)
      ..write(obj.mode)
      ..writeByte(7)
      ..write(obj.taskKind)
      ..writeByte(8)
      ..write(obj.payload)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.retryCount)
      ..writeByte(11)
      ..write(obj.lastError)
      ..writeByte(12)
      ..write(obj.createdAt)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }
}
