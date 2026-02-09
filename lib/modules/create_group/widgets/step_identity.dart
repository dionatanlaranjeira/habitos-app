import 'package:flutter/material.dart';
import '../controllers/controllers.dart';

class StepIdentity extends StatelessWidget {
  final CreateGroupController controller;

  const StepIdentity({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: controller.validator.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Como se chama seu grupo?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escolha um nome que represente a união de vocês.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: controller.groupNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Grupo',
                hintText: 'Ex: Os Imparáveis',
                border: OutlineInputBorder(),
              ),
              validator: (v) => controller.validator.validate('name', v),
            ),
          ],
        ),
      ),
    );
  }
}
