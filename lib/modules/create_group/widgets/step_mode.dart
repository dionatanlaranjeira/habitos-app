import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../../../shared/shared.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';
import 'widgets.dart';

class StepMode extends StatelessWidget {
  final CreateGroupController controller;

  const StepMode({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Qual o modo de jogo?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escolha como os pontos serão contabilizados.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SignalFutureBuilder<List<GameModeModel>>(
            asyncState: controller.gameModesAS.value,
            builder: (modes) {
              return Watch((_) {
                return Column(
                  children: modes
                      .map(
                        (m) => ModeCard(
                          mode: m,
                          isSelected:
                              controller.selectedModeS.value?.id == m.id,
                          onTap: () => controller.selectedModeS.value = m,
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
