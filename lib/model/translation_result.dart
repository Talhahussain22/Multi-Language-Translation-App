import 'dart:convert';

/// Holds the parsed result of a translation API response.
/// Every field is nullable — missing fields never cause a crash.
class TranslationResult {
  final String? text;
  final String? from;
  final String? to;

  // ── Core translation ────────────────────────────────────────────
  final String? nativeTranslation;
  final String? romanizedTranslation;

  // ── Single-word extras ──────────────────────────────────────────
  final String? partOfSpeech;
  final String? definition;
  final String? pronunciation;
  final List<String> synonyms; // always a list, never null

  // ── Example sentence ────────────────────────────────────────────
  final String? exampleNative;
  final String? exampleRomanized;
  final String? exampleMeaning;

  const TranslationResult({
    this.text,
    this.from,
    this.to,
    this.nativeTranslation,
    this.romanizedTranslation,
    this.partOfSpeech,
    this.definition,
    this.pronunciation,
    this.synonyms = const [],
    this.exampleNative,
    this.exampleRomanized,
    this.exampleMeaning,
  });

  /// True when the response contains word-level detail.
  bool get isSingleWord =>
      (pronunciation != null && pronunciation!.isNotEmpty) ||
      (exampleNative != null && exampleNative!.isNotEmpty) ||
      (partOfSpeech != null && partOfSpeech!.isNotEmpty) ||
      synonyms.isNotEmpty;

  /// Compact string stored in Hive history: "native | romanized".
  String get historyString {
    final parts = <String>[];
    if (nativeTranslation != null && nativeTranslation!.isNotEmpty) {
      parts.add(nativeTranslation!);
    }
    if (romanizedTranslation != null && romanizedTranslation!.isNotEmpty) {
      parts.add(romanizedTranslation!);
    }
    return parts.join(' | ');
  }

  /// Parse a raw JSON string returned by the API.
  factory TranslationResult.fromJsonString(String raw) {
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return TranslationResult.fromMap(map);
    } catch (_) {
      return const TranslationResult();
    }
  }

  factory TranslationResult.fromMap(Map<String, dynamic> map) {
    // ── translation ────────────────────────────────────────────────
    final translation = map['translation'];
    String? native;
    String? romanized;
    if (translation is Map<String, dynamic>) {
      native = _str(translation['native']);
      romanized = _str(translation['romanized']);
    }

    // ── example ────────────────────────────────────────────────────
    final example = map['example'];
    String? exNative;
    String? exRomanized;
    String? exMeaning;
    if (example is Map<String, dynamic>) {
      final sentence = example['sentence'];
      if (sentence is Map<String, dynamic>) {
        exNative = _str(sentence['native']);
        exRomanized = _str(sentence['romanized']);
      }
      exMeaning = _str(example['meaning']);
    }

    // ── synonyms ───────────────────────────────────────────────────
    final rawSynonyms = map['synonyms'];
    final List<String> synonymList = [];
    if (rawSynonyms is List) {
      for (final s in rawSynonyms) {
        final str = s?.toString().trim() ?? '';
        if (str.isNotEmpty) synonymList.add(str);
      }
    }

    return TranslationResult(
      text: _str(map['text']),
      from: _str(map['from']),
      to: _str(map['to']),
      nativeTranslation: native,
      romanizedTranslation: romanized,
      partOfSpeech: _str(map['partOfSpeech']),
      definition: _str(map['definition']),
      pronunciation: _str(map['pronunciation']),
      synonyms: synonymList,
      exampleNative: exNative,
      exampleRomanized: exRomanized,
      exampleMeaning: exMeaning,
    );
  }

  /// Safely converts a value to a non-empty String, or returns null.
  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }
}
