// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationItemAdapter extends TypeAdapter<NotificationItem> {
  @override
  final int typeId = 1;

  @override
  NotificationItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationItem(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      payload: fields[3] as String,
      date: fields[4] as DateTime,
      isRead: fields[5] as bool,
      type: fields[6] as String,
      imageUrl: fields[7] as String?,
      link: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NotificationItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.payload)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.isRead)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.imageUrl)
      ..writeByte(8)
      ..write(obj.link);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
