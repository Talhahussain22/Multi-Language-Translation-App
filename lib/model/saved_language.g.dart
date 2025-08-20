// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_language.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedLanguageAdapter extends TypeAdapter<SavedLanguage> {
  @override
  final int typeId = 3;

  @override
  SavedLanguage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedLanguage(
      fromLanguage: (fields[0] as Map?)?.cast<String, String>(),
      toLanguage: (fields[1] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, SavedLanguage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.fromLanguage)
      ..writeByte(1)
      ..write(obj.toLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedLanguageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
