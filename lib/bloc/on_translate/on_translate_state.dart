part of 'on_translate_bloc.dart';

@immutable
sealed class OnTranslateState {}

final class OnTranslateInitial extends OnTranslateState {}

final class OnTranslateLoadingState extends OnTranslateState{}

final class OnTranslateSuccessState extends OnTranslateState{
  String data;
  bool? isfavourite;
  OnTranslateSuccessState({required this.data,this.isfavourite});
}

final class OnTranslateFailureState extends OnTranslateState{
  String error;
  OnTranslateFailureState({required this.error});
}