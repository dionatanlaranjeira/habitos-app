import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:signals/signals_flutter.dart';

import '../../auth/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserStore {
  UserStore(this._authRepository, this._userRepository) {
    _subscription = _authRepository.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  StreamSubscription<firebase_auth.User?>? _subscription;

  final currentUser = signal<firebase_auth.User?>(null);
  final user = signal<UserModel?>(null);

  // Getters de conveniência
  String? get uid => currentUser.value?.uid;
  String? get email => currentUser.value?.email;
  String? get name => user.value?.name;
  bool get isAuthenticated => currentUser.value != null;
  bool get hasUser => user.value != null;

  void _onAuthStateChanged(firebase_auth.User? authUser) {
    if (currentUser.value == authUser) return;
    currentUser.value = authUser;

    if (authUser == null) {
      user.value = null;
      return;
    }

    _loadUser(authUser.uid);
  }

  Future<void> _loadUser(String uid) async {
    try {
      user.value = await _userRepository.getUser(uid);
    } catch (_) {
      user.value = null;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
