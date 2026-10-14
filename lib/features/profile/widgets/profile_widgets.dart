import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';

/// Profile screen ke reusable pieces.

/// Section ka label (jaise "ACCOUNT").
class ProfileSectionLabel extends StatelessWidget {
  final String text;
  const ProfileSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 22, bottom: 10),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6)),
    );
  }
}

/// Ek profile menu tile — colored icon + title + optional subtitle + arrow.
class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool highlight;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: highlight
                    ? AppBrand.violet.withValues(alpha: 0.3)
                    : const Color(0xFFEEF1F5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            color: highlight
                                ? AppBrand.violet
                                : const Color(0xFF0F172A),
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle!,
                          style: const TextStyle(
                              color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Color(0xFFCBD5E1), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Profile completion progress bar.
class ProfileCompletion extends StatelessWidget {
  final int percent;
  const ProfileCompletion({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Profile Completion',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Text('$percent%',
                  style: const TextStyle(
                      color: AppBrand.violet,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(AppBrand.violet),
            ),
          ),
          const SizedBox(height: 8),
          Text('Complete your profile for better AI recommendations.',
              style: TextStyle(
                  color: const Color(0xFF94A3B8), fontSize: 12)),
        ],
      ),
    );
  }
}