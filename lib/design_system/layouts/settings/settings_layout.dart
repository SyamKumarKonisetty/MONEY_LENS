import 'package:flutter/material.dart';
import '../../foundations/spacing.dart';
import '../base/scaffold.dart';
import '../page/page.dart';
import '../responsive/responsive_layout.dart';

/// MoneyLens Design System (MLDS) Settings Layout.
///
/// Structures personal profiles, application settings tiles, and compliance footers.
class MLSettingsLayout extends StatelessWidget {
  const MLSettingsLayout({
    required this.header,
    required this.profileCard,
    required this.settingsTiles,
    super.key,
    this.footer,
  });

  final Widget header;
  final Widget profileCard;
  final Widget settingsTiles;
  final Widget? footer;

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
    return MLScrollablePage(
      header: header,
      spacing: MLSpacing.xl,
      footer: footer,
      children: [profileCard, settingsTiles],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    final footerWidget = footer;
    return Column(
      children: [
        header,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(MLSpacing.pagePadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left profile column
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      profileCard,
                      const SizedBox(height: MLSpacing.xl),
                      ?footerWidget,
                    ],
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Right settings navigation column
                Expanded(
                  flex: 3,
                  child: MLSection(title: 'Preferences', child: settingsTiles),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final footerWidget = footer;
    return Column(
      children: [
        header,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(MLSpacing.pagePadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left profile/about side-bar
                SizedBox(
                  width: 320.0,
                  child: Column(
                    children: [
                      profileCard,
                      const Spacer(),
                      ?footerWidget,
                    ],
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Main preference options panel
                Expanded(
                  child: MLSection(
                    title: 'Application Preferences & Policy',
                    child: SingleChildScrollView(child: settingsTiles),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
