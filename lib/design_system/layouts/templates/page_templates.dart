import 'package:flutter/material.dart';
import '../../foundations/spacing.dart';
import '../base/scaffold.dart';
import '../page/page.dart';
import '../responsive/responsive_layout.dart';

/// MoneyLens Design System (MLDS) Wizard Layout.
///
/// Structures multi-step visual workflows (e.g. onboarding or CSV imports).
class MLWizardLayout extends StatelessWidget {
  const MLWizardLayout({
    required this.stepProgress,
    required this.stepContent,
    required this.actions,
    super.key,
    this.header,
  });

  final Widget? header;
  final Widget stepProgress;
  final Widget stepContent;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final headerWidget = header;
    return MLScaffold(
      body: MLSafeAreaLayout(
        child: Column(
          children: [
            ?headerWidget,
            Padding(
              padding: const EdgeInsets.all(MLSpacing.pagePadding),
              child: stepProgress,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MLSpacing.pagePadding,
                ),
                child: stepContent,
              ),
            ),
            MLStickyFooter(child: actions),
          ],
        ),
      ),
    );
  }
}

/// MoneyLens Design System (MLDS) Search Layout.
///
/// Layout optimized for entering text search queries and displaying filtered listings.
class MLSearchLayout extends StatelessWidget {
  const MLSearchLayout({
    required this.searchBar,
    required this.results,
    super.key,
    this.filterChips,
    this.emptyState,
    this.showEmptyState = false,
  });

  final Widget searchBar;
  final Widget? filterChips;
  final Widget results;
  final Widget? emptyState;
  final bool showEmptyState;

  @override
  Widget build(BuildContext context) {
    return MLScaffold(
      body: MLSafeAreaLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(MLSpacing.pagePadding),
              child: Column(
                children: [
                  searchBar,
                  if (filterChips != null) ...[
                    const SizedBox(height: MLSpacing.md),
                    filterChips!,
                  ],
                ],
              ),
            ),
            Expanded(
              child: showEmptyState && emptyState != null
                  ? Padding(
                      padding: const EdgeInsets.all(MLSpacing.pagePadding),
                      child: emptyState!,
                    )
                  : results,
            ),
          ],
        ),
      ),
    );
  }
}

/// MoneyLens Design System (MLDS) Empty State Layout.
///
/// Centers vector graphics, messaging, and actions for screens with no items.
class MLEmptyLayout extends StatelessWidget {
  const MLEmptyLayout({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
    this.actionButton,
  });

  final Widget icon;
  final String title;
  final String description;
  final Widget? actionButton;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(MLSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(opacity: 0.6, child: icon),
            const SizedBox(height: MLSpacing.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: MLSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            if (actionButton != null) ...[
              const SizedBox(height: MLSpacing.xxl),
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}

/// MoneyLens Design System (MLDS) Form Layout.
///
/// Arranges dynamic text fields and options with standard vertical rhythm.
class MLFormLayout extends StatelessWidget {
  const MLFormLayout({
    required this.fields,
    required this.actions,
    super.key,
    this.header,
  });

  final Widget? header;
  final List<Widget> fields;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final headerWidget = header;
    return MLScaffold(
      body: Column(
        children: [
          ?headerWidget,
          Expanded(
            child: MLScrollablePage(
              spacing: MLSpacing.formSpacing,
              children: fields,
            ),
          ),
          MLStickyFooter(child: actions),
        ],
      ),
    );
  }
}

/// MoneyLens Design System (MLDS) Report Layout.
///
/// Designed for documents, structured CSV export reviews, and monthly audits.
class MLReportLayout extends StatelessWidget {
  const MLReportLayout({
    required this.header,
    required this.metricsGrid,
    required this.visualCharts,
    required this.summaryText,
    super.key,
    this.bottomNavigation,
  });

  final Widget header;
  final Widget metricsGrid;
  final Widget visualCharts;
  final Widget summaryText;
  final Widget? bottomNavigation;

  @override
  Widget build(BuildContext context) {
    return MLScaffold(
      bottomNavigationBar: bottomNavigation,
      body: MLResponsiveContainer(
        phone: _buildPhoneLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildTabletLayout(context), // Shared structure for reports
      ),
    );
  }

  Widget _buildPhoneLayout(BuildContext context) {
    return MLScrollablePage(
      header: header,
      spacing: MLSpacing.xl,
      children: [
        metricsGrid,
        MLSection(title: 'Visual Representation', child: visualCharts),
        MLSection(title: 'Audit Summary', child: summaryText),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                metricsGrid,
                const SizedBox(height: MLSpacing.xxl),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: MLSection(
                        title: 'Visual Representation',
                        child: visualCharts,
                      ),
                    ),
                    const SizedBox(width: MLSpacing.xxl),
                    Expanded(
                      flex: 4,
                      child: MLSection(
                        title: 'Audit Summary',
                        child: summaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// MoneyLens Design System (MLDS) standard List Layout.
class MLListLayout extends StatelessWidget {
  const MLListLayout({
    required this.items,
    super.key,
    this.header,
    this.floatingActionButton,
    this.bottomNavigation,
  });

  final Widget? header;
  final List<Widget> items;
  final Widget? floatingActionButton;
  final Widget? bottomNavigation;

  @override
  Widget build(BuildContext context) {
    return MLScaffold(
      bottomNavigationBar: bottomNavigation,
      floatingActionButton: floatingActionButton,
      body: MLScrollablePage(
        header: header,
        spacing: MLSpacing.listSpacing,
        children: items,
      ),
    );
  }
}

/// MoneyLens Design System (MLDS) Detail Layout.
class MLDetailLayout extends StatelessWidget {
  const MLDetailLayout({
    required this.heroCard,
    required this.detailRows,
    required this.actions,
    super.key,
    this.header,
  });

  final Widget? header;
  final Widget heroCard;
  final Widget detailRows;
  final Widget actions;

  @override
  Widget build(BuildContext context) {
    final headerWidget = header;
    return MLScaffold(
      body: Column(
        children: [
          ?headerWidget,
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(MLSpacing.pagePadding),
              child: Column(
                children: [
                  heroCard,
                  const SizedBox(height: MLSpacing.xl),
                  detailRows,
                ],
              ),
            ),
          ),
          MLStickyFooter(child: actions),
        ],
      ),
    );
  }
}
