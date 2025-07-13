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
      if (i == 0) {
        formatted += digits[i];
      } else if (i == 1) {
        formatted += digits[i];
      } else if (i == 2) {
        formatted += '${digits[i]} ';
      } else if (i == 5) {
        formatted += '${digits[i]} ';
      } else if (i == 7) {
        formatted += '${digits[i]} ';
      } else {
        formatted += digits[i];
      }
    }
    formatted = formatted.trimRight();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
