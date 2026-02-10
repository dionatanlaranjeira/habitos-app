import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide ErrorBuilder;
import 'package:signals/signals_flutter.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../home/models/models.dart';
import '../../shared/shared.dart';
import '../habit_selection/models/habit_model.dart';
import 'controllers/controllers.dart';
import 'models/models.dart';
import 'widgets/widgets.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GroupController>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Watch((context) {
          final group = controller.groupAS.watch(context).value;
          return Text(group?.name ?? '');
        }),
        centerTitle: true,
      ),
      body: SignalFutureBuilder<GroupModel?>(
        asyncState: controller.groupAS.watch(context),
        onRetry: controller.refresh,
        loadingWidget: const GroupSkeleton(),
        builder: (group) {
          if (group == null) {
            return const Center(child: Text('Grupo não encontrado'));
          }

          return RefreshIndicator(
            onRefresh: controller.refresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header com navegação de data
                  GroupHeader(controller: controller),
                  const SizedBox(height: 20),

                  // Meu Progresso (Compacto)
                  _buildMyProgressSection(context, controller, theme),
                  const SizedBox(height: 24),

                  // Feed de Competição
                  _buildCompetitionFeed(context, controller, theme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMyProgressSection(
    BuildContext context,
    GroupController controller,
    ThemeData theme,
  ) {
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

  Widget _buildCompetitionFeed(
    BuildContext context,
    GroupController controller,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feed da Competição',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SignalFutureBuilder<List<CheckInModel>>(
          asyncState: controller.allCheckInsAS.watch(context),
          loadingWidget: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DefaultShimmer(
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
          emptyWidget: Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(
                  LucideIcons.flame,
                  size: 48,
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ninguém postou ainda hoje.\nSeja o primeiro!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          builder: (allCheckIns) {
            return Watch((context) {
              final names = controller.memberNamesAS.watch(context).value ?? {};
              final library =
                  controller.habitLibraryAS.watch(context).value ?? [];

              // Ordenar check-ins pelo horário (mais recentes primeiro)
              final sortedCheckIns = [...allCheckIns];
              sortedCheckIns.sort(
                (a, b) => b.completedAt.compareTo(a.completedAt),
              );

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedCheckIns.length,
                itemBuilder: (context, index) {
                  final checkIn = sortedCheckIns[index];
                  final memberName = names[checkIn.userId] ?? 'Usuário';

                  // Encontrar detalhes do hábito na biblioteca completa
                  final habitDetail = library.firstWhere(
                    (h) => h.id == checkIn.habitId,
                    orElse: () => const HabitModel(
                      id: '',
                      name: 'Hábito',
                      category: 'Geral',
                      iconCode: 0xe1af, // default eye icon or similar
                    ),
                  );

                  return CheckinFeedCard(
                    checkIn: checkIn,
                    memberName: memberName,
                    habitName: habitDetail.name,
                    habitIcon: habitDetail.iconData,
                    controller: controller,
                  );
                },
              );
            });
          },
        ),
      ],
    );
  }
}
