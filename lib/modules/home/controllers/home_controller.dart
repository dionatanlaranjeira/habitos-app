import 'dart:async';
import 'package:signals/signals_flutter.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../global_modules/global_modules.dart';
import '../../habit_selection/habit_selection.dart';
import '../../group/group_module.dart';
import '../home.dart';

class HomeController with HomeVariables {
  HomeController({
    required HomeRepository homeRepository,
    required UserStore userStore,
  }) : _homeRepository = homeRepository,
       _userStore = userStore {
    _init();
  }

  final HomeRepository _homeRepository;
  final UserStore _userStore;

  StreamSubscription<List<GroupModel>>? _subscription;
  String? _currentUserId;

  String? get _userId => _userStore.uid;

  void _init() {
    // Efeito para monitorar usuário e recriar assinatura
    effect(() {
      final uid = _userStore.uid;

      if (uid != _currentUserId) {
        _currentUserId = uid;
        _setupStream(uid);
      }
    });
  }

  void _setupStream(String? uid) {
    _subscription?.cancel();

    if (uid == null) {
      groupsAS.value = AsyncData([]);
      return;
    }

    groupsAS.value = AsyncLoading();

    _subscription = _homeRepository
        .watchGroupsByUser(uid)
        .listen(
          (data) {
            groupsAS.value = AsyncData(data);
          },
          onError: (e, s) {
            Log.error('Erro no stream de grupos', error: e, stackTrace: s);
            groupsAS.value = AsyncError(e, s);
          },
        );
  }

  /// Método para compatibilidade (refresh manual), mas o stream já é live.
  /// Pode ser usado para forçar uma reconexão se necessário.
  Future<void> fetchGroups() async {
    _setupStream(_userId);
  }

  Future<void> joinGroup() async {
    final code = groupCodeController.text.trim().toUpperCase();
    if (code.isEmpty || _userId == null) return;

    await FutureHandler(
      asyncState: joinGroupSignal,
      futureFunction: _homeRepository.joinGroupByCode(
        code: code,
        userId: _userId!,
      ),
      onValue: (group) async {
        groupCodeController.clear();
        if (group == null) {
          Messages.error('Código inválido ou grupo cheio.');
          return;
        }

        Messages.success('Você entrou no grupo "${group.name}"!');
        AppRouter.router.push(
          HabitSelectionModule.path,
          extra: {'groupId': group.id},
        );
      },
      catchError: (e, s) {
        Log.error('Falha ao entrar no grupo', error: e, stackTrace: s);
        Messages.error('Não foi possível entrar no grupo.');
      },
    ).call();
  }

  Future<void> selectGroup(GroupModel group) async {
    if (_userId == null) return;

    try {
      final habits = await _homeRepository.getMemberHabits(
        groupId: group.id,
        userId: _userId!,
      );

      if (habits.isEmpty) {
        AppRouter.router.push(
          HabitSelectionModule.path,
          extra: {'groupId': group.id},
        );
      } else {
        AppRouter.router.push(
          GroupModule.path.replaceFirst(':groupId', group.id),
        );
      }
    } catch (e, s) {
      Log.error('Erro ao selecionar grupo', error: e, stackTrace: s);
      Messages.error('Erro ao acessar o grupo. Tente novamente.');
    }
  }

  // Importante: Controller deve limpar subscription ao ser descartado
  // O Dart/Flutter não tem destrutor garantido para classes puras,
  // mas como é um singleton/factory via GetIt ou similar, esperamos que dure.
  // Se fosse um AutoDispose, precisaríamos de um método dispose().
  void dispose() {
    _subscription?.cancel();
  }
}
