import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/animations/haptics.dart';
import 'flow_state.dart';

/// Base controller implementing StateNotifier to govern Product Pattern Flows.
abstract class MLFlowController<T, S extends MLFlowState<T>>
    extends StateNotifier<S> {
  MLFlowController(super.state);

  /// Moves the flow forward to the next step, pushing the current index to history.
  void nextStep() {
    if (state.stepIndex < state.stepsCount - 1) {
      final newHistory = List<int>.from(state.history)..add(state.stepIndex);
      state =
          state.copyWith(
                stepIndex: state.stepIndex + 1,
                history: newHistory,
                errorMessage: null,
              )
              as S;
      MLHaptics.selection();
    }
  }

  /// Navigates back by popping the last step from history.
  void previousStep() {
    if (state.history.isNotEmpty) {
      final newHistory = List<int>.from(state.history);
      final prevIndex = newHistory.removeLast();
      state =
          state.copyWith(
                stepIndex: prevIndex,
                history: newHistory,
                errorMessage: null,
              )
              as S;
      MLHaptics.selection();
    }
  }

  /// Triggers a step back, supporting undo flows.
  void undo() {
    previousStep();
  }

  /// Directly jump to a target step.
  void goToStep(int index) {
    if (index >= 0 && index < state.stepsCount) {
      final newHistory = List<int>.from(state.history)..add(state.stepIndex);
      state =
          state.copyWith(
                stepIndex: index,
                history: newHistory,
                errorMessage: null,
              )
              as S;
      MLHaptics.selection();
    }
  }

  /// Set loading flags.
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading) as S;
  }

  /// Set error description and trigger warning haptics.
  void setError(String? error) {
    state = state.copyWith(errorMessage: error, isLoading: false) as S;
    if (error != null) {
      MLHaptics.warning();
    }
  }

  /// Set success message and trigger success haptics.
  void setSuccess(String? message) {
    state = state.copyWith(successMessage: message, isLoading: false) as S;
    if (message != null) {
      MLHaptics.success();
    }
  }

  /// Executes an operation optimistically. Automatically fires rollback on failure.
  Future<void> executeOptimistically({
    required Future<void> Function() action,
    required void Function() rollback,
    String? successMsg,
  }) async {
    try {
      setLoading(true);
      await action();
      setSuccess(successMsg);
    } catch (e) {
      rollback();
      setError(e.toString());
    }
  }
}
