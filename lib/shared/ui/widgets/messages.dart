import 'package:flutter/material.dart';
import '../../../core/core.dart';
import '../../../shared/shared.dart';

class Messages {
  Messages._();

  static Widget _snackBar(String title, subtitle, String path, Color color) {
    return IntrinsicHeight(
      child: CustomSnackBar.snackBar(
        borderRadius: BorderRadius.circular(4),
        child: Material(
          color: currentContext.backgroundColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 16,
            children: [
              Container(width: 8, color: color.withValues(alpha: .2)),
              Image.asset(
                path,
                width: 20,
                height: 20,
                color: color.withValues(alpha: 0.7),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        title,
                        softWrap: true,
                        style: TextStyle(
                          color: color.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void error(String? message) {
    if (message == null) return;
    showTopSnackBar(
      displayDuration: Duration(seconds: 3),
      AppRouter.router.routerDelegate.navigatorKey.currentState!.overlay!,
      _snackBar(
        "Ops!",
        message,
        "assets/images/error.png",
        AppColors.i.errorColor,
      ),
    );
  }

  static void info(String? message) {
    if (message == null) return;
    showTopSnackBar(
      AppRouter.router.routerDelegate.navigatorKey.currentState!.overlay!,
      _snackBar(
        "Informativo",
        message,
        "assets/images/info.png",
        AppColors.i.infoColor,
      ),
    );
  }

  static void success(String? message) {
    if (message == null) return;
    showTopSnackBar(
      AppRouter.router.routerDelegate.navigatorKey.currentState!.overlay!,
      _snackBar(
        "Sucesso!",
        message,
        "assets/images/success.png",
        AppColors.i.successColor,
      ),
    );
  }
}
