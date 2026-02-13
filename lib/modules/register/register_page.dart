import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

import '../../shared/shared.dart';
import 'register.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<RegisterController>();
    final validator = controller.validator;
    final formKey = validator.formKey;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Text(
                    'Criar conta',
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preencha os dados para começar',
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form fields
                  DefaultInputField(
                    controller: controller.nameController,
                    label: 'Nome',
                    validatorHandler: validator,
                    validationField: 'name',
                  ),
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 16),
                  DefaultInputField(
                    controller: controller.confirmPasswordController,
                    label: 'Confirmar senha',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Confirme a senha';
                      }
                      if (value != controller.passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Register button
                  Watch((_) {
                    final isLoading = controller.registerSignal.value.isLoading;
                    return FilledButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (formKey.currentState?.validate() ?? false) {
                                if (controller.passwordController.text !=
                                    controller.confirmPasswordController.text) {
                                  return;
                                }
                                controller.register();
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
                          : const Text('Criar conta'),
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

                  // Social Buttons
                  Watch((_) {
                    final isLoading = controller.registerSignal.value.isLoading;
                    return Column(
                      children: [
                        OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : controller.registerWithGoogle,
                          icon: const Icon(Icons.g_mobiledata, size: 24),
                          label: const Text('Continuar com Google'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 40),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (Theme.of(context).platform == TargetPlatform.iOS)
                          OutlinedButton.icon(
                            onPressed: isLoading
                                ? null
                                : controller.registerWithApple,
                            icon: const Icon(Icons.apple, size: 24),
                            label: const Text('Continuar com Apple'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 40),
                            ),
                          ),
                      ],
                    );
                  }),

                  const SizedBox(height: 32),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Já tem conta? ',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Entrar',
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
