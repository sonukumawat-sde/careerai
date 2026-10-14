import 'package:flutter/material.dart';
import '../../../../core/theme/app_gradients.dart';
import '../resume_builder_data.dart';
import '../resume_builder_screen.dart';
import '../../../../core/premium/premium_widgets.dart';

/// Template ka data.
class ResumeTemplate {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final IconData icon;
  final bool isPremium;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.icon,
    this.isPremium = false,
  });
}

/// 3 free templates + premium ka hint.
const List<ResumeTemplate> resumeTemplates = [
  ResumeTemplate(
    id: 'modern',
    name: 'Modern',
    description: 'Clean design with a bold header. Great for tech & startups.',
    primaryColor: AppBrand.violet,
    icon: Icons.bolt,
  ),
  ResumeTemplate(
    id: 'professional',
    name: 'Professional',
    description: 'Classic corporate layout. Perfect for formal industries.',
    primaryColor: AppBrand.blueAccent,
    icon: Icons.business_center,
  ),
  ResumeTemplate(
    id: 'minimal',
    name: 'Minimal',
    description: 'Simple & elegant. Focuses on content, highly ATS-friendly.',
    primaryColor: Color(0xFF0F172A),
    icon: Icons.article_outlined,
  ),
];

/// Template Selection — 3 templates dikhe, choose karo.
class TemplateSelectionScreen extends StatelessWidget {
  const TemplateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Choose Template'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const Text('Pick a template',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text(
              'All templates are ATS-friendly. Choose one and edit with your details.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(height: 20),

          // 3 free templates
          ...resumeTemplates.map((t) => _templateCard(context, t)),

          const SizedBox(height: 8),

         // Premium templates upgrade card
          GestureDetector(
            onTap: () => showPremiumLock(
              context,
              feature: 'Premium Templates',
              benefits: const [
                '10+ industry-specific templates',
                'Designer-made professional layouts',
                'Highly ATS-optimized designs',
                'Unlimited template downloads',
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
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
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
                        Text('10+ Premium Templates',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                        SizedBox(height: 2),
                        Text('Industry-specific, designer-made layouts',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white, size: 22),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _templateCard(BuildContext context, ResumeTemplate t) {
    return GestureDetector(
      onTap: () {
        // Template choose kiya -> builder khule (us template ke saath)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResumeBuilderScreen(templateId: t.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEF1F5)),
          boxShadow: [
            BoxShadow(
              color: t.primaryColor.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Mini template preview
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: t.primaryColor.withValues(alpha: 0.05),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(child: _miniPreview(t)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: t.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(t.icon, color: t.primaryColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(t.name,
                                style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('FREE',
                                  style: TextStyle(
                                      color: Color(0xFF22C55E),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(t.description,
                            style: const TextStyle(
                                color: Color(0xFF64748B),
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
          ],
        ),
      ),
    );
  }

  // Mini template preview (dikhne ke liye)
  Widget _miniPreview(ResumeTemplate t) {
    return Container(
      width: 100,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header bar
          Container(
            height: t.id == 'minimal' ? 18 : 30,
            decoration: BoxDecoration(
              color: t.id == 'minimal'
                  ? Colors.white
                  : t.primaryColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: t.id == 'minimal'
                ? Center(
                    child: Container(
                      width: 50,
                      height: 4,
                      color: t.primaryColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 6),
          ...List.generate(
            5,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Container(
                height: 3,
                width: double.infinity,
                color: i == 0
                    ? t.primaryColor.withValues(alpha: 0.5)
                    : const Color(0xFFE2E8F0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}