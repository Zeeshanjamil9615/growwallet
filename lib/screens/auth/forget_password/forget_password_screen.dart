import 'package:flutter/material.dart';
import 'package:gcoin/api_service/api_service.dart';
import 'package:gcoin/utils/app_colors.dart';
import 'package:get/get.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  late AnimationController _mainAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _pulseAnimationController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: _floatingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    _mainAnimationController.forward();
    _floatingAnimationController.repeat(reverse: true);
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _floatingAnimationController.dispose();
    _pulseAnimationController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (response != null && response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'OTP sent to your email',
          backgroundColor: MyColor.gCoinSuccess,
          colorText: MyColor.colorWhite,
          snackPosition: SnackPosition.TOP,
          borderRadius: 12,
          margin: const EdgeInsets.all(16),
        );

        // Navigate to reset password screen with email
        Get.toNamed('/reset-password', arguments: _emailController.text.trim());
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send OTP. Please try again.',
        backgroundColor: MyColor.colorRed,
        colorText: MyColor.colorWhite,
        snackPosition: SnackPosition.TOP,
        borderRadius: 12,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MyColor.backgroundColor,
              MyColor.appBarColor,
              MyColor.fieldDisableBorderColor,
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundElements(),
            _buildMainContent(size),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        // Floating orbs
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Positioned(
              top: 80 + _floatingAnimation.value,
              right: 40,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      MyColor.gCoinPrimary.withOpacity(0.3),
                      MyColor.gCoinPrimary.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Positioned(
              bottom: 150 - _floatingAnimation.value,
              left: 25,
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      MyColor.gCoinSecondary.withOpacity(0.4),
                      MyColor.gCoinSecondary.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // Background pattern
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: MyColor.gCoinPrimary.withOpacity(0.1),
                width: 1.5,
              ),
            ),
          ),
        ),
        // Additional floating element
        AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Positioned(
              top: 200 + (_floatingAnimation.value * 0.5),
              left: 60,
              child: Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      MyColor.gCoinAccent.withOpacity(0.3),
                      MyColor.gCoinAccent.withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMainContent(Size size) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Back button
            Align(
              alignment: Alignment.centerLeft,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MyColor.fieldFillColor,
                    boxShadow: [
                      BoxShadow(
                        color: MyColor.gCoinPrimary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: MyColor.gCoinPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            _buildHeader(),
            SizedBox(height: size.height * 0.04),
            _buildForgotPasswordCard(),
            const SizedBox(height: 24),
            _buildBackToSignInOption(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Animated Lock Icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: MyColor.getGCoinPrimaryGradient(),
                      boxShadow: [
                        BoxShadow(
                          color: MyColor.gCoinPrimary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_reset_rounded,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: MyColor.headingTextColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Enter your email address and we\'ll send you an OTP code to reset your password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: MyColor.smallTextColor.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: MyColor.cardBgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: MyColor.cardBorderColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: MyColor.gCoinPrimary.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: MyColor.gCoinShadow,
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: MyColor.headingTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildEmailField(),
                const SizedBox(height: 24),
                _buildSendOtpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: MyColor.labelTextColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: MyColor.gCoinPrimary.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _sendOtp(),
            style: TextStyle(
              color: MyColor.colorWhite,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: TextStyle(
                color: MyColor.hintTextColor.withOpacity(0.6),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: MyColor.gCoinPrimary.withOpacity(0.7),
                size: 20,
              ),
              filled: true,
              fillColor: MyColor.fieldFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: MyColor.fieldDisableBorderColor.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: MyColor.fieldDisableBorderColor.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: MyColor.fieldEnableBorderColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: MyColor.colorRed, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: MyColor.colorRed, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email address';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSendOtpButton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: MyColor.getGCoinPrimaryGradient(),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: MyColor.gCoinPrimary.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _sendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColor.transparentColor,
          shadowColor: MyColor.transparentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: MyColor.colorWhite,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              color: MyColor.colorWhite,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'SEND OTP',
              style: TextStyle(
                color: MyColor.colorWhite,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToSignInOption() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Remember your password? ",
            style: TextStyle(
              color: MyColor.smallTextColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
            child: Text(
              'Sign In',
              style: TextStyle(
                color: MyColor.gCoinPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}