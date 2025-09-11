import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gcoin/main.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../utils/ad_helper.dart';
import '../../../utils/app_colors.dart';
import '../../homescreen/home_controller.dart';
import 'mineg_controller.dart';

class MineGScreen extends StatefulWidget {
  const MineGScreen({super.key});

  @override
  State<MineGScreen> createState() => _MineGScreenState();
}

class _MineGScreenState extends State<MineGScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final MineGController _controller = Get.put(MineGController());
  final HomeController _homeController = Get.find<HomeController>();

  // Variables for native ad
  // NativeAd? _nativeAd;
  // bool _isNativeAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    // Load banner and native ads after a small delay
    Future.delayed(const Duration(milliseconds: 500), () {
          if(myAds['BannerRateNetwork'] == true){
_loadBottomBannerAd();
}
      // _listenToAdSettings();
      // if(myAds['Nat'] == true){
      //   _loadNativeAd();
      // }
    });
  }


  bool _shouldShowAds = false; // Add this variable

  StreamSubscription? _adSettingsSubscription; // Add this

  // Replace _checkAdSettings with this listener approach
  // void _listenToAdSettings() {
  //   print("Setting up Firestore listener...");

  //   _adSettingsSubscription = FirebaseFirestore.instance
  //       .collection('app_settings')
  //       .doc('RATE_NETWORK')
  //       .snapshots()
  //       .listen(
  //         (DocumentSnapshot doc) {
  //       print("Listener triggered - Document exists: ${doc.exists}");
  //       print("Listener - Document data: ${doc.data()}");

  //       if (doc.exists) {
  //         Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
  //         bool showAds = data?['rateNetwork'] ?? false;

  //         print("Listener - show_ads value: $showAds");

  //         setState(() {
  //           _shouldShowAds = showAds;
  //         });

  //         if (_shouldShowAds && _nativeAd == null) {
  //           print("Listener - Loading ads...");
  //           _loadNativeAd();
  //         } else if (!_shouldShowAds && _nativeAd != null) {
  //           print("Listener - Disposing ads...");
  //           _nativeAd?.dispose();
  //           _nativeAd = null;

  //           setState(() {
  //             _isNativeAdLoaded = false;
  //           });
  //         }
  //       } else {
  //         print("Listener - Document does not exist, creating it...");
  //         _createDefaultAdSettings();
  //       }
  //     },
  //     onError: (error) {
  //       print("Listener error: $error");
  //       setState(() {
  //         _shouldShowAds = false;
  //       });
  //     },
  //   );
  // }

  // // Method to create default settings if document doesn't exist
  // Future<void> _createDefaultAdSettings() async {
  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('app_settings')
  //         .doc('RATE_NETWORK')
  //         .set({
  //       'rateNetwork': true, // Default value
  //     });
  //     print("Default ad settings created");
  //   } catch (e) {
  //     print("Error creating default ad settings: $e");
  //   }
  // }


  // void _loadNativeAd() {
  //   _nativeAd = NativeAd(
  //     adUnitId: kDebugMode ? "ca-app-pub-3940256099942544/2247696110" : AdHelper.nativeAdUnitId,
  //     factoryId: 'listTile', // Make sure this matches your registered factory
  //     request: const AdRequest(),
  //     listener: NativeAdListener(
  //       onAdLoaded: (Ad ad) {
  //         if (kDebugMode) {
  //           print('NativeAd loaded successfully.');
  //         }
  //         if (mounted) {
  //           setState(() {
  //             _nativeAd = ad as NativeAd;
  //             _isNativeAdLoaded = true;
  //           });
  //         }
  //       },
  //       onAdFailedToLoad: (Ad ad, LoadAdError error) {
  //         if (kDebugMode) {
  //           print('NativeAd failed to load: $error');
  //         }
  //         ad.dispose();
  //         if (mounted) {
  //           setState(() {
  //             _isNativeAdLoaded = false;
  //           });
  //         }
  //       },
  //       onAdOpened: (Ad ad) {
  //         if (kDebugMode) {
  //           print('NativeAd opened');
  //         }
  //       },
  //       onAdClosed: (Ad ad) {
  //         if (kDebugMode) {
  //           print('NativeAd closed');
  //         }
  //       },
  //     ),
  //   );
  //   _nativeAd!.load();
  // }
   // Banner Ad variables
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
 void _loadBottomBannerAd() {
    String id = myAds['BannerRateNetworkVID'] ?? 'ca-app-pub-9756236136807053/4298987360';
    // String id = 'ca-app-pub-3940256099942544/6300978111';
    _bottomBannerAd = BannerAd(
      // adUnitId: kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : AdHelper.bannerNewAdUnitId,
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (kDebugMode) {
            print('BannerAd loaded.');
          }
          setState(() {
            _isBottomBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          if (kDebugMode) {
            print('BannerAd failed to load: $error');
          }
          ad.dispose();
          setState(() {
            _isBottomBannerAdLoaded = false;
          });
        },
      ),
    );
    _bottomBannerAd!.load();
  }
  @override
  void dispose() {
    // _nativeAd?.dispose(); // Dispose the native ad
    _pulseController.dispose();
    _adSettingsSubscription?.cancel(); // Cancel the listener
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       bottomNavigationBar: _buildBottomBannerAd(),
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppBar(
        backgroundColor: MyColor.getAppbarBgColor(),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: MyColor.getAppbarTitleColor(),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_controller.getBalance()} ',
              style: TextStyle(
                color: MyColor.getAppbarTitleColor(),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'G',
              style: TextStyle(
                color: MyColor.getGCoinPrimaryColor(),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        )),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'EN',
                  style: TextStyle(
                    color: MyColor.getGCoinPrimaryColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.language,
                  color: MyColor.getGCoinPrimaryColor(),
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Mining Session Timer Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: MyColor.getGCoinHeroGradient(),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.access_time,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _homeController.isMining.value
                            ? 'Gaming Session Ends'
                            : 'No Active Gaming Session',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                        _homeController.isMining.value
                            ? _homeController.formatTime(_homeController.miningTimeLeft.value)
                            : '00:00:00',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Total Mining Rate Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MyColor.getGCoinCardColor(),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MyColor.getGCoinDividerColor(),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColor.getGCoinShadowColor(),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total gaming rate:',
                        style: TextStyle(
                          color: MyColor.getTextColor(),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "${(_homeController.userData['mine_rate'])} G/ ${(int.parse(_homeController.userData['total_mine_time'])/60).toStringAsFixed(0)}m",
                              style: TextStyle(
                                color: MyColor.getGCoinPrimaryColor(),
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: MyColor.getGCoinPrimaryColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Add the Native Ad here
                // _buildNativeAd(),

                const SizedBox(height: 24),

                // Base Rate Section
                _buildExpandableSection(
                  title: 'Base Rate',
                  value: '${(_homeController.userData['mine_rate'])} G/ ${(int.parse(_homeController.userData['total_mine_time'])/60).toStringAsFixed(0)}m',
                  color: Colors.red.shade50,
                  borderColor: Colors.red,
                  icon: Icons.info_outline,
                  content: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Your base gaming rate is calculated based on your account verification and activity level.',
                      style: TextStyle(
                        color: MyColor.getTextColor(),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Widget _buildNativeAd() {
  //   if (_isNativeAdLoaded && _nativeAd != null) {
  //     return Container(
  //       height: 120, // Adjust height as needed for your ad
  //       margin: const EdgeInsets.symmetric(vertical: 8),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.1),
  //             blurRadius: 8,
  //             offset: const Offset(0, 2),
  //           ),
  //         ],
  //       ),
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(12),
  //         child: AdWidget(ad: _nativeAd!),
  //       ),
  //     );
  //   } else {
  //     return Container(
  //       height: 120, // Reserve space to avoid layout shifts
  //       margin: const EdgeInsets.symmetric(vertical: 8),
  //       decoration: BoxDecoration(
  //         color: Colors.grey.shade200,
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Center(
  //         child: _isNativeAdLoaded == false && _nativeAd == null
  //             ? Text(
  //           'Loading Ad...',
  //           style: TextStyle(
  //             color: Colors.black,
  //             fontSize: 14,
  //           ),
  //         )
  //             : Icon(
  //           Icons.ads_click,
  //           color: Colors.grey.shade400,
  //           size: 32,
  //         ),
  //       ),
  //     );
  //   }
  // }

  Widget _buildExpandableSection({
    required String title,
    required String value,
    required Color color,
    required Color borderColor,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          leading: Icon(icon, color: borderColor),
          title: Text(
            title,
            style: TextStyle(
              color: borderColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: borderColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.expand_more, color: borderColor),
            ],
          ),
          children: [content],
        ),
      ),
    );
  }
   Widget _buildBottomBannerAd() {
    return _isBottomBannerAdLoaded
        ? Container(
      width: _bottomBannerAd!.size.width.toDouble(),
      height: _bottomBannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bottomBannerAd!),
    )
        :
         myAds['BannerRateNetwork'] == false?
         SizedBox.shrink() : Container( width: _bottomBannerAd!.size.width.toDouble(),
      height: _bottomBannerAd!.size.height.toDouble(),child: Center(child: Text("Loading Ads..."),),); 
    //     : Container(
    //   width: AdSize.banner.width.toDouble(),
    //   height: AdSize.banner.height.toDouble(),
    //   child: const Center(
    //     child: Text('Loading Advertisement'),
    //   ),
    // );
  }
}