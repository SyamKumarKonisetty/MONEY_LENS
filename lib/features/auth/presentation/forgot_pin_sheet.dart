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

class ForgotPinSheet extends ConsumerStatefulWidget {
  const ForgotPinSheet({super.key});

  @override
  ConsumerState<ForgotPinSheet> createState() => _ForgotPinSheetState();
}

class _ForgotPinSheetState extends ConsumerState<ForgotPinSheet> {
  int _selectedOption =
      0; // 0 = none, 1 = Option 1 (Current PIN), 2 = Option 2 (Recovery Answer)

  final _formKey1 = GlobalKey<FormState>();
  final _currentPinController = TextEditingController();
  final _newPinController1 = TextEditingController();
  final _confirmPinController1 = TextEditingController();

  final _formKey2 = GlobalKey<FormState>();
  final _recoveryAnswerController = TextEditingController();
  final _newPinController2 = TextEditingController();
  final _confirmPinController2 = TextEditingController();

  bool _isAnswerVerified = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController1.dispose();
    _confirmPinController1.dispose();
    _recoveryAnswerController.dispose();
    _newPinController2.dispose();
    _confirmPinController2.dispose();
    super.dispose();
  }

  void _verifyOption1() async {
    if (!_formKey1.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = authNotifier.changePin(
      _currentPinController.text,
      _newPinController1.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Authenticate with new PIN
      authNotifier.authenticate(_newPinController1.text);
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN reset successfully via current PIN'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.primaryColor,
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

  void _verifyAnswer() async {
    setState(() {
      _errorMessage = null;
    });

    final answer = _recoveryAnswerController.text.trim();
    final parsed = double.tryParse(answer.replaceAll(',', '').trim());
    if (parsed == null || parsed <= 1) {
      setState(() {
        _errorMessage = 'Please enter a valid amount greater than 1';
      });
      return;
    }

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final isCorrect = authNotifier.verifyRecoveryAnswer(answer);

    if (isCorrect) {
      setState(() {
        _isAnswerVerified = true;
      });
    } else {
      setState(() {
        _errorMessage = 'Incorrect recovery answer. Please try again.';
      });
    }
  }

  void _verifyOption2() async {
    if (!_formKey2.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = authNotifier.resetPinWithRecovery(_newPinController2.text);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN reset successfully via recovery question'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.primaryColor,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      setState(() {
        _errorMessage = 'Failed to reset PIN. Try again.';
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
              'Recover PIN',
              style: AppTypography.titleLarge.copyWith(
                color: context.textPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choose a verification method to reset your passcode.',
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

            if (_selectedOption == 0) ...[
              // Option 1 Selector
              ListTile(
                leading: Icon(Icons.pin_rounded, color: context.primaryColor),
                title: Text(
                  'Option 1: Verify Current PIN',
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
                subtitle: Text(
                  'Enter your active PIN to change it',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.textSecondaryColor,
                ),
                onTap: () {
                  setState(() {
                    _selectedOption = 1;
                    _errorMessage = null;
                  });
                },
              ),
              const Divider(),
              // Option 2 Selector
              ListTile(
                leading: Icon(
                  Icons.security_rounded,
                  color: context.primaryColor,
                ),
                title: Text(
                  'Option 2: Verify Recovery Answer',
                  style: AppTypography.bodyLarge.copyWith(
                    color: context.textPrimaryColor,
                  ),
                ),
                subtitle: Text(
                  'Answer security question to reset PIN',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.textSecondaryColor,
                ),
                onTap: () {
                  setState(() {
                    _selectedOption = 2;
                    _errorMessage = null;
                  });
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ] else if (_selectedOption == 1) ...[
              // Back Button
              TextButton.icon(
                onPressed: () => setState(() => _selectedOption = 0),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: context.primaryColor,
                ),
                label: Text(
                  'Back to options',
                  style: TextStyle(color: context.primaryColor),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Form(
                key: _formKey1,
                child: Column(
                  children: [
                    _buildPinField(
                      controller: _currentPinController,
                      labelText: 'Current PIN',
                      hintText: 'Enter active 4-digit PIN',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPinField(
                      controller: _newPinController1,
                      labelText: 'New PIN',
                      hintText: 'Enter new 4-digit PIN',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildPinField(
                      controller: _confirmPinController1,
                      labelText: 'Confirm New PIN',
                      hintText: 'Re-enter new 4-digit PIN',
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Confirm PIN cannot be empty';
                        }
                        if (val.length != 4) {
                          return 'PIN must be exactly 4 digits';
                        }
                        if (val != _newPinController1.text) {
                          return 'Confirm PIN does not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    MLButton.primary(
                      label: 'Reset PIN',
                      onPressed: _verifyOption1,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ] else if (_selectedOption == 2) ...[
              // Back Button
              TextButton.icon(
                onPressed: () => setState(() => _selectedOption = 0),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: context.primaryColor,
                ),
                label: Text(
                  'Back to options',
                  style: TextStyle(color: context.primaryColor),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (!_isAnswerVerified) ...[
                Text(
                  'Question:',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.textSecondaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ref.watch(authNotifierProvider).profileType == 'student'
                      ? 'What is your expected monthly income?'
                      : 'What is your monthly salary?',
                  style: AppTypography.titleMedium.copyWith(
                    color: context.textPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                MLInput.text(
                  controller: _recoveryAnswerController,
                  hintText: 'e.g. 50000',
                  label: 'Your Answer (₹)',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: AppSpacing.xxl),
                MLButton.primary(
                  label: 'Verify Answer',
                  onPressed: _verifyAnswer,
                ),
              ] else ...[
                Form(
                  key: _formKey2,
                  child: Column(
                    children: [
                      const Text(
                        'Answer verified! Enter your new PIN below.',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPinField(
                        controller: _newPinController2,
                        labelText: 'New PIN',
                        hintText: 'Enter new 4-digit PIN',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildPinField(
                        controller: _confirmPinController2,
                        labelText: 'Confirm New PIN',
                        hintText: 'Re-enter new 4-digit PIN',
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Confirm PIN cannot be empty';
                          }
                          if (val.length != 4) {
                            return 'PIN must be exactly 4 digits';
                          }
                          if (val != _newPinController2.text) {
                            return 'Confirm PIN does not match';
                          }
                          return null;
                        },
                      ),
                      MLButton.primary(
                        label: 'Reset PIN',
                        onPressed: _verifyOption2,
                        isLoading: _isLoading,
                      ),
                    ],
                  ),
                ),
              ],
            ],
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
