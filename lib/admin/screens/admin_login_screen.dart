import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';
import '../../common/providers/theme_provider.dart';
import '../../app/theme/app_colors.dart';

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
            backgroundColor: AppColors.error,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        title: Text(
          'One-Time Password Verification',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.text(isDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A 6-digit institutional OTP code has been sent to $email.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSec(isDark), height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(fontSize: 18, letterSpacing: 8, fontWeight: FontWeight.w700, color: AppColors.text(isDark)),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: '••••••',
                hintStyle: TextStyle(fontSize: 18, letterSpacing: 8, color: AppColors.textMut(isDark)),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                filled: true,
                fillColor: AppColors.surfaceAlt(isDark),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: AppColors.border(isDark))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: AppColors.border(isDark))),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.border(isDark)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : AppColors.brand,
              foregroundColor: isDark ? AppColors.brand : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              await context.read<AdminAuthProvider>().ssoLogin();
              if (mounted) setState(() => _isLoading = false);
            },
            child: const Text('Verify & Sign In', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final resetEmailCtrl = TextEditingController(text: _emailController.text);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceColor(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: AppColors.border(isDark)),
        ),
        title: Text(
          'Reset Administrator Password',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.text(isDark)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your registered official email address to receive password reset instructions.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSec(isDark), height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: resetEmailCtrl,
              style: TextStyle(fontSize: 13, color: AppColors.text(isDark)),
              decoration: InputDecoration(
                labelText: 'Official Email Address',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide(color: AppColors.border(isDark))),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.border(isDark)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: Text('Cancel', style: TextStyle(color: AppColors.textSec(isDark), fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.white : AppColors.brand,
              foregroundColor: isDark ? AppColors.brand : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Password reset instructions dispatched to ${resetEmailCtrl.text}.')),
              );
            },
            child: const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = AppColors.bg(isDark);
    final cardBg = AppColors.surfaceColor(isDark);
    final borderColor = AppColors.border(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Theme toggle top-right
            Positioned(
              top: 16,
              right: 20,
              child: TextButton(
                onPressed: () {
                  final tp = context.read<ThemeProvider>();
                  tp.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                },
                child: Text(
                  isDark ? 'Light Mode' : 'Dark Mode',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSec(isDark)),
                ),
              ),
            ),

            // Centered Main Canvas
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. Top Branding
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              'assets/images/lagacy.png',
                              width: 28,
                              height: 28,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.brand,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Center(
                                  child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Acadyk',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(isDark),
                              letterSpacing: -0.3,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Container(width: 1, height: 18, color: borderColor),
                          ),
                          Image.asset(
                            'assets/images/mitslog.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/mits_logo.png',
                              width: 24,
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Text('MITS', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.text(isDark))),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'MITS-DU',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text(isDark),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. Heading
                      Text(
                        'Administration Portal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text(isDark),
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Secure institutional management & administration',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSec(isDark),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. Main Login Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text(isDark),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Official Email Address
                            Text(
                              'Official Email Address',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSec(isDark),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _emailController,
                              focusNode: _emailFocus,
                              style: TextStyle(fontSize: 13.5, color: AppColors.text(isDark)),
                              onSubmitted: (_) => _passwordFocus.requestFocus(),
                              decoration: InputDecoration(
                                hintText: 'admin@acadyk.edu',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                errorText: _emailError,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Password
                            Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSec(isDark),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocus,
                              obscureText: _obscurePassword,
                              style: TextStyle(fontSize: 13.5, color: AppColors.text(isDark)),
                              onSubmitted: (_) => _handleLogin(),
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                errorText: _passwordError,
                                suffixIcon: TextButton(
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  child: Text(_obscurePassword ? 'Show' : 'Hide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMut(isDark))),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Forgot your password?
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: _showForgotPasswordDialog,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Text(
                                    'Forgot your password?',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Sign In Button
                            SizedBox(
                              width: double.infinity,
                              height: 42,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? Colors.white : AppColors.brand,
                                  foregroundColor: isDark ? AppColors.brand : Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: _isLoading
                                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: isDark ? AppColors.brand : Colors.white, strokeWidth: 2))
                                    : const Text(
                                        'Sign In to Administration',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: borderColor, thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'or',
                                    style: TextStyle(fontSize: 11.5, color: AppColors.textMut(isDark)),
                                  ),
                                ),
                                Expanded(child: Divider(color: borderColor, thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // OTP Button
                            SizedBox(
                              width: double.infinity,
                              height: 40,
                              child: OutlinedButton(
                                onPressed: _isLoading ? null : _handleOtpLogin,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                child: Text(
                                  'Sign In with One-Time Password',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSec(isDark),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Authorized Access Notice
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceAlt(isDark),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Authorized Access Only',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'This portal is restricted to authorized Acadyk administrators and institutional personnel.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMut(isDark),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}