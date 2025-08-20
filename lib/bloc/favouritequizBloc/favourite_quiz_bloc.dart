import 'package:ai_text_to_speech/Utils/prompts.dart';
import 'package:ai_text_to_speech/model/gemini_response_model.dart';
import 'package:ai_text_to_speech/model/hive_model.dart';
import 'package:ai_text_to_speech/services/gemini_mcqs_generator.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'favourite_quiz_event.dart';
part 'favourite_quiz_state.dart';

class FavouriteQuizBloc extends Bloc<FavouriteQuizEvent, FavouriteQuizState> {
  FavouriteQuizBloc() : super(FavouriteQuizInitial()) {
    on<OnFavouriteQuizStartButtonPressed>((event, emit) async{
      List<FavoriteWord> words=event.words;
      emit(FavouriteQuizLoadingState());
      try
          {
            final GeminiMCQService geminiMCQService=GeminiMCQService();
            List<MCQQuestion>? mcqs=await geminiMCQService.generateMCQs(prompt_message:Prompts.favouriteQuizPrompt(words: words));
            return emit(FavouriteQuizLoadedState(mcqs: mcqs));
          }catch(e){
        return emit(FavouriteQuizErrorState(error: e.toString()));
      }
    });
  }
}
