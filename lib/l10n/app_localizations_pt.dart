// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get shared_appTitle => 'Hábitos';

  @override
  String get shared_confirm => 'Confirmar';

  @override
  String get habitSelection_title => 'Escolha seus hábitos';

  @override
  String get habitSelection_subtitle =>
      'Selecione de 3 a 5 hábitos para esta temporada.';

  @override
  String habitSelection_selected(int count) {
    return '$count selecionados';
  }

  @override
  String get habitSelection_minMax => 'mínimo 3, máximo 5';

  @override
  String get habitSelection_noHabitsFound => 'Nenhum hábito cadastrado.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get shared_appTitle => 'Hábitos';

  @override
  String get shared_confirm => 'Confirmar';

  @override
  String get habitSelection_title => 'Escolha seus hábitos';

  @override
  String get habitSelection_subtitle =>
      'Selecione de 3 a 5 hábitos para esta temporada.';

  @override
  String habitSelection_selected(int count) {
    return '$count selecionados';
  }

  @override
  String get habitSelection_minMax => 'mínimo 3, máximo 5';

  @override
  String get habitSelection_noHabitsFound => 'Nenhum hábito cadastrado.';
}
