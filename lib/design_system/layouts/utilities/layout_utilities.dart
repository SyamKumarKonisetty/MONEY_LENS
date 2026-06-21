import 'package:flutter/material.dart';
import '../../foundations/spacing.dart';

/// Helper class to resolve layout safe areas, gesture bars, and notch dimensions.
class MLLayoutUtils {
  MLLayoutUtils._();

  /// Gets the height of the soft keyboard from the current view.
  static double keyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  /// Checks if the keyboard is currently active/visible.
  static bool isKeyboardVisible(BuildContext context) {
    return keyboardHeight(context) > 0.0;
  }

  /// Calculates top safe area padding, ensuring a minimum baseline value for notch styles.
  static double topPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topOffset = mediaQuery.padding.top;
    return topOffset > 0 ? topOffset : MLSpacing.safeAreaTopMin;
  }

  /// Calculates bottom safe area padding, ensuring a minimum baseline.
  static double bottomPadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomOffset = mediaQuery.padding.bottom;
    return bottomOffset > 0 ? bottomOffset : MLSpacing.safeAreaBottomMin;
  }

  /// Returns true if the viewport resembles a foldable screen with split geometry.
  static bool isFoldableHingeDetected(BuildContext context) {
    // Foldable screens typically report display features or have medium-range aspects.
    final size = MediaQuery.of(context).size;
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    // Simple heuristic for foldable dimensions
    return size.width > 500 && size.width < 700 && pixelRatio > 2.0;
  }
}

/// Helper container that listens to keyboard height changes and adjusts height.
class MLKeyboardSpacer extends StatelessWidget {
  const MLKeyboardSpacer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: MediaQuery.of(context).viewInsets.bottom);
  }
}
