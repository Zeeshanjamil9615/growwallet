import 'package:flutter/material.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class LoadingScreen extends StatefulWidget {
  final Function() onComplete;
  final bool hideLoadingText;
  final String adUnitId;

   LoadingScreen({
    super.key,
    required this.onComplete,
    this.hideLoadingText = false,
    required this.adUnitId,
  });

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  InterstitialAd? _interstitialAd;
  bool _showBlackScreen = false;
  bool _adLoaded = false;

  @override
  void initState() {
    super.initState();

    loadAds();
  }

  void loadAds() {
    const adRequest = AdRequest();
    InterstitialAd.load(
      adUnitId: widget.adUnitId,
      request: adRequest,
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          setState(() {
            _interstitialAd = ad;
            _adLoaded = true;
          });
          showAds();
        },
        onAdFailedToLoad: (LoadAdError error) {
          widget.onComplete();
        },
      ),
    );
    Future.delayed(const Duration(seconds: 8), () {
      print('add dispose after 8 sec');
      if (!_adLoaded) {
        _interstitialAd?.dispose();
        widget.onComplete();
      }
    });
  }

  void showAds() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          setState(() {
            _showBlackScreen = true;
          });

          Future.delayed(const Duration(milliseconds: 500), () {
            widget.onComplete();
          });
        },
        onAdFailedToShowFullScreenContent: (ad, AdError error) {
          ad.dispose();
          widget.onComplete();
        },
      );
      _interstitialAd!.show();
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    // bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      // backgroundColor:,
      body: Center(
        child:
            _showBlackScreen
                ? const SizedBox.expand()
                : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.black),
                    if (!widget.hideLoadingText) ...[
                      SizedBox(height: 15),
                      Text(
                        'Loading Advertisement',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ],
                  ],
                ),
      ),
    );
  }
}
