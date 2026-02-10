import 'package:flutter/material.dart';

import '../home.dart';

class HomeFab extends StatelessWidget {
  const HomeFab({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showOptionsSheet(context),
      child: const Icon(Icons.add_rounded),
    );
  }

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      isScrollControlled: true,
      builder: (_) => FabOptionsSheet(controller: controller),
    );
  }
}
