import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:signals/signals_flutter.dart';

import '../controllers/controllers.dart';

class GroupInfoSheet extends StatelessWidget {
  const GroupInfoSheet({super.key, required this.controller});

  final GroupController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final group = controller.groupAS.watch(context).value;

    if (group == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle gauge
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    LucideIcons.users,
                    size: 32,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  group.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.gameMode.toUpperCase()} • ${group.seasonDuration} dias',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),

          // Invite Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONVITE',
                  style: theme.textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.code,
                          style: theme.textTheme.titleLarge?.copyWith(
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: group.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Código copiado!'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.copy, size: 20),
                        tooltip: 'Copiar código',
                      ),
                      IconButton(
                        onPressed: () {
                          Share.share(
                            'Entre no meu grupo no aplicativo de hábitos! \nCódigo: ${group.code}',
                          );
                        },
                        icon: const Icon(LucideIcons.share2, size: 20),
                        tooltip: 'Compartilhar',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Members Section
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'MEMBROS',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: Watch((context) {
                    final members =
                        controller.membersAS.watch(context).value ?? [];
                    final names =
                        controller.memberNamesAS.watch(context).value ?? {};
                    controller.ensureMemberNamesLoaded(
                      members.map((m) => m.userId).toList(),
                    );

                    return ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final name =
                            names[member.userId] ??
                            _fallbackMemberName(member.userId);
                        final isOwner = member.userId == group.ownerId;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: isOwner ? FontWeight.bold : null,
                            ),
                          ),
                          trailing: isOwner
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'ADMIN',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : null,
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          // Footer / Sair do Grupo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Watch((_) {
              final isLeaving = controller.groupActionAS.value.isLoading;
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isLeaving
                      ? null
                      : () async {
                          await _showLeaveGroupDialog(context, controller);
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: isLeaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.logOut, size: 18),
                  label: Text(isLeaving ? 'Saindo...' : 'Sair do Grupo'),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  static Future<void> show(BuildContext context, GroupController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GroupInfoSheet(controller: controller),
    );
  }

  String _fallbackMemberName(String userId) {
    final suffix = userId.length >= 6 ? userId.substring(0, 6) : userId;
    return 'Membro $suffix';
  }

  Future<void> _showLeaveGroupDialog(
    BuildContext context,
    GroupController controller,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Watch((_) {
          final isLeaving = controller.groupActionAS.value.isLoading;
          return AlertDialog(
            title: const Text('Sair do grupo'),
            content: const Text(
              'Você vai sair do grupo e seus check-ins serão removidos. Deseja continuar?',
            ),
            actions: [
              SizedBox(
                width: 110,
                child: TextButton(
                  onPressed: isLeaving
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
              ),
              SizedBox(
                width: 110,
                child: FilledButton(
                  onPressed: isLeaving
                      ? null
                      : () async {
                          await controller.leaveGroup();
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                  child: isLeaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sair'),
                ),
              ),
            ],
          );
        });
      },
    );
  }
}
