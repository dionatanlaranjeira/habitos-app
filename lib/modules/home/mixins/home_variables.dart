import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../models/models.dart';

mixin HomeVariables {
  final createGroupSignal = asyncSignal<GroupModel?>(AsyncData(null));
  final joinGroupSignal = asyncSignal<GroupModel?>(AsyncData(null));
  final groupsAS = asyncSignal<List<GroupModel>>(AsyncLoading());
  final groupNameController = TextEditingController();
  final groupCodeController = TextEditingController();
}
