import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:keyboard_emoji_picker/keyboard_emoji_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:signals_flutter/signals_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final myEmoji = controller.myReactionsByCheckIn.watch(
        context,
      )[checkIn.id];

      final activeReactions = checkIn.reactionCounts.entries
          .where((e) => e.value > 0)
          .toList();

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isDense ? 0 : 12,
          vertical: 8,
        ),
        child: Row(
          children: [
            if (activeReactions.isEmpty)
              _ZeroStateReactionButton(
                onTap: () => _showReactionPicker(context),
                isDense: isDense,
              )
            else ...[
              ...activeReactions.map(
                (entry) => _ReactionButton(
                  emoji: entry.key,
                  count: entry.value,
                  isMyReaction: entry.key == myEmoji,
                  onTap: () => controller.toggleReaction(checkIn.id, entry.key),
                  isDense: isDense,
                ),
              ),
              _AddReactionButton(
                onTap: () => _showReactionPicker(context),
                isDense: isDense,
              ),
            ],
            const Spacer(),
            _CommentButton(count: checkIn.commentCount, isDense: isDense),
          ],
        ),
      );
    });
  }

  Future<void> _showReactionPicker(BuildContext context) async {
    if (Platform.isIOS) {
      final hasKeyboard = await KeyboardEmojiPicker().checkHasEmojiKeyboard();
      if (hasKeyboard) {
        final emoji = await KeyboardEmojiPicker().pickEmoji();
        if (emoji != null) {
          controller.toggleReaction(checkIn.id, emoji);
        }
        return;
      }
    }

    if (!context.mounted) return;
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

class _ZeroStateReactionButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDense;

  const _ZeroStateReactionButton({required this.onTap, required this.isDense});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Icon(
          LucideIcons.smilePlus,
          size: isDense ? 18 : 20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
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
          LucideIcons.smilePlus,
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
  final bool isMyReaction;
  final VoidCallback onTap;
  final bool isDense;

  const _ReactionButton({
    required this.emoji,
    required this.count,
    required this.isMyReaction,
    required this.onTap,
    required this.isDense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDense ? 6 : 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: isMyReaction
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isMyReaction
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.5),
                    width: 1.5,
                  )
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: TextStyle(fontSize: isDense ? 14 : 16)),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Text(
                  count.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isMyReaction
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
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
