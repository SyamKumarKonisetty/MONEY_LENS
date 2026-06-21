import 'package:flutter/material.dart';
import '../components/text.dart';
import '../components/primitives.dart';
import '../foundations/colors.dart';

/// MoneyLens Design System (MLDS) Component Inspector.
///
/// **ARCHITECTURAL STUB & PREVIEW LAYOUT — DO NOT VISUALLY DEPLOY.**
///
/// Under Project AURA guidelines, this inspector serves as an in-app visual
/// documentation tool allowing developers to click a component and review
/// its exact design tokens, accessibility traits, and code patterns.
class MLComponentInspector extends StatelessWidget {
  const MLComponentInspector({
    required this.componentName,
    required this.purpose,
    required this.codeExample,
    required this.typographyToken,
    required this.colorToken,
    required this.spacingToken,
    required this.radiusToken,
    required this.shadowToken,
    required this.accessibilityNotes,
    super.key,
  });

  final String componentName;
  final String purpose;
  final String codeExample;

  final String typographyToken;
  final String colorToken;
  final String spacingToken;
  final String radiusToken;
  final String shadowToken;

  final String accessibilityNotes;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      color: MLColors.surfaceVariant(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MLText.heading(componentName),
              const MLBadge(label: 'INSPECTOR'),
            ],
          ),
          const SizedBox(height: 12.0),
          MLText.body('Purpose: $purpose'),
          const SizedBox(height: 16.0),

          const MLText.dotLabel('Foundation Tokens Used'),
          const SizedBox(height: 8.0),
          _buildTokenRow('Typography', typographyToken),
          _buildTokenRow('Color', colorToken),
          _buildTokenRow('Spacing', spacingToken),
          _buildTokenRow('Radius', radiusToken),
          _buildTokenRow('Shadow', shadowToken),
          const SizedBox(height: 16.0),

          const MLText.dotLabel('Accessibility Notes'),
          const SizedBox(height: 6.0),
          MLText.caption(accessibilityNotes),
          const SizedBox(height: 16.0),

          const MLText.dotLabel('Code Example'),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: Colors.black.withAlpha(204),
            child: Text(
              codeExample,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                color: Colors.greenAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenRow(String tokenType, String tokenName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [MLText.caption(tokenType), MLText.dotLabel(tokenName)],
      ),
    );
  }
}
