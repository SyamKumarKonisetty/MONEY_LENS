import 'package:flutter/material.dart';
import 'text.dart';
import 'money.dart';
import 'primitives.dart';
import 'package:money_lens/core/design/design_system.dart';

/// MoneyLens Design System (MLDS) Layer 3 Financial Components.
///
/// These components form the core visual identity of MoneyLens,
/// defining transaction lists, balance indicators, goals, and summaries.

class MLHeroBalance extends StatelessWidget {
  const MLHeroBalance({
    required this.amount,
    required this.currency,
    super.key,
  });

  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MLText.dotLabel('Total Balance'),
        const SizedBox(height: 8.0),
        MLMoneyDisplay.hero(amount: amount, currency: currency),
      ],
    );
  }
}

class MLBalanceCard extends StatelessWidget {
  const MLBalanceCard({
    required this.amount,
    required this.currency,
    super.key,
  });

  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.dotLabel('Net Balance'),
          const SizedBox(height: 12.0),
          MLMoneyDisplay.hero(amount: amount, currency: currency),
        ],
      ),
    );
  }
}

class MLIncomeCard extends StatelessWidget {
  const MLIncomeCard({required this.amount, required this.currency, super.key});

  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.dotLabel('Income'),
          const SizedBox(height: 8.0),
          MLMoneyDisplay.standard(
            amount: amount,
            currency: currency,
            isIncome: true,
          ),
        ],
      ),
    );
  }
}

class MLExpenseCard extends StatelessWidget {
  const MLExpenseCard({
    required this.amount,
    required this.currency,
    super.key,
  });

  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.dotLabel('Expense'),
          const SizedBox(height: 8.0),
          MLMoneyDisplay.standard(
            amount: amount,
            currency: currency,
            isIncome: false,
          ),
        ],
      ),
    );
  }
}

class MLCashFlowCard extends StatelessWidget {
  const MLCashFlowCard({
    required this.income,
    required this.expense,
    required this.currency,
    super.key,
  });

  final double income;
  final double expense;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MLText.dotLabel('INFLOW'),
              const SizedBox(height: 4.0),
              MLMoneyDisplay.standard(
                amount: income,
                currency: currency,
                isIncome: true,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MLText.dotLabel('OUTFLOW'),
              const SizedBox(height: 4.0),
              MLMoneyDisplay.standard(
                amount: expense,
                currency: currency,
                isIncome: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MLBudgetPlanCard extends StatelessWidget {
  const MLBudgetPlanCard({
    required this.name,
    required this.limit,
    required this.spent,
    required this.currency,
    super.key,
  });

  final String name;
  final double limit;
  final double spent;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final progress = spent / limit;
    return MLSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MLText.dotLabel(name),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MLMoneyDisplay.standard(amount: spent, currency: currency),
              MLText.caption('Limit: $currency$limit'),
            ],
          ),
          const SizedBox(height: 8.0),
          MLLinearProgress(value: progress.clamp(0.0, 1.0)),
        ],
      ),
    );
  }
}

class MLBudgetRing extends StatelessWidget {
  const MLBudgetRing({required this.percentage, super.key});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const MLCircularProgress(
            size: 100,
          ),
          Text('${(percentage * 100).toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}

class MLBudgetProgress extends StatelessWidget {
  const MLBudgetProgress({
    required this.limit,
    required this.spent,
    required this.currency,
    super.key,
  });

  final double limit;
  final double spent;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return MLBudgetPlanCard(
      name: 'OVERALL BUDGET',
      limit: limit,
      spent: spent,
      currency: currency,
    );
  }
}

class MLBudgetAlert extends StatelessWidget {
  const MLBudgetAlert({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(38),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red),
          const SizedBox(width: 8.0),
          Expanded(child: MLText.caption(message, color: Colors.red)),
        ],
      ),
    );
  }
}

class MLBudgetSummary extends StatelessWidget {
  const MLBudgetSummary({
    required this.totalSpent,
    required this.totalLimit,
    required this.currency,
    super.key,
  });

  final double totalSpent;
  final double totalLimit;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final remaining = totalLimit - totalSpent;
    return MLSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MLText.dotLabel('BUDGET SUMMARY'),
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MLText.caption('Remaining'),
                  MLMoneyDisplay.standard(
                    amount: remaining,
                    currency: currency,
                    isIncome: remaining >= 0,
                  ),
                ],
              ),
              MLBudgetRing(percentage: (totalSpent / totalLimit)),
            ],
          ),
        ],
      ),
    );
  }
}

class MLMerchantCard extends StatelessWidget {
  const MLMerchantCard({required this.name, required this.category, super.key});

  final String name;
  final String category;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Row(
        children: [
          MLAvatar(initials: name.substring(0, 1)),
          const SizedBox(width: 12.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [MLText.heading(name), MLText.caption(category)],
          ),
        ],
      ),
    );
  }
}

class MLMerchantChip extends StatelessWidget {
  const MLMerchantChip({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: MLAvatar(initials: name.substring(0, 1), radius: 10),
      label: Text(name),
    );
  }
}

class MLMerchantAvatar extends StatelessWidget {
  const MLMerchantAvatar({required this.name, super.key});

  final String name;

  @override
  Widget build(BuildContext context) {
    return MLAvatar(initials: name.substring(0, 1));
  }
}

class MLMerchantLogo extends StatelessWidget {
  const MLMerchantLogo({required this.initials, super.key});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      child: Text(initials, style: const TextStyle(fontSize: 12)),
    );
  }
}

class MLTransactionCard extends StatelessWidget {
  const MLTransactionCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    super.key,
    this.isIncome = false,
  });

  final String title;
  final double amount;
  final String currency;
  final String category;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [MLText.heading(title), MLText.caption(category)],
          ),
          MLMoneyDisplay.standard(
            amount: amount,
            currency: currency,
            isIncome: isIncome,
          ),
        ],
      ),
    );
  }
}

class MLTransactionTile extends StatelessWidget {
  const MLTransactionTile({
    required this.title,
    required this.amount,
    required this.currency,
    super.key,
    this.isIncome = false,
  });

  final String title;
  final double amount;
  final String currency;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: MLText.body(title),
      trailing: MLMoneyDisplay.standard(
        amount: amount,
        currency: currency,
        isIncome: isIncome,
      ),
    );
  }
}

class MLTransactionTimeline extends StatelessWidget {
  const MLTransactionTimeline({required this.tiles, super.key});

  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(children: tiles);
  }
}

class MLExpenseComposer extends StatelessWidget {
  const MLExpenseComposer({required this.onSave, super.key});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Column(
        children: [
          const MLText.dotLabel('ADD EXPENSE'),
          const SizedBox(height: 12.0),
          ElevatedButton(onPressed: onSave, child: const Text('Save Expense')),
        ],
      ),
    );
  }
}

class MLIncomeComposer extends StatelessWidget {
  const MLIncomeComposer({required this.onSave, super.key});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Column(
        children: [
          const MLText.dotLabel('ADD INCOME'),
          const SizedBox(height: 12.0),
          ElevatedButton(onPressed: onSave, child: const Text('Save Income')),
        ],
      ),
    );
  }
}

class MLMoneyInput extends StatelessWidget {
  const MLMoneyInput({super.key});

  @override
  Widget build(BuildContext context) {
    return const TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(prefixText: '₹ ', hintText: '0.00'),
    );
  }
}

class MLCurrencyInput extends StatelessWidget {
  const MLCurrencyInput({super.key});

  @override
  Widget build(BuildContext context) {
    return const MLMoneyInput();
  }
}

class MLQuickActionCard extends StatelessWidget {
  const MLQuickActionCard({
    required this.label,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: MLSurface(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8.0),
            MLText.caption(label),
          ],
        ),
      ),
    );
  }
}

class MLAnalyticsCard extends StatelessWidget {
  const MLAnalyticsCard({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [MLText.dotLabel(title), const SizedBox(height: 12.0), child],
      ),
    );
  }
}

class MLInsightCard extends StatelessWidget {
  const MLInsightCard({required this.insight, super.key});

  final String insight;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline),
          const SizedBox(width: 12.0),
          Expanded(child: MLText.body(insight)),
        ],
      ),
    );
  }
}

class MLSpendingHeatmap extends StatelessWidget {
  const MLSpendingHeatmap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: AppColors.textMuted.withAlpha(38),
      child: const Center(child: Text('Spending Heatmap Placeholder')),
    );
  }
}

class MLCategoryBreakdown extends StatelessWidget {
  const MLCategoryBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    return const MLSurface(
      child: Column(
        children: [
          MLText.dotLabel('CATEGORIES'),
          SizedBox(height: 8.0),
          Text('Food: 40% | Rent: 50% | Other: 10%'),
        ],
      ),
    );
  }
}

class MLSavingsGoal extends StatelessWidget {
  const MLSavingsGoal({
    required this.title,
    required this.target,
    required this.current,
    super.key,
  });

  final String title;
  final double target;
  final double current;

  @override
  Widget build(BuildContext context) {
    return MLSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MLText.dotLabel(title),
          const SizedBox(height: 8.0),
          Text('$current / $target saved'),
        ],
      ),
    );
  }
}

class MLGoalProgress extends StatelessWidget {
  const MLGoalProgress({required this.percentage, super.key});

  final double percentage;

  @override
  Widget build(BuildContext context) {
    return MLLinearProgress(value: percentage);
  }
}

class MLGoalCelebration extends StatelessWidget {
  const MLGoalCelebration({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 48, color: Colors.amber),
          SizedBox(height: 12.0),
          MLText.heading('Goal Achieved!'),
        ],
      ),
    );
  }
}

class MLRecurringPayment extends StatelessWidget {
  const MLRecurringPayment({
    required this.title,
    required this.amount,
    required this.currency,
    super.key,
  });

  final String title;
  final double amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return MLTransactionTile(title: title, amount: amount, currency: currency);
  }
}

class MLBillReminder extends StatelessWidget {
  const MLBillReminder({required this.title, required this.dueDate, super.key});

  final String title;
  final DateTime dueDate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: MLText.body(title),
        subtitle: Text('Due: ${dueDate.day}/${dueDate.month}'),
        trailing: const Icon(Icons.notifications_active),
      ),
    );
  }
}

class MLFinancialNotification extends StatelessWidget {
  const MLFinancialNotification({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MLInsightCard(insight: message);
  }
}

class MLImportPreview extends StatelessWidget {
  const MLImportPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Import Preview Stub'));
  }
}

class MLExportSummary extends StatelessWidget {
  const MLExportSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Export Summary Stub'));
  }
}

class MLCSVPreview extends StatelessWidget {
  const MLCSVPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('CSV Preview Stub'));
  }
}

class MLDashboardHero extends StatelessWidget {
  const MLDashboardHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const MLBalanceCard(amount: 48520.50, currency: '₹');
  }
}

class MLRecentTransactions extends StatelessWidget {
  const MLRecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        MLTransactionTile(
          title: 'Grocery Store',
          amount: -1250.00,
          currency: '₹',
        ),
        MLTransactionTile(
          title: 'Salary Credit',
          amount: 85000.00,
          currency: '₹',
          isIncome: true,
        ),
      ],
    );
  }
}

class MLNetWorthCard extends StatelessWidget {
  const MLNetWorthCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MLBalanceCard(amount: 1248000.00, currency: '₹');
  }
}

class MLWalletCard extends StatelessWidget {
  const MLWalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MLBalanceCard(amount: 15400.00, currency: '₹');
  }
}

class MLForecastCard extends StatelessWidget {
  const MLForecastCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MLSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MLText.dotLabel('FORECAST'),
          SizedBox(height: 8.0),
          MLText.body('Estimated balance next month: ₹54,200.00'),
        ],
      ),
    );
  }
}

class MLDailySummary extends StatelessWidget {
  const MLDailySummary({super.key});

  @override
  Widget build(BuildContext context) {
    return const MLSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MLText.dotLabel('DAILY SUMMARY'),
          SizedBox(height: 8.0),
          MLText.body('Today: Spent ₹1,250.00 | Recieved ₹0.00'),
        ],
      ),
    );
  }
}
