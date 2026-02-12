import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import '../../../global_modules/global_modules.dart';
import '../../../shared/shared.dart';
import '../../modules.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = context.read<UserStore>();
    final authRepository = context.read<AuthRepository>();
    final user = userStore.user.value;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Visual Header
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

            const Divider(height: 1),

            // Profile Tile
            ListTile(
              leading: const Icon(LucideIcons.user),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                context.push(ProfileModule.path);
              },
            ),

            const Spacer(),

            const Divider(height: 1),

            // Theme, Privacy and Terms Group
            SwitchListTile(
              secondary: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? LucideIcons.moon
                    : LucideIcons.sun,
              ),
              title: const Text('Tema Escuro'),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (bool value) {
                if (value) {
                  AdaptiveTheme.of(context).setDark();
                } else {
                  AdaptiveTheme.of(context).setLight();
                }
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.shieldCheck),
              title: const Text('Política de Privacidade'),
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Em breve')));
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.fileText),
              title: const Text('Termos de Uso'),
              onTap: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Em breve')));
              },
            ),

            const Divider(height: 1),

            // Logout separate at the very bottom
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

            // Version Label
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _AppVersionLabel(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppVersionLabel extends StatelessWidget {
  const _AppVersionLabel();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '...';
        final buildNumber = snapshot.data?.buildNumber ?? '';
        final display = buildNumber.isNotEmpty
            ? 'v$version+$buildNumber'
            : 'v$version';

        return Text(
          display,
          style: context.textTheme.labelSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
