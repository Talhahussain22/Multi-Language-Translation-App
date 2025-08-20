import 'package:ai_text_to_speech/services/gemini_summary_generator.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'summary_fetch_event.dart';
part 'summary_fetch_state.dart';

class SummaryFetchBloc extends Bloc<SummaryFetchEvent, SummaryFetchState> {
  SummaryFetchBloc() : super(SummaryFetchInitial()) {
    on<SummaryFetchButtonPressed>((event, emit) async{
      String? topic=event.topic;
      List<String>? words=event.words;
      String? targetLang=event.targetLanguage;
      emit(SummaryFetchLoadingState());
      try
          {

            final GeminiSummary geminiSummary=GeminiSummary();
            String? output=await geminiSummary.getSummary(topic: topic??'How to become rich', words: words??['money','thinking'], targetLanguage: targetLang??'English');

            return emit(SummaryFetchLoadedState(text: output));
          }
          catch(e){

            await Future.delayed(Duration(seconds: 2));
       return emit(SummaryFetchErrorState(error: e.toString()));
      }
    });
  }
}
