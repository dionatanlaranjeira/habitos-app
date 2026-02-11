import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../logger/logger.dart';
import '../exceptions/exceptions.dart';
import '../../shared/ui/widgets/messages.dart';

class ExceptionHandler {
  final Object error;
  final StackTrace? stackTrace;

  ExceptionHandler(this.error, this.stackTrace) {
    Log.error('Exceção capturada', error: error, stackTrace: stackTrace);

    // Mostra mensagem amigável para o usuário
    String? displayMessage;

    if (error is FirebaseAuthException) {
      displayMessage = _getFirebaseAuthMessage(error as FirebaseAuthException);
    } else if (error is HttpException) {
      displayMessage = (error as HttpException).message;
    } else if (error is String) {
      displayMessage = error as String;
    }

    // Se for abortado pelo sistema (ex: Google Sign In cancelado), não mostra nada
    if (displayMessage == '__aborted__') return;

    // Fallback se não conseguirmos extrair uma mensagem específica
    displayMessage ??= 'Ops! Ocorreu um erro inesperado.';

    // Mostra o erro na UI
    Messages.error(displayMessage);

    if (Firebase.apps.isNotEmpty) {
      final globalException = GlobalException(error, stackTrace);
      FirebaseCrashlytics.instance.recordError(
        globalException.error,
        globalException.stackTrace,
        printDetails: false,
        fatal: true,
      );
    }
  }

  String? _getFirebaseAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      // Auth
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou senha incorretos.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'sign_in_aborted':
        return '__aborted__';

      // Register
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'weak-password':
        return 'A senha fornecida é muito fraca.';
      case 'invalid-email':
        return 'O endereço de email é inválido.';

      default:
        return e.message;
    }
  }
}
