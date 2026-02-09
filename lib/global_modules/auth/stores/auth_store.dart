import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:signals/signals_flutter.dart';

import '../repositories/auth_repository.dart';

class AuthStore {
  AuthStore(this._repository) {
    _subscription = _repository.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthRepository _repository;
  StreamSubscription<firebase_auth.User?>? _subscription;

  final currentUser = signal<firebase_auth.User?>(null);

  firebase_auth.User? get user => currentUser.value;
  bool get isAuthenticated => currentUser.value != null;

  void _onAuthStateChanged(firebase_auth.User? user) {
    if (currentUser.value == user) return;
    currentUser.value = user;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
