import 'package:flutter/material.dart';
import '../foundations/typography.dart';

/// MoneyLens Design System (MLDS) Semantic Text API helper.
///
/// Under Project AURA, developers must consume semantic text initializers
/// instead of raw Text widgets with custom Styles.
///
/// Example:
/// ```dart
/// MLText.heading('Recent Activity')
/// ```
abstract class MLText extends StatelessWidget {
  const MLText({super.key});

  /// Large hero amount header style (e.g. for dashboard sums).
  const factory MLText.heroAmount(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _MLTextHeroAmount;

  /// Large balance description styling.
  const factory MLText.balance(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _MLTextBalance;

  /// Standard section header text.
  const factory MLText.heading(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _MLTextHeading;

  /// Standard readable body content.
  const factory MLText.body(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _MLTextBody;

  /// Auxiliary caption text.
  const factory MLText.caption(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _MLTextCaption;

  /// Uppercase dot-matrix label for metadata, card headings, and system lines.
  const factory MLText.dotLabel(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _MLTextDotLabel;

  /// Semantic financial values text.
  const factory MLText.money(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _MLTextMoney;

  /// Interactive chart value labels.
  const factory MLText.chartValue(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _MLTextChartValue;

  /// Badge indicator text.
  const factory MLText.badge(
    String text, {
    Key? key,
    Color? color,
    TextAlign? textAlign,
  }) = _MLTextBadge;
}

class _MLTextHeroAmount extends MLText {
  const _MLTextHeroAmount(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: MLTypography.heroAmount.copyWith(color: color),
    );
  }
}

class _MLTextBalance extends MLText {
  const _MLTextBalance(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: MLTypography.heroBalance.copyWith(color: color),
    );
  }
}

class _MLTextHeading extends MLText {
  const _MLTextHeading(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: MLTypography.headingLarge.copyWith(color: color),
    );
  }
}

class _MLTextBody extends MLText {
  const _MLTextBody(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: MLTypography.bodyMedium.copyWith(color: color),
    );
  }
}

class _MLTextCaption extends MLText {
  const _MLTextCaption(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: MLTypography.caption.copyWith(color: color),
    );
  }
}

class _MLTextDotLabel extends MLText {
  const _MLTextDotLabel(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: MLTypography.getDotMatrixStyle(
        MLTypography.dotLabel,
      ).copyWith(color: color),
    );
  }
}

class _MLTextMoney extends MLText {
  const _MLTextMoney(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: MLTypography.moneyMedium.copyWith(color: color),
    );
  }
}

class _MLTextChartValue extends MLText {
  const _MLTextChartValue(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: MLTypography.chartValue.copyWith(color: color),
    );
  }
}

class _MLTextBadge extends MLText {
  const _MLTextBadge(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: MLTypography.badge.copyWith(color: color),
    );
  }
}
