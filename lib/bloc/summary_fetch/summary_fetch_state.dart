part of 'summary_fetch_bloc.dart';

@immutable
sealed class SummaryFetchState {}

final class SummaryFetchInitial extends SummaryFetchState {}

final class SummaryFetchLoadingState extends SummaryFetchState{}

final class SummaryFetchLoadedState extends SummaryFetchState{
  String? text;
  SummaryFetchLoadedState({required this.text});
}

final class SummaryFetchErrorState extends SummaryFetchState{
  String? error;
  SummaryFetchErrorState({required this.error});
}
