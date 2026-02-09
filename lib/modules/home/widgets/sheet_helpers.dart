import 'package:flutter/material.dart';

import '../home.dart';

void showCreateGroupSheet(BuildContext context, HomeController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => CreateGroupSheet(controller: controller),
  );
}

void showJoinGroupSheet(BuildContext context, HomeController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => JoinGroupSheet(controller: controller),
  );
}
