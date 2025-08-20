// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteWordAdapter extends TypeAdapter<FavoriteWord> {
  @override
  final int typeId = 0;

  @override
  FavoriteWord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteWord(
      word: fields[0] as String,
      translation: fields[1] as String,
      fromLanguage: fields[2] as String,
      toLanguage: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteWord obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.translation)
      ..writeByte(2)
      ..write(obj.fromLanguage)
      ..writeByte(3)
      ..write(obj.toLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteWordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
