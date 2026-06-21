import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/settings_provider.dart';

/// Premium glass Profile Hero card displaying avatar, user info, role, and monthly goal.
class ProfileHero extends ConsumerStatefulWidget {
  const ProfileHero({super.key});

  @override
  ConsumerState<ProfileHero> createState() => _ProfileHeroState();
}

class _ProfileHeroState extends ConsumerState<ProfileHero> {
  static const String _prefRoleKey = 'profile_role';
  static const String _prefGoalKey = 'profile_monthly_goal';

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileNotifierProvider);
    final prefs = ref.watch(sharedPreferencesProvider);

    final role = prefs.getString(_prefRoleKey) ?? 'Salaried';
    final goal = prefs.getDouble(_prefGoalKey) ?? 20000.0;
    final initials = profile.name.trim().isEmpty ? 'G' : profile.name.trim().substring(0, 1).toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Row(
              children: [
                // Glass Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: context.primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: context.primaryColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTypography.displayMedium.copyWith(
                        color: context.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Name & Role
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleLarge.copyWith(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        role,
                        style: AppTypography.labelMedium.copyWith(
                          color: context.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit Button
                IconButton(
                  icon: Icon(Icons.edit_note_rounded, color: context.primaryColor),
                  onPressed: () => _showEditDialog(context, profile.name, role, goal, prefs),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Info rows
            _infoRow('Monthly Goal', CurrencyFormatter.full(goal)),
            const SizedBox(height: AppSpacing.sm),
            _infoRow('Current Version', '${AppConstants.appVersion} (${AppConstants.appBuildNumber})'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(color: context.textSecondaryColor),
        ),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: context.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    String currentName,
    String currentRole,
    double currentGoal,
    var prefs,
  ) {
    final nameCtrl = TextEditingController(text: currentName);
    final goalCtrl = TextEditingController(text: currentGoal.toStringAsFixed(0));
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: context.surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Edit Profile',
                style: AppTypography.titleLarge.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    style: TextStyle(color: context.textPrimaryColor),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: context.textSecondaryColor),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.separatorColor)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    dropdownColor: context.surfaceColor,
                    style: TextStyle(color: context.textPrimaryColor),
                    decoration: InputDecoration(
                      labelText: 'Role',
                      labelStyle: TextStyle(color: context.textSecondaryColor),
                    ),
                    items: ['Salaried', 'Student', 'Freelancer', 'Business'].map((r) {
                      return DropdownMenuItem(value: r, child: Text(r));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedRole = val);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: goalCtrl,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: context.textPrimaryColor),
                    decoration: InputDecoration(
                      labelText: 'Monthly Savings Goal (₹)',
                      labelStyle: TextStyle(color: context.textSecondaryColor),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.separatorColor)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('Cancel', style: TextStyle(color: context.textSecondaryColor)),
                ),
                TextButton(
                  onPressed: () async {
                    final newName = nameCtrl.text.trim();
                    final newGoal = double.tryParse(goalCtrl.text.trim()) ?? 0.0;
                    if (newName.isNotEmpty) {
                      await ref.read(userProfileNotifierProvider.notifier).updateName(newName);
                      await prefs.setString(_prefRoleKey, selectedRole);
                      await prefs.setDouble(_prefGoalKey, newGoal);
                      setState(() {});
                      if (context.mounted) Navigator.of(ctx).pop();
                    }
                  },
                  child: Text('Save', style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
