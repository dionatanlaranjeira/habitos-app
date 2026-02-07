import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../shared.dart';

class ErrorBuilder extends StatelessWidget {
  final Object? error;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context)? unauthenticatedBuilder;
  final Widget Function(BuildContext context)? noConnectionBuilder;
  final Widget Function(BuildContext context)? genericErrorBuilder;

  const ErrorBuilder({
    super.key,
    this.error,
    this.onRetry,
    this.noConnectionBuilder,
    this.genericErrorBuilder,
    this.unauthenticatedBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (error is DioException) {
      final dioError = error as DioException;

      final isConnectionError =
          dioError.type == DioExceptionType.connectionError ||
          dioError.type == DioExceptionType.connectionTimeout ||
          dioError.error is SocketException;

      if (isConnectionError) {
        if (noConnectionBuilder != null) {
          return noConnectionBuilder!(context);
        }
        return _DefaultErrorWidget(
          onRetry: onRetry,
          icon: Icons.wifi_off,
          message: "Verifique sua conexão com a internet.",
          color: Theme.of(context).primaryColor,
        );
      }
    }

    // Para todos os outros erros (Dio ou não)
    if (genericErrorBuilder != null) {
      return genericErrorBuilder!(context);
    }

    return _DefaultErrorWidget(
      onRetry: onRetry,
      icon: Icons.error_outline,
      message: "Ocorreu um erro inesperado. Tente novamente mais tarde.",
      color: Theme.of(context).colorScheme.error,
    );
  }
}

/// Um widget interno para evitar repetição de código.
class _DefaultErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final IconData icon;
  final String message;
  final Color color;

  const _DefaultErrorWidget({
    required this.icon,
    required this.message,
    required this.color,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: color),
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          if (onRetry != null) ...[
            const Gap(16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: context.primaryColor, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text("Tentar Novamente"),
            ),
          ],
        ],
      ),
    );
  }
}
