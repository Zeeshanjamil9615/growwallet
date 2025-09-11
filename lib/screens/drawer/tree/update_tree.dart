import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
// Import your app colors

class NetworkTreeUpdateScreen extends StatefulWidget {
  const NetworkTreeUpdateScreen({Key? key}) : super(key: key);

  @override
  State<NetworkTreeUpdateScreen> createState() => _NetworkTreeUpdateScreenState();
}

class _NetworkTreeUpdateScreenState extends State<NetworkTreeUpdateScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the main icon
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation for the update icon
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Fade animation for text
    _fadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      body: Container(
        decoration: BoxDecoration(
          gradient: MyColor.getGCoinHeroGradient(),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: MyColor.colorWhite,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Network Tree',
                        style: TextStyle(
                          color: MyColor.colorWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: MyColor.getGCoinGlassColor(),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: MyColor.getGCoinGlassBorderColor(),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MyColor.getGCoinShadowColor(),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Network Tree Icon
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: MyColor.getGCoinPrimaryGradient(),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: MyColor.gCoinPrimary.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.account_tree,
                                size: 60,
                                color: MyColor.colorWhite,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Rotating Update Icon
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: MyColor.getGCoinAccentColor(),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.refresh,
                                size: 30,
                                color: MyColor.colorWhite,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Main Message
                      AnimatedBuilder(
                        animation: _fadeAnimation,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _fadeAnimation.value,
                            child: Column(
                              children: [
                                Text(
                                  'Network Tree is',
                                  style: TextStyle(
                                    color: MyColor.getTextColor(),
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'On Update',
                                  style: TextStyle(
                                    color: MyColor.getGCoinPrimaryColor(),
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 30),

                      // Description
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'We\'re working hard to improve your experience.\nThis module will be available soon!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: MyColor.getSecondaryTextColor(),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Progress Indicator
                      Container(
                        width: 200,
                        height: 6,
                        decoration: BoxDecoration(
                          color: MyColor.getFieldDisableBorderColor(),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return LinearProgressIndicator(
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                MyColor.getGCoinPrimaryColor(),
                              ),
                              borderRadius: BorderRadius.circular(3),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Status Text
                      Text(
                        'Updating...',
                        style: TextStyle(
                          color: MyColor.getGCoinPrimaryColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: MyColor.colorWhite.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Thank you for your patience',
                      style: TextStyle(
                        color: MyColor.colorWhite.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}