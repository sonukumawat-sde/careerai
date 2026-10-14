import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/premium/premium_service.dart';
import '../../../core/premium/premium_widgets.dart';
import '../../premium/premium_screen.dart';
import 'resume_builder_screen.dart';
import 'templates/template_selection_screen.dart';

/// Resume Builder Landing — 2 options: Choose Template / AI Builder.
class BuilderLandingScreen extends StatefulWidget {
  const BuilderLandingScreen({super.key});

  @override
  State<BuilderLandingScreen> createState() => _BuilderLandingScreenState();
}

class _BuilderLandingScreenState extends State<BuilderLandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Resume Builder'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          // ---- Hero ----
          Container(
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
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                const Text('Build Your Perfect Resume',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text(
                    'Choose a ready template or let AI build it for you. ATS-friendly & professional.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        const SizedBox(height: 24),

          const Text('How do you want to start?',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),

          // ---- Option A: Choose Template ----
          _optionCard(
            icon: Icons.dashboard_customize_outlined,
            title: 'Choose a Template',
            subtitle:
                'Pick from 3 professional templates and edit with your details.',
            tag: '3 Free Templates',
            color: AppBrand.violet,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const TemplateSelectionScreen()),
            ),
          ),
          const SizedBox(height: 14),

          // ---- Option B: AI Builder ----
          _optionCard(
            icon: Icons.smart_toy_outlined,
            title: 'AI Resume Builder',
            subtitle:
                'Fill your details and let AI craft a top-class resume for you.',
            tag: 'AI Powered',
            color: AppBrand.blueAccent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResumeBuilderScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String tag,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, color.withValues(alpha: 0.04)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.75)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(title,
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 16,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12.5,
                          height: 1.4)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(tag,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
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