import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_responsive.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminDashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF13171F) : Colors.white;
    final borderColor = isDark ? const Color(0xFF21262D) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827);
    final textSecondary = isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 960;
              final cards = [
                AdminStatCard(
                  label: 'User Retention Rate',
                  value: '84.2%',
                  subtitle: '+2.8% vs last month',
                  icon: Icons.trending_up_rounded,
                  accentColor: const Color(0xFF059669),
                ),
                AdminStatCard(
                  label: 'Avg Daily Active Users',
                  value: '648',
                  subtitle: '52% daily engagement',
                  icon: Icons.access_time_rounded,
                  accentColor: const Color(0xFF0A66C2),
                ),
                AdminStatCard(
                  label: 'Posts Per Student',
                  value: '3.12',
                  subtitle: 'Academic discussions & opps',
                  icon: Icons.chat_bubble_outline_rounded,
                  accentColor: const Color(0xFF7C3AED),
                ),
                AdminStatCard(
                  label: 'Moderation Resolution',
                  value: '< 4.2 hrs',
                  subtitle: '99.4% reports resolved',
                  icon: Icons.verified_user_outlined,
                  accentColor: const Color(0xFF059669),
                ),
              ];

              if (isWide) {
                return Row(
                  children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c))).toList(),
                );
              }

              return GridView.count(
                crossAxisCount: constraints.maxWidth < 640 ? 1 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: cards,
              );
            },
          ),
          const SizedBox(height: 20),

          // Detailed Institutional Distribution Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= AdminBreakpoints.tablet;
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTermGrowthChart(cardBg, borderColor, textPrimary, textSecondary)),
                    const SizedBox(width: 20),
                    Expanded(child: _buildEngagementBreakdown(cardBg, borderColor, textPrimary, textSecondary)),
                  ],
                );
              }
              return Column(
                children: [
                  _buildTermGrowthChart(cardBg, borderColor, textPrimary, textSecondary),
                  const SizedBox(height: 20),
                  _buildEngagementBreakdown(cardBg, borderColor, textPrimary, textSecondary),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermGrowthChart(Color cardBg, Color borderColor, Color textPrimary, Color textSecondary) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug'];
    final users = [340, 420, 580, 690, 780, 920, 1080, 1247];
    final maxVal = 1300;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Student Growth & Enrollment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
              Text('Academic Year 2026', style: TextStyle(fontSize: 12, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (i) {
                final heightFactor = users[i] / maxVal;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('${users[i]}', style: TextStyle(fontSize: 9, color: textSecondary, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        Container(
                          height: 140 * heightFactor,
                          decoration: BoxDecoration(
                            color: i == months.length - 1 ? const Color(0xFF0A66C2) : const Color(0xFF0A66C2).withOpacity(0.4),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(months[i], style: TextStyle(fontSize: 11, color: textSecondary)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementBreakdown(Color cardBg, Color borderColor, Color textPrimary, Color textSecondary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Content Engagement by Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
              Text('Total: 3,892 posts', style: TextStyle(fontSize: 12, color: textSecondary)),
            ],
          ),
          const SizedBox(height: 20),
          _buildCategoryBar('Academic Research Papers', '1,420 (36%)', 0.36, const Color(0xFF0A66C2), textPrimary, textSecondary),
          const SizedBox(height: 14),
          _buildCategoryBar('Career & Internship Opportunities', '1,050 (27%)', 0.27, const Color(0xFF059669), textPrimary, textSecondary),
          const SizedBox(height: 14),
          _buildCategoryBar('Campus Clubs & Societies', '820 (21%)', 0.21, const Color(0xFF7C3AED), textPrimary, textSecondary),
          const SizedBox(height: 14),
          _buildCategoryBar('General Student Discussions', '602 (16%)', 0.16, const Color(0xFFD97706), textPrimary, textSecondary),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(String label, String count, double pct, Color color, Color textPrimary, Color textSecondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textPrimary)),
            Text(count, style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: textSecondary.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}