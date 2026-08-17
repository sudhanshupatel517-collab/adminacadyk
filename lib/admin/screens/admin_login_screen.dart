import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../../common/providers/theme_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController(text: 'admin@acadyk.edu');
  final _passwordController = TextEditingController(text: 'SuperAdmin2026!');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    final auth = context.read<AdminAuthProvider>();
    final ok = await auth.login(_emailController.text.trim(), _passwordController.text);
    if (mounted) {
      setState(() => _isLoading = false);
      if (!ok && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage!), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _handleOtpLogin() async {
    setState(() => _isLoading = true);
    final auth = context.read<AdminAuthProvider>();
    await auth.ssoLogin();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1117) : const Color(0xFFFAFAFA);
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE5E7EB);
    final textColor = isDark ? Colors.white : const Color(0xFF0A1128);
    final subtextColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF4B5563);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Theme Toggle in Top Right
            Positioned(
              top: 16,
              right: 20,
              child: IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 22,
                  color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827),
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  final tp = context.read<ThemeProvider>();
                  tp.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                },
              ),
            ),

            // Scrollable Content Center
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Logos: Acadyk | MITS-DU
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.change_history_rounded, color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Acadyk',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              letterSpacing: -0.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Container(width: 1, height: 24, color: borderColor),
                          ),
                          Image.asset(
                            'assets/images/mits_logo.png',
                            width: 26,
                            height: 26,
                            errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 26, color: Color(0xFF0F4C81)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MITS-DU',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F4C81),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // 2. Headline: "Administration Portal"
                      Text(
                        'Administration Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF0A1128),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Dashed line with center shield icon
                      Row(
                        children: [
                          Expanded(
                            child: CustomPaint(
                              size: const Size(double.infinity, 1),
                              painter: _DashedLinePainter(color: isDark ? const Color(0xFF484F58) : const Color(0xFF9CA3AF)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: isDark ? const Color(0xFFD29922) : const Color(0xFFB45309),
                            ),
                          ),
                          Expanded(
                            child: CustomPaint(
                              size: const Size(double.infinity, 1),
                              painter: _DashedLinePainter(color: isDark ? const Color(0xFF484F58) : const Color(0xFF9CA3AF)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 4. Tagline: "Secure  Centralized  Reliable"
                      Text(
                        'Secure   Centralized   Reliable',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF1E293B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 5. Main Card: "Administrator Log in"
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Title
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 26,
                                  color: isDark ? const Color(0xFF79C0FF) : const Color(0xFF0F4C81),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Administrator Log in',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Official Email Address Input
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.mail_outline_rounded, size: 20, color: subtextColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Official Email Address',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: subtextColor,
                                          ),
                                        ),
                                        TextField(
                                          controller: _emailController,
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.only(top: 2, bottom: 2),
                                            hintText: 'Enter your registered email address',
                                            hintStyle: TextStyle(fontSize: 12, color: subtextColor.withValues(alpha: 0.7)),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Password Input
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline_rounded, size: 20, color: subtextColor),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Password',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: subtextColor,
                                          ),
                                        ),
                                        TextField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.only(top: 2, bottom: 2),
                                            hintText: 'Enter your password',
                                            hintStyle: TextStyle(fontSize: 12, color: subtextColor.withValues(alpha: 0.7)),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      size: 18,
                                      color: subtextColor,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Forgot your password link
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Password reset instructions sent to registered institutional email.')),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    'Forgot your password?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1E88E5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sign In to Administration Button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFF1F6FEB) : const Color(0xFF0A1128),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Sign In to Administration',
                                            style: TextStyle(fontFamily: 'serif', fontSize: 15, fontWeight: FontWeight.w700),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(Icons.arrow_forward_rounded, size: 18),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // "or continue with" Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: borderColor)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'or continue with',
                                    style: TextStyle(fontSize: 11, color: subtextColor),
                                  ),
                                ),
                                Expanded(child: Divider(color: borderColor)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Continue with One-Time Password Button
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : _handleOtpLogin,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: textColor,
                                  backgroundColor: isDark ? const Color(0xFF21262D) : const Color(0xFFF3F4F6),
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.security_rounded, size: 18, color: Color(0xFF0F4C81)),
                                    Expanded(
                                      child: Text(
                                        'Continue with One-Time Password',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontFamily: 'serif', fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF6B7280)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Authorized Access Only Note Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E170A) : const Color(0xFFFFFDF5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF8C6D1F) : const Color(0xFFFDE68A),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 20,
                                    color: isDark ? const Color(0xFFD29922) : const Color(0xFFB45309),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Authorized Access Only',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? const Color(0xFFF0883E) : const Color(0xFF92400E),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'This portal is restricted to authorized Acadyk administrators and institutional personnel.',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF4B5563),
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 6. Bottom Card: Built on Institutional Collaboration
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Built on Institutional Collaboration',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(width: 32, height: 2, color: const Color(0xFFC59B27)),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Quantaforze
                                Column(
                                  children: [
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(Icons.all_inclusive_rounded, color: Colors.white, size: 24),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Quantaforze',
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),

                                // Handshake
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Container(width: 1, height: 34, color: borderColor),
                                      const SizedBox(width: 14),
                                      const Icon(Icons.handshake_outlined, size: 34, color: Color(0xFFC59B27)),
                                      const SizedBox(width: 14),
                                      Container(width: 1, height: 34, color: borderColor),
                                    ],
                                  ),
                                ),

                                // MITS-DU
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/mits_logo.png',
                                      width: 46,
                                      height: 46,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 46, color: Color(0xFF0F4C81)),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'MITS-DU',
                                      style: TextStyle(
                                        fontFamily: 'serif',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Connecting technology, education, and opportunity.',
                              style: TextStyle(
                                fontSize: 12,
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}