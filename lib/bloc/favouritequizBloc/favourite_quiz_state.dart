part of 'favourite_quiz_bloc.dart';

@immutable
sealed class FavouriteQuizState {}

final class FavouriteQuizInitial extends FavouriteQuizState {
  FavouriteQuizInitial();
}

final class FavouriteQuizLoadingState extends FavouriteQuizState {
  FavouriteQuizLoadingState();
}

final class FavouriteQuizLoadedState extends FavouriteQuizState {
  final List<MCQQuestion>? mcqs;
  FavouriteQuizLoadedState({required this.mcqs});
}

final class FavouriteQuizErrorState extends FavouriteQuizState {
  final String error;
  FavouriteQuizErrorState({required this.error});
}
