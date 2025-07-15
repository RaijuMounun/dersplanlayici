import 'package:flutter/material.dart';

/// Uygulama genelinde kullanılacak, özelleştirilebilir bir onay diyaloğu gösterir.
///
/// [context]: Diyaloğun gösterileceği `BuildContext`.
/// [title]: Diyaloğun başlığı.
/// [content]: Diyaloğun içeriği, genellikle bir `Text` widget'ı.
/// [confirmText]: Onay butonunun metni, varsayılan olarak 'Onayla'.
/// [cancelText]: İptal butonunun metni, varsayılan olarak 'İptal'.
///
/// Kullanıcı onay butonuna basarsa `true`, iptal ederse veya dışarı tıklarsa `false` döner.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  String confirmText = 'Onayla',
  String cancelText = 'İptal',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
