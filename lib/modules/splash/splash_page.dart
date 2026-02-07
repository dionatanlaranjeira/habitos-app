import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import 'splash.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SplashController>();
    return Scaffold(body: Center(child: Text('Splash Page')));
  }
}
