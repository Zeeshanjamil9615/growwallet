import 'package:flutter/material.dart';
import 'package:gcoin/theme_controller.dart';
import 'package:get/get.dart';

class MyColor{

  // G Coin Brand Colors - Extracted from Logo and Image
  static const Color gCoinPrimary = Color(0xFF7ED321); // Vibrant lime green from logo
  static const Color gCoinSecondary = Color(0xFF4CAF50); // Rich green accent
  static const Color gCoinAccent = Color(0xFF8BC34A); // Light green highlight
  static const Color gCoinDark = Color(0xFF2E7D32); // Deep forest green
  static const Color gCoinLight = Color(0xFFCDDC39); // Bright lime for highlights
  static const Color gCoinGradientStart = Color(0xFF66BB6A); // Gradient start
  static const Color gCoinGradientEnd = Color(0xFF4CAF50); // Gradient end

  // Primary brand color - Updated to G Coin vibrant green
  static const Color primaryColor = gCoinPrimary;

  // Dark theme colors - G Coin inspired dark theme with deep greens
  static const Color backgroundColor = Color(0xFF0D1F0F); // Very deep green-black
  static const Color splashBgColor = primaryColor;
  static const Color appBarColor = Color(0xFF1B2E1C); // Dark green app bar

  static const Color fieldEnableBorderColor = primaryColor;
  static const Color fieldDisableBorderColor = Color(0xFF2D4A2E); // Muted dark green
  static const Color fieldFillColor = Color(0xFF1B2E1C); // Input field background
  static const Color headingTextColor = Color(0xFFE8F5E8); // Very light green tint
  static const Color colorBlackFaq = Color(0xFF81C784); // Medium green text
  static const Color grayColor3 = Color(0xFFF1F8E9); // Very light green-white

  /// card color - G Coin themed cards
  static const Color cardPrimaryColor = Color(0xFF1B2E1C); // Primary card color
  static const Color cardSecondaryColor = Color(0xFF2D4A2E); // Secondary card
  static const Color cardBorderColor = Color(0xFF388E3C); // Green card borders
  static const Color cardBgColor = Color(0xFF1B2E1C); // Card background

  /// text color
  static const Color primaryTextColor = Color(0xFFFFFFFF); // White text
  static const Color secondaryTextColor = primaryColor; // G Coin green text
  static const Color smallTextColor = Color(0xFFCED9CE); // Light green-tinted text
  static const Color labelTextColor = Color(0xFFA5D6A7); // Medium green text
  static const Color hintTextColor = Color(0xFF66BB6A); // Green hint text
  static const Color colorRed = Color(0xFFE53935); // Modern red for errors

  static const Color colorWhite = Color(0xFFFFFFFF); // Pure white
  static const Color colorBlack = Color(0xFF0D1F0F); // Deep green-black
  static const Color colorGrey = Color(0xFF6B7B6C); // Green-tinted gray
  static const Color transparentColor = Colors.transparent;

  /// bottom navbar
  static const Color bottomNavBgColor = Color(0xFF1B2E1C); // Dark green navigation
  static const Color borderColor = Color(0xFF388E3C); // Green borders

  /// shimmer color
  static const Color shimmerBaseColor = Color(0xFF1B2E1C); // Dark green shimmer base
  static const Color shimmerSplashColor = Color(0xFF2D4A2E); // Green shimmer highlight
  static const Color red = Color(0xFFE53935); // Modern red
  static const Color green = Color(0xFF4CAF50); // G Coin green

  // Light theme colors - Clean white with G Coin green accents
  static const Color lScreenBgColor1 = Color(0xFFF8FFF8); // Very light green tint
  static const Color lScreenBgColor = Color(0xFFFFFFFF); // Pure white
  static const Color lTextColor = Color(0xFF1B2E1C); // Dark green text
  static const Color lPrimaryColor = gCoinPrimary; // G Coin green for light theme
  static const Color delteBtnTextColor = Color(0xFFD32F2F); // Delete button text
  static const Color delteBtnColor = Color(0xFFFFEBEE); // Delete button background
  static const Color textFieldDisableBorderColor = Color(0xFFE0E0E0); // Light border
  static const Color titleColor = Color(0xFF1B2E1C); // Dark green title
  static const Color naturalDark = Color(0xFF388E3C); // Natural dark green
  static const Color naturalLight = Color(0xFF81C784); // Natural light green
  static const Color ticketDetails = Color(0xFF66BB6A); // Ticket details color

  /// set color for theme
  static const Color iconColor = primaryColor; // G Coin green icons
  static const Color activeBadgeColor = primaryColor; // Active badge color

  // G Coin specific colors from brand theme
  static const Color gCoinSuccess = Color(0xFF4CAF50); // Success green
  static const Color gCoinWarning = Color(0xFFFF9800); // Warning orange
  static const Color gCoinInfo = Color(0xFF2196F3); // Info blue
  static const Color gCoinProfit = Color(0xFF8BC34A); // Profit light green
  static const Color gCoinLoss = colorRed; // Loss red
  static const Color gCoinNeutral = Color(0xFF757575); // Neutral gray

  // All existing getter methods remain unchanged
  static Color getActiveBadgeBGColor() {
    return Get.find<ThemeController>().darkTheme ? activeBadgeColor : activeBadgeColor;
  }

  static Color getLabelTextColor(){
    return Get.find<ThemeController>().darkTheme ? labelTextColor : lTextColor.withValues(alpha:0.6);
  }

  static Color getInputTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorBlack;
  }

  static Color getHintTextColor(){
    return Get.find<ThemeController>().darkTheme ? hintTextColor : colorBlack;
  }

  static Color getButtonColor(){
    return  primaryColor ;
  }

  static Color getAppbarTitleColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : lPrimaryColor;
  }

  static Color getButtonTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorWhite;
  }

  static Color getPrimaryColor(){
    return  primaryColor ;
  }

  static Color getAppbarBgColor() {
    return Get.find<ThemeController>().darkTheme ? appBarColor : colorWhite;
  }

  static Color getScreenBgColor(){
    return Get.find<ThemeController>().darkTheme ? backgroundColor : lScreenBgColor1;
  }

  static Color getScreenBgColor1(){
    return Get.find<ThemeController>().darkTheme ? backgroundColor : colorWhite;
  }

  static Color getCardBg(){
    return Get.find<ThemeController>().darkTheme ? cardBgColor : colorWhite;
  }

  static Color getBottomNavBg(){
    return Get.find<ThemeController>().darkTheme ? bottomNavBgColor : primaryColor;
  }

  static Color getBottomNavIconColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorGrey;
  }

  static Color getBottomNavSelectedIconColor(){
    return Get.find<ThemeController>().darkTheme ? primaryColor : colorWhite;
  }

  static Color getTextFieldTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : lPrimaryColor;
  }

  static Color getTextFieldLabelColor(){
    return Get.find<ThemeController>().darkTheme ? labelTextColor : lTextColor;
  }

  static Color getTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorBlack;
  }

  static Color getTextColor1(){
    return Get.find<ThemeController>().darkTheme ? Colors.white.withValues(alpha:0.75) : lTextColor;
  }

  static Color getTextFieldBg(){
    return Get.find<ThemeController>().darkTheme ? transparentColor : transparentColor;
  }

  static Color getTextFieldHintColor(){
    return Get.find<ThemeController>().darkTheme ? hintTextColor : colorGrey;
  }

  static Color getPrimaryTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorBlack;
  }

  static Color getSecondaryTextColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite.withValues(alpha:0.8) : colorBlack.withValues(alpha:0.8);
  }

  static Color getDialogBg(){
    return Get.find<ThemeController>().darkTheme ? cardBgColor : colorWhite;
  }

  static Color getStatusColor(){
    return Get.find<ThemeController>().darkTheme ? primaryColor : lPrimaryColor;
  }

  static Color getFieldDisableBorderColor(){
    return Get.find<ThemeController>().darkTheme ? fieldDisableBorderColor : colorGrey.withValues(alpha:0.3);
  }

  static Color getFieldEnableBorderColor(){
    return Get.find<ThemeController>().darkTheme ? primaryColor : lPrimaryColor;
  }

  static Color getTextColor2(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorGrey;
  }

  static Color getTextColor3(){
    return Get.find<ThemeController>().darkTheme ? getLabelTextColor() : getLabelTextColor();
  }

  static Color getBottomNavColor(){
    return Get.find<ThemeController>().darkTheme ? bottomNavBgColor : colorWhite;
  }

  static Color getUnselectedIconColor(){
    return Get.find<ThemeController>().darkTheme ? colorWhite : colorGrey.withValues(alpha:0.6);
  }

  static Color getSelectedIconColor(){
    return Get.find<ThemeController>().darkTheme ? getTextColor() : getTextColor();
  }

  static Color getPendingStatueColor(){
    return Get.find<ThemeController>().darkTheme ? Colors.grey : Colors.orange;
  }

  static Color getBorderColor(){
    return Get.find<ThemeController>().darkTheme ? Colors.grey.withValues(alpha:.3) : Colors.grey.withValues(alpha:.3);
  }

  static Color getTextFieldDisableBorder(){
    return textFieldDisableBorderColor;
  }

  static Color getHeadingTextColor() {
    return Get.find<ThemeController>().darkTheme ? headingTextColor: titleColor;
  }

  static Color getErrorColor(){
    return Get.find<ThemeController>().darkTheme ? colorRed : Color(0xFFE53935).withOpacity(0.8);
  }

  // Additional G Coin specific getters
  static Color getGCoinPrimaryColor() => gCoinPrimary;
  static Color getGCoinSecondaryColor() => gCoinSecondary;
  static Color getGCoinAccentColor() => gCoinAccent;
  static Color getGCoinSuccessColor() => gCoinSuccess;
  static Color getGCoinWarningColor() => gCoinWarning;
  static Color getGCoinInfoColor() => gCoinInfo;
  static Color getGCoinProfitColor() => gCoinProfit;
  static Color getGCoinLossColor() => gCoinLoss;
  static Color getGCoinNeutralColor() => gCoinNeutral;

  // Modern gradient methods for beautiful UI effects
  static LinearGradient getGCoinPrimaryGradient() {
    return LinearGradient(
      colors: [gCoinGradientStart, gCoinGradientEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getGCoinSuccessGradient() {
    return LinearGradient(
      colors: [gCoinSecondary, gCoinAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient getGCoinAccentGradient() {
    return LinearGradient(
      colors: [gCoinLight, gCoinPrimary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Modern vibrant gradient for hero sections
  static LinearGradient getGCoinHeroGradient() {
    return LinearGradient(
      colors: [
        Color(0xFF7ED321),
        Color(0xFF4CAF50),
        Color(0xFF2E7D32),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.0, 0.5, 1.0],
    );
  }

  // Subtle gradient for cards
  static LinearGradient getGCoinCardGradient() {
    return LinearGradient(
      colors: [
        Color(0xFF66BB6A).withOpacity(0.1),
        Color(0xFF4CAF50).withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  //support ticket
  static const Color purpleAcccent = gCoinPrimary; // Updated to G Coin green
  static const Color bodyTextColor = Color(0xFF757575);

  static Color getTicketDetailsColor() {
    return ticketDetails;
  }
  static Color getGreyColor() {
    return MyColor.colorGrey;
  }
  static Color getGreyText(){
    return  MyColor.colorBlack.withValues(alpha:0.5);
  }

  static const Color pendingColor = Color(0xFFFF9800);
  static const Color highPriorityPurpleColor = gCoinPrimary; // Updated to G Coin green
  static const Color bgColorLight = Color(0xFFF8FFF8); // Light green background
  static const Color closeRedColor = colorRed; // Consistent red
  static const Color greenSuccessColor = greenP;
  static const Color redCancelTextColor = colorRed; // Consistent red
  static const Color greenP = green; // Consistent green

  // Additional modern UI colors for G Coin app
  static const Color gCoinCardElevated = Color(0xFF2D4A2E); // Elevated card color
  static const Color gCoinDivider = Color(0xFF388E3C); // Divider color
  static const Color gCoinShadow = Color(0x1A000000); // Shadow color
  static const Color gCoinOverlay = Color(0x80000000); // Overlay color

  // Light theme specific G Coin colors
  static const Color lGCoinCardColor = Color(0xFFFAFDFA); // Light green-tinted card
  static const Color lGCoinBorderColor = Color(0xFFE8F5E8); // Light green border
  static const Color lGCoinShadow = Color(0x0D000000); // Light shadow
  static const Color lGCoinOverlay = Color(0x4D000000); // Light overlay

  // Additional helper methods for G Coin specific UI
  static Color getGCoinCardColor() {
    return Get.find<ThemeController>().darkTheme ? cardBgColor : lGCoinCardColor;
  }

  static Color getGCoinElevatedCardColor() {
    return Get.find<ThemeController>().darkTheme ? gCoinCardElevated : colorWhite;
  }

  static Color getGCoinDividerColor() {
    return Get.find<ThemeController>().darkTheme ? gCoinDivider : lGCoinBorderColor;
  }

  static Color getGCoinShadowColor() {
    return Get.find<ThemeController>().darkTheme ? gCoinShadow : lGCoinShadow;
  }

  static Color getGCoinOverlayColor() {
    return Get.find<ThemeController>().darkTheme ? gCoinOverlay : lGCoinOverlay;
  }

  // New modern UI helper methods
  static Color getGCoinSurfaceColor() {
    return Get.find<ThemeController>().darkTheme ? Color(0xFF1B2E1C) : Color(0xFFFAFDFA);
  }

  static Color getGCoinOnSurfaceColor() {
    return Get.find<ThemeController>().darkTheme ? Color(0xFFE8F5E8) : Color(0xFF1B2E1C);
  }

  // Modern glassmorphism effect colors
  static Color getGCoinGlassColor() {
    return Get.find<ThemeController>().darkTheme
        ? Color(0xFF4CAF50).withOpacity(0.1)
        : Color(0xFF7ED321).withOpacity(0.1);
  }

  static Color getGCoinGlassBorderColor() {
    return Get.find<ThemeController>().darkTheme
        ? Color(0xFF4CAF50).withOpacity(0.2)
        : Color(0xFF7ED321).withOpacity(0.2);
  }
}