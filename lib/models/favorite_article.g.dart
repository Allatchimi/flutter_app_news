// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteArticleAdapter extends TypeAdapter<FavoriteArticle> {
  @override
  final int typeId = 0;

  @override
  FavoriteArticle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteArticle(
      title: fields[0] as String,
      link: fields[1] as String,
      author: fields[2] as String,
      date: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteArticle obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.link)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
