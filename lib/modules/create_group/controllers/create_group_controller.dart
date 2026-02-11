import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../global_modules/global_modules.dart';
import '../../habit_selection/habit_selection.dart';
import '../../home/models/models.dart';
import '../mixins/mixins.dart';
import '../repositories/repositories.dart';

class CreateGroupController with CreateGroupVariables {
  CreateGroupController({
    required CreateGroupRepository createGroupRepository,
    required UserStore userStore,
  }) : _createGroupRepository = createGroupRepository,
       _userStore = userStore {
    _loadOptions();
  }

  final CreateGroupRepository _createGroupRepository;
  final UserStore _userStore;

  String? get _userId => _userStore.uid;

  Future<void> _loadOptions() async {
    await Future.wait([_loadGameModes(), _loadSeasonDurations()]);
  }

  Future<void> _loadGameModes() async {
    await FutureHandler(
      asyncState: gameModesAS,
      futureFunction: _createGroupRepository.getGameModes(),
      onValue: (modes) {
        if (modes.isNotEmpty && selectedModeS.value == null) {
          selectedModeS.value = modes.first;
        }
      },
    ).call();
  }

  Future<void> _loadSeasonDurations() async {
    await FutureHandler(
      asyncState: seasonDurationsAS,
      futureFunction: _createGroupRepository.getSeasonDurations(),
      onValue: (durations) {
        if (durations.isNotEmpty && selectedDurationS.value == null) {
          selectedDurationS.value = durations.first;
        }
      },
    ).call();
  }

  void nextStep() {
    if (currentStep.value == 0) {
      if (validator.formKey.currentState?.validate() ?? false) {
        currentStep.value++;
      }
    } else if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> createGroup() async {
    if (_userId == null) return;
    if (selectedDurationS.value == null || selectedModeS.value == null) return;

    final startImmediately = startImmediatelyS.value;
    final scheduledDate = scheduledStartDateS.value;

    if (!startImmediately && scheduledDate == null) {
      Messages.error('Por favor, selecione uma data para o início.');
      return;
    }

    await FutureHandler<GroupModel?>(
      asyncState: createGroupSignal,
      futureFunction: _createGroupRepository.createGroup(
        name: groupNameController.text.trim(),
        ownerId: _userId!,
        seasonDuration: selectedDurationS.value!.days,
        gameMode: selectedModeS.value!.id,
        timezone: 'America/Sao_Paulo', // TODO: Pegar timezone real do device
        status: startImmediately ? 'active' : 'draft',
        seasonStartDate: startImmediately ? DateTime.now() : scheduledDate,
      ),
      onValue: (group) async {
        if (group == null) return;
        Messages.success('Grupo "${group.name}" criado com sucesso!');

        AppRouter.router.go(
          HabitSelectionModule.path,
          extra: {'groupId': group.id},
        );
      },
    ).call();
  }
}
