part of 'generalquiz_bloc.dart';

@immutable
sealed class GeneralquizEvent {}
final class GeneralQuizStartButtonPressesd extends GeneralquizEvent{
  String fromLang;
  String toLang;
  String difficulty;
  String numberofQuiz;
  GeneralQuizStartButtonPressesd({required this.fromLang,required this.toLang,required this.difficulty,required this.numberofQuiz});
}
