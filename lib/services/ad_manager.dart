import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  bool _initialized = false;
  bool _isShowingFullScreenAd = false;

  // ── Ad Unit IDs (test IDs in debug, real in release) ─────────────────────
  static const String rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // Test Rewarded
      : 'ca-app-pub-2684836162704194/1140949286';
  static const String interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Test Interstitial
      : 'ca-app-pub-2684836162704194/9753936472';
  static const String bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111' // Test Banner
      : 'ca-app-pub-2684836162704194/4092385998'; // Production Banner

  // ── Cached ads ────────────────────────────────────────────────────────────
  RewardedAd?     _rewardedAd;
  InterstitialAd? _interstitialAd;

  bool get isRewardedAdReady     => _rewardedAd != null;
  bool get isInterstitialAdReady => _interstitialAd != null;

  // ─────────────────────────────────────────────────────────────────────────
  // INTERNET CHECK
  // ─────────────────────────────────────────────────────────────────────────

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INITIALIZE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(),
    );
    await MobileAds.instance.initialize();
    _initialized = true;

    unawaited(loadRewardedAd(onAdFailed: null));
    unawaited(loadInterstitialAd(onAdFailed: null));
  }

  /// Call from any screen's initState to ensure ads are warm.
  Future<void> ensureAdsPreloaded() async {
    await initialize();
    if (_rewardedAd == null)     unawaited(loadRewardedAd(onAdFailed: null));
    if (_interstitialAd == null) unawaited(loadInterstitialAd(onAdFailed: null));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REWARDED AD
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadRewardedAd({required VoidCallback? onAdFailed}) async {
    await initialize();
    if (!await _hasInternet()) { onAdFailed?.call(); return; }
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded:       (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (e)  { _rewardedAd = null; onAdFailed?.call(); },
      ),
    );
  }

  Future<void> _ensureRewardedLoaded() async {
    if (_rewardedAd != null) return;
    final c = Completer<void>();
    if (!await _hasInternet()) { c.completeError('offline'); return c.future; }
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded:       (ad) { _rewardedAd = ad; if (!c.isCompleted) c.complete(); },
        onAdFailedToLoad: (e)  { _rewardedAd = null; if (!c.isCompleted) c.completeError(e); },
      ),
    );
    return c.future;
  }

  Future<void> showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailed,
  }) async {
    if (_isShowingFullScreenAd) { onAdFailed(); return; }
    await initialize();
    if (!await _hasInternet()) { onAdFailed(); return; }
    if (_rewardedAd == null) {
      try { await _ensureRewardedLoaded(); } catch (_) { onAdFailed(); return; }
    }
    final ad = _rewardedAd;
    if (ad == null) { onAdFailed(); return; }

    _isShowingFullScreenAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingFullScreenAd = false;
        onAdDismissed();
        ad.dispose();
        _rewardedAd = null;
        unawaited(loadRewardedAd(onAdFailed: null));
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingFullScreenAd = false;
        onAdFailed();
        ad.dispose();
        _rewardedAd = null;
        unawaited(loadRewardedAd(onAdFailed: null));
      },
    );
    ad.setImmersiveMode(true);
    ad.show(onUserEarnedReward: (_, __) => onRewardEarned());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // INTERSTITIAL AD
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> loadInterstitialAd({required VoidCallback? onAdFailed}) async {
    await initialize();
    if (!await _hasInternet()) { onAdFailed?.call(); return; }
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded:       (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (e)  { _interstitialAd = null; onAdFailed?.call(); },
      ),
    );
  }

  Future<void> _ensureInterstitialLoaded() async {
    if (_interstitialAd != null) return;
    final c = Completer<void>();
    if (!await _hasInternet()) { c.completeError('offline'); return c.future; }
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded:       (ad) { _interstitialAd = ad; if (!c.isCompleted) c.complete(); },
        onAdFailedToLoad: (e)  { _interstitialAd = null; if (!c.isCompleted) c.completeError(e); },
      ),
    );
    return c.future;
  }

  Future<void> showInterstitialAd({
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailed,
  }) async {
    if (_isShowingFullScreenAd) { onAdFailed(); return; }
    await initialize();
    if (!await _hasInternet()) { onAdFailed(); return; }
    if (_interstitialAd == null) {
      try { await _ensureInterstitialLoaded(); } catch (_) { onAdFailed(); return; }
    }
    final ad = _interstitialAd;
    if (ad == null) { onAdFailed(); return; }

    _isShowingFullScreenAd = true;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingFullScreenAd = false;
        onAdDismissed();
        ad.dispose();
        _interstitialAd = null;
        unawaited(loadInterstitialAd(onAdFailed: null));
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingFullScreenAd = false;
        onAdFailed();
        ad.dispose();
        _interstitialAd = null;
        unawaited(loadInterstitialAd(onAdFailed: null));
      },
    );
    ad.setImmersiveMode(true);
    ad.show();
  }

  /// Convenience: show an interstitial if the ad is ready; silently skip if not.
  Future<void> showInterstitialIfReady({VoidCallback? onDismissed}) async {
    if (_isShowingFullScreenAd) return;
    await showInterstitialAd(
      onAdDismissed: onDismissed ?? () {},
      onAdFailed:    () {},
    );
  }
}
