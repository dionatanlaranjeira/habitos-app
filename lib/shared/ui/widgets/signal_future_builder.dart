import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

import '../../shared.dart';

class SignalFutureBuilder<D> extends StatelessWidget {
  final AsyncState<D> asyncState;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final VoidCallback? onRetry;
  final Function(D data) builder;

  const SignalFutureBuilder({
    super.key,
    this.onRetry,
    required this.asyncState,
    required this.builder,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (asyncState.isLoading) {
          return loadingWidget ?? CircularProgressIndicator();
        }
        if (asyncState.hasError) {
          return errorWidget ??
              ErrorBuilder(error: asyncState.error, onRetry: onRetry);
        }
        if (asyncState.hasValue) {
          final value = asyncState.value;
          if (value is List && value.isEmpty) {
            return emptyWidget ?? const Text("Nenhum dado encontrado");
          }
          return builder(value as D);
        }
        return errorWidget ??
            ErrorBuilder(error: asyncState.error, onRetry: onRetry);
      },
    );
  }
}
