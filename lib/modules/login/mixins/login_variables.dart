import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:signals/signals.dart';

mixin LoginVariables {
  final loginSignal = asyncSignal<firebase_auth.UserCredential?>(AsyncData(null));
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
}
