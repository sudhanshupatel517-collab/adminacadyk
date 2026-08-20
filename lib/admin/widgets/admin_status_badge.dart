import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Compact, restrained status indicator.
/// Dot + label pattern. Semantic colors.
class AdminStatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const AdminStatusBadge({
    super.key,
    required this.status,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final config = _statusConfig(status.toLowerCase(), isDark);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: config.dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          config.label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: config.textColor,
          ),
        ),
      ],
    );
  }

  _StatusConfig _statusConfig(String status, bool isDark) {
    switch (status) {
      case 'active':
      case 'published':
      case 'completed':
        return _StatusConfig(
          label: _capitalize(this.status),
          dotColor: AppColors.success,
          textColor: isDark ? const Color(0xFF4ADE80) : AppColors.successText,
        );
      case 'suspended':
      case 'cancelled':
      case 'rejected':
        return _StatusConfig(
          label: _capitalize(this.status),
          dotColor: AppColors.error,
          textColor: isDark ? const Color(0xFFF87171) : AppColors.errorText,
        );
      case 'pending':
      case 'draft':
      case 'review':
        return _StatusConfig(
          label: _capitalize(this.status),
          dotColor: AppColors.warning,
          textColor: isDark ? const Color(0xFFFBBF24) : AppColors.warningText,
        );
      case 'inactive':
      case 'archived':
        return _StatusConfig(
          label: _capitalize(this.status),
          dotColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          textColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        );
      default:
        return _StatusConfig(
          label: _capitalize(this.status),
          dotColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          textColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        );
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _StatusConfig {
  final String label;
  final Color dotColor;
  final Color textColor;
  const _StatusConfig({required this.label, required this.dotColor, required this.textColor});
}
