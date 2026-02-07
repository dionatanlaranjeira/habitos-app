import 'dart:ui';

class AppColors {
  static AppColors? _instance;
  AppColors._();

  static AppColors get i {
    _instance ??= AppColors._();
    return _instance!;
  }

  Color get containerColor => const Color(0xFFF2F2F5);
  Color get primaryColor => const Color(0xFF5616d9);
  Color get primaryColorDark => const Color(0xFF430fb6);
  Color get dividerColor => const Color(0xFFDDDDDE);
  Color get errorColor => const Color(0xFFFF3B3B);
  Color get successColor => const Color(0xFF06C270);
  Color get warningColor => const Color(0xFFFFCC00);
  Color get infoColor => const Color(0xFF0063F7);
  Color get atentionColor => const Color.fromARGB(255, 255, 123, 0);

  Color get borderColor => const Color(0xFFDDDDDE);

  //Dark Theme
  Color get primaryLightColor => const Color.fromARGB(255, 138, 86, 250);
  Color get backgroundDarkColor => const Color(0xFF1a1a1d);
  Color get dividerColorDarkMode => const Color(0xFF414040);
}
