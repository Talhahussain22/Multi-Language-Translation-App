import 'package:ai_text_to_speech/Utils/prompts.dart';
import 'package:ai_text_to_speech/model/history_model.dart';
import 'package:ai_text_to_speech/model/translation_result.dart';
import 'package:ai_text_to_speech/services/openai_translate.dart';
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
    on<OnTranslateButtonClicked>((event, emit) async {
      final favBox = Hive.box<FavoriteWord>('favourites');
      emit(OnTranslateLoadingState());
      try {
        final text = event.text;
        final fromLanguage = event.fromLanguage;
        final toLanguage = event.toLanguage;

        final TranslationResult result = await OpenAITranslate().TranslateWord(
          prompt_message: Prompts.translateText(
            word: text,
            toLang: toLanguage,
            fromLang: fromLanguage,
          ),
        );

        // Save a compact representation to Hive history
        final historyString = result.historyString;
        final hivebox = Hive.box<HistoryModel>('History');
        hivebox.add(HistoryModel(
          word: text,
          translation: historyString,
          fromLanguage: fromLanguage,
          toLanguage: toLanguage,
        ));

        // Check if this word is already favourited
        final keyAvailable = favBox.keys.firstWhere(
          (key) {
            final item = favBox.get(key);
            return item?.word.toUpperCase() == text.toUpperCase() &&
                item?.translation.toUpperCase() ==
                    historyString.toUpperCase();
          },
          orElse: () => null,
        );

        if (keyAvailable != null) {
          return emit(
              OnTranslateSuccessState(result: result, isfavourite: true));
        }
        return emit(
            OnTranslateSuccessState(result: result, isfavourite: false));
      } catch (e) {
        return emit(OnTranslateFailureState(error: e.toString()));
      }
    });
  }
}
