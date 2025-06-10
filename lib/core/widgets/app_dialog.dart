import 'package:flutter/material.dart';
import '../constants/color_constants.dart';
import '../constants/app_constants.dart';

/// Uygulama genelinde kullanılan dialog widget'ı.
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;
  final bool isDismissible;
  final VoidCallback? onDismiss;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.actions,
    this.isDismissible = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isDismissible,
      child: AlertDialog(
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content:
            content ??
            (message != null
                ? Text(message!, style: Theme.of(context).textTheme.bodyMedium)
                : null),
        actions:
            actions ??
            [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (onDismiss != null) onDismiss!();
                },
                child: const Text(AppConstants.cancelButton),
              ),
            ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.mediumRadius),
        ),
        backgroundColor: ColorConstants.dialogBackground,
        elevation: 4,
      ),
    );
  }

  /// Basit bir bilgi dialogu gösterir.
  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Tamam',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Onay dialogu gösterir ve kullanıcının cevabını döndürür.
  static Future<bool> showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Evet',
    String cancelText = 'Hayır',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Hata dialogu gösterir.
  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Tamam',
  }) async {
    return showDialog<void>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        message: message,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(foregroundColor: ColorConstants.error),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
