import 'package:flutter/material.dart';
import 'package:gcoin/screens/auth/signin/signin_controller.dart';
import 'package:gcoin/utils/app_colors.dart';
import 'package:get/get.dart';

import '../../../routes/route.dart';
import '../forget_password/forget_password_screen.dart';

class GCoinSignInScreen extends StatefulWidget {
  const GCoinSignInScreen({super.key});

  @override
  State<GCoinSignInScreen> createState() => _GCoinSignInScreenState();
}

class _GCoinSignInScreenState extends State<GCoinSignInScreen>
    with TickerProviderStateMixin {
  final SignInController _signInController = Get.put(SignInController());
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  // bool _rememberMe = false;
  bool _obscurePassword = true;
  // bool _isLoading = false;

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
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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
          children: [_buildBackgroundElements(), _buildMainContent(size)],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return Stack(
      children: [
        // Floating orbs - reduced size for compactness
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
        // Reduced mining pattern background
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
            SizedBox(height: size.height * 0.05), // Reduced from 0.08
            _buildHeader(),
            SizedBox(height: size.height * 0.04), // Reduced from 0.06
            _buildSignInCard(),
            const SizedBox(height: 16), // Reduced from 24
            _buildSignUpOption(),
            const SizedBox(height: 16), // Reduced from 20
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
            // Animated Logo - reduced size
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 80, // Reduced from 100
                    height: 80, // Reduced from 100
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: MyColor.getGCoinPrimaryGradient(),
                      boxShadow: [
                        BoxShadow(
                          color: MyColor.gCoinPrimary.withOpacity(0.4),
                          blurRadius: 16, // Reduced from 20
                          offset: const Offset(0, 6), // Reduced from 8
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.g_mobiledata,
                      size: 40, // Reduced from 50
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18), // Reduced from 24
            // Welcome Text - reduced size
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 28, // Reduced from 32
                fontWeight: FontWeight.bold,
                color: MyColor.headingTextColor,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6), // Reduced from 8
            Text(
              'Sign in to continue Grow Network',
              style: TextStyle(
                fontSize: 14, // Reduced from 16
                color: MyColor.smallTextColor.withOpacity(0.8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInCard() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20), // Reduced from 28
          decoration: BoxDecoration(
            color: MyColor.cardBgColor,
            borderRadius: BorderRadius.circular(20), // Reduced from 24
            border: Border.all(
              color: MyColor.cardBorderColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: MyColor.gCoinPrimary.withOpacity(0.1),
                blurRadius: 16, // Reduced from 20
                offset: const Offset(0, 6), // Reduced from 8
              ),
              BoxShadow(
                color: MyColor.gCoinShadow,
                blurRadius: 25, // Reduced from 30
                offset: const Offset(0, 12), // Reduced from 15
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 22, // Reduced from 24
                    fontWeight: FontWeight.bold,
                    color: MyColor.headingTextColor,
                  ),
                ),
                const SizedBox(height: 24), // Reduced from 32
                _buildEmailField(),
                const SizedBox(height: 16), // Reduced from 20
                _buildPasswordField(),
                const SizedBox(height: 16), // Reduced from 20
                _buildRememberMeAndForgotPassword(),
                const SizedBox(height: 24), // Reduced from 32
                _buildSignInButton(),
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
          'Email or Username',
          style: TextStyle(
            fontSize: 13, // Reduced from 14
            fontWeight: FontWeight.w500,
            color: MyColor.labelTextColor,
          ),
        ),
        const SizedBox(height: 6), // Reduced from 8
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14), // Reduced from 16
            boxShadow: [
              BoxShadow(
                color: MyColor.gCoinPrimary.withOpacity(0.1),
                blurRadius: 6, // Reduced from 8
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
            style: TextStyle(
              color: MyColor.colorWhite,
              fontSize: 15,
            ), // Reduced from 16
            decoration: InputDecoration(
              hintText: 'Enter your email or username',
              hintStyle: TextStyle(
                color: MyColor.hintTextColor.withOpacity(0.6),
                fontSize: 15, // Reduced from 16
              ),
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: MyColor.gCoinPrimary.withOpacity(0.7),
                size: 20, // Reduced from 22
              ),
              filled: true,
              fillColor: MyColor.fieldFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), // Reduced from 16
                borderSide: BorderSide(
                  color: MyColor.fieldDisableBorderColor.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), // Reduced from 16
                borderSide: BorderSide(
                  color: MyColor.fieldDisableBorderColor.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), // Reduced from 16
                borderSide: BorderSide(
                  color: MyColor.fieldEnableBorderColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), // Reduced from 16
                borderSide: BorderSide(color: MyColor.colorRed, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, // Reduced from 16
                vertical: 14, // Reduced from 16
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or username';
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
        Text(
          'Password',
          style: TextStyle(
            fontSize: 13, // Reduced from 14
            fontWeight: FontWeight.w500,
            color: MyColor.labelTextColor,
          ),
        ),
        const SizedBox(height: 6), // Reduced from 8
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14), // Reduced from 16
            boxShadow: [
              BoxShadow(
                color: MyColor.gCoinPrimary.withOpacity(0.1),
                blurRadius: 6, // Reduced from 8
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            style: TextStyle(
              color: MyColor.colorWhite,
              fontSize: 15,
            ), // Reduced from 16
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: TextStyle(
                color: MyColor.hintTextColor.withOpacity(0.6),
                fontSize: 15, // Reduced from 16
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: MyColor.gCoinPrimary.withOpacity(0.7),
                size: 20, // Reduced from 22
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
                  size: 20, // Reduced from 22
                ),
              ),
              filled: true,
              fillColor: MyColor.fieldFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), // Reduced from 16
                borderSide: BorderSide(
                  color: MyColor.fieldDisableBorderColor.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), // Reduced from 16
                borderSide: BorderSide(
                  color: MyColor.fieldDisableBorderColor.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), // Reduced from 16
                borderSide: BorderSide(
                  color: MyColor.fieldEnableBorderColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), // Reduced from 16
                borderSide: BorderSide(color: MyColor.colorRed, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, // Reduced from 16
                vertical: 14, // Reduced from 16
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
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

  Widget _buildRememberMeAndForgotPassword() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Obx(
                  () => Checkbox(
                    value: _signInController.rememberMe.value,
                    onChanged: (value) {
                      _signInController.rememberMe.value = value ?? false;
                    },
                    activeColor: MyColor.gCoinPrimary,
                    checkColor: MyColor.colorWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: BorderSide(
                      color:
                          _signInController.rememberMe.value
                              ? MyColor.gCoinPrimary
                              : MyColor.fieldDisableBorderColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'Remember me',
                style: TextStyle(color: MyColor.smallTextColor, fontSize: 13),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            // Get.snackbar(
            //   'Forgot Password',
            //   'Functionality coming soon',
            //   backgroundColor: MyColor.gCoinPrimary,
            // );
            Get.to(()=> ForgotPasswordScreen());
          },
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: MyColor.gCoinPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInButton() {
    return Obx(() {
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
          onPressed: _signInController.isLoading.value ? null : _handleSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColor.transparentColor,
            shadowColor: MyColor.transparentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child:
              _signInController.isLoading.value
                  ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: MyColor.colorWhite,
                      strokeWidth: 2,
                    ),
                  )
                  : Text(
                    'SIGN IN',
                    style: TextStyle(
                      color: MyColor.colorWhite,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
        ),
      );
    });
  }

  Widget _buildSignUpOption() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Don't have an account? ",
            style: TextStyle(
              color: MyColor.smallTextColor.withOpacity(0.8),
              fontSize: 14, // Reduced from 16
            ),
          ),
          TextButton(
            onPressed: () {
              Get.toNamed(RouteHelper.signup);

            },
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: MyColor.gCoinPrimary,
                fontSize: 14, // Reduced from 16
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      _signInController.loginUser(
        emailOrUsername: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    }
  }
}
