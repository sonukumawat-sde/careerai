import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';

/// Premium splash — clean white bg, big logo reveal + glow pulse.
class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _glowController;
  late final AnimationController _textController;
  late final AnimationController _dotsController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _nameFade;
  late final Animation<double> _taglineSlide;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<double>(begin: 18.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _textController, curve: const Interval(0.3, 1.0)),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textController, curve: const Interval(0.3, 1.0)),
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 250));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 750));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => widget.nextScreen,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),

            // ---- Big logo with soft glow ----
            AnimatedBuilder(
              animation: Listenable.merge([_logoController, _glowController]),
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(
                                alpha: 0.12 + 0.18 * _glowController.value),
                            blurRadius: 50 + 40 * _glowController.value,
                            spreadRadius: 10 + 15 * _glowController.value,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/branding/splash_symbol.png',
                        width: 190,
                        height: 190,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // ---- App name (gradient text) ----
            FadeTransition(
              opacity: _nameFade,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF4338CA),
                    Color(0xFF7C3AED),
                    Color(0xFF22D3EE),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'CareerAI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ---- Tagline ----
            AnimatedBuilder(
              animation: _textController,
              builder: (context, child) {
                return Opacity(
                  opacity: _taglineFade.value,
                  child: Transform.translate(
                    offset: Offset(0, _taglineSlide.value),
                    child: child,
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'One App. Everything You Need\nTo Get Your Dream Job.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),

            // ---- Loading dots ----
            AnimatedBuilder(
              animation: _dotsController,
              builder: (context, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) {
                    final t = (_dotsController.value + i * 0.2) % 1.0;
                    final scale = 0.6 + 0.4 * (1 - (2 * t - 1).abs());
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED)
                                .withValues(alpha: 0.3 + 0.5 * scale),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}