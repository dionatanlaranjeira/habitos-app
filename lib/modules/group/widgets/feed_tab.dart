import 'package:flutter/material.dart';
import '../controllers/controllers.dart';
import 'competition_feed.dart';
import 'group_header.dart';
import 'my_progress_section.dart';

class FeedTab extends StatelessWidget {
  final GroupController controller;

  const FeedTab({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GroupHeader(controller: controller),
            const SizedBox(height: 20),
            MyProgressSection(controller: controller),
            const SizedBox(height: 24),
            CompetitionFeed(controller: controller),
          ],
        ),
      ),
    );
  }
}
