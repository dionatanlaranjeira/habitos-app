import 'package:flutter/material.dart';

import '../core/core.dart';
import 'app_widget.dart';

/// Executa [ApplicationConfig.configureApp] antes de exibir o app.
/// Evita bloquear a inicialização no main. Usa FutureBuilder (sem setState).
class AppBootstrap extends StatelessWidget {
  const AppBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: ApplicationConfig().configureApp(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          Log.error('Falha ao configurar o app',
              error: snapshot.error, stackTrace: snapshot.stackTrace);
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Erro ao inicializar: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        return const AppWidget();
      },
    );
  }
}
