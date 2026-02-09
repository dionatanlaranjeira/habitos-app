import 'package:flutter/material.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Por enquanto, vamos pegar o ID da rota ou argumentos
    // Mas o controller já deve estar provido pelo Module

    // final controller = context.watch<GroupController>(); // Se usarmos provider

    // Placeholder UI
    return Scaffold(
      appBar: AppBar(title: const Text('Grupo')),
      body: const Center(child: Text('Bem-vindo ao Grupo!')),
    );
  }
}
