import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals/signals_flutter.dart';
import '../../../shared/shared.dart';
import '../controllers/controllers.dart';

class StepStart extends StatelessWidget {
  final CreateGroupController controller;

  const StepStart({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quando a temporada começa?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Escolha se quer começar agora ou agendar uma data.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Opção: Agora
          Watch(
            (_) => _StartOptionTile(
              icon: Icons.flash_on_rounded,
              title: 'Iniciar agora',
              subtitle: 'O campeonato começa assim que o grupo for criado.',
              isSelected: controller.startImmediatelyS.value,
              onTap: () => controller.startImmediatelyS.value = true,
            ),
          ),
          const SizedBox(height: 12),

          // Opção: Agendar
          Watch(
            (_) => _StartOptionTile(
              icon: Icons.calendar_today_rounded,
              title: 'Agendar data',
              subtitle: 'Defina uma data futura para o início.',
              isSelected: !controller.startImmediatelyS.value,
              onTap: () => controller.startImmediatelyS.value = false,
            ),
          ),

          const SizedBox(height: 24),

          // Date Picker (apenas se agendado)
          Watch((_) {
            if (controller.startImmediatelyS.value) {
              return const SizedBox.shrink();
            }

            final selectedDate = controller.scheduledStartDateS.value;
            final dateText = selectedDate != null
                ? DateFormat('dd/MM/yyyy').format(selectedDate)
                : 'Selecionar data';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Data de Início',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final date = await showDatePicker(
                      context: context,
                      initialDate:
                          selectedDate ?? now.add(const Duration(days: 1)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      controller.scheduledStartDateS.value = date;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.event_rounded),
                        const SizedBox(width: 12),
                        Text(dateText),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _StartOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _StartOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSelected
            ? context.primaryColor.withValues(alpha: 0.1)
            : context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? context.primaryColor
              : context.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? context.primaryColor
                    : context.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? context.primaryColor : null,
                      ),
                    ),
                    Text(subtitle, style: context.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
