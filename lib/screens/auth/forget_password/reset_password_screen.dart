import 'package:flutter/material.dart';
import 'package:gcoin/api_service/api_service.dart';
import 'package:gcoin/utils/app_colors.dart';
import 'package:get/get.dart';
import 'dart:async';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
}

class ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ApiService _apiService = ApiService();

  // Focus nodes
  final _otpFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _canResend = false;
  int _resendTimer = 60;
  Timer? _timer;

  String email = '';

  // Animation controllers
  late AnimationController _mainAnimationController;
  late AnimationController _floatingAnimationController;
  late AnimationController _pulseAnimationController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    email = Get.arguments ?? '';
    _setupAnimations();
    _startAnimations();
    _startResendTimer();
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
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _canResend = false;
    _resendTimer = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimer > 0) {
          _resendTimer--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.resetPassword(
        email: email,
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        otp: _otpController.text,
      );

      if (response != null && response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'Password reset successfully',
          backgroundColor: MyColor.gCoinPrimary,
          colorText: MyColor.colorWhite,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );

        // Navigate back to login screen
        Get.offAllNamed('/sign_in');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.resendOtp(email: email);

      if (response != null && response.statusCode == 200) {
        Get.snackbar(
          'Success',
          'OTP sent successfully',
          backgroundColor: MyColor.gCoinPrimary,
          colorText: MyColor.colorWhite,
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(16),
          borderRadius: 12,
        );
        _startResendTimer();
      }
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
      ],
    );
  }

  Widget _buildMainContent(Size size) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.05),
            _buildHeader(),
            SizedBox(height: size.height * 0.04),
            _buildResetPasswordCard(),
            const SizedBox(height: 16),
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
            // Animated Security Icon
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: MyColor.getGCoinPrimaryGradient(),
                      boxShadow: [
                        BoxShadow(
                          color: MyColor.gCoinPrimary.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            // Title Text
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: MyColor.headingTextColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Enter OTP and create new password',
              style: TextStyle(
                fontSize: 14,
                color: MyColor.smallTextColor.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetPasswordCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
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
                  'Verification & Reset',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: MyColor.headingTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                _buildOtpField(),
                const SizedBox(height: 12),
                _buildResendOtpSection(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildConfirmPasswordField(),
                const SizedBox(height: 24),
                _buildResetPasswordButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OTP Code',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: MyColor.labelTextColor,
          ),
        ),
        const SizedBox(height: 6),
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
            controller: _otpController,
            focusNode: _otpFocusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
            style: TextStyle(
              color: MyColor.colorWhite,
              fontSize: 15,
              letterSpacing: 2,
            ),
            decoration: InputDecoration(
              hintText: 'Enter 4-6 digit OTP',
              hintStyle: TextStyle(
                color: MyColor.hintTextColor.withOpacity(0.6),
                fontSize: 15,
                letterSpacing: 0,
              ),
              prefixIcon: Icon(
                Icons.lock_clock_rounded,
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter OTP';
              }
              if (value.length < 4) {
                return 'OTP must be at least 4 digits';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResendOtpSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive OTP? ",
          style: TextStyle(
            color: MyColor.smallTextColor.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
        TextButton(
          onPressed: _canResend && !_isLoading ? _resendOtp : null,
          child: Text(
            _canResend ? 'Resend OTP' : 'Resend in ${_resendTimer}s',
            style: TextStyle(
              color: _canResend ? MyColor.gCoinPrimary : MyColor.smallTextColor.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: MyColor.labelTextColor,
          ),
        ),
        const SizedBox(height: 6),
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
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
            style: TextStyle(
              color: MyColor.colorWhite,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Enter new password',
              hintStyle: TextStyle(
                color: MyColor.hintTextColor.withOpacity(0.6),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: MyColor.gCoinPrimary.withOpacity(0.7),
                size: 20,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: MyColor.hintTextColor.withOpacity(0.7),
                  size: 20,
                ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm New Password',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: MyColor.labelTextColor,
          ),
        ),
        const SizedBox(height: 6),
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
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              color: MyColor.colorWhite,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Confirm new password',
              hintStyle: TextStyle(
                color: MyColor.hintTextColor.withOpacity(0.6),
                fontSize: 15,
              ),
              prefixIcon: Icon(
                Icons.lock_reset_rounded,
                color: MyColor.gCoinPrimary.withOpacity(0.7),
                size: 20,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: MyColor.hintTextColor.withOpacity(0.7),
                  size: 20,
                ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordButton() {
    return Container(
      height: 50,
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
        onPressed: _isLoading ? null : _resetPassword,
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
            : Text(
          'RESET PASSWORD',
          style: TextStyle(
            color: MyColor.colorWhite,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
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
            onPressed: () {
              Get.offAllNamed('/login');
            },
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