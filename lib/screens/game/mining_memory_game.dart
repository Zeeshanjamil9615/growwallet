// mining_memory_game.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:math';
import 'dart:async';
import '../../utils/ad_helper.dart';
import '../../utils/app_colors.dart';

class MiningMemoryGameController extends GetxController {
  // Game state observables
  RxList<String> gameImages = <String>[].obs;
  RxList<bool> isFlipped = <bool>[].obs;
  RxList<bool> isMatched = <bool>[].obs;
  RxList<int> selectedCards = <int>[].obs;
  RxInt matchedPairs = 0.obs;
  RxBool isProcessing = false.obs;
  RxBool gameStarted = false.obs;
  RxBool gameCompleted = false.obs;
  RxInt tries = 0.obs;
  RxInt score = 0.obs;

  // Timer for game duration
  Timer? _gameTimer;
  RxInt gameTime = 0.obs;

  // Callback for when game completes
  Function()? onGameCompleted;

  // Available images (1.png to 12.png)
  final List<String> availableImages = List.generate(12, (index) =>
  'assets/images/game/${index + 1}.png');

  final String hiddenCardImage = 'assets/images/game/hidden.png';

  void initializeGame({Function()? onCompleted}) {
    onGameCompleted = onCompleted;

    // Reset game state
    gameImages.clear();
    isFlipped.clear();
    isMatched.clear();
    selectedCards.clear();
    matchedPairs.value = 0;
    isProcessing.value = false;
    gameStarted.value = false;
    gameCompleted.value = false;
    tries.value = 0;
    score.value = 0;
    gameTime.value = 0;

    // Randomly select 4 images for matching pairs (2x4 grid = 8 cards = 4 pairs)
    final random = Random();
    final selectedImages = <String>[];

    while (selectedImages.length < 4) {
      final image = availableImages[random.nextInt(availableImages.length)];
      if (!selectedImages.contains(image)) {
        selectedImages.add(image);
      }
    }

    // Create pairs and shuffle
    final cardImages = <String>[];
    for (final image in selectedImages) {
      cardImages.add(image);
      cardImages.add(image);
    }
    cardImages.shuffle();

    // Initialize game arrays for 8 cards
    gameImages.value = cardImages;
    isFlipped.value = List.filled(8, false);
    isMatched.value = List.filled(8, false);

    gameStarted.value = true;
    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!gameCompleted.value) {
        gameTime.value++;
      } else {
        timer.cancel();
      }
    });
  }

  void onCardTap(int index) {
    if (isProcessing.value ||
        isFlipped[index] ||
        isMatched[index] ||
        selectedCards.length >= 2) {
      return;
    }

    // Flip the card
    isFlipped[index] = true;
    selectedCards.add(index);

    if (selectedCards.length == 2) {
      tries.value++;
      _checkMatch();
    }
  }

  void _checkMatch() {
    isProcessing.value = true;

    Timer(const Duration(milliseconds: 800), () {
      final firstIndex = selectedCards[0];
      final secondIndex = selectedCards[1];

      if (gameImages[firstIndex] == gameImages[secondIndex]) {
        // Match found
        isMatched[firstIndex] = true;
        isMatched[secondIndex] = true;
        matchedPairs.value++;
        score.value += 10;

        if (matchedPairs.value == 4) { // Now need 4 pairs instead of 8
          _completeGame();
        }
      } else {
        // No match - flip back
        isFlipped[firstIndex] = false;
        isFlipped[secondIndex] = false;
      }

      selectedCards.clear();
      isProcessing.value = false;
    });
  }

  void _completeGame() {
    gameCompleted.value = true;
    _gameTimer?.cancel();
    score.value += (100 - gameTime.value).clamp(0, 100); // Reduced bonus for easier game

    // Call the completion callback after a short delay
    Timer(const Duration(seconds: 2), () {
      onGameCompleted?.call();
    });
  }

  void restartGame() {
    _gameTimer?.cancel();
    initializeGame(onCompleted: onGameCompleted);
  }

  String formatTime() {
    final minutes = gameTime.value ~/ 60;
    final seconds = gameTime.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _gameTimer?.cancel();
    super.onClose();
  }
}

class MiningMemoryGame extends StatefulWidget {
  final Function()? onGameCompleted;

  const MiningMemoryGame({
    super.key,
    this.onGameCompleted,
  });

  @override
  State<MiningMemoryGame> createState() => _MiningMemoryGameState();
}

class _MiningMemoryGameState extends State<MiningMemoryGame>
    with TickerProviderStateMixin {

  late final MiningMemoryGameController controller;
  late AnimationController _scaleController;
  late AnimationController _completionController;


  @override
  void initState() {
    super.initState();
    controller = Get.put(MiningMemoryGameController(), tag: 'mining_game');
    _initializeAnimations();
    controller.initializeGame(onCompleted: _onGameCompleted);

  }

  // New method to handle game completion
  void _onGameCompleted() {

    // Call original callback if exists
    widget.onGameCompleted?.call();
  }


  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  // Method to show rewarded ad
  void _showRewardedAd() {


    _handleRewardEarned();
  }

  // Handle reward earned
  void _handleRewardEarned() {
    // Add haptic feedback
    HapticFeedback.mediumImpact();

    // Show success and navigate to home
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        _showRewardSuccessAndNavigateHome();
      }
    });
  }

  // Show reward success and navigate to home
  void _showRewardSuccessAndNavigateHome() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: MyColor.getGCoinSuccessGradient(),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.card_giftcard,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Reward Earned!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MyColor.getGCoinSuccessColor(),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You earned bonus coins!',
                style: TextStyle(
                  fontSize: 14,
                  color: MyColor.headingTextColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to home/previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColor.getGCoinPrimaryColor(),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Continue'),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Handle no ad available
  void _handleNoAdAvailable() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off,
                size: 48,
                color: MyColor.gCoinLoss,
              ),
              SizedBox(height: 16),
              Text(
                'No Ad Available',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MyColor.headingTextColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: MyColor.headingTextColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.getGCoinPrimaryColor(),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Retry'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Go back to home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.getGCoinSecondaryColor(),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Skip'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Show retry dialog
  void _showRetryDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                size: 48,
                color: MyColor.getGCoinPrimaryColor(),
              ),
              SizedBox(height: 16),
              Text(
                'Watch Ad for Reward?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: MyColor.headingTextColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You can watch an ad to earn bonus coins.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: MyColor.headingTextColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();

                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.getGCoinPrimaryColor(),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Try Again'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Go back to home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.getGCoinSecondaryColor(),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Skip'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Handle ad error
  void _handleAdError() {
    Get.snackbar(
      'Ad Error',
      'Failed to show ad. Please try again.',
      backgroundColor: MyColor.gCoinLoss,
      colorText: Colors.white,
      duration: Duration(seconds: 3),
    );

    // Navigate back to home after error
    Future.delayed(Duration(seconds: 1), () {
      Get.back();
    });
  }

  // Add this method to your dispose
  @override
  void dispose() {

    _scaleController.dispose();
    _completionController.dispose();
    Get.delete<MiningMemoryGameController>(tag: 'mining_game');
    super.dispose();
  }


  // Update the build method to include reward dialog
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            // Game Header
            _buildGameHeader(),

            const SizedBox(height: 16),

            // Game Content
            Expanded(
              child: Stack(
                children: [
                  Obx(() => controller.gameCompleted.value
                      ? _buildCompletionScreen()
                      : _buildGameGrid()),


                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build reward dialog widget
  Widget _buildRewardDialog() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 32),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: MyColor.getGCoinPrimaryGradient(),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.play_arrow,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Earn Bonus Coins!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MyColor.getGCoinPrimaryColor(),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Watch a short video to earn bonus coins for completing the gaming challenge.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: MyColor.headingTextColor.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  // Expanded(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //
                  //       _showRewardedAd();
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: MyColor.getGCoinPrimaryColor(),
                  //       foregroundColor: Colors.white,
                  //       padding: EdgeInsets.symmetric(vertical: 12),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     child: _isLoadingRewardedAd
                  //         ? SizedBox(
                  //       width: 20,
                  //       height: 20,
                  //       child: CircularProgressIndicator(
                  //         color: Colors.white,
                  //         strokeWidth: 2,
                  //       ),
                  //     )
                  //         : Text('Watch Ad'),
                  //   ),
                  // ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                                              // Navigate back to home
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColor.getGCoinSecondaryColor(),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Skip'),
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

  Widget _buildGameHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: MyColor.getGCoinPrimaryGradient(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Game Challenge',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Time', controller.formatTime()),
              _buildStatItem('Tries', '${controller.tries.value}'),
              _buildStatItem('Score', '${controller.score.value}'),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildGameGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate card size based on available space for 2x4 grid
        double availableWidth = constraints.maxWidth - 32;
        double cardSize = (availableWidth - 24) / 4; // 4 cards per row with spacing
        cardSize = cardSize.clamp(50.0, 80.0); // Larger cards for easier game

        return Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Build 2 rows of 4 cards each
                for (int row = 0; row < 2; row++) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int col = 0; col < 4; col++) ...[
                        _buildCard(row * 4 + col, cardSize),
                        if (col < 3) SizedBox(width: 8),
                      ],
                    ],
                  ),
                  if (row < 1) const SizedBox(height: 8),
                ],
                const SizedBox(height: 16),
                // Restart button (commented out as per original)
                // ElevatedButton(
                //   onPressed: controller.restartGame,
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: MyColor.getGCoinSecondaryColor(),
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                //   child: const Text('Restart', style: TextStyle(fontSize: 12)),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(int index, double size) {
    return Obx(() {
      final isCardFlipped = controller.isFlipped[index];
      final isCardMatched = controller.isMatched[index];
      final isSelected = controller.selectedCards.contains(index);

      return AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          final scale = isSelected ? 1.0 - (_scaleController.value * 0.1) : 1.0;

          return Transform.scale(
            scale: scale,
            child: GestureDetector(
              onTap: () {
                controller.onCardTap(index);
                _scaleController.forward().then((_) {
                  _scaleController.reverse();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: isCardMatched
                      ? MyColor.getGCoinSuccessColor().withOpacity(0.3)
                      : MyColor.appBarColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCardMatched
                        ? MyColor.getGCoinSuccessColor()
                        : isCardFlipped
                        ? MyColor.getGCoinPrimaryColor()
                        : MyColor.getGCoinDividerColor(),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MyColor.getGCoinShadowColor(),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isCardFlipped || isCardMatched
                        ? Image.asset(
                      controller.gameImages[index],
                      key: ValueKey('revealed_$index'),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                          child: Icon(
                            Icons.image_not_supported,
                            size: size * 0.3,
                            color: MyColor.getGCoinPrimaryColor(),
                          ),
                        );
                      },
                    )
                        : Image.asset(
                      controller.hiddenCardImage,
                      key: ValueKey('hidden_$index'),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                          child: Icon(
                            Icons.flash_on_rounded,
                            size: size * 0.3,
                            color: MyColor.getGCoinPrimaryColor(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCompletionScreen() {
    _completionController.forward();

    return AnimatedBuilder(
      animation: _completionController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_completionController.value * 0.2),
          child: Opacity(
            opacity: _completionController.value,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: MyColor.getGCoinSuccessGradient(),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: MyColor.getGCoinSuccessColor().withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Gaming Unlocked!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: MyColor.getGCoinSuccessColor(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Completed in ${controller.formatTime()}',
                    style: TextStyle(
                      fontSize: 14,
                      color: MyColor.headingTextColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Score: ${controller.score.value}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyColor.getGCoinPrimaryColor(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Starting gaming...',
                    style: TextStyle(
                      fontSize: 12,
                      color: MyColor.headingTextColor.withOpacity(0.7),
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