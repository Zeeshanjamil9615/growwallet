// Add this custom widget class to your project
import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedDigitDisplay extends StatefulWidget {
  final String value;
  final TextStyle textStyle;
  final Duration duration;

  const AnimatedDigitDisplay({
    super.key,
    required this.value,
    required this.textStyle,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  AnimatedDigitDisplayState createState() => AnimatedDigitDisplayState();
}

class AnimatedDigitDisplayState extends State<AnimatedDigitDisplay>
    with TickerProviderStateMixin {
  late String _previousValue;
  late String _currentValue;
  Map<int, AnimationController> _controllers = {};
  Map<int, Animation<double>> _animations = {};

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _currentValue = widget.value;
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Clear existing controllers
    _controllers.forEach((_, controller) => controller.dispose());
    _controllers.clear();
    _animations.clear();

    // Create controllers for each digit position
    for (int i = 0; i < _currentValue.length; i++) {
      _controllers[i] = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      _animations[i] = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controllers[i]!,
        curve: Curves.easeOutCubic,
      ));
    }
  }

  @override
  void didUpdateWidget(AnimatedDigitDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = _currentValue;
      _currentValue = widget.value;
      _updateAnimations();
    }
  }

  void _updateAnimations() {
    // Ensure we have the right number of controllers
    _initializeAnimationsIfNeeded();

    // Find which digits have changed and animate them
    final maxLength = math.max(_previousValue.length, _currentValue.length);

    for (int i = 0; i < maxLength; i++) {
      final prevChar = i < _previousValue.length ? _previousValue[i] : '0';
      final currChar = i < _currentValue.length ? _currentValue[i] : '0';

      if (prevChar != currChar && _controllers.containsKey(i)) {
        _controllers[i]!.reset();
        _controllers[i]!.forward();
      }
    }
  }

  void _initializeAnimationsIfNeeded() {
    final currentLength = _currentValue.length;

    // Add new controllers for new positions
    for (int i = _controllers.length; i < currentLength; i++) {
      _controllers[i] = AnimationController(
        duration: widget.duration,
        vsync: this,
      );
      _animations[i] = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _controllers[i]!,
        curve: Curves.easeOutCubic,
      ));
    }

    // Remove controllers for positions we no longer need
    final keysToRemove = <int>[];
    _controllers.forEach((key, controller) {
      if (key >= currentLength) {
        controller.dispose();
        keysToRemove.add(key);
      }
    });
    for (var key in keysToRemove) {
      _controllers.remove(key);
      _animations.remove(key);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Widget _buildAnimatedDigit(int index) {
    final currentChar = index < _currentValue.length ? _currentValue[index] : '';
    final previousChar = index < _previousValue.length ? _previousValue[index] : '';

    if (!_animations.containsKey(index)) {
      return Text(currentChar, style: widget.textStyle);
    }

    return AnimatedBuilder(
      animation: _animations[index]!,
      builder: (context, child) {
        final animationValue = _animations[index]!.value;

        return SizedBox(
          height: widget.textStyle.fontSize! * 1.2,
          child: ClipRect(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Previous digit sliding up
                Transform.translate(
                  offset: Offset(0, -widget.textStyle.fontSize! * 1.2 * animationValue),
                  child: Opacity(
                    opacity: 1.0 - animationValue,
                    child: Text(
                      previousChar,
                      style: widget.textStyle,
                    ),
                  ),
                ),
                // Current digit sliding up from bottom
                Transform.translate(
                  offset: Offset(0, widget.textStyle.fontSize! * 1.2 * (1.0 - animationValue)),
                  child: Opacity(
                    opacity: animationValue,
                    child: Text(
                      currentChar,
                      style: widget.textStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        for (int i = 0; i < _currentValue.length; i++)
          _buildAnimatedDigit(i),
      ],
    );
  }
}

