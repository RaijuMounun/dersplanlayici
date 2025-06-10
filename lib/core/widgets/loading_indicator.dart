import 'package:flutter/material.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';

/// Uygulama genelinde kullanılan yükleme göstergesi widget'ı.
/// Bu widget, donma sorunlarını önlemek için özellikle tasarlanmıştır.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;
  final bool isOverlay;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
    this.color = AppColors.primary,
    this.isOverlay = false,
  });

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 3.0,
          ),
        ),
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );

    if (isOverlay) {
      return Material(
        type: MaterialType.transparency,
        child: Stack(
          children: [
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withOpacity(0.3),
            ),
            Center(child: loadingWidget),
          ],
        ),
      );
    }

    return Center(child: loadingWidget);
  }

  /// Ekranın üstüne yükleme göstergesi ile birlikte bir overlay gösterir.
  /// Bu metot, donma sorunlarını önlemek için kullanılmalıdır.
  static void showOverlay(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: LoadingIndicator(message: message, isOverlay: true),
        );
      },
    );
  }

  /// Aktif overlay'ı kapatır.
  static void hideOverlay(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// Bir Future işlemi sırasında yükleme göstergesi gösterir.
  /// Bu metot özellikle ağır işlemler için kullanılmalıdır.
  static Future<T> wrapWithLoading<T>({
    required BuildContext context,
    required Future<T> future,
    String? message,
  }) async {
    try {
      // Yükleme göstergesini hemen göster
      showOverlay(context, message: message);

      // İşlemi ayrı bir isolate veya async/await ile yap
      final result = await future;

      // Sonuç döndükten sonra overlay'ı kapat
      if (context.mounted) {
        hideOverlay(context);
      }

      return result;
    } catch (e) {
      // Hata durumunda overlay'ı kapat
      if (context.mounted) {
        hideOverlay(context);
      }
      rethrow;
    }
  }
}
