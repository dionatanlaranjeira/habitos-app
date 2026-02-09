import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals/signals_flutter.dart';

const _localeKey = 'app_locale';

class LocaleStore {
  LocaleStore(this._prefs) {
    _loadLocale();
  }

  final SharedPreferences _prefs;
  final locale = signal<Locale>(const Locale('pt', 'BR'));

  Future<void> setLocale(Locale value) async {
    if (locale.value == value) return;
    locale.value = value;
    await _prefs.setString(_localeKey, _localeToString(value));
  }

  void _loadLocale() {
    final stored = _prefs.getString(_localeKey);
    if (stored != null) {
      locale.value = _localeFromString(stored);
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
