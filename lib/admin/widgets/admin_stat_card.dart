import 'package:flutter/material.dart';

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final String? subtitle;

  const AdminStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF161616) : Colors.white;
    final borderColor = isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8);
    final effectiveIconColor = iconColor ?? (isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: effectiveIconColor.withValues(alpha: isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: effectiveIconColor),
              ),
              if (subtitle != null)
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: subtitle!.contains('+')
                          ? const Color(0xFF00BA7C).withValues(alpha: 0.1)
                          : (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(subtitle!, style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: subtitle!.contains('+')
                          ? const Color(0xFF00BA7C)
                          : (isDark ? const Color(0xFF888888) : const Color(0xFF999999)),
                    ), overflow: TextOverflow.ellipsis),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
          ), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}