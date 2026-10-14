import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';

/// Today's Goals + Daily Streak ke pieces.

/// Ek goal item — checkbox + text + XP.
class GoalItem extends StatelessWidget {
  final String text;
  final bool done;
  final int xp;

  const GoalItem({
    super.key,
    required this.text,
    required this.done,
    required this.xp,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: done ? AppBrand.violet : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: done ? AppBrand.violet : const Color(0xFFCBD5E1),
                width: 2,
              ),
            ),
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: done
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF334155),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration:
                        done ? TextDecoration.lineThrough : null)),
          ),
          Text('+$xp XP',
              style: const TextStyle(
                  color: AppBrand.violet,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Chhota progress ring (2/3 type).
class SmallRing extends StatelessWidget {
  final int done;
  final int total;

  const SmallRing({super.key, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              value: total == 0 ? 0 : done / total,
              strokeWidth: 5,
              backgroundColor: AppBrand.violet.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(AppBrand.violet),
            ),
          ),
          Text('$done/$total',
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

/// Daily streak week dots (M T W T F S S).
class StreakDots extends StatelessWidget {
  final List<bool> days; // 7 values, true = done

  const StreakDots({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final done = i < days.length && days[i];
        return Column(
          children: [
            Text(labels[i],
                style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: done ? AppBrand.violet : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: done
                  ? const Icon(Icons.check, color: Colors.white, size: 15)
                  : null,
            ),
          ],
        );
      }),
    );
  }
}