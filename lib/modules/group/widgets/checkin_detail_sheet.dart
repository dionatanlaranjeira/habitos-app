import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals/signals_flutter.dart';

import '../../../shared/shared.dart';
import '../models/models.dart';
import '../controllers/group_controller.dart';
import 'reaction_bar.dart';

class CheckinDetailSheet extends StatefulWidget {
  final String checkinId;
  final GroupController controller;
  final String memberName;
  final String habitName;
  final IconData habitIcon;

  const CheckinDetailSheet({
    super.key,
    required this.checkinId,
    required this.controller,
    required this.memberName,
    required this.habitName,
    required this.habitIcon,
  });

  @override
  State<CheckinDetailSheet> createState() => _CheckinDetailSheetState();
}

class _CheckinDetailSheetState extends State<CheckinDetailSheet> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.controller.loadComments(widget.checkinId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    await widget.controller.addComment(widget.checkinId, text);
    if (!mounted) return;
    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Watch((context) {
      final allCheckIns =
          widget.controller.allCheckInsAS.watch(context).value ?? [];
      final checkIn = allCheckIns.firstWhere(
        (c) => c.id == widget.checkinId,
        orElse: () => CheckInModel(
          id: '',
          userId: '',
          habitId: '',
          date: '',
          photoUrl: '',
          completedAt: DateTime.now(),
          description: '',
          points: 0,
        ),
      );

      if (checkIn.id.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(child: Text('Check-in não encontrado')),
        );
      }

      final names = widget.controller.memberNamesAS.watch(context).value ?? {};
      final memberName = names[checkIn.userId] ?? widget.memberName;
      final timeStr = DateFormat('HH:mm').format(checkIn.completedAt);
      final isMyCheckin = checkIn.userId == widget.controller.userStore.uid;

      return Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    child: Text(
                      memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          memberName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'às $timeStr • ${widget.habitName}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMyCheckin)
                        IconButton(
                          tooltip: 'Excluir check-in',
                          onPressed: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Excluir check-in'),
                                content: const Text(
                                  'Essa ação remove o check-in, comentários, reações e a mídia. Deseja continuar?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('Excluir'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldDelete != true) return;
                            await widget.controller.deleteCheckIn(checkIn.id);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(LucideIcons.trash2),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(LucideIcons.x),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content Scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Foto
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          checkIn.photoUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    if (checkIn.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        checkIn.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Barra de Reações Reutilizada
                    ReactionBar(
                      checkIn: checkIn,
                      controller: widget.controller,
                      isDense: false,
                    ),

                    const Divider(),

                    // Lista de Comentários
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Comentários',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SignalFutureBuilder<List<CommentModel>>(
                      asyncState: widget.controller.checkinCommentsAS.value,
                      emptyWidget: SizedBox.shrink(),
                      errorWidget: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text('Erro ao carregar comentários.'),
                        ),
                      ),
                      loadingWidget: _buildCommentsShimmer(),
                      builder: (comments) {
                        if (comments.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Text(
                                'Nenhum comentário ainda. Seja o primeiro!',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: comments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final comment = comments[index];
                            return _CommentTile(
                              comment: comment,
                              memberName:
                                  widget
                                      .controller
                                      .memberNamesAS
                                      .value
                                      .value?[comment.userId] ??
                                  'Usuário',
                              isOwner:
                                  comment.userId ==
                                  widget.controller.userStore.uid,
                              onDelete: () => widget.controller.deleteComment(
                                checkIn.id,
                                comment.id,
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Input de Comentário
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Escreva um comentário...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _submitComment,
                    icon: const Icon(LucideIcons.sendHorizontal, size: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCommentsShimmer() {
    return Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DefaultShimmer(
                child: CircleAvatar(radius: 14, backgroundColor: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DefaultShimmer(
                      child: Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    DefaultShimmer(
                      child: Container(
                        width: double.infinity,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final String memberName;
  final bool isOwner;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.memberName,
    required this.isOwner,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm').format(comment.createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Text(
            memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    memberName,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeStr,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              GestureDetector(
                onLongPress: isOwner ? () => _showDeleteDialog(context) : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(comment.text, style: theme.textTheme.bodyMedium),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar comentário?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
