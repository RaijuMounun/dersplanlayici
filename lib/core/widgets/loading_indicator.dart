import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

/// Uygulama genelinde kullanılan yükleme göstergesi widget'ı.
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;
  final bool isOverlay;

  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 40.0,
    this.color = ColorConstants.primaryColor,
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
              color: Color.fromRGBO(0, 0, 0, 0.3),
            ),
            Center(child: loadingWidget),
          ],
        ),
      );
    }

    return Center(child: loadingWidget);
  }

  /// Ekranın üstüne yükleme göstergesi ile birlikte bir overlay gösterir.
  static void showOverlay(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingIndicator(message: message, isOverlay: true);
      },
    );
  }

  /// Aktif overlay'ı kapatır.
  static void hideOverlay(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Bir Future işlemi sırasında yükleme göstergesi gösterir.
  static Future<T> wrapWithLoading<T>({
    required BuildContext context,
    required Future<T> future,
    String? message,
  }) async {
    // BuildContext'i async metot başında yakalayalım
    showOverlay(context, message: message);

    try {
      final result = await future;
      if (context.mounted) {
        hideOverlay(context);
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        hideOverlay(context);
      }
      rethrow;
    }
  }
}
