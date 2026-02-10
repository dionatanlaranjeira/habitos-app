import 'dart:io';

import 'package:signals/signals.dart';

import '../../home/models/models.dart';
import '../../habit_selection/models/habit_model.dart';
import '../models/models.dart';

mixin GroupVariables {
  final groupAS = asyncSignal<GroupModel?>(AsyncLoading());
  final habitLibraryAS = asyncSignal<List<HabitModel>>(AsyncLoading());
  final myHabitsAS = asyncSignal<List<HabitModel>>(AsyncLoading());
  final myCheckInsAS = asyncSignal<List<CheckInModel>>(AsyncLoading());
  final allCheckInsAS = asyncSignal<List<CheckInModel>>(AsyncLoading());
  final membersAS = asyncSignal<List<GroupMemberModel>>(AsyncLoading());
  final memberNamesAS = asyncSignal<Map<String, String>>(AsyncData({}));
  final checkinCommentsAS = asyncSignal<List<CommentModel>>(AsyncLoading());
  final submitCheckInAS = asyncSignal<void>(AsyncData(null));

  final selectedDate = signal<DateTime>(DateTime.now());
  final isHabitsListExpanded = signal<bool>(false);
  final pendingPhotos = mapSignal<String, File>({}); // habitId -> File
  final pendingDescriptions = mapSignal<String, String>(
    {},
  ); // habitId -> String
}
