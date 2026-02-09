import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../../global_modules/global_modules.dart';
import '../../home/home.dart';
import '../register.dart';

class RegisterController with RegisterVariables {
  RegisterController({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<void> register() async {
    await FutureHandler(
      asyncState: registerSignal,
      futureFunction: _authRepository.createUserWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
      onValue: (credential) async {
        if (credential == null) return;
        final authUser = credential.user;
        if (authUser == null) return;
        final user = UserModel(
          uid: authUser.uid,
          name: nameController.text.trim().isEmpty
              ? emailController.text.trim().split('@').first
              : nameController.text.trim(),
          email: authUser.email ?? emailController.text.trim(),
          photoUrl: null,
          createdAt: DateTime.now(),
        );
        await _userRepository.createUser(user);
        Messages.success('Conta criada com sucesso!');
        AppRouter.router.go(HomeModule.path);
      },
      catchError: (e, s) {
        Log.error('Falha no registro', error: e, stackTrace: s);
        _showAuthError(e);
      },
    ).call();
  }

  void _showAuthError(Object e) {
    String message = 'Não foi possível criar a conta. Tente novamente.';
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Este email já está em uso.';
          break;
        case 'weak-password':
          message = 'A senha deve ter no mínimo 6 caracteres.';
          break;
        case 'invalid-email':
          message = 'Email inválido.';
          break;
        default:
          message = e.message ?? message;
      }
    }
    Messages.error(message);
  }
}
