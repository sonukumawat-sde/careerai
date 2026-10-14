import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';

/// Home screen ke reusable pieces. Ek jagah rakhe taaki home_screen saaf rahe.

/// Section ka heading + optional "See All" link.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionText!,
                style: const TextStyle(
                    color: AppBrand.violet,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

/// Module tile (Resume Analyzer, Interview, etc.) — colored icon + naam + desc.
class ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEEF1F5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.2)),
            const SizedBox(height: 6),
            Text(subtitle,
                style: const TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 12, height: 1.3)),
            const SizedBox(height: 12),
            const Icon(Icons.arrow_forward,
                color: Color(0xFF94A3B8), size: 18),
          ],
        ),
      ),
    );
  }
}

/// Chhota circular progress ring (Career Progress section ke liye).
class MiniStatRing extends StatelessWidget {
  final String value;     // "85%" ya "28"
  final String label;     // "Resume Score"
  final double progress;  // 0.0 - 1.0
  final Color color;

  const MiniStatRing({
    super.key,
    required this.value,
    required this.label,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 5,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
              Text(value,
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// AI Suggestion list item — icon + text + arrow.
class SuggestionItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final VoidCallback onTap;

  const SuggestionItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500)),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }
}
/// Resume Score hero card — bada gradient card with score ring.
class ResumeScoreCard extends StatelessWidget {
  final int score;
  final int change; // +15 type
  final VoidCallback onImprove;
  final VoidCallback onViewAnalysis;

  const ResumeScoreCard({
    super.key,
    required this.score,
    required this.change,
    required this.onImprove,
    required this.onViewAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppBrand.violet.withValues(alpha: 0.10),
            AppBrand.blueAccent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppBrand.violet.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left side
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RESUME SCORE',
                        style: TextStyle(
                            color: AppBrand.violet,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$score',
                            style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                height: 1)),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text('/100',
                              style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(_scoreMessage(score),
                        style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                            height: 1.3)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              
              // Right side - score ring
              _bigRing(score),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onImprove,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: AppGradients.buttonGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Improve Now',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onViewAnalysis,
                child: const Row(
                  children: [
                    Text('View Analysis',
                        style: TextStyle(
                            color: AppBrand.violet,
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    Icon(Icons.chevron_right, color: AppBrand.violet, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
String _scoreMessage(int score) {
    if (score == 0) {
      return 'Analyze your resume to see your score and get AI feedback.';
    }
    if (score >= 85) return 'Excellent! Your resume is in top shape.';
    if (score >= 70) return 'Good job! A few tweaks can make it great.';
    if (score >= 50) return 'Decent start. Let\'s improve it further.';
    return 'Needs work. Tap Improve Now for AI suggestions.';
  }
  Widget _bigRing(int score) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 92,
            height: 92,
            child: CircularProgressIndicator(
              value: score == 0 ? 0 : score / 100,
              strokeWidth: 8,
              backgroundColor: AppBrand.violet.withValues(alpha: 0.12),
              valueColor: const AlwaysStoppedAnimation(AppBrand.violet),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$score',
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 26,
                      fontWeight: FontWeight.w900)),
              const Text('Score',
                  style: TextStyle(
                      color: AppBrand.violet,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Premium upgrade banner (bottom).
class PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;
  const PremiumBanner({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppBrand.purple, AppBrand.violet],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppBrand.violet.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.workspace_premium,
                color: Color(0xFFFBBF24), size: 26),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CareerAI Pro',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 3),
                Text('Unlock unlimited AI tools & premium features.',
                    style: TextStyle(
                        color: Colors.white70, fontSize: 12, height: 1.3)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Upgrade',
                  style: TextStyle(
                      color: AppBrand.violet,
                      fontWeight: FontWeight.w800,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
/// Ultra-premium module card — gradient icon, glow, tap animation.
class JourneyCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  const JourneyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  State<JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<JourneyCard>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _down(_) => setState(() => _scale = 0.96);
  void _up(_) => setState(() => _scale = 1.0);
  void _cancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _cancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.fullWidth ? _horizontalCard() : _verticalCard(),
      ),
    );
  }

  // ---- Full width (Job Hub) ----
  Widget _horizontalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          _iconBox(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title,
                    style: _titleStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(widget.subtitle,
                    style: _subStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          _arrow(),
        ],
      ),
    );
  }

  // ---- Normal (2x2 grid) ----
  Widget _verticalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _iconBox(),
              _arrow(),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.title,
              style: _titleStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(widget.subtitle,
              style: _subStyle(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            widget.color.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: widget.color.withValues(alpha: 0.18)),
        boxShadow: [
          // Colored glow
          BoxShadow(
            color: widget.color.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          // Soft base shadow
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _iconBox() => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.color,
              widget.color.withValues(alpha: 0.75),
            ],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(widget.icon, color: Colors.white, size: 24),
      );

  Widget _arrow() => Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.color.withValues(alpha: 0.15),
              widget.color.withValues(alpha: 0.08),
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.arrow_forward, color: widget.color, size: 16),
      );

  TextStyle _titleStyle() => const TextStyle(
      color: Color(0xFF0F172A),
      fontSize: 15,
      fontWeight: FontWeight.w800,
      height: 1.2);

  TextStyle _subStyle() => const TextStyle(
      color: Color(0xFF94A3B8), fontSize: 12, height: 1.25);
}