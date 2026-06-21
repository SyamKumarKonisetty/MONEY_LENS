import 'package:flutter/material.dart';
import '../foundations/typography.dart';
import '../foundations/colors.dart';
import '../foundations/curves.dart';
import '../foundations/duration.dart';
import '../components/text.dart';
import '../components/money.dart';
import '../components/buttons.dart';
import '../components/composites.dart';
import '../components/financial.dart' hide MLForecastCard, MLInsightCard;
import '../animations/number_scroller.dart';
import '../animations/haptics.dart';
import '../animations/transitions.dart';
import 'inspector.dart';
import '../layouts/playground/layout_gallery.dart';
import '../components/charts.dart';
import '../components/timelines.dart';
import '../components/insights_components.dart';
import '../foundations/insights.dart';
import 'package:money_lens/core/design/design_system.dart';

/// MLDS Internal Design Playground Gallery.
///
/// Under Project AURA, this gallery acts as a developer laboratory where every
/// component variant can be previewed independently.
class MLDSGalleryScreen extends StatefulWidget {
  const MLDSGalleryScreen({super.key});

  @override
  State<MLDSGalleryScreen> createState() => _MLDSGalleryScreenState();
}

class _MLDSGalleryScreenState extends State<MLDSGalleryScreen>
    with TickerProviderStateMixin {
  static const _currencies = ['\u20B9', '\u0024', '\u20AC', '\u00A5'];
  String _activeCurrency = '\u20B9';
  double _testAmount = 48520.50;
  bool _isDarkPreview = true;
  bool _showSign = false;

  // Color Lab States
  double _budgetProgress = 0.50;
  DateTime _seasonDate = DateTime.now();

  // Motion Lab States
  bool _reducedMotionActive = false;

  // FIS Lab States
  MLChartState _fisState = MLChartState.render;
  MLChartEmptyType _fisEmptyType = MLChartEmptyType.noData;
  double _simulatedTransactionCount = 100.0;
  bool _highContrastMode = false;
  bool _colorBlindnessMode = false;

  // Component Lab States
  String _selectedComponentToInspect = 'MLButton';

  late AnimationController _buttonPressController;
  late AnimationController _cardLiftController;
  late AnimationController _coinDropController;
  late AnimationController _receiptFoldController;
  late AnimationController _shimmerController;
  late AnimationController _breathingRingController;

  late Animation<double> _buttonScale;
  late Animation<double> _cardTranslation;
  late Animation<double> _cardScale;
  late Animation<double> _cardShadow;
  late Animation<double> _coinTranslation;
  late Animation<double> _coinScale;
  late Animation<double> _coinOpacity;
  late Animation<double> _receiptFoldScale;
  late Animation<double> _receiptFoldOpacity;
  late Animation<double> _shimmerOpacity;
  late Animation<double> _ringBreath;

  @override
  void initState() {
    super.initState();

    // 1. Button Press Spring Back
    _buttonPressController = AnimationController(
      vsync: this,
      duration: MLDuration.fast,
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(
        parent: _buttonPressController,
        curve: MLCurves.springBack,
      ),
    );

    // 2. Card Lift & Hover
    _cardLiftController = AnimationController(
      vsync: this,
      duration: MLDuration.normal,
    );
    _cardTranslation = Tween<double>(begin: 0.0, end: -4.0).animate(
      CurvedAnimation(parent: _cardLiftController, curve: MLCurves.standard),
    );
    _cardScale = Tween<double>(begin: 1.0, end: 1.01).animate(
      CurvedAnimation(parent: _cardLiftController, curve: MLCurves.standard),
    );
    _cardShadow = Tween<double>(begin: 4.0, end: 16.0).animate(
      CurvedAnimation(parent: _cardLiftController, curve: MLCurves.standard),
    );

    // 3. FML Income Coin Drop
    _coinDropController = AnimationController(
      vsync: this,
      duration: MLDuration.coinDrop,
    );
    _coinTranslation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _coinDropController,
        curve: MLCurves.coinDropBounce,
      ),
    );
    _coinScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _coinDropController,
        curve: MLCurves.coinDropBounce,
      ),
    );
    _coinOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _coinDropController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // 4. FML Expense Receipt Fold
    _receiptFoldController = AnimationController(
      vsync: this,
      duration: MLDuration.receiptFold,
    );
    _receiptFoldScale = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _receiptFoldController,
        curve: MLCurves.receiptFoldCurve,
      ),
    );
    _receiptFoldOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _receiptFoldController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // 5. Skeleton Load Shimmer Breathing
    _shimmerController = AnimationController(
      vsync: this,
      duration: MLDuration.skeletonShimmer,
    )..repeat(reverse: true);
    _shimmerOpacity = Tween<double>(begin: 0.3, end: 0.65).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // 6. Living Ring Breath
    _breathingRingController = AnimationController(
      vsync: this,
      duration: MLDuration.livingRingBreath,
    )..repeat(reverse: true);
    _ringBreath = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _breathingRingController,
        curve: MLCurves.livingRingEase,
      ),
    );
  }

  @override
  void dispose() {
    _buttonPressController.dispose();
    _cardLiftController.dispose();
    _coinDropController.dispose();
    _receiptFoldController.dispose();
    _shimmerController.dispose();
    _breathingRingController.dispose();
    super.dispose();
  }

  void _randomizeAmount() {
    setState(() {
      _testAmount = (_testAmount == 48520.50) ? -124900.75 : 48520.50;
    });
  }

  void _toggleReducedMotion(bool value) {
    setState(() {
      _reducedMotionActive = value;
      MLHaptics.setReducedMotion(value);
      MLTransitions.setReducedMotion(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('MLDS Project AURA Laboratory'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.font_download), text: 'Typography Lab'),
              Tab(icon: Icon(Icons.palette), text: 'Color Lab'),
              Tab(icon: Icon(Icons.animation), text: 'Motion Lab'),
              Tab(icon: Icon(Icons.layers), text: 'Component Lab'),
              Tab(icon: Icon(Icons.grid_view), text: 'Layout Lab'),
              Tab(icon: Icon(Icons.analytics_rounded), text: 'Financial Lab'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTypographyLab(context),
            _buildColorLab(context),
            _buildMotionLab(context),
            _buildComponentLab(context),
            const MLLayoutGallery(),
            _buildFinancialLab(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTypographyLab(BuildContext context) {
    final previewBg = _isDarkPreview ? Colors.black : AppColors.textPrimary;
    final previewText = _isDarkPreview ? AppColors.textPrimary : Colors.black;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.heading('Financial Typography Laboratory'),
          const SizedBox(height: 8.0),
          const MLText.body(
            'Test and preview Project AURA typographic tokens, weight hierarchies, '
            'and tabular alignment rules in isolation.',
          ),
          const SizedBox(height: 24.0),

          // Interactive Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MLText.dotLabel('Preview Controls'),
                  const SizedBox(height: 12.0),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isDarkPreview = !_isDarkPreview;
                          });
                        },
                        child: Text(
                          _isDarkPreview ? 'Light Preview' : 'Dark Preview',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _randomizeAmount,
                        child: const Text('Toggle Amount Sign'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showSign = !_showSign;
                          });
                        },
                        child: Text(_showSign ? 'Hide Signs' : 'Show Signs'),
                      ),
                      DropdownButton<String>(
                        value: _activeCurrency,
                        items: _currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _activeCurrency = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Theme Canvas Preview
          const MLText.dotLabel('Typography Render Canvas'),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: previewBg,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.textMuted.withAlpha(76)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Display Stubs
                MLText.dotLabel(
                  'FTS Hero Balance',
                  color: previewText.withAlpha(128),
                ),
                const SizedBox(height: 8.0),
                MLMoneyDisplay.hero(
                  amount: _testAmount,
                  currency: _activeCurrency,
                  color: previewText,
                  showSign: _showSign,
                ),
                const SizedBox(height: 20.0),

                MLText.dotLabel(
                  'FTS Standard Ledger List',
                  color: previewText.withAlpha(128),
                ),
                const SizedBox(height: 8.0),
                MLMoneyDisplay.standard(
                  amount: 48520.50,
                  currency: _activeCurrency,
                  showSign: _showSign,
                ),
                const SizedBox(height: 6.0),
                MLMoneyDisplay.standard(
                  amount: -1250.00,
                  currency: _activeCurrency,
                  showSign: _showSign,
                ),
                const SizedBox(height: 20.0),

                MLText.dotLabel(
                  'Odometer Animation Roll Preview',
                  color: previewText.withAlpha(128),
                ),
                const SizedBox(height: 8.0),
                MLAnimatedNumber(
                  value: _testAmount,
                  style: MLTypography.heroAmount.copyWith(color: previewText),
                  currency: _activeCurrency,
                ),
                const SizedBox(height: 24.0),
                const Divider(),
                const SizedBox(height: 12.0),

                // General Scale
                MLText.dotLabel(
                  'Semantic Scale',
                  color: previewText.withAlpha(128),
                ),
                const SizedBox(height: 12.0),
                MLText.heroAmount('Display XL 48', color: previewText),
                const SizedBox(height: 8.0),
                MLText.balance('Display Large 36', color: previewText),
                const SizedBox(height: 8.0),
                MLText.heading('Heading Large 20', color: previewText),
                const SizedBox(height: 8.0),
                MLText.body(
                  'Body Medium 14 text copy is legible.',
                  color: previewText,
                ),
                const SizedBox(height: 8.0),
                MLText.caption(
                  'Caption 11 secondary details.',
                  color: previewText,
                ),
                const SizedBox(height: 8.0),
                MLText.dotLabel('Dot Label 11 uppercase', color: previewText),
                const SizedBox(height: 8.0),
                MLText.badge('BADGE 10', color: previewText),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Tabular Figure Comparison Grid
          const MLText.dotLabel('Tabular vs Proportional Figure Test'),
          const SizedBox(height: 8.0),
          Table(
            border: TableBorder.all(color: AppColors.textMuted.withAlpha(51)),
            children: [
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: MLText.dotLabel('Font Feature Tabular'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '111111.11\n888888.88',
                      style: MLTypography.moneyMedium.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: MLText.dotLabel('Standard Proportional'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '111111.11\n888888.88',
                      style: MLTypography.bodyMedium.copyWith(height: 1.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  Widget _buildColorLab(BuildContext context) {
    final scaleColor = MLColors.budgetScaleColor(context, _budgetProgress);
    final seasonOverlayColor = MLColors.seasonColor(context, _seasonDate);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.heading('Emotional Color Laboratory'),
          const SizedBox(height: 8.0),
          const MLText.body(
            'ECS preview environment. Inspect semantic surface stacking, budget emotional '
            'sweeps, calendar-based seasons, and accessibility metrics.',
          ),
          const SizedBox(height: 24.0),

          // 1. Semantic Color Swatches Grid
          const MLText.dotLabel('Semantic Palette'),
          const SizedBox(height: 8.0),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 1.2,
            children: [
              _buildColorSwatch(context, 'Primary', MLColors.primary(context)),
              _buildColorSwatch(
                context,
                'Secondary',
                MLColors.secondary(context),
              ),
              _buildColorSwatch(context, 'Income', MLColors.income(context)),
              _buildColorSwatch(context, 'Expense', MLColors.expense(context)),
              _buildColorSwatch(context, 'Budget', MLColors.budget(context)),
              _buildColorSwatch(context, 'Savings', MLColors.glass(context)),
              _buildColorSwatch(context, 'Success', MLColors.success(context)),
              _buildColorSwatch(context, 'Warning', MLColors.warning(context)),
              _buildColorSwatch(context, 'Error', MLColors.error(context)),
            ],
          ),
          const SizedBox(height: 24.0),

          // 2. Interactive Budget Emotion Scale
          const MLText.dotLabel('Interactive Budget Emotion Sweep'),
          const SizedBox(height: 8.0),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MLText.body(
                        'Progression: ${(_budgetProgress * 100).toStringAsFixed(0)}%',
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: scaleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _budgetProgress,
                    max: 1.2,
                    onChanged: (val) {
                      setState(() {
                        _budgetProgress = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8.0),
                  MLText.caption(
                    _budgetProgress <= 0.40
                        ? '0-40%: Safe, Cool (Structured cyan)'
                        : _budgetProgress <= 0.70
                        ? '40-70%: Stable, Balanced (Steady green)'
                        : _budgetProgress <= 0.85
                        ? '70-85%: Attention Needed (Amber warning)'
                        : _budgetProgress <= 1.00
                        ? '85-100%: Careful Preparation (Muted orange)'
                        : '100%+: Budget Exceeded (Respectful red)',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // 3. Surface System & Layers
          const MLText.dotLabel('Surface Elevation Hierarchy'),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: MLColors.background(context),
            child: Column(
              children: [
                _buildSurfaceLayer(
                  context,
                  'Background (0dp)',
                  MLColors.background(context),
                ),
                const SizedBox(height: 8.0),
                _buildSurfaceLayer(
                  context,
                  'Surface Card (1dp)',
                  MLColors.surfaceCard(context),
                ),
                const SizedBox(height: 8.0),
                _buildSurfaceLayer(
                  context,
                  'Surface Navigation',
                  MLColors.surfaceNavigation(context),
                ),
                const SizedBox(height: 8.0),
                _buildSurfaceLayer(
                  context,
                  'Surface Bottom Sheet',
                  MLColors.surfaceBottomSheet(context),
                ),
                const SizedBox(height: 8.0),
                _buildSurfaceLayer(
                  context,
                  'Surface Dialog',
                  MLColors.surfaceDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // 4. Financial Seasons
          const MLText.dotLabel('Financial Monthly Seasons'),
          const SizedBox(height: 8.0),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MLText.body('Selected Day: ${_seasonDate.day}'),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(
                          () => _seasonDate = DateTime(
                            _seasonDate.year,
                            _seasonDate.month,
                            5,
                          ),
                        ),
                        child: const Text('Day 5 (Fresh)'),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () => setState(
                          () => _seasonDate = DateTime(
                            _seasonDate.year,
                            _seasonDate.month,
                            15,
                          ),
                        ),
                        child: const Text('Day 15 (Stable)'),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () => setState(
                          () => _seasonDate = DateTime(
                            _seasonDate.year,
                            _seasonDate.month,
                            25,
                          ),
                        ),
                        child: const Text('Day 25 (Review)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: AppColors.textMuted.withAlpha(51)),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(color: MLColors.background(context)),
                        ),
                        Positioned.fill(
                          child: Container(color: seasonOverlayColor),
                        ),
                        const Center(
                          child: MLText.dotLabel(
                            'Seasonal Tint Preview Overlay',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // 5. Component States Preview
          const MLText.dotLabel('Standard Component States'),
          const SizedBox(height: 8.0),
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              _buildStateChip('Idle', AppColors.textMuted),
              _buildStateChip('Hover', MLColors.primary(context)),
              _buildStateChip(
                'Pressed',
                MLColors.primary(context).withAlpha(150),
              ),
              _buildStateChip(
                'Focused',
                MLColors.primary(context),
                hasOutline: true,
              ),
              _buildStateChip('Disabled', AppColors.textMuted.withAlpha(97)),
            ],
          ),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  Widget _buildMotionLab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.heading('Financial Interaction Laboratory'),
          const SizedBox(height: 8.0),
          const MLText.body(
            'FIL preview environment. Test button scale animations, elastic cards, '
            'FML triggers, and native haptic clicks in isolation.',
          ),
          const SizedBox(height: 24.0),

          // Accessibility Reduced Motion Switch
          Card(
            child: SwitchListTile(
              title: const MLText.body('Reduced Motion (Accessibility)'),
              subtitle: const MLText.caption(
                'Substitutes slide/spring parameters with soft fades.',
              ),
              value: _reducedMotionActive,
              onChanged: _toggleReducedMotion,
            ),
          ),
          const SizedBox(height: 24.0),

          // 1. Button Press Spring Physics Preview
          const MLText.dotLabel('Button Physics (Spring Back)'),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTapDown: (_) {
              if (!_reducedMotionActive) _buttonPressController.forward();
              MLHaptics.light();
            },
            onTapUp: (_) {
              if (!_reducedMotionActive) _buttonPressController.reverse();
            },
            onTapCancel: () {
              if (!_reducedMotionActive) _buttonPressController.reverse();
            },
            onTap: () {},
            child: ScaleTransition(
              scale: _buttonScale,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: MLColors.primary(context),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: MLText.dotLabel(
                    'Press to Compress',
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // 2. Card Lift on Hover/Touch
          const MLText.dotLabel('Card Physics (Elevation Lift)'),
          const SizedBox(height: 8.0),
          GestureDetector(
            onPanStart: (_) {
              if (!_reducedMotionActive) _cardLiftController.forward();
              MLHaptics.selection();
            },
            onPanEnd: (_) {
              if (!_reducedMotionActive) _cardLiftController.reverse();
            },
            child: AnimatedBuilder(
              animation: _cardLiftController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0.0, _cardTranslation.value),
                  child: Transform.scale(
                    scale: _cardScale.value,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: MLColors.surfaceCard(context),
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(
                              (_cardShadow.value * (_isDarkPreview ? 3 : 1))
                                  .round(),
                            ),
                            offset: Offset(0.0, _cardShadow.value / 2),
                            blurRadius: _cardShadow.value * 1.5,
                          ),
                        ],
                        border: Border.all(color: AppColors.textMuted.withAlpha(51)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MLText.dotLabel('Draggable Surface'),
                          SizedBox(height: 8.0),
                          MLText.body(
                            'Hold and drag to lift card. Relies on physics shadow scaling.',
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24.0),

          // 3. FML Coin Drop Preview
          const MLText.dotLabel('FML: Income Coin Drop'),
          const SizedBox(height: 8.0),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: double.infinity,
                        color: Colors.transparent,
                      ),
                      AnimatedBuilder(
                        animation: _coinDropController,
                        builder: (context, child) {
                          return Positioned(
                            top: 50.0 + _coinTranslation.value,
                            child: Opacity(
                              opacity: _coinOpacity.value,
                              child: Transform.scale(
                                scale: _coinScale.value,
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF30D158),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.currency_rupee,
                                    color: AppColors.textPrimary,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      _coinDropController.forward(from: 0.0);
                      MLHaptics.success();
                    },
                    child: const Text('Simulate Coin Drop'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // 4. FML Receipt Fold Preview
          const MLText.dotLabel('FML: Expense Receipt Fold'),
          const SizedBox(height: 8.0),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _receiptFoldController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _receiptFoldOpacity.value,
                        child: Transform(
                          transform: Matrix4.diagonal3Values(
                            1.0,
                            _receiptFoldScale.value,
                            1.0,
                          )..setEntry(3, 2, 0.001), // perspective
                          alignment: Alignment.topCenter,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      color: AppColors.textMuted.withAlpha(38),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MLText.dotLabel('RECEIPT #8059'),
                          SizedBox(height: 6.0),
                          MLText.body('Grocery shopping - ₹1,250.00'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _receiptFoldController.forward(from: 0.0);
                          MLHaptics.medium();
                        },
                        child: const Text('Fold Receipt'),
                      ),
                      const SizedBox(width: 8.0),
                      TextButton(
                        onPressed: () {
                          _receiptFoldController.reverse();
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // 5. Living Ring Breathing Progress
          const MLText.dotLabel('FML: Living Ring Pulse'),
          const SizedBox(height: 8.0),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: AnimatedBuilder(
                  animation: _breathingRingController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _ringBreath.value,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: MLColors.budget(context),
                            width: 8.0,
                          ),
                        ),
                        child: const Center(child: Text('70%')),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // 6. Shimmer Loading Skeletons
          const MLText.dotLabel('Loading Skeletons (Breathing Loop)'),
          const SizedBox(height: 8.0),
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Opacity(
                opacity: _shimmerOpacity.value,
                child: Column(
                  children: [
                    _buildSkeletonBar(120),
                    const SizedBox(height: 8.0),
                    _buildSkeletonBar(double.infinity),
                    const SizedBox(height: 8.0),
                    _buildSkeletonBar(200),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24.0),

          // 7. Native Haptics Player
          const MLText.dotLabel('Haptic Feedback Laboratory'),
          const SizedBox(height: 8.0),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  ElevatedButton(
                    onPressed: MLHaptics.light,
                    child: const Text('Light'),
                  ),
                  ElevatedButton(
                    onPressed: MLHaptics.medium,
                    child: const Text('Medium'),
                  ),
                  ElevatedButton(
                    onPressed: MLHaptics.heavy,
                    child: const Text('Heavy'),
                  ),
                  ElevatedButton(
                    onPressed: MLHaptics.selection,
                    child: const Text('Selection'),
                  ),
                  ElevatedButton(
                    onPressed: MLHaptics.success,
                    child: const Text('Success'),
                  ),
                  ElevatedButton(
                    onPressed: MLHaptics.warning,
                    child: const Text('Warning'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40.0),
        ],
      ),
    );
  }

  Widget _buildComponentLab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.heading('FCS Component Laboratory'),
          const SizedBox(height: 8.0),
          const MLText.body(
            'Select any design system component below to review its visual mockup '
            'and inspect its underlying token specifications and accessibility notes.',
          ),
          const SizedBox(height: 24.0),

          // Component Selector Dropdown
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const MLText.body('Select Component:'),
                  DropdownButton<String>(
                    value: _selectedComponentToInspect,
                    items: <String>['MLButton', 'MLAppBar', 'MLHeroBalance']
                        .map((val) {
                          return DropdownMenuItem<String>(
                            value: val,
                            child: Text(val),
                          );
                        })
                        .toList(),
                    onChanged: (newVal) {
                      if (newVal != null) {
                        setState(() {
                          _selectedComponentToInspect = newVal;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24.0),

          // Live Preview Area
          const MLText.dotLabel('Live Component Preview'),
          const SizedBox(height: 8.0),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: MLColors.surfaceCard(context),
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: AppColors.textMuted.withAlpha(51)),
            ),
            child: Center(child: _buildInspectedComponentPreview()),
          ),
          const SizedBox(height: 24.0),

          // Inspector Panel
          _buildComponentInspectorPanel(),
        ],
      ),
    );
  }

  Widget _buildInspectedComponentPreview() {
    switch (_selectedComponentToInspect) {
      case 'MLButton':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MLButton.primary(label: 'Primary Action', onPressed: () {}),
          ],
        );
      case 'MLAppBar':
        return const SizedBox(
          width: double.infinity,
          height: 60,
          child: MLAppBar(title: 'Preview App Bar'),
        );
      case 'MLHeroBalance':
        return const MLHeroBalance(amount: 48520.50, currency: '₹');
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildComponentInspectorPanel() {
    switch (_selectedComponentToInspect) {
      case 'MLButton':
        return const MLComponentInspector(
          componentName: 'MLButton.primary',
          purpose:
              'Triggers the main action on a page with high semantic emphasis.',
          codeExample:
              "MLButton.primary(\n  label: 'Save Transaction',\n  onPressed: () {},\n)",
          typographyToken: 'MLTypography.button',
          colorToken: 'MLColors.primary',
          spacingToken: 'MLSpacing.buttonPadding',
          radiusToken: 'MLRadius.large',
          shadowToken: 'MLShadow.soft',
          accessibilityNotes:
              'Minimum touch target size of 48x48 dp. Focus outline indicator supported.',
        );
      case 'MLAppBar':
        return const MLComponentInspector(
          componentName: 'MLAppBar',
          purpose: 'Structural header enclosing screen context and actions.',
          codeExample: 'const MLAppBar(\n  title: \'Settings\',\n)',
          typographyToken: 'MLTypography.headingLarge',
          colorToken: 'MLColors.surfaceNavigation',
          spacingToken: 'MLSpacing.pagePadding',
          radiusToken: 'MLRadius.none',
          shadowToken: 'MLShadow.none',
          accessibilityNotes:
              'Semantics Node registered as Header. Contrast ratio WCAG 4.5:1 confirmed.',
        );
      case 'MLHeroBalance':
        return const MLComponentInspector(
          componentName: 'MLHeroBalance',
          purpose:
              'High priority balance summation displayed at the top of screens.',
          codeExample:
              'const MLHeroBalance(\n  amount: 48520.50,\n  currency: \'₹\',\n)',
          typographyToken: 'MLTypography.heroAmount',
          colorToken: 'MLColors.textPrimary',
          spacingToken: 'MLSpacing.pagePadding',
          radiusToken: 'MLRadius.none',
          shadowToken: 'MLShadow.none',
          accessibilityNotes:
              'Uses Tabular Figures to align digits. Screen Reader pronounces full decimal amounts.',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSkeletonBar(double width) {
    return Container(
      height: 16.0,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.textMuted.withAlpha(97),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  Widget _buildColorSwatch(BuildContext context, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.textMuted.withAlpha(51)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MLText.dotLabel(
              label,
              color: color.computeLuminance() > 0.5
                  ? Colors.black
                  : AppColors.textPrimary,
            ),
            const SizedBox(height: 4.0),
            Text(
              '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
              style: TextStyle(
                fontSize: 10,
                color: color.computeLuminance() > 0.5
                    ? Colors.black.withAlpha(150)
                    : AppColors.textPrimary.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurfaceLayer(BuildContext context, String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: AppColors.textMuted.withAlpha(51)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MLText.body(
            label,
            color: color.computeLuminance() > 0.5 ? Colors.black : AppColors.textPrimary,
          ),
          Text(
            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: TextStyle(
              fontSize: 11,
              color: color.computeLuminance() > 0.5
                  ? Colors.black.withAlpha(150)
                  : AppColors.textPrimary.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateChip(String label, Color color, {bool hasOutline = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: hasOutline ? Colors.transparent : color,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: hasOutline ? color : AppColors.textMuted.withAlpha(51),
          width: hasOutline ? 2.0 : 1.0,
        ),
      ),
      child: MLText.caption(
        label,
        color: hasOutline
            ? color
            : (color.computeLuminance() > 0.5 ? Colors.black : AppColors.textPrimary),
      ),
    );
  }

  // ─── Financial Information System (FIS) Laboratory ─────────────────────────

  Widget _buildFinancialLab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.heading('Financial Information System (FIS) Lab'),
          const SizedBox(height: 8.0),
          const MLText.body(
            'Interactive testing suite for charts, timelines, storytelling components, '
            'trend resolving engines, and accessibility options.',
          ),
          const SizedBox(height: 24.0),

          // Control Dashboard
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MLText.dotLabel('State & Simulator Controls'),
                  const SizedBox(height: 16.0),

                  // Component State Selector
                  const MLText.caption('Visualization State:'),
                  const SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      ChoiceChip(
                        label: const Text('Render'),
                        selected: _fisState == MLChartState.render,
                        onSelected: (val) =>
                            setState(() => _fisState = MLChartState.render),
                      ),
                      ChoiceChip(
                        label: const Text('Loading (Skeletons)'),
                        selected: _fisState == MLChartState.loading,
                        onSelected: (val) =>
                            setState(() => _fisState = MLChartState.loading),
                      ),
                      ChoiceChip(
                        label: const Text('Empty State'),
                        selected: _fisState == MLChartState.empty,
                        onSelected: (val) =>
                            setState(() => _fisState = MLChartState.empty),
                      ),
                    ],
                  ),

                  if (_fisState == MLChartState.empty) ...[
                    const SizedBox(height: 12.0),
                    const MLText.caption('Select Empty Type:'),
                    DropdownButton<MLChartEmptyType>(
                      value: _fisEmptyType,
                      items: MLChartEmptyType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.name),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setState(() => _fisEmptyType = newVal);
                        }
                      },
                    ),
                  ],

                  const Divider(height: 24.0),

                  // Data Size Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const MLText.caption('Simulated Transactions:'),
                      MLText.dotLabel(
                        '${_simulatedTransactionCount.round()} logs',
                      ),
                    ],
                  ),
                  Slider(
                    value: _simulatedTransactionCount,
                    min: 10,
                    max: 100000,
                    divisions: 4,
                    label: '${_simulatedTransactionCount.round()}',
                    onChanged: (val) {
                      setState(() => _simulatedTransactionCount = val);
                    },
                  ),

                  const Divider(height: 24.0),

                  // Accessibility simulation toggles
                  const MLText.caption('Accessibility Filters:'),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Switch(
                        value: _highContrastMode,
                        onChanged: (val) =>
                            setState(() => _highContrastMode = val),
                      ),
                      const SizedBox(width: 8.0),
                      const MLText.caption('Simulate High Contrast'),
                      const SizedBox(width: 24.0),
                      Switch(
                        value: _colorBlindnessMode,
                        onChanged: (val) =>
                            setState(() => _colorBlindnessMode = val),
                      ),
                      const SizedBox(width: 8.0),
                      const MLText.caption('Simulate Color Blindness'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24.0),

          // Simulated Filters Warning Overlay
          if (_highContrastMode || _colorBlindnessMode)
            Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: MLColors.warning(context).withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: MLColors.warning(context),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.accessibility_new_rounded,
                    color: MLColors.warning(context),
                    size: 18,
                  ),
                  const SizedBox(width: 8.0),
                  const Expanded(
                    child: Text(
                      'Accessibility filters active. Colors are adjusted for accessibility standards.',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),

          const MLText.dotLabel(
            'Tap any element below to open the Information Inspector',
          ),
          const SizedBox(height: 16.0),

          // 1. Metric Cards & Trend Indicators
          const MLText.heading('Metric Cards & Trends'),
          const SizedBox(height: 12.0),
          MLStatGrid(
            cards: [
              MLMetricCard(
                title: 'Total Balance',
                value: '₹48,520.50',
                trendText: '18% less vs last week',
                isPositiveTrend: false,
                sparklinePoints: const [54000, 52000, 50000, 48520.50],
              ),
              MLMetricCard(
                title: 'Savings Progress',
                value: '₹14,500.00',
                trendText: '4.5% up vs target',
                isPositiveTrend: true,
                sparklinePoints: const [10000, 12000, 13500, 14500],
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          GestureDetector(
            onTap: () => _showFisInspector(context, 'MLMetricCard'),
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Inspect Metric Card API',
                    style: TextStyle(
                      color: MLColors.primary(context),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 10,
                    color: MLColors.primary(context),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 32.0),

          // 2. Storytelling & Dynamic Insights
          const MLText.heading('Storytelling & Dynamic Insights'),
          const SizedBox(height: 12.0),
          GestureDetector(
            onTap: () => _showFisInspector(context, 'MLFinancialStory'),
            child: const MLFinancialStory(
              storyText:
                  'You spent 18% less on Entertainment this weekend compared to your average. Keep it up!',
              actionLabel: 'View breakdown',
            ),
          ),
          const SizedBox(height: 12.0),
          GestureDetector(
            onTap: () => _showFisInspector(context, 'MLForecastCard'),
            child: const MLForecastCard(
              predictedSpend: 54000,
              limit: 50000,
              daysRemaining: 10,
              currentVelocity: 1800,
            ),
          ),
          const SizedBox(height: 12.0),
          GestureDetector(
            onTap: () => _showFisInspector(context, 'MLInsightCard'),
            child: MLInsightCard(
              insight: MLInsight(
                id: '1',
                type: MLInsightType.budgetRisk,
                severity: MLInsightSeverity.warning,
                title: 'Budget Threshold Risk',
                message:
                    'Your Fuel budget is at 88% capacity. Expect to exhaust it in 3 days.',
                timestamp: DateTime.now(),
              ),
            ),
          ),

          const Divider(height: 32.0),

          // 3. Visualization Gallery
          const MLText.heading('Chart Gallery'),
          const SizedBox(height: 12.0),

          // Line Chart
          const MLText.caption('Historical Spline Trend (MLLineChart):'),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () => _showFisInspector(context, 'MLLineChart'),
            child: MLLineChart(
              dataPoints: const [32000, 36000, 42000, 38000, 45000, 48520.50],
              xAxisLabels: const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
              state: _fisState,
              emptyType: _fisEmptyType,
            ),
          ),

          const SizedBox(height: 20.0),

          // Bar Chart
          const MLText.caption('Category Allocation Bars (MLBarChart):'),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () => _showFisInspector(context, 'MLBarChart'),
            child: MLBarChart(
              values: const [12000, 8500, 6200, 4100],
              labels: const ['Food', 'Bills', 'Travel', 'Other'],
              state: _fisState,
              emptyType: _fisEmptyType,
            ),
          ),

          const SizedBox(height: 20.0),

          // Donut Chart
          const MLText.caption('Relative Distributions (MLDonutChart):'),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () => _showFisInspector(context, 'MLDonutChart'),
            child: MLDonutChart(
              values: const [40, 25, 20, 15],
              labels: const ['Food', 'Transport', 'Shopping', 'Bills'],
              colors: [
                MLColors.primary(context),
                MLColors.secondary(context),
                MLColors.budget(context),
                MLColors.expense(context),
              ],
              centerLabel: 'Total Spent',
              centerValue: '₹30,800.00',
              state: _fisState,
              emptyType: _fisEmptyType,
            ),
          ),

          const SizedBox(height: 20.0),

          // Heatmap Chart
          const MLText.caption('Spending Intensity Grid (MLHeatMap):'),
          const SizedBox(height: 8.0),
          GestureDetector(
            onTap: () => _showFisInspector(context, 'MLHeatMap'),
            child: MLHeatMap(
              intensityGrid: const [
                [0, 120, 0, 50, 0, 800, 0],
                [400, 0, 300, 0, 1200, 0, 150],
                [0, 0, 80, 0, 0, 600, 0],
              ],
              state: _fisState,
              emptyType: _fisEmptyType,
            ),
          ),

          const Divider(height: 32.0),

          // 4. Timelines Gallery
          const MLText.heading('Timeline Gallery'),
          const SizedBox(height: 12.0),
          GestureDetector(
            onTap: () => _showFisInspector(context, 'MLCashFlowTimeline'),
            child: MLCashFlowTimeline(
              events: [
                MLTimelineEvent(
                  id: '1',
                  title: 'Salary Credit',
                  amount: 45000,
                  date: DateTime.now().subtract(const Duration(days: 2)),
                  categoryId: 'salary',
                  isIncome: true,
                ),
                MLTimelineEvent(
                  id: '2',
                  title: 'Whole Foods Market',
                  amount: 2450.50,
                  date: DateTime.now().subtract(const Duration(days: 1)),
                  categoryId: 'food',
                  isIncome: false,
                ),
              ],
              state: _fisState,
              emptyType: _fisEmptyType,
            ),
          ),

          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  void _showFisInspector(BuildContext context, String componentName) {
    String purpose = '';
    String question = '';
    String dataReq = '';
    String typo = '';
    String color = '';
    String spacing = '';
    String radius = '';
    String shadow = '';
    String access = '';
    String example = '';

    switch (componentName) {
      case 'MLMetricCard':
        purpose =
            'Displays high-level KPI amounts with resolved trend percentages and sparklines.';
        question =
            'What is the absolute value and what was the recent direction of this metric?';
        dataReq =
            'String title, String value, String trendText, bool isPositiveTrend, List<double>? sparklinePoints';
        typo = 'MLTypography.displayLarge (weight bold), MLTypography.caption';
        color =
            'MLColors.primary, MLColors.success (improving), MLColors.error (declining)';
        spacing =
            'MLSpacing.cardPadding (16.0), MLSpacing.lg (16.0) gap spacing';
        radius = 'MLRadius.card (16.0)';
        shadow = 'MLShadow.none (uses subtle border borders)';
        access =
            'Announces trend indicator semantically. Enables font scaling wrappers without truncating metrics.';
        example =
            'const MLMetricCard(\n  title: "Total Balance",\n  value: "₹48,520.50",\n  trendText: "18% down vs last week",\n  isPositiveTrend: false,\n)';
        break;
      case 'MLFinancialStory':
        purpose =
            'Generates supportive narrative insights translating calculations into human stories.';
        question =
            'How does my recent budget performance explain my financial situation?';
        dataReq =
            'String storyText, String actionLabel, VoidCallback? onAction';
        typo = 'MLTypography.titleMedium (weight Medium, height 1.4)';
        color = 'MLColors.primary, MLColors.secondary';
        spacing = 'MLSpacing.cardPadding (16.0)';
        radius = 'MLRadius.card (16.0)';
        shadow = 'MLShadow.none';
        access =
            'Large readable text wraps correctly. High contrast background gradients >= 5:1 ratio.';
        example =
            'const MLFinancialStory(\n  storyText: "You spent 18% less on Entertainment this weekend.",\n  actionLabel: "View breakdown",\n)';
        break;
      case 'MLForecastCard':
        purpose =
            'Visualizes predictive month-end runout estimates against spending limits.';
        question =
            'Will my current rate of spending cause me to exceed my budget?';
        dataReq =
            'double predictedSpend, double limit, int daysRemaining, double currentVelocity';
        typo = 'MLTypography.caption, MLTypography.titleMedium';
        color =
            'MLColors.error (if exceeding), MLColors.success (if within budget)';
        spacing = 'MLSpacing.cardPadding (16.0)';
        radius = 'MLRadius.card (16.0)';
        shadow = 'MLShadow.none';
        access =
            'Alerts the user without shaming. Screen readers read the projection description immediately.';
        example =
            'const MLForecastCard(\n  predictedSpend: 54000,\n  limit: 50000,\n  daysRemaining: 10,\n  currentVelocity: 1800,\n)';
        break;
      case 'MLInsightCard':
        purpose = 'Renders contextual warnings, advices, and goal completions.';
        question = 'What requires my immediate attention?';
        dataReq = 'MLInsight insight, VoidCallback? onTap';
        typo = 'MLTypography.titleMedium, MLTypography.bodySmall';
        color =
            'MLColors.primary (info), MLColors.warning (warn), MLColors.error (critical)';
        spacing = 'MLSpacing.cardPadding (16.0)';
        radius = 'MLRadius.card (16.0)';
        shadow = 'MLShadow.none';
        access =
            'Minimum WCAG touch target 48dp. High visibility severity icons.';
        example =
            'const MLInsightCard(\n  insight: MLInsight(\n    id: "1",\n    type: MLInsightType.budgetRisk,\n    severity: MLInsightSeverity.warning,\n    title: "Budget Risk",\n    message: "Fuel limit is almost reached.",\n  ),\n)';
        break;
      case 'MLLineChart':
        purpose = 'Renders interactive historical spline graphics.';
        question =
            'What was my balance or expense direction over the last few months?';
        dataReq = 'List<double> dataPoints, List<String> xAxisLabels';
        typo = 'NothingDotMatrix (small uppercase tags)';
        color = 'MLColors.primary, MLColors.surfaceOverlay (grid lines)';
        spacing = 'MLSpacing.cardPadding (16.0)';
        radius = 'MLRadius.card (16.0)';
        shadow = 'MLShadow.none';
        access =
            'Contrast ratio 4.5:1. Screen readers announce historical data summaries. Tabular figures enabled.';
        example =
            'MLLineChart(\n  dataPoints: [32000, 42000, 48520.50],\n  xAxisLabels: ["Jan", "Feb", "Mar"],\n)';
        break;
      case 'MLBarChart':
        purpose = 'Renders visual comparison bars.';
        question = 'How much did I spend in category A compared to category B?';
        dataReq = 'List<double> values, List<String> labels';
        typo = 'NothingDotMatrix';
        color = 'MLColors.primary';
        spacing = 'MLSpacing.cardPadding (16.0)';
        radius = 'MLRadius.card (16.0)';
        shadow = 'MLShadow.none';
        access =
            'Gradients highlight top expenses. Focus node rings supported on key targets.';
        example =
            'MLBarChart(\n  values: [12000, 8500],\n  labels: ["Food", "Bills"],\n)';
        break;
      case 'MLDonutChart':
        purpose =
            'Renders relative proportion allocations with center summation labels.';
        question = 'Where does my money go in terms of percentage splits?';
        dataReq =
            'List<double> values, List<String> labels, List<Color> colors, String centerValue';
        typo = 'NothingDotMatrix, MLTypography.titleMedium';
        color = 'Category Palette, MLColors.primary';
        spacing = 'MLSpacing.cardPadding (16.0)';
        radius = 'MLRadius.card (16.0)';
        shadow = 'MLShadow.none';
        access =
            'Announces share allocations. Color blind safe color distributions.';
        example =
            'MLDonutChart(\n  values: [40, 60],\n  labels: ["Bills", "Savings"],\n  centerLabel: "Total",\n  centerValue: "₹50,000",\n)';
        break;
      case 'MLHeatMap':
        purpose = 'Renders daily calendar spend grids.';
        question =
            'What was my spending intensity during this calendar period?';
        dataReq = 'List<List<double>> intensityGrid';
        typo = 'NothingDotMatrix';
        color = 'MLColors.expense (shades of intensity)';
        spacing = 'MLSpacing.cardPadding (16.0)';
        radius = 'MLRadius.card (16.0)';
        shadow = 'MLShadow.none';
        access =
            'Includes readable semantic tables describing cell contents for blind users.';
        example =
            'MLHeatMap(\n  intensityGrid: [[0, 120, 80], [40, 200, 0]],\n)';
        break;
      case 'MLCashFlowTimeline':
        purpose = 'Displays dynamic vertical lists of cash events.';
        question = 'In what order did my money arrive and leave?';
        dataReq = 'List<MLTimelineEvent> events';
        typo = 'MLTypography.titleMedium, NothingDotMatrix';
        color = 'MLColors.income, MLColors.expense';
        spacing = 'MLSpacing.cardPadding (16.0)';
        radius = 'MLRadius.card (16.0)';
        shadow = 'MLShadow.none';
        access =
            'Announces full date/time descriptions and transaction daltas.';
        example = 'MLCashFlowTimeline(\n  events: [MLTimelineEvent(...)],\n)';
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20.0),
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withAlpha(128),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16.0),
                MLComponentInspector(
                  componentName: componentName,
                  purpose:
                      '$purpose\n\nQuestion Answered: $question\nData Required: $dataReq',
                  codeExample: example,
                  typographyToken: typo,
                  colorToken: color,
                  spacingToken: spacing,
                  radiusToken: radius,
                  shadowToken: shadow,
                  accessibilityNotes: access,
                ),
                const SizedBox(height: 24.0),
              ],
            ),
          ),
        );
      },
    );
  }
}
