import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/premium/premium_service.dart';
import '../../core/premium/premium_widgets.dart';
import 'menu_widgets.dart';
import 'saved_jobs_screen.dart';
import 'application_tracker_screen.dart';
import 'my_resumes_screen.dart';
import 'refer_earn_screen.dart';
import 'rewards_screen.dart';
import '../premium/premium_screen.dart';
import '../tools/interview/interview_home_screen.dart';
import '../roadmap/roadmap_screen.dart';

/// App ka side menu (hamburger drawer) — premium, branding colors.
class AppMenu extends ConsumerWidget {
  const AppMenu({super.key});

  /// Career Roadmap kholo — premium gating ke saath.
  Future<void> _openRoadmap(BuildContext context) async {
    Navigator.pop(context); // drawer band
    final isPremium = await PremiumService.isPremium();
    if (!context.mounted) return;
    if (!isPremium) {
      showPremiumLock(
        context,
        feature: 'Career Roadmap',
        benefits: const [
          'AI-generated personalized roadmap',
          'Step-by-step phases with skills & actions',
          'Realistic timeline to your goal',
          'Save & revisit your roadmaps',
        ],
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RoadmapScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: const Color(0xFFF8FAFC),
      width: MediaQuery.of(context).size.width * 0.82,
      child: Column(
        children: [
          // ---- Branded header ----
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppBrand.purple, AppBrand.violet, AppBrand.indigo],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.trending_up_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text('CareerAI',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Your AI-Powered Career Partner',
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13)),
              ],
            ),
          ),

          // ---- Menu items ----
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                const MenuSectionLabel('MY WORK'),
                MenuItem(
                  icon: Icons.description_outlined,
                  title: 'My Resumes',
                  color: AppBrand.violet,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const MyResumesScreen()),
                    );
                  },
                ),
                MenuItem(
                  icon: Icons.bookmark_border,
                  title: 'Saved Jobs',
                  color: AppBrand.blueAccent,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const SavedJobsScreen()),
                    );
                  },
                ),
                MenuItem(
                  icon: Icons.assignment_outlined,
                  title: 'Application Tracker',
                  color: const Color(0xFF22C55E),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ApplicationTrackerScreen()),
                    );
                  },
                ),
                MenuItem(
                  icon: Icons.history,
                  title: 'Interview History',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const InterviewHomeScreen()),
                    );
                  },
                ),
                MenuItem(
                  icon: Icons.map_outlined,
                  title: 'Career Roadmap',
                  color: const Color(0xFFEC4899),
                  badge: 'Pro',
                  onTap: () => _openRoadmap(context),
                ),
                const MenuSectionLabel('REWARDS'),
                MenuItem(
                  icon: Icons.card_giftcard,
                  title: 'Refer & Earn',
                  color: const Color(0xFF14B8A6),
                  badge: 'New',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const ReferEarnScreen()),
                    );
                  },
                ),
                MenuItem(
                  icon: Icons.emoji_events_outlined,
                  title: 'Rewards & Achievements',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const RewardsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // ---- Bottom: Upgrade banner ----
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppGradients.buttonGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: Color(0xFFFBBF24), size: 26),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CareerAI Pro',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800)),
                          Text('Unlock all features',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('Upgrade',
                          style: TextStyle(
                              color: AppBrand.violet,
                              fontWeight: FontWeight.w800,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}