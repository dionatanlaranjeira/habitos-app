import 'package:flutter/material.dart';
import '../../../../shared/shared.dart';
import '../models/models.dart';
import 'group_card.dart';

class GroupList extends StatelessWidget {
  const GroupList({super.key, required this.groups});

  final List<GroupModel> groups;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
      itemCount: groups.length + 1, // +1 para o título
      separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 8 : 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            'Seus grupos',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          );
        }
        return GroupCard(group: groups[index - 1]);
      },
    );
  }
}
