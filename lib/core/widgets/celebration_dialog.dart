import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_gradients.dart';

/// Celebration popup — confetti + reward message. Reusable.
/// Use: showCelebration(context, title: '...', message: '...', points: 25);
void showCelebration(
  BuildContext context, {
  required String title,
  required String message,
  int? points,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _CelebrationDialog(
      title: title,
      message: message,
      points: points,
    ),
  );
}
/// Celebration dikhao aur band hone tak wait karo (await ke liye).
Future<void> showCelebrationAndWait(
  BuildContext context, {
  required String title,
  required String message,
  int? points,
}) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => _CelebrationDialog(
      title: title,
      message: message,
      points: points,
    ),
  );
}

class _CelebrationDialog extends StatefulWidget {
  final String title;
  final String message;
  final int? points;

  const _CelebrationDialog({
    required this.title,
    required this.message,
    this.points,
  });

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dialog
        Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with gradient
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppGradients.buttonGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppBrand.violet.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.celebration,
                      color: Colors.white, size: 48),
                ),
                const SizedBox(height: 20),
                Text(widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 22,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(widget.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        height: 1.4)),
                if (widget.points != null) ...[
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        const Color(0xFFF59E0B).withValues(alpha: 0.15),
                        const Color(0xFFF59E0B).withValues(alpha: 0.08),
                      ]),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars,
                            color: Color(0xFFF59E0B), size: 22),
                        const SizedBox(width: 8),
                        Text('+${widget.points} Points',
                            style: const TextStyle(
                                color: Color(0xFFF59E0B),
                                fontSize: 18,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppGradients.buttonGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('Awesome!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

      // Confetti (upar se girta)
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            numberOfParticles: 30,
            gravity: 0.25,
            emissionFrequency: 0.05,
            colors: const [
              AppBrand.violet,
              AppBrand.blueAccent,
              AppBrand.indigo,
              Color(0xFFF59E0B),
              Color(0xFF22C55E),
            ],
          ),
        ),
      ],
    );
  }
}