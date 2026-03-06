import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String keyDarkMode = 'dark_mode_enabled';
  static const String keyFreeSummaryUsed = 'free_summary_used';
  static const String keySummaryRewardGranted = 'summary_reward_granted';

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<bool> getDarkMode() async {
    final p = await _prefs();
    return p.getBool(keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final p = await _prefs();
    await p.setBool(keyDarkMode, value);
  }

  Future<bool> isFreeSummaryUsed() async {
    final p = await _prefs();
    return p.getBool(keyFreeSummaryUsed) ?? false;
  }

  Future<void> setFreeSummaryUsed(bool used) async {
    final p = await _prefs();
    await p.setBool(keyFreeSummaryUsed, used);
  }

  Future<bool> isSummaryRewardGranted() async {
    final p = await _prefs();
    return p.getBool(keySummaryRewardGranted) ?? false;
  }

  Future<void> setSummaryRewardGranted(bool granted) async {
    final p = await _prefs();
    await p.setBool(keySummaryRewardGranted, granted);
  }

  Future<void> resetSummaryGating() async {
    final p = await _prefs();
    await p.remove(keySummaryRewardGranted);
  }
}

