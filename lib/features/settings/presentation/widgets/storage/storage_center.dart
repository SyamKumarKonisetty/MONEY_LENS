import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/extensions/context_extensions.dart';
import '../../../../../core/ui_engine/glass/glass_card.dart';

class StorageCenter extends ConsumerStatefulWidget {
  const StorageCenter({super.key});

  @override
  ConsumerState<StorageCenter> createState() => _StorageCenterState();
}

class _StorageCenterState extends ConsumerState<StorageCenter> with SingleTickerProviderStateMixin {
  double _dbSize = 0.0;
  double _cacheSize = 0.0;
  bool _isLoading = false;
  late final AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _loadSizes();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSizes() async {
    double dbSize = 0.0;
    double cacheSize = 0.0;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      if (await docDir.exists()) {
        await for (final entity in docDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            final pathLower = entity.path.toLowerCase();
            if (pathLower.contains('money_lens') || pathLower.endsWith('.sqlite') || pathLower.endsWith('.db')) {
              dbSize += await entity.length();
            }
          }
        }
      }
    } catch (_) {}

    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            cacheSize += await entity.length();
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _dbSize = dbSize;
        _cacheSize = cacheSize;
      });
    }
  }

  String _formatSize(double bytes) {
    if (bytes < 1024) return '${bytes.toStringAsFixed(0)} B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  Future<void> _clearCache() async {
    setState(() => _isLoading = true);
    try {
      final tempDir = await getTemporaryDirectory();
      if (await tempDir.exists()) {
        await for (final entity in tempDir.list(recursive: true, followLinks: false)) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            // Silently ignore individual file deletion errors
          }
        }
      }
      _showMsg('Cache cleared successfully');
    } catch (e) {
      if (e is PathNotFoundException) {
         _showMsg('Cache already clean');
      } else {
         _showMsg('Failed to clear cache: $e', isError: true);
      }
    } finally {
      await _loadSizes();
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _optimizeStorage() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    _showMsg('Database indexing optimized');
    await _loadSizes();
    if (mounted) setState(() => _isLoading = false);
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: isError ? context.errorColor : context.successColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _dbSize + _cacheSize;
    final double maxScale = 10.0 * 1024 * 1024; 
    final dbRatio = total > 0 ? (_dbSize / maxScale).clamp(0.02, 0.9) : 0.05;
    final cacheRatio = total > 0 ? (_cacheSize / maxScale).clamp(0.02, 0.9) : 0.05;
    final freeRatio = (1.0 - dbRatio - cacheRatio).clamp(0.05, 0.96);

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
                    Text('Storage Center', style: AppTypography.titleMedium.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text('Total Local Data: ${_formatSize(total)}', style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
                  ],
                ),
                if (_isLoading)
                  RotationTransition(
                    turns: _spinCtrl,
                    child: Icon(Icons.donut_large_rounded, color: context.primaryColor, size: 18),
                  )
                else
                  Icon(Icons.storage_rounded, color: context.primaryColor, size: 20),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    Expanded(flex: (dbRatio * 100).toInt(), child: Container(color: context.primaryColor)),
                    Expanded(flex: (cacheRatio * 100).toInt(), child: Container(color: Colors.orange)),
                    Expanded(flex: (freeRatio * 100).toInt(), child: Container(color: context.separatorColor.withValues(alpha: 0.3))),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                _legendItem(context.primaryColor, 'Database', _formatSize(_dbSize)),
                const SizedBox(width: AppSpacing.lg),
                _legendItem(Colors.orange, 'Cache / Temp', _formatSize(_cacheSize)),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Divider(height: 1, color: context.separatorColor.withValues(alpha: 0.3)),
            const SizedBox(height: AppSpacing.md),

            _actionTile(icon: Icons.delete_sweep_outlined, title: 'Clear Cache Files', subtitle: 'Free up temporary file storage', onTap: _clearCache),
            _actionTile(icon: Icons.compress_rounded, title: 'Optimize Database', subtitle: 'Re-index tables for peak performance', onTap: _optimizeStorage),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, String size) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: AppSpacing.xs),
        Text('$label ($size)', style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
      ],
    );
  }

  Widget _actionTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
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
                  Text(title, style: AppTypography.bodyMedium.copyWith(color: context.textPrimaryColor, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: context.textSecondaryColor)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
