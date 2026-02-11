import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../../group/models/check_in_model.dart';
import '../models/models.dart';

mixin HomeVariables {
  final createGroupSignal = asyncSignal<GroupModel?>(AsyncData(null));
  final joinGroupSignal = asyncSignal<GroupModel?>(AsyncData(null));
  final groupsAS = asyncSignal<List<GroupModel>>(AsyncLoading());
  final currentDateS = signal<DateTime>(DateTime.now());
  final monthActivityAS = asyncSignal<List<CheckInModel>>(AsyncLoading());
  final isFirstLoadS = signal<bool>(true);

  final groupNameController = TextEditingController();
  final groupCodeController = TextEditingController();
}
