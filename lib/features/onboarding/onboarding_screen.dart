import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../auth/widgets/auth_widgets.dart';
import 'onboarding_data.dart';
import 'role_screen.dart';
import '../../services/local_storage.dart';

/// Onboarding — 3 swipe slides. Value dikhao, phir role poochho.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == onboardingSlides.length - 1;

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finish() async {
    // "Onboarding dekh li" mark karo (dobara na dikhe).
    await LocalStorage.setSeenOnboarding();
    if (!mounted) return;
    // Role selection pe jao.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RoleScreen()),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ---- Skip button (top right) ----
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Skip',
                      style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ),
              ),
            ),

            // ---- Slides ----
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: onboardingSlides.length,
                itemBuilder: (context, i) {
                  final slide = onboardingSlides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated icon circle
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slide.color.withValues(alpha: 0.1),
                          ),
                          child: Center(
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    slide.color,
                                    slide.color.withValues(alpha: 0.7),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: slide.color.withValues(alpha: 0.35),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Icon(slide.icon,
                                  color: Colors.white, size: 52),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ---- Dots indicator ----
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingSlides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? AppBrand.violet
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ---- Next / Get Started button ----
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: GradientButton(
                label: _isLast ? 'Get Started' : 'Next',
                onTap: _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}