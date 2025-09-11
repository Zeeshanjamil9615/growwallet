import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/style.dart';
ThemeData light = ThemeData(
    fontFamily: 'Inter',
    primaryColor: MyColor.lPrimaryColor,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: MyColor.colorGrey.withValues(alpha:0.3),
    hintColor: MyColor.hintTextColor,
    buttonTheme: ButtonThemeData(
      buttonColor: MyColor.getPrimaryColor(),
    ),
    cardColor: MyColor.cardBgColor,
    appBarTheme: AppBarTheme(
        backgroundColor: MyColor.lPrimaryColor,
        elevation: 0,
        titleTextStyle: interRegularLarge.copyWith(color: MyColor.colorWhite),
        iconTheme: const IconThemeData(
            size: 20,
            color: MyColor.colorWhite
        )
    ),
    checkboxTheme: CheckboxThemeData(
     checkColor: WidgetStateProperty.all(MyColor.colorBlack),
     fillColor: WidgetStateProperty.all(MyColor.primaryColor),

));