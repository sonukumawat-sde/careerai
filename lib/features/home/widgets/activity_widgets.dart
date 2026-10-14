import 'package:flutter/material.dart';

/// Recent Activity timeline item — colored dot + text + time.
class ActivityItem extends StatelessWidget {
  final Color dotColor;
  final String text;
  final String time;
  final bool isLast;

  const ActivityItem({
    super.key,
    required this.dotColor,
    required this.text,
    required this.time,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + line
          Column(
            children: [
              const SizedBox(height: 4),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFEEF1F5),
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Text + time
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text,
                      style: const TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(time,
                      style: const TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}