import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DefaultShimmer extends StatelessWidget {
  final Widget child;

  const DefaultShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AdaptiveTheme.of(context).mode.isDark
          ? Colors.grey.shade900
          : Colors.grey.shade300,
      highlightColor: AdaptiveTheme.of(context).mode.isDark
          ? Colors.grey.shade600
          : Colors.grey.shade100,
      enabled: true,
      child: child,
    );
  }
}
