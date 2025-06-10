import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// Uygulamada kullanılan standart metin giriş alanı widget'ı.
class AppTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsets? contentPadding;
  final bool filled;
  final Color? fillColor;
  final String? helperText;
  final String? errorText;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextAlign textAlign;
  final bool showCursor;

  const AppTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.filled = true,
    this.fillColor,
    this.helperText,
    this.errorText,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.textAlign = TextAlign.start,
    this.showCursor = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultContentPadding =
        contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing12,
        );

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator,
      textAlign: textAlign,
      showCursor: showCursor,
      style: style,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helperText,
        errorText: errorText,
        filled: filled,
        fillColor: fillColor ?? AppColors.surface,
        contentPadding: defaultContentPadding,
        prefix: prefix,
        suffix: suffix,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelStyle: labelStyle,
        hintStyle: hintStyle,
        errorStyle: errorStyle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius8),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}
