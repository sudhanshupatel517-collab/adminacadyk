import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Shared filter chip row used across Users, Events, Organizations,
/// Notices, Activity, and Content screens.
class AdminFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selected;
  final ValueChanged<String> onSelected;
  final Map<String, int>? counts;

  const AdminFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
    this.counts,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: filters.map((filter) {
        final isActive = selected == filter;
        final count = counts?[filter];

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => onSelected(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? (isDark ? Colors.white : AppColors.brand)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive
                      ? (isDark ? Colors.white : AppColors.brand)
                      : AppColors.border(isDark),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatLabel(filter),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive
                          ? (isDark ? AppColors.brand : Colors.white)
                          : AppColors.textSec(isDark),
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: 5),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? (isDark ? AppColors.brand : Colors.white.withValues(alpha: 0.8))
                            : AppColors.textMut(isDark),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatLabel(String filter) {
    if (filter == 'all') return 'All';
    return filter.split('_').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}
