import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/premium/premium_service.dart';
import '../../../core/premium/premium_widgets.dart';
import '../../premium/premium_screen.dart';
import 'interview_data.dart';
import 'interview_service.dart';
import 'interview_setup_screen.dart';
import 'interview_result_screen.dart';

/// Interview Practice — landing. Type cards + history + gating.
class InterviewHomeScreen extends StatefulWidget {
  const InterviewHomeScreen({super.key});

  @override
  State<InterviewHomeScreen> createState() => _InterviewHomeScreenState();
}

class _InterviewHomeScreenState extends State<InterviewHomeScreen> {
  List<InterviewSession> _sessions = [];
  bool _loading = true;
  int _remaining = 2;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await InterviewService.getSessions();
    final left = await PremiumService.remaining(
        'interview_practice', FeatureLimits.interviewPractice);
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _remaining = left;
      _loading = false;
    });
  }

  Future<void> _startInterview(InterviewTypeInfo typeInfo) async {
    // Gating check
    final canUse = await PremiumService.canUse(
        'interview_practice', FeatureLimits.interviewPractice);
    if (!canUse) {
      if (!mounted) return;
      showPremiumLock(
        context,
        feature: 'Interview Practice',
        benefits: const [
          'Unlimited mock interviews',
          'Voice & video practice (coming soon)',
          'Company-specific preparation',
          'Detailed performance reports',
        ],
      );
      return;
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InterviewSetupScreen(type: typeInfo.type),
      ),
    );
    _load(); // wapas aane pe refresh
  }

  void _openResult(InterviewSession s) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InterviewResultScreen(session: s)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Interview Practice'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _heroCard(),
          const SizedBox(height: 16),
          SmartUsageCard(
            remaining: _remaining,
            total: FeatureLimits.interviewPractice,
            price: '₹149',
            onUpgrade: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Choose Interview Type',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ...kInterviewTypes.map(_typeCard),

          const SizedBox(height: 26),
          const Text('Past Interviews',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _history(),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(22),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.mic_none_rounded,
                color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          const Text('AI Mock Interview',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text(
              'Practice with real interview questions, get instant AI feedback, and boost your confidence.',
              style: TextStyle(
                  color: Colors.white70, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _typeCard(InterviewTypeInfo info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _startInterview(info),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEEF1F5)),
            boxShadow: [
              BoxShadow(
                color: AppBrand.violet.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppBrand.violet.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(info.emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.title,
                        style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(info.description,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                            height: 1.3)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Color(0xFFCBD5E1), size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _history() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(color: AppBrand.violet)),
      );
    }
    if (_sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF1F5)),
        ),
        child: const Column(
          children: [
            Icon(Icons.history, color: Color(0xFFCBD5E1), size: 36),
            SizedBox(height: 10),
            Text('No interviews yet',
                style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Start your first mock interview above.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
      );
    }
    return Column(
      children: _sessions.map((s) {
        final c = s.overallScore >= 75
            ? const Color(0xFF22C55E)
            : s.overallScore >= 50
                ? const Color(0xFFF59E0B)
                : const Color(0xFFEF4444);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _openResult(s),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEF1F5)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text('${s.overallScore}',
                        style: TextStyle(
                            color: c,
                            fontSize: 16,
                            fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.role.isEmpty ? s.typeLabel : s.role,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${s.typeLabel} · ${s.difficultyLabel} · ${s.questions.length} Qs',
                            style: const TextStyle(
                                color: Color(0xFF94A3B8), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(s.timeAgo,
                      style: const TextStyle(
                          color: Color(0xFFCBD5E1), fontSize: 11)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}