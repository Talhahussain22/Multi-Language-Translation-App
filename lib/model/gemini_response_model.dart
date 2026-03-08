// ─────────────────────────────────────────────────────────────
// Structured option for vocabulary MCQ (native script + romanized)
// ─────────────────────────────────────────────────────────────
class MCQOption {
  /// The translation in the target language's native script.
  final String native;

  /// The romanized (English-letter) pronunciation of the translation.
  final String romanized;

  const MCQOption({required this.native, required this.romanized});

  /// Display value used when comparing against correctAnswer.
  String get value => native;

  /// Full label shown in UI: "native (romanized)" – or just native when
  /// romanized is identical / empty / same as native.
  String get label {
    final r = romanized.trim();
    if (r.isEmpty || r == native.trim()) return native;
    return '$native ($r)';
  }

  factory MCQOption.fromJson(Map<String, dynamic> json) {
    return MCQOption(
      native: json['native']?.toString() ?? json['text']?.toString() ?? '',
      romanized: json['romanized']?.toString() ?? '',
    );
  }

  /// Fallback: build a plain MCQOption from a bare string (legacy format).
  factory MCQOption.fromString(String text) =>
      MCQOption(native: text, romanized: '');
}

// ─────────────────────────────────────────────────────────────
// Vocabulary MCQ model
// ─────────────────────────────────────────────────────────────
class MCQQuestion {
  /// The English (source-language) question word.
  String question;

  /// Structured options, each with native + romanized text.
  List<MCQOption> options;

  /// The correct answer stored as the native-script string.
  String correctAnswer;

  MCQQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory MCQQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'] as List<dynamic>? ?? [];

    List<MCQOption> opts;
    if (rawOptions.isNotEmpty && rawOptions.first is Map) {
      // New structured format: [{"native": "...", "romanized": "..."}]
      opts = rawOptions
          .map((e) => MCQOption.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // Legacy flat format: ["word1", "word2", ...]
      opts = rawOptions.map((e) => MCQOption.fromString(e.toString())).toList();
    }

    // Ensure correctAnswer exists among options (by native value).
    final correctNative = json['correctAnswer']?.toString() ?? '';
    if (!opts.any((o) => o.native == correctNative)) {
      if (opts.isNotEmpty) {
        opts[0] = MCQOption(native: correctNative, romanized: '');
      } else {
        opts.add(MCQOption(native: correctNative, romanized: ''));
      }
    }

    opts.shuffle();

    return MCQQuestion(
      question: json['question']?.toString() ?? '',
      options: opts,
      correctAnswer: correctNative,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Grammar question model - supports both Parts of Speech and Vocabulary tests
// ─────────────────────────────────────────────────────────────
class GrammarQuestion {
  /// The sentence displayed to the user (may contain ______ or *word*)
  final String sentence;

  /// For Parts of Speech tests: the word marked with asterisks
  final String? markedWord;

  /// The four answer options
  final List<String> options;

  /// The correct answer
  final String correctAnswer;

  /// A brief hint explaining WHY the answer is correct
  final String hint;

  /// Returns true if this is a Parts of Speech question
  bool get isPartsOfSpeech => markedWord != null && markedWord!.isNotEmpty;

  GrammarQuestion({
    required this.sentence,
    this.markedWord,
    required this.options,
    required this.correctAnswer,
    required this.hint,
  });

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) {
    List<String> opts = List<String>.from(json['options'] ?? []);

    // Safety: ensure correctAnswer is in the options list
    if (!opts.contains(json['correctAnswer'])) {
      if (opts.isNotEmpty) {
        opts[0] = json['correctAnswer'] ?? opts[0];
      } else {
        opts.add(json['correctAnswer'] ?? '');
      }
    }

    opts.shuffle();

    return GrammarQuestion(
      sentence: json['sentence']?.toString() ?? '',
      markedWord: json['markedWord']?.toString(),
      options: opts,
      correctAnswer: json['correctAnswer']?.toString() ?? '',
      hint: json['hint']?.toString() ?? '',
    );
  }
}
