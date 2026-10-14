import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'resume_analyzer/analyzer_screen.dart';

/// Tools tab — AI tools landing (Resume Analyzer, Builder, Interview).
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            // Header
            const Text('AI Tools',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
            const SizedBox(height: 4),
            const Text('Powerful AI tools to boost your career.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 24),

           // Resume Analyzer
            _ToolCard(
              icon: Icons.document_scanner_outlined,
              title: 'Resume Analyzer',
              subtitle: 'Upload your resume and get an instant AI score, ATS check & suggestions.',
              color: AppBrand.violet,
              tag: 'Most Popular',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AnalyzerScreen()),
              ),
            ),
            const SizedBox(height: 14),

            // Resume Builder
            _ToolCard(
              icon: Icons.edit_document,
              title: 'Resume Builder',
              subtitle: 'Create a professional ATS-friendly resume from scratch with AI.',
              color: AppBrand.blueAccent,
              onTap: () {},
            ),
            const SizedBox(height: 14),

            // Interview Practice
            _ToolCard(
              icon: Icons.mic_none_rounded,
              title: 'Interview Practice',
              subtitle: 'Practice real mock interviews and get AI feedback on your answers.',
              color: AppBrand.indigo,
              onTap: () {},
            ),
            const SizedBox(height: 28),

            // Recent section
            const Text('Recent',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEEF1F5)),
              ),
              child: Column(
                children: [
                  Icon(Icons.history,
                      color: const Color(0xFF94A3B8).withValues(alpha: 0.6),
                      size: 40),
                  const SizedBox(height: 10),
                  const Text('No recent activity yet',
                      style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Start with a tool above to see your history here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bada premium tool card.
class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? tag;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                  colors: [color, color.withValues(alpha: 0.7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                      if (tag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(tag!,
                              style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}