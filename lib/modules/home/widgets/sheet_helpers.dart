import 'package:flutter/material.dart';

import '../home.dart';

void showJoinGroupSheet(BuildContext context, HomeController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    builder: (_) => JoinGroupSheet(controller: controller),
  );
}
