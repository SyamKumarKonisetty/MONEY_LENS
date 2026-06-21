import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../design_system/components/buttons.dart';
import '../../../design_system/components/inputs.dart';
import '../providers/auth_provider.dart';

class ChangePinSheet extends ConsumerStatefulWidget {
  const ChangePinSheet({super.key});

  @override
  ConsumerState<ChangePinSheet> createState() => _ChangePinSheetState();
}

class _ChangePinSheetState extends ConsumerState<ChangePinSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentPin = _currentPinController.text;
    final newPin = _newPinController.text;

    // Small delay for premium feel
    await Future<void>.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = authNotifier.changePin(currentPin, newPin);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN updated successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.primaryColor,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _errorMessage = 'Incorrect current PIN. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        top: AppSpacing.lg,
        left: AppSpacing.pagePadding,
        right: AppSpacing.pagePadding,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: context.separatorColor,
                  borderRadius: AppRadius.circularFull,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Change PIN',
              style: AppTypography.titleLarge.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Update your 4-digit security passcode.',
              style: AppTypography.bodySmall.copyWith(
                color: context.textSecondaryColor,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: context.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: context.errorColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildPinField(
                    controller: _currentPinController,
                    labelText: 'Current PIN',
                    hintText: 'Enter active 4-digit PIN',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPinField(
                    controller: _newPinController,
                    labelText: 'New PIN',
                    hintText: 'Enter new 4-digit PIN',
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildPinField(
                    controller: _confirmPinController,
                    labelText: 'Confirm New PIN',
                    hintText: 'Re-enter new 4-digit PIN',
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Confirm PIN cannot be empty';
                      }
                      if (val.length != 4) {
                        return 'PIN must be exactly 4 digits';
                      }
                      if (val != _newPinController.text) {
                        return 'Confirm PIN does not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  MLButton.primary(
                    label: 'Update PIN',
                    onPressed: _submit,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    String? Function(String?)? validator,
  }) {
    return MLInput.text(
      controller: controller,
      hintText: hintText,
      label: labelText,
      obscureText: true,
      maxLength: 4,
      keyboardType: TextInputType.number,
      style: AppTypography.bodyLarge.copyWith(
        color: context.textPrimaryColor,
        letterSpacing: 8.0,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      validator: validator ??
          (val) {
            if (val == null || val.isEmpty) return '$labelText cannot be empty';
            if (val.length != 4) return 'PIN must be exactly 4 digits';
            return null;
          },
    );
  }
}
