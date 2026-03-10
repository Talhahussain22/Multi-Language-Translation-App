import 'package:shared_preferences/shared_preferences.dart';

/// Manages daily usage limits for translation and grammar quiz API calls.
/// Also tracks interstitial ad counters and cooldowns.
/// All counters auto-reset after 24 hours.
class UsageLimitService {
  static final UsageLimitService _instance = UsageLimitService._internal();
  factory UsageLimitService() => _instance;
  UsageLimitService._internal();

  // ── SharedPreferences keys ────────────────────────────────────────────────
  static const _kTranslationCount   = 'usage_translation_count';
  static const _kQuizCount          = 'usage_quiz_count';
  static const _kLastResetDate      = 'usage_last_reset_date';
  static const _kNavCounter         = 'ad_nav_counter';
  static const _kTranslationCounter = 'ad_translation_counter';
  static const _kLastInterstitialTs  = 'ad_last_interstitial_ts';
  static const _kLastTestAdTs        = 'ad_last_test_end_ts'; // separate cooldown for test-end ads

  // ── Limits ────────────────────────────────────────────────────────────────
  static const int dailyTranslationLimit = 30;
  static const int dailyQuizLimit        = 3;

  /// Translations that earn from a rewarded ad.
  static const int rewardedTranslationBonus = 10;

  /// Quiz generations unlocked by one rewarded ad.
  static const int rewardedQuizBonus = 1;

  // ── Ad trigger thresholds ─────────────────────────────────────────────────
  static const int translationAdThreshold  = 7;              // show interstitial every 7 translations
  static const int navAdThreshold          = 10;             // show interstitial every 10 navigation taps
  static const int interstitialCooldownMs  = 2 * 60 * 1000; // 2 minutes between nav/translate ads
  static const int testAdCooldownMs        = 90 * 1000;      // 90 seconds between test-end ads

  // ── In-memory rewarded bonus pool ────────────────────────────────────────
  int _extraTranslations = 0;
  int _extraQuizzes      = 0;

  // ─────────────────────────────────────────────────────────────────────────
  // DAILY RESET
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _resetIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kLastResetDate) ?? '';
    final today = _todayKey();
    if (saved != today) {
      await prefs.setInt(_kTranslationCount, 0);
      await prefs.setInt(_kQuizCount, 0);
      await prefs.setString(_kLastResetDate, today);
      // Reset in-memory bonuses on new day too
      _extraTranslations = 0;
      _extraQuizzes      = 0;
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TRANSLATION LIMITS
  // ─────────────────────────────────────────────────────────────────────────

  Future<int> getTranslationCount() async {
    await _resetIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTranslationCount) ?? 0;
  }

  /// Returns true if the user can still translate (under limit).
  Future<bool> canTranslate() async {
    final used = await getTranslationCount();
    return used < dailyTranslationLimit + _extraTranslations;
  }

  /// Returns remaining translations today.
  Future<int> remainingTranslations() async {
    final used = await getTranslationCount();
    final max  = dailyTranslationLimit + _extraTranslations;
    return (max - used).clamp(0, max);
  }

  /// Call when a translation is completed. Returns whether to show an interstitial.
  Future<bool> recordTranslation() async {
    await _resetIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_kTranslationCount) ?? 0) + 1;
    await prefs.setInt(_kTranslationCount, count);

    // Increment translation-ad counter
    final adCount = (prefs.getInt(_kTranslationCounter) ?? 0) + 1;
    await prefs.setInt(_kTranslationCounter, adCount);

    if (adCount >= translationAdThreshold && await _canShowInterstitial()) {
      await prefs.setInt(_kTranslationCounter, 0);
      await _markInterstitialShown();
      return true; // caller should show ad
    }
    return false;
  }

  /// Grant extra translations from rewarded ad.
  void grantRewardedTranslations() {
    _extraTranslations += rewardedTranslationBonus;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUIZ LIMITS
  // ─────────────────────────────────────────────────────────────────────────

  Future<int> getQuizCount() async {
    await _resetIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kQuizCount) ?? 0;
  }

  Future<bool> canGenerateQuiz() async {
    final used = await getQuizCount();
    return used < dailyQuizLimit + _extraQuizzes;
  }

  Future<int> remainingQuizGenerations() async {
    final used = await getQuizCount();
    final max  = dailyQuizLimit + _extraQuizzes;
    return (max - used).clamp(0, max);
  }

  Future<void> recordQuizGeneration() async {
    await _resetIfNewDay();
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_kQuizCount) ?? 0) + 1;
    await prefs.setInt(_kQuizCount, count);
  }

  void grantRewardedQuiz() {
    _extraQuizzes += rewardedQuizBonus;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // NAVIGATION INTERSTITIAL COUNTER
  // ─────────────────────────────────────────────────────────────────────────

  /// Call on every bottom-nav tap. Returns true if an interstitial should show.
  Future<bool> recordNavigation() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_kNavCounter) ?? 0) + 1;
    await prefs.setInt(_kNavCounter, count);

    if (count >= navAdThreshold && await _canShowInterstitial()) {
      await prefs.setInt(_kNavCounter, 0);
      await _markInterstitialShown();
      return true;
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COOLDOWN HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _canShowInterstitial() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTs = prefs.getInt(_kLastInterstitialTs) ?? 0;
    final now    = DateTime.now().millisecondsSinceEpoch;
    return (now - lastTs) >= interstitialCooldownMs;
  }

  Future<void> _markInterstitialShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastInterstitialTs, DateTime.now().millisecondsSinceEpoch);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TEST-END INTERSTITIAL
  // Uses a separate cooldown key so test-end ads are never blocked by
  // nav/translation cooldowns and vice-versa.
  // ─────────────────────────────────────────────────────────────────────────

  /// Call when any quiz/test finishes.  Returns true when the caller
  /// should show an interstitial ad.
  Future<bool> shouldShowAdOnTestComplete() async {
    final prefs  = await SharedPreferences.getInstance();
    final lastTs = prefs.getInt(_kLastTestAdTs) ?? 0;
    final now    = DateTime.now().millisecondsSinceEpoch;
    if ((now - lastTs) >= testAdCooldownMs) {
      await prefs.setInt(_kLastTestAdTs, now);
      return true;
    }
    return false;
  }
}

