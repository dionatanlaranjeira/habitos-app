import 'package:flutter/material.dart';

import '../core/core.dart';
import '../shared/shared.dart';
import 'app_widget.dart';

/// Executa [ApplicationConfig.configureApp] antes de exibir o app.
/// Evita bloquear a inicialização no main. Usa FutureBuilder (sem setState).
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.i.primaryColor;

    return FutureBuilder<void>(
      future: ApplicationConfig().configureApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Log.error(
            'Falha ao configurar o app',
            error: snapshot.error,
            stackTrace: snapshot.stackTrace,
          );
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: primaryColor,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icon/launch_icon_foreground.png',
                        width: 120,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Erro ao inicializar:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: primaryColor,
              body: Center(
                child: Image.asset(
                  'assets/icon/launch_icon_foreground.png',
                  width: 120,
                ),
              ),
            ),
          );
        }
        return const AppWidget();
      },
    );
  }
}
