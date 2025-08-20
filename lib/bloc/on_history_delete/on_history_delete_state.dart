part of 'on_history_delete_bloc.dart';

@immutable
sealed class OnHistoryDeleteState {}

final class OnHistoryDeleteInitial extends OnHistoryDeleteState {}

final class OnHistoryLoadedState extends OnHistoryDeleteState{
  List<HistoryModel> history;
  OnHistoryLoadedState({required this.history});
}
