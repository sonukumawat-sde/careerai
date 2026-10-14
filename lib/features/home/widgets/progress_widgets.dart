import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';

/// Career Progress section ke pieces (combined card ke liye).

/// Career Level badge — hexagon-style gradient badge with level number.
class CareerLevelBadge extends StatelessWidget {
  final int level;
  final String rank;
  final int currentXp;
  final int maxXp;

  const CareerLevelBadge({
    super.key,
    required this.level,
    required this.rank,
    required this.currentXp,
    required this.maxXp,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Career Level',
            style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Container(
          width: 74,
          height: 74,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppBrand.purple, AppBrand.violet, AppBrand.indigo],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppBrand.violet.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text('$level',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(height: 12),
        Text(rank,
            style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        SizedBox(
          width: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: maxXp == 0 ? 0 : currentXp / maxXp,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation(AppBrand.violet),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('$currentXp / $maxXp XP',
            style: const TextStyle(
                color: Color(0xFF94A3B8), fontSize: 11)),
      ],
    );
  }
}

/// Weekly Challenge bar.
class WeeklyChallenge extends StatelessWidget {
  final String title;
  final int current;
  final int target;
  final int rewardXp;

  const WeeklyChallenge({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    required this.rewardXp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppBrand.violet.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppBrand.violet.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Color(0xFFF59E0B), size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Weekly Challenge',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: target == 0 ? 0 : current / target,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFE9E3FB),
                    valueColor:
                        const AlwaysStoppedAnimation(AppBrand.violet),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text('$rewardXp XP',
                  style: const TextStyle(
                      color: AppBrand.violet,
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
              Text('$current/$target',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}