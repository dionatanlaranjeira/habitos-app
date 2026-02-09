import 'package:signals/signals_flutter.dart';

import '../../auth/stores/auth_store.dart';
import '../models/group_model.dart';
import '../repositories/group_repository.dart';

class GroupStore {
  GroupStore(this._groupRepository, this._authStore) {
    effect(() {
      final authUser = _authStore.currentUser.value;
      if (authUser == null) {
        groups.value = [];
        return;
      }
      _loadGroups(authUser.uid);
    });
  }

  final GroupRepository _groupRepository;
  final AuthStore _authStore;

  final groups = signal<List<GroupModel>>([]);
  final isLoading = signal<bool>(false);

  bool get hasGroups => groups.value.isNotEmpty;

  Future<void> _loadGroups(String userId) async {
    try {
      isLoading.value = true;
      groups.value = await _groupRepository.getGroupsByUser(userId);
    } catch (_) {
      groups.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    final authUser = _authStore.currentUser.value;
    if (authUser == null) return;
    await _loadGroups(authUser.uid);
  }
}
