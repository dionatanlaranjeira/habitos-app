import 'package:signals/signals_flutter.dart';

import '../../auth/stores/auth_store.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserStore {
  UserStore(this._userRepository, this._authStore) {
    effect(() {
      final authUser = _authStore.currentUser.value;
      if (authUser == null) {
        user.value = null;
        return;
      }
      _loadUser(authUser.uid);
    });
  }

  final UserRepository _userRepository;
  final AuthStore _authStore;

  final user = signal<UserModel?>(null);

  bool get hasUser => user.value != null;

  Future<void> _loadUser(String uid) async {
    try {
      user.value = await _userRepository.getUser(uid);
    } catch (_) {
      user.value = null;
    }
  }
}
