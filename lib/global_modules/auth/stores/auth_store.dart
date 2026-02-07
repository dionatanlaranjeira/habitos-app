import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';

import '../repositories/auth_repository.dart';

class AuthStore extends ChangeNotifier {
  AuthStore(this._repository) {
    _subscription = _repository.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthRepository _repository;
  StreamSubscription<firebase_auth.User?>? _subscription;

  firebase_auth.User? _user;
  firebase_auth.User? get currentUser => _user;

  bool get isAuthenticated => _user != null;

  void _onAuthStateChanged(firebase_auth.User? user) {
    if (_user == user) return;
    _user = user;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
