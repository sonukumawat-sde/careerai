import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../core/theme/app_gradients.dart';
import 'widgets/auth_widgets.dart';
import 'widgets/career_logo.dart';
import 'auth_service.dart';
import '../profile/profile_service.dart';
import '../../core/widgets/main_shell.dart';
import '../../core/widgets/celebration_dialog.dart';

/// Login + Signup on a single page (toggle). Premium light theme. Live auth.
class AuthScreen extends StatefulWidget {
  final String? pendingRole;
  const AuthScreen({super.key, this.pendingRole});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _rememberMe = true;
  bool _loading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    if (widget.pendingRole != null) _isLogin = false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();


    
    // Capture referral code NOW (controller may be cleared later)
    final referralCode = _referralController.text.trim();

    if (email.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
      _showMessage('Saari fields bharo.');
      return;
    }
    if (password.length < 6) {
      _showMessage('Password kam se kam 6 characters ka ho.');
      return;
    }

    setState(() => _loading = true);

    final result = _isLogin
        ? await AuthService.login(email: email, password: password)
        : await AuthService.signUp(
            name: name, email: email, password: password);

    if (!mounted) return;

    await result.match(
      (failure) async {
        setState(() => _loading = false);
        _showMessage(failure.message);
      },
      (user) async {
        // 1. Role save karo (signup pe)
        if (!_isLogin && widget.pendingRole != null) {
          await ProfileService.updateRole(widget.pendingRole!);
        }

        // 2. Referral apply karo (sirf naye signup pe, agar code diya)
        if (!_isLogin && referralCode.isNotEmpty) {
          // Session ready hone do (thoda ruko), warna auth.uid() null aata hai
          await Future.delayed(const Duration(milliseconds: 800));
          final refResult =
              await AuthService.applyReferralCode(referralCode);

          if (mounted && refResult.toString().contains('success')) {
            // Loading band karke celebration dikhao
            setState(() => _loading = false);
            await showCelebrationAndWait(
              context,
              title: 'Referral Applied! 🎉',
              message: 'You earned bonus points. Welcome to CareerAI!',
              points: 25,
            );
          }
        }

        if (!mounted) return;
        setState(() => _loading = false);
        _showMessage(
          _isLogin ? 'Welcome back!' : 'Account created! Welcome 🎉',
          success: true,
        );

        // 3. Home pe le jao
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      },
    );
  }
Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    final result = await AuthService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    result.match(
      (failure) => _showMessage(failure.message),
      (user) {
        _showMessage('Welcome! 🎉', success: true);
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      },
    );
  }
  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppBrand.violet : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Center(child: CareerLogo(height: 170)),
              const SizedBox(height: 24),
              Text(
                _isLogin ? 'Welcome back 👋' : 'Create account 🚀',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isLogin
                    ? 'Login to continue your journey towards your dream career.'
                    : 'Start your journey towards your dream career.',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 26),
              if (!_isLogin) ...[
                GlassField(
                  controller: _nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 14),
              ],
              GlassField(
                controller: _emailController,
                hint: 'Email address',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              GlassField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                isPassword: true,
                obscure: _obscure,
                onToggleObscure: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(height: 14),
              // Referral code field — sirf signup me dikhe
              if (!_isLogin) ...[
                GlassField(
                  controller: _referralController,
                  hint: 'Referral code (optional)',
                  icon: Icons.card_giftcard,
                ),
                const SizedBox(height: 14),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                          activeColor: AppBrand.violet,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Remember me',
                          style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                  if (_isLogin)
                    GestureDetector(
                      onTap: () {},
                      child: const Text('Forgot Password?',
                          style: TextStyle(
                              color: AppBrand.violet,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              GradientButton(
                label: _isLogin ? 'Login' : 'Create Account',
                loading: _loading,
                onTap: _submit,
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or continue with',
                        style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500)),
                  ),
                  const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SocialButton(
                      icon: const GoogleLogo(size: 20),
                      label: 'Continue with Google',
                      onTap: _googleSignIn,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? "Don't have an account? "
                        : 'Already have an account? ',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin ? 'Sign up' : 'Login',
                      style: const TextStyle(
                          color: AppBrand.violet,
                          fontSize: 14,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}