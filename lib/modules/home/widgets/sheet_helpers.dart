import 'package:flutter/material.dart';

import '../home.dart';

void showCreateGroupSheet(BuildContext context, HomeController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    builder: (_) => CreateGroupSheet(controller: controller),
  );
}

void showJoinGroupSheet(BuildContext context, HomeController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    builder: (_) => JoinGroupSheet(controller: controller),
  );
}
