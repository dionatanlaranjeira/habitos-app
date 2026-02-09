import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

import '../../../global_modules/global_modules.dart';

mixin HomeVariables {
  final createGroupSignal = asyncSignal<GroupModel?>(AsyncData(null));
  final joinGroupSignal = asyncSignal<GroupModel?>(AsyncData(null));
  final groupNameController = TextEditingController();
  final groupCodeController = TextEditingController();
}
