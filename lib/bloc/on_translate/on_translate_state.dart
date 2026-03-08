part of 'on_translate_bloc.dart';

@immutable
sealed class OnTranslateState {}

final class OnTranslateInitial extends OnTranslateState {}

final class OnTranslateLoadingState extends OnTranslateState {}

final class OnTranslateSuccessState extends OnTranslateState {
  final TranslationResult result;
  final bool? isfavourite;
  OnTranslateSuccessState({required this.result, this.isfavourite});
}

final class OnTranslateFailureState extends OnTranslateState {
  final String error;
  OnTranslateFailureState({required this.error});
}