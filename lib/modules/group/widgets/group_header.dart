import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

import '../controllers/controllers.dart';

class GroupHeader extends StatelessWidget {
  final GroupController controller;

  const GroupHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Nome do grupo e status
        Watch((context) {
          final group = controller.groupAS.watch(context).value;
          if (group == null) return const SizedBox.shrink();

          return Column(
            children: [
              Text(
                group.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(group.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(group.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _statusColor(group.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 16),
        // Navegação de datas
        Watch((context) {
          final date = controller.selectedDate.watch(context);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.chevronLeft),
                onPressed: controller.goToPreviousDay,
              ),
              GestureDetector(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: controller.isToday
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.isToday
                        ? 'Hoje'
                        : DateFormat('dd MMM, yyyy', 'pt_BR').format(date),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: controller.isToday
                          ? theme.colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.chevronRight),
                onPressed: controller.isToday ? null : controller.goToNextDay,
              ),
            ],
          );
        }),
      ],
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Temporada Ativa';
      case 'draft':
        return 'Em Formação';
      case 'closed':
        return 'Encerrada';
      default:
        return status;
    }
  }
}
