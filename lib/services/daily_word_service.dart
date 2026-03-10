import 'dart:convert';
import 'package:ai_text_to_speech/services/app_config.dart';
import 'package:http/http.dart' as http;
import '../model/daily_word_model.dart';

class DailyWordService {
  /// Fetches a new daily word.
  ///
  /// • [learningLanguage] – the language the user wants to learn (word is in this language).
  /// • [nativeLanguage]   – the language the user already knows (definition/meaning in this language).
  Future<DailyWordModel> fetchDailyWord({
    required String nativeLanguage,
    required String learningLanguage,
    required List<String> previousWordIds,
  }) async {
    const apiKey = AppConfig.openAiApiKey;
    if (apiKey.isEmpty) {
      throw 'OpenAI API key is missing. Build with --dart-define=OPENAI_API_KEY=your-key';
    }

    final prompt = '''You are a vocabulary teacher.

The user already knows **$nativeLanguage** and is learning **$learningLanguage**.

Generate ONE useful daily vocabulary word **in $learningLanguage**.

${previousWordIds.isNotEmpty ? 'DO NOT reuse these word IDs: ${previousWordIds.join(', ')}' : ''}

Requirements:
- The DAILY WORD must be in $learningLanguage (the language the user is learning).
- Provide a unique wordId (lowercase, underscores, based on the word).
- Provide pronunciation (IPA or phonetic) of the word in $learningLanguage.
- Provide a clear and simple definition of the word **in $nativeLanguage**.
- Provide the meaning / translation of the word **in $nativeLanguage**.
- Provide 1 short example sentence **in $learningLanguage** (MAX 10 words).
- Provide the translation of that example **in $nativeLanguage** (MAX 10 words).
- Provide 3-4 synonyms **in $learningLanguage**.
- Provide 3-4 antonyms **in $learningLanguage**.

Return ONLY valid JSON in this exact format (no markdown):
{
  "wordId": "example_word_id",
  "word": "<word in $learningLanguage>",
  "learningLanguage": "$learningLanguage",
  "nativeLanguage": "$nativeLanguage",
  "definitionInNative": "<clear definition in $nativeLanguage>",
  "meaningInNative": "<short meaning/translation in $nativeLanguage>",
  "pronunciation": "<IPA or phonetic>",
  "exampleInLearning": "<short example in $learningLanguage>",
  "exampleInNative": "<translation of example in $nativeLanguage>",
  "synonyms": ["syn1", "syn2", "syn3"],
  "antonyms": ["ant1", "ant2", "ant3"]
}

Rules:
- Both examples MUST be 10 words or less.
- Pick an intermediate-level word (not too easy, not too hard).
- Do NOT return markdown, only raw JSON.
- Do NOT add extra keys.
''';

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = jsonEncode({
      "model": "gpt-4o-mini",
      "messages": [
        {
          "role": "system",
          "content": "You return only valid JSON without markdown formatting."
        },
        {"role": "user", "content": prompt}
      ],
      "temperature": 0.8,
    });

    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final content = decoded['choices']?[0]?['message']?['content'];

        if (content == null || content.trim().isEmpty) {
          throw 'No content returned from API';
        }

        // Clean markdown formatting if present
        String cleanContent = content.trim();
        if (cleanContent.startsWith('```')) {
          cleanContent =
              cleanContent.replaceAll(RegExp(r'```json|```'), '').trim();
        }

        final wordJson = jsonDecode(cleanContent);

        return DailyWordModel(
          wordId: (wordJson['wordId'] ?? '').toString(),
          word: (wordJson['word'] ?? '').toString(),
          language:
              (wordJson['learningLanguage'] ?? learningLanguage).toString(),
          nativeLanguage:
              (wordJson['nativeLanguage'] ?? nativeLanguage).toString(),
          // Meaning in the user's native language
          translation: (wordJson['meaningInNative'] ?? '').toString(),
          // Definition in the user's native language
          englishMeaning: (wordJson['definitionInNative'] ?? '').toString(),
          pronunciation: wordJson['pronunciation']?.toString(),
          // Example in the learning language
          exampleSentenceEnglish:
              (wordJson['exampleInLearning'] ?? '').toString(),
          // Example in the native language
          exampleSentenceLearning:
              (wordJson['exampleInNative'] ?? '').toString(),
          synonyms: List<String>.from(
              (wordJson['synonyms'] ?? const []).map((e) => e.toString())),
          antonyms: List<String>.from(
              (wordJson['antonyms'] ?? const []).map((e) => e.toString())),
          dateShown: DateTime.now(),
        );
      } else {
        throw 'API error: ${response.statusCode}';
      }
    } catch (e) {
      throw 'Failed to fetch daily word: $e';
    }
  }
}
