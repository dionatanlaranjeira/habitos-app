import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

import '../../global_modules/global_modules.dart';
import '../../shared/shared.dart';
import 'home.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = context.watch<UserStore>();
    final controller = context.read<HomeController>();

    return Scaffold(
      drawer: const HomeDrawer(),
      floatingActionButton: Watch((_) {
        final state = controller.groupsAS.value;
        final hasGroups = state.hasValue && (state.value?.isNotEmpty ?? false);

        if (!hasGroups) return const SizedBox.shrink();
        return HomeFab(controller: controller);
      }),
      body: Watch((_) {
        final user = userStore.user.value;

        if (user == null) {
          return const HomeSkeleton();
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              leading: Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              ),
              title: const Text(
                'Meus Hábitos',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
            ),
            HomeDashboard(controller: controller),
            Watch((context) {
              return SignalFutureBuilder<List<GroupModel>>(
                asyncState: controller.groupsAS.watch(context),
                loadingWidget: SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: GroupSkeleton(),
                      ),
                      childCount: 3,
                    ),
                  ),
                ),
                errorWidget: SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Erro ao carregar grupos'),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: controller.fetchGroups,
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
                builder: (groups) {
                  if (groups.isEmpty) {
                    return SliverToBoxAdapter(
                      child: HomeEmptyState(controller: controller),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Seus grupos',
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        }
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GroupCard(group: groups[index - 1]),
                        );
                      }, childCount: groups.length + 1),
                    ),
                  );
                },
              );
            }),
          ],
        );
      }),
    );
  }
}
