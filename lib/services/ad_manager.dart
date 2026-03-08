import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  bool _initialized = false;
  bool _isShowingFullScreenAd = false; // prevent back-to-back

  // Placeholder AdMob IDs (replace with real IDs when ready)
  static const String rewardedAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // Test Rewarded
      : 'ca-app-pub-2684836162704194/1140949286';
  static const String interstitialAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Test Interstitial
      : 'ca-app-pub-2684836162704194/9753936472';

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  // Getters to check if ads are currently loaded
  bool get isRewardedAdReady => _rewardedAd != null;
  bool get isInterstitialAdReady => _interstitialAd != null;

  // Method to ensure ads are preloaded (useful for screens that need ads soon)
  Future<void> ensureAdsPreloaded() async {
    await initialize();
    if (_rewardedAd == null) {
      unawaited(loadRewardedAd(onAdFailed: null));
    }
    if (_interstitialAd == null) {
      unawaited(loadInterstitialAd(onAdFailed: null));
    }
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    // Optional: configure test device IDs here if you have them.
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        // testDeviceIds: ['TEST_DEVICE_ID'],
      ),
    );
    await MobileAds.instance.initialize();
    _initialized = true;

    // Preload both ad types once SDK is ready.
    // Ignore failures; we'll try on-demand when showing.
    unawaited(loadRewardedAd(onAdFailed: null));
    unawaited(loadInterstitialAd(onAdFailed: null));
  }

  // Rewarded Ad
  Future<void> loadRewardedAd({
    required VoidCallback? onAdFailed,
  }) async {
    await initialize();
    if (!await _hasInternet()) {
      onAdFailed?.call();
      return;
    }
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          onAdFailed?.call();
        },
      ),
    );
  }

  Future<void> _ensureRewardedLoaded() async {
    if (_rewardedAd != null) return;
    final completer = Completer<void>();
    if (!await _hasInternet()) {
      completer.completeError('offline');
      return completer.future;
    }
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          if (!completer.isCompleted) completer.completeError(error);
        },
      ),
    );
    return completer.future;
  }

  Future<void> showRewardedAd({
    required VoidCallback onRewardEarned,
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailed,
  }) async {
    if (_isShowingFullScreenAd) {
      onAdFailed();
      return;
    }

    await initialize();

    if (!await _hasInternet()) {
      onAdFailed();
      return;
    }

    // Ensure loaded, especially first time.
    if (_rewardedAd == null) {
      try {
        await _ensureRewardedLoaded();
      } catch (_) {
        onAdFailed();
        return;
      }
    }

    final ad = _rewardedAd;
    if (ad == null) {
      onAdFailed();
      return;
    }

    _isShowingFullScreenAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingFullScreenAd = false;
        onAdDismissed();
        ad.dispose();
        _rewardedAd = null;
        // Preload next rewarded for future use.
        unawaited(loadRewardedAd(onAdFailed: null));
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingFullScreenAd = false;
        onAdFailed();
        ad.dispose();
        _rewardedAd = null;
        // Try preloading next.
        unawaited(loadRewardedAd(onAdFailed: null));
      },
    );

    ad.setImmersiveMode(true);
    ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      onRewardEarned();
    });
  }

  // Interstitial Ad
  Future<void> loadInterstitialAd({
    required VoidCallback? onAdFailed,
  }) async {
    await initialize();
    if (!await _hasInternet()) {
      onAdFailed?.call();
      return;
    }
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          onAdFailed?.call();
        },
      ),
    );
  }

  Future<void> _ensureInterstitialLoaded() async {
    if (_interstitialAd != null) return;
    final completer = Completer<void>();
    if (!await _hasInternet()) {
      completer.completeError('offline');
      return completer.future;
    }
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          if (!completer.isCompleted) completer.complete();
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          if (!completer.isCompleted) completer.completeError(error);
        },
      ),
    );
    return completer.future;
  }

  Future<void> showInterstitialAd({
    required VoidCallback onAdDismissed,
    required VoidCallback onAdFailed,
  }) async {
    if (_isShowingFullScreenAd) {
      onAdFailed();
      return;
    }

    await initialize();

    if (!await _hasInternet()) {
      onAdFailed();
      return;
    }

    // Ensure loaded, especially first time.
    if (_interstitialAd == null) {
      try {
        await _ensureInterstitialLoaded();
      } catch (_) {
        onAdFailed();
        return;
      }
    }

    final ad = _interstitialAd;
    if (ad == null) {
      onAdFailed();
      return;
    }

    _isShowingFullScreenAd = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingFullScreenAd = false;
        onAdDismissed();
        ad.dispose();
        _interstitialAd = null;
        // Preload next interstitial for future use.
        unawaited(loadInterstitialAd(onAdFailed: null));
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingFullScreenAd = false;
        onAdFailed();
        ad.dispose();
        _interstitialAd = null;
        // Try preloading next.
        unawaited(loadInterstitialAd(onAdFailed: null));
      },
    );

    ad.setImmersiveMode(true);
    ad.show();
  }
}
