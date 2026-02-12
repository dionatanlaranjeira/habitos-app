import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

import '../controllers/controllers.dart';
import 'habit_checkin_tile.dart';

class MyProgressSection extends StatelessWidget {
  final GroupController controller;

  const MyProgressSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      final habits = controller.myHabitsAS.watch(context).value ?? [];
      final myCheckIns = controller.myCheckInsAS.watch(context).value ?? [];
      final allCheckIns = controller.allCheckInsAS.watch(context).value ?? [];
      final isExpanded = controller.isHabitsListExpanded.watch(context);

      if (habits.isEmpty) return const SizedBox.shrink();

      final total = habits.length;
      final done = myCheckIns.length;
      final progress = total > 0 ? done / total : 0.0;
      final feedIsEmpty = allCheckIns.isEmpty;

      return Theme(
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
          child: ExpansionTile(
            key: PageStorageKey('my_progress_${controller.selectedDate.value}'),
            initiallyExpanded: feedIsEmpty || isExpanded,
            onExpansionChanged: (v) =>
                controller.isHabitsListExpanded.value = v,
            title: Row(
              children: [
                Text(
                  'Meu Progresso',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$done/$total hábitos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                ),
              ),
            ),
            trailing: Icon(
              isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
              color: theme.colorScheme.primary,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: habits.map((habit) {
              return HabitCheckinTile(habit: habit, controller: controller);
            }).toList(),
          ),
        ),
      );
    });
  }
}
