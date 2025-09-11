import 'package:flutter/material.dart';
import 'package:gcoin/utils/custom_snackbar.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

import '../../utils/app_colors.dart';
import 'controller.dart';

class MaintenanceScreen extends StatefulWidget {
  final String? heading;
  final String? description;
  final String? estimatedTime;
  final VoidCallback? onRetry;

  const MaintenanceScreen({
    super.key,
    this.heading,
    this.description,
    this.estimatedTime,
    this.onRetry,
  });

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  final MaintenanceController controller = Get.find<MaintenanceController>();
  @override
  void initState() {
    super.initState();

    // Fade in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Pulse animation for dots
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation animation for maintenance icon
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Start animations
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: MyColor.headingTextColor,
        // decoration: BoxDecoration(
        //   gradient: _getBackgroundGradient(),
        // ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 8),

                      // Animated Maintenance Icon
                      _buildMaintenanceIcon(),

                      const SizedBox(height: 18),

                      // Header Section
                      _buildHeaderSection(),

                      const SizedBox(height: 18),

                      // Description Section
                      _buildDescriptionSection(),

                      const SizedBox(height: 20),

                      // Animated Loading Dots
                      _buildLoadingDots(),

                      const SizedBox(height: 20),

                      // Estimated Time Card
                      _buildEstimatedTimeCard(),

                      const SizedBox(height: 32),

                      // Thank you message
                      _buildThankYouMessage(),

                      const SizedBox(height: 32),

                      // Retry Button
                      _buildRetryButton(),

                      SizedBox(height: size.height * 0.05),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMaintenanceIcon() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  MyColor.getGCoinPrimaryColor().withOpacity(0.3),
                  MyColor.getGCoinSecondaryColor().withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: MyColor.getGCoinPrimaryColor().withOpacity(0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: MyColor.getGCoinPrimaryColor().withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              Icons.settings_rounded,
              size: 56,
              color: MyColor.getGCoinPrimaryColor(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Text(
          widget.heading ?? 'We\'ll be back soon!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: MyColor.getPrimaryTextColor(),
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        widget.description ?? 'We\'re currently performing scheduled maintenance.\nPlease check back in a while.',
        style: TextStyle(
          fontSize: 16,
          color: MyColor.getPrimaryTextColor().withOpacity(0.8),
          height: 1.6,
          letterSpacing: 0.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDot(0),
            const SizedBox(width: 12),
            _buildDot(1),
            const SizedBox(width: 12),
            _buildDot(2),
          ],
        );
      },
    );
  }

  Widget _buildDot(int index) {
    final delay = index * 0.2;
    final animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Interval(delay, 1.0, curve: Curves.easeInOut),
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MyColor.getGCoinPrimaryColor().withOpacity(animation.value),
              boxShadow: [
                BoxShadow(
                  color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEstimatedTimeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MyColor.getGCoinPrimaryColor().withOpacity(0.1),
            MyColor.getGCoinSecondaryColor().withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: MyColor.getGCoinPrimaryColor().withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MyColor.getGCoinPrimaryColor().withOpacity(0.2),
            ),
            child: Icon(
              Icons.schedule_rounded,
              color: MyColor.getGCoinPrimaryColor(),
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Estimated Time',
            style: TextStyle(
              fontSize: 14,
              color: MyColor.getPrimaryTextColor().withOpacity(0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.estimatedTime ?? 'A few minutes',
            style: TextStyle(
              fontSize: 20,
              color: MyColor.getGCoinPrimaryColor(),
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThankYouMessage() {
    return Text(
      'Thank you for your patience! 🙏',
      style: TextStyle(
        fontSize: 15,
        color: MyColor.getPrimaryTextColor().withOpacity(0.6),
        fontStyle: FontStyle.italic,
        letterSpacing: 0.3,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRetryButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [
            MyColor.getGCoinPrimaryColor().withOpacity(0.2),
            MyColor.getGCoinSecondaryColor().withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: MyColor.getGCoinPrimaryColor().withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinPrimaryColor().withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () {
            controller.retry();

          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 20,
                  color: MyColor.getGCoinPrimaryColor(),
                ),
                const SizedBox(width: 12),
                Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: MyColor.getGCoinPrimaryColor(),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // LinearGradient _getBackgroundGradient() {
  //   return LinearGradient(
  //     colors: [
  //       MyColor.getScreenBgColor(),
  //       MyColor.getScreenBgColor().withOpacity(0.95),
  //       MyColor.getGCoinPrimaryColor().withOpacity(0.05),
  //     ],
  //     begin: Alignment.topCenter,
  //     end: Alignment.bottomCenter,
  //     stops: const [0.0, 0.7, 1.0],
  //   );
  // }
}