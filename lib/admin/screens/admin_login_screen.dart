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
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  // Design Tokens based on institutional reference
  static const Color kNavyPrimary = Color(0xFF07143D);
  static const Color kNavySecondary = Color(0xFF263453);
  static const Color kGoldAccent = Color(0xFFB58A3A);
  static const Color kGoldLight = Color(0xFFF7F2E8);
  static const Color kGoldBorder = Color(0xFFE8D8B8);
  static const Color kBorder = Color(0xFFE4E6EA);
  static const Color kTextMuted = Color(0xFF667085);
  static const Color kLinkBlue = Color(0xFF1E88E5);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _emailError = 'Please enter your official email address');
      return false;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailError = 'Please enter a valid email address');
      return false;
    }
    if (password.isEmpty) {
      setState(() => _passwordError = 'Please enter your password');
      return false;
    }
    if (password.length < 6) {
      setState(() => _passwordError = 'Password must be at least 6 characters');
      return false;
    }
    return true;
  }

  Future<void> _handleLogin() async {
    if (!_validate()) return;

    setState(() => _isLoading = true);
    final auth = context.read<AdminAuthProvider>();
    final ok = await auth.login(_emailController.text.trim(), _passwordController.text);
    if (mounted) {
      setState(() => _isLoading = false);
      if (!ok && auth.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage!),
            backgroundColor: const Color(0xFFEF5350),
          ),
        );
      }
    }
  }

  Future<void> _handleOtpLogin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _emailError = 'Please enter your official email for OTP');
      return;
    }

    final otpController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.shield_outlined, color: kNavyPrimary, size: 22),
            SizedBox(width: 10),
            Text(
              'One-Time Password',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: kNavyPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A 6-digit institutional OTP code has been sent to $email.',
              style: const TextStyle(fontSize: 13, color: kTextMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 18, letterSpacing: 8, fontWeight: FontWeight.w700, color: kNavyPrimary),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '••••••',
                hintStyle: const TextStyle(fontSize: 18, letterSpacing: 8, color: Color(0xFFCBD5E1)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: kTextMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kNavyPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await context.read<AdminAuthProvider>().ssoLogin();
              if (mounted) setState(() => _isLoading = false);
            },
            child: const Text('Verify & Sign In'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text(
          'Reset Administrator Password',
          style: TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: kNavyPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your registered official email address to receive password reset instructions.',
              style: TextStyle(fontSize: 13, color: kTextMuted, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: resetEmailCtrl,
              style: const TextStyle(fontSize: 13, color: kNavyPrimary),
              decoration: InputDecoration(
                labelText: 'Official Email Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: kTextMuted))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kNavyPrimary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset instructions dispatched to ${resetEmailCtrl.text}.')),
              );
            },
            child: const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D1117) : Colors.white;
    final cardBg = isDark ? const Color(0xFF161B22) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : kBorder;
    final brandingTextColor = isDark ? const Color(0xFFF0F6FC) : kNavyPrimary;
    final primaryTextColor = isDark ? const Color(0xFFF0F6FC) : kNavyPrimary;
    final secondaryTextColor = isDark ? const Color(0xFF8B949E) : kNavySecondary;
    final mutedTextColor = isDark ? const Color(0xFF8B949E) : kTextMuted;

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
                  color: isDark ? const Color(0xFFF0F6FC) : kNavyPrimary,
                ),
                tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  final tp = context.read<ThemeProvider>();
                  tp.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                },
              ),
            ),

            // Centered Main Canvas
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 490),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Top Branding: [lagacy.png] Acadyk  |  [mitslog.png] MITS-DU (Same Deep Navy Color)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              'assets/images/lagacy.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: kNavyPrimary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.change_history_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Acadyk',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: brandingTextColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(width: 1, height: 24, color: borderColor),
                          ),
                          Image.asset(
                            'assets/images/mitslog.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/mits_logo.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.school, size: 28, color: kNavyPrimary),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'MITS-DU',
                            style: TextStyle(
                              fontFamily: 'serif',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: brandingTextColor,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. Large Heading: "Administration Portal" (Attractive serif typography)
                      Text(
                        'Administration Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: primaryTextColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Gold Decorative Divider with Center Shield Outline
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: kGoldAccent.withValues(alpha: isDark ? 0.4 : 0.6),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CustomPaint(
                              size: const Size(16, 18),
                              painter: _ShieldIconPainter(color: kGoldAccent),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: kGoldAccent.withValues(alpha: isDark ? 0.4 : 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 4. Tagline: "Secure  Centralized  Reliable"
                      Text(
                        'Secure   Centralized   Reliable',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 5. Main Login Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(26),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card Header: [Shield] Administrator Log in
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomPaint(
                                  size: const Size(22, 26),
                                  painter: _ShieldFilledPainter(color: primaryTextColor),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Administrator Log in',
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),

                            // Field 1: Official Email Address
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0D1117) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _emailError != null ? const Color(0xFFEF5350) : borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.mail_outline_rounded, size: 20, color: secondaryTextColor),
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
                                            color: primaryTextColor,
                                          ),
                                        ),
                                        TextField(
                                          controller: _emailController,
                                          focusNode: _emailFocus,
                                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: primaryTextColor),
                                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.only(top: 2, bottom: 2),
                                            hintText: 'Enter your registered email address',
                                            hintStyle: TextStyle(fontSize: 12.5, color: mutedTextColor.withValues(alpha: 0.7)),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_emailError != null) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(_emailError!, style: const TextStyle(fontSize: 11, color: Color(0xFFEF5350))),
                              ),
                            ],
                            const SizedBox(height: 12),

                            // Field 2: Password
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0D1117) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _passwordError != null ? const Color(0xFFEF5350) : borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_outline_rounded, size: 20, color: secondaryTextColor),
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
                                            color: primaryTextColor,
                                          ),
                                        ),
                                        TextField(
                                          controller: _passwordController,
                                          focusNode: _passwordFocus,
                                          obscureText: _obscurePassword,
                                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: primaryTextColor),
                                          onSubmitted: (_) => _handleLogin(),
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding: const EdgeInsets.only(top: 2, bottom: 2),
                                            hintText: 'Enter your password',
                                            hintStyle: TextStyle(fontSize: 12.5, color: mutedTextColor.withValues(alpha: 0.7)),
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
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      size: 18,
                                      color: mutedTextColor,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                ],
                              ),
                            ),
                            if (_passwordError != null) ...[
                              const SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(_passwordError!, style: const TextStyle(fontSize: 11, color: Color(0xFFEF5350))),
                              ),
                            ],
                            const SizedBox(height: 6),

                            // Forgot your password?
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: _showForgotPasswordDialog,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    'Forgot your password?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: kLinkBlue,
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
                                  backgroundColor: isDark ? const Color(0xFF1F6FEB) : kNavyPrimary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Sign In to Administration',
                                            style: TextStyle(
                                              fontFamily: 'serif',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                            ),
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
                                Expanded(child: Divider(color: borderColor, thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'or continue with',
                                    style: TextStyle(fontSize: 11.5, color: mutedTextColor),
                                  ),
                                ),
                                Expanded(child: Divider(color: borderColor, thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Continue with One-Time Password Button (Shield with lock inside + Right Arrow)
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : _handleOtpLogin,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryTextColor,
                                  backgroundColor: isDark ? const Color(0xFF21262D) : Colors.white,
                                  side: BorderSide(color: borderColor, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: CustomPaint(
                                        size: const Size(18, 20),
                                        painter: _ShieldWithLockPainter(color: primaryTextColor),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Text(
                                        'Continue with One-Time Password',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'serif',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_rounded, size: 16, color: primaryTextColor),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Authorized Access Only Notice Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E170A) : kGoldLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF8C6D1F) : kGoldBorder,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 18,
                                    color: kGoldAccent,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Authorized Access Only',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? const Color(0xFFF0883E) : const Color(0xFF785116),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'This portal is restricted to authorized Acadyk administrators and institutional personnel.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isDark ? const Color(0xFFC9D1D9) : const Color(0xFF594D3B),
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

class _ShieldIconPainter extends CustomPainter {
  final Color color;
  _ShieldIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.6);
    path.cubicTo(
      size.width, size.height * 0.85,
      size.width * 0.5, size.height,
      size.width * 0.5, size.height,
    );
    path.cubicTo(
      size.width * 0.5, size.height,
      0, size.height * 0.85,
      0, size.height * 0.6,
    );
    path.lineTo(0, size.height * 0.2);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShieldFilledPainter extends CustomPainter {
  final Color color;
  _ShieldFilledPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Outer shield stroke
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.6);
    path.cubicTo(
      size.width, size.height * 0.85,
      size.width * 0.5, size.height,
      size.width * 0.5, size.height,
    );
    path.cubicTo(
      size.width * 0.5, size.height,
      0, size.height * 0.85,
      0, size.height * 0.6,
    );
    path.lineTo(0, size.height * 0.2);
    path.close();

    canvas.drawPath(path, strokePaint);

    // Inner filled shield
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final innerPath = Path();
    innerPath.moveTo(size.width * 0.5, size.height * 0.16);
    innerPath.lineTo(size.width * 0.82, size.height * 0.3);
    innerPath.lineTo(size.width * 0.82, size.height * 0.58);
    innerPath.cubicTo(
      size.width * 0.82, size.height * 0.76,
      size.width * 0.5, size.height * 0.88,
      size.width * 0.5, size.height * 0.88,
    );
    innerPath.cubicTo(
      size.width * 0.5, size.height * 0.88,
      size.width * 0.18, size.height * 0.76,
      size.width * 0.18, size.height * 0.58,
    );
    innerPath.lineTo(size.width * 0.18, size.height * 0.3);
    innerPath.close();

    canvas.drawPath(innerPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShieldWithLockPainter extends CustomPainter {
  final Color color;
  _ShieldWithLockPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    // Outer shield stroke
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width, size.height * 0.2);
    path.lineTo(size.width, size.height * 0.6);
    path.cubicTo(
      size.width, size.height * 0.85,
      size.width * 0.5, size.height,
      size.width * 0.5, size.height,
    );
    path.cubicTo(
      size.width * 0.5, size.height,
      0, size.height * 0.85,
      0, size.height * 0.6,
    );
    path.lineTo(0, size.height * 0.2);
    path.close();

    canvas.drawPath(path, strokePaint);

    // Lock body
    final lockBodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final lockRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.6),
      width: size.width * 0.44,
      height: size.height * 0.3,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(lockRect, const Radius.circular(2)), lockBodyPaint);

    // Lock shackle
    final shacklePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final shackleRect = Rect.fromCenter(
      center: Offset(size.width * 0.5, size.height * 0.44),
      width: size.width * 0.26,
      height: size.height * 0.22,
    );
    canvas.drawArc(shackleRect, 3.14159, 3.14159, false, shacklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}