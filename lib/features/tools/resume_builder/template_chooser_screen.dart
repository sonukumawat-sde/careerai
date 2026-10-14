import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/premium/premium_service.dart';
import '../../../core/premium/premium_widgets.dart';
import '../../premium/premium_screen.dart';
import 'resume_templates.dart';
import 'resume_builder_screen.dart';

/// Resume Builder main screen — 4 template cards.
/// User koi ek choose kare -> details bhare -> us template me PDF.
class TemplateChooserScreen extends ConsumerStatefulWidget {
  const TemplateChooserScreen({super.key});

  @override
  ConsumerState<TemplateChooserScreen> createState() =>
      _TemplateChooserScreenState();
}

class _TemplateChooserScreenState
    extends ConsumerState<TemplateChooserScreen> {
  int _remaining = 4;

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

  void _useTemplate(String templateId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResumeBuilderScreen(templateId: templateId),
      ),
    );
  }

  Widget _heroTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ---- Header ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Color(0xFF0F172A), size: 20),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text('Resume Builder',
                            style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Premium hero card (top)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF7C3AED),
                            Color(0xFF8B5CF6),
                            Color(0xFF6366F1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6)
                                .withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.auto_awesome,
                                    color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 12),
                              const Text('Build Your Resume',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                              'Pick a professional, ATS-friendly template. Fill your details and download a polished PDF instantly.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  height: 1.45)),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _heroTag(Icons.check_circle, 'ATS-Friendly'),
                              const SizedBox(width: 8),
                              _heroTag(Icons.bolt, 'Instant PDF'),
                              const SizedBox(width: 8),
                              _heroTag(Icons.star, 'Pro Quality'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Usage card (subtle)
                    SmartUsageCard(
                      remaining: _remaining,
                      total: FeatureLimits.resumeBuilder,
                      price: '₹149',
                      onUpgrade: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PremiumScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // ---- 4 template cards (2x2 grid) ----
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final t = kResumeTemplates[index];
                    return _TemplateCard(
                      template: t,
                      onTap: () => _useTemplate(t.id),
                    );
                  },
                  childCount: kResumeTemplates.length,
                ),
              ),
            ),

            // ---- Premium banner (more templates) ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: GestureDetector(
                 onTap: () => showPremiumLock(
                    context,
                    feature: 'Premium Resume Builder',
                    benefits: const [
                      '10+ premium industry-specific templates',
                      'Unlimited resume downloads (no limits)',
                      'AI-powered content & bullet writing',
                      'Advanced ATS optimization & scoring',
                      'Multiple resume versions & tailoring',
                      'Cover letter builder included',
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFFF59E0B).withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.workspace_premium,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Unlock 10+ Premium Templates',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800)),
                              SizedBox(height: 2),
                              Text('Industry-specific, designer-made',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ek template card (preview image + naam + use button).
class _TemplateCard extends StatelessWidget {
  final ResumeTemplate template;
  final VoidCallback onTap;

  const _TemplateCard({required this.template, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEEF1F5)),
          boxShadow: [
            BoxShadow(
              color: template.accentColor.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(18)),
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: Image.asset(
                    template.previewAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.description_outlined,
                          color: template.accentColor, size: 40),
                    ),
                  ),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(template.name,
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('FREE',
                            style: TextStyle(
                                color: Color(0xFF22C55E),
                                fontSize: 9,
                                fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          template.accentColor,
                          template.accentColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text('Use Template',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
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