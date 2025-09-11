import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gcoin/main.dart';
import 'package:gcoin/screens/drawer/kyc/kyc_screen.dart';
import 'dart:math';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gcoin/utils/ad_helper.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/drawer.dart';
import 'animation.dart';
import 'home_controller.dart';


class PiNetworkHomeScreen extends StatefulWidget {
  const PiNetworkHomeScreen({super.key});

  @override
  PiNetworkHomeScreenState createState() => PiNetworkHomeScreenState();
}

class PiNetworkHomeScreenState extends State<PiNetworkHomeScreen>
    with TickerProviderStateMixin {
  final HomeController _homeController = Get.find<HomeController>();
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers
    _initializeAnimations();

    // Start animations
    _startAnimations();
    if (myAds['BannerHome'] == true) {
      _loadBottomBannerAd();
    }

    // Show community dialog after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 1500), () {
        if (mounted) {
          _showCommunityJoinDialog();
        }
      });
    });
  }

  // Add this method to your PiNetworkHomeScreenState class
  void _showCommunityJoinDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B2E1C), Color(0xFF0D1F0F)],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Color(0xFF7ED321).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF7ED321).withOpacity(0.2),
                  blurRadius: 25,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(0xFF7ED321).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF7ED321),
                        size: 20,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10),

                // Community icon
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7ED321), Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF7ED321).withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),

                SizedBox(height: 20),

                // Title
                Text(
                  'Join Our Community!',
                  style: TextStyle(
                    color: Color(0xFFE8F5E8),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12),

                // Description
                Text(
                  'Connect with fellow gamers, get updates, tips, and be part of the Grow Network community!',
                  style: TextStyle(
                    color: Color(0xFFCED9CE),
                    fontSize: 16,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 30),

                // Buttons
                Column(
                  children: [
                    // WhatsApp Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF25D366), Color(0xFF1DA851)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF25D366).withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed:
                            () => _launchURL(
                              'https://whatsapp.com/channel/0029Vb6BwuyLNSZyl9g2TO1G',
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'WhatsApp',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12),

                    // Telegram Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0088CC), Color(0xFF006699)],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF0088CC).withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed:
                            () =>
                                _launchURL('https://t.me/+SmOkdL9bZO01NzQ0'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(
                              FontAwesomeIcons.telegram,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Telegram',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Skip button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(color: Color(0xFFCED9CE), fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Add this method to handle URL launching
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        Navigator.of(context).pop(); // Close dialog after successful launch
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          'Could not open the link. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
  void _loadBottomBannerAd() {
    // Only load if we should show ads
    if (_bottomBannerAd != null) {
      return;
    }
    String id =
        myAds['BannerHomeVID'] ?? 'ca-app-pub-9756236136807053/8665623693';
    print('the banner id comes from firebase $id');
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

  Widget _buildBottomBannerAd() {
    // Only show if ads are enabled and loaded
    // if (!_shouldShowAds) return SizedBox.shrink();
    // myAds['BannerTeamTree'] == false ? return SizedBox.shrink() : null;

    return _isBottomBannerAdLoaded
        ? Container(
          width: _bottomBannerAd!.size.width.toDouble(),
          height: _bottomBannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bottomBannerAd!),
        )
        : myAds['BannerHome'] == false
        ? SizedBox.shrink()
        : Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            // color: Colors.black,
            border: Border.all(color: Colors.black),
          ),
          width: Get.size.width,
          height: 70,
          child: Center(child: Text("Loading Ads...")),
        );
    //     : Container(
    //   width: AdSize.banner.width.toDouble(),
    //   height: AdSize.banner.height.toDouble(),
    //   // color: Colors.red,
    //   child: Center(
    //     child: Text('loading advertisement'),
    //   ),
    // );
  }

  void _initializeAnimations() {
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: Duration(seconds: 10),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.bounceOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_homeController.isLoading.value) {
        return Scaffold(
          backgroundColor: Color(0xFF0D1F0F),
          body: Center(
            child: CircularProgressIndicator(color: Color(0xFF7ED321)),
          ),
        );
      }

      // Add KYC check right after the loading check
      if (_homeController.userData['kyc_form'] == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.to(() => KYCScreen());
        });
      }

      return Scaffold(
        backgroundColor: Color(0xFF0D1F0F),
        drawer: GNetworkDrawer(),
        body: SafeArea(
          child: RefreshIndicator(
            color: Color(0xFF7ED321),
            backgroundColor: Color(0xFF0D1F0F),
            onRefresh: () async {
              await _homeController.fetchDashboardData();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Add KYC message banner if kyc_form is true
                  if (_homeController.userData['kyc_form'] == true &&
                      _homeController.userData['kyc_message'] != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _homeController.userData['kyc_message']
                                  .toString(),
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Enhanced Header with gradient background
                  _buildEnhancedHeader(),
                  _buildBottomBannerAd(),
                  // Stats Cards Section


                  // Enhanced Game Apps Section

                  // Pioneer Posts Section
                  _buildPioneerPostsSection(),

                  SizedBox(height: 8),

                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButtons(),
      );
    });
  }

  // Updated _buildEnhancedHeader method
  Widget _buildEnhancedHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF7ED321).withOpacity(0.1),
              Color(0xFF4CAF50).withOpacity(0.05),
              Color(0xFF0D1F0F),
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Column(
          children: [
            // Top navigation bar with slide animation
            SlideTransition(
              position: _slideAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (BuildContext context) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: IconButton(
                          onPressed: () => Scaffold.of(context).openDrawer(),
                          icon: Icon(
                            Icons.menu_rounded,
                            color: Color(0xFFE8F5E8),
                            size: 32,
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF1B2E1C),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF7ED321).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'EN',
                              style: TextStyle(
                                color: Color(0xFFE8F5E8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.language_rounded,
                              color: Color(0xFF7ED321),
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // G Balance Section with digit animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7ED321).withOpacity(0.15),
                            Color(0xFF4CAF50).withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color(0xFF7ED321).withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF7ED321).withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Animated Balance Display with Digit Animation
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              // Use Obx to watch the animated balance changes
                              Obx(() {
                                final displayValue =
                                    _homeController.isMining.value
                                        ? _homeController.getAnimatedBalance()
                                        : double.parse(
                                          _homeController.getBalance(),
                                        ).toStringAsFixed(3);

                                return AnimatedDigitDisplay(
                                  value: displayValue,
                                  duration: Duration(milliseconds: 600),
                                  textStyle: TextStyle(
                                    color: Color(0xFFE8F5E8),
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5,
                                    shadows: [
                                      Shadow(
                                        color: Color(
                                          0xFF7ED321,
                                        ).withOpacity(0.3),
                                        offset: Offset(0, 2),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              SizedBox(width: 8),
                              AnimatedBuilder(
                                animation: _rotationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle:
                                        _rotationAnimation.value * 2 * 3.14159,
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        color: Color(0xFF7ED321),
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(
                                            color: Color(
                                              0xFF7ED321,
                                            ).withOpacity(0.5),
                                            offset: Offset(0, 2),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          // Balance Label with Mining Status
                          Obx(() {
                            return Column(
                              children: [
                                Text(
                                  _homeController.isMining.value
                                      ? 'Gaming Balance'
                                      : 'Available Balance',
                                  style: TextStyle(
                                    color: Color(0xFFCED9CE),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                                // Mining Progress Indicator
                                if (_homeController.isMining.value) ...[
                                  SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF1B2E1C),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor:
                                          _homeController.getMiningProgress(),
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 500),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF7ED321),
                                              Color(0xFF4CAF50),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(
                                                0xFF7ED321,
                                              ).withOpacity(0.4),
                                              blurRadius: 4,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Earned: ${_homeController.getEstimatedReward()} G',
                                        style: TextStyle(
                                          color: Color(0xFF7ED321),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        'Rate: ${(_homeController.userData['mine_rate'])} G/ ${(int.parse(_homeController.userData['total_mine_time']) / 60).toStringAsFixed(0)}m',
                                        style: TextStyle(
                                          color: Color(0xFFCED9CE),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// Update _buildFloatingActionButtons in homescreen.dart
  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        
        SizedBox(height: 12),
        _buildAnimatedStatFAB(
          icon: Icons.people_outline_rounded,
          value: _homeController.getNetworkCount(),
          backgroundColor: Color(0xFF66BB6A),
          delay: 400,
        ),
        SizedBox(height: 12),
        _buildAnimatedFAB(
          icon: Icons.send_rounded,
          backgroundColor: Color(0xFF7ED321),
          iconColor: Colors.white,
          heroTag: "invite",
          label: 'Invite',
          delay: 800,
          onPressed: () {
            _homeController.shareReferralCode();
          },
        ),
      ],
    );
  }

  // Update _buildMiningFAB to include onTap
   Widget _buildAnimatedFAB({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required String heroTag,
    String? label,
    int delay = 0,
    VoidCallback? onPressed, // Add this parameter
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: onPressed, // Use the passed callback
                backgroundColor: backgroundColor,
                elevation: 0,
                mini: true,
                heroTag: heroTag,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    label != null
                        ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: iconColor, size: 16),
                            Text(
                              label,
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                        : Icon(icon, color: iconColor, size: 20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStatFAB({
    required IconData icon,
    required String value,
    required Color backgroundColor,
    int delay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, animationValue, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - animationValue), 0),
          child: Opacity(
            opacity: animationValue,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon, color: Colors.white, size: 18),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPioneerPostsSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Post description with modern card design
                  // Container(
                  //   padding: EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: Color(0xFF1B2E1C),
                  //     borderRadius: BorderRadius.circular(16),
                  //     border: Border.all(
                  //       color: Color(0xFF7ED321).withOpacity(0.2),
                  //       width: 1,
                  //     ),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Color(0xFF7ED321).withOpacity(0.1),
                  //         blurRadius: 12,
                  //         offset: Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Row(
                  //         children: [
                  //           Container(
                  //             padding: EdgeInsets.symmetric(
                  //               horizontal: 12,
                  //               vertical: 6,
                  //             ),
                  //             decoration: BoxDecoration(
                  //               gradient: LinearGradient(
                  //                 colors: [
                  //                   Color(0xFF7ED321),
                  //                   Color(0xFF4CAF50),
                  //                 ],
                  //               ),
                  //               borderRadius: BorderRadius.circular(12),
                  //             ),
                  //             child: Text(
                  //               '@PiCoreTeam',
                  //               style: TextStyle(
                  //                 color: Colors.white,
                  //                 fontWeight: FontWeight.bold,
                  //                 fontSize: 12,
                  //               ),
                  //             ),
                  //           ),
                  //           Spacer(),
                  //           Text(
                  //             'May 30th - 9:56pm',
                  //             style: TextStyle(
                  //               color: Color(0xFFCED9CE),
                  //               fontSize: 12,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       SizedBox(height: 16),
                  //     ],
                  //   ),
                  // ),
                  // SizedBox(height: 20),
                  _buildCommunityStatsSection(),





                  SizedBox(height: 20),

                  // Recent Activities Timeline
                  _buildRecentActivitiesSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCommunityStatsSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 80 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.5,
                  colors: [
                    Color(0xFF7ED321).withOpacity(0.1),
                    Color(0xFF4CAF50).withOpacity(0.05),
                    Color(0xFF0D1F0F),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Color(0xFF7ED321).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7ED321).withOpacity(0.1),
                    blurRadius: 25,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Community Impact',
                    style: TextStyle(
                      color: Color(0xFFE8F5E8),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAnimatedStat(
                        '400K+',
                        'App installation',
                        Icons.people_rounded,
                        Color(0xFF7ED321),
                      ),
                      _buildAnimatedStat(
                        '170+',
                        'Countries',
                        Icons.public_rounded,
                        Color(0xFF4CAF50),
                      ),
                      _buildAnimatedStat(
                        '400K+',
                        'App User',
                        Icons.apps_rounded,
                        Color(0xFF66BB6A),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedStat(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1500),
      builder: (context, animValue, child) {
        return Column(
          children: [
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: sin(_rotationController.value * 2 * pi) * 0.05,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 32),
                  ),
                );
              },
            ),
            SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(
                begin: 0.0,
                end: double.parse(value.replaceAll(RegExp(r'[^0-9.]'), '')),
              ),
              duration: Duration(seconds: 2),
              builder: (context, animatedValue, child) {
                String displayValue;
                if (value.contains('M')) {
                  displayValue = '${(animatedValue).toStringAsFixed(0)}M+';
                } else if (value.contains('K')) {
                  displayValue = '${(animatedValue).toStringAsFixed(0)}K+';
                } else {
                  displayValue = '${animatedValue.toInt()}+';
                }
                return Text(
                  displayValue,
                  style: TextStyle(
                    color: Color(0xFFE8F5E8),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            Text(
              label,
              style: TextStyle(
                color: Color(0xFFCED9CE),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivitiesSection() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF1B2E1C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Color(0xFF7ED321).withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF7ED321).withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF7ED321), Color(0xFF4CAF50)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Recent Activities',
                        style: TextStyle(
                          color: Color(0xFFE8F5E8),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ..._homeController.logs.map(
                    (log) => Container(
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF7ED321).withOpacity(0.05),
                            Color(0xFF4CAF50).withOpacity(0.03),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF7ED321).withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF7ED321).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.notifications_rounded,
                              color: Color(0xFF7ED321),
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      color: Color(0xFFE8F5E8),
                                      fontSize: 14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: log['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7ED321),
                                        ),
                                      ),
                                      TextSpan(text: ' ${log['action']}'),
                                    ],
                                  ),
                                ),
                                Text(
                                  log['created_at'],
                                  style: TextStyle(
                                    color: Color(0xFFCED9CE),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
