import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design/design_system.dart';
import 'sections/budget/monthly_budget_section.dart';
import 'sections/financial_health/financial_health_section.dart';
import 'sections/hero/greeting_header.dart';
import 'sections/hero/hero_financial_card.dart';
import 'sections/quick_actions/quick_actions_section.dart';
import 'sections/recent_activity/recent_activity_section.dart';
import 'sections/smart_insights/smart_insights_section.dart';
import 'sections/today_story/today_story_section.dart';

/// MoneyLens NEXT — Reimagined Hero Dashboard Experience screen assembly.
///
/// Features clean architectural grouping, beautiful section entrances,
/// and modularized custom painters to maintain 60 FPS.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: RepaintBoundary(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Safe Area Header Spacer
              SizedBox(height: AppSpacing.giant),

              // 2. Animated Greeting Header
              GreetingHeader(),
              SizedBox(height: AppSpacing.xxl),

              // 3. Hero Financial Card (with slow rotating mesh gradient)
              HeroFinancialCard(),
              SizedBox(height: AppSpacing.lg),

              // 4. Today's Story (Large narrative context)
              TodayStorySection(),
              SizedBox(height: AppSpacing.sectionGap),

              // 5. Springy Glass Quick Actions circular dock
              QuickActionsSection(),
              SizedBox(height: AppSpacing.sectionGap),

              // 6. Dynamic Financial Health radial score
              FinancialHealthSection(),
              SizedBox(height: AppSpacing.sectionGap),

              // 7. Monthly Liquid Progress Ring budget card
              MonthlyBudgetSection(),
              SizedBox(height: AppSpacing.sectionGap),

              // 8. Recent Timeline list or illustrated empty view
              RecentActivitySection(),
              SizedBox(height: AppSpacing.sectionGap),

              // 9. Rotating Smart Insights crossfading panel
              SmartInsightsSection(),

              // 10. Bottom breathing space to offset floating navigators
              SizedBox(height: AppSpacing.massive),
            ],
          ),
        ),
      ),
    );
  }
}
