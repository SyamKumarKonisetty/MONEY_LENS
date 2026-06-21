import 'package:flutter/material.dart';

/// Base class representing the immutable state of any Product Pattern Flow.
@immutable
abstract class MLFlowState<T> {
  const MLFlowState({
    required this.stepIndex,
    required this.stepsCount,
    required this.history,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final int stepIndex;
  final int stepsCount;
  final List<int> history;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  bool get isFirstStep => stepIndex == 0;
  bool get isLastStep => stepIndex == stepsCount - 1;
  bool get isSuccess => successMessage != null;
  bool get hasError => errorMessage != null;

  /// Clones the state with updated parameters.
  MLFlowState<T> copyWith({
    int? stepIndex,
    int? stepsCount,
    List<int>? history,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  });
}
