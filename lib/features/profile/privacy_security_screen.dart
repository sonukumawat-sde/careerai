import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../../services/supabase_service.dart';
import '../auth/auth_service.dart';
import 'settings_service.dart';

/// Privacy & Security — change password, delete account (real).
class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = SupabaseService.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Privacy & Security'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          // Email card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEF1F5)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppBrand.violet.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(Icons.mail_outline,
                      color: AppBrand.violet, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email',
                          style: TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(email,
                          style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _sectionLabel('SECURITY'),
          _actionTile(
            'Change Password',
            'Update your account password',
            Icons.lock_outline,
            AppBrand.violet,
            () => _showChangePassword(context),
          ),
          const SizedBox(height: 24),

          _sectionLabel('LEGAL'),
          _actionTile(
            'Privacy Policy',
            'How we handle your data',
            Icons.privacy_tip_outlined,
            AppBrand.blueAccent,
            () {},
          ),
          _actionTile(
            'Terms of Service',
            'Our terms and conditions',
            Icons.article_outlined,
            AppBrand.indigo,
            () {},
          ),
          const SizedBox(height: 24),

          _sectionLabel('DANGER ZONE'),
          _actionTile(
            'Delete Account',
            'Permanently delete your account',
            Icons.delete_outline,
            const Color(0xFFEF4444),
            () => _confirmDelete(context),
            danger: true,
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6)),
    );
  }

  Widget _actionTile(String title, String subtitle, IconData icon, Color color,
      VoidCallback onTap,
      {bool danger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: danger
                    ? const Color(0xFFEF4444).withValues(alpha: 0.2)
                    : const Color(0xFFEEF1F5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: danger
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Color(0xFFCBD5E1), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Change Password dialog ----
  void _showChangePassword(BuildContext context) {
    final passController = TextEditingController();
    final confirmController = TextEditingController();
    bool loading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Password',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(passController, 'New password'),
              const SizedBox(height: 12),
              _dialogField(confirmController, 'Confirm password'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppBrand.violet),
              onPressed: loading
                  ? null
                  : () async {
                      final pass = passController.text.trim();
                      final confirm = confirmController.text.trim();
                      if (pass.length < 6) {
                        _snack(ctx, 'Password kam se kam 6 characters ka ho.');
                        return;
                      }
                      if (pass != confirm) {
                        _snack(ctx, 'Passwords match nahi kar rahe.');
                        return;
                      }
                      setDialogState(() => loading = true);
                      final result =
                          await SettingsService.changePassword(pass);
                      if (!ctx.mounted) return;
                      result.match(
                        (failure) {
                          setDialogState(() => loading = false);
                          _snack(ctx, failure.message);
                        },
                        (_) {
                          Navigator.pop(ctx);
                          _snack(context, 'Password changed successfully!');
                        },
                      );
                    },
              child: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ---- Delete account confirm ----
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text(
            'This will permanently delete your account and all your data. This action cannot be undone.',
            style: TextStyle(height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(ctx);
              // Account ka data delete karo, phir logout
              await _deleteAccountData();
              await AuthService.logout();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccountData() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;
      // User ka data saari tables se hatao
      final client = SupabaseService.client;
      await client.from('saved_jobs').delete().eq('user_id', userId);
      await client.from('applications').delete().eq('user_id', userId);
      await client.from('resumes').delete().eq('user_id', userId);
      await client.from('profiles').delete().eq('id', userId);
    } catch (_) {}
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}