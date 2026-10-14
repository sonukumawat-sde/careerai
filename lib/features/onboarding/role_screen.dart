import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../../services/supabase_service.dart';
import '../auth/auth_screen.dart';
import '../auth/widgets/auth_widgets.dart';
import '../profile/profile_service.dart';
import '../../core/widgets/main_shell.dart';

/// Role selection — user batata hai wo kaun hai.
/// Ye database (profiles table) me save hota hai, personalization ke liye.
class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  String? _selected;
  bool _loading = false;

  final List<_Role> _roles = const [
    _Role('Student', 'College me padh raha hoon', Icons.school_outlined),
    _Role('Fresher', 'Naukri dhundh raha hoon', Icons.person_search_outlined),
    _Role('Experienced', 'Kaam kar raha hoon', Icons.work_outline),
    _Role('Career Switcher', 'Field badalna chahta hoon', Icons.swap_horiz),
  ];

  Future<void> _continue() async {
    if (_selected == null) return;

    // Agar user logged in hai -> database me save karo.
    // Agar nahi (pehli baar) -> abhi signup pe bhej do, role signup ke baad save hoga.
    if (SupabaseService.isLoggedIn) {
      setState(() => _loading = true);
      final result = await ProfileService.updateRole(_selected!);
      if (!mounted) return;
      setState(() => _loading = false);

      result.match(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        ),
        (_) => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainShell()),
        ),
      );
    } else {
      // Role ko temporarily le jao signup screen tak.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AuthScreen(pendingRole: _selected),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Tell us about yourself',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Taaki hum tumhare liye perfect career guidance de sakein.',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 32),

              // Role options
              ..._roles.map((role) {
                final isSelected = _selected == role.title;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: InkWell(
                    onTap: () => setState(() => _selected = role.title),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppBrand.violet.withValues(alpha: 0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppBrand.violet
                              : const Color(0xFFE2E8F0),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppBrand.violet
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(role.icon,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(role.title,
                                    style: const TextStyle(
                                        color: Color(0xFF0F172A),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                                const SizedBox(height: 2),
                                Text(role.subtitle,
                                    style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: AppBrand.violet, size: 24),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              GradientButton(
                label: 'Continue',
                loading: _loading,
                onTap: _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Role {
  final String title;
  final String subtitle;
  final IconData icon;
  const _Role(this.title, this.subtitle, this.icon);
}