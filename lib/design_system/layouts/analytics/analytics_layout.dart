import 'package:flutter/material.dart';
import '../../foundations/spacing.dart';
import '../base/scaffold.dart';
import '../page/page.dart';
import '../responsive/responsive_layout.dart';

/// MoneyLens Design System (MLDS) Analytics Layout.
///
/// Structures charts, selectors, breakdowns, and automated financial insights.
class MLAnalyticsLayout extends StatelessWidget {
  const MLAnalyticsLayout({
    required this.header,
    required this.rangeSelector,
    required this.primaryChart,
    required this.breakdown,
    required this.insights,
    super.key,
    this.bottomNavigation,
  });

  final Widget header;
  final Widget rangeSelector;
  final Widget primaryChart;
  final Widget breakdown;
  final Widget insights;
  final Widget? bottomNavigation;

  @override
  Widget build(BuildContext context) {
    return MLScaffold(
      bottomNavigationBar: bottomNavigation,
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
      children: [
        rangeSelector,
        MLSection(title: 'Trend Analysis', child: primaryChart),
        MLSection(title: 'Category Breakdown', child: breakdown),
        MLSection(title: 'Insights', child: insights),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        header,
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MLSpacing.pagePadding,
          ),
          child: rangeSelector,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MLSpacing.pagePadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Primary trend chart
                Expanded(
                  flex: 3,
                  child: MLSection(
                    title: 'Trend Analysis',
                    child: primaryChart,
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Right side: Breakdown & insights
                Expanded(
                  flex: 2,
                  child: MLSectionGroup(
                    children: [
                      MLSection(title: 'Category Breakdown', child: breakdown),
                      MLSection(title: 'Insights', child: insights),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MLSpacing.pagePadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Workspace side: Filters and main chart
                Expanded(
                  flex: 5,
                  child: MLSectionGroup(
                    children: [
                      rangeSelector,
                      MLSection(
                        title: 'Interactive Trend Workspace',
                        child: primaryChart,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Breakdown side
                Expanded(
                  flex: 3,
                  child: MLSection(
                    title: 'Category Distribution',
                    child: breakdown,
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Recommendations side
                Expanded(
                  flex: 2,
                  child: MLSection(
                    title: 'Algorithmic Insights',
                    child: insights,
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
