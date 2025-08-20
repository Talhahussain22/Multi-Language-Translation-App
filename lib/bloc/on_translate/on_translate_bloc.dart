import 'package:ai_text_to_speech/model/history_model.dart';
import 'package:ai_text_to_speech/services/network_services.dart';
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import '../../model/hive_model.dart';

part 'on_translate_event.dart';
part 'on_translate_state.dart';

class OnTranslateBloc extends Bloc<OnTranslateEvent, OnTranslateState> {
  final NetworkServices networkServices;
  OnTranslateBloc(this.networkServices) : super(OnTranslateInitial()) {
    on<OnTranslateButtonClicked>((event, emit) async{
      final favBox=Hive.box<FavoriteWord>('favourites');
      emit(OnTranslateLoadingState());
      try
      {
        final text=event.text;
        final fromLanguage=event.fromLanguage;
        final toLanguage=event.toLanguage;
        NetworkServices network_sevices=NetworkServices();
        String output= await network_sevices.streamTranslate(text,toLanguage,fromLanguage);

        final hivebox=Hive.box<HistoryModel>('History');
        hivebox.add(HistoryModel(word: text, translation: output, fromLanguage: fromLanguage, toLanguage: toLanguage));
        final keyAvailiable = favBox.keys.firstWhere(
                (key) {
              final item = favBox.get(key);
              return item?.word.toUpperCase() == text.toUpperCase() && item?.translation.toUpperCase()==output.toUpperCase();
            },
            orElse: ()=>null
        );

        if(keyAvailiable!=null)
          {
            return emit(OnTranslateSuccessState(data: output,isfavourite: true));
          }
       return emit(OnTranslateSuccessState(data: output,isfavourite: false));

      }catch(e)
      {
        return emit(OnTranslateFailureState(error: e.toString()));
      }
    });
  }
}
