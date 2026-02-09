import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:zard/zard.dart';

import '../../core/core.dart';
import '../../shared/shared.dart';
import 'login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<LoginController>();
    final formKey = GlobalKey<FormState>();
    final validator = FieldValidationHandler(
      fields: {
        'email': z.string().email(),
        'password': z.string().min(6),
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // Header
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 56,
                    color: context.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Bem-vindo de volta!',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entre na sua conta para continuar',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Form fields
                  DefaultInputField(
                    controller: controller.emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validatorHandler: validator,
                    validationField: 'email',
                  ),
                  const SizedBox(height: 16),
                  DefaultInputField(
                    controller: controller.passwordController,
                    label: 'Senha',
                    obscureText: true,
                    validatorHandler: validator,
                    validationField: 'password',
                  ),

                  const SizedBox(height: 24),

                  // Login button
                  Watch((_) {
                    final isLoading = controller.loginSignal.value.isLoading;
                    return FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (formKey.currentState?.validate() ?? false) {
                                controller.loginWithEmail();
                              }
                            },
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Entrar'),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Google button
                  Watch((_) {
                    final isLoading = controller.loginSignal.value.isLoading;
                    return OutlinedButton.icon(
                      onPressed: isLoading ? null : controller.loginWithGoogle,
                      icon: const Icon(Icons.g_mobiledata, size: 24),
                      label: const Text('Continuar com Google'),
                    );
                  }),

                  const SizedBox(height: 32),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem conta? ',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/register'),
                        child: Text(
                          'Criar conta',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
