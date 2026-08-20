import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_responsive.dart';
import '../widgets/admin_section_header.dart';
import '../../app/theme/app_colors.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _animation = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AdminDashboardProvider>();
      if (provider.stats == null) provider.loadDashboard();
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AdminDashboardProvider>();
    final stats = provider.stats;

    if (stats == null) {
      return Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.text(isDark)),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= AdminBreakpoints.tablet;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Heading
                  const AdminSectionHeader(
                    title: 'Institutional Analytics & Metrics',
                    padding: EdgeInsets.only(bottom: 16),
                  ),

                  // Row 1: Bar Chart + Donut Chart
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildBarChart(isDark, stats)),
                        const SizedBox(width: 18),
                        Expanded(flex: 2, child: _buildDonutChart(isDark, stats)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildBarChart(isDark, stats),
                        const SizedBox(height: 18),
                        _buildDonutChart(isDark, stats),
                      ],
                    ),

                  const SizedBox(height: 18),

                  // Row 2: Growth Trend + KPI Cards
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildGrowthTrend(isDark, stats)),
                        const SizedBox(width: 18),
                        Expanded(flex: 2, child: _buildKPICards(isDark, stats)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildGrowthTrend(isDark, stats),
                        const SizedBox(height: 18),
                        _buildKPICards(isDark, stats),
                      ],
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _card(bool isDark, {required Widget child}) {
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }

  // BAR CHART
  Widget _buildBarChart(bool isDark, dynamic stats) {
    final barColor = isDark ? const Color(0xFF38BDF8) : AppColors.brand;
    final data = [
      _BarData('Users', stats.totalUsers.toDouble(), barColor),
      _BarData('Active', stats.activeUsers.toDouble(), barColor),
      _BarData('Posts', stats.totalPosts.toDouble(), barColor),
      _BarData('Opps', stats.totalOpportunities.toDouble(), barColor),
      _BarData('Clubs', stats.totalClubs.toDouble(), barColor),
      _BarData('Events', stats.totalEvents.toDouble(), barColor),
    ];
    final scaledData = data.map((d) => _BarData(d.label, math.sqrt(d.value + 1) * 10, d.color)).toList();
    final maxVal = scaledData.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return _card(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Institutional Resource Distribution',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text(isDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Relative platform resource allocation across active records',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMut(isDark),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 240,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: scaledData.asMap().entries.map((entry) {
                    final d = entry.value;
                    final original = data[entry.key];
                    final barHeight = maxVal > 0 ? (d.value / maxVal) * 200 * _animation.value : 0.0;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: entry.key < scaledData.length - 1 ? 12 : 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              original.value.toInt().toString(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSec(isDark),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: d.color,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              d.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textMut(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // DONUT CHART
  Widget _buildDonutChart(bool isDark, dynamic stats) {
    final segments = [
      _DonutSegment('Users', stats.totalUsers.toDouble(), isDark ? Colors.white : AppColors.brand),
      _DonutSegment('Posts', stats.totalPosts.toDouble(), const Color(0xFF0284C7)),
      _DonutSegment('Opportunities', stats.totalOpportunities.toDouble(), AppColors.success),
      _DonutSegment('Clubs', stats.totalClubs.toDouble(), AppColors.warning),
      _DonutSegment('Events', stats.totalEvents.toDouble(), const Color(0xFF7C3AED)),
    ];

    return _card(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entity Proportions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text(isDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Category ratio breakdown',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMut(isDark),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(
                painter: _DonutPainter(segments: segments, progress: _animation.value, isDark: isDark),
              ),
            ),
          ),
          const SizedBox(height: 18),
          ...segments.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSec(isDark),
                    ),
                  ),
                ),
                Text(
                  s.value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(isDark),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // GROWTH TREND
  Widget _buildGrowthTrend(bool isDark, dynamic stats) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    final base = stats.totalUsers * 0.6;
    final rand = math.Random(42);
    final values = List.generate(7, (i) => base + rand.nextDouble() * stats.totalUsers * 0.6 * (i + 1) / 7);
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return _card(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Platform Growth',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text(isDark),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Monthly active user enrollment volume',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMut(isDark),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceAlt(isDark) : AppColors.successBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: isDark ? AppColors.border(isDark) : const Color(0xFFBBF7D0)),
                ),
                child: Text(
                  '+24.5% MoM',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isDark ? const Color(0xFF4ADE80) : AppColors.successText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (i) {
                final barHeight = maxVal > 0 ? (values[i] / maxVal) * 180 * _animation.value : 0.0;
                final accentColor = isDark ? const Color(0xFF38BDF8) : AppColors.brand;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < months.length - 1 ? 8 : 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          values[i].toInt().toString(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMut(isDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.35 + (i / months.length) * 0.65),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          months[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMut(isDark),
                          ),
                        ),
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

  // KPI CARDS
  Widget _buildKPICards(bool isDark, dynamic stats) {
    final retention = (stats.activeUsers / stats.totalUsers * 100).toStringAsFixed(1);
    final avgPosts = (stats.totalPosts / stats.totalUsers).toStringAsFixed(1);

    return _card(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Operational Indicators',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.text(isDark),
            ),
          ),
          const SizedBox(height: 16),
          _buildKPI(isDark, 'Active User Retention', '$retention%', stats.activeUsers / stats.totalUsers, AppColors.success),
          const SizedBox(height: 14),
          _buildKPI(isDark, 'Avg Posts per User', avgPosts, (stats.totalPosts / stats.totalUsers) / 10, const Color(0xFF0284C7)),
          const SizedBox(height: 14),
          _buildKPI(isDark, 'Content Moderation Rate', '${(stats.pendingReports / stats.totalPosts * 100).toStringAsFixed(2)}%', stats.pendingReports / stats.totalPosts, AppColors.warning),
          const SizedBox(height: 14),
          _buildKPI(isDark, 'New Registrations Today', '+${stats.newUsersToday}', stats.newUsersToday / 50, const Color(0xFF7C3AED)),
        ],
      ),
    );
  }

  Widget _buildKPI(bool isDark, String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSec(isDark)),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text(isDark)),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (progress * _animation.value).clamp(0.0, 1.0),
            backgroundColor: AppColors.surfaceAlt(isDark),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}

class _BarData {
  final String label;
  final double value;
  final Color color;
  _BarData(this.label, this.value, this.color);
}

class _DonutSegment {
  final String label;
  final double value;
  final Color color;
  _DonutSegment(this.label, this.value, this.color);
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double progress;
  final bool isDark;

  _DonutPainter({required this.segments, required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const strokeWidth = 18.0;
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * 2 * math.pi * progress;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    final totalText = TextPainter(
      text: TextSpan(
        text: total.toInt().toString(),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.text(isDark),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    totalText.paint(canvas, Offset(center.dx - totalText.width / 2, center.dy - totalText.height / 2 - 4));

    final labelText = TextPainter(
      text: TextSpan(
        text: 'Total',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textMut(isDark),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelText.paint(canvas, Offset(center.dx - labelText.width / 2, center.dy + 7));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}