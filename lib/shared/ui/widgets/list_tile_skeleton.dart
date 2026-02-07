import 'package:flutter/material.dart';

import 'default_shimmer.dart';

class ListTileSkeleton extends StatelessWidget {
  final int length;
  final double spacing;
  final double height;
  const ListTileSkeleton({
    super.key,
    this.length = 3,
    this.spacing = 16,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultShimmer(
      child: Column(
        children: List.generate(
          length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
