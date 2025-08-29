// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoItemAdapter extends TypeAdapter<VideoItem> {
  @override
  final int typeId = 2;

  @override
  VideoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoItem(
      title: fields[0] as String,
      link: fields[1] as String,
      thumbnailUrl: fields[2] as String?,
      description: fields[3] as String?,
      id: fields[4] as String?,
      source: fields[5] as String?,
      pubDate: fields[6] as DateTime?,
      videoUrl: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.link)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.id)
      ..writeByte(5)
      ..write(obj.source)
      ..writeByte(6)
      ..write(obj.pubDate)
      ..writeByte(7)
      ..write(obj.videoUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
