import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:image_picker/image_picker.dart';

mixin ProfileVariables {
  final nameController = TextEditingController();
  final avatarFile = signal<XFile?>(null);
  final saveStatus = asyncSignal<void>(AsyncData(null));
}
