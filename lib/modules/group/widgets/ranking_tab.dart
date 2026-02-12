import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../shared/shared.dart';
import '../controllers/controllers.dart';
import 'ranking_tile.dart';

class RankingTab extends StatelessWidget {
  final GroupController controller;

  const RankingTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SignalFutureBuilder(
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
      builder: (ranking) => Watch((context) {
        final profiles = controller.memberProfilesAS.watch(context).value ?? {};
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
                  (entry) => RankingTile(
                    entry: entry,
                    highlighted: false,
                    displayNameOverride: profiles[entry.userId]?.name,
                    photoUrlOverride: profiles[entry.userId]?.photoUrl,
                  ),
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
                RankingTile(
                  entry: myPosition,
                  highlighted: true,
                  displayNameOverride: profiles[myPosition.userId]?.name,
                  photoUrlOverride: profiles[myPosition.userId]?.photoUrl,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
