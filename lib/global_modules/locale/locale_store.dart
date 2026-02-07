import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _localeKey = 'app_locale';

class LocaleStore extends ChangeNotifier {
  LocaleStore(this._prefs) {
    _loadLocale();
  }

  final SharedPreferences _prefs;
  Locale _locale = const Locale('pt', 'BR');

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(_localeKey, _localeToString(locale));
    notifyListeners();
  }

  void _loadLocale() {
    final stored = _prefs.getString(_localeKey);
    if (stored != null) {
      _locale = _localeFromString(stored);
    }
  }

  String _localeToString(Locale locale) {
    return jsonEncode({
      'languageCode': locale.languageCode,
      'countryCode': locale.countryCode,
    });
  }

  Locale _localeFromString(String stored) {
    try {
      final map = jsonDecode(stored) as Map<String, dynamic>;
      return Locale(
        map['languageCode'] as String? ?? 'pt',
        map['countryCode'] as String?,
      );
    } catch (_) {
      return const Locale('pt', 'BR');
    }
  }
}
