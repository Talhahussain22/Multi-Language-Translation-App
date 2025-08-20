import 'package:ai_text_to_speech/model/hive_model.dart';

class Prompts {
  static String generalmcqsprompt({
    required String count,
    required String fromLang,
    required String toLang,
    required String mcqslevel,
  }) {
    final session=DateTime.now().millisecondsSinceEpoch.toString();
    return '''
Generate $count multiple-choice vocabulary questions with "$mcqslevel" difficulty.

Translate from $fromLang to $toLang.

Requirements:
- Use only "$mcqslevel"-level words in $fromLang.
- Difficulty levels:
  - Easy: Very common, everyday words (e.g., "go", "play", "run", "house", "eat") it is mandatory  for each request generate differnet question other than these with session id $session
  - Low-Medium: Slightly more abstract but still familiar (e.g., "protect", "sustain", "improve", "important") it is mandatory for each request generate differnet question other than these with session id $session
  - Medium: Less common but understandable words (e.g., "analyze", "observe", "fragile") it is mandatory for each request generate differnet question other than these with session id $session
  - Hard: Rare, academic, or advanced vocabulary (e.g., "ubiquitous", "mellifluous", "taciturn") it is mandatory for each request generate differnet question other than these with session id $session

Each question must contain:
- A single word in $fromLang (according to the selected difficulty)
- 4 options in $toLang:
  - 1 correct translation
  - 3 incorrect but believable distractors
  but if $fromLang==$toLang then for each word in from language $fromLang generate options in from Language $fromLang (like one synonyms other incorrect but beleiveable deistractors

✳️ Constraints:
-It is mandatory that option must be shuffled so correct option would have differnet positions
- Shuffle the option so correct option lie at differnet position for each question.
- Do not repeat any questions from previous prompts which have sessionid $session.
- Ensure the JSON is strictly valid — no markdown, no explanations, no extra formatting.

Return ONLY the raw JSON list in this format:
[
  {
    "question": "play",
    "options": ["jugar", "leer", "dormir", "beber"],
    "correctAnswer": "jugar"
  }
]


''';
  }

  static String favouriteQuizPrompt({required List<FavoriteWord> words}){
    List<Map<String,String>> inputList=words.map((word)=>{
      "word": word.word,
      "correctAnswer": word.translation,
      "fromLang": word.fromLanguage,
      "toLang": word.toLanguage
    }).toList();
   return '''You are a vocabulary MCQ generator.

Below is a list of favorited words. Each entry includes:
- A word in a source language (`fromLang`)
- Its correct translation in the target language (`toLang`)

Your task:
- For each word, create a multiple-choice question.
- Use the `word` as the question prompt (in its `fromLang`).
- Include 4 options in the `toLang`:
  - 
  - One is the correct translation (provided as `correctAnswer`) and must be exact same as correct answer(option much contain this) 
  - Three are believable but incorrect distractors but not synonyms of correct answer (you must generate these).
- All distractors must be in the correct `toLang` and of the same type/part of speech as the correct answer.
- Options should feel plausible in meaning but still incorrect.

Input list:
 $inputList

Expected output: Only return a valid JSON array like this:
[
  {
    "question": "apple",
    "options": ["manzana", "queso", "casa", "perro"],
    "correctAnswer": "manzana"
  },
  {
    "question": "maison",
    "options": ["house", "table", "wall", "lamp"],
    "correctAnswer": "house"
  },
  {
    "question": "کتاب",
    "options": ["book", "pen", "page", "notebook"],
    "correctAnswer": "book"
  }
]

❗ Do not return anything other than the raw JSON list.
❗ Do not repeat distractors across questions.
❗ Make sure all distractors are in the correct `toLang` for that question.

 ''';
  }
}
