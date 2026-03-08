part of 'generalquiz_bloc.dart';

@immutable
sealed class GeneralquizState {}

final class GeneralquizInitial extends GeneralquizState {
  GeneralquizInitial();
}

final class GeneralQuizLoadingState extends GeneralquizState {
  GeneralQuizLoadingState();
}

final class GeneralQuizLoadedState extends GeneralquizState {
  final List<MCQQuestion>? mcqs;
  GeneralQuizLoadedState({required this.mcqs});
}

final class GeneralQuizErrorState extends GeneralquizState {
  final String? error;
  GeneralQuizErrorState({required this.error});
}
