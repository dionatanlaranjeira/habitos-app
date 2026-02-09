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
    final authRepository = context.read<AuthRepository>();
    final userStore = context.read<UserStore>();
    final groupStore = context.read<GroupStore>();
    final controller = context.read<HomeController>();

    return Scaffold(
      body: SafeArea(
        child: Watch((_) {
          final user = userStore.user.value;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = groupStore.groups.value;
          final isLoadingGroups = groupStore.isLoading.value;

          return CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: context.colorScheme.primaryContainer,
                        backgroundImage: user.photoUrl != null
                            ? NetworkImage(user.photoUrl!)
                            : null,
                        child: user.photoUrl == null
                            ? Text(
                                user.name.isNotEmpty
                                    ? user.name[0].toUpperCase()
                                    : '?',
                                style: context.textTheme.titleLarge?.copyWith(
                                  color:
                                      context.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              user.name,
                              style: context.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await authRepository.signOut();
                        },
                        icon: Icon(
                          Icons.logout_rounded,
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        tooltip: 'Sair',
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              if (isLoadingGroups)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (groups.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(controller: controller),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList.separated(
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _GroupCard(group: group);
                    },
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: context.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum campeonato ainda',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crie ou entre em um grupo para\ncomeçar a competir!',
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 32),

          // Criar grupo
          FilledButton.icon(
            onPressed: () => _showCreateGroupSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Criar grupo'),
          ),
          const SizedBox(height: 12),

          // Entrar com código
          OutlinedButton.icon(
            onPressed: () => _showJoinGroupSheet(context),
            icon: const Icon(Icons.login_rounded),
            label: const Text('Entrar com código'),
          ),
        ],
      ),
    );
  }

  void _showCreateGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CreateGroupSheet(controller: controller),
    );
  }

  void _showJoinGroupSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => JoinGroupSheet(controller: controller),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: navegar para detalhes do grupo
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: context.colorScheme.primaryContainer,
                child: Text(
                  group.name.isNotEmpty
                      ? group.name[0].toUpperCase()
                      : '?',
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.memberIds.length} participante${group.memberIds.length != 1 ? 's' : ''}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
