import '../../common/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_auth_provider.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF111827),
            ),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              final tp = context.read<ThemeProvider>();
              tp.setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF7F7F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/lagacy.png',
                    width: 56, height: 56, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(child: Text('A', style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24,
                      ))),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Admin Console', style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5,
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                )),
                const SizedBox(height: 6),
                Text('Sign in to manage your platform', style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
                )),
                const SizedBox(height: 36),

                // Form Card
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161616) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF252525) : const Color(0xFFE8E8E8)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email
                        Text('Email', style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                        )),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                          decoration: _inputDecoration(isDark, 'admin@acadyk.edu', Icons.mail_outline_rounded),
                          validator: (v) => v?.contains('@') == true ? null : 'Enter a valid email',
                        ),
                        const SizedBox(height: 20),

                        // Password
                        Text('Password', style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCCCCCC) : const Color(0xFF555555),
                        )),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                          decoration: _inputDecoration(isDark, '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022', Icons.lock_outline_rounded).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                size: 18, color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => v != null && v.length >= 6 ? null : 'Password must be at least 6 characters',
                        ),
                        const SizedBox(height: 28),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
                              foregroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                              disabledBackgroundColor: isDark ? const Color(0xFF333333) : const Color(0xFFCCCCCC),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: _isLoading
                                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark ? const Color(0xFF666666) : Colors.white,
                                  ))
                                : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Protected administrative area', style: TextStyle(
                  fontSize: 12,
                  color: isDark ? const Color(0xFF444444) : const Color(0xFFCCCCCC),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? const Color(0xFF555555) : const Color(0xFFCCCCCC),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, size: 18, color: isDark ? const Color(0xFF555555) : const Color(0xFFCCCCCC)),
      filled: true,
      fillColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F7F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? const Color(0xFF252525) : const Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: isDark ? Colors.white : const Color(0xFF1A1A1A), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFEF5350)),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final success = await context.read<AdminAuthProvider>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Invalid credentials. Please try again.'),
          backgroundColor: const Color(0xFFC62828),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}