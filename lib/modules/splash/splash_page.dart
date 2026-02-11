import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../shared/shared.dart';
import 'splash.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<SplashController>();

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emoji_events_rounded,
              size: 72,
              color: context.primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Habitus',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Campeonato de hábitos',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            LoadingAnimationWidget.staggeredDotsWave(
              color: context.primaryColor,
              size: 40,
            ),
          ],
        ),
      ),
    );
  }
}
