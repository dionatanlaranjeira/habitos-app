import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../global_modules/global_modules.dart';
import '../../../shared/shared.dart';
import '../home.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = context.read<UserStore>();
    final authRepository = context.read<AuthRepository>();
    final controller = context.read<HomeController>();
    final user = userStore.user.value;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: context.colorScheme.primaryContainer,
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? Text(
                            user != null && user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: context.textTheme.titleLarge?.copyWith(
                              color: context.colorScheme.onPrimaryContainer,
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
                          user?.name ?? '',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          user?.email ?? '',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Opções
            ListTile(
              leading: const Icon(Icons.add_rounded),
              title: const Text('Criar grupo'),
              onTap: () {
                Navigator.of(context).pop();
                showCreateGroupSheet(context, controller);
              },
            ),
            ListTile(
              leading: const Icon(Icons.login_rounded),
              title: const Text('Entrar com código'),
              onTap: () {
                Navigator.of(context).pop();
                showJoinGroupSheet(context, controller);
              },
            ),

            const Spacer(),

            const Divider(),

            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: context.colorScheme.error,
              ),
              title: Text(
                'Sair',
                style: TextStyle(color: context.colorScheme.error),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                await authRepository.signOut();
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
