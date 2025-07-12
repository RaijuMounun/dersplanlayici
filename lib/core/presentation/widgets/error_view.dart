import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/error/app_exception.dart';

/// Hata ekranı widget'ı
class ErrorView extends StatelessWidget {

  /// Hata durumundan oluşturulan bir ErrorView
  const ErrorView({
    super.key,
    required this.message,
    this.details,
    this.onRetry,
    this.onBack,
    this.icon,
  });

  /// AppException'dan bir ErrorView oluşturur
  factory ErrorView.fromException(
    AppException exception, {
    Key? key,
    VoidCallback? onRetry,
    VoidCallback? onBack,
  }) => ErrorView(
      key: key,
      message: exception.message,
      details: exception.details?.toString(),
      onRetry: onRetry,
      onBack: onBack,
      icon: _getIconForException(exception),
    );
  /// Görüntülenecek hata mesajı
  final String message;

  /// Hata detayları (isteğe bağlı)
  final String? details;

  /// Tekrar deneme butonu için callback (isteğe bağlı)
  final VoidCallback? onRetry;

  /// Geri dönme butonu için callback (isteğe bağlı)
  final VoidCallback? onBack;

  /// Özel bir icon (isteğe bağlı)
  final IconData? icon;

  /// Exception tipine göre uygun bir icon seçer
  static IconData _getIconForException(AppException exception) {
    if (exception is ValidationException) {
      return Icons.error_outline;
    } else if (exception is DatabaseException) {
      return Icons.storage_rounded;
    } else if (exception is NetworkException) {
      return Icons.wifi_off_rounded;
    } else if (exception is BusinessLogicException) {
      return Icons.warning_amber_rounded;
    } else if (exception is NotFoundException) {
      return Icons.search_off_rounded;
    } else {
      return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 72,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: 16),
              Text(
                details!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(179),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onBack != null)
                  OutlinedButton.icon(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Geri Dön'),
                  ),
                if (onBack != null && onRetry != null)
                  const SizedBox(width: 16),
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
}

/// Sayfa yüklenirken gösterilecek loading ekranı
class LoadingView extends StatelessWidget {

  const LoadingView({super.key, this.message});
  /// Gösterilecek mesaj (isteğe bağlı)
  final String? message;

  @override
  Widget build(BuildContext context) => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ],
      ),
    );
}
