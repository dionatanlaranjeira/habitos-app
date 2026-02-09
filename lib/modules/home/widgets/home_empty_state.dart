import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';
import '../controllers/home_controller.dart';
import 'sheet_helpers.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: context.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum campeonato ainda',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie ou entre em um grupo para\ncomeçar a competir!',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.7,
              ),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: () => showCreateGroupSheet(context, controller),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Criar grupo'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => showJoinGroupSheet(context, controller),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Entrar com código'),
          ),
        ],
      ),
    );
  }
}
