import 'package:flutter/material.dart';
import '../../foundations/spacing.dart';
import '../base/scaffold.dart';
import '../page/page.dart';
import '../responsive/responsive_layout.dart';

/// MoneyLens Design System (MLDS) Dashboard Layout.
///
/// A semantic slot-based page builder that physically structures the home dashboard.
/// Adapts columns dynamically for phone, tablet, and desktop viewports.
class MLDashboardLayout extends StatelessWidget {
  const MLDashboardLayout({
    required this.header,
    required this.balance,
    required this.quickActions,
    required this.budgets,
    required this.insights,
    required this.transactions,
    super.key,
    this.bottomNavigation,
  });

  final Widget header;
  final Widget balance;
  final Widget quickActions;
  final Widget budgets;
  final Widget insights;
  final Widget transactions;
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
        MLHeroArea(padding: EdgeInsets.zero, child: balance),
        quickActions,
        MLSection(title: 'Budgets', child: budgets),
        MLSection(title: 'Insights', child: insights),
        MLSection(title: 'Recent Activity', child: transactions),
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
                // Left Column: Core balances and transactions
                Expanded(
                  flex: 3,
                  child: MLSectionGroup(
                    children: [
                      MLHeroArea(padding: EdgeInsets.zero, child: balance),
                      MLSection(title: 'Recent Activity', child: transactions),
                    ],
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Right Column: Quick actions, budgets and insights
                Expanded(
                  flex: 2,
                  child: MLSectionGroup(
                    children: [
                      quickActions,
                      MLSection(title: 'Budgets', child: budgets),
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
                // Column 1: Financial Hero & Actions
                Expanded(
                  flex: 3,
                  child: MLSectionGroup(
                    children: [
                      MLHeroArea(padding: EdgeInsets.zero, child: balance),
                      quickActions,
                    ],
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Column 2: Budgeting and Insights
                Expanded(
                  flex: 3,
                  child: MLSectionGroup(
                    children: [
                      MLSection(title: 'Budgets', child: budgets),
                      MLSection(title: 'Insights', child: insights),
                    ],
                  ),
                ),
                const SizedBox(width: MLSpacing.xxl),
                // Column 3: Detailed Activity log workspace
                Expanded(
                  flex: 4,
                  child: MLSection(
                    title: 'Recent Activity Log',
                    child: transactions,
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
