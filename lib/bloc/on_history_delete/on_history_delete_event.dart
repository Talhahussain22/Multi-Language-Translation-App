part of 'on_history_delete_bloc.dart';

@immutable
sealed class OnHistoryDeleteEvent {}

final class OnHistoryLoaded extends OnHistoryDeleteEvent{}

final class OnHistoryDeleteButtonPress extends OnHistoryDeleteEvent{
int index;
OnHistoryDeleteButtonPress({required this.index});
}

final class OnHistoryClearButtonPress extends OnHistoryDeleteEvent{}
