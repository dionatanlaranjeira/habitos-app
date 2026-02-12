import 'package:flutter/material.dart';
import 'package:provider/provider.dart' hide ErrorBuilder;
import 'package:signals/signals_flutter.dart';

import '../home/models/models.dart';
import '../../shared/shared.dart';
import 'controllers/controllers.dart';
import 'widgets/widgets.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<GroupController>();
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: Watch((context) {
            final group = controller.groupAS.watch(context).value;
            return Text(group?.name ?? '');
          }),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => GroupInfoSheet.show(context, controller),
              icon: const Icon(Icons.menu),
              tooltip: 'Informações do Grupo',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Feed'),
              Tab(text: 'Ranking'),
            ],
          ),
        ),
        body: SignalFutureBuilder<GroupModel?>(
          asyncState: controller.groupAS.watch(context),
          onRetry: controller.refresh,
          loadingWidget: const GroupSkeleton(),
          builder: (group) {
            if (group == null) {
              return const Center(child: Text('Grupo não encontrado'));
            }

            return TabBarView(
              children: [
                FeedTab(controller: controller),
                RankingTab(controller: controller),
              ],
            );
          },
        ),
      ),
    );
  }
}
