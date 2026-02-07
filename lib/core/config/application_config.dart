import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

import 'environments.dart';

class ApplicationConfig {
  Future<void> configureApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await _initFirebase();
    await _loadEnv();
  }

  Future<void> _loadEnv() async {
    await Environments.loadEnv();
  }

  Future<void> _initFirebase() async {
    await Firebase.initializeApp();
    FirebaseAnalytics.instance;
    FirebaseCrashlytics.instance;
  }
}
