part of 'daily_word_bloc.dart';

abstract class DailyWordEvent {}

class LoadDailyWord extends DailyWordEvent {
  final String language;
  LoadDailyWord(this.language);
}

class RefreshDailyWord extends DailyWordEvent {
  final String language;
  RefreshDailyWord(this.language);
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

