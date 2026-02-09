import 'package:signals/signals_flutter.dart';

import '../../auth/stores/auth_store.dart';
import '../models/group_model.dart';
import '../repositories/group_repository.dart';

class GroupStore {
  GroupStore(this._groupRepository, this._authStore) {
    effect(() {
      final authUser = _authStore.currentUser.value;
      if (authUser == null) {
        groupsAS.value = AsyncData([]);
        return;
      }
      _loadGroups(authUser.uid);
    });
  }

  final GroupRepository _groupRepository;
  final AuthStore _authStore;

  final groupsAS = asyncSignal<List<GroupModel>>(AsyncData([]));

  bool get hasGroups {
    final state = groupsAS.value;
    return state.hasValue && (state.value?.isNotEmpty ?? false);
  }

  Future<void> _loadGroups(String userId) async {
    groupsAS.value = AsyncLoading();
    try {
      final result = await _groupRepository.getGroupsByUser(userId);
      groupsAS.value = AsyncData(result);
    } catch (e, s) {
      groupsAS.value = AsyncError(e, s);
    }
  }

  Future<void> refresh() async {
    final authUser = _authStore.currentUser.value;
    if (authUser == null) return;
    await _loadGroups(authUser.uid);
  }
}
