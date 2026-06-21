import 'package:flutter/material.dart';
import '../../foundations/spacing.dart';
import '../base/scaffold.dart';
import '../responsive/responsive_layout.dart';

/// MoneyLens Design System (MLDS) Authentication Layout.
///
/// Structures security PIN entry, setup screens, and recovery operations.
class MLAuthenticationLayout extends StatelessWidget {
  const MLAuthenticationLayout({
    required this.logo,
    required this.pinPad,
    required this.recoveryActions,
    super.key,
    this.header,
  });

  final Widget? header;
  final Widget logo;
  final Widget pinPad;
  final Widget recoveryActions;

  @override
  Widget build(BuildContext context) {
    return MLScaffold(
      body: MLResponsiveContainer(
        phone: _buildPhoneLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MLSpacing.pagePadding),
        child: Column(
          children: [
            ?header,
            const Spacer(),
            logo,
            const Spacer(),
            pinPad,
            const SizedBox(height: MLSpacing.xl),
            recoveryActions,
            const SizedBox(height: MLSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MLSpacing.pagePadding),
        child: Row(
          children: [
            // Left Welcome/Branding column
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ?header,
                  const Spacer(),
                  logo,
                  const Spacer(),
                ],
              ),
            ),
            const VerticalDivider(width: 48.0, thickness: 1.0),
            // Right Security Pad input column
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  pinPad,
                  const SizedBox(height: MLSpacing.xl),
                  recoveryActions,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800.0),
          padding: const EdgeInsets.all(MLSpacing.pagePadding),
          child: Row(
            children: [
              // Left Section: Branding & Identity
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ?header,
                    const SizedBox(height: MLSpacing.xxl),
                    logo,
                  ],
                ),
              ),
              const SizedBox(width: MLSpacing.giant),
              // Right Section: Pin entry and password recovery
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    pinPad,
                    const SizedBox(height: MLSpacing.xxl),
                    recoveryActions,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
