import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

import '../../global_modules/global_modules.dart'; // For UserStore
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
      body: SafeArea(
        child: Watch((_) {
          final user = userStore.user.value;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              HomeHeader(user: user),
              Expanded(
                child: Watch((_) {
                  final state = controller.groupsAS.value;

                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.hasError) {
                    return Center(
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
                    );
                  }

                  final groups = state.value ?? [];
                  if (groups.isEmpty) {
                    return HomeEmptyState(controller: controller);
                  }

                  return GroupList(groups: groups);
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}
