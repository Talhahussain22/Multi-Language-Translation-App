part of 'on_translate_bloc.dart';

@immutable
sealed class OnTranslateEvent {}

final class OnTranslateButtonClicked extends OnTranslateEvent{
  String text;
  String fromLanguage;
  String toLanguage;
  OnTranslateButtonClicked({required this.text,required this.fromLanguage,required this.toLanguage});
}
