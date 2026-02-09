import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

import '../../../shared/shared.dart';
import 'controllers/controllers.dart';
import 'models/models.dart';
import 'widgets/widgets.dart';

class HabitSelectionPage extends StatelessWidget {
  const HabitSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<HabitSelectionController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.habitSelection_title),
        centerTitle: true,
      ),
      bottomNavigationBar: HabitSelectionBottomBar(controller: controller),
      body: Watch((context) {
        // Leitura do signal aqui para garantir que o Watch reconstrua quando mudar
        final selectedIds = controller.selectedHabitIds.value;

        return SignalFutureBuilder<List<CategoryModel>>(
          asyncState: controller.categoriesAS.value,
          loadingWidget: const Center(child: CircularProgressIndicator()),
          builder: (categories) {
            return SignalFutureBuilder<List<HabitModel>>(
              asyncState: controller.habitLibraryAS.value,
              loadingWidget: const Center(child: CircularProgressIndicator()),
              emptyWidget: Center(
                child: Text(context.l10n.habitSelection_noHabitsFound),
              ),
              builder: (habits) {
                final grouped = _groupHabitsByCategory(habits, categories);
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          context.l10n.habitSelection_subtitle,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    ...grouped.entries.expand((entry) {
                      final category = entry.key;
                      final categoryHabits = entry.value;

                      return [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              category.getLocalizedTitle(
                                Localizations.localeOf(context).languageCode,
                              ),
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: context.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.1,
                                ),
                            delegate: SliverChildBuilderDelegate((ctx, index) {
                              final habit = categoryHabits[index];
                              final isSelected = selectedIds.contains(habit.id);

                              return HabitTile(
                                habit: habit,
                                isSelected: isSelected,
                                onTap: () => controller.toggleHabit(habit.id),
                              );
                            }, childCount: categoryHabits.length),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ];
                    }),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 40 + MediaQuery.of(context).padding.bottom,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      }),
    );
  }

  Map<CategoryModel, List<HabitModel>> _groupHabitsByCategory(
    List<HabitModel> habits,
    List<CategoryModel> categories,
  ) {
    final Map<CategoryModel, List<HabitModel>> grouped = {};

    final sortedCategories = List<CategoryModel>.from(categories)
      ..sort((a, b) => a.order.compareTo(b.order));

    for (var category in sortedCategories) {
      final categoryHabits =
          habits.where((h) => h.category == category.id).toList()
            ..sort((a, b) => a.order.compareTo(b.order));

      if (categoryHabits.isNotEmpty) {
        grouped[category] = categoryHabits;
      }
    }

    return grouped;
  }
}
