import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_gradients.dart';
import '../profile/profile_screen.dart';
import '../menu/app_menu.dart';
import '../notifications/notification_screen.dart';
import 'home_provider.dart';
import 'widgets/home_widgets.dart';
import 'widgets/progress_widgets.dart';
import 'widgets/activity_widgets.dart';
import '../../core/widgets/user_avatar.dart';
import '../premium/premium_screen.dart';
import '../tools/resume_analyzer/analyzer_screen.dart';
import '../tools/resume_builder/template_chooser_screen.dart';
import '../coach/coach_screen.dart';
import '../tools/interview/interview_home_screen.dart';
import '../jobs/jobs_screen.dart';

/// Home dashboard — clean, real data only.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key, this.onGoToJobs});

  final VoidCallback? onGoToJobs;

  void _openAnalyzer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AnalyzerScreen()),
    );
  }

  void _openBuilder(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TemplateChooserScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.watch(firstNameProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: const AppMenu(),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppBrand.violet,
          onRefresh: () async {
            ref.invalidate(homeStatsProvider);
            ref.invalidate(recentActivityProvider);
            ref.invalidate(suggestionsProvider);
            await ref.read(homeStatsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              // ---- Top bar ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () => Scaffold.of(context).openDrawer(),
                      child: const Icon(Icons.menu,
                          color: Color(0xFF0F172A), size: 26),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NotificationScreen(),
                            ),
                          );
                        },
                        child: const Icon(Icons.notifications_outlined,
                            color: Color(0xFF0F172A), size: 26),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: const UserAvatar(radius: 20, fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ---- Greeting ----
              firstName.when(
                data: (name) => Text('Hello, $name! 👋',
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5)),
                loading: () => const Text('Hello! 👋',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
                error: (_, __) => const Text('Hello! 👋',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 26,
                        fontWeight: FontWeight.w800)),
              ),
              const SizedBox(height: 4),
              const Text(
                  "Let's make today another step towards your dream career.",
                  style: TextStyle(
                      color: Color(0xFF64748B), fontSize: 14, height: 1.4)),
              const SizedBox(height: 20),

              // ---- Resume Score hero card (REAL) ----
              ref.watch(homeStatsProvider).when(
                    data: (stats) => ResumeScoreCard(
                      score: stats.hasResume ? stats.resumeScore : 0,
                      change: 0,
                      onImprove: () => _openAnalyzer(context),
                      onViewAnalysis: () => _openAnalyzer(context),
                    ),
                    loading: () => ResumeScoreCard(
                      score: 0,
                      change: 0,
                      onImprove: () => _openAnalyzer(context),
                      onViewAnalysis: () => _openAnalyzer(context),
                    ),
                    error: (_, __) => ResumeScoreCard(
                      score: 0,
                      change: 0,
                      onImprove: () => _openAnalyzer(context),
                      onViewAnalysis: () => _openAnalyzer(context),
                    ),
                  ),
              const SizedBox(height: 28),

              // ---- Continue Your Journey ----
              const SectionHeader(
                  title: 'Continue Your Journey', actionText: ''),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: JourneyCard(
                      icon: Icons.description_outlined,
                      title: 'Resume Analyzer',
                      subtitle: 'Get AI feedback',
                      color: AppBrand.violet,
                      onTap: () => _openAnalyzer(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: JourneyCard(
                      icon: Icons.edit_document,
                      title: 'Resume Builder',
                      subtitle: 'ATS friendly',
                      color: AppBrand.blueAccent,
                      onTap: () => _openBuilder(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: JourneyCard(
                      icon: Icons.mic_none_rounded,
                      title: 'Interview',
                      subtitle: 'Practice & improve',
                      color: const Color(0xFF22C55E),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const InterviewHomeScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: JourneyCard(
                      icon: Icons.chat_bubble_outline,
                      title: 'Career Coach',
                      subtitle: 'AI guidance',
                      color: const Color(0xFFF59E0B),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CoachScreen()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              JourneyCard(
                icon: Icons.work_outline,
                title: 'Job Hub',
                subtitle: 'Find & track opportunities',
                color: const Color(0xFFEC4899),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const JobsScreen()),
                ),
                fullWidth: true,
              ),
              const SizedBox(height: 28),

              // ---- Career Progress (REAL 4 rings) ----
              const SectionHeader(title: 'Career Progress', actionText: ''),
              const SizedBox(height: 14),
              ref.watch(homeStatsProvider).when(
                    data: (stats) => _progressCard(stats),
                    loading: () => _progressCardShimmer(),
                    error: (_, __) => _progressCard(HomeStats.empty),
                  ),
              const SizedBox(height: 28),

              // ---- AI Suggestions (REAL) ----
              _suggestionsSection(context, ref),
              const SizedBox(height: 20),

              // ---- Recent Activity (REAL) ----
              _activitySection(ref),
              const SizedBox(height: 20),

              // ---- Premium banner ----
              PremiumBanner(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- CAREER PROGRESS (real rings) ----------
  Widget _progressCard(HomeStats stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEF1F5)),
        boxShadow: [
          BoxShadow(
            color: AppBrand.violet.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          MiniStatRing(
            value: stats.hasResume ? '${stats.resumeScore}%' : '—',
            label: 'Resume',
            progress: stats.resumeScore / 100,
            color: AppBrand.violet,
          ),
          MiniStatRing(
            value: stats.interviewsCount > 0
                ? '${stats.avgInterviewScore}%'
                : '—',
            label: 'Interview',
            progress: stats.avgInterviewScore / 100,
            color: AppBrand.indigo,
          ),
          MiniStatRing(
            value: '${stats.applicationsCount}',
            label: 'Applied',
            progress: (stats.applicationsCount / 20).clamp(0.0, 1.0),
            color: AppBrand.blueAccent,
          ),
          MiniStatRing(
            value: '${stats.profileCompletion}%',
            label: 'Profile',
            progress: stats.profileCompletion / 100,
            color: AppBrand.purple,
          ),
        ],
      ),
    );
  }

  Widget _progressCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppBrand.violet),
      ),
    );
  }

  // ---------- AI SUGGESTIONS (real) ----------
  Widget _suggestionsSection(BuildContext context, WidgetRef ref) {
    final iconFor = <int, IconData>{
      0: Icons.trending_up,
      1: Icons.account_circle_outlined,
      2: Icons.mic_none_rounded,
      3: Icons.work_outline,
    };
    final colorFor = <int, Color>{
      0: AppBrand.violet,
      1: const Color(0xFF22C55E),
      2: AppBrand.indigo,
      3: const Color(0xFFF59E0B),
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppBrand.violet, size: 20),
              SizedBox(width: 8),
              Text('Suggestions for You',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          ref.watch(suggestionsProvider).when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('No suggestions right now.',
                          style: TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 13)),
                    );
                  }
                  return Column(
                    children: [
                      for (int i = 0; i < list.length; i++) ...[
                        if (i > 0)
                          const Divider(
                              height: 1, color: Color(0xFFF1F5F9)),
                        SuggestionItem(
                          icon: iconFor[i] ?? Icons.lightbulb_outline,
                          iconColor: colorFor[i] ?? AppBrand.violet,
                          text: list[i],
                          onTap: () {},
                        ),
                      ],
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppBrand.violet)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
        ],
      ),
    );
  }

  // ---------- RECENT ACTIVITY (real) ----------
  Widget _activitySection(WidgetRef ref) {
    Color dotFor(String type) {
      switch (type) {
        case 'resume':
          return const Color(0xFF22C55E);
        case 'interview':
          return AppBrand.violet;
        case 'application':
          return AppBrand.blueAccent;
        default:
          return const Color(0xFFF59E0B);
      }
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ref.watch(recentActivityProvider).when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                          'No activity yet. Start by analyzing your resume or practicing an interview.',
                          style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              height: 1.4)),
                    );
                  }
                  return Column(
                    children: [
                      for (int i = 0; i < entries.length; i++)
                        ActivityItem(
                          dotColor: dotFor(entries[i].type),
                          text: entries[i].text,
                          time: entries[i].timeAgo,
                          isLast: i == entries.length - 1,
                        ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                      child: CircularProgressIndicator(
                          color: AppBrand.violet)),
                ),
                error: (_, __) => const SizedBox.shrink(),
              ),
        ],
      ),
    );
  }
}