import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:zard/zard.dart';
import '../../../core/core.dart';
import '../../home/models/models.dart';
import '../models/game_mode_model.dart';
import '../models/season_duration_model.dart';

mixin CreateGroupVariables {
  final createGroupSignal = asyncSignal<GroupModel?>(AsyncData(null));

  final gameModesAS = asyncSignal<List<GameModeModel>>(AsyncLoading());
  final seasonDurationsAS = asyncSignal<List<SeasonDurationModel>>(
    AsyncLoading(),
  );

  final groupNameController = TextEditingController();
  final currentStep = signal<int>(0);

  final selectedDurationS = signal<SeasonDurationModel?>(null);
  final selectedModeS = signal<GameModeModel?>(null);

  final startImmediatelyS = signal<bool>(true);
  final scheduledStartDateS = signal<DateTime?>(null);

  final validator = FieldValidationHandler(
    fields: {
      'name': z
          .string(message: "O nome do grupo é obrigatório")
          .min(3, message: "O nome do grupo deve ter pelo menos 3 caracteres")
          .max(30, message: "O nome do grupo deve ter no máximo 30 caracteres"),
    },
  );
}
