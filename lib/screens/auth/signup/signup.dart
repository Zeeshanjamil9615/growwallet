import 'package:flutter/material.dart';
import 'package:gcoin/screens/auth/signup/signup_controller.dart';
import 'package:get/get.dart';
import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';

import '../../../utils/custom_snackbar.dart'; // Import Cloudflare Turnstile

class GCoinSignUpScreen extends StatefulWidget {
  const GCoinSignUpScreen({super.key});

  @override
  State<GCoinSignUpScreen> createState() => _GCoinSignUpScreenState();
}

class _GCoinSignUpScreenState extends State<GCoinSignUpScreen>
    with TickerProviderStateMixin {
  final SignUpController _signUpController = Get.put(SignUpController());
  final _referByController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _userNameFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _acceptTerms = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // bool _isLoading = false;

  // Cloudflare Turnstile token
  String? _turnstileToken; // Variable to store the token

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
    // Main animation controller for entrance animations
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Floating animation for background elements
    _floatingAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Pulse animation for logo
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1F0F), // backgroundColor
              Color(0xFF1B2E1C), // appBarColor
              Color(0xFF2D4A2E), // fieldDisableBorderColor
            ],
          ),
        ),
        child: Stack(
          children: [_buildBackgroundElements(), _buildMainContent(size)],
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
              top: 120 + _floatingAnimation.value,
              right: 40,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF7ED321).withOpacity(0.3),
                      const Color(0xFF7ED321).withOpacity(0.1),
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
              left: 20,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4CAF50).withOpacity(0.4),
                      const Color(0xFF4CAF50).withOpacity(0.1),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // Mining pattern background
        Positioned(
          top: -40,
          left: -40,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF7ED321).withOpacity(0.1),
                width: 2,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -60,
          right: -60,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4CAF50).withOpacity(0.08),
                width: 2,
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
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            SizedBox(height: size.height * 0.06),
            _buildHeader(),
            SizedBox(height: size.height * 0.04),
            _buildSignUpCard(),
            const SizedBox(height: 24),
            _buildSignInOption(),
            const SizedBox(height: 20),
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
            // Animated Logo
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF7ED321), // gCoinPrimary
                          Color(0xFF4CAF50), // gCoinSecondary
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7ED321).withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.g_mobiledata,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            // Welcome Text
            const Text(
              'Join Grow Network',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE8F5E8), // headingTextColor
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your account and start gaming network',
              style: TextStyle(
                fontSize: 16,
                color: const Color(
                  0xFFCED9CE,
                ).withOpacity(0.8), // smallTextColor
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2E1C),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF388E3C).withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7ED321).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE8F5E8),
                  ),
                ),
                const SizedBox(height: 32),
                _buildNameField(),
                const SizedBox(height: 20),
                _buildEmailField(),
                const SizedBox(height: 20),
                _buildUserNameField(),
                const SizedBox(height: 20),
                _buildPasswordField(),
                const SizedBox(height: 20),
                _buildConfirmPasswordField(),
                const SizedBox(height: 20),
                _buildReferByField(), // Add this new field
                const SizedBox(height: 20),
                // --- Cloudflare Turnstile Widget ---
                const Text(
                  'Verify you are human:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA5D6A7),
                  ),
                ),
                const SizedBox(height: 8),
                CloudflareTurnstile(
                  siteKey: '0x4AAAAAABksqT2qG3ONV4l-',
                  baseUrl: 'https://gnetwork.pro/',// <--- REPLACE THIS WITH YOUR SITE KEY
                  options: TurnstileOptions(
                    // mode: TurnstileMode.managed, // invisible challenge
                    // You can customize theme, language, etc.
                    theme: TurnstileTheme.dark, // Adjust based on your app's theme
                  ),
                  onTokenReceived: (token) {
                    setState(() {
                      _turnstileToken = token;
                    });
                    CustomSnackBar.success('CAPTCHA verified!');
                    print('Turnstile Token: $token');
                  },
                  onError: (error) {
                    setState(() {
                      _turnstileToken = null; // Clear token on error
                    });
                    CustomSnackBar.error('CAPTCHA verification failed: $error');
                    print('Turnstile Error: $error');
                  },
                  // onLoad: () {
                  //   print('Cloudflare Turnstile loaded successfully!');
                  // },
                ),
                const SizedBox(height: 20),
                // --- End Cloudflare Turnstile Widget ---
                _buildTermsAndConditions(),
                const SizedBox(height: 32),
                _buildSignUpButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Full Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA5D6A7), // labelTextColor
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7ED321).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter your full name',
              hintStyle: TextStyle(
                color: const Color(
                  0xFF66BB6A,
                ).withOpacity(0.6), // hintTextColor
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: const Color(0xFF7ED321).withOpacity(0.7),
                size: 22,
              ),
              filled: true,
              fillColor: const Color(0xFF1B2E1C), // fieldFillColor
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF7ED321), // fieldEnableBorderColor
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE53935), // colorRed
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReferByField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Referral Code',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA5D6A7),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7ED321).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _referByController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter referral code if any',
              hintStyle: TextStyle(
                color: const Color(0xFF66BB6A).withOpacity(0.6),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.person_add_alt_1_outlined,
                color: const Color(0xFF7ED321).withOpacity(0.7),
                size: 22,
              ),
              filled: true,
              fillColor: const Color(0xFF1B2E1C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF7ED321),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE53935), // colorRed
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            // Referral code is optional, so no validator needed unless you have specific format rules
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an Referral code';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA5D6A7), // labelTextColor
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7ED321).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _userNameFocusNode.requestFocus(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: TextStyle(
                color: const Color(
                  0xFF66BB6A,
                ).withOpacity(0.6), // hintTextColor
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: const Color(0xFF7ED321).withOpacity(0.7),
                size: 22,
              ),
              filled: true,
              fillColor: const Color(0xFF1B2E1C), // fieldFillColor
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF7ED321), // fieldEnableBorderColor
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE53935), // colorRed
                  width: 2,
                ),
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
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Name',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA5D6A7), // labelTextColor
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7ED321).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _userNameController,
            focusNode: _userNameFocusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Enter your user name',
              hintStyle: TextStyle(
                color: const Color(
                  0xFF66BB6A,
                ).withOpacity(0.6), // hintTextColor
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.person,
                color: const Color(0xFF7ED321).withOpacity(0.7),
                size: 22,
              ),
              filled: true,
              fillColor: const Color(0xFF1B2E1C), // fieldFillColor
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF7ED321), // fieldEnableBorderColor
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE53935), // colorRed
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your user name';
              }
              if (value.contains(' ')) {
                return 'Username should not contain spaces';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA5D6A7), // labelTextColor
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7ED321).withOpacity(0.1),
                blurRadius: 8,
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
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Create a password',
              hintStyle: TextStyle(
                color: const Color(0xFF66BB6A).withOpacity(0.6),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: const Color(0xFF7ED321).withOpacity(0.7),
                size: 22,
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
                  color: const Color(0xFF66BB6A).withOpacity(0.7),
                  size: 22,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFF1B2E1C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF7ED321),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE53935),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please create a password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              // if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              //   return 'Password must contain uppercase, lowercase and number';
              // }
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
        const Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFA5D6A7), // labelTextColor
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7ED321).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocusNode,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              hintStyle: TextStyle(
                color: const Color(0xFF66BB6A).withOpacity(0.6),
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: const Color(0xFF7ED321).withOpacity(0.7),
                size: 22,
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
                  color: const Color(0xFF66BB6A).withOpacity(0.7),
                  size: 22,
                ),
              ),
              filled: true,
              fillColor: const Color(0xFF1B2E1C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF2D4A2E).withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF7ED321),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFE53935),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
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

  Widget _buildTermsAndConditions() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            activeColor: const Color(0xFF7ED321),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            side: BorderSide(
              color: _acceptTerms
                  ? const Color(0xFF7ED321)
                  : const Color(0xFF2D4A2E),
              width: 2,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFFCED9CE),
                fontSize: 14,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Show Terms & Conditions'),
                          backgroundColor: Color(0xFF7ED321),
                        ),
                      );
                    },
                    child: const Text(
                      'Terms & Conditions',
                      style: TextStyle(
                        color: Color(0xFF7ED321),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const TextSpan(text: ' and '),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Show Privacy Policy'),
                          backgroundColor: Color(0xFF7ED321),
                        ),
                      );
                    },
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        color: Color(0xFF7ED321),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return Obx(() {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7ED321), Color(0xFF4CAF50)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7ED321).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _signUpController.isLoading.value ? null : _handleSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _signUpController.isLoading.value
              ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text(
            'CREATE ACCOUNT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    });
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        CustomSnackBar.error('Please accept the Terms & Conditions');
        return;
      }
      // --- CAPTCHA Check ---
      if (_turnstileToken == null || _turnstileToken!.isEmpty) {
        CustomSnackBar.error('Please complete the CAPTCHA verification.');
        return;
      }
      // --- End CAPTCHA Check ---

      _signUpController.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        username: _userNameController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
        referBy: _referByController.text.trim(),
        recaptchaToken: _turnstileToken!, // Pass the Turnstile token
      );
    }
  }

  Widget _buildSignInOption() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Already have an account? ",
            style: TextStyle(
              color: const Color(0xFFCED9CE).withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          TextButton(
            onPressed: () {
              // Handle sign in navigation
              Navigator.pop(context);
            },
            child: const Text(
              'Sign In',
              style: TextStyle(
                color: Color(0xFF7ED321),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}