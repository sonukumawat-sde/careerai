import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';

/// Application status stages.
enum AppStatus { applied, underReview, interview, offer, rejected }

/// Ek applied job.
class AppliedJob {
  final String title;
  final String company;
  final String location;
  final String appliedDate;
  final AppStatus status;
  final Color color;

  const AppliedJob({
    required this.title,
    required this.company,
    required this.location,
    required this.appliedDate,
    required this.status,
    required this.color,
  });

  /// Supabase row se AppliedJob banao (REAL).
  factory AppliedJob.fromMap(Map<String, dynamic> map, Color color) {
    return AppliedJob(
      title: (map['title'] ?? 'Job').toString(),
      company: (map['company'] ?? '').toString(),
      location: (map['location'] ?? '').toString(),
      appliedDate: _timeAgo(map['applied_at'] ?? map['created_at']),
      status: _statusFromString((map['status'] ?? 'applied').toString()),
      color: color,
    );
  }

  static AppStatus _statusFromString(String s) {
    switch (s.toLowerCase()) {
      case 'under_review':
      case 'underreview':
      case 'review':
        return AppStatus.underReview;
      case 'interview':
        return AppStatus.interview;
      case 'offer':
        return AppStatus.offer;
      case 'rejected':
        return AppStatus.rejected;
      default:
        return AppStatus.applied;
    }
  }

  static String _timeAgo(dynamic v) {
    final t = DateTime.tryParse((v ?? '').toString())?.toLocal();
    if (t == null) return 'Recently';
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return '1 day ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 14) return '1 week ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }
}

/// Status ka label + color (helper).
extension AppStatusInfo on AppStatus {
  String get label {
    switch (this) {
      case AppStatus.applied:
        return 'Applied';
      case AppStatus.underReview:
        return 'Under Review';
      case AppStatus.interview:
        return 'Interview';
      case AppStatus.offer:
        return 'Offer';
      case AppStatus.rejected:
        return 'Rejected';
    }
  }

  Color get statusColor {
    switch (this) {
      case AppStatus.applied:
        return const Color(0xFF64748B);
      case AppStatus.underReview:
        return const Color(0xFFF59E0B);
      case AppStatus.interview:
        return AppBrand.violet;
      case AppStatus.offer:
        return const Color(0xFF22C55E);
      case AppStatus.rejected:
        return const Color(0xFFEF4444);
    }
  }

  /// Progress step (0-3) timeline ke liye. Rejected -> -1.
  int get step {
    switch (this) {
      case AppStatus.applied:
        return 0;
      case AppStatus.underReview:
        return 1;
      case AppStatus.interview:
        return 2;
      case AppStatus.offer:
        return 3;
      case AppStatus.rejected:
        return -1;
    }
  }
}