import 'dart:io';

import 'package:intl/intl.dart';
import 'package:signals/signals.dart';

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../global_modules/global_modules.dart';
import '../../home/models/models.dart';
import '../../habit_selection/models/habit_model.dart';
import '../../habit_selection/repositories/repositories.dart';
import '../models/models.dart';
import '../mixins/mixins.dart';
import '../repositories/repositories.dart';

class GroupController with GroupVariables {
  GroupController({
    required String groupId,
    required GroupDetailRepository groupRepository,
    required CheckInRepository checkInRepository,
    required HabitRepository habitRepository,
    required InteractionRepository
    interactionRepository, // Added to constructor
    required WeeklyRankingRepository weeklyRankingRepository,
    required UserStore userStore,
  }) : _groupId = groupId,
       _groupRepository = groupRepository,
       _checkInRepository = checkInRepository,
       _habitRepository = habitRepository,
       _interactionRepository =
           interactionRepository, // Added to initializer list
       _weeklyRankingRepository = weeklyRankingRepository,
       _userStore = userStore {
    // Sincroniza o perfil do próprio usuário reativamente
    effect(() {
      final user = _userStore.user.value;
      if (user != null) {
        final currentMap = memberProfilesAS.value.value ?? {};
        if (currentMap[user.uid] != user) {
          memberProfilesAS.value = AsyncData({...currentMap, user.uid: user});
        }
      }
    });

    _init();
  }

  final String _groupId;
  final GroupDetailRepository _groupRepository;
  final CheckInRepository _checkInRepository;
  final HabitRepository _habitRepository;
  final InteractionRepository _interactionRepository;
  final WeeklyRankingRepository _weeklyRankingRepository;
  final UserStore _userStore;

  UserStore get userStore => _userStore;
  String? get _userId => _userStore.uid;

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
    _loadWeeklyRanking();
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
      onValue: (members) =>
          _loadMemberProfiles(members.map((m) => m.userId).toList()),
    ).call();
  }

  Future<void> _loadMemberProfiles(List<String> userIds) async {
    final Map<String, UserModel> profiles = {
      ...memberProfilesAS.value.value ?? {},
    };
    bool changed = false;

    // Filtra IDs que ainda não temos no cache
    final missingIds = userIds.where((id) => !profiles.containsKey(id)).toSet();

    if (missingIds.isEmpty) return;

    // Busca os perfis faltantes em paralelo
    await Future.wait(
      missingIds.map((id) async {
        try {
          final user = await _groupRepository.getUserById(id);
          if (user != null) {
            profiles[id] = user;
            changed = true;
          }
        } catch (e) {
          Log.error('Erro ao carregar perfil do usuário $id', error: e);
        }
      }),
    );

    if (changed) {
      memberProfilesAS.value = AsyncData(profiles);
    }
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

  Future<void> _loadCheckIns({bool silent = false}) async {
    // 1. Meus check-ins do dia
    if (_userId != null) {
      await FutureHandler<List<CheckInModel>>(
        asyncState: myCheckInsAS,
        futureFunction: _checkInRepository.getCheckInsByUserAndDate(
          groupId: _groupId,
          userId: _userId!,
          date: _dateString,
        ),
      ).call(showLoading: !silent);
    }

    // 2. Todos os check-ins do dia (para ranking e visibilidade)
    await FutureHandler<List<CheckInModel>>(
      asyncState: allCheckInsAS,
      futureFunction: _checkInRepository.getCheckInsByDate(
        groupId: _groupId,
        date: _dateString,
      ),
      onValue: (checkins) {
        if (checkins.isNotEmpty) {
          final userIds = checkins.map((c) => c.userId).toList();
          _loadMemberProfiles(userIds);
        }
      },
    ).call(showLoading: !silent);

    // 3. Sincronizar minhas reações para otimismo preciso
    if (_userId != null) {
      try {
        final reactions = await _interactionRepository
            .getReactionsByUserAndDate(
              groupId: _groupId,
              userId: _userId!,
              date: _dateString,
            );

        final Map<String, String?> reactionMap = {};
        for (var r in reactions) {
          final checkinId = r.checkinId;
          if (checkinId != null) {
            // Um user só tem uma reação por check-in
            reactionMap[checkinId] = r.emoji;
          }
        }
        myReactionsByCheckIn.value = reactionMap;
      } catch (e) {
        Log.error('Erro ao sincronizar reações do usuário', error: e);
      }
    }
  }

  Future<void> _loadWeeklyRanking({bool silent = false}) async {
    await FutureHandler<WeeklyRankingModel>(
      asyncState: weeklyRankingAS,
      futureFunction: _weeklyRankingRepository.getWeeklyRanking(
        groupId: _groupId,
      ),
      onValue: (ranking) {
        final ids = <String>{
          ...ranking.top.map((e) => e.userId),
          if (ranking.myPosition != null) ranking.myPosition!.userId,
        }.toList();

        if (ids.isNotEmpty) {
          _loadMemberProfiles(ids);
        }
      },
    ).call(showLoading: !silent);
  }

  bool isHabitCheckedIn(String habitId) {
    final checkIns = myCheckInsAS.value.value ?? [];
    return checkIns.any((c) => c.habitId == habitId);
  }

  CheckInModel? getCheckInForHabit(String habitId) {
    final checkIns = myCheckInsAS.value.value ?? [];
    try {
      return checkIns.firstWhere((c) => c.habitId == habitId);
    } catch (e) {
      return null;
    }
  }

  /// Check-ins de um membro específico no dia
  List<CheckInModel> getCheckInsForMember(String userId) {
    final checkIns = allCheckInsAS.value.value ?? [];
    return checkIns.where((c) => c.userId == userId).toList();
  }

  // Hábitos de um membro no dia
  List<String> getCompletedHabitIdsForMember(String userId) {
    return getCheckInsForMember(userId).map((c) => c.habitId).toList();
  }

  // Nomes dos hábitos de um membro no dia
  List<String> getCompletedHabitNamesForMember(String userId) {
    final habitIds = getCompletedHabitIdsForMember(userId);
    final habits = habitLibraryAS.value.value ?? [];
    return habitIds.map((id) {
      final habit = habits.where((h) => h.id == id).firstOrNull;
      return habit?.name ?? id;
    }).toList();
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
        _loadWeeklyRanking(silent: true);
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

  Future<void> refreshWeeklyRanking() async {
    _loadWeeklyRanking();
  }

  Future<void> ensureMemberProfilesLoaded(List<String> userIds) {
    return _loadMemberProfiles(userIds);
  }

  Future<void> deleteCheckIn(String checkinId) async {
    await FutureHandler<void>(
      asyncState: groupActionAS,
      futureFunction: _checkInRepository.deleteCheckIn(
        groupId: _groupId,
        checkinId: checkinId,
      ),
      onValue: (_) {
        Messages.success('Check-in removido com sucesso.');
        _loadCheckIns(silent: true);
        _loadWeeklyRanking(silent: true);
      },
    ).call(showLoading: false);
  }

  Future<void> leaveGroup() async {
    await FutureHandler<void>(
      asyncState: groupActionAS,
      futureFunction: _groupRepository.leaveGroup(groupId: _groupId),
      onValue: (_) {
        Messages.success('Você saiu do grupo.');
        AppRouter.router.go('/home');
      },
    ).call();
  }

  // --- INTERAÇÕES ---

  Future<void> toggleReaction(String checkinId, String emoji) async {
    if (_userId == null) return;

    final currentData = allCheckInsAS.peek().value;
    if (currentData == null) return;

    // --- LÓGICA OTIMISTA ---
    final previousEmoji = myReactionsByCheckIn[checkinId];
    final isSameEmoji = previousEmoji == emoji;

    // 1. Atualizar rastreio local
    myReactionsByCheckIn[checkinId] = isSameEmoji ? null : emoji;

    // 2. Atualizar contagem no sinal allCheckInsAS
    final newList = currentData.map((c) {
      if (c.id == checkinId) {
        final newCounts = Map<String, int>.from(c.reactionCounts);

        // Decrementar emoji antigo (se estava reagido com outro)
        if (previousEmoji != null) {
          newCounts[previousEmoji] = ((newCounts[previousEmoji] ?? 0) - 1)
              .clamp(0, 999);
        }

        // Incrementar novo (se não é o mesmo — se é o mesmo, só removeu)
        if (!isSameEmoji) {
          newCounts[emoji] = (newCounts[emoji] ?? 0) + 1;
        }

        return c.copyWith(reactionCounts: newCounts);
      }
      return c;
    }).toList();

    allCheckInsAS.value = AsyncData(newList);
    // ------------------------

    FutureHandler<void>(
      asyncState: socialWriteAS,
      futureFunction: _interactionRepository.toggleReaction(
        groupId: _groupId,
        checkinId: checkinId,
        userId: _userId!,
        emoji: emoji,
      ),
      catchError: (e, s) => null, // ExceptionHandler já trata
    ).call(showLoading: false);
  }

  Future<void> addComment(String checkinId, String text) async {
    if (_userId == null || text.trim().isEmpty) return;

    final currentData = allCheckInsAS.peek().value;
    if (currentData != null) {
      // OTIMISTA: Incrementar contador de comentários
      final newList = currentData.map((c) {
        if (c.id == checkinId) {
          return c.copyWith(commentCount: (c.commentCount + 1));
        }
        return c;
      }).toList();
      allCheckInsAS.value = AsyncData(newList);

      // OTIMISTA: Injetar comentário na lista local
      final currentComments = checkinCommentsAS.peek().value ?? [];
      final tempComment = CommentModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        userId: _userId!,
        text: text.trim(),
        createdAt: DateTime.now(),
      );
      checkinCommentsAS.value = AsyncData([...currentComments, tempComment]);
    }

    FutureHandler<void>(
      asyncState: socialWriteAS,
      futureFunction: _interactionRepository.addComment(
        groupId: _groupId,
        checkinId: checkinId,
        userId: _userId!,
        text: text.trim(),
      ),
      catchError: (e, s) => null,
    ).call(showLoading: false);
  }

  Future<void> deleteComment(String checkinId, String commentId) async {
    final currentData = allCheckInsAS.peek().value;
    if (currentData != null) {
      // OTIMISTA: Decrementar contador de comentários
      final newList = currentData.map((c) {
        if (c.id == checkinId) {
          return c.copyWith(commentCount: (c.commentCount - 1).clamp(0, 999));
        }
        return c;
      }).toList();
      allCheckInsAS.value = AsyncData(newList);

      // OTIMISTA: Remover comentário da lista local
      final currentComments = checkinCommentsAS.peek().value ?? [];
      final newListComments = currentComments
          .where((c) => c.id != commentId)
          .toList();
      checkinCommentsAS.value = AsyncData(newListComments);
    }

    FutureHandler<void>(
      asyncState: socialWriteAS,
      futureFunction: _interactionRepository.deleteComment(
        groupId: _groupId,
        checkinId: checkinId,
        commentId: commentId,
      ),
      catchError: (e, s) => null,
    ).call(showLoading: false);
  }

  Future<List<CommentModel>> getComments(String checkinId) {
    return _interactionRepository.getComments(
      groupId: _groupId,
      checkinId: checkinId,
    );
  }

  Future<void> loadComments(String checkinId) async {
    await FutureHandler<List<CommentModel>>(
      asyncState: checkinCommentsAS,
      futureFunction: getComments(checkinId),
    ).call();
  }
}
