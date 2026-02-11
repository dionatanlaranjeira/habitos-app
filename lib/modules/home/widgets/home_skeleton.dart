import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/shared.dart';
import 'group_skeleton.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            leading: const Icon(Icons.menu_rounded),
            title: const Text(
              'Meus Hábitos',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            centerTitle: true,
          ),
          // Activity Calendar Skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Shimmer.fromColors(
                baseColor: context.colorScheme.surfaceVariant,
                highlightColor: context.colorScheme.surface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Groups Title Skeleton
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Shimmer.fromColors(
                baseColor: context.colorScheme.surfaceVariant,
                highlightColor: context.colorScheme.surface,
                child: Container(
                  width: 100,
                  height: 16,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          // Group List Skeleton
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: GroupSkeleton(),
                ),
                childCount: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
