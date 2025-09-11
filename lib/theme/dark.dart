
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/style.dart';


ThemeData dark = ThemeData(
  fontFamily: 'Inter',
  primaryColor: MyColor.getPrimaryColor(),
  brightness: Brightness.light,
  scaffoldBackgroundColor: MyColor.getScreenBgColor(),
  hintColor: MyColor.hintTextColor,
  focusColor: MyColor.fieldEnableBorderColor,
  
  buttonTheme: ButtonThemeData(
    buttonColor: MyColor.getPrimaryColor(),
  ),
  cardColor: MyColor.cardBgColor,
  appBarTheme: AppBarTheme(
    backgroundColor: MyColor.getAppbarBgColor(),

    elevation: 0,
    titleTextStyle: interRegularLarge.copyWith(color: MyColor.colorWhite),
    iconTheme: IconThemeData(
      size: 20,
      color: MyColor.colorWhite
    )
  ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(MyColor.colorWhite),
      fillColor: WidgetStateProperty.all(MyColor.colorWhite),
      overlayColor: WidgetStateProperty.all(MyColor.transparentColor),
    ));