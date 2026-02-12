import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';

import '../../global_modules/global_modules.dart';
import '../../shared/shared.dart';
import 'controllers/controllers.dart';
import 'widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileController>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ProfileController>();
    final userStore = context.watch<UserStore>();
    final user = userStore.user.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileAvatar(
              controller: controller,
              currentPhotoUrl: user?.photoUrl,
              initials: user != null && user.name.isNotEmpty
                  ? user.name[0].toUpperCase()
                  : '?',
            ),
            const SizedBox(height: 32),
            Text(
              'Informações Pessoais',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest.withOpacity(
                  0.3,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: InputBorder.none,
                        prefixIcon: Icon(LucideIcons.user),
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(LucideIcons.mail),
                    title: const Text('Email'),
                    subtitle: Text(user?.email ?? ''),
                    enabled: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SignalFutureBuilder<void>(
              asyncState: controller.saveStatus.watch(context),
              loadingWidget: FilledButton(
                onPressed: null,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
              builder: (_) => FilledButton(
                onPressed: () => _handleSave(context, controller),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Salvar Alterações',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave(
    BuildContext context,
    ProfileController controller,
  ) async {
    await controller.save();

    if (mounted && !controller.saveStatus.value.hasError) {
      Messages.success('Perfil atualizado com sucesso!');
      Navigator.of(context).pop();
    }
  }
}
