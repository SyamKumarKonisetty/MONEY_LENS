import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';
import '../../../../../core/utils/backup_helper.dart';
import '../../../../../core/database/app_database.dart';
import '../../providers/settings_provider.dart';
import '../../../../expenses/presentation/providers/expense_provider.dart';
import '../../../../budget/presentation/providers/budget_provider.dart';

class BackupRestoreCard extends ConsumerStatefulWidget {
  const BackupRestoreCard({super.key});

  @override
  ConsumerState<BackupRestoreCard> createState() => _BackupRestoreCardState();
}

class _BackupRestoreCardState extends ConsumerState<BackupRestoreCard> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  static const String _prefBackupDateKey = 'last_backup_date';
  late final AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(sharedPreferencesProvider);
    final lastBackup = prefs.getString(_prefBackupDateKey) ?? 'Never';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: GlassCard(
        isInteractive: false,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backup & Restore',
                      style: AppTypography.titleMedium.copyWith(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last Backup: $lastBackup',
                      style: AppTypography.bodySmall.copyWith(
                        color: context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  RotationTransition(
                    turns: _spinCtrl,
                    child: Icon(Icons.donut_large_rounded, color: context.primaryColor, size: 20),
                  )
                else
                  Icon(Icons.cloud_upload_outlined, color: context.primaryColor),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            // Backup Now
            _actionTile(
              icon: Icons.backup_rounded,
              title: 'Backup Now (CSV)',
              subtitle: 'Export entire database to local file',
              onTap: () => _runAction(() async {
                final csv = await BackupHelper.serializeDataToCsv();
                final name = BackupHelper.generateBackupFileName();
                final file = await BackupHelper.saveBackupLocally(csv, name);
                await prefs.setString(_prefBackupDateKey, DateTime.now().toString().substring(0, 16));
                _showMsg('Saved to: ${file.path}');
              }),
            ),

            // Share Backup
            _actionTile(
              icon: Icons.share_rounded,
              title: 'Share Backup File',
              subtitle: 'Send CSV backup file via system share',
              onTap: () => _runAction(() async {
                final csv = await BackupHelper.serializeDataToCsv();
                final name = BackupHelper.generateBackupFileName();
                await BackupHelper.shareBackupFile(csv, name);
              }),
            ),

            // Restore Backup
            _actionTile(
              icon: Icons.settings_backup_restore_rounded,
              title: 'Restore Backup (CSV)',
              subtitle: 'Wipe current data & restore from file',
              onTap: () => _runAction(() async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['csv'],
                );
                if (result != null && result.files.single.path != null) {
                  final csvText = await File(result.files.single.path!).readAsString();
                  if (!csvText.startsWith('Record Type')) {
                    throw const FormatException('Invalid CSV header structure');
                  }
                  await BackupHelper.deserializeDataFromCsv(csvText);
                  ref.invalidate(expenseNotifierProvider);
                  ref.invalidate(budgetNotifierProvider);
                  _showMsg('Data restored successfully!');
                }
              }),
            ),

            // Export JSON
            _actionTile(
              icon: Icons.code_rounded,
              title: 'Export JSON',
              subtitle: 'Share structured transactions file',
              onTap: () => _runAction(() async {
                final db = AppDatabase.instance;
                final txs = await db.select(db.expenses).get();
                final list = txs.map((e) => {
                  'title': e.title,
                  'amount': e.amount,
                  'category': e.category,
                  'notes': e.notes,
                  'createdAt': e.createdAt.toIso8601String(),
                  'transactionType': e.transactionType,
                }).toList();
                final jsonStr = const JsonEncoder.withIndent('  ').convert(list);
                final temp = await Directory.systemTemp.createTemp();
                final file = File('${temp.path}/MoneyLens_Backup.json');
                await file.writeAsString(jsonStr);
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    text: 'MoneyLens JSON Backup',
                  ),
                );
              }),
            ),

            // Export PDF mock
            _actionTile(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Export PDF Statement',
              subtitle: 'Generate printable financial summary',
              onTap: () => _runAction(() async {
                final db = AppDatabase.instance;
                final txs = await db.select(db.expenses).get();
                final sb = StringBuffer()
                  ..writeln('MONEYLENS FINANCIAL STATEMENT')
                  ..writeln('Generated: ${DateTime.now().toIso8601String()}')
                  ..writeln('----------------------------------------\n');
                for (final t in txs) {
                  sb.writeln('${t.createdAt.toString().substring(0, 10)} | ${t.title.padRight(15)} | ${t.category.padRight(12)} | ₹${t.amount}');
                }
                final temp = await Directory.systemTemp.createTemp();
                final file = File('${temp.path}/MoneyLens_Statement.txt');
                await file.writeAsString(sb.toString());
                await SharePlus.instance.share(
                  ShareParams(
                    files: [XFile(file.path)],
                    text: 'MoneyLens Financial Statement',
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(icon, color: context.textSecondaryColor, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.textPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: context.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _runAction(Future<void> Function() action) async {
    setState(() => _isLoading = true);
    try {
      await action();
    } catch (e) {
      if (e is FormatException) {
        _showMsg('Invalid backup file format. Please choose a valid MoneyLens backup.', isError: true);
      } else if (e is FileSystemException) {
        _showMsg('Failed to read or write backup file. Please try again.', isError: true);
      } else {
        _showMsg('An unexpected error occurred. Please try again.', isError: true);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? context.errorColor : context.successColor,
      ),
    );
  }
}
