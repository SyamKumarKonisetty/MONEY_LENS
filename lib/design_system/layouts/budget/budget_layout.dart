import 'package:flutter/material.dart';
import '../../foundations/spacing.dart';
import '../base/scaffold.dart';
import '../page/page.dart';
import '../responsive/responsive_layout.dart';

/// MoneyLens Design System (MLDS) Budget Layout.
///
/// Designed to structure active goals, limits, and visual progress gauges.
class MLBudgetLayout extends StatelessWidget {
  const MLBudgetLayout({
    required this.header,
    required this.totalProgress,
    required this.budgetList,
    required this.budgetAlerts,
    super.key,
    this.bottomNavigation,
  });

  final Widget header;
  final Widget totalProgress;
  final Widget budgetList;
  final Widget budgetAlerts;
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
        MLHeroArea(padding: EdgeInsets.zero, child: totalProgress),
        MLSection(title: 'Budget Alert Center', child: budgetAlerts),
        MLSection(title: 'Enrolled Categories', child: budgetList),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        header,
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MLSpacing.pagePadding),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Total progress overview
                Expanded(
                  flex: 3,
                  child: MLSectionGroup(
                    children: [
                      totalProgress,
                      MLSection(
                        title: 'Budget Alert Center',
                        child: budgetAlerts,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Right Column: Category-specific lists
                Expanded(
                  flex: 4,
                  child: MLSection(
                    title: 'Enrolled Categories',
                    child: budgetList,
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
                // Column 1: Core aggregates
                Expanded(
                  flex: 3,
                  child: MLSectionGroup(
                    children: [
                      totalProgress,
                      MLSection(
                        title: 'Active Limits Summary',
                        child: const Text(
                          'Aggregate analysis of current budget execution parameters.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Column 2: Lists
                Expanded(
                  flex: 4,
                  child: MLSection(
                    title: 'Enrolled Categories',
                    child: budgetList,
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Column 3: Real-time alerts
                Expanded(
                  flex: 3,
                  child: MLSection(
                    title: 'Alert Center & Risks',
                    child: budgetAlerts,
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
