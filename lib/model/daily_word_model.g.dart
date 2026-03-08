// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_word_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyWordModelAdapter extends TypeAdapter<DailyWordModel> {
  @override
  final int typeId = 5;

  @override
  DailyWordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return DailyWordModel(
      wordId:                  fields[0]  as String,
      word:                    fields[1]  as String,
      language:                fields[2]  as String,
      translation:             fields[3]  as String,
      pronunciation:           fields[4]  as String?,
      exampleSentenceEnglish:  fields[5]  as String? ?? '',
      exampleSentenceLearning: fields[6]  as String? ?? '',
      synonyms:                (fields[7]  as List?)?.cast<String>() ?? const [],
      antonyms:                (fields[8]  as List?)?.cast<String>() ?? const [],
      dateShown:               fields[9]  as DateTime? ?? DateTime.now(),
      englishMeaning:          fields[10] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, DailyWordModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.wordId)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.language)
      ..writeByte(3)
      ..write(obj.translation)
      ..writeByte(4)
      ..write(obj.pronunciation)
      ..writeByte(5)
      ..write(obj.exampleSentenceEnglish)
      ..writeByte(6)
      ..write(obj.exampleSentenceLearning)
      ..writeByte(7)
      ..write(obj.synonyms)
      ..writeByte(8)
      ..write(obj.antonyms)
      ..writeByte(9)
      ..write(obj.dateShown)
      ..writeByte(10)
      ..write(obj.englishMeaning);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyWordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DailyWordStreakAdapter extends TypeAdapter<DailyWordStreak> {
  @override
  final int typeId = 6;

  @override
  DailyWordStreak read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyWordStreak(
      currentStreak: fields[0] as int,
      lastViewDate: fields[1] as DateTime,
      longestStreak: fields[2] as int,
      learningLanguage: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DailyWordStreak obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.currentStreak)
      ..writeByte(1)
      ..write(obj.lastViewDate)
      ..writeByte(2)
      ..write(obj.longestStreak)
      ..writeByte(3)
      ..write(obj.learningLanguage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyWordStreakAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
