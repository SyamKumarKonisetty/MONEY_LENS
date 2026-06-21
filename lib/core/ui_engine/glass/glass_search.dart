import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/colors/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import 'glass_surface.dart';

class GlassSearch extends StatefulWidget {
  const GlassSearch({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.hintText = 'Search...',
    this.autoFocus = false,
    this.compact = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool autoFocus;
  final bool compact;

  @override
  State<GlassSearch> createState() => _GlassSearchState();
}

class _GlassSearchState extends State<GlassSearch> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool get _hasText => widget.controller?.text.trim().isNotEmpty ?? false;
  bool get _isExpanded => !widget.compact || _isFocused || _hasText;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller?.addListener(_onTextChange);
    if (widget.autoFocus) {
      _focusNode.requestFocus();
    }
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _focusSearch() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _focusSearch,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: _isExpanded ? AppRadius.pill : BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: AppColors.midnightSapphire.withValues(alpha: 0.55),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
              if (_isFocused || _hasText)
                BoxShadow(
                  color: AppColors.cyanHighlight.withValues(alpha: 0.16),
                  blurRadius: 18,
                ),
            ],
          ),
          child: GlassSurface(
            borderRadius: _isExpanded ? AppRadius.pill : BorderRadius.circular(999),
            opacity: (_isFocused || _hasText) ? 0.22 : 0.18,
            blur: 18.0,
            borderColor: (_isFocused || _hasText)
                ? AppColors.cyanHighlight.withValues(alpha: 0.22)
                : AppColors.divider.withValues(alpha: 0.16),
            gradientTint: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface1.withValues(alpha: 0.96),
                AppColors.surface2.withValues(alpha: 0.92),
                AppColors.surface3.withValues(alpha: 0.88),
              ],
            ),
            showBorder: true,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: _isExpanded ? _buildExpanded() : _buildCompactButton(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton() {
    return SizedBox(
      key: const ValueKey('search-compact'),
      width: 44,
      height: 44,
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface2.withValues(alpha: 0.78),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyanHighlight.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildExpanded() {
    return Container(
      key: const ValueKey('search-expanded'),
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onTap: _focusSearch,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: _isFocused ? AppColors.cyanHighlight : AppColors.textMuted,
            size: 20,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 24,
          ),
          suffixIcon: _hasText
              ? GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.controller?.clear();
                    widget.onChanged?.call('');
                  },
                  child: Icon(
                    Icons.clear_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 32,
            minHeight: 24,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        cursorColor: AppColors.cyanHighlight,
      ),
    );
  }
}
