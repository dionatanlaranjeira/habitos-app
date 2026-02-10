import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

import '../../../shared/shared.dart';
import '../controllers/controllers.dart';

class CheckinFormSheet extends StatefulWidget {
  final String habitId;
  final String habitName;
  final GroupController controller;

  const CheckinFormSheet({
    super.key,
    required this.habitId,
    required this.habitName,
    required this.controller,
  });

  @override
  State<CheckinFormSheet> createState() => _CheckinFormSheetState();
}

class _CheckinFormSheetState extends State<CheckinFormSheet> {
  final _descriptionController = TextEditingController();
  File? _selectedPhoto;

  @override
  void initState() {
    super.initState();
    // Recuperar dados pendentes se houver
    _selectedPhoto = widget.controller.pendingPhotos.value[widget.habitId];
    _descriptionController.text =
        widget.controller.pendingDescriptions.value[widget.habitId] ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );

    if (picked != null) {
      setState(() {
        _selectedPhoto = File(picked.path);
      });
      widget.controller.setPhotoForHabit(widget.habitId, _selectedPhoto!);
    }
  }

  Future<void> _submit() async {
    if (_selectedPhoto == null) {
      return;
    }

    widget.controller.setDescriptionForHabit(
      widget.habitId,
      _descriptionController.text,
    );

    await widget.controller.submitCheckIn(
      widget.habitId,
      description: _descriptionController.text,
    );

    if (mounted && !widget.controller.submitCheckInAS.value.hasError) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Título
              Text(
                widget.habitName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Compromisso diário',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Área da Foto
              GestureDetector(
                onTap: () => _showPhotoOptions(),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: _selectedPhoto == null
                        ? Border.all(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            style: BorderStyle.solid,
                          )
                        : null,
                  ),
                  child: _selectedPhoto != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedPhoto!,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(
                                    LucideIcons.camera,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: _showPhotoOptions,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.camera,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Toque para tirar uma foto',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Descrição
              DefaultInputField(
                controller: _descriptionController,
                label: 'Descrição (opcional)',
                hint: 'Como foi realizar este hábito hoje?',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Botão Enviar
              Watch((context) {
                final isSubmitting = widget.controller.submitCheckInAS
                    .watch(context)
                    .isLoading;

                return FilledButton(
                  onPressed: _selectedPhoto != null && !isSubmitting
                      ? _submit
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Enviar Check-in',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(LucideIcons.camera),
                  title: const Text('Câmera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(LucideIcons.image),
                  title: const Text('Galeria'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
