import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:signals/signals_flutter.dart';

import '../../../shared/shared.dart';
import '../../group/models/check_in_model.dart';
import '../controllers/home_controller.dart';

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Watch((context) {
          final currentDate = controller.currentDateS.watch(context);
          final activityState = controller.monthActivityAS.watch(context);
          final isLoading = activityState.isLoading;

          final monthName = DateFormat(
            'MMMM yyyy',
            'pt_BR',
          ).format(currentDate);
          final now = DateTime.now();
          final isCurrentMonth =
              currentDate.year == now.year && currentDate.month == now.month;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthName.capitalize(),
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Row(
                    children: [
                      _ArrowButton(
                        icon: Icons.chevron_left_rounded,
                        onPressed: controller.previousMonth,
                      ),
                      const SizedBox(width: 8),
                      _ArrowButton(
                        icon: Icons.chevron_right_rounded,
                        onPressed: isCurrentMonth ? null : controller.nextMonth,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: SignalFutureBuilder<List<CheckInModel>>(
                    key: ValueKey(currentDate),
                    asyncState: activityState,
                    loadingWidget:
                        (activityState.value == null &&
                            controller.isFirstLoadS.value)
                        ? const _CalendarSkeleton()
                        : _CalendarGrid(
                            activities: activityState.value ?? const [],
                            currentDate: currentDate,
                            isLoading: true,
                          ),
                    emptyWidget: _CalendarGrid(
                      activities: const [],
                      currentDate: currentDate,
                      isLoading: isLoading,
                    ),
                    errorWidget: const Center(
                      child: Text('Erro ao carregar atividades.'),
                    ),
                    builder: (activities) {
                      return _CalendarGrid(
                        activities: activities,
                        currentDate: currentDate,
                        isLoading: isLoading,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.activities,
    required this.currentDate,
    required this.isLoading,
  });

  final List<CheckInModel> activities;
  final DateTime currentDate;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(
      currentDate.year,
      currentDate.month + 1,
      0,
    ).day;
    final firstDayOfWeek = DateTime(
      currentDate.year,
      currentDate.month,
      1,
    ).weekday;

    // Ajuste para semana começando no domingo (Flutter é 1=Segunda, 7=Domingo)
    final offset = firstDayOfWeek % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.colorScheme.outlineVariant.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SizedBox(
                height: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.orange,
                    ),
                  ),
                ),
              ),
            )
          else
            const SizedBox(height: 16), // Maintains layout when not loading
          _buildWeekDays(context),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: daysInMonth + offset,
            itemBuilder: (context, index) {
              if (index < offset) return const SizedBox.shrink();

              final day = index - offset + 1;
              final dateStr = DateFormat(
                'yyyy-MM-dd',
              ).format(DateTime(currentDate.year, currentDate.month, day));

              final hasActivity = activities.any((c) => c.date == dateStr);
              final isToday =
                  DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateStr;

              return _CalendarDay(
                day: day,
                hasActivity: hasActivity,
                isToday: isToday,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDays(BuildContext context) {
    final weekDays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays
          .map(
            (d) => Text(
              d,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant.withOpacity(0.5),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarSkeleton extends StatelessWidget {
  const _CalendarSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.colorScheme.surfaceVariant.withOpacity(0.5),
      highlightColor: context.colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: context.colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 15), // Same height as progress bar spacer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                7,
                (i) => Container(
                  width: 20,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: 35,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.hasActivity,
    required this.isToday,
  });

  final int day;
  final bool hasActivity;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final orangeColor = Colors.orange.shade700;

    return Container(
      decoration: BoxDecoration(
        color: hasActivity
            ? orangeColor.withOpacity(0.1)
            : isToday
            ? context.colorScheme.surfaceVariant
            : null,
        borderRadius: BorderRadius.circular(12),
        border: hasActivity
            ? Border.all(color: orangeColor.withOpacity(0.3), width: 1.5)
            : isToday
            ? Border.all(color: context.colorScheme.primary, width: 1.5)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.toString(),
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: hasActivity ? orangeColor : null,
              ),
            ),
            if (hasActivity) const Text('🔥', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;

    return Opacity(
      opacity: isDisabled ? 0.3 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          visualDensity: VisualDensity.compact,
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
