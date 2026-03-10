import 'package:ai_text_to_speech/model/hive_model.dart';

class Prompts {
  static String generalmcqsprompt({
    required String count,
    required String fromLang,   // kept for difficulty calibration context
    required String toLang,
    required String mcqslevel,
    List<String> usedWords = const [],
  }) {
    final session = DateTime.now().millisecondsSinceEpoch.toString();
    final exclusion = usedWords.isEmpty
        ? ''
        : '\n🚫 EXCLUDED WORDS (already shown to this user – do NOT use as questions):\n${usedWords.map((w) => '"$w"').join(', ')}\n';

    return '''
Generate $count multiple-choice vocabulary questions with "$mcqslevel" difficulty.

━━━━━━━━━━━━━━━  MANDATORY LANGUAGE RULE  ━━━━━━━━━━━━━━━
⚠️  The "question" field MUST ALWAYS be a plain English word.
⚠️  NEVER put a $toLang word or any non-English word in the "question" field.
The user is learning $toLang from English, so they see an English word
and must pick the correct $toLang translation from the options.

━━━━━━━━━━━━━━━  LANGUAGE SETUP  ━━━━━━━━━━━━━━━
• Question word   : English only (difficulty calibrated for "$mcqslevel" English vocabulary)
• Answer options  : $toLang (native script + romanized English pronunciation)
• Session ID      : $session   ← ensures fresh questions every session
$exclusion
━━━━━━━━━━━━━━━  DIFFICULTY  ━━━━━━━━━━━━━━━
Level: "$mcqslevel"
- Easy       : Very common everyday English words (go, play, run, house, eat)
- Low-Medium : Slightly abstract but familiar English (protect, sustain, improve)
- Medium     : Less common English (analyze, observe, fragile)
- Hard       : Rare/academic English (ubiquitous, mellifluous, taciturn)

━━━━━━━━━━━━━━━  QUESTION FORMAT  ━━━━━━━━━━━━━━━
Each question MUST have:
1. "question"     – ONE English word the user must translate (ALWAYS English, never $toLang)
2. "options"      – exactly 4 objects, each with TWO fields:
     • "native"    : the word in $toLang native script / alphabet
     • "romanized" : pronunciation of that $toLang word in English letters (romanization)
   Include 1 correct $toLang translation + 3 believable but WRONG distractors (also in $toLang).
3. "correctAnswer" – must exactly match one option's "native" field

━━━━━━━━━━━━━━━  CONSTRAINTS  ━━━━━━━━━━━━━━━
✓ "question" is ALWAYS a plain English word – no exceptions
✓ All 4 options are ALWAYS in $toLang (native script)
✓ Shuffle options so the correct answer is in a DIFFERENT position each time
✓ Do NOT use any word from EXCLUDED WORDS as a question word
✓ Do NOT repeat any question from session $session
✓ Return ONLY valid raw JSON array – no markdown, no prose, no extra keys

━━━━━━━━━━━━━━━  EXAMPLE (learning Chinese)  ━━━━━━━━━━━━━━━
[
  {
    "question": "play",
    "options": [
      {"native": "玩",   "romanized": "wán"},
      {"native": "吃",   "romanized": "chī"},
      {"native": "跪",   "romanized": "pǎo"},
      {"native": "写",   "romanized": "xiě"}
    ],
    "correctAnswer": "玩"
  }
]

''';
  }

  /// Used when the user selects English as the target language.
  /// Questions are English words; options are 4 English definitions.
  static String englishDefinitionQuizPrompt({
    required String count,
    required String mcqslevel,
    List<String> usedWords = const [],
  }) {
    final session = DateTime.now().millisecondsSinceEpoch.toString();
    final exclusion = usedWords.isEmpty
        ? ''
        : '\n🚫 EXCLUDED WORDS (already used – do NOT repeat): ${usedWords.map((w) => '"$w"').join(', ')}\n';

    return '''
Generate $count English vocabulary quiz questions at "$mcqslevel" difficulty.

━━━━━━━━━━━━━━━  MODE: ENGLISH DEFINITION QUIZ  ━━━━━━━━━━━━━━━
The user sees an English word and must pick the correct English definition from 4 options.
This tests English vocabulary knowledge, not translation skills.
$exclusion
━━━━━━━━━━━━━━━  DIFFICULTY  ━━━━━━━━━━━━━━━
Level: "$mcqslevel"
- Easy       : Very common everyday words (run, happy, big, water)
- Low-Medium : Slightly abstract but familiar (protect, improve, fragile)
- Medium     : Less common (eloquent, candid, ambiguous)
- Hard       : Rare/academic words (ephemeral, perspicacious, sycophant)

━━━━━━━━━━━━━━━  OUTPUT FORMAT  ━━━━━━━━━━━━━━━
Return a raw JSON array. Each item:
{
  "question": "<English word>",
  "options": [
    {"native": "<definition 1>", "romanized": ""},
    {"native": "<definition 2>", "romanized": ""},
    {"native": "<definition 3>", "romanized": ""},
    {"native": "<definition 4>", "romanized": ""}
  ],
  "correctAnswer": "<definition that matches the question word>"
}

━━━━━━━━━━━━━━━  RULES  ━━━━━━━━━━━━━━━
✓ "romanized" is always empty string "" (not needed for English definitions)
✓ Options are SHORT concise definitions (1 sentence max)
✓ All 4 options must be in English
✓ 1 correct definition + 3 plausible but wrong definitions
✓ correctAnswer must exactly match one option's "native" field
✓ Shuffle options so correct answer is NOT always first
✓ Session ID $session – ensure fresh words every call
✓ Return ONLY valid raw JSON array – no markdown, no extra keys
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

  static String translateText({required String word, required String toLang, required String fromLang}) {
    return '''You are a language learning assistant that returns structured JSON.

Translate the text "$word" from $fromLang to $toLang.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
RULES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Always use the most natural, everyday translation. Avoid rare or overly formal words.
2. For every target-language text field, always provide BOTH:
   - "native"    : the text in the target script / alphabet.
   - "romanized" : the pronunciation using English letters (romanization).
3. Count the number of words in the input to decide which output schema to use.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHEN INPUT IS A SINGLE WORD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Return ALL of the following fields:

  a) translation   – { "native": "...", "romanized": "..." }
  b) partOfSpeech  – grammatical category in English.
                     Use one of: "noun", "verb", "adjective", "adverb",
                     "pronoun", "preposition", "conjunction", "interjection".
  c) definition    – a single short, plain-English sentence (max 12 words)
                     that explains what the word means. This must always be
                     written in English regardless of $fromLang.
  d) pronunciation – how the TRANSLATED word sounds, in English letters.
  e) synonyms      – a JSON array of 2–3 common $fromLang synonyms of the
                     SOURCE word. Write them in $fromLang, not $toLang.
                     Return only true synonyms — skip if none exist.
  f) example       – one short, natural sentence in $toLang (max 8 words)
                     that uses the translated word.
                     Include "sentence": { "native": "...", "romanized": "..." }
                     and "meaning": the $fromLang translation of that sentence.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WHEN INPUT IS A SENTENCE / PHRASE (more than one word)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Return ONLY the translation field.
Do NOT include partOfSpeech, definition, pronunciation, synonyms, or example.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OUTPUT FORMAT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Return ONLY a single raw JSON object. No markdown, no comments, no extra keys.

JSON schema – SINGLE WORD:
{
  "text": "$word",
  "from": "$fromLang",
  "to": "$toLang",
  "partOfSpeech": "",
  "definition": "",
  "translation": {
    "native": "",
    "romanized": ""
  },
  "pronunciation": "",
  "synonyms": ["", ""],
  "example": {
    "sentence": {
      "native": "",
      "romanized": ""
    },
    "meaning": ""
  }
}

JSON schema – SENTENCE:
{
  "text": "$word",
  "from": "$fromLang",
  "to": "$toLang",
  "translation": {
    "native": "",
    "romanized": ""
  }
}
''';
  }

  /// Generates grammar test questions based on the selected [testType].
  static String grammarTestPrompt({
    required String count,
    required String language,
    required String testType,
  }) {
    final session = DateTime.now().millisecondsSinceEpoch.toString();

    if (testType.startsWith('Focused:')) {
      // Focused practice: Fill in the blank with specific part of speech words
      String specificType = testType.replaceFirst('Focused: ', '');

      return '''You are an educational grammar test generator specializing in $specificType.

Generate $count fill-in-the-blank questions in $language that test knowledge of $specificType.
Session: $session  ← ensure unique questions

━━━━━━━━━━━━━━━  TEST TYPE: $specificType PRACTICE  ━━━━━━━━━━━━━━━
ALL questions MUST focus on $specificType only.

━━━━━━━━━━━━━━━  QUESTION FORMAT  ━━━━━━━━━━━━━━━
Each question MUST:
1. Present a sentence with ONE blank: "______"
2. The blank must be filled with a $specificType word
3. Provide exactly 4 $specificType words as options
4. All 4 options must be valid $specificType words
5. Only ONE option makes the sentence grammatically correct and natural
6. Include a brief educational hint

━━━━━━━━━━━━━━━  PART OF SPEECH GUIDELINES  ━━━━━━━━━━━━━━━

**Nouns**: Use blanks for person, place, thing, or idea
Example: "The ______ is on the table." Options: [book, water, happiness, teacher]

**Verbs**: Use blanks for action or state verbs
Example: "She ______ to school every day." Options: [walks, runs, drives, goes]

**Adjectives**: Use blanks for descriptive words
Example: "The ______ cat slept peacefully." Options: [lazy, beautiful, small, happy]

**Adverbs**: Use blanks for words modifying verbs/adjectives
Example: "He spoke ______ to the audience." Options: [confidently, quickly, slowly, loudly]

**Pronouns**: Use blanks for words replacing nouns
Example: "______ went to the store yesterday." Options: [She, He, They, I]

**Prepositions**: Use blanks for relationship words
Example: "The cat jumped ______ the table." Options: [on, under, over, through]

**Conjunctions**: Use blanks for connecting words
Example: "I like tea ______ coffee." Options: [and, but, or, nor]

**Interjections**: Use blanks for emotion words
Example: "______! That was amazing!" Options: [Wow, Oh, Hey, Ouch]

━━━━━━━━━━━━━━━  REQUIREMENTS  ━━━━━━━━━━━━━━━
✓ ALL options must be $specificType words
✓ Use natural, everyday sentences (8-15 words)
✓ Only ONE option makes grammatical sense
✓ Options should be at similar difficulty level
✓ Shuffle option positions
✓ Hints should be concise (max 15 words)
✓ No repeat questions from session $session

━━━━━━━━━━━━━━━  EXAMPLE OUTPUT  ━━━━━━━━━━━━━━━
[
  {
    "sentence": "The cat jumped ______ the table.",
    "options": ["over", "under", "through", "behind"],
    "correctAnswer": "over",
    "hint": "Shows direction of movement from one side to another."
  },
  {
    "sentence": "She placed the book ______ the shelf.",
    "options": ["on", "at", "in", "by"],
    "correctAnswer": "on",
    "hint": "Use for contact with a surface."
  }
]

Return ONLY valid JSON array. No markdown, no explanations, no extra text.''';
    } else if (testType == 'Identify Part of Speech') {
      return '''You are an educational grammar test generator specializing in Parts of Speech.

Generate $count multiple-choice questions in $language that test identification of parts of speech.
Session: $session  ← ensure unique questions

━━━━━━━━━━━━━━━  PARTS OF SPEECH TO TEST  ━━━━━━━━━━━━━━━
• Noun (person, place, thing, idea)
• Verb (action, state of being)
• Adjective (describes noun)
• Adverb (modifies verb/adjective/adverb)
• Pronoun (replaces noun)
• Preposition (shows relationship)
• Conjunction (connects words/phrases)
• Interjection (expresses emotion)

━━━━━━━━━━━━━━━  QUESTION FORMAT  ━━━━━━━━━━━━━━━
Each question MUST:
1. Present a complete, natural sentence in $language
2. Mark ONE word with asterisks: *word*
3. Ask which part of speech that marked word is
4. Provide 4 options with one correct answer
5. Include a brief educational hint explaining why

━━━━━━━━━━━━━━━  REQUIREMENTS  ━━━━━━━━━━━━━━━
✓ Use everyday, natural sentences (8-15 words)
✓ Distribute questions across ALL different parts of speech
✓ Make distractors plausible (e.g., if word is adjective, include adverb as distractor)
✓ Shuffle option positions (correct answer not always in same spot)
✓ Hints should be educational and concise (max 15 words)
✓ Sentences should be grammatically perfect
✓ No repeat questions from session $session

━━━━━━━━━━━━━━━  EXAMPLE OUTPUT  ━━━━━━━━━━━━━━━
[
  {
    "sentence": "The *beautiful* garden blooms every spring.",
    "markedWord": "beautiful",
    "options": ["Adjective", "Adverb", "Noun", "Verb"],
    "correctAnswer": "Adjective",
    "hint": "Describes 'garden' - what kind of garden it is."
  },
  {
    "sentence": "She *quickly* ran to catch the bus.",
    "markedWord": "quickly",
    "options": ["Verb", "Adverb", "Adjective", "Noun"],
    "correctAnswer": "Adverb",
    "hint": "Modifies the verb 'ran' - tells how she ran."
  },
  {
    "sentence": "The book is *on* the table.",
    "markedWord": "on",
    "options": ["Preposition", "Verb", "Conjunction", "Adverb"],
    "correctAnswer": "Preposition",
    "hint": "Shows spatial relationship between book and table."
  }
]

Return ONLY valid JSON array. No markdown, no explanations, no extra text.''';
    } else if (testType == 'Fill Correct Part of Speech') {
      // Fill in the blank with correct part of speech
      return '''You are an educational grammar test generator specializing in Vocabulary in Context.

Generate $count fill-in-the-blank questions in $language that test vocabulary and grammar understanding.
Session: $session  ← ensure unique questions

━━━━━━━━━━━━━━━  TEST TYPE: VOCABULARY IN CONTEXT  ━━━━━━━━━━━━━━━
Test learners' ability to choose the correct word based on sentence context.

━━━━━━━━━━━━━━━  QUESTION FORMAT  ━━━━━━━━━━━━━━━
Each question MUST:
1. Present a sentence with ONE word replaced by "______"
2. The blank should test vocabulary, word form, or grammatical correctness
3. Provide exactly 4 options (all single words in $language)
4. Include 1 correct answer and 3 plausible but incorrect options
5. Add a helpful hint explaining the grammar rule or context clue

━━━━━━━━━━━━━━━  FOCUS AREAS  ━━━━━━━━━━━━━━━
• Correct verb tenses (past, present, future)
• Singular vs plural forms
• Subject-verb agreement
• Adjective vs adverb forms
• Appropriate vocabulary for context
• Common prepositions and articles
• Pronoun usage

━━━━━━━━━━━━━━━  REQUIREMENTS  ━━━━━━━━━━━━━━━
✓ Use natural, everyday sentences (8-15 words)
✓ All options must be same part of speech (e.g., all verbs, all adjectives)
✓ Make distractors believable but grammatically incorrect
✓ Shuffle option positions (correct answer not always first)
✓ Include variety: verbs, nouns, adjectives, prepositions, articles
✓ Hints should guide learning (max 15 words)
✓ No repeat questions from session $session

━━━━━━━━━━━━━━━  EXAMPLE OUTPUT  ━━━━━━━━━━━━━━━
[
  {
    "sentence": "She ______ to the market yesterday.",
    "options": ["went", "goes", "going", "go"],
    "correctAnswer": "went",
    "hint": "Use past tense for completed action with 'yesterday'."
  },
  {
    "sentence": "The children are playing ______ in the park.",
    "options": ["happily", "happy", "happiness", "happier"],
    "correctAnswer": "happily",
    "hint": "Need adverb to describe how they're playing."
  },
  {
    "sentence": "I have ______ books on my shelf.",
    "options": ["many", "much", "more", "most"],
    "correctAnswer": "many",
    "hint": "Use 'many' with countable plural nouns."
  }
]

Return ONLY valid JSON array. No markdown, no explanations, no extra text.''';
    } else {
      // Fallback for unknown test types - default to Identify Part of Speech
      return '''You are an educational grammar test generator specializing in Parts of Speech.

Generate $count multiple-choice questions in $language that test identification of parts of speech.
Session: $session  ← ensure unique questions

━━━━━━━━━━━━━━━  QUESTION FORMAT  ━━━━━━━━━━━━━━━
Each question MUST:
1. Present a complete, natural sentence in $language
2. Mark ONE word with asterisks: *word*
3. Ask which part of speech that marked word is
4. Provide 4 options with one correct answer
5. Include a brief educational hint explaining why

━━━━━━━━━━━━━━━  REQUIREMENTS  ━━━━━━━━━━━━━━━
✓ Use everyday, natural sentences (8-15 words)
✓ Distribute questions across ALL different parts of speech
✓ Make distractors plausible
✓ Shuffle option positions (correct answer not always in same spot)
✓ Hints should be educational and concise (max 15 words)
✓ Sentences should be grammatically perfect

━━━━━━━━━━━━━━━  EXAMPLE OUTPUT  ━━━━━━━━━━━━━━━
[
  {
    "sentence": "The *beautiful* garden blooms every spring.",
    "markedWord": "beautiful",
    "options": ["Adjective", "Adverb", "Noun", "Verb"],
    "correctAnswer": "Adjective",
    "hint": "Describes 'garden' - what kind of garden it is."
  }
]

Return ONLY valid JSON array. No markdown, no explanations, no extra text.''';
    }
  }
}
