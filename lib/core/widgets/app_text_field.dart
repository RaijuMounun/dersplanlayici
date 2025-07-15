import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_dimensions.dart';

/// Uygulamada kullanılan standart metin giriş alanı widget'ı.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
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
    this.required = false,
  });

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
  final bool required;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _internalFocusNode;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
      _isInternalFocusNode = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalFocusNode) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultContentPadding =
        widget.contentPadding ??
        const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacing16,
          vertical: AppDimensions.spacing12,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: widget.labelStyle ?? theme.textTheme.titleSmall,
              ),
              if (widget.required)
                Text(' *', style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          focusNode: _effectiveFocusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          autofocus: widget.autofocus,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          onFieldSubmitted: (value) {
            // Klavye olaylarını temizle
            _effectiveFocusNode.unfocus();
            widget.onSubmitted?.call(value);
          },
          onTap: () {
            // Tap olayında focus'u düzgün yönet
            if (!_effectiveFocusNode.hasFocus) {
              _effectiveFocusNode.requestFocus();
            }
            widget.onTap?.call();
          },
          validator: widget.validator,
          textAlign: widget.textAlign,
          showCursor: widget.showCursor,
          style: widget.style ?? theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: widget.filled,
            fillColor: widget.fillColor,
            contentPadding: defaultContentPadding,
            prefix: widget.prefix,
            suffix: widget.suffix,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            hintStyle: widget.hintStyle,
            errorStyle: widget.errorStyle,
            // Tema renklerini kullan - sabit renkler yerine
            border: null,
            enabledBorder: null,
            focusedBorder: null,
            errorBorder: null,
            focusedErrorBorder: null,
          ),
        ),
      ],
    );
  }
}
