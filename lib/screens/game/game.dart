// game.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'dart:async';

import '../../routes/route.dart';
import '../../utils/app_colors.dart';

class EarnGameController extends GetxController {
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
  late Timer _gameTimer;
  RxInt gameTime = 0.obs;

  // Available images (1.png to 12.png)
  final List<String> availableImages = List.generate(12, (index) =>
  'assets/images/game/${index + 1}.png');

  final String hiddenCardImage = 'assets/images/game/hidden.png';

  @override
  void onInit() {
    super.onInit();
    _initializeGame();
  }

  void _initializeGame() {
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
    _gameTimer.cancel();
    score.value += (100 - gameTime.value).clamp(0, 100); // Reduced bonus for easier game

    // Navigate to dashboard after 2 seconds
    Timer(const Duration(seconds: 2), () {
      Get.offAllNamed(RouteHelper.homeScreen); // Navigate back to dashboard
    });
  }

  void restartGame() {
    _gameTimer.cancel();
    _initializeGame();
  }

  String formatTime() {
    final minutes = gameTime.value ~/ 60;
    final seconds = gameTime.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    if (_gameTimer.isActive) {
      _gameTimer.cancel();
    }
    super.onClose();
  }
}

class EarnGameScreen extends StatefulWidget {
  const EarnGameScreen({super.key});

  @override
  State<EarnGameScreen> createState() => _EarnGameScreenState();
}

class _EarnGameScreenState extends State<EarnGameScreen>
    with TickerProviderStateMixin {

  late final EarnGameController controller;
  late AnimationController _flipController;
  late AnimationController _scaleController;
  late AnimationController _completionController;


  @override
  void initState() {
    super.initState();
    controller = Get.put(EarnGameController());
    _initializeAnimations();

  }

  void _initializeAnimations() {
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }


  @override
  void dispose() {
    _flipController.dispose();
    _scaleController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: AppBar(
        backgroundColor: MyColor.getGCoinPrimaryColor(),
        elevation: 0,
        title: const Text(
          'Grow Network',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              _buildHeader(),
              const SizedBox(height: 20),
              Obx(() => controller.gameStarted.value
                  ? _buildGameContent()
                  : _buildStartScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: MyColor.getGCoinPrimaryGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: MyColor.getGCoinShadowColor(),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onDoubleTap: controller._completeGame,
            child: Text(
              'Quick Match Game',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => controller.gameStarted.value
              ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Time', controller.formatTime()),
              _buildStatItem('Tries', '${controller.tries.value}'),
              _buildStatItem('Score', '${controller.score.value}'),
            ],
          )
              : Text(
            'Match all 4 pairs to continue',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
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
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStartScreen() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: MyColor.getGCoinPrimaryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: MyColor.getGCoinPrimaryColor(),
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.play_arrow,
                size: 50,
                color: MyColor.getGCoinPrimaryColor(),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Ready to play?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: MyColor.getTextColor(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Match all 4 pairs to continue',
              style: TextStyle(
                fontSize: 16,
                color: MyColor.getTextColor().withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                controller.gameStarted.value = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColor.getGCoinPrimaryColor(),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent() {
    return Expanded(
      child: Obx(() => controller.gameCompleted.value
          ? _buildCompletionScreen()
          : _buildGameGrid()),
    );
  }

  Widget _buildGameGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate card size based on available space for 2x4 grid
        double availableWidth = constraints.maxWidth - 32; // Account for padding
        double cardSize = (availableWidth - 36) / 4; // 4 cards per row with spacing
        cardSize = cardSize.clamp(60.0, 100.0); // Larger cards for easier game

        return Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: (cardSize * 4) + 36, // 4 cards + spacing
              maxHeight: (cardSize * 2) + 12, // 2 rows + spacing
            ),
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
                          if (col < 3) SizedBox(width: 12),
                        ],
                      ],
                    ),
                    if (row < 1) const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 24),
                  // Restart button
                  ElevatedButton(
                    onPressed: controller.restartGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyColor.getGCoinSecondaryColor(),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('New Game'),
                  ),
                ],
              ),
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCardMatched
                        ? MyColor.getGCoinSuccessColor()
                        : isCardFlipped
                        ? MyColor.getGCoinPrimaryColor()
                        : MyColor.getGCoinDividerColor(),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MyColor.getGCoinShadowColor(),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
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
                            size: size * 0.4,
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
                            Icons.help_outline,
                            size: size * 0.4,
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
    // Start completion animation
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
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: MyColor.getGCoinSuccessGradient(),
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: MyColor.getGCoinSuccessColor().withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Excellent!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: MyColor.getGCoinSuccessColor(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Game completed in ${controller.formatTime()}',
                    style: TextStyle(
                      fontSize: 16,
                      color: MyColor.getTextColor(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Score: ${controller.score.value}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: MyColor.getGCoinPrimaryColor(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Taking you to dashboard...',
                    style: TextStyle(
                      fontSize: 14,
                      color: MyColor.getTextColor().withOpacity(0.7),
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