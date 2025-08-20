part of 'favourite_quiz_bloc.dart';

@immutable
sealed class FavouriteQuizState {}

final class FavouriteQuizInitial extends FavouriteQuizState {}

final class FavouriteQuizLoadingState extends FavouriteQuizState{}

final class FavouriteQuizLoadedState extends FavouriteQuizState{
  List<MCQQuestion>? mcqs;
  FavouriteQuizLoadedState({required this.mcqs});
}

final class FavouriteQuizErrorState extends FavouriteQuizState{
  String error;
  FavouriteQuizErrorState({required this.error});
}
