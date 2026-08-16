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
  bool _usePassword = false;
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

  Future<void> _handleSso() async {
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
    final textColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtextColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF4B5563);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Theme toggle top-right
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

            // Main Scrollable Container
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Logos Header: Acadyk | MITS-DU
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
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Container(width: 1, height: 22, color: borderColor),
                          ),
                          Image.asset(
                            'assets/images/mits_logo.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 24, color: Color(0xFF0F4C81)),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MITS-DU',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F4C81),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // 2. Large Serif Heading: "Next Opportunity Starts Here"
                      Text(
                        'Next Opportunity Starts Here',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFE6EDF3) : const Color(0xFF0A1128),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Dashed line separator
                      CustomPaint(
                        size: const Size(double.infinity, 1),
                        painter: _DashedLinePainter(color: isDark ? const Color(0xFF484F58) : const Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 16),

                      // 4. Subtitle
                      Text(
                        'Discover competitions, jobs, and internships\ndesigned to shape your future.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: subtextColor,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 5. Continue with Mits-DU Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSso,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF21262D) : const Color(0xFF1E293B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  'assets/images/mits_logo.png',
                                  width: 18,
                                  height: 18,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 18, color: Color(0xFF0F4C81)),
                                ),
                              ),
                              const Expanded(
                                child: Text(
                                  'Continue with Mits–DU',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 6. OR Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: borderColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: subtextColor),
                            ),
                          ),
                          Expanded(child: Divider(color: borderColor)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 7. Email Field
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF161B22) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: TextField(
                          controller: _emailController,
                          style: TextStyle(fontSize: 14, color: textColor),
                          decoration: InputDecoration(
                            hintText: 'Enter your  email',
                            hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF6E7681) : const Color(0xFF9CA3AF)),
                            prefixIcon: Icon(Icons.mail_outline_rounded, size: 18, color: isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 8. Login via Password link
                      Align(
                        alignment: Alignment.centerRight,
                        child: InkWell(
                          onTap: () => setState(() => _usePassword = !_usePassword),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(
                              _usePassword ? 'Login via OTP' : 'Login via Password',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E88E5)),
                            ),
                          ),
                        ),
                      ),

                      // Password Field (if toggled)
                      if (_usePassword) ...[
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF161B22) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderColor),
                          ),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(fontSize: 14, color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Password',
                              hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF6E7681) : const Color(0xFF9CA3AF)),
                              prefixIcon: Icon(Icons.lock_outline_rounded, size: 18, color: isDark ? const Color(0xFF8B949E) : const Color(0xFF6B7280)),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // 9. Continue with OTP / Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? const Color(0xFF238636) : const Color(0xFF26201B),
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
                                  children: [
                                    Text(
                                      _usePassword ? 'Sign In' : 'Continue with OTP',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 10. Terms Note
                      Text.rich(
                        TextSpan(
                          text: 'By signing in, you agree to our ',
                          style: TextStyle(fontSize: 11, color: subtextColor),
                          children: const [
                            TextSpan(text: 'Terms of Service', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.w600)),
                            TextSpan(text: ' and '),
                            TextSpan(text: 'Privacy Policy.', style: TextStyle(color: Color(0xFF1E88E5), fontWeight: FontWeight.w600)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // 11. Card 1: Powering the Ecosystem
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Powering the Ecosystem',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(width: 28, height: 2, color: const Color(0xFFC59B27)),
                            const SizedBox(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Quantaforze
                                Column(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
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
                                      Container(width: 1, height: 32, color: borderColor),
                                      const SizedBox(width: 12),
                                      const Icon(Icons.handshake_outlined, size: 32, color: Color(0xFFC59B27)),
                                      const SizedBox(width: 12),
                                      Container(width: 1, height: 32, color: borderColor),
                                    ],
                                  ),
                                ),

                                // MITS-DU
                                Column(
                                  children: [
                                    Image.asset(
                                      'assets/images/mits_logo.png',
                                      width: 44,
                                      height: 44,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 44, color: Color(0xFF0F4C81)),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 12. Card 2: Guided by Excellence
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Guided by Excellence',
                              style: TextStyle(
                                fontFamily: 'serif',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(width: 28, height: 2, color: const Color(0xFFC59B27)),
                            const SizedBox(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Photo
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: borderColor, width: 2),
                                    image: const DecorationImage(
                                      image: AssetImage('assets/images/somraj_avatar.jpg'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dr. Rajni Ranjan Singh Makwana',
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Assoc. Prof. & Head, CAI',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E88E5),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Expert in fostering innovation and academic excellence with years of experience in guiding impactful projects and student development.',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: subtextColor,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 13. Footer: Visit our more work | quantaforze.com
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.language_rounded, size: 16, color: subtextColor),
                          const SizedBox(width: 6),
                          Text(
                            'Visit our more work',
                            style: TextStyle(fontSize: 12, color: subtextColor),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Container(width: 1, height: 14, color: borderColor),
                          ),
                          Text(
                            'quantaforze.com',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF0F4C81)),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.open_in_new_rounded, size: 13, color: isDark ? const Color(0xFF58A6FF) : const Color(0xFF0F4C81)),
                        ],
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