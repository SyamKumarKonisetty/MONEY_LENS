import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../design_system/components/buttons.dart';
import '../../../design_system/components/inputs.dart';
import '../../../design_system/components/chips.dart';
import '../providers/auth_provider.dart';
import '../../settings/presentation/providers/user_profile_provider.dart';
import 'forgot_pin_sheet.dart';
import '../../../core/design/colors/app_colors.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  final bool isSetupMode;

  const PinLoginScreen({super.key, required this.isSetupMode});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _inputPin = '';
  String _firstEnteredPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  bool _isEnteringName = false;
  final _nameFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  bool _isSettingUpRecovery = false;
  String? _selectedProfile; // 'student' or 'salaried'
  final _recoveryFormKey = GlobalKey<FormState>();
  final _recoveryInputController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _recoveryInputController.dispose();
    super.dispose();
  }

  void _onNumberTap(int number) {
    if (_inputPin.length >= 4) return;
    HapticFeedback.lightImpact();

    setState(() {
      _errorMessage = null;
      _inputPin += number.toString();
    });

    if (_inputPin.length == 4) {
      _processPin();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  void _onDeleteTap() {
    if (_inputPin.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _errorMessage = null;
      _inputPin = _inputPin.substring(0, _inputPin.length - 1);
    });
  }

  void _processPin() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;

      final authNotifier = ref.read(authNotifierProvider.notifier);

      if (widget.isSetupMode) {
        if (!_isConfirming) {
          // Store first entry and transition to confirmation
          setState(() {
            _firstEnteredPin = _inputPin;
            _inputPin = '';
            _isConfirming = true;
          });
        } else {
          // Confirm PIN
          if (_inputPin == _firstEnteredPin) {
            HapticFeedback.mediumImpact();
            setState(() {
              _isEnteringName = true;
              _errorMessage = null;
            });
          } else {
            HapticFeedback.heavyImpact();
            setState(() {
              _errorMessage = 'PINs do not match. Please try again.';
              _inputPin = '';
              _firstEnteredPin = '';
              _isConfirming = false;
            });
          }
        }
      } else {
        // Login mode
        final success = authNotifier.authenticate(_inputPin);
        if (success) {
          HapticFeedback.mediumImpact();
        } else {
          HapticFeedback.heavyImpact();
          setState(() {
            _errorMessage = 'Incorrect PIN. Please try again.';
            _inputPin = '';
          });
        }
      }
    });
  }

  void _showForgotPinDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => const ForgotPinSheet(),
    );
  }

  Widget _buildProfileSelectionView(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.giant,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 40,
                    color: context.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Who are you?',
                style: AppTypography.displayMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose your profile type to configure recovery.',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.giant),

              // Student Card
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedProfile = 'student';
                  });
                },
                borderRadius: AppRadius.card,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: context.separatorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.incomeGreen.withValues(alpha: 0.1),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Icon(
                          Icons.school_rounded,
                          color: AppColors.incomeGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student',
                              style: AppTypography.titleMedium.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Expected Monthly Income',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: context.textSecondaryColor,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Salaried Card
              InkWell(
                onTap: () {
                  setState(() {
                    _selectedProfile = 'salaried';
                  });
                },
                borderRadius: AppRadius.card,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: AppRadius.card,
                    border: Border.all(
                      color: context.separatorColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.sapphireBlue.withValues(alpha: 0.1),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Icon(
                          Icons.work_rounded,
                          color: AppColors.sapphireBlue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Salaried Professional',
                              style: AppTypography.titleMedium.copyWith(
                                color: context.textPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Monthly Salary',
                              style: AppTypography.bodySmall.copyWith(
                                color: context.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: context.textSecondaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalaryInputView(BuildContext context) {
    final isStudent = _selectedProfile == 'student';
    final questionText = isStudent
        ? 'What is your expected monthly income?'
        : 'What is your monthly salary?';
    final labelText = isStudent
        ? 'Expected Monthly Income (₹)'
        : 'Monthly Salary (₹)';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.giant,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: MLButton.text(
                  label: 'Back to Profile selection',
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () {
                    setState(() {
                      _selectedProfile = null;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.security_rounded,
                    size: 40,
                    color: context.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Recovery Setup',
                style: AppTypography.displayMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Set a recovery security question to secure your account.',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Question:',
                style: AppTypography.bodySmall.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                questionText,
                style: AppTypography.titleMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Form(
                key: _recoveryFormKey,
                child: Column(
                  children: [
                    MLInput.number(
                      controller: _recoveryInputController,
                      hintText: 'e.g. 50000',
                      label: labelText,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(color: context.textPrimaryColor),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid amount greater than 1';
                        }
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 1) {
                          return 'Please enter a valid amount greater than 1';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    MLButton.primary(
                      label: 'Save Recovery & PIN',
                      onPressed: () async {
                        if (_recoveryFormKey.currentState!.validate()) {
                          final amt = double.parse(
                            _recoveryInputController.text,
                          );
                          await ref
                              .read(userProfileNotifierProvider.notifier)
                              .updateName(_nameController.text);
                          ref
                              .read(authNotifierProvider.notifier)
                              .setupPinAndRecovery(
                                _firstEnteredPin,
                                amt,
                                _selectedProfile!,
                              );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameInputView(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePadding,
            vertical: AppSpacing.giant,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: MLButton.text(
                  label: 'Back to PIN creation',
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () {
                    setState(() {
                      _isEnteringName = false;
                      _inputPin = '';
                      _firstEnteredPin = '';
                      _isConfirming = false;
                    });
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.face_rounded,
                    size: 40,
                    color: context.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'What should we call you?',
                style: AppTypography.displayMedium.copyWith(
                  color: context.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose a display name for your personalized dashboard.',
                style: AppTypography.bodyMedium.copyWith(
                  color: context.textSecondaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Form(
                key: _nameFormKey,
                child: Column(
                  children: [
                    MLInput.text(
                      controller: _nameController,
                      hintText: 'e.g. Rahul',
                      label: 'Your Name',
                      maxLength: 25,
                      style: TextStyle(color: context.textPrimaryColor),
                      inputFormatters: [LengthLimitingTextInputFormatter(25)],
                      onChanged: (val) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.trim().length > 25) {
                          return 'Name must be 25 characters or less';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Examples chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: ['HERO', 'HEROINE', 'VILLAN', 'NOONE'].map((
                        name,
                      ) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: MLChip.choice(
                            label: name,
                            isSelected: _nameController.text.trim() == name,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _nameController.text = name;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    MLButton.primary(
                      label: 'Continue',
                      onPressed: () {
                        if (_nameFormKey.currentState!.validate()) {
                          setState(() {
                            _isEnteringName = false;
                            _isSettingUpRecovery = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecoverySetupView(BuildContext context) {
    if (_selectedProfile == null) {
      return _buildProfileSelectionView(context);
    } else {
      return _buildSalaryInputView(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEnteringName) {
      return _buildNameInputView(context);
    }
    if (_isSettingUpRecovery) {
      return _buildRecoverySetupView(context);
    }

    String titleText;
    String subtitleText;

    if (widget.isSetupMode) {
      if (!_isConfirming) {
        titleText = 'Create PIN';
        subtitleText = 'Setup a 4-digit PIN to secure your financial data';
      } else {
        titleText = 'Confirm PIN';
        subtitleText = 'Re-enter your 4-digit PIN to verify';
      }
    } else {
      titleText = 'Welcome Back';
      subtitleText = 'Enter your 4-digit PIN to unlock';
    }

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Title & Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 40,
                      color: context.primaryColor,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    titleText,
                    style: AppTypography.displayMedium.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    subtitleText,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textSecondaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // PIN Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final isFilled = index < _inputPin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? context.primaryColor
                        : context.separatorColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFilled
                          ? context.primaryColor
                          : context.separatorColor,
                      width: 1.5,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.md),

            // Error Message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePadding,
                ),
                child: Text(
                  _errorMessage ?? '',
                  style: TextStyle(
                    color: context.errorColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const Spacer(),

            // Custom Keypad
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, bottom: 30),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeypadButton(1),
                      _buildKeypadButton(2),
                      _buildKeypadButton(3),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeypadButton(4),
                      _buildKeypadButton(5),
                      _buildKeypadButton(6),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKeypadButton(7),
                      _buildKeypadButton(8),
                      _buildKeypadButton(9),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Forgot PIN button (only in login mode)
                      !widget.isSetupMode
                          ? InkWell(
                              onTap: _showForgotPinDialog,
                              borderRadius: BorderRadius.circular(35),
                              child: Container(
                                width: 70,
                                height: 70,
                                alignment: Alignment.center,
                                child: Text(
                                  'Forgot\nPIN?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: context.textSecondaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : const SizedBox(width: 70, height: 70),
                      _buildKeypadButton(0),
                      _buildDeleteButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypadButton(int number) {
    return InkWell(
      onTap: () => _onNumberTap(number),
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.separatorColor.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          number.toString(),
          style: AppTypography.displayMedium.copyWith(
            fontSize: 24,
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return InkWell(
      onTap: _onDeleteTap,
      borderRadius: BorderRadius.circular(35),
      child: SizedBox(
        width: 70,
        height: 70,
        child: Icon(
          Icons.backspace_outlined,
          color: context.textPrimaryColor,
          size: 22,
        ),
      ),
    );
  }
}
