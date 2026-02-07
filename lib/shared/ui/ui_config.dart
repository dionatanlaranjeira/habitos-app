import 'package:flutter/material.dart';

import '../shared.dart';

class UiConfig {
  UiConfig._();

  static String get title => 'Template App';

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    useMaterial3: true,
    dividerColor: AppColors.i.borderColor,
    textTheme: AppTextTheme.i.textTheme,
    primaryColor: AppColors.i.primaryColor,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: AppColors.i.primaryColor,
      primary: AppColors.i.primaryColor,
      error: AppColors.i.errorColor,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    dividerColor: AppColors.i.borderColor,
    useMaterial3: true,
    textTheme: AppTextTheme.i.textTheme,
    scaffoldBackgroundColor: AppColors.i.backgroundDarkColor,
    primaryColor: AppColors.i.primaryLightColor,
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: AppColors.i.primaryLightColor,
      primary: AppColors.i.primaryLightColor,
      error: AppColors.i.errorColor,
    ),
  );
}
