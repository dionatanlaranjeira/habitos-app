import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

import '../../../shared/shared.dart';
import '../controllers/controllers.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.controller,
    required this.currentPhotoUrl,
    required this.initials,
  });

  final ProfileController controller;
  final String? currentPhotoUrl;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Watch((_) {
            final file = controller.avatarFile.value;

            return Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colorScheme.primaryContainer,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: file != null
                    ? DecorationImage(
                        image: FileImage(File(file.path)),
                        fit: BoxFit.cover,
                      )
                    : (currentPhotoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(currentPhotoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null),
              ),
              child: file == null && currentPhotoUrl == null
                  ? Center(
                      child: Text(
                        initials,
                        style: context.textTheme.displaySmall?.copyWith(
                          color: context.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : null,
            );
          }),
          Positioned(
            bottom: 0,
            right: 0,
            child: Material(
              color: context.colorScheme.primary,
              shape: const CircleBorder(),
              elevation: 4,
              child: IconButton(
                onPressed: () => _showPicker(context),
                icon: const Icon(
                  LucideIcons.camera,
                  color: Colors.white,
                  size: 20,
                ),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Câmera'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Galeria'),
              onTap: () {
                Navigator.pop(context);
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
