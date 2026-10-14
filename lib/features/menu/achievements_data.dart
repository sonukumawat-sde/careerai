import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'rewards_service.dart';

/// Ek achievement/badge.
class Achievement {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool Function(RewardsData data) isUnlocked;

  const Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.isUnlocked,
  });
}

/// Saari achievements. Har ek ka unlock condition real data pe based hai.
final List<Achievement> allAchievements = [
  // ---- Resume ----
  Achievement(
    icon: Icons.description,
    title: 'First Resume',
    description: 'Analyze your first resume',
    color: AppBrand.violet,
    isUnlocked: (d) => d.resumesCount >= 1,
  ),
  Achievement(
    icon: Icons.workspace_premium,
    title: 'Resume Pro',
    description: 'Analyze 5 resumes',
    color: AppBrand.violet,
    isUnlocked: (d) => d.resumesCount >= 5,
  ),

  // ---- Jobs ----
  Achievement(
    icon: Icons.send,
    title: 'First Application',
    description: 'Apply to your first job',
    color: AppBrand.blueAccent,
    isUnlocked: (d) => d.applicationsCount >= 1,
  ),
  Achievement(
    icon: Icons.rocket_launch,
    title: 'Job Hunter',
    description: 'Apply to 10 jobs',
    color: AppBrand.blueAccent,
    isUnlocked: (d) => d.applicationsCount >= 10,
  ),
  Achievement(
    icon: Icons.bookmark,
    title: 'Collector',
    description: 'Save your first job',
    color: AppBrand.indigo,
    isUnlocked: (d) => d.savedJobsCount >= 1,
  ),
  Achievement(
    icon: Icons.bookmarks,
    title: 'Curator',
    description: 'Save 10 jobs',
    color: AppBrand.indigo,
    isUnlocked: (d) => d.savedJobsCount >= 10,
  ),

  // ---- Referral ----
  Achievement(
    icon: Icons.card_giftcard,
    title: 'First Referral',
    description: 'Refer your first friend',
    color: const Color(0xFF14B8A6),
    isUnlocked: (d) => d.referralCount >= 1,
  ),
  Achievement(
    icon: Icons.groups,
    title: 'Influencer',
    description: 'Refer 5 friends',
    color: const Color(0xFF14B8A6),
    isUnlocked: (d) => d.referralCount >= 5,
  ),

  // ---- Points ----
  Achievement(
    icon: Icons.stars,
    title: 'Point Starter',
    description: 'Earn 100 points',
    color: const Color(0xFFF59E0B),
    isUnlocked: (d) => d.totalPoints >= 100,
  ),
  Achievement(
    icon: Icons.emoji_events,
    title: 'Point Master',
    description: 'Earn 500 points',
    color: const Color(0xFFF59E0B),
    isUnlocked: (d) => d.totalPoints >= 500,
  ),

  // ---- Level ----
  Achievement(
    icon: Icons.trending_up,
    title: 'Level Up',
    description: 'Reach Level 2',
    color: const Color(0xFFEC4899),
    isUnlocked: (d) => d.level >= 2,
  ),
  Achievement(
    icon: Icons.military_tech,
    title: 'Pro Status',
    description: 'Reach Level 4 (Pro)',
    color: const Color(0xFFEC4899),
    isUnlocked: (d) => d.level >= 4,
  ),
];