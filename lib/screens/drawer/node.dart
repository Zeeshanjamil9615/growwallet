import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gcoin/main.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../api_service/api_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/custom_snackbar.dart';
import '../homescreen/home_controller.dart';

class EmailVerificationController extends GetxController
    with GetTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController otpController = TextEditingController();
  final FocusNode otpFocusNode = FocusNode();

  late AnimationController animationController;
  late AnimationController pulseController;
  late Animation<double> slideAnimation;
  late Animation<double> pulseAnimation;

  var otpDigits = ['', '', '', ''].obs;
  var currentIndex = 0.obs;
  var isLoading = false.obs;
  var isEmailVerified = false.obs;
  var codeSent = false.obs;
  var verifiedAt = ''.obs;
  var userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeUserData();
    _setupAnimations();
    // Remove the focus listener that was preventing keyboard from opening
  }

  void _initializeUserData() {
    final homeController = Get.find<HomeController>();
    isEmailVerified.value = homeController.userData['email_verified_at'] != null;
    verifiedAt.value = homeController.userData['email_verified_at'] ?? '';
    userEmail.value = homeController.userData['email'] ?? 'your email';
  }

  void _setupAnimations() {
    animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    pulseController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutBack),
    );

    pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: pulseController, curve: Curves.easeInOut),
    );

    animationController.forward();
    pulseController.repeat(reverse: true);
  }

  void onOtpChanged(String value) {
    // Ensure we only process digits and limit to 4 characters
    String filteredValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (filteredValue.length > 4) {
      filteredValue = filteredValue.substring(0, 4);
      otpController.text = filteredValue;
      otpController.selection = TextSelection.fromPosition(
        TextPosition(offset: filteredValue.length),
      );
    }

    for (int i = 0; i < 4; i++) {
      otpDigits[i] = i < filteredValue.length ? filteredValue[i] : '';
    }
    currentIndex.value = filteredValue.length;
  }

  void focusOtpField() {
    if (!codeSent.value) {
      CustomSnackBar.error('Please request a verification code first');
      return;
    }

    // Always request focus when tapping on OTP boxes
    Future.delayed(Duration(milliseconds: 100), () {
      otpFocusNode.requestFocus();
    });
  }

  Future<void> sendVerificationEmail() async {
    isLoading.value = true;
    try {
      final response = await _apiService.sendEmailVerification();
      if (response?.statusCode == 200) {
        codeSent.value = true;
        CustomSnackBar.success('Verification code sent to ${userEmail.value}');
        // Clear any previous OTP
        _clearOtpFields();
        // Focus on OTP field after code is sent
        await Future.delayed(Duration(milliseconds: 300));
        otpFocusNode.requestFocus();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyEmail() async {
    if (otpController.text.length != 4) {
      CustomSnackBar.error('Please enter a valid 4-digit code');
      focusOtpField();
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiService.verifyEmailWithOtp(otpController.text);
      final homeController = Get.find<HomeController>();

      if (response?.statusCode == 200) {
        await homeController.fetchDashboardData();
        isEmailVerified.value = true;
        verifiedAt.value = homeController.userData['email_verified_at'] ?? '';
        codeSent.value = false;
        CustomSnackBar.success('Email verified successfully!');
      } else {
        // Clear OTP and refocus on invalid code
        _clearOtpFields();
        CustomSnackBar.error('Invalid verification code. Please try again.');
        // Delay focus to ensure error message is shown first
        await Future.delayed(Duration(milliseconds: 500));
        focusOtpField();
      }
    } catch (e) {
      CustomSnackBar.error('An error occurred. Please try again.');
      // Focus back on error
      await Future.delayed(Duration(milliseconds: 500));
      focusOtpField();
    } finally {
      isLoading.value = false;
    }
  }

  void _clearOtpFields() {
    otpController.clear();
    otpDigits.value = ['', '', '', ''];
    currentIndex.value = 0;
  }

  void clearOtp() {
    _clearOtpFields();
    focusOtpField();
  }

  @override
  void onClose() {
    otpFocusNode.dispose();
    animationController.dispose();
    pulseController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
/// started screen from here 
class EmailVerificationScreen extends StatefulWidget {
  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final EmailVerificationController controller =
  Get.put(EmailVerificationController());
// Banner Ad variables
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdLoaded = false;
  @override
  void initState() {
    super.initState();
        if(myAds['BannerNode'] == true){
_loadBottomBannerAd();
}
  }
   void _loadBottomBannerAd() {
    String id = myAds['BannerNodeVID'] ?? 'ca-app-pub-9756236136807053/6151140998';
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
    _bottomBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar: _buildBottomBannerAd(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              MyColor.getScreenBgColor(),
              MyColor.getGCoinSurfaceColor(),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              SizedBox(
                height: screenHeight * 0.25,
                child: Stack(
                  children: [
                    // Background decoration
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: MyColor.getGCoinPrimaryGradient(),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
                              blurRadius: 40,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Header content
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top navigation row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Back button
                              ScaleTransition(
                                scale: controller.pulseAnimation,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.chevron_left,
                                      color: MyColor.getTextColor(),
                                      size: 24,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ),

                              // Balance and language
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Obx(() {
                                      final homeController = Get.find<HomeController>();
                                      return Text(
                                        '${homeController.getBalance()} G',
                                        style: TextStyle(
                                          color: MyColor.getTextColor(),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      );
                                    }),
                                  ),
                                  SizedBox(width: 12),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'EN',
                                          style: TextStyle(
                                            color: MyColor.getTextColor(),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.expand_more,
                                          color: MyColor.getTextColor(),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          Spacer(),

                          // Title section
                          SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(controller.slideAnimation.value, 0),
                              end: Offset.zero,
                            ).animate(controller.animationController),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email Verification',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: MyColor.getHeadingTextColor(),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Secure your account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: MyColor.getSecondaryTextColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Section
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: MyColor.getGCoinCardColor(),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColor.getGCoinShadowColor(),
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: MyColor.getGCoinDividerColor(),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: 32),

                        Obx(() => controller.isEmailVerified.value
                            ? _buildVerifiedStatus()
                            : _buildVerificationForm()),

                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedStatus() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: MyColor.getGCoinSuccessGradient(),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.white, size: 50),
        ),
        SizedBox(height: 24),
        Text(
          'Email Verified',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: MyColor.getGCoinSuccessColor(),
          ),
        ),
        SizedBox(height: 8),
        Obx(() => Text(
          'Your email ${controller.userEmail.value} was verified',
          style: TextStyle(
            fontSize: 16,
            color: MyColor.getSecondaryTextColor(),
          ),
        )),
        SizedBox(height: 8),
        Obx(() => controller.verifiedAt.value.isNotEmpty
            ? Text(
          'Verified on ${_formatVerifiedDate(controller.verifiedAt.value)}',
          style: TextStyle(
            fontSize: 14,
            color: MyColor.getSecondaryTextColor(),
          ),
        )
            : SizedBox()),
      ],
    );
  }

  Widget _buildVerificationForm() {
    return Column(
      children: [
        // Description with icon
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                MyColor.getGCoinSecondaryColor().withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MyColor.getGCoinPrimaryColor().withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: MyColor.getGCoinPrimaryGradient(),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(Icons.email, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify your email address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MyColor.getHeadingTextColor(),
                      ),
                    ),
                    SizedBox(height: 8),
                    Obx(() => Text(
                      'We sent a verification code to ${controller.userEmail.value}. Enter the code below to verify your email.',
                      style: TextStyle(
                        fontSize: 14,
                        color: MyColor.getTextColor(),
                        height: 1.4,
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 40),

        // OTP input section
        Text(
          'Verification Code',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: MyColor.getHeadingTextColor(),
          ),
        ),
        SizedBox(height: 20),

        // OTP input boxes - Made properly tappable
        Stack(
          children: [
            // Visual OTP boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return GestureDetector(
                  onTap: controller.focusOtpField,
                  child: Obx(() => AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 60,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: index < controller.currentIndex.value &&
                          controller.codeSent.value
                          ? MyColor.getGCoinPrimaryGradient()
                          : null,
                      color: index < controller.currentIndex.value &&
                          controller.codeSent.value
                          ? null
                          : MyColor.getGCoinSurfaceColor(),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: index == controller.currentIndex.value &&
                            controller.codeSent.value
                            ? MyColor.getGCoinPrimaryColor()
                            : MyColor.getGCoinDividerColor(),
                        width: index == controller.currentIndex.value &&
                            controller.codeSent.value ? 2 : 1,
                      ),
                      boxShadow: index == controller.currentIndex.value &&
                          controller.codeSent.value
                          ? [
                        BoxShadow(
                          color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        controller.otpDigits[index],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: index < controller.currentIndex.value &&
                              controller.codeSent.value
                              ? Colors.white
                              : MyColor.getTextColor(),
                        ),
                      ),
                    ),
                  )),
                );
              }),
            ),

            // Invisible text field for input - positioned to cover the boxes
            Positioned.fill(
              child: GestureDetector(
                onTap: controller.focusOtpField,
                child: Container(
                  color: Colors.transparent,
                  child: TextField(
                    controller: controller.otpController,
                    focusNode: controller.otpFocusNode,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.transparent,
                      fontSize: 24,
                    ),
                    cursorColor: Colors.transparent,
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: controller.onOtpChanged,
                    onTap: () {
                      if (!controller.codeSent.value) {
                        controller.otpFocusNode.unfocus();
                        CustomSnackBar.error('Please request a verification code first');
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 24),

        // Clear button when there's input
        Obx(() => controller.codeSent.value &&
            controller.otpController.text.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: TextButton(
            onPressed: controller.clearOtp,
            child: Text(
              'Clear Code',
              style: TextStyle(
                color: MyColor.getGCoinPrimaryColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        )
            : SizedBox()),

        // Main action button
        Obx(() => Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: controller.codeSent.value
                ? MyColor.getGCoinSuccessGradient()
                : MyColor.getGCoinHeroGradient(),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (controller.codeSent.value
                    ? MyColor.getGCoinSuccessColor()
                    : MyColor.getGCoinPrimaryColor()).withOpacity(0.4),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: controller.isLoading.value
                  ? null
                  : controller.codeSent.value
                  ? controller.verifyEmail
                  : controller.sendVerificationEmail,
              child: Center(
                child: controller.isLoading.value
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                  controller.codeSent.value
                      ? 'Verify Email'
                      : 'Send Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        )),
        SizedBox(height: 40),

        // Security warning
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: MyColor.getGCoinWarningColor().withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: MyColor.getGCoinWarningColor().withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MyColor.getGCoinWarningColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.security, color: Colors.white, size: 16),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Security Guidelines',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: MyColor.getGCoinWarningColor(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildSecurityPoint('Never share your verification code'),
              SizedBox(height: 8),
              _buildSecurityPoint('The code expires after 10 minutes'),
              SizedBox(height: 8),
              _buildSecurityPoint(
                'Check your spam folder if you don\'t see the email',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(top: 6, right: 12),
          decoration: BoxDecoration(
            color: MyColor.getGCoinWarningColor(),
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: MyColor.getTextColor(),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  String _formatVerifiedDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
   Widget _buildBottomBannerAd() {
    return _isBottomBannerAdLoaded
        ? Container(
          color: Colors.white,
      width: _bottomBannerAd!.size.width.toDouble(),
      height: _bottomBannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bottomBannerAd!),
    )
      : myAds['BannerNode'] == false?
      SizedBox.shrink() : Container( width: _bottomBannerAd!.size.width.toDouble(),
      height: _bottomBannerAd!.size.height.toDouble(),child: Center(child: Text("Loading Ads..."),),); 
  
  }
}