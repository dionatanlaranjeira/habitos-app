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
  }) : _authRepository = authRepository,
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
    ).call();
  }

  Future<void> registerWithGoogle() async {
    await FutureHandler(
      asyncState: registerSignal,
      futureFunction: _authRepository.signInWithGoogle(),
      onValue: (credential) async {
        if (credential == null) return;
        final user = credential.user;
        if (user != null) await _ensureUserDoc(user);
        AppRouter.router.go(HomeModule.path);
      },
    ).call();
  }

  Future<void> registerWithApple() async {
    await FutureHandler(
      asyncState: registerSignal,
      futureFunction: _authRepository.signInWithApple(),
      onValue: (credential) async {
        if (credential == null) return;
        final user = credential.user;
        if (user != null) await _ensureUserDoc(user);
        AppRouter.router.go(HomeModule.path);
      },
    ).call();
  }

  Future<void> _ensureUserDoc(firebase_auth.User authUser) async {
    final existing = await _userRepository.getUser(authUser.uid);
    if (existing != null) return;
    final user = UserModel(
      uid: authUser.uid,
      name:
          authUser.displayName ?? authUser.email?.split('@').first ?? 'Usuário',
      email: authUser.email ?? '',
      photoUrl: authUser.photoURL,
      createdAt: DateTime.now(),
    );
    await _userRepository.createUser(user);
  }
}
