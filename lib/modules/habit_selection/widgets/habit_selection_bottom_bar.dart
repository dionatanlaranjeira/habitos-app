import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../../core/core.dart';
import '../../modules.dart';
import '../../../../shared/shared.dart';

class HabitSelectionBottomBar extends StatelessWidget {
  const HabitSelectionBottomBar({super.key, required this.controller});

  final HabitSelectionController controller;

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final count = controller.selectedCount;
      final status = controller.saveStatusAS.value;
      final isLoading = status.isLoading;

      return Container(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.habitSelection_selected(count),
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: count < 3 || count > 5
                          ? context.colorScheme.error
                          : context.colorScheme.primary,
                    ),
                  ),
                  Text(
                    context.l10n.habitSelection_minMax,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            FilledButton(
              onPressed: controller.canConfirm && !isLoading
                  ? () async {
                      final success = await controller.confirmSelection();
                      if (success && context.mounted) {
                        AppRouter.router.go(
                          GroupModule.path.replaceFirst(
                            ':groupId',
                            controller.groupId,
                          ),
                        );
                      }
                    }
                  : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(
                  100,
                  48,
                ), // width fixo ou pelo menos finito
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(context.l10n.shared_confirm),
            ),
          ],
        ),
      );
    });
  }
}
