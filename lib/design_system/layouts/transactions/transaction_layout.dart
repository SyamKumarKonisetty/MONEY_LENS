import 'package:flutter/material.dart';
import '../../foundations/spacing.dart';
import '../base/scaffold.dart';
import '../responsive/responsive_layout.dart';

/// MoneyLens Design System (MLDS) Transaction Layout.
///
/// Designed to list entries clearly while providing instant search and filters.
class MLTransactionLayout extends StatelessWidget {
  const MLTransactionLayout({
    required this.header,
    required this.searchBar,
    required this.filterBar,
    required this.transactionList,
    super.key,
    this.bottomNavigation,
  });

  final Widget header;
  final Widget searchBar;
  final Widget filterBar;
  final Widget transactionList;
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
    return Column(
      children: [
        header,
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MLSpacing.pagePadding,
          ),
          child: Column(
            children: [
              searchBar,
              const SizedBox(height: MLSpacing.md),
              filterBar,
            ],
          ),
        ),
        const SizedBox(height: MLSpacing.lg),
        Expanded(child: transactionList),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Column(
      children: [
        header,
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left sidebar filter view
              Container(
                width: 240.0,
                padding: const EdgeInsets.all(MLSpacing.pagePadding),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchBar,
                    const SizedBox(height: MLSpacing.xl),
                    Text(
                      'Filter By',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: MLSpacing.md),
                    Expanded(child: SingleChildScrollView(child: filterBar)),
                  ],
                ),
              ),
              // Right content list view
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(MLSpacing.pagePadding),
                  child: transactionList,
                ),
              ),
            ],
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Extended filter side-bar
              Container(
                width: 300.0,
                padding: const EdgeInsets.all(MLSpacing.pagePadding),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    searchBar,
                    const SizedBox(height: MLSpacing.xl),
                    Text(
                      'Refine List',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: MLSpacing.md),
                    Expanded(child: SingleChildScrollView(child: filterBar)),
                  ],
                ),
              ),
              // Wide transactional ledger workspace
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(MLSpacing.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audit Log & Ledger',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: MLSpacing.lg),
                      Expanded(child: transactionList),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
