import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import '../logger/logger.dart';
import 'environments.dart';

class ApplicationConfig {
  static bool _firebaseInitialized = false;
  static bool get isFirebaseInitialized => _firebaseInitialized;

  static SharedPreferences? _prefs;
  static SharedPreferences get prefs => _prefs!;

  Future<void> configureApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    await _initFirebase();
    if (_firebaseInitialized) {
      await _loadEnv();
    }
  }

  Future<void> _loadEnv() async {
    await Environments.loadEnv();
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseAnalytics.instance;
      FirebaseCrashlytics.instance;
      _firebaseInitialized = true;
    } catch (e, s) {
      Log.error(
        'Falha ao inicializar Firebase. Execute "flutterfire configure" se ainda não configurou.',
        error: e,
        stackTrace: s,
      );
      _firebaseInitialized = false;
    }
  }
}
