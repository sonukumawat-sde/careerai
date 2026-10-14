import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';

/// Menu (drawer) ke reusable pieces.

/// Ek menu item — icon (colored) + title + optional badge + arrow.
class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final String? badge; // jaise "3" ya "New"
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
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
              child: Text(title,
                  style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ),
            if (badge != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppBrand.violet,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(badge!,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(Icons.chevron_right,
                color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }
}

/// Section ka chhota label (jaise "MY WORK").
class MenuSectionLabel extends StatelessWidget {
  final String text;
  const MenuSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 18, bottom: 6),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6)),
    );
  }
}