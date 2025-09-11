import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../routes/route.dart';

// Modern Animated Onboarding Screen for G Coin
class GCoinOnboardingScreen extends StatefulWidget {
  const GCoinOnboardingScreen({super.key});

  @override
  State<GCoinOnboardingScreen> createState() => _GCoinOnboardingScreenState();
}

class _GCoinOnboardingScreenState extends State<GCoinOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _floatingController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _floatingAnimation;

  int currentIndex = 0;


  final List<OnboardingData> onboardingData = [
    OnboardingData(
      title: 'Grow your network through fun gameplay',
      subtitle: 'Play simple games, earn Gaming Coins, and build your digital circle',
      icon: Icons.gamepad,
      color: Color(0xFF7ED321),
    ),
    OnboardingData(
      title: 'Earn rewards and track your progress',
      subtitle: 'Complete daily challenges and watch your Gaming Coins grow',
      icon: Icons.account_balance_wallet,
      color: Color(0xFF4CAF50),
    ),
    OnboardingData(
      title: 'Play, invite, and rise on the leaderboard',
      subtitle: 'Level up by playing and bringing your friends along',
      icon: Icons.group_add,
      color: Color(0xFF8BC34A),
    ),
  ];


  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
    _animationController.reset();
    _animationController.forward();
  }

  void _nextPage() {
    if (currentIndex < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to login screen
      Get.toNamed(RouteHelper.sign);
    }
  }

  void _skipOnboarding() {
    // Navigate to login screen
    Get.toNamed(RouteHelper.sign);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D1F0F),
              const Color(0xFF1B2E1C),
              const Color(0xFF2D4A2E).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              if (currentIndex < onboardingData.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: _skipOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF7ED321).withOpacity(0.3),
                          ),
                          color: const Color(0xFF7ED321).withOpacity(0.1),
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF7ED321),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _animationController,
                      child: OnboardingPage(
                        data: onboardingData[index],
                        floatingAnimation: _floatingAnimation,
                      ),
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Transform.translate(
                            offset: Offset(0, _slideAnimation.value),
                            child: child,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Page Indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    onboardingData.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: currentIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: currentIndex == index
                            ? const Color(0xFF7ED321)
                            : const Color(0xFF7ED321).withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),

              // Action Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: GestureDetector(
                  onTap: _nextPage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7ED321), Color(0xFF4CAF50)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7ED321).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            currentIndex == onboardingData.length - 1
                                ? 'Get Started'
                                : 'Continue',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            currentIndex == onboardingData.length - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
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
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final Animation<double> floatingAnimation;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.floatingAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon with Floating Effects
          AnimatedBuilder(
            animation: floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, floatingAnimation.value),
                child: Container(
                  height: size.width * 0.4,
                  width: size.width * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        data.color.withOpacity(0.3),
                        data.color.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      height: size.width * 0.25,
                      width: size.width * 0.25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            data.color,
                            data.color.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: data.color.withOpacity(0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        data.icon,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 60),

          // Title
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [data.color, data.color.withOpacity(0.8)],
            ).createShader(bounds),
            child: Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Subtitle
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Decorative Elements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
                  (index) => AnimatedContainer(
                duration: Duration(milliseconds: 800 + (index * 200)),
                height: 4,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      data.color.withOpacity(0.6),
                      data.color.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

// Modern Circular Progress Indicator for G Coin
class GCoinCircularProgress extends StatefulWidget {
  final double progress;
  final Color color;
  final double size;
  final VoidCallback? onComplete;

  const GCoinCircularProgress({
    super.key,
    required this.progress,
    required this.color,
    this.size = 80,
    this.onComplete,
  });

  @override
  State<GCoinCircularProgress> createState() => _GCoinCircularProgressState();
}

class _GCoinCircularProgressState extends State<GCoinCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: GCoinProgressPainter(
              progress: _animation.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class GCoinProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  GCoinProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.6)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * (progress / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Progress dot
    if (progress > 0) {
      final dotAngle = startAngle + sweepAngle;
      final dotX = center.dx + radius * math.cos(dotAngle);
      final dotY = center.dy + radius * math.sin(dotAngle);

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), 8, dotPaint);

      // Inner dot glow
      final glowPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(dotX, dotY), 4, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}