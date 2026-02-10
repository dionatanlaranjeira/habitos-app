import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../habit_selection/models/habit_model.dart';
import '../controllers/controllers.dart';
import '../models/models.dart';
import 'checkin_photo_viewer.dart';
import 'checkin_form_sheet.dart';

class HabitCheckinTile extends StatelessWidget {
  final HabitModel habit;
  final GroupController controller;

  const HabitCheckinTile({
    super.key,
    required this.habit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = controller.isHabitCheckedIn(habit.id);
    final checkIn = controller.getCheckInForHabit(habit.id);
    final pendingPhoto = controller.pendingPhotos.value[habit.id];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCompleted
            ? theme.colorScheme.primary.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isCompleted
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            habit.iconData,
            color: isCompleted
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            size: 22,
          ),
        ),
        title: Text(
          habit.name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: isCompleted
            ? Text(
                'Confira seu check-in',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              )
            : Text(
                'Pendente',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
        trailing: _buildTrailing(context, isCompleted, checkIn, pendingPhoto),
        onTap: isCompleted
            ? () => _showPhotoViewer(context, checkIn!.photoUrl)
            : () => _openCheckinForm(context),
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    bool isCompleted,
    CheckInModel? checkIn,
    File? pendingPhoto,
  ) {
    final theme = Theme.of(context);

    if (isCompleted && checkIn != null) {
      // Mostrar miniatura da foto
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTap: () => _showPhotoViewer(context, checkIn.photoUrl),
          child: Image.network(
            checkIn.photoUrl,
            width: 48,
            height: 48,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                LucideIcons.check,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      );
    }

    if (!controller.isToday) {
      return const SizedBox.shrink();
    }

    if (pendingPhoto != null) {
      // Foto capturada, mostrar preview
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          pendingPhoto,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
        ),
      );
    }

    // Botão de câmera/mais
    return Icon(
      LucideIcons.camera,
      size: 20,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
    );
  }

  void _openCheckinForm(BuildContext context) {
    if (!controller.isToday) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (_) => CheckinFormSheet(
        habitId: habit.id,
        habitName: habit.name,
        controller: controller,
      ),
    );
  }

  void _showPhotoViewer(BuildContext context, String photoUrl) {
    showDialog(
      context: context,
      builder: (_) => CheckinPhotoViewer(photoUrl: photoUrl),
    );
  }
}
