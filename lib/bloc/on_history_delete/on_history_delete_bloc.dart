import 'package:ai_text_to_speech/model/history_model.dart';
import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

part 'on_history_delete_event.dart';
part 'on_history_delete_state.dart';

class OnHistoryDeleteBloc extends Bloc<OnHistoryDeleteEvent, OnHistoryDeleteState> {
  OnHistoryDeleteBloc() : super(OnHistoryDeleteInitial()) {
    on<OnHistoryLoaded>((event,emit){
      final hivebox=Hive.box<HistoryModel>('History');
      List<HistoryModel> favouriteword=hivebox.values.toList();
      List<HistoryModel>? sortedFavouritedWords=favouriteword.reversed.toList();
      emit(OnHistoryLoadedState(history: sortedFavouritedWords));
    });

    on<OnHistoryDeleteButtonPress>((event, emit){
      final hivebox=Hive.box<HistoryModel>('History');
      hivebox.deleteAt(event.index);
      emit(OnHistoryLoadedState(history:hivebox.values.toList() ));
    });
    on<OnHistoryClearButtonPress>((event,emit)async{
      final hivebox=Hive.box<HistoryModel>('History');
     await hivebox.clear();
      emit(OnHistoryLoadedState(history: hivebox.values.toList()));
    });
  }

}
