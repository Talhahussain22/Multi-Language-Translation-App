part of 'on_translate_bloc.dart';

@immutable
sealed class OnTranslateEvent {}

final class OnTranslateButtonClicked extends OnTranslateEvent {
  final String text;
  final String fromLanguage;
  final String toLanguage;
  OnTranslateButtonClicked({required this.text, required this.fromLanguage, required this.toLanguage});
}
