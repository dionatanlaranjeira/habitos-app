import 'dart:io';

import 'package:intl/intl.dart';
import 'package:signals/signals.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../global_modules/auth/stores/auth_store.dart';
import '../../home/models/models.dart';
import '../../home/repositories/repositories.dart';

import '../../habit_selection/models/habit_model.dart';
import '../../habit_selection/repositories/repositories.dart';
import '../../../global_modules/user/models/user_model.dart';
import '../../../global_modules/user/repositories/user_repository.dart';
import '../models/models.dart';
import '../mixins/mixins.dart';
import '../repositories/repositories.dart';

class GroupController with GroupVariables {
  GroupController({
    required String groupId,
    required GroupRepository groupRepository,
    required CheckInRepository checkInRepository,
    required HabitRepository habitRepository,
    required UserRepository userRepository,
    required AuthStore authStore,
  }) : _groupId = groupId,
       _groupRepository = groupRepository,
       _checkInRepository = checkInRepository,
       _habitRepository = habitRepository,
       _userRepository = userRepository,
       _authStore = authStore {
    _init();
  }

  final String _groupId;
  final GroupRepository _groupRepository;
  final CheckInRepository _checkInRepository;
  final HabitRepository _habitRepository;
  final UserRepository _userRepository;
  final AuthStore _authStore;

  String? get _userId => _authStore.user?.uid;

  String get _dateString => DateFormat('yyyy-MM-dd').format(selectedDate.value);

  bool get isToday {
    final now = DateTime.now();
    final sel = selectedDate.value;
    return sel.year == now.year && sel.month == now.month && sel.day == now.day;
  }

  void _init() {
    _loadGroup();
    _loadHabitLibrary();
    _loadMembers();
    _loadMyHabits();
    _loadCheckIns();
  }

  Future<void> _loadHabitLibrary() async {
    await FutureHandler<List<HabitModel>>(
      asyncState: habitLibraryAS,
      futureFunction: _habitRepository.getHabitLibrary(),
    ).call();
  }

  Future<void> _loadGroup() async {
    await FutureHandler<GroupModel?>(
      asyncState: groupAS,
      futureFunction: _groupRepository.getGroupById(_groupId),
    ).call();
  }

  Future<void> _loadMembers() async {
    await FutureHandler<List<GroupMemberModel>>(
      asyncState: membersAS,
      futureFunction: _groupRepository.getGroupMembers(_groupId),
      onValue: (members) => _loadMemberNames(members),
    ).call();
  }

  Future<void> _loadMemberNames(List<GroupMemberModel> members) async {
    final Map<String, String> names = {...memberNamesAS.value.value ?? {}};

    for (final member in members) {
      if (names.containsKey(member.userId)) continue;

      await FutureHandler<UserModel?>(
        asyncState: asyncSignal(
          AsyncLoading(),
        ), // Sinal temporário para não afetar o principal
        futureFunction: _userRepository.getUser(member.userId),
        onValue: (user) {
          if (user != null) {
            names[member.userId] = user.name;
          } else {
            names[member.userId] = 'Usuário';
          }
        },
        catchError: (e, s) {
          names[member.userId] = 'Usuário';
        },
      ).call();
    }

    memberNamesAS.value = AsyncData(names);
  }

  Future<void> _loadMyHabits() async {
    if (_userId == null) return;

    await FutureHandler<List<HabitModel>>(
      asyncState: myHabitsAS,
      futureFunction: () async {
        final habitIds = await _groupRepository.getMemberHabits(
          groupId: _groupId,
          userId: _userId!,
        );

        if (habitIds.isEmpty) return <HabitModel>[];

        final allHabits = await _habitRepository.getHabitLibrary();
        return allHabits.where((h) => habitIds.contains(h.id)).toList();
      }(),
    ).call();
  }

  Future<void> _loadCheckIns() async {
    // Meus check-ins do dia
    if (_userId != null) {
      await FutureHandler<List<CheckInModel>>(
        asyncState: myCheckInsAS,
        futureFunction: _checkInRepository.getCheckInsByUserAndDate(
          groupId: _groupId,
          userId: _userId!,
          date: _dateString,
        ),
      ).call();
    }

    // Todos os check-ins do dia (para ranking e visibilidade)
    await FutureHandler<List<CheckInModel>>(
      asyncState: allCheckInsAS,
      futureFunction: _checkInRepository.getCheckInsByDate(
        groupId: _groupId,
        date: _dateString,
      ),
    ).call();
  }

  bool isHabitCheckedIn(String habitId) {
    final checkIns = myCheckInsAS.value.value ?? [];
    return checkIns.any((c) => c.habitId == habitId);
  }

  CheckInModel? getCheckInForHabit(String habitId) {
    final checkIns = myCheckInsAS.value.value ?? [];
    try {
      return checkIns.firstWhere((c) => c.habitId == habitId);
    } catch (_) {
      return null;
    }
  }

  void setPhotoForHabit(String habitId, File photo) {
    pendingPhotos.value = {...pendingPhotos.value, habitId: photo};
  }

  void setDescriptionForHabit(String habitId, String description) {
    pendingDescriptions.value = {
      ...pendingDescriptions.value,
      habitId: description,
    };
  }

  Future<void> submitCheckIn(String habitId, {String? description}) async {
    if (_userId == null) return;

    // Priorizar descrição passada por parâmetro ou pegar do signal
    final effectiveDescription =
        description ?? pendingDescriptions.value[habitId] ?? '';
    final photo = pendingPhotos.value[habitId];

    if (photo == null) {
      Messages.error('Tire uma foto para comprovar o hábito.');
      return;
    }

    await FutureHandler<void>(
      asyncState: submitCheckInAS,
      futureFunction: _checkInRepository.submitCheckIn(
        groupId: _groupId,
        userId: _userId!,
        habitId: habitId,
        date: _dateString,
        photo: photo,
        description: effectiveDescription,
      ),
      onValue: (_) {
        // Limpar dados pendentes
        final updatedPhotos = {...pendingPhotos.value};
        updatedPhotos.remove(habitId);
        pendingPhotos.value = updatedPhotos;

        final updatedDescs = {...pendingDescriptions.value};
        updatedDescs.remove(habitId);
        pendingDescriptions.value = updatedDescs;

        Messages.success('Check-in registrado! 🎯');

        // Recarregar check-ins
        _loadCheckIns();
      },
      catchError: (e, s) {
        Log.error('Erro ao registrar check-in', error: e, stackTrace: s);
        Messages.error('Erro ao registrar check-in.');
      },
    ).call();
  }

  void goToPreviousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
    _loadCheckIns();
  }

  void goToNextDay() {
    final next = selectedDate.value.add(const Duration(days: 1));
    final now = DateTime.now();
    // Não permitir ir para o futuro
    if (next.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59))) {
      return;
    }
    selectedDate.value = next;
    _loadCheckIns();
  }

  /// Pontos de um membro no dia
  int getPointsForMember(String userId, String date) {
    final checkIns = allCheckInsAS.value.value ?? [];
    return checkIns.where((c) => c.userId == userId && c.date == date).length;
  }

  /// Pontos totais de um membro (soma de todos os check-ins carregados)
  int getTotalPointsForMember(String userId) {
    final checkIns = allCheckInsAS.value.value ?? [];
    return checkIns.where((c) => c.userId == userId).length;
  }

  Future<void> refresh() async {
    _init();
  }
}
