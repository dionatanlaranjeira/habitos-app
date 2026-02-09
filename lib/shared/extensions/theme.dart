import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import '../shared.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  AppDimensions get dimensions => AppDimensions.i;

  Color get primaryColor => colorScheme.primary;

  Color get secondaryColor => colorScheme.secondary;

  Color get backgroundColor => theme.scaffoldBackgroundColor;

  Color get surfaceColor => colorScheme.surface;

  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
