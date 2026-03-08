import 'package:hive_flutter/adapters.dart';

part 'daily_word_model.g.dart';

@HiveType(typeId: 5)
class DailyWordModel extends HiveObject {
  @HiveField(0)
  final String wordId;

  @HiveField(1)
  final String word;

  @HiveField(2)
  final String language;

  @HiveField(3)
  final String translation;

  @HiveField(4)
  final String? pronunciation;

  @HiveField(5)
  final String exampleSentenceEnglish;

  @HiveField(6)
  final String exampleSentenceLearning;

  @HiveField(7)
  final List<String> synonyms;

  @HiveField(8)
  final List<String> antonyms;

  @HiveField(9)
  final DateTime dateShown;

  @HiveField(10)
  final String englishMeaning;

  DailyWordModel({
    required this.wordId,
    required this.word,
    required this.language,
    required this.translation,
    this.pronunciation,
    required this.exampleSentenceEnglish,
    required this.exampleSentenceLearning,
    required this.synonyms,
    required this.antonyms,
    required this.dateShown,
    required this.englishMeaning,
  });

  Map<String, dynamic> toJson() => {
        'wordId': wordId,
        'word': word,
        'language': language,
        'translation': translation,
        'pronunciation': pronunciation,
        'exampleSentenceEnglish': exampleSentenceEnglish,
        'exampleSentenceLearning': exampleSentenceLearning,
        'synonyms': synonyms,
        'antonyms': antonyms,
        'dateShown': dateShown.toIso8601String(),
        'englishMeaning': englishMeaning,
      };

  factory DailyWordModel.fromJson(Map<String, dynamic> json) => DailyWordModel(
        wordId: json['wordId'],
        word: json['word'],
        language: json['language'],
        translation: json['translation'],
        pronunciation: json['pronunciation'],
        exampleSentenceEnglish: json['exampleSentenceEnglish'] ?? (json['exampleSentence'] ?? ''),
        exampleSentenceLearning: json['exampleSentenceLearning'] ?? '',
        synonyms: List<String>.from(json['synonyms']),
        antonyms: List<String>.from(json['antonyms']),
        dateShown: DateTime.parse(json['dateShown']),
        englishMeaning: json['englishMeaning'] ?? '',
      );
}

@HiveType(typeId: 6)
class DailyWordStreak extends HiveObject {
  @HiveField(0)
  int currentStreak;

  @HiveField(1)
  DateTime lastViewDate;

  @HiveField(2)
  int longestStreak;

  @HiveField(3)
  String learningLanguage;

  DailyWordStreak({
    required this.currentStreak,
    required this.lastViewDate,
    required this.longestStreak,
    required this.learningLanguage,
  });
}
