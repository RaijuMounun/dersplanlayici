import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Türk GSM numarası için 5xx xxx xx xx formatında maskeleme yapan formatter.
class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');
    if (digits.length > 10) digits = digits.substring(0, 10);

    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6 || i == 8) {
        formatted += ' ';
      }
      formatted += digits[i];
    }
    formatted = formatted.trimRight();
    debugPrint('formatted: $formatted');
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
