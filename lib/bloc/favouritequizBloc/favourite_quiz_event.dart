part of 'favourite_quiz_bloc.dart';

@immutable
sealed class FavouriteQuizEvent {}

final class OnFavouriteQuizStartButtonPressed extends FavouriteQuizEvent {
  final List<FavoriteWord> words;
  OnFavouriteQuizStartButtonPressed({required this.words});
}
