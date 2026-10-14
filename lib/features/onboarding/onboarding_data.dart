import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';

/// Onboarding ke 3 slides ka data — ek jagah rakha taaki easily edit ho.
class OnboardingSlide {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const OnboardingSlide({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

/// 3 slides — Resume, Interview+Coach, Jobs (tere 5 modules ko group karke).
const List<OnboardingSlide> onboardingSlides = [
  OnboardingSlide(
    icon: Icons.description_outlined,
    title: 'Perfect Your Resume',
    subtitle:
        'AI se professional resume banao, ATS score check karo, aur ek click me improve karo.',
    color: AppBrand.violet,
  ),
  OnboardingSlide(
    icon: Icons.record_voice_over_outlined,
    title: 'Crack Every Interview',
    subtitle:
        'Real mock interviews practice karo aur 24x7 AI career coach se guidance lo.',
    color: AppBrand.indigo,
  ),
  OnboardingSlide(
    icon: Icons.rocket_launch_outlined,
    title: 'Land Your Dream Job',
    subtitle:
        'Tere profile se matching jobs dhundo aur saari applications ek jagah track karo.',
    color: AppBrand.blueAccent,
  ),
];