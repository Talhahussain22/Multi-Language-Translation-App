part of 'on_favourite_bloc.dart';

@immutable
sealed class OnFavouriteEvent {}

class OnFavouriteButtonClicked extends OnFavouriteEvent{
  FavoriteWord favoriteWord;
  OnFavouriteButtonClicked({required this.favoriteWord});
}
