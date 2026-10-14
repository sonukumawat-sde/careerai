import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';
import 'resume_builder_data.dart';
import 'steps/personal_info_step.dart';
import 'steps/summary_step.dart';
import 'steps/experience_step.dart';
import 'steps/education_step.dart';
import 'steps/skills_step.dart';
import 'resume_preview_screen.dart';
import '../../../core/premium/premium_service.dart';
import '../../../core/premium/premium_widgets.dart';
import '../../premium/premium_screen.dart';
import 'steps/projects_step.dart';
import 'steps/achievements_step.dart';

/// Resume Builder — multi-step premium form. Progress bar + smooth steps.
class ResumeBuilderScreen extends StatefulWidget {
  final String? templateId; // null = AI Builder, warna chosen template

  const ResumeBuilderScreen({super.key, this.templateId});

  @override
  State<ResumeBuilderScreen> createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final ResumeData _data = ResumeData();
  int _step = 0;
  int _remaining = 3;

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    final left = await PremiumService.remaining(
        'resume_builder', FeatureLimits.resumeBuilder);
    if (!mounted) return;
    setState(() => _remaining = left);
  }

final _steps = const [
    'Personal',
    'Summary',
    'Experience',
    'Projects',
    'Education',
    'Skills',
    'Achievements',
  ];

  void _next() {
    if (_step < _steps.length - 1) {
      setState(() => _step++);
   } else {
      // Last step -> Preview (chosen template ke saath)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResumePreviewScreen(
            data: _data,
            templateId: widget.templateId ?? 'modern',
          ),
        ),
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
    } else {
      Navigator.pop(context);
    }
  }

  Widget _currentStep() {
    switch (_step) {
      case 0:
        return PersonalInfoStep(data: _data, onChanged: () => setState(() {}));
      case 1:
        return SummaryStep(data: _data, onChanged: () => setState(() {}));
      case 2:
        return ExperienceStep(data: _data, onChanged: () => setState(() {}));
      case 3:
        return ProjectsStep(data: _data, onChanged: () => setState(() {}));
      case 4:
        return EducationStep(data: _data, onChanged: () => setState(() {}));
      case 5:
        return SkillsStep(data: _data, onChanged: () => setState(() {}));
      case 6:
        return AchievementsStep(data: _data, onChanged: () => setState(() {}));
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / _steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ---- Header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _back,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Color(0xFF0F172A), size: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Resume Builder',
                          style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      Text('Step ${_step + 1} of ${_steps.length} · ${_steps[_step]}',
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Usage card (subtle, 0/3 used) ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SmartUsageCard(
                remaining: _remaining,
                total: FeatureLimits.resumeBuilder,
                price: '₹149',
                onUpgrade: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ---- Progress bar (animated) ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor:
                            const AlwaysStoppedAnimation(AppBrand.violet),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Step dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_steps.length, (i) {
                      final done = i <= _step;
                      return Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: done
                                  ? AppGradients.buttonGradient
                                  : null,
                              color: done ? null : const Color(0xFFE2E8F0),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: i < _step
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 15)
                                  : Text('${i + 1}',
                                      style: TextStyle(
                                          color: done
                                              ? Colors.white
                                              : const Color(0xFF94A3B8),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Step content (animated switch) ----
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.1, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: SingleChildScrollView(
                  key: ValueKey(_step),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: _currentStep(),
                ),
              ),
            ),

            // ---- Bottom nav buttons ----
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF64748B).withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: GestureDetector(
                        onTap: _back,
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text('Back',
                                style: TextStyle(
                                    color: Color(0xFF475569),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _next,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: AppGradients.buttonGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppBrand.violet.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _step == _steps.length - 1
                                ? 'Preview Resume'
                                : 'Continue',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}