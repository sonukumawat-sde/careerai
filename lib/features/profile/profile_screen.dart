import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_gradients.dart';
import '../../services/supabase_service.dart';
import '../auth/auth_service.dart';
import '../home/home_provider.dart';
import 'widgets/profile_widgets.dart';
import '../../core/widgets/user_avatar.dart';
import 'edit_profile_screen.dart';
import 'personal_details_screen.dart';
import 'career_preferences_screen.dart';
import 'notifications_settings_screen.dart';
import 'language_screen.dart';
import 'privacy_security_screen.dart';
import 'support/help_support_screen.dart';
import 'support/about_screen.dart';
import 'support/terms_privacy_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../premium/premium_screen.dart';
/// Profile screen — premium, branding-heavy. Account/settings sab yaha.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsProvider);
    final resumeCount = stats.when(data: (s) => '${s.hasResume ? 1 : 0}', loading: () => '-', error: (_, __) => '0');
    final appCount = stats.when(data: (s) => '${s.applicationsCount}', loading: () => '-', error: (_, __) => '0');
    final intCount = stats.when(data: (s) => '${s.interviewsCount}', loading: () => '-', error: (_, __) => '0');
    final user = SupabaseService.currentUser;
    final email = user?.email ?? '';
    final nameAsync = ref.watch(userNameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          // ---- Hero card ----
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppBrand.purple, AppBrand.violet, AppBrand.indigo],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppBrand.violet.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                   const UserAvatar(radius: 34, fontSize: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          nameAsync.when(
                            data: (name) => Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                            loading: () => const Text('Loading...',
                                style: TextStyle(color: Colors.white)),
                            error: (_, __) => const Text('User',
                                style: TextStyle(color: Colors.white)),
                          ),
                          const SizedBox(height: 3),
                          Text(email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontSize: 13)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Fresher',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                     _StatItem(value: resumeCount, label: 'Resumes'),
                      _StatDivider(),
                    _StatItem(value: appCount, label: 'Applications'),
                      _StatDivider(),
                    _StatItem(value: intCount, label: 'Interviews'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- Profile completion ----
          stats.when(
            data: (s) => ProfileCompletion(percent: s.profileCompletion),
            loading: () => const ProfileCompletion(percent: 0),
            error: (_, __) => const ProfileCompletion(percent: 0),
          ),

          // ---- Account (brand colors) ----
          const ProfileSectionLabel('ACCOUNT'),
          ProfileTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Name, phone, photo',
            color: AppBrand.violet,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          ProfileTile(
            icon: Icons.school_outlined,
            title: 'Personal Details',
            subtitle: 'Education, skills, experience',
            color: AppBrand.indigo,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PersonalDetailsScreen()),
            ),
          ),
         ProfileTile(
            icon: Icons.tune,
            title: 'Career Preferences',
            subtitle: 'Target role, salary, location',
            color: AppBrand.blueAccent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CareerPreferencesScreen()),
            ),
          ),

          // ---- Settings (brand colors) ----
          const ProfileSectionLabel('SETTINGS'),
         ProfileTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            color: AppBrand.violet,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const NotificationsSettingsScreen()),
            ),
          ),
         ProfileTile(
            icon: Icons.language,
            title: 'Language',
            color: AppBrand.indigo,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LanguageScreen()),
            ),
          ),
         ProfileTile(
            icon: Icons.lock_outline,
            title: 'Privacy & Security',
            color: AppBrand.blueAccent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacySecurityScreen()),
            ),
          ),

          // ---- Support (brand colors) ----
          const ProfileSectionLabel('SUPPORT'),
         ProfileTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            color: AppBrand.violet,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
            ),
          ),
        ProfileTile(
            icon: Icons.info_outline,
            title: 'About CareerAI',
            color: AppBrand.indigo,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AboutScreen()),
            ),
          ),
         ProfileTile(
            icon: Icons.star_border,
            title: 'Rate Us',
            color: AppBrand.blueAccent,
            onTap: () async {
              final uri = Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.example.careerai');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
         ProfileTile(
            icon: Icons.share_outlined,
            title: 'Share App',
            color: AppBrand.violet,
            onTap: () => Share.share(
              'Check out CareerAI — the AI-powered app to land your dream job! 🚀\n\nDownload: https://careerai.app',
            ),
          ),
        ProfileTile(
            icon: Icons.article_outlined,
            title: 'Terms & Privacy Policy',
            color: AppBrand.indigo,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TermsPrivacyScreen()),
            ),
          ),
          const SizedBox(height: 24),

          // ---- Upgrade to Pro banner (bada, gradient) ----
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppBrand.purple, AppBrand.violet],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppBrand.violet.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.workspace_premium,
                      color: Color(0xFFFBBF24), size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CareerAI Pro',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text('Unlock unlimited AI tools & features.',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              height: 1.3)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                 onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('Upgrade',
                        style: TextStyle(
                            color: AppBrand.violet,
                            fontWeight: FontWeight.w800,
                            fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- Logout ----
          InkWell(
            onTap: () => _confirmLogout(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                  SizedBox(width: 10),
                  Text('Logout',
                      style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('CareerAI v1.0.0',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Kya aap sure ho logout karna chahte ho?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await AuthService.logout();
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}