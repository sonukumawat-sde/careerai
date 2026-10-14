import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_gradients.dart';

/// About CareerAI — app info, features, stats, mission, social.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('About CareerAI'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          // ---- Logo + name ----
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.buttonGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppBrand.violet.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.trending_up_rounded,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 16),
                const Text('CareerAI',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 26,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Your AI-Powered Career Partner',
                    style: TextStyle(
                        color: Color(0xFF64748B), fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppBrand.violet.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Version 1.0.0',
                      style: TextStyle(
                          color: AppBrand.violet,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ---- Mission ----
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.rocket_launch, color: AppBrand.violet, size: 22),
                    SizedBox(width: 10),
                    Text('Our Mission',
                        style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'To empower every job seeker in India with AI-powered tools that make landing their dream job simple, smart, and accessible. One app for everything you need in your career journey.',
                  style: TextStyle(
                      color: Color(0xFF475569), fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ---- Stats ----
          Row(
            children: [
              Expanded(child: _statCard('50K+', 'Users')),
              const SizedBox(width: 10),
              Expanded(child: _statCard('1M+', 'Jobs')),
              const SizedBox(width: 10),
              Expanded(child: _statCard('4.8★', 'Rating')),
            ],
          ),
          const SizedBox(height: 24),

          // ---- Features ----
          const Text('What We Offer',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _feature(Icons.document_scanner_outlined, 'AI Resume Analyzer',
              'Instant score, ATS check & suggestions', AppBrand.violet),
          _feature(Icons.edit_document, 'Resume Builder',
              'Create ATS-friendly resumes', AppBrand.blueAccent),
          _feature(Icons.work_outline, 'Job Hub',
              'Real jobs, apply & track', AppBrand.indigo),
          _feature(Icons.psychology_outlined, 'AI Career Coach',
              'Personal mentor, available 24/7', const Color(0xFFF59E0B)),
          _feature(Icons.mic_none_rounded, 'Interview Practice',
              'Mock interviews with AI feedback', const Color(0xFFEC4899)),
          const SizedBox(height: 24),

          // ---- Social ----
          const Text('Connect With Us',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _social(Icons.language, 'Website',
                  () => _openUrl('https://careerai.app')),
              _social(Icons.camera_alt_outlined, 'Instagram',
                  () => _openUrl('https://instagram.com')),
              _social(Icons.close, 'X',
                  () => _openUrl('https://x.com')),
              _social(Icons.business_center_outlined, 'LinkedIn',
                  () => _openUrl('https://linkedin.com')),
            ],
          ),
          const SizedBox(height: 28),

          // ---- Made in India ----
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Made with ',
                        style: TextStyle(
                            color: Color(0xFF64748B), fontSize: 13)),
                    Icon(Icons.favorite, color: Color(0xFFEF4444), size: 16),
                    Text(' in India 🇮🇳',
                        style: TextStyle(
                            color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('© 2026 CareerAI. All rights reserved.',
                    style: TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: child,
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppBrand.violet.withValues(alpha: 0.1),
            AppBrand.indigo.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppBrand.violet.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: AppBrand.violet,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(desc,
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _social(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFEEF1F5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppBrand.violet, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}