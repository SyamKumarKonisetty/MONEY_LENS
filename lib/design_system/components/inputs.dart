import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundations/colors.dart';
import '../foundations/radius.dart';
import '../foundations/spacing.dart';
import '../foundations/typography.dart';
import 'package:money_lens/core/design/design_system.dart';

/// MoneyLens Design System (MLDS) Input Component interface.
///
/// Under MLDS, text inputs must follow a strict semantic layout and focus state.
abstract class MLInput extends StatelessWidget {
  const MLInput({super.key});

  /// Standard text input field.
  const factory MLInput.text({
    required String hintText,
    Key? key,
    TextEditingController? controller,
    String? label,
    IconData? prefixIcon,
    ValueChanged<String>? onChanged,
    bool autofocus,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    bool obscureText,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextStyle? style,
  }) = _MLTextInput;

  /// Numeric/currency input field.
  const factory MLInput.number({
    required String hintText,
    Key? key,
    TextEditingController? controller,
    String? label,
    IconData? prefixIcon,
    ValueChanged<String>? onChanged,
    bool autofocus,
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    bool obscureText,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextStyle? style,
  }) = _MLNumberInput;
}

class _MLTextInput extends MLInput {
  const _MLTextInput({
    required this.hintText,
    super.key,
    this.controller,
    this.label,
    this.prefixIcon,
    this.onChanged,
    this.autofocus = false,
    this.textInputAction,
    this.focusNode,
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.keyboardType,
    this.style,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? label;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? MLColors.surfaceVariant(context)
        : const Color(0xFFF2F2F7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: MLTypography.titleSmall.copyWith(
              color: MLColors.of(context).secondary,
            ),
          ),
          const SizedBox(height: MLSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          validator: validator,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: style ??
              MLTypography.input.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimary
                    : Colors.black,
              ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: MLTypography.bodyMedium.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textPrimary.withValues(alpha: 0.24)
                  : Colors.black38,
              letterSpacing: style?.letterSpacing != null ? 0.0 : null,
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
            filled: true,
            fillColor: fillColor,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MLSpacing.lg,
              vertical: MLSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: MLRadius.largeBorderRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: MLRadius.largeBorderRadius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: MLRadius.largeBorderRadius,
              borderSide: BorderSide(
                color: MLColors.primary(context),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MLNumberInput extends MLInput {
  const _MLNumberInput({
    required this.hintText,
    super.key,
    this.controller,
    this.label,
    this.prefixIcon,
    this.onChanged,
    this.autofocus = false,
    this.textInputAction,
    this.focusNode,
    this.obscureText = false,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.style,
  });

  final String hintText;
  final TextEditingController? controller;
  final String? label;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool obscureText;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final fillColor = Theme.of(context).brightness == Brightness.dark
        ? MLColors.surfaceVariant(context)
        : const Color(0xFFF2F2F7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: MLTypography.titleSmall.copyWith(
              color: MLColors.of(context).secondary,
            ),
          ),
          const SizedBox(height: MLSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          textInputAction: textInputAction,
          obscureText: obscureText,
          maxLength: maxLength,
          validator: validator,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: inputFormatters ??
              [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
          onChanged: onChanged,
          style: style ??
              MLTypography.input.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimary
                    : Colors.black,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: MLTypography.bodyMedium.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textPrimary.withValues(alpha: 0.24)
                  : Colors.black38,
              letterSpacing: style?.letterSpacing != null ? 0.0 : null,
            ),
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
            filled: true,
            fillColor: fillColor,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: MLSpacing.lg,
              vertical: MLSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: MLRadius.largeBorderRadius,
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: MLRadius.largeBorderRadius,
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: MLRadius.largeBorderRadius,
              borderSide: BorderSide(
                color: MLColors.primary(context),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
