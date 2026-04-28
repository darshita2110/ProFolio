import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:profolio/core/routing/app_router.dart';
import 'package:profolio/core/theme/app_theme.dart';
import 'package:profolio/features/auth/application/auth_controller.dart';
import 'package:profolio/core/providers/firebase_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _formKey      = GlobalKey<FormState>();

  late AnimationController _fadeAnim;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  late AnimationController _pulseAnim;
  late Animation<double>   _pulse;

  bool _isLogin = true;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _fadeAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade  = CurvedAnimation(parent: _fadeAnim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeAnim, curve: Curves.easeOutCubic));
    _fadeAnim.forward();

    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.08, end: 0.18)
        .animate(CurvedAnimation(parent: _pulseAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _nameCtrl.dispose();
    _fadeAnim.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w._%+\-]+@[\w.\-]+\.[a-zA-Z]{2,}$').hasMatch(v))
      return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  String? _validateName(String? v) {
    if (v == null || v.isEmpty) return 'Name is required';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ctrl = ref.read(authControllerProvider.notifier);
    if (_isLogin) {
      await ctrl.signInWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } else {
      await ctrl.registerWithEmail(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        name: _nameCtrl.text.trim(),
      );
    }
    if (!mounted) return;
    final err = ref.read(authControllerProvider).error;
    if (err != null) _showErr(err);
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13))),
      ]),
      backgroundColor: AppTheme.error,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  void _toggleMode() {
    _fadeAnim.reset();
    setState(() => _isLogin = !_isLogin);
    _fadeAnim.forward();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (_, next) {
      next.whenData((u) { if (u != null && mounted) context.go(AppRoutes.profile); });
    });

    final loading = ref.watch(authControllerProvider).isLoading;
    final isDark = AppTheme.isDark(context);
    final bgBase = AppTheme.bgBaseOf(context);
    final textPrimary = AppTheme.textPrimaryOf(context);
    final textMuted = AppTheme.textMutedOf(context);
    final borderColor = AppTheme.borderOf(context);
    final cardColor = AppTheme.bgCardOf(context);

    return Scaffold(
      backgroundColor: bgBase,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Stack(children: [
              Positioned(
                top: -100,
                right: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.primary.withOpacity(_pulse.value),
                      AppTheme.primary.withOpacity(_pulse.value * 0.3),
                      Colors.transparent,
                    ], stops: const [0.0, 0.4, 1.0]),
                  ),
                ),
              ),
              Positioned(
                bottom: -80,
                left: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.accent.withOpacity(_pulse.value * 0.6),
                      AppTheme.accent.withOpacity(_pulse.value * 0.15),
                      Colors.transparent,
                    ], stops: const [0.0, 0.4, 1.0]),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                left: MediaQuery.of(context).size.width * 0.5,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.primaryGlow.withOpacity(_pulse.value * 0.35),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
            ]),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryGlow],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person_outline_rounded,
                                color: Color(0xFF0F0E0C), size: 20),
                          ),
                          const SizedBox(width: 10),
                          Text('ProFolio',
                              style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 22, color: textPrimary)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => ref.read(themeModeProvider.notifier).toggle(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark
                                        ? AppTheme.primary
                                        : AppTheme.accent)
                                        .withOpacity(0.15),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, anim) =>
                                    RotationTransition(
                                        turns: Tween(begin: 0.75, end: 1.0).animate(anim),
                                        child: FadeTransition(opacity: anim, child: child)),
                                child: Icon(
                                  isDark
                                      ? Icons.light_mode_rounded
                                      : Icons.dark_mode_rounded,
                                  key: ValueKey(isDark),
                                  size: 18,
                                  color: isDark ? AppTheme.primaryGlow : AppTheme.accent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 44),

                      
                      Text(
                        _isLogin ? 'Welcome\nback.' : 'Build your\nstory.',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 46,
                          color: textPrimary,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isLogin
                            ? 'Sign in to access your professional portfolio'
                            : 'Create an account to showcase your journey',
                        style: GoogleFonts.dmSans(
                            fontSize: 14, color: textMuted, height: 1.5),
                      ),

                      const SizedBox(height: 36),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : AppTheme.lightBorder,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                              blurRadius: 32,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              if (!_isLogin) ...[
                                _field(
                                  ctrl: _nameCtrl,
                                  label: 'Full Name',
                                  hint: 'Jane Doe',
                                  icon: Icons.person_outline_rounded,
                                  validator: _validateName,
                                  enabled: !loading,
                                ),
                                const SizedBox(height: 14),
                              ],
                              _field(
                                ctrl: _emailCtrl,
                                label: 'Email',
                                hint: 'you@example.com',
                                icon: Icons.mail_outline_rounded,
                                validator: _validateEmail,
                                keyboard: TextInputType.emailAddress,
                                enabled: !loading,
                              ),
                              const SizedBox(height: 14),
                              _field(
                                ctrl: _passwordCtrl,
                                label: 'Password',
                                hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                validator: _validatePassword,
                                obscure: _obscure,
                                enabled: !loading,
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                    color: textMuted,
                                  ),
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                              ),

                              if (_isLogin) ...[
                                const SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: loading ? null : _forgotPassword,
                                    child: Text(
                                      'Forgot password?',
                                      style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),

                              _primaryButton(
                                label: _isLogin ? 'Sign In' : 'Create Account',
                                onTap: loading ? null : _submit,
                                loading: loading,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _isLogin
                                  ? "Don't have an account?  "
                                  : 'Already have an account?  ',
                              style: GoogleFonts.dmSans(
                                  fontSize: 14, color: textMuted),
                            ),
                            GestureDetector(
                              onTap: loading ? null : _toggleMode,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  _isLogin ? 'Sign Up' : 'Sign In',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primary,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppTheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboard,
    bool obscure = false,
    bool enabled = true,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      keyboardType: keyboard,
      obscureText: obscure,
      enabled: enabled,
      style: GoogleFonts.dmSans(
          color: AppTheme.textPrimaryOf(context), fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onTap,
    required bool loading,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: onTap != null
              ? const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryGlow],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: onTap == null ? AppTheme.primary.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: onTap != null
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF0F0E0C)),
                  ))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(label,
                      style: GoogleFonts.dmSans(
                          color: const Color(0xFF0F0E0C),
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded,
                      color: Color(0xFF0F0E0C), size: 17),
                ]),
        ),
      ),
    );
  }

  void _forgotPassword() {
    final emailCtrl = TextEditingController(text: _emailCtrl.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurfaceOf(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: AppTheme.borderOf(context),
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text('Reset Password',
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 22,
                    color: AppTheme.textPrimaryOf(context))),
            const SizedBox(height: 6),
            Text("We'll send a reset link to your email.",
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppTheme.textMutedOf(context))),
            const SizedBox(height: 20),
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.dmSans(
                  color: AppTheme.textPrimaryOf(context)),
              decoration:
                  const InputDecoration(hintText: 'you@example.com'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (emailCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                await ref.read(authControllerProvider.notifier)
                    .resetPassword(email: emailCtrl.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Reset link sent! Check your inbox.',
                        style: GoogleFonts.dmSans(color: Colors.white)),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ));
                }
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}