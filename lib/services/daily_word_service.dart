import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/daily_word_model.dart';

class DailyWordService {
  /// Fetches a new daily word for the specified language
  Future<DailyWordModel> fetchDailyWord({
    required String language,
    required List<String> previousWordIds,
  }) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'] ?? dotenv.env['APIKEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw 'OpenAI API key is missing';
    }

    final prompt = '''You are a vocabulary teacher.

Generate ONE DAILY WORD for a user who is learning: $language.

IMPORTANT:
- The DAILY WORD itself MUST be in English.
- The user is learning "$language", so meanings/translations should be in $language.

${previousWordIds.isNotEmpty ? 'DO NOT use these word IDs: ${previousWordIds.join(', ')}' : ''}

Requirements:
- Pick an intermediate English word (not too easy, not too hard)
- Provide a unique wordId (use the English word in lowercase with underscores)
- Provide pronunciation (IPA) if available
- Provide an English definition (clear and simple)
- Provide "meaningInLearningLanguage" in $language (so the user understands the meaning in their learning language)
- Provide 1 short example in English (MAX 10 WORDS)
- Provide meaning of example that given in english sentence in learning language ($language) (MAX 10 WORDS) 
- Provide 3-4 simple English synonyms
- Provide 3-4 simple English antonyms

Return ONLY valid JSON in this exact format:
{
  "wordId": "persistent",
  "word": "persistent",
  "learningLanguage": "$language",
  "meaningInLearningLanguage": "...",
  "englishDefinition": "...",
  "pronunciation": "/pərˈsɪstənt/",
  "exampleEnglish": "She stayed persistent.",
  "exampleLearningLanguage": "...",
  "synonyms": ["determined", "tenacious", "steady"],
  "antonyms": ["inconsistent", "wavering", "unreliable"]
}

Rules:
- BOTH examples MUST be 10 words or less.
- Do not return markdown.
- Do not add extra keys.
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
          cleanContent = cleanContent.replaceAll(RegExp(r'```json|```'), '').trim();
        }

        final wordJson = jsonDecode(cleanContent);

        return DailyWordModel(
          wordId: (wordJson['wordId'] ?? '').toString(),
          word: (wordJson['word'] ?? '').toString(),
          language: (wordJson['learningLanguage'] ?? language).toString(),
          // Meaning/translation shown in the user's learning language
          translation: (wordJson['meaningInLearningLanguage'] ?? '').toString(),
          // Definition stays English
          englishMeaning: (wordJson['englishDefinition'] ?? '').toString(),
          pronunciation: wordJson['pronunciation']?.toString(),
          exampleSentenceEnglish: (wordJson['exampleEnglish'] ?? '').toString(),
          exampleSentenceLearning:
              (wordJson['exampleLearningLanguage'] ?? '').toString(),
          synonyms: List<String>.from((wordJson['synonyms'] ?? const []).map((e) => e.toString())),
          antonyms: List<String>.from((wordJson['antonyms'] ?? const []).map((e) => e.toString())),
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
