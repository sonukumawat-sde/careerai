import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'notification_data.dart';

/// Ek notification card — colored icon + title + message + time.
/// Unread wale purple-tinted (premium touch).
class NotificationCard extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;

  const NotificationCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.unread
              ? AppBrand.violet.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.unread
                ? AppBrand.violet.withValues(alpha: 0.18)
                : const Color(0xFFEEF1F5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title,
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w800)),
                      ),
                      if (item.unread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppBrand.violet,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.message,
                      style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          height: 1.35)),
                  const SizedBox(height: 8),
                  Text(item.time,
                      style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filter chip (All / Jobs / Interviews / Resume).
class FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterChipItem({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.buttonGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}