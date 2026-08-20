import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Clean enterprise data table without decorative icons.
class AdminDataTableColumn {
  final String label;
  final int flex;
  final TextAlign align;

  const AdminDataTableColumn({
    required this.label,
    this.flex = 1,
    this.align = TextAlign.left,
  });
}

class AdminDataTable extends StatelessWidget {
  final List<AdminDataTableColumn> columns;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final bool isLoading;
  final String? emptyTitle;
  final String? emptySubtitle;
  final String? error;
  final VoidCallback? onRetry;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.itemCount,
    required this.itemBuilder,
    this.isLoading = false,
    this.emptyTitle,
    this.emptySubtitle,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = AppColors.border(isDark);
    final headerBg = AppColors.surfaceAlt(isDark);
    final headerText = AppColors.textSec(isDark);
    final rowDivider = AppColors.borderSubtle(isDark);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(isDark),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          // Header Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Row(
              children: columns.map((col) {
                return Expanded(
                  flex: col.flex,
                  child: Text(
                    col.label.toUpperCase(),
                    textAlign: col.align,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: headerText,
                      letterSpacing: 0.5,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(height: 1, color: borderColor),

          // Body States
          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.text(isDark),
                  ),
                ),
              ),
            )
          else if (error != null)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Failed to load table data',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(isDark),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error!,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSec(isDark),
                      ),
                    ),
                    if (onRetry != null) ...[
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: onRetry,
                        child: const Text('Retry'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else if (itemCount == 0)
            Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      emptyTitle ?? 'No records found',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(isDark),
                      ),
                    ),
                    if (emptySubtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        emptySubtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSec(isDark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              separatorBuilder: (_, __) => Container(height: 1, color: rowDivider),
              itemBuilder: itemBuilder,
            ),
        ],
      ),
    );
  }
}