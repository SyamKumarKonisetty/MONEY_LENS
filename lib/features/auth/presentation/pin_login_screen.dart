import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/extensions/context_extensions.dart';
import '../providers/auth_provider.dart';

class PinLoginScreen extends ConsumerStatefulWidget {
  final bool isSetupMode;

  const PinLoginScreen({
    super.key,
    required this.isSetupMode,
  });

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  String _inputPin = '';
  String _firstEnteredPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

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
            authNotifier.setupPin(_inputPin);
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

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
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
                      // Empty space / Fingerprint placeholder
                      const SizedBox(width: 70, height: 70),
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
