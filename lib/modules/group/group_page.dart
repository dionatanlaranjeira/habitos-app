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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: Watch((context) {
            final group = controller.groupAS.watch(context).value;
            return Text(group?.name ?? '');
          }),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => GroupInfoSheet.show(context, controller),
              icon: const Icon(LucideIcons.info),
              tooltip: 'Informações do Grupo',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Feed'),
              Tab(text: 'Ranking'),
            ],
          ),
        ),
        body: SignalFutureBuilder<GroupModel?>(
          asyncState: controller.groupAS.watch(context),
          onRetry: controller.refresh,
          loadingWidget: const GroupSkeleton(),
          builder: (group) {
            if (group == null) {
              return const Center(child: Text('Grupo não encontrado'));
            }

            return TabBarView(
              children: [
                _buildFeedTab(context, controller, theme),
                _buildRankingTab(context, controller, theme),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeedTab(
    BuildContext context,
    GroupController controller,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GroupHeader(controller: controller),
            const SizedBox(height: 20),
            _buildMyProgressSection(context, controller, theme),
            const SizedBox(height: 24),
            _buildCompetitionFeed(context, controller, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingTab(
    BuildContext context,
    GroupController controller,
    ThemeData theme,
  ) {
    return SignalFutureBuilder<WeeklyRankingModel>(
      asyncState: controller.weeklyRankingAS.watch(context),
      onRetry: controller.refreshWeeklyRanking,
      loadingWidget: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DefaultShimmer(
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
      builder: (ranking) {
        final myPosition = ranking.myPosition;
        final myPositionOutsideTop =
            myPosition != null && myPosition.position > ranking.top.length;

        return RefreshIndicator(
          onRefresh: controller.refreshWeeklyRanking,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ranking semanal',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ranking.weekStartDate} - ${ranking.weekEndDate}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (ranking.top.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  alignment: Alignment.center,
                  child: Text(
                    'Ainda não há pontuação nesta semana.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.55,
                      ),
                    ),
                  ),
                )
              else
                ...ranking.top.map(
                  (entry) =>
                      _buildRankingTile(theme, entry, highlighted: false),
                ),
              if (myPositionOutsideTop) ...[
                const SizedBox(height: 8),
                Text(
                  'Sua posição',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                _buildRankingTile(theme, myPosition, highlighted: true),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingTile(
    ThemeData theme,
    WeeklyRankingEntryModel entry, {
    required bool highlighted,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.25)
              : theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${entry.position}º',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dias ativos: ${entry.seasonActiveDays} • Dias zerados: ${entry.seasonZeroDays}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.points} pts',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${entry.weeklyActiveDays} dias na semana',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
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

                  final habitDetail = library.firstWhere(
                    (h) => h.id == checkIn.habitId,
                    orElse: () => const HabitModel(
                      id: '',
                      name: 'Hábito',
                      category: 'Geral',
                      iconCode: 0xe1af,
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
