part of 'summary_fetch_bloc.dart';

@immutable
sealed class SummaryFetchEvent {}

final class SummaryFetchButtonPressed extends SummaryFetchEvent{
  String? topic;
  List<String>? words;
  String? targetLanguage;
  SummaryFetchButtonPressed({required this.topic,required this.words,required this.targetLanguage});
}
