part of 'generalquiz_bloc.dart';

@immutable
sealed class GeneralquizEvent {}

final class GeneralQuizStartButtonPressesd extends GeneralquizEvent {
  final String fromLang;
  final String toLang;
  final String difficulty;
  final String numberofQuiz;

  GeneralQuizStartButtonPressesd({
    required this.fromLang,
    required this.toLang,
    required this.difficulty,
    required this.numberofQuiz,
  });
}
