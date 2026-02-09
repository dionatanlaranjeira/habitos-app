import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../global_modules/global_modules.dart';
import '../home.dart';

class HomeController with HomeVariables {
  HomeController({
    required GroupRepository groupRepository,
    required GroupStore groupStore,
    required AuthStore authStore,
  })  : _groupRepository = groupRepository,
        _groupStore = groupStore,
        _authStore = authStore;

  final GroupRepository _groupRepository;
  final GroupStore _groupStore;
  final AuthStore _authStore;

  String? get _userId => _authStore.user?.uid;

  Future<void> createGroup() async {
    final name = groupNameController.text.trim();
    if (name.isEmpty || _userId == null) return;

    await FutureHandler(
      asyncState: createGroupSignal,
      futureFunction: _groupRepository.createGroup(
        name: name,
        ownerId: _userId!,
      ),
      onValue: (group) async {
        groupNameController.clear();
        await _groupStore.refresh();
        Messages.success('Grupo "${group?.name}" criado!');
      },
      catchError: (e, s) {
        Log.error('Falha ao criar grupo', error: e, stackTrace: s);
        Messages.error('Não foi possível criar o grupo.');
      },
    ).call();
  }

  Future<void> joinGroup() async {
    final code = groupCodeController.text.trim().toUpperCase();
    if (code.isEmpty || _userId == null) return;

    await FutureHandler(
      asyncState: joinGroupSignal,
      futureFunction: _groupRepository.joinGroupByCode(
        code: code,
        userId: _userId!,
      ),
      onValue: (group) async {
        groupCodeController.clear();
        if (group == null) {
          Messages.error('Código inválido ou grupo cheio.');
          return;
        }
        await _groupStore.refresh();
        Messages.success('Você entrou no grupo "${group.name}"!');
      },
      catchError: (e, s) {
        Log.error('Falha ao entrar no grupo', error: e, stackTrace: s);
        Messages.error('Não foi possível entrar no grupo.');
      },
    ).call();
  }
}
