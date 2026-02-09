import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../../shared/shared.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';
import 'widgets.dart';

class StepSeason extends StatelessWidget {
  final CreateGroupController controller;

  const StepSeason({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quanto tempo dura a temporada?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Defina o período de competição do seu grupo.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SignalFutureBuilder<List<SeasonDurationModel>>(
            asyncState: controller.seasonDurationsAS.value,
            builder: (durations) {
              return Watch((_) {
                return Column(
                  children: durations
                      .map(
                        (d) => DurationCard(
                          duration: d,
                          isSelected:
                              controller.selectedDurationS.value?.id == d.id,
                          onTap: () => controller.selectedDurationS.value = d,
                        ),
                      )
                      .toList(),
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
