import 'package:flutter/material.dart';
import '../models/models.dart';

class RankingTile extends StatelessWidget {
  final WeeklyRankingEntryModel entry;
  final bool highlighted;
  final String? displayNameOverride;
  final String? photoUrlOverride;

  const RankingTile({
    super.key,
    required this.entry,
    required this.highlighted,
    this.displayNameOverride,
    this.photoUrlOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: highlighted
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.25)
              : theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${entry.position}º',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage:
                photoUrlOverride != null && photoUrlOverride!.isNotEmpty
                ? NetworkImage(photoUrlOverride!)
                : null,
            child: photoUrlOverride == null || photoUrlOverride!.isEmpty
                ? Text(
                    (displayNameOverride ?? entry.displayName).isNotEmpty
                        ? (displayNameOverride ?? entry.displayName)[0]
                              .toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _resolveRankingName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dias ativos: ${entry.seasonActiveDays} • Dias zerados: ${entry.seasonZeroDays}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.points} pts',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '${entry.weeklyActiveDays} dias na semana',
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _resolveRankingName() {
    if (displayNameOverride != null && displayNameOverride!.trim().isNotEmpty) {
      return displayNameOverride!;
    }

    if (entry.displayName.trim().isNotEmpty && entry.displayName != 'Usuário') {
      return entry.displayName;
    }

    final uid = entry.userId;
    final suffix = uid.length >= 6 ? uid.substring(0, 6) : uid;
    return 'Membro $suffix';
  }
}
