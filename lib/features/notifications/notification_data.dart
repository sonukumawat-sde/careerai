import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';

/// Notification ka ek item.
class AppNotification {
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String time;
  final bool unread;
  final String category; // 'Resume' / 'Jobs' / 'Interviews' / 'General'

  const AppNotification({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    required this.time,
    required this.unread,
    required this.category,
  });
}

/// Dummy notifications (baad me real data aayega modules se).
const List<AppNotification> dummyNotifications = [
  AppNotification(
    icon: Icons.trending_up,
    color: AppBrand.violet,
    title: 'Resume Score Improved!',
    message: 'Your resume score went up to 85. Great progress!',
    time: '2h ago',
    unread: true,
    category: 'Resume',
  ),
  AppNotification(
    icon: Icons.work_outline,
    color: AppBrand.blueAccent,
    title: '12 New Jobs Match Your Profile',
    message: 'Fresh Flutter Developer roles are waiting for you.',
    time: '5h ago',
    unread: true,
    category: 'Jobs',
  ),
  AppNotification(
    icon: Icons.mic_none_rounded,
    color: AppBrand.indigo,
    title: 'Interview Practice Reminder',
    message: 'Keep your streak going — practice one mock interview today.',
    time: '1d ago',
    unread: false,
    category: 'Interviews',
  ),
  AppNotification(
    icon: Icons.assignment_turned_in_outlined,
    color: Color(0xFF22C55E),
    title: 'Application Update',
    message: 'Your application to Google moved to the Interview stage.',
    time: '1d ago',
    unread: false,
    category: 'Jobs',
  ),
  AppNotification(
    icon: Icons.emoji_events_outlined,
    color: Color(0xFFF59E0B),
    title: 'You Earned 50 XP!',
    message: 'You completed today\'s goals. Keep it up!',
    time: '2d ago',
    unread: false,
    category: 'General',
  ),
];