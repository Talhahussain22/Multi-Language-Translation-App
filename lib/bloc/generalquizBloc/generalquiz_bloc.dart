import 'package:ai_text_to_speech/Utils/prompts.dart';
import 'package:ai_text_to_speech/model/gemini_response_model.dart';
import 'package:ai_text_to_speech/services/openai_mcqs_generator.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'generalquiz_event.dart';
part 'generalquiz_state.dart';

class GeneralquizBloc extends Bloc<GeneralquizEvent, GeneralquizState> {
  GeneralquizBloc() : super(GeneralquizInitial()) {
    on<GeneralQuizStartButtonPressesd>((event, emit) async{
      String fromLang=event.fromLang;
      String toLang=event.toLang;
      String difficulty=event.difficulty;
      String numberofQuiz=event.numberofQuiz;

      emit(GeneralQuizLoadingState());
      try
          {
            final openai = OpenAIMCQService();
            List<MCQQuestion>? mcqs=await openai.generateMCQs(prompt_message: Prompts.generalmcqsprompt(count: numberofQuiz, fromLang: fromLang, toLang: toLang, mcqslevel: difficulty));
            return emit(GeneralQuizLoadedState(mcqs: mcqs));
          }catch(e){
        emit(GeneralQuizErrorState(error: e.toString()));
      }
    });
  }
}
