import 'package:flutter/material.dart';
import 'admin_responsive.dart';
import '../../app/theme/app_colors.dart';

class AdminFormRow extends StatelessWidget {
  final List<Widget> children;

  const AdminFormRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isMobile = AdminBreakpoints.isMobile(context);
    if (isMobile || children.length == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: c,
        )).toList(),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children.asMap().entries.map((entry) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.key < children.length - 1 ? 14 : 0,
              bottom: 14,
            ),
            child: entry.value,
          ),
        );
      }).toList(),
    );
  }
}

class AdminTextField extends StatelessWidget {
  final String label;
  final String? value;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool enabled;

  const AdminTextField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSec(isDark),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceAlt(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.border(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.border(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.text(isDark), width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: AppColors.borderSubtle(isDark)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
        ),
      ],
    );
  }
}

class AdminSwitchField extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AdminSwitchField({
    super.key,
    required this.label,
    this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt(isDark),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border(isDark), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(isDark),
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textMut(isDark),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: isDark ? Colors.white : AppColors.brand,
          ),
        ],
      ),
    );
  }
}