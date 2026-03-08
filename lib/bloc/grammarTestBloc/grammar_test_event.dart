part of 'grammar_test_bloc.dart';

@immutable
sealed class GrammarTestEvent {}

final class GrammarTestStarted extends GrammarTestEvent {
  final String language;
  final String testType;
  final String count;
  GrammarTestStarted({
    required this.language,
    required this.testType,
    required this.count,
  });
}
