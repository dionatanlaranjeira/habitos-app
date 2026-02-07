import 'package:cloud_functions/cloud_functions.dart';

/// Adapter para Cloud Functions callable.
/// Centraliza a instância e permite injeção para testes.
class FunctionsAdapter {
  FunctionsAdapter() : _functions = FirebaseFunctions.instance;

  final FirebaseFunctions _functions;
  FirebaseFunctions get instance => _functions;
}
