import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../../shared/shared.dart';
import '../home.dart';

class JoinGroupSheet extends StatefulWidget {
  const JoinGroupSheet({super.key, required this.controller});

  final HomeController controller;

  @override
  State<JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends State<JoinGroupSheet> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Entrar em um grupo',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Digite ou cole o código do grupo que deseja entrar.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            DefaultInputField(
              controller: widget.controller.groupCodeController,
              label: 'Código do grupo',
              hint: 'Ex: ABC123',
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o código do grupo';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            Watch((_) {
              final isLoading =
                  widget.controller.joinGroupSignal.value.isLoading;
              return FilledButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState?.validate() ?? false) {
                          widget.controller.joinGroup().then((_) {
                            if (context.mounted) Navigator.of(context).pop();
                          });
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Entrar'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
