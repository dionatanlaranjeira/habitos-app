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
      'name': z
          .string(message: "O nome é obrigatório")
          .min(3, message: "O nome deve ter pelo menos 3 caracteres")
          .max(30, message: "O nome deve ter no máximo 30 caracteres"),
      'email': z
          .string(message: "O email é obrigatório")
          .email(message: "Email inválido"),
      'password': z
          .string(message: "A senha é obrigatória")
          .min(6, message: "A senha deve ter pelo menos 6 caracteres"),
    },
  );
}
