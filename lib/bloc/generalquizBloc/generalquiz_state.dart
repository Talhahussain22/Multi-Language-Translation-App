part of 'generalquiz_bloc.dart';

@immutable
sealed class GeneralquizState {}

final class GeneralquizInitial extends GeneralquizState {}

final class GeneralQuizLoadingState extends GeneralquizState{}
final class GeneralQuizLoadedState extends GeneralquizState{
  List<MCQQuestion>? mcqs;
  GeneralQuizLoadedState({required this.mcqs});
}
final class GeneralQuizErrorState extends GeneralquizState{
  String? error;
  GeneralQuizErrorState({required this.error});
}
