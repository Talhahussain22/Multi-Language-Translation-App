part of 'daily_word_bloc.dart';

abstract class DailyWordState {}

class DailyWordInitial extends DailyWordState {}

class DailyWordLoading extends DailyWordState {}

class DailyWordLoaded extends DailyWordState {
  final DailyWordModel currentWord;
  final List<DailyWordModel> previousWords;
  final int currentStreak;
  final int longestStreak;
  final bool isSaved;

  DailyWordLoaded({
    required this.currentWord,
    required this.previousWords,
    required this.currentStreak,
    required this.longestStreak,
    this.isSaved = false,
  });

  DailyWordLoaded copyWith({
    DailyWordModel? currentWord,
    List<DailyWordModel>? previousWords,
    int? currentStreak,
    int? longestStreak,
    bool? isSaved,
  }) {
    return DailyWordLoaded(
      currentWord: currentWord ?? this.currentWord,
      previousWords: previousWords ?? this.previousWords,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class DailyWordError extends DailyWordState {
  final String message;
  DailyWordError(this.message);
}

class DailyWordSaved extends DailyWordState {}

