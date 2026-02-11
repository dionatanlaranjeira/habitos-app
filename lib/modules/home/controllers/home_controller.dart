import 'dart:async';
import 'package:signals/signals_flutter.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../global_modules/global_modules.dart';
import '../../habit_selection/habit_selection.dart';
import '../../group/group_module.dart';
import '../../group/models/check_in_model.dart';
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
        _activityCache.clear(); // Clear cache for new user
        _setupStream(uid);
        _loadMonthActivity();
      }
    });

    // Efeito para recarregar ao mudar o mês
    effect(() {
      currentDateS.value;
      _loadMonthActivity();
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

  final Map<String, List<CheckInModel>> _activityCache = {};

  Future<void> _loadMonthActivity() async {
    final uid = _userId;
    if (uid == null) {
      monthActivityAS.value = AsyncData([]);
      return;
    }

    final date = currentDateS.value;
    final cacheKey = "${date.year}-${date.month}";

    if (_activityCache.containsKey(cacheKey)) {
      monthActivityAS.value = AsyncData(_activityCache[cacheKey]!);
      isFirstLoadS.value = false;
      return;
    }

    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);

    await FutureHandler(
      asyncState: monthActivityAS,
      futureFunction: _homeRepository.getUserCheckIns(
        userId: uid,
        start: start,
        end: end,
      ),
      onValue: (data) {
        _activityCache[cacheKey] = data;
        isFirstLoadS.value = false;
      },
    ).call(showLoading: false);
  }

  void nextMonth() {
    final next = DateTime(
      currentDateS.value.year,
      currentDateS.value.month + 1,
    );
    final now = DateTime.now();
    if (next.isAfter(DateTime(now.year, now.month))) return;
    currentDateS.value = next;
  }

  void previousMonth() {
    final date = currentDateS.value;
    currentDateS.value = DateTime(date.year, date.month - 1);
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
    ).call();
  }

  Future<void> selectGroup(GroupModel group) async {
    if (_userId == null) return;

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
  }

  // Importante: Controller deve limpar subscription ao ser descartado
  // O Dart/Flutter não tem destrutor garantido para classes puras,
  // mas como é um singleton/factory via GetIt ou similar, esperamos que dure.
  // Se fosse um AutoDispose, precisaríamos de um método dispose().
  void dispose() {
    _subscription?.cancel();
  }
}
