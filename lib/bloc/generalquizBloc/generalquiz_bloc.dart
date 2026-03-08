import 'package:ai_text_to_speech/Utils/prompts.dart';
import 'package:ai_text_to_speech/model/gemini_response_model.dart';
import 'package:ai_text_to_speech/services/openai_mcqs_generator.dart';
import 'package:ai_text_to_speech/services/quiz_word_history_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'generalquiz_event.dart';
part 'generalquiz_state.dart';

class GeneralquizBloc extends Bloc<GeneralquizEvent, GeneralquizState> {
  final _historyService = QuizWordHistoryService();

  GeneralquizBloc() : super(GeneralquizInitial()) {
    on<GeneralQuizStartButtonPressesd>((event, emit) async {
      final String fromLang = event.fromLang;
      final String toLang = event.toLang;
      final String difficulty = event.difficulty;
      final String numberofQuiz = event.numberofQuiz;

      emit(GeneralQuizLoadingState());

      try {
        // Load words already used for this language-pair + difficulty
        final usedWords = await _historyService.getUsedWords(
          fromLang: fromLang,
          toLang: toLang,
          difficulty: difficulty,
        );

        final isEnglishMode = toLang.toLowerCase() == 'english';

        final openai = OpenAIMCQService();
        final List<MCQQuestion>? mcqs = await openai.generateMCQs(
          prompt_message: isEnglishMode
              ? Prompts.englishDefinitionQuizPrompt(
                  count: numberofQuiz,
                  mcqslevel: difficulty,
                  usedWords: usedWords.toList(),
                )
              : Prompts.generalmcqsprompt(
                  count: numberofQuiz,
                  fromLang: fromLang,
                  toLang: toLang,
                  mcqslevel: difficulty,
                  usedWords: usedWords.toList(),
                ),
        );

        // Persist the new question words so they won't be repeated next time
        if (mcqs != null && mcqs.isNotEmpty) {
          await _historyService.addUsedWords(
            fromLang: fromLang,
            toLang: toLang,
            difficulty: difficulty,
            words: mcqs.map((q) => q.question).toList(),
          );
        }

        return emit(GeneralQuizLoadedState(mcqs: mcqs));
      } catch (e) {
        emit(GeneralQuizErrorState(error: e.toString()));
      }
    });
  }
}
