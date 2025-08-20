part of 'on_favourite_delete_bloc.dart';

@immutable
sealed class OnFavouriteDeleteEvent {}

final class OnFavouriteClearButtonPressed extends OnFavouriteDeleteEvent{}
