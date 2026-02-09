import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

mixin RegisterVariables {
  final registerSignal = asyncSignal<firebase_auth.UserCredential?>(AsyncData(null));
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
}
