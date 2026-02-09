import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/core.dart';
import '../../../shared/shared.dart';
import '../../home/home.dart';
import '../../../global_modules/global_modules.dart';
import '../login.dart';

class LoginController with LoginVariables {
  LoginController({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  Future<void> loginWithEmail() async {
    await FutureHandler(
      asyncState: loginSignal,
      futureFunction: _authRepository.signInWithEmail(
        email: emailController.text.trim(),
        password: passwordController.text,
      ),
      onValue: (_) => _goHome(),
      catchError: (e, s) {
        Log.error('Falha no login', error: e, stackTrace: s);
        _showAuthError(e);
      },
    ).call();
  }

  Future<void> loginWithGoogle() async {
    await FutureHandler(
      asyncState: loginSignal,
      futureFunction: _authRepository.signInWithGoogle(),
      onValue: (credential) async {
        if (credential == null) return;
        final user = credential.user;
        if (user != null) await _ensureUserDoc(user);
        _goHome();
      },
      catchError: (e, s) {
        Log.error('Falha no login com Google', error: e, stackTrace: s);
        _showAuthError(e);
      },
    ).call();
  }

  Future<void> _ensureUserDoc(firebase_auth.User authUser) async {
    final existing = await _userRepository.getUser(authUser.uid);
    if (existing != null) return;
    final user = UserModel(
      uid: authUser.uid,
      name: authUser.displayName ?? authUser.email?.split('@').first ?? 'Usuário',
      email: authUser.email ?? '',
      photoUrl: authUser.photoURL,
      createdAt: DateTime.now(),
    );
    await _userRepository.createUser(user);
  }

  void _goHome() => AppRouter.router.go(HomeModule.path);

  void _showAuthError(Object e) {
    String message = 'Não foi possível fazer login. Tente novamente.';
    if (e is firebase_auth.FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Email ou senha incorretos.';
          break;
        case 'user-disabled':
          message = 'Esta conta foi desativada.';
          break;
        case 'sign_in_aborted':
          return; // usuário cancelou, não mostrar mensagem
        default:
          message = e.message ?? message;
      }
    }
    Messages.error(message);
  }
}
