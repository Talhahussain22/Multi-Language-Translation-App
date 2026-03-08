import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists all words that have already been shown in the General Word Quiz
/// so the AI can be told to avoid them in future sessions.
class QuizWordHistoryService {
  static const String _prefix = 'quiz_used_words_';

  /// Build a storage key unique to language-pair + difficulty.
  static String _key(String fromLang, String toLang, String difficulty) =>
      '$_prefix${fromLang}_${toLang}_$difficulty'.replaceAll(' ', '_').toLowerCase();

  /// Returns the set of words already used for this combination.
  Future<Set<String>> getUsedWords({
    required String fromLang,
    required String toLang,
    required String difficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(fromLang, toLang, difficulty));
    if (raw == null || raw.isEmpty) return {};
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => e.toString()).toSet();
  }

  /// Adds new words to the persisted history for this combination.
  Future<void> addUsedWords({
    required String fromLang,
    required String toLang,
    required String difficulty,
    required List<String> words,
  }) async {
    if (words.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final existing = await getUsedWords(
      fromLang: fromLang,
      toLang: toLang,
      difficulty: difficulty,
    );
    final updated = {...existing, ...words};
    final key = _key(fromLang, toLang, difficulty);
    await prefs.setString(key, jsonEncode(updated.toList()));
  }

  /// Clears the word history for a specific combination (optional reset).
  Future<void> clearHistory({
    required String fromLang,
    required String toLang,
    required String difficulty,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(fromLang, toLang, difficulty));
  }

  /// Clears ALL quiz word history across all language combinations.
  Future<void> clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
