import 'package:flutter/material.dart';
import '../../foundations/colors.dart';
import '../../foundations/spacing.dart';
import '../../components/text.dart';
import '../../components/primitives.dart';

// Import newly created layout constructs
import '../dashboard/dashboard_layout.dart';
import '../analytics/analytics_layout.dart';
import '../transactions/transaction_layout.dart';
import '../budget/budget_layout.dart';
import '../settings/settings_layout.dart';
import '../authentication/auth_layout.dart';
import 'package:money_lens/core/design/design_system.dart';

/// Layout Metadata structure to feed the Layout Inspector
class LayoutMetadata {
  const LayoutMetadata({
    required this.name,
    required this.purpose,
    required this.expectedComponents,
    required this.hierarchy,
    required this.responsiveRules,
    required this.spacingTokens,
    required this.motionSequence,
    required this.accessibilityNotes,
    required this.codeExample,
    required this.designGuidelines,
  });

  final String name;
  final String purpose;
  final String expectedComponents;
  final String hierarchy;
  final String responsiveRules;
  final String spacingTokens;
  final String motionSequence;
  final String accessibilityNotes;
  final String codeExample;
  final String designGuidelines;
}

final Map<String, LayoutMetadata> _layoutsMetadata = {
  'MLDashboardLayout': const LayoutMetadata(
    name: 'MLDashboardLayout',
    purpose:
        'Core application landing screen summarizing user accounts, quick actions, active budgets, real-time insights, and recent transactions.',
    expectedComponents:
        'MLAppBar, MLHeroBalance, MLQuickActions, MLActiveBudgets, MLInsightsCarousel, MLRecentTransactions, MLBottomNavigationBar.',
    hierarchy:
        '1. Financial Hero Area (Primary Focus)\n2. Primary Quick Actions\n3. Budgets & Real-time Insights (Secondary)\n4. Recent Ledger Logs (Supporting)',
    responsiveRules:
        'Phone: Stacked vertically.\nTablet: 2-column layout (Hero & Transactions left, Budgets & Insights right).\nDesktop: 3-column layout (Hero left, Budgets middle, Activity ledger right).',
    spacingTokens:
        'MLSpacing.pagePadding (20.0), MLSpacing.xl (20.0) vertical rhythm, MLSpacing.xxl (24.0) column separations.',
    motionSequence:
        '1. Hero area transitions first (Spring curve, 250ms)\n2. Quick action grid fade-in\n3. Budget progress stagger list slide\n4. Activity card fade entrance.',
    accessibilityNotes:
        'Screen reader focus flows top-to-bottom, left-to-right. Semantic labels exist for all interactive balance cards. Large text scaling preserves 3-column vertical wraps.',
    codeExample:
        'MLDashboardLayout(\n  header: const MLAppBar(title: "Home"),\n  balance: const MLHeroBalance(amount: 48520.50),\n  quickActions: const MLQuickActionsGrid(),\n  budgets: const MLActiveBudgetsList(),\n  insights: const MLInsightsCarousel(),\n  transactions: const MLRecentTransactionsList(),\n)',
    designGuidelines:
        'Do: Place only one primary Hero per page. Use consistent vertical spacing. Keep breathing room between columns.\nDon\'t: Overload the dashboard with dense data grids. Avoid nesting multiple scrolling elements without fixed viewports.',
  ),
  'MLAnalyticsLayout': const LayoutMetadata(
    name: 'MLAnalyticsLayout',
    purpose:
        'Aggregated financial charts, trend indicators, category spending breakdowns, and algorithmic insights.',
    expectedComponents:
        'MLAppBar, MLRangeSelector, MLTrendChart, MLCategoryList, MLInsightAlert.',
    hierarchy:
        '1. Range/Period Selector\n2. Trend Chart (Interactive workspace)\n3. Spending Distribution & Breakdown\n4. Algorithmic Recommendations',
    responsiveRules:
        'Phone: Vertically stacked elements.\nTablet: Side-by-side splits (Chart left, Breakdown and Insights list right).\nDesktop: Wide interactive analytics workspace with 3-pane layout.',
    spacingTokens:
        'MLSpacing.pagePadding (20.0), MLSpacing.xl (20.0), MLSpacing.xxl (24.0) pane spacing.',
    motionSequence:
        '1. Range selector slide-in\n2. Chart grid entry and line draws (600ms curve)\n3. Distribution charts scale up.',
    accessibilityNotes:
        'Screen readers read raw data summary tables first. Color-blind friendly color mappings on trend lines. Contrast ratio >= 4.5:1 on charts.',
    codeExample:
        'MLAnalyticsLayout(\n  header: const MLAppBar(title: "Analytics"),\n  rangeSelector: const MLPeriodToggle(),\n  primaryChart: const MLSynchronizedLineChart(),\n  breakdown: const MLCategoryBreakdownList(),\n  insights: const MLSavingInsightsPanel(),\n)',
    designGuidelines:
        'Do: Always provide clear axis markers. Use semantic emotional colors (e.g. green for stable, red for limit exceeded).\nDon\'t: Display more than 3 charts simultaneously. Avoid placing dense interactive maps without full pagination.',
  ),
  'MLTransactionLayout': const LayoutMetadata(
    name: 'MLTransactionLayout',
    purpose:
        'List of past transactions with search bar input and filter controls.',
    expectedComponents:
        'MLAppBar, MLSearchBar, MLFilterChips, MLTransactionList.',
    hierarchy:
        '1. Screen Header\n2. Search Inputs & Filter Triggers\n3. Scrollable Transaction Cards (Primary Focus)',
    responsiveRules:
        'Phone: Single column stacked listing.\nTablet/Desktop: Left-docked filter panel and right-scrolled transaction ledger.',
    spacingTokens:
        'MLSpacing.pagePadding (20.0), MLSpacing.md (12.0) search to chips, MLSpacing.lg (16.0) vertical scroll rhythm.',
    motionSequence:
        '1. Fade and slide search card\n2. Staggered list element entry animation (normal duration).',
    accessibilityNotes:
        'Transaction items read with date, description, category, and delta sign context. Search field supports keyboard actions and instant search screen announcement.',
    codeExample:
        'MLTransactionLayout(\n  header: const MLAppBar(title: "Transactions"),\n  searchBar: const MLSearchBar(),\n  filterBar: const MLFilterToggleBar(),\n  transactionList: const MLTransactionInfiniteList(),\n)',
    designGuidelines:
        'Do: Maintain chronological groupings. Keep filters sticky or collapsable on smaller mobile devices.\nDon\'t: Render infinite items without lazy loading. Do not hide total item count or active filter tags.',
  ),
  'MLBudgetLayout': const LayoutMetadata(
    name: 'MLBudgetLayout',
    purpose:
        'Tracking spending thresholds, progression rings, active budget parameters, and predictive runout triggers.',
    expectedComponents:
        'MLAppBar, MLBudgetProgressRing, MLBudgetListView, MLBudgetAlertTile.',
    hierarchy:
        '1. Aggregate Limit Progress (Primary Focus)\n2. Immediate Risks and Warning Indicators\n3. Component-level Budgets List',
    responsiveRules:
        'Phone: Stacked progress header and scrollable list.\nTablet/Desktop: Side-by-side representation with progress left and categories right.',
    spacingTokens:
        'MLSpacing.pagePadding (20.0), MLSpacing.xl (20.0) section rhythm, MLSpacing.cardPadding (16.0).',
    motionSequence:
        '1. Aggregate progress circle builds (stretching animated stroke)\n2. Alert banner slides down\n3. Category bars slide horizontally.',
    accessibilityNotes:
        'Percentage progress read clearly. Haptic feedback triggered on limit-exceeded entries. Screen reader announces budget warnings immediately upon load.',
    codeExample:
        'MLBudgetLayout(\n  header: const MLAppBar(title: "Budget"),\n  totalProgress: const MLBudgetRadialProgress(),\n  budgetList: const MLCategoryBudgetList(),\n  budgetAlerts: const MLBudgetRiskBanners(),\n)',
    designGuidelines:
        'Do: Position urgent risk elements close to the primary visual hierarchy. Ensure color is accompanied by text symbols.\nDon\'t: Overlay more than one progress ring at a time. Avoid dense lists without visual bars.',
  ),
  'MLSettingsLayout': const LayoutMetadata(
    name: 'MLSettingsLayout',
    purpose:
        'Standard app preference page structuring profile information, features config, and document resources.',
    expectedComponents:
        'MLAppBar, MLProfileHeader, MLSettingsGroup, MLComplianceFooter.',
    hierarchy:
        '1. User Profile Card\n2. Grouped preference panels\n3. App build version and privacy policy links (Supporting)',
    responsiveRules:
        'Phone: Stacked profile card and scrollable settings rows.\nTablet/Desktop: Left sidebar for profile summary, right panel for configuration categories.',
    spacingTokens:
        'MLSpacing.pagePadding (20.0), MLSpacing.xl (20.0) group splits, MLSpacing.formSpacing (20.0) row separations.',
    motionSequence:
        '1. Profile card fade-in\n2. Settings options slide vertically (Stagger sequence).',
    accessibilityNotes:
        'Settings list supports keyboard focus traversal and is labeled correctly for screen reader navigation.',
    codeExample:
        'MLSettingsLayout(\n  header: const MLAppBar(title: "Settings"),\n  profileCard: const MLUserProfileHeader(),\n  settingsTiles: const MLSettingsOptionsGroup(),\n  footer: const MLBuildVersionLabel(),\n)',
    designGuidelines:
        'Do: Group related settings under descriptive headers. Provide simple, instant toggle actions.\nDon\'t: Nest settings panels deeper than 2 levels. Avoid adding long forms directly on settings landing pages.',
  ),
  'MLAuthenticationLayout': const LayoutMetadata(
    name: 'MLAuthenticationLayout',
    purpose:
        'Secure entry screen showing brand logo, security PIN pad keys, and recovery parameters.',
    expectedComponents:
        'MLBrandingLogo, MLPinIndicatorField, MLNumericPinPadGrid, MLTextButton.',
    hierarchy:
        '1. Brand Identification (Logo)\n2. Security State Indicator (PIN bubbles)\n3. Input triggers (Keypad, Primary Focus)\n4. Password Recovery links (Supporting)',
    responsiveRules:
        'Phone: Centered vertical layout.\nTablet/Desktop: Split layout (Welcome/logo left, Pinpad/actions right).',
    spacingTokens:
        'MLSpacing.pagePadding (20.0), MLSpacing.xxl (24.0) keypad gaps, MLSpacing.giant (48.0) top logo spacing.',
    motionSequence:
        '1. Logo slides down gently\n2. Keypad buttons animate sequentially with fade scale (150ms).',
    accessibilityNotes:
        'Haptic feedback on keypad press. Security keypad announces key presses depending on user setting. Pin values are masked visually but read by screen readers using masked indicators.',
    codeExample:
        'MLAuthenticationLayout(\n  logo: const MLBrandLogoView(),\n  pinPad: const MLSecurityKeypad(),\n  recoveryActions: const MLPinRecoveryButtons(),\n)',
    designGuidelines:
        'Do: Keep layout completely centered on phones. Make touch targets large and readable.\nDon\'t: Show raw password strings. Avoid placing decorative graphics that distract from security input.',
  ),
};

/// Laboratory Playground layout showcasing FLS builders in action
class MLLayoutGallery extends StatefulWidget {
  const MLLayoutGallery({super.key});

  @override
  State<MLLayoutGallery> createState() => _MLLayoutGalleryState();
}

class _MLLayoutGalleryState extends State<MLLayoutGallery> {
  String _selectedLayout = 'MLDashboardLayout';
  String _simulatedDevice = 'Phone'; // Phone, Tablet, Desktop
  bool _gridOverlay = false;
  bool _spacingOverlay = false;
  bool _componentOverlay = false;
  bool _safeAreaOverlay = false;

  double _getSimulatedWidth() {
    switch (_simulatedDevice) {
      case 'Tablet':
        return 768.0;
      case 'Desktop':
        return 1000.0;
      case 'Phone':
      default:
        return 360.0;
    }
  }

  double _getSimulatedHeight() {
    switch (_simulatedDevice) {
      case 'Tablet':
        return 900.0;
      case 'Desktop':
        return 600.0;
      case 'Phone':
      default:
        return 640.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final metadata = _layoutsMetadata[_selectedLayout]!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header / Intro
          const Padding(
            padding: EdgeInsets.all(MLSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MLText.heading('MLDS Financial Layout Laboratory'),
                SizedBox(height: MLSpacing.sm),
                MLText.body(
                  'FLS defines how every MoneyLens screen is structured. '
                  'Use this simulator to preview responsive layout adapters and verify alignment overlay lines.',
                ),
              ],
            ),
          ),

          // Control Panel
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MLSpacing.pagePadding,
            ),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(MLSpacing.cardPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const MLText.dotLabel('Simulation Settings'),
                    const SizedBox(height: MLSpacing.md),
                    // Layout Dropdown
                    Row(
                      children: [
                        const Expanded(child: MLText.body('Layout Template:')),
                        DropdownButton<String>(
                          value: _selectedLayout,
                          items: _layoutsMetadata.keys.map((String key) {
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(
                                key,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedLayout = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: MLSpacing.sm),
                    // Device Dropdown
                    Row(
                      children: [
                        const Expanded(child: MLText.body('Device Type:')),
                        DropdownButton<String>(
                          value: _simulatedDevice,
                          items: ['Phone', 'Tablet', 'Desktop'].map((
                            String key,
                          ) {
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(
                                key,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _simulatedDevice = val;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    const MLText.dotLabel('Overlay Indicators'),
                    const SizedBox(height: MLSpacing.sm),
                    // Switch controls
                    Wrap(
                      spacing: MLSpacing.md,
                      runSpacing: MLSpacing.sm,
                      children: [
                        _buildOverlayToggle('Grid (Columns)', _gridOverlay, (
                          val,
                        ) {
                          setState(() => _gridOverlay = val);
                        }),
                        _buildOverlayToggle('Spacing Insets', _spacingOverlay, (
                          val,
                        ) {
                          setState(() => _spacingOverlay = val);
                        }),
                        _buildOverlayToggle('Slot Borders', _componentOverlay, (
                          val,
                        ) {
                          setState(() => _componentOverlay = val);
                        }),
                        _buildOverlayToggle(
                          'Safe Area Height',
                          _safeAreaOverlay,
                          (val) {
                            setState(() => _safeAreaOverlay = val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: MLSpacing.xl),

          // Simulator Render Box
          Center(
            child: Container(
              width: _getSimulatedWidth(),
              height: _getSimulatedHeight(),
              margin: const EdgeInsets.symmetric(
                horizontal: MLSpacing.pagePadding,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400, width: 4.0),
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Stack(
                  children: [
                    // Layout Simulator Canvas
                    Positioned.fill(child: _buildLayoutSimulationContent()),
                    // Overlay Canvas Layers
                    if (_spacingOverlay)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: _buildSpacingOverlayLayer(),
                        ),
                      ),
                    if (_gridOverlay)
                      Positioned.fill(
                        child: IgnorePointer(child: _buildGridOverlayLayer()),
                      ),
                    if (_componentOverlay)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: _buildComponentOverlayLayer(),
                        ),
                      ),
                    if (_safeAreaOverlay)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: _buildSafeAreaOverlayLayer(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: MLSpacing.xl),

          // Layout Inspector Metadata Panel
          Padding(
            padding: const EdgeInsets.all(MLSpacing.pagePadding),
            child: MLLayoutInspector(metadata: metadata),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayToggle(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: value,
      onSelected: onChanged,
      selectedColor: Colors.blue.withValues(alpha: 0.2),
    );
  }

  Widget _buildLayoutSimulationContent() {
    final mockHeader = Container(
      color: Colors.blue.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(MLSpacing.md),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.menu, size: 20),
          Text(
            'MoneyLens FLS Simulation',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Icon(Icons.notifications_outlined, size: 20),
        ],
      ),
    );

    final mediaQuerySimulated = MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(size: Size(_getSimulatedWidth(), _getSimulatedHeight())),
      child: _buildSimulatedBody(mockHeader),
    );

    return mediaQuerySimulated;
  }

  Widget _buildSimulatedBody(Widget mockHeader) {
    switch (_selectedLayout) {
      case 'MLDashboardLayout':
        return MLDashboardLayout(
          header: mockHeader,
          balance: _buildMockCard(
            'Primary Balance Hero',
            '₹ 4,85,200.50',
            Colors.green,
          ),
          quickActions: _buildMockActionsGrid(),
          budgets: _buildMockProgressList('Category Limit Trackers'),
          insights: _buildMockInsightAlert(
            'Insight Alert: Food expenses 12% lower than usual.',
          ),
          transactions: _buildMockTransactionsList(),
        );
      case 'MLAnalyticsLayout':
        return MLAnalyticsLayout(
          header: mockHeader,
          rangeSelector: _buildMockSelector('Analytics Range (Monthly)'),
          primaryChart: _buildMockChartArea(),
          breakdown: _buildMockProgressList('Distribution Breakdown'),
          insights: _buildMockInsightAlert(
            'Algorithmic Warning: Recurring subscriptions rising.',
          ),
        );
      case 'MLTransactionLayout':
        return MLTransactionLayout(
          header: mockHeader,
          searchBar: _buildMockInput('Search ledger records...'),
          filterBar: _buildMockSelector('Filters: Cash | Inflow | All'),
          transactionList: _buildMockTransactionsList(),
        );
      case 'MLBudgetLayout':
        return MLBudgetLayout(
          header: mockHeader,
          totalProgress: _buildMockCard(
            'Total Budget Enrolled',
            '64% Used',
            Colors.teal,
          ),
          budgetList: _buildMockProgressList('Enrolled Limits'),
          budgetAlerts: _buildMockInsightAlert(
            'Aggregated warning: Coffee budget 92% exhausted.',
          ),
        );
      case 'MLSettingsLayout':
        return MLSettingsLayout(
          header: mockHeader,
          profileCard: _buildMockCard(
            'Syam Vamshi Katari',
            'Student Account Profile',
            Colors.indigo,
          ),
          settingsTiles: _buildMockProgressList(
            'App settings group: Security, Backup, Sync',
          ),
          footer: const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'MLDS v1.0 • Project AURA',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ),
          ),
        );
      case 'MLAuthenticationLayout':
        return MLAuthenticationLayout(
          header: mockHeader,
          logo: const Column(
            children: [
              Icon(Icons.blur_on_rounded, size: 64, color: Colors.blue),
              SizedBox(height: 8),
              Text(
                'MONEYLENS SECURE ACCESS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          pinPad: _buildMockActionsGrid(),
          recoveryActions: const Text(
            'Forgot Secure PIN? Reset using recovery answers.',
            style: TextStyle(
              fontSize: 11,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      default:
        return const Center(child: Text('Layout Template Stub'));
    }
  }

  // Visual Mock Card builder
  Widget _buildMockCard(String title, String val, MaterialColor color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MLSpacing.cardPadding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            val,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Visual Mock Selector
  Widget _buildMockSelector(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.textMuted.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }

  // Visual Mock Input Field
  Widget _buildMockInput(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.textMuted.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.textMuted.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Text(hint, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
        ],
      ),
    );
  }

  // Visual Mock Actions Grid
  Widget _buildMockActionsGrid() {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.2,
      children: List.generate(4, (index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, size: 16, color: Colors.blue),
              const SizedBox(height: 4),
              Text('Action ${index + 1}', style: const TextStyle(fontSize: 9)),
            ],
          ),
        );
      }),
    );
  }

  // Visual Mock Chart area
  Widget _buildMockChartArea() {
    return Container(
      height: 120.0,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.purple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.show_chart, color: Colors.purple, size: 28),
            const SizedBox(height: 4),
            Text(
              'Simulated Trend Chart',
              style: TextStyle(color: Colors.purple.shade700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // Visual Mock progress bars list
  Widget _buildMockProgressList(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        _buildProgressBar('Groceries', 0.8),
        const SizedBox(height: 6),
        _buildProgressBar('Leisure', 0.4),
        const SizedBox(height: 6),
        _buildProgressBar('Rent', 1.0),
      ],
    );
  }

  Widget _buildProgressBar(String cat, double pct) {
    final color = pct >= 1.0
        ? Colors.red
        : (pct >= 0.7 ? Colors.amber : Colors.green);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(cat, style: const TextStyle(fontSize: 10)),
        ),
        Expanded(
          flex: 7,
          child: MLLinearProgress(
            value: pct,
            color: color,
          ),
        ),
      ],
    );
  }

  // Visual Mock Transaction Ledger
  Widget _buildMockTransactionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    child: Icon(Icons.shopping_bag, size: 10),
                  ),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mock Outlet Transaction',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Today • Food',
                        style: TextStyle(fontSize: 8, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                index % 2 == 0 ? '-₹240.00' : '+₹1500.0',
                style: TextStyle(
                  fontSize: 11,
                  color: index % 2 == 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Visual Mock Alert panel
  Widget _buildMockInsightAlert(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Grid columns overlay
  Widget _buildGridOverlayLayer() {
    final int cols = _simulatedDevice == 'Phone'
        ? 4
        : (_simulatedDevice == 'Tablet' ? 8 : 12);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final colWidth = w / cols;
        return Row(
          children: List.generate(cols, (index) {
            return Container(
              width: colWidth,
              height: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Colors.blue.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  right: index == cols - 1
                      ? BorderSide(
                          color: Colors.blue.withValues(alpha: 0.15),
                          width: 1,
                        )
                      : BorderSide.none,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Spacing Overlay
  Widget _buildSpacingOverlayLayer() {
    return Positioned.fill(
      child: Container(
        color: Colors.purple.withValues(alpha: 0.04),
        child: const Center(
          child: Text(
            'Spacing Overlay (Active)',
            style: TextStyle(
              color: Colors.purple,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Component slot boundaries
  Widget _buildComponentOverlayLayer() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1.5),
        ),
        child: const Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Text(
              'Slots Border Outline',
              style: TextStyle(
                color: Colors.red,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Safe area heights
  Widget _buildSafeAreaOverlayLayer() {
    return Column(
      children: [
        Container(
          height: 32.0,
          color: Colors.green.withValues(alpha: 0.2),
          child: const Center(
            child: Text(
              'Top Safe Area Inset (32dp)',
              style: TextStyle(
                color: Colors.green,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          height: 48.0,
          color: Colors.green.withValues(alpha: 0.2),
          child: const Center(
            child: Text(
              'Bottom Gesture Bar Inset (48dp)',
              style: TextStyle(
                color: Colors.green,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Layout Inspector widget showcasing metadata
class MLLayoutInspector extends StatelessWidget {
  const MLLayoutInspector({required this.metadata, super.key});

  final LayoutMetadata metadata;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      color: MLColors.surfaceVariant(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MLText.heading(metadata.name),
              const MLBadge(label: 'LAYOUT INSPECTOR'),
            ],
          ),
          const SizedBox(height: MLSpacing.md),
          MLText.body('Purpose: ${metadata.purpose}'),
          const Divider(height: 24),

          _buildSectionHeader('Expected Components'),
          MLText.caption(metadata.expectedComponents),
          const SizedBox(height: MLSpacing.md),

          _buildSectionHeader('Hierarchy'),
          Text(metadata.hierarchy, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: MLSpacing.md),

          _buildSectionHeader('Responsive Rules'),
          Text(metadata.responsiveRules, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: MLSpacing.md),

          _buildSectionHeader('Spacing Tokens'),
          Text(metadata.spacingTokens, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: MLSpacing.md),

          _buildSectionHeader('Motion Sequence'),
          Text(metadata.motionSequence, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: MLSpacing.md),

          _buildSectionHeader('Accessibility Notes'),
          MLText.caption(metadata.accessibilityNotes),
          const SizedBox(height: MLSpacing.md),

          _buildSectionHeader('Code Example'),
          const SizedBox(height: MLSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            color: Colors.black.withValues(alpha: 0.85),
            child: Text(
              metadata.codeExample,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontSize: 12,
                color: Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(height: MLSpacing.md),

          _buildSectionHeader('Design Guidelines'),
          Text(
            metadata.designGuidelines,
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Container(width: 4, height: 12, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
