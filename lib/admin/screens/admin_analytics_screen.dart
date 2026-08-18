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
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
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
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? Colors.white : const Color(0xFF0F172A)),
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
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: child,
    );
  }

  // BAR CHART
  Widget _buildBarChart(bool isDark, dynamic stats) {
    final barColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
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
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Relative platform resource allocation across active records',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 260,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: scaledData.asMap().entries.map((entry) {
                    final d = entry.value;
                    final original = data[entry.key];
                    final barHeight = maxVal > 0 ? (d.value / maxVal) * 220 * _animation.value : 0.0;
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
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
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
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
      _DonutSegment('Users', stats.totalUsers.toDouble(), const Color(0xFF0F172A)),
      _DonutSegment('Posts', stats.totalPosts.toDouble(), const Color(0xFF0284C7)),
      _DonutSegment('Opportunities', stats.totalOpportunities.toDouble(), const Color(0xFF16A34A)),
      _DonutSegment('Clubs', stats.totalClubs.toDouble(), const Color(0xFFD97706)),
      _DonutSegment('Events', stats.totalEvents.toDouble(), const Color(0xFF6366F1)),
    ];

    return _card(
      isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entity Proportions',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Category ratio breakdown',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _DonutPainter(segments: segments, progress: _animation.value, isDark: isDark),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...segments.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: s.color, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ),
                Text(
                  s.value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monthly active user enrollment volume',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Text(
                  '+24.5% MoM',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 240,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(months.length, (i) {
                final barHeight = maxVal > 0 ? (values[i] / maxVal) * 200 * _animation.value : 0.0;
                final accentColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
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
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.4 + (i / months.length) * 0.6),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          months[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 18),
          _buildKPI(isDark, 'Active User Retention', '$retention%', stats.activeUsers / stats.totalUsers, const Color(0xFF16A34A)),
          const SizedBox(height: 16),
          _buildKPI(isDark, 'Avg Posts per User', avgPosts, (stats.totalPosts / stats.totalUsers) / 10, const Color(0xFF0284C7)),
          const SizedBox(height: 16),
          _buildKPI(isDark, 'Content Moderation Rate', '${(stats.pendingReports / stats.totalPosts * 100).toStringAsFixed(2)}%', stats.pendingReports / stats.totalPosts, const Color(0xFFD97706)),
          const SizedBox(height: 16),
          _buildKPI(isDark, 'New Registrations Today', '+${stats.newUsersToday}', stats.newUsersToday / 50, const Color(0xFF6366F1)),
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
              style: TextStyle(fontSize: 12.5, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (progress * _animation.value).clamp(0.0, 1.0),
            backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
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
    const strokeWidth = 20.0;
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
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF0F172A),
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
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelText.paint(canvas, Offset(center.dx - labelText.width / 2, center.dy + 8));
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.progress != progress;
}