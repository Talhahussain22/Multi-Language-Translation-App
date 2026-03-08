part of 'daily_word_bloc.dart';

abstract class DailyWordEvent {}

class LoadDailyWord extends DailyWordEvent {
  final String nativeLanguage;
  final String learningLanguage;
  LoadDailyWord({required this.nativeLanguage, required this.learningLanguage});
}

class RefreshDailyWord extends DailyWordEvent {
  final String nativeLanguage;
  final String learningLanguage;
  RefreshDailyWord({required this.nativeLanguage, required this.learningLanguage});
}

class SaveDailyWordToFavorites extends DailyWordEvent {
  final String word;
  final String translation;
  final String fromLanguage;
  SaveDailyWordToFavorites({
    required this.word,
    required this.translation,
    required this.fromLanguage,
  });
}

