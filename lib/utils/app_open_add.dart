// import 'package:flutter/foundation.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';

// class AppOpenAdManager {
//   AppOpenAd? _appOpenAd;
//   bool _isAdLoaded = false;
//   final String _adUnitId;

//   AppOpenAdManager({required String adUnitId}) : _adUnitId = adUnitId;
//   // static String intertialAdd = 'ca-app-pub-3940256099942544/1033173712';
//   // static String bannerAdd = 'ca-app-pub-3940256099942544/9214589741';
//   // static String nativeAdd = 'ca-app-pub-3940256099942544/2247696110';
//   // static String appOpenAdd = 'ca-app-pub-3940256099942544/9257395921';
//   // Function to load the ad
//   void loadAd() {
//     AppOpenAd.load(
//       // adUnitId: _adUnitId,
//       adUnitId: 'ca-app-pub-3940256099942544/9257395921',
//       request: const AdRequest(),
//       adLoadCallback: AppOpenAdLoadCallback(
//         onAdLoaded: (ad) {
//           if (kDebugMode) {
//             print('AppOpenAd loaded successfully');
//           }
//           _appOpenAd = ad;
//           _isAdLoaded = true;
//         },
//         onAdFailedToLoad: (error) {
//           if (kDebugMode) {
//             print('AppOpenAd failed to load: $error');
//           }
//           _isAdLoaded = false;
//         },
//       ),
//     );
//   }

//   // Function to show the ad if it is ready and Firebase allows it
//   void showAdIfAvailable() {
//     if (!_isAdLoaded || _appOpenAd == null) {
//       if (kDebugMode) {
//         print('Ad not ready yet. Loading a new one.');
//       }
//       loadAd(); // Load a new one for the next time
//       return;
//     }

//     _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
//       onAdShowedFullScreenContent: (ad) {
//         _isAdLoaded = false; // Reset the flag
//         if (kDebugMode) {
//           print('AppOpenAd showed full screen content.');
//         }
//       },
//       onAdDismissedFullScreenContent: (ad) {
//         if (kDebugMode) {
//           print('AppOpenAd dismissed.');
//         }
//         ad.dispose();
//         _appOpenAd = null;
//         loadAd(); // Preload the next ad
//       },
//       onAdFailedToShowFullScreenContent: (ad, error) {
//         if (kDebugMode) {
//           print('AppOpenAd failed to show: $error');
//         }
//         ad.dispose();
//         _appOpenAd = null;
//         loadAd(); // Preload the next ad
//       },
//     );

//     _appOpenAd!.show();
//   }

//   // Function to dispose of the ad
//   void dispose() {
//     _appOpenAd?.dispose();
//     _appOpenAd = null;
//     _isAdLoaded = false;
//   }

//   // Getter to check if ad is loaded
//   bool get isAdLoaded => _isAdLoaded;
// }


import 'package:flutter/foundation.dart';
import 'package:gcoin/main.dart';
import 'package:gcoin/utils/ad_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  static final AppOpenAdManager _instance = AppOpenAdManager._internal();
  factory AppOpenAdManager() => _instance;
  AppOpenAdManager._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  bool _isLoadingAd = false;
  DateTime? _appOpenLoadTime;

  // App lifecycle states
  bool _isAppInBackground = false;
  bool _wasInterstitialShowingWhenBackgrounded = false;

  /// Maximum duration allowed between loading and showing the ad.
  Duration maxCacheDuration = const Duration(hours: 8);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? get appOpenLoadTime => _appOpenLoadTime;

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null && _isAdNotExpired();
  }

  bool get isShowingAd => _isShowingAd;

  /// Check if the ad was loaded too long ago.
  bool _isAdNotExpired() {
    if (_appOpenLoadTime == null) return false;
    return DateTime.now()
            .difference(_appOpenLoadTime!)
            .compareTo(maxCacheDuration) <
        0;
  }

  /// Load an app open ad.
  void loadAd() {
    // Check if App Open ads are enabled
    if (!(myAds['AppOpen'] ?? false)) {
      print('App Open Ad disabled in Firebase config');
      return;
    }

    if (_isLoadingAd || isAdAvailable) {
      return;
    }
  String id = myAds['AppOpenVID'] ?? 'ca-app-pub-9756236136807053/9898814312';
  // String id = 'ca-app-pub-3940256099942544/9257395921';
    _isLoadingAd = true;
    AppOpenAd.load(
      // adUnitId: AppConstant.appOpenAdd,
      //  adUnitId: kDebugMode ? 'ca-app-pub-3940256099942544/9257395921' : AdHelper.appOpenAdUnitId,
       adUnitId:id,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print('App Open Ad loaded successfully');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
          _isLoadingAd = false;
        },
        onAdFailedToLoad: (error) {
          print('App Open Ad failed to load: $error');
          _isLoadingAd = false;
        },
      ),
    );
  }

  /// Shows the app open ad if available and conditions are met.
  void showAdIfAvailable() {
    // Check if App Open ads are enabled
    if (!(myAds['AppOpen'] ?? false)) {
      print('App Open Ad disabled in Firebase config');
      return;
    }

    if (!isAdAvailable) {
      print('App Open Ad not available');
      return;
    }

    if (_isShowingAd) {
      print('App Open Ad already showing');
      return;
    }

    // Don't show if interstitial was showing when app went to background
    if (_wasInterstitialShowingWhenBackgrounded) {
      print('Interstitial was showing when backgrounded, skipping App Open Ad');
      _wasInterstitialShowingWhenBackgrounded = false;
      return;
    }

    // Only show when app resumes from background
    if (!_isAppInBackground) {
      print('App was not in background, skipping App Open Ad');
      return;
    }

    _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('App Open Ad showed full screen content');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('App Open Ad failed to show: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _resetAppState();
      },
      onAdDismissedFullScreenContent: (ad) {
        print('App Open Ad dismissed');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        _resetAppState();
        // Immediately load a new ad for next time
        Future.delayed(const Duration(milliseconds: 100), () {
          loadAd();
        });
      },
    );

    _appOpenAd!.show();
  }

  /// Call this when app goes to background
  void onAppPaused({bool interstitialWasShowing = false}) {
    _isAppInBackground = true;
    _wasInterstitialShowingWhenBackgrounded = interstitialWasShowing;
    print(
      'App paused - background: $_isAppInBackground, interstitial was showing: $_wasInterstitialShowingWhenBackgrounded',
    );
  }

  /// Call this when an interstitial ad starts showing
  void onInterstitialAdShowing() {
    if (_isAppInBackground) {
      _wasInterstitialShowingWhenBackgrounded = true;
    }
  }

  /// Call this when app resumes from background
  void onAppResumed() {
    print('App resumed from background');
    if (_isAppInBackground) {
      // Show ad immediately if available
      if (isAdAvailable) {
        showAdIfAvailable();
      } else {
        print('App Open Ad not ready when resumed');
        _resetAppState();
      }
    }
  }

  /// Initialize and preload first ad (call this early in app lifecycle)
  void initialize() {
    print('Initializing App Open Ad Manager');
    // Only initialize if App Open ads are enabled
    if (myAds['AppOpen'] ?? false) {
      if (!isAdAvailable && !_isLoadingAd) {
        loadAd();
      }
    } else {
      print('App Open Ad disabled - skipping initialization');
    }
  }

  /// Ensure ad is always ready (call this periodically)
  void ensureAdReady() {
    // Only ensure ad is ready if App Open ads are enabled
    if (myAds['AppOpen'] ?? false) {
      if (!isAdAvailable && !_isLoadingAd) {
        print('Ensuring App Open Ad is ready');
        loadAd();
      }
    }
  }

  /// Reset app state after ad is shown/dismissed
  void _resetAppState() {
    _isAppInBackground = false;
    _wasInterstitialShowingWhenBackgrounded = false;
  }

  /// Call this to dispose resources
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
  }
}
