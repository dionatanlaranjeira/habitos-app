import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

import '../../../shared/shared.dart';
import '../models/models.dart';
import '../controllers/controllers.dart';
import '../../habit_selection/models/habit_model.dart';
import 'checkin_feed_card.dart';

class CompetitionFeed extends StatelessWidget {
  final GroupController controller;

  const CompetitionFeed({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              final profiles =
                  controller.memberProfilesAS.watch(context).value ?? {};
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
                  final profile = profiles[checkIn.userId];
                  final memberName = profile?.name ?? 'Usuário';
                  final memberPhotoUrl = profile?.photoUrl;

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
                    memberPhotoUrl: memberPhotoUrl,
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
