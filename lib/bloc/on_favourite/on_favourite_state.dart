part of 'on_favourite_bloc.dart';

@immutable
sealed class OnFavouriteState {}

final class OnFavouriteInitial extends OnFavouriteState {}

final class OnFavouriteSuccess extends OnFavouriteState {
  final bool isFavourited;
  OnFavouriteSuccess({required this.isFavourited});
}
