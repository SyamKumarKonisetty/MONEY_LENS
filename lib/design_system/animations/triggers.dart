import 'package:flutter/material.dart';
import '../foundations/curves.dart';

/// MoneyLens Design System (MLDS) Animation Triggers.
///
/// Under FIL and FML guidelines, these static helpers provide standardized hooks
/// to animate interactive elements using spring physics and custom curves.
class MLAnimationTriggers {
  MLAnimationTriggers._();

  /// Trigger a spring scale punch on a given animation controller.
  static void springPunch(AnimationController controller) {
    controller.forward(from: 0.0);
  }

  /// Triggers the Income "Coin Drop" animation sequence (approx 600ms).
  ///
  /// Animates translation and scale overlays on the balance container.
  static void triggerCoinDrop(AnimationController controller) {
    controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 600),
      curve: MLCurves.coinDropBounce,
    );
  }

  /// Triggers the Expense "Receipt Fold" animation sequence (approx 500ms).
  ///
  /// Governs folding collapse transformations.
  static void triggerReceiptFold(AnimationController controller) {
    controller.animateTo(
      1.0,
      duration: const Duration(milliseconds: 500),
      curve: MLCurves.receiptFoldCurve,
    );
  }

  /// Triggers the CSV Export "Document Store" sequence.
  ///
  /// Governs translating slide-ins into containment cells.
  static void triggerDocumentStore(AnimationController controller) {
    controller.forward(from: 0.0);
  }

  /// Triggers the CSV Import "Folder Open" sequence.
  ///
  /// Sequentially triggers child item entrance controllers.
  static void triggerFolderOpen(List<AnimationController> controllers) {
    for (int i = 0; i < controllers.length; i++) {
      Future.delayed(Duration(milliseconds: 50 * i), () {
        controllers[i].forward(from: 0.0);
      });
    }
  }

  /// Triggers the "Paper Fold" dismiss swipe sequence.
  static void triggerPaperFold(AnimationController controller) {
    controller.forward(from: 0.0);
  }
}
