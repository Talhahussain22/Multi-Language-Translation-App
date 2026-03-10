part of 'on_favourite_bloc.dart';

@immutable
sealed class OnFavouriteEvent {}

final class OnFavouriteButtonClicked extends OnFavouriteEvent {
  final FavoriteWord favoriteWord;
  OnFavouriteButtonClicked({required this.favoriteWord});
}
