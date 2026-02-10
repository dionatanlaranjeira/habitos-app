import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../controllers/group_controller.dart';
import '../models/models.dart';

class ReactionBar extends StatelessWidget {
  final CheckInModel checkIn;
  final GroupController controller;
  final bool isDense;

  const ReactionBar({
    super.key,
    required this.checkIn,
    required this.controller,
    this.isDense = false,
  });

  static const _emojis = ['🔥', '❤️', '💪', '👏', '😂'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDense ? 0 : 12, vertical: 8),
      child: Row(
        children: [
          ..._emojis.map((emoji) {
            final count = checkIn.reactionCounts[emoji] ?? 0;
            return _ReactionButton(
              emoji: emoji,
              count: count,
              onTap: () => controller.toggleReaction(checkIn.id, emoji),
              isDense: isDense,
            );
          }),
          // Botão para abrir o seletor
          _AddReactionButton(
            onTap: () => _showReactionPicker(context),
            isDense: isDense,
          ),
          const Spacer(),
          // Botão de Comentários
          _CommentButton(count: checkIn.commentCount, isDense: isDense),
        ],
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          height: MediaQuery.of(context).size.height * 0.45,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    controller.toggleReaction(checkIn.id, emoji.emoji);
                    Navigator.pop(context);
                  },
                  config: Config(
                    height: 256,
                    checkPlatformCompatibility: true,
                    viewOrderConfig: const ViewOrderConfig(),
                    emojiViewConfig: EmojiViewConfig(
                      backgroundColor: theme.colorScheme.surface,
                      columns: 7,
                      emojiSizeMax:
                          32 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.30
                              : 1.0),
                    ),
                    categoryViewConfig: CategoryViewConfig(
                      backgroundColor: theme.colorScheme.surface,
                      indicatorColor: theme.colorScheme.primary,
                      iconColorSelected: theme.colorScheme.primary,
                      backspaceColor: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddReactionButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDense;

  const _AddReactionButton({required this.onTap, required this.isDense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(
          LucideIcons.plus,
          size: isDense ? 14 : 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final int count;
  final VoidCallback onTap;
  final bool isDense;

  const _ReactionButton({
    required this.emoji,
    required this.count,
    required this.onTap,
    required this.isDense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isDense ? 6 : 8, vertical: 4),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: isDense ? 14 : 16)),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                count.toString(),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommentButton extends StatelessWidget {
  final int count;
  final bool isDense;

  const _CommentButton({required this.count, required this.isDense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(
            LucideIcons.messageSquare,
            size: isDense ? 16 : 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
