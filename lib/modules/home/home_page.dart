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
    final groupStore = context.watch<GroupStore>();
    final controller = context.read<HomeController>();

    return Scaffold(
      drawer: const HomeDrawer(),
      floatingActionButton: Watch((_) {
        if (!groupStore.hasGroups) return const SizedBox.shrink();
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
                child: SignalFutureBuilder<List<GroupModel>>(
                  asyncState: groupStore.groupsAS.value,
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(),
                  ),
                  emptyWidget: HomeEmptyState(controller: controller),
                  onRetry: groupStore.refresh,
                  builder: (groups) => GroupList(groups: groups),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
