import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gcoin/main.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../api_service/api_service.dart';
import '../../../utils/ad_helper.dart';
import '../../../utils/app_colors.dart';


// Declare a global counter for the interstitial ad
int walletScreenOpenCount = 0;

class WalletScreen extends StatefulWidget {
  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  bool _isRefreshing = false;

  Map<String, dynamic>? _walletData;
  List<dynamic> _transactions = [];
  double _miningBalance = 0.0;
  double _referralBalance = 0.0;

  // Banner Ad variables
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;



  // Interstitial Ad variable
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadWalletData();
    // _listenToAdSettings();
    if(myAds['BannerWallet'] == true){
_loadBottomBannerAd();
}
// if(myAds['IntWallet'] == true){
// _loadInterstitialAd();
// }
  }
  bool _shouldShowAds = false; // Add this variable

  StreamSubscription? _adSettingsSubscription; // Add this

  // // Replace _checkAdSettings with this listener approach
  // void _listenToAdSettings() {
  //   print("Setting up Firestore listener...");

  //   _adSettingsSubscription = FirebaseFirestore.instance
  //       .collection('app_settings')
  //       .doc('WALLET')
  //       .snapshots()
  //       .listen(
  //         (DocumentSnapshot doc) {
  //       print("Listener triggered - Document exists: ${doc.exists}");
  //       print("Listener - Document data: ${doc.data()}");

  //       if (doc.exists) {
  //         Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
  //         bool showAds = data?['wallet'] ?? false;

  //         print("Listener - show_ads value: $showAds");

  //         setState(() {
  //           _shouldShowAds = showAds;
  //         });

  //         if (_shouldShowAds && _bottomBannerAd == null) {
  //           print("Listener - Loading ads...");
  //           _loadAds();
  //         } else if (!_shouldShowAds && _bottomBannerAd != null) {
  //           print("Listener - Disposing ads...");
  //           _bottomBannerAd?.dispose();
  //           _bottomBannerAd = null;
  //           _interstitialAd?.dispose();
  //           _interstitialAd = null;
  //           setState(() {
  //             _isBottomBannerAdLoaded = false;
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
  //         .doc('WALLET')
  //         .set({
  //       'wallet': true, // Default value
  //     });
  //     print("Default ad settings created");
  //   } catch (e) {
  //     print("Error creating default ad settings: $e");
  //   }
  // }


  void _loadAds() {
    _loadBottomBannerAd();
    // _showInterstitialAdIfReady();
  }

  void _loadBottomBannerAd() {
    String id = myAds['BannerWalletVID'] ?? 'ca-app-pub-9756236136807053/5428236207';
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

  // void _loadInterstitialAd() {
  //   // String id = myAds['IntWalletVID'] ?? 'ca-app-pub-9756236136807053/1488991193';
  //   String id = 'ca-app-pub-3940256099942544/1033173712';
  //   InterstitialAd.load(
  //     // adUnitId: kDebugMode ? 'ca-app-pub-3940256099942544/1033173712' : AdHelper.interstitialAdUnitId,
  //     adUnitId: id,
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (InterstitialAd ad) {
  //         if (kDebugMode) {
  //           print('InterstitialAd loaded.');
  //         }
  //         _interstitialAd = ad;
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         if (kDebugMode) {
  //           print('InterstitialAd failed to load: $error');
  //         }
  //       },
  //     ),
  //   );
  // }

  // void _showInterstitialAdIfReady() {
  //   walletScreenOpenCount++;
  //   if (kDebugMode) {
  //     print("Wallet screen opened $walletScreenOpenCount times.");
  //   }

  //   if (walletScreenOpenCount % 2 == 0) {
  //     if (_interstitialAd == null) {
  //       if (kDebugMode) {
  //         print('Ad is not ready yet, loading new one.');
  //       }
  //       _loadInterstitialAd();
  //       return;
  //     }

  //     _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
  //       onAdShowedFullScreenContent: (InterstitialAd ad) {
  //         if (kDebugMode) {
  //           print('onAdShowedFullScreenContent');
  //         }
  //       },
  //       onAdDismissedFullScreenContent: (InterstitialAd ad) {
  //         if (kDebugMode) {
  //           print('$ad onAdDismissedFullScreenContent');
  //         }
  //         ad.dispose();
  //         _loadInterstitialAd(); // Load the next ad immediately
  //       },
  //       onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
  //         if (kDebugMode) {
  //           print('$ad onAdFailedToShowFullScreenContent: $error');
  //         }
  //         ad.dispose();
  //         _loadInterstitialAd();
  //       },
  //     );

  //     _interstitialAd!.show();
  //     _interstitialAd = null; // Clear the ad after showing
  //   } else {
  //     // If not an even-numbered open, just preload the ad for the next time
  //     _loadInterstitialAd();
  //   }
  // }

  // Existing methods...
  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    _pulseController.repeat(reverse: true);
  }

  Future<void> _loadWalletData() async {
    try {
      final response = await _apiService.getWalletData();
      if (response != null && response.statusCode == 200) {
        setState(() {
          _walletData = response.data;
          _miningBalance = double.parse(_walletData!['user']['mining_balance']);
          _referralBalance = double.parse(_walletData!['user']['referal_balance']);
          _transactions = _walletData!['transactions'] ?? [];
          _isLoading = false;
        });

        _slideController.forward();
        _fadeController.forward();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Get.snackbar('Error', 'Failed to load wallet data');
    }
  }

  Future<void> _refreshWalletData() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadWalletData();
    setState(() {
      _isRefreshing = false;
    });
  }


  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _interstitialAd?.dispose();
    _adSettingsSubscription?.cancel(); // Cancel the listener
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      body: _isLoading
          ? _buildLoadingState()
          : RefreshIndicator(
        onRefresh: _refreshWalletData,
        color: MyColor.getGCoinPrimaryColor(),
        backgroundColor: MyColor.getCardBg(),
        child: CustomScrollView(
          physics: BouncingScrollPhysics(),
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildBalanceCards(),
                  SizedBox(height: 20),
                  _buildTransactionSection(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBannerAd(),
    );
  }
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MyColor.getCardBg(),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: MyColor.getGCoinShadowColor(),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(MyColor.getGCoinPrimaryColor()),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Loading Wallet...',
            style: TextStyle(
              color: MyColor.getTextColor(),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: MyColor.getAppbarBgColor(),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: FadeTransition(
          opacity: _fadeAnimation,
          child: Text(
            'Grow Coin Wallet',
            style: TextStyle(
              color: MyColor.headingTextColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: MyColor.getGCoinPrimaryGradient(),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: MyColor.getAppbarTitleColor(),
          ),
          onPressed: _refreshWalletData,
        ),
      ],
    );
  }

  Widget _buildBalanceCards() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Total Balance Card
              _buildTotalBalanceCard(),
              SizedBox(height: 20),
              // Balance Breakdown Cards
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceCard(
                      'Mining Balance',
                      _miningBalance,
                      Icons.diamond,
                      MyColor.getGCoinPrimaryColor(),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: _buildBalanceCard(
                      'Referral Balance',
                      _referralBalance,
                      Icons.people,
                      MyColor.getGCoinSecondaryColor(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBalanceCard() {
    double totalBalance = _miningBalance + _referralBalance;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: MyColor.getGCoinHeroGradient(),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Colors.white,
                  size: 40,
                ),
                SizedBox(height: 15),
                Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '${totalBalance.toStringAsFixed(2)} G',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MyColor.getCardBg(),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              color: MyColor.getTextColor().withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 5),
          Text(
            '${amount.toStringAsFixed(2)} G',
            style: TextStyle(
              color: MyColor.getTextColor(),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transactions',
                  style: TextStyle(
                    color: MyColor.getTextColor(),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all transactions
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: MyColor.getGCoinPrimaryColor(),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return Container(
        margin: EdgeInsets.all(20),
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: MyColor.getCardBg(),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: MyColor.getGCoinShadowColor(),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 60,
              color: MyColor.getTextColor().withOpacity(0.3),
            ),
            SizedBox(height: 15),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: MyColor.getTextColor().withOpacity(0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return _buildTransactionItem(transaction, index);
      },
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction, int index) {
    final amount = double.parse(transaction['amount']);
    final type = transaction['type'] ?? 'Transaction';
    final remarks = transaction['remarks'] ?? '';
    final createdAt = transaction['created_at'];
    final isPositive = amount > 0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      margin: EdgeInsets.only(bottom: 15),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MyColor.getCardBg(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: MyColor.getGCoinDividerColor(),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: MyColor.getGCoinShadowColor(),
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                _getTransactionIconByType(type),
                color: MyColor.getGCoinPrimaryColor(),
                size: 24,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          type,
                          style: TextStyle(
                            color: MyColor.getTextColor(),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isPositive
                              ? MyColor.getGCoinSuccessColor()
                              : MyColor.getGCoinLossColor()).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${isPositive ? '+' : '-'}${amount.toStringAsFixed(2)} G',
                          style: TextStyle(
                            color: isPositive
                                ? MyColor.getGCoinSuccessColor()
                                : MyColor.getGCoinLossColor(),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    createdAt,
                    style: TextStyle(
                      color: MyColor.getTextColor().withOpacity(0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (remarks.isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      remarks,
                      style: TextStyle(
                        color: MyColor.getTextColor().withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTransactionIconByType(String type) {
    switch (type.toLowerCase()) {
      case 'commission':
        return Icons.swap_horiz;
      case 'mining reward':
      case 'mining':
        return Icons.diamond;
      case 'referral bonus':
      case 'referral':
        return Icons.people;
      case 'transfer':
        return Icons.swap_horiz;
      case 'bonus':
        return Icons.card_giftcard;
      case 'withdrawal':
        return Icons.arrow_upward;
      case 'deposit':
        return Icons.arrow_downward;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Widget _buildBottomBannerAd() {
    return _isBottomBannerAdLoaded
        ? Container(
      width: _bottomBannerAd!.size.width.toDouble(),
      height: _bottomBannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bottomBannerAd!),
    )
        : myAds['BannerWallet'] == false?
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




