import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals/signals_flutter.dart';
import '../../shared/shared.dart';
import 'controllers/controllers.dart';
import 'widgets/widgets.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final PageController _pageController = PageController();
  EffectCleanup? _effectCleanup;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_effectCleanup == null) {
      final controller = context.read<CreateGroupController>();
      _effectCleanup = effect(() {
        final step = controller.currentStep.value;
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            step,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _effectCleanup?.call();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<CreateGroupController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Novo Grupo'), centerTitle: true),
      body: Column(
        children: [
          // Stepper Progress
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Watch(
              (_) => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isActive = controller.currentStep.value >= index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: controller.currentStep.value == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? context.primaryColor
                          : context.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                StepIdentity(controller: controller),
                StepSeason(controller: controller),
                StepMode(controller: controller),
                StepStart(controller: controller),
              ],
            ),
          ),

          // Bottom Navigation
          Padding(
            padding: const EdgeInsets.all(24),
            child: Watch((_) {
              final step = controller.currentStep.value;
              final isLoading = controller.createGroupSignal.value.isLoading;

              return Row(
                children: [
                  if (step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : controller.previousStep,
                        child: const Text('Voltar'),
                      ),
                    ),
                  if (step > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: isLoading
                          ? null
                          : (step < 3
                                ? controller.nextStep
                                : controller.createGroup),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(step < 3 ? 'Próximo' : 'Criar Grupo 🚀'),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
