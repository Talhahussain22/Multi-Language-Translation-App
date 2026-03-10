import 'dart:convert';

import 'package:ai_text_to_speech/model/gemini_response_model.dart';
import 'package:ai_text_to_speech/Utils/prompts.dart';
import 'package:ai_text_to_speech/services/app_config.dart';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'grammar_test_event.dart';
part 'grammar_test_state.dart';

class GrammarTestBloc extends Bloc<GrammarTestEvent, GrammarTestState> {
  GrammarTestBloc() : super(GrammarTestInitial()) {
    on<GrammarTestStarted>((event, emit) async {
      emit(GrammarTestLoading());
      try {
        final questions = await _generateGrammarQuestions(
          language: event.language,
          testType: event.testType,
          count: event.count,
        );
        emit(GrammarTestLoaded(questions: questions));
      } catch (e) {
        emit(GrammarTestError(error: e.toString()));
      }
    });
  }

  Future<List<GrammarQuestion>> _generateGrammarQuestions({
    required String language,
    required String testType,
    required String count,
  }) async {
    const apiKey = AppConfig.openAiApiKey;
    if (apiKey.isEmpty) {
      throw 'OpenAI API key is missing. Build with --dart-define=OPENAI_API_KEY=your-key';
    }

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-4o-mini',
      'messages': [
        {
          'role': 'system',
          'content':
              'You are a grammar test generator. Output ONLY a valid JSON array matching the expected schema. No markdown, no prose.',
        },
        {
          'role': 'user',
          // Generate prompt based on selected test type
          'content': Prompts.grammarTestPrompt(
            count: count,
            language: language,
            testType: testType,
          ),
        }
      ],
    });

    const maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      attempt++;
      try {
        final response = await http
            .post(url, headers: headers, body: body)
            .timeout(const Duration(seconds: 30), onTimeout: () {
          throw 'Request timed out. Check your internet connection.';
        });

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final content = decoded['choices']?[0]?['message']?['content'];
          if (content is String && content.trim().isNotEmpty) {
            final cleaned = content
                .replaceAll('```json', '')
                .replaceAll('```', '')
                .trim();
            final dynamic parsed = jsonDecode(cleaned);
            if (parsed is List) {
              return parsed
                  .map((e) =>
                      GrammarQuestion.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
            throw 'Unexpected JSON shape — expected a list.';
          }
          throw 'No content returned from OpenAI.';
        } else if (response.statusCode == 429 || response.statusCode >= 500) {
          await Future.delayed(const Duration(seconds: 2));
        } else {
          throw 'API error ${response.statusCode}: ${response.body}';
        }
      } catch (e) {
        if (attempt >= maxRetries) rethrow;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw 'Try again in a few seconds.';
  }
}
