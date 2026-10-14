import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';

/// Animated hero graphic — center me glowing AI orb, around floating
/// feature tiles (Resume Analyzer, Career Coach, etc.).
/// Code se bana hai, koi image file nahi chahiye. Brand colors me.
class AiHeroAnimation extends StatefulWidget {
  final double height;
  const AiHeroAnimation({super.key, this.height = 240});

  @override
  State<AiHeroAnimation> createState() => _AiHeroAnimationState();
}

class _AiHeroAnimationState extends State<AiHeroAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _floatController; // tiles float up-down
  late final AnimationController _pulseController; // orb glow pulse

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glow
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.purpleGlow,
            ),
          ),

          // ---- Floating feature tiles ----
          _FloatingTile(
            controller: _floatController,
            alignment: const Alignment(-0.95, -0.75),
            icon: Icons.description_outlined,
            label: 'Resume\nAnalyzer',
            color: AppBrand.violet,
            phase: 0.0,
          ),
          _FloatingTile(
            controller: _floatController,
            alignment: const Alignment(0.95, -0.55),
            icon: Icons.edit_document,
            label: 'Resume\nBuilder',
            color: AppBrand.blueAccent,
            phase: 0.5,
          ),
          _FloatingTile(
            controller: _floatController,
            alignment: const Alignment(-0.95, 0.6),
            icon: Icons.mic_none_rounded,
            label: 'Interview\nPractice',
            color: AppBrand.indigo,
            phase: 0.25,
          ),
          _FloatingTile(
            controller: _floatController,
            alignment: const Alignment(0.9, 0.15),
            icon: Icons.person_pin_circle_outlined,
            label: 'Career\nCoach',
            color: AppBrand.purple,
            phase: 0.75,
          ),
          _FloatingTile(
            controller: _floatController,
            alignment: const Alignment(0.95, 0.85),
            icon: Icons.work_outline_rounded,
            label: 'Job Hub',
            color: AppBrand.cyanGlow,
            phase: 0.4,
          ),

          // ---- Center glowing AI orb ----
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final t = _pulseController.value;
              return Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppBrand.violet, AppBrand.indigo],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppBrand.violet.withValues(alpha: 0.4 + t * 0.3),
                      blurRadius: 30 + t * 20,
                      spreadRadius: 2 + t * 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome,
                      color: Colors.white, size: 44),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Ek floating feature tile jo halke se up-down float karti hai.
class _FloatingTile extends StatelessWidget {
  final AnimationController controller;
  final Alignment alignment;
  final IconData icon;
  final String label;
  final Color color;
  final double phase; // 0-1, taaki sab alag time pe float karein

  const _FloatingTile({
    required this.controller,
    required this.alignment,
    required this.icon,
    required this.label,
    required this.color,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Sine wave se smooth up-down motion
        final offset = math.sin((controller.value + phase) * 2 * math.pi) * 6;
        return Align(
          alignment: alignment,
          child: Transform.translate(
            offset: Offset(0, offset),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppBrand.glassFill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.25),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}