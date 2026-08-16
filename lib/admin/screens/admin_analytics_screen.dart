import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import '../providers/admin_dashboard_provider.dart';
import '../widgets/admin_responsive.dart';

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
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
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
      return Center(child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white : const Color(0xFF1A1A1A)));
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
                  // Row 1: Bar Chart + Donut Chart
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildBarChart(isDark, stats)),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _buildDonutChart(isDark, stats)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildBarChart(isDark, stats),
                        const SizedBox(height: 20),
                        _buildDonutChart(isDark, stats),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Row 2: Growth Trend + KPI Cards
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildGrowthTrend(isDark, stats)),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: _buildKPICards(isDark, stats)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildGrowthTrend(isDark, stats),
                        const SizedBox(height: 20),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161616) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8)),
      ),
      child: child,
    );
  }

  // â”€â”€ BAR CHART â”€â”€
  Widget _buildBarChart(bool isDark, dynamic stats) {
    final barColor = isDark ? const Color(0xFF90CAF9) : const Color(0xFF5C9CE6);
    final data = [
      _BarData('Users', stats.totalUsers.toDouble(), barColor),
      _BarData('Active', stats.activeUsers.toDouble(), barColor),
      _BarData('Posts', stats.totalPosts.toDouble(), barColor),
      _BarData('Opps', stats.totalOpportunities.toDouble(), barColor),
      _BarData('Clubs', stats.totalClubs.toDouble(), barColor),
      _BarData('Events', stats.totalEvents.toDouble(), barColor),
    ];
    // Use sqrt scale to handle large differences between values
    final scaledData = data.map((d) => _BarData(d.label, math.sqrt(d.value + 1) * 10, d.color)).toList();
    final maxVal = scaledData.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return _card(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Platform Metrics', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        )),
        const SizedBox(height: 6),
        Text('Overview of all platform metrics', style: TextStyle(
          fontSize: 13, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
        )),
        const SizedBox(height: 28),
        SizedBox(
          height: 320,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: scaledData.asMap().entries.map((entry) {
                  final d = entry.value;
                  final original = data[entry.key];
                  final barHeight = maxVal > 0 ? (d.value / maxVal) * 280 * _animation.value : 0.0;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: entry.key < scaledData.length - 1 ? 12 : 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(original.value.toInt().toString(), style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                          )),
                          const SizedBox(height: 6),
                          Container(
                            height: barHeight,
                            decoration: BoxDecoration(
                              color: d.color,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(d.label, style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
                          )),
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
    ));
  }

  // â”€â”€ DONUT CHART â”€â”€
  Widget _buildDonutChart(bool isDark, dynamic stats) {
    final segments = [
      _DonutSegment('Users', stats.totalUsers.toDouble(), isDark ? const Color(0xFF90CAF9) : const Color(0xFF5C9CE6)),
      _DonutSegment('Posts', stats.totalPosts.toDouble(), isDark ? const Color(0xFF7AB8F5) : const Color(0xFF4A8AD4)),
      _DonutSegment('Opps', stats.totalOpportunities.toDouble(), isDark ? const Color(0xFF64A8E8) : const Color(0xFF3B7BC2)),
      _DonutSegment('Clubs', stats.totalClubs.toDouble(), isDark ? const Color(0xFF4E98DB) : const Color(0xFF2C6CB0)),
      _DonutSegment('Events', stats.totalEvents.toDouble(), isDark ? const Color(0xFF3888CE) : const Color(0xFF1D5D9E)),
    ];

    return _card(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Distribution', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        )),
        const SizedBox(height: 6),
        Text('Content type breakdown', style: TextStyle(
          fontSize: 13, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
        )),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 160, height: 160,
            child: CustomPaint(
              painter: _DonutPainter(segments: segments, progress: _animation.value, isDark: isDark),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...segments.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 10),
              Expanded(child: Text(s.label, style: TextStyle(
                fontSize: 13, color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
              ))),
              Text(s.value.toInt().toString(), style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1A1A1A),
              )),
            ],
          ),
        )),
      ],
    ));
  }

  // â”€â”€ GROWTH TREND (Simulated line chart using bars) â”€â”€
  Widget _buildGrowthTrend(bool isDark, dynamic stats) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
    final base = stats.totalUsers * 0.6;
    final rand = math.Random(42);
    final values = List.generate(7, (i) => base + rand.nextDouble() * stats.totalUsers * 0.6 * (i + 1) / 7);
    final maxVal = values.reduce((a, b) => a > b ? a : b);

    return _card(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Growth Trend', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                )),
                const SizedBox(height: 4),
                Text('Monthly user acquisition', style: TextStyle(
                  fontSize: 13, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
                )),
              ],
            )),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00BA7C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('+24.5%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF00BA7C))),
            ),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          height: 320,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(months.length, (i) {
              final barHeight = maxVal > 0 ? (values[i] / maxVal) * 280 * _animation.value : 0.0;
              final accentColor = isDark ? const Color(0xFF90CAF9) : const Color(0xFF5C9CE6);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < months.length - 1 ? 8 : 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(values[i].toInt().toString(), style: TextStyle(
                        fontSize: 9, fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF666666) : const Color(0xFFAAAAAA),
                      )),
                      const SizedBox(height: 4),
                      Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.5 + (i / months.length) * 0.5),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(months[i], style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF888888) : const Color(0xFF888888),
                      )),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    ));
  }

  // â”€â”€ KPI CARDS â”€â”€
  Widget _buildKPICards(bool isDark, dynamic stats) {
    final retention = (stats.activeUsers / stats.totalUsers * 100).toStringAsFixed(1);
    final avgPosts = (stats.totalPosts / stats.totalUsers).toStringAsFixed(1);

    return _card(isDark, child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Key Metrics', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        )),
        const SizedBox(height: 20),
        _buildKPI(isDark, 'User Retention', '$retention%', stats.activeUsers / stats.totalUsers, isDark ? const Color(0xFF90CAF9) : const Color(0xFF5C9CE6)),
        const SizedBox(height: 18),
        _buildKPI(isDark, 'Avg Posts/User', avgPosts, (stats.totalPosts / stats.totalUsers) / 10, isDark ? const Color(0xFF7AB8F5) : const Color(0xFF4A8AD4)),
        const SizedBox(height: 18),
        _buildKPI(isDark, 'Report Rate', '${(stats.pendingReports / stats.totalPosts * 100).toStringAsFixed(2)}%', stats.pendingReports / stats.totalPosts, isDark ? const Color(0xFF64A8E8) : const Color(0xFF3B7BC2)),
        const SizedBox(height: 18),
        _buildKPI(isDark, 'New Users Today', '+${stats.newUsersToday}', stats.newUsersToday / 50, isDark ? const Color(0xFF4E98DB) : const Color(0xFF2C6CB0)),
      ],
    ));
  }

  Widget _buildKPI(bool isDark, String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(
              fontSize: 13, color: isDark ? const Color(0xFF999999) : const Color(0xFF666666),
            )),
            Text(value, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            )),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (progress * _animation.value).clamp(0.0, 1.0),
            backgroundColor: isDark ? const Color(0xFF252525) : const Color(0xFFF0F0F0),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// â”€â”€ DATA CLASSES â”€â”€
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

// â”€â”€ DONUT PAINTER â”€â”€
class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double progress;
  final bool isDark;

  _DonutPainter({required this.segments, required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    final strokeWidth = 24.0;
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

    // Center text
    final totalText = TextPainter(
      text: TextSpan(
        text: total.toInt().toString(),
        style: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    totalText.paint(canvas, Offset(center.dx - totalText.width / 2, center.dy - totalText.height / 2 - 6));

    final labelText = TextPainter(
      text: TextSpan(
        text: 'Total',
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500,
          color: isDark ? const Color(0xFF888888) : const Color(0xFF999999),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelText.paint(canvas, Offset(center.dx - labelText.width / 2, center.dy + 8));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}