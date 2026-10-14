import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';
import '../../features/premium/premium_screen.dart';

/// "Pro" badge — locked feature pe dikhta hai (chhota tag).
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, color: Colors.white, size: 11),
          SizedBox(width: 3),
          Text('PRO',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }
}

/// Smart Usage Card — subscription psychology.
/// Subtle jab free bache, dots + dynamic color + value anchor.
class SmartUsageCard extends StatelessWidget {
  final int remaining; // -1 = premium
  final int total;
  final String price;
  final VoidCallback onUpgrade;

  const SmartUsageCard({
    super.key,
    required this.remaining,
    required this.total,
    required this.onUpgrade,
    this.price = '₹149',
  });

  @override
  Widget build(BuildContext context) {
    if (remaining == -1) return _premiumCard();

    final used = total - remaining;
    final Color accent;
    final String message;
    if (remaining == 0) {
      accent = const Color(0xFFEF4444);
      message = 'All free credits used';
    } else if (remaining == 1) {
      accent = const Color(0xFFF59E0B);
      message = 'Only 1 free left';
    } else {
      accent = AppBrand.violet;
      message = '$remaining free left this month';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                remaining == 0 ? Icons.lock_outline : Icons.auto_awesome,
                color: accent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message,
                    style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
              ),
              Text('$used/$total used',
                  style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          // Visual dots
          Row(
            children: List.generate(total, (i) {
              final isUsed = i < used;
              return Expanded(
                child: Container(
                  height: 7,
                  margin: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: isUsed ? accent : accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _premiumCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: const [
          Icon(Icons.all_inclusive, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unlimited Access',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                Text('You\'re a Pro member 🎉',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium lock sheet — jab free limit khatam ho, animated card dikhao.
/// Use: showPremiumLock(context, feature: 'Resume Analyzer', benefits: [...]);
void showPremiumLock(
  BuildContext context, {
  required String feature,
  List<String>? benefits,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PremiumLockSheet(
      feature: feature,
      benefits: benefits ??
          [
            'Unlimited $feature',
            'All premium features unlocked',
            'Priority support',
          ],
    ),
  );
}

class _PremiumLockSheet extends StatefulWidget {
  final String feature;
  final List<String> benefits;
  const _PremiumLockSheet({required this.feature, required this.benefits});

  @override
  State<_PremiumLockSheet> createState() => _PremiumLockSheetState();
}

class _PremiumLockSheetState extends State<_PremiumLockSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Crown (animated pop-in)
          ScaleTransition(
            scale: _scale,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium,
                  color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          Text('Unlock ${widget.feature} Pro',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          const Text(
            'You\'ve used all your free credits. Upgrade to Pro and supercharge your career!',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Color(0xFF64748B), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          ...widget.benefits.map(_benefit),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PremiumScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('Upgrade to Pro',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Maybe later',
                style: TextStyle(color: Color(0xFF94A3B8))),
          ),
        ],
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}