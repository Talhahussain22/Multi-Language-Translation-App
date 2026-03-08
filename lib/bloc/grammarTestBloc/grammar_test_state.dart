part of 'grammar_test_bloc.dart';

@immutable
sealed class GrammarTestState {}

final class GrammarTestInitial extends GrammarTestState {}

final class GrammarTestLoading extends GrammarTestState {}

final class GrammarTestLoaded extends GrammarTestState {
  final List<GrammarQuestion> questions;
  GrammarTestLoaded({required this.questions});
}

final class GrammarTestError extends GrammarTestState {
  final String error;
  GrammarTestError({required this.error});
}
