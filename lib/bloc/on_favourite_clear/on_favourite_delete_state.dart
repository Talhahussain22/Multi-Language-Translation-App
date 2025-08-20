part of 'on_favourite_delete_bloc.dart';

@immutable
sealed class OnFavouriteDeleteState {}

final class OnFavouriteDeleteInitial extends OnFavouriteDeleteState {}

final class OnFavouriteDeleteLoadedState extends OnFavouriteDeleteState{}
