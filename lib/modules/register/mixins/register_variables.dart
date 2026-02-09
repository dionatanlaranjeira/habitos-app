import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import 'package:zard/zard.dart';
import '../../../core/core.dart';

mixin RegisterVariables {
  final registerSignal = asyncSignal<firebase_auth.UserCredential?>(
    AsyncData(null),
  );
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final validator = FieldValidationHandler(
    fields: {
      'name': z.string().optional(),
      'email': z.string().email(),
      'password': z.string().min(6),
    },
  );
}
