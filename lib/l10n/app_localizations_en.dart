// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get shared_appTitle => 'Habits';

  @override
  String get shared_confirm => 'Confirm';

  @override
  String get habitSelection_title => 'Pick your habits';

  @override
  String get habitSelection_subtitle => 'Select 3 to 5 habits for this season.';

  @override
  String habitSelection_selected(int count) {
    return '$count selected';
  }

  @override
  String get habitSelection_minMax => 'minimum 3, maximum 5';

  @override
  String get habitSelection_noHabitsFound => 'No habits found.';
}
