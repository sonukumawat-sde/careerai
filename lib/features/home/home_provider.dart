import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/supabase_service.dart';
import '../profile/profile_service.dart';

/// User ka naam laata hai (database profiles table se).
final userNameProvider = FutureProvider<String>((ref) async {
  final result = await ProfileService.getProfile();
  return result.match(
    (failure) {
      final metaName =
          SupabaseService.currentUser?.userMetadata?['full_name'] as String?;
      return metaName ?? 'User';
    },
    (data) {
      final name = data['full_name'] as String?;
      if (name != null && name.trim().isNotEmpty) return name;
      final metaName =
          SupabaseService.currentUser?.userMetadata?['full_name'] as String?;
      return metaName ?? 'User';
    },
  );
});

/// Sirf pehla naam (greeting ke liye).
final firstNameProvider = Provider<AsyncValue<String>>((ref) {
  final fullName = ref.watch(userNameProvider);
  return fullName.whenData((name) => name.split(' ').first);
});

/// User ka avatar URL.
final avatarUrlProvider = FutureProvider<String?>((ref) async {
  final result = await ProfileService.getProfile();
  return result.match(
    (failure) => null,
    (data) {
      final url = data['avatar_url']?.toString();
      if (url == null || url.isEmpty) return null;
      return url;
    },
  );
});

/// Profile kitna % complete hai (real).
int _profileCompletion(Map<String, dynamic> p) {
  // Ye fields bhare hue hain toh profile complete maana jayega
  const fields = [
    'full_name',
    'role',
    'target_role',
    'experience',
    'industry',
    'avatar_url',
  ];
  int filled = 0;
  for (final f in fields) {
    final v = p[f];
    if (v != null && v.toString().trim().isNotEmpty) filled++;
  }
  return ((filled / fields.length) * 100).round();
}

/// Home ka real dashboard data.
class HomeStats {
  final int resumeScore; // 0-100 (last analyzed)
  final bool hasResume;
  final int applicationsCount;
  final int savedJobsCount;
  final int interviewsCount;
  final int avgInterviewScore; // 0-100
  final int profileCompletion; // 0-100
  final int totalPoints;

  const HomeStats({
    required this.resumeScore,
    required this.hasResume,
    required this.applicationsCount,
    required this.savedJobsCount,
    required this.interviewsCount,
    required this.avgInterviewScore,
    required this.profileCompletion,
    required this.totalPoints,
  });

  static const empty = HomeStats(
    resumeScore: 0,
    hasResume: false,
    applicationsCount: 0,
    savedJobsCount: 0,
    interviewsCount: 0,
    avgInterviewScore: 0,
    profileCompletion: 0,
    totalPoints: 0,
  );
}

/// Home ka real data laao (database se).
final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  final client = SupabaseService.client;
  final userId = SupabaseService.currentUser?.id;
  if (userId == null) return HomeStats.empty;

  // Last resume
  final resumeData = await client
      .from('resumes')
      .select('score, ats_score')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(1);
  final hasResume = (resumeData as List).isNotEmpty;
  final resumeScore = hasResume ? (resumeData[0]['score'] ?? 0) as int : 0;

  // Applications + saved
  final apps =
      await client.from('applications').select('id').eq('user_id', userId);
  final saved =
      await client.from('saved_jobs').select('id').eq('user_id', userId);
  final applicationsCount = (apps as List).length;
  final savedJobsCount = (saved as List).length;

  // Interviews (count + avg score)
  int interviewsCount = 0;
  int avgInterviewScore = 0;
  try {
    final interviews = await client
        .from('interviews')
        .select('overall_score')
        .eq('user_id', userId);
    final list = interviews as List;
    interviewsCount = list.length;
    if (list.isNotEmpty) {
      final sum = list.fold<int>(
          0, (a, e) => a + ((e['overall_score'] ?? 0) as int));
      avgInterviewScore = (sum / list.length).round();
    }
  } catch (_) {}

  // Profile completion
  int profileCompletion = 0;
  try {
    final profile = await client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (profile != null) {
      profileCompletion =
          _profileCompletion(Map<String, dynamic>.from(profile));
    }
  } catch (_) {}

  // Referral points
  final referralRow = await client
      .from('referrals')
      .select('reward_points')
      .eq('user_id', userId)
      .maybeSingle();
  final referralPoints = (referralRow?['reward_points'] ?? 0) as int;
  final totalPoints =
      referralPoints + (applicationsCount * 5) + (savedJobsCount * 2);

  return HomeStats(
    resumeScore: resumeScore,
    hasResume: hasResume,
    applicationsCount: applicationsCount,
    savedJobsCount: savedJobsCount,
    interviewsCount: interviewsCount,
    avgInterviewScore: avgInterviewScore,
    profileCompletion: profileCompletion,
    totalPoints: totalPoints,
  );
});

/// Ek recent activity item.
class ActivityEntry {
  final String text;
  final DateTime time;
  final String type; // resume / interview / application / saved
  const ActivityEntry({
    required this.text,
    required this.time,
    required this.type,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

/// Recent activity (real — resumes, interviews, applications se).
final recentActivityProvider =
    FutureProvider<List<ActivityEntry>>((ref) async {
  final client = SupabaseService.client;
  final userId = SupabaseService.currentUser?.id;
  if (userId == null) return [];

  final entries = <ActivityEntry>[];

  DateTime parseTime(dynamic v) =>
      DateTime.tryParse((v ?? '').toString())?.toLocal() ?? DateTime.now();

  try {
    final resumes = await client
        .from('resumes')
        .select('file_name, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(5);
    for (final r in resumes as List) {
      entries.add(ActivityEntry(
        text: 'Analyzed resume: ${r['file_name'] ?? 'Resume'}',
        time: parseTime(r['created_at']),
        type: 'resume',
      ));
    }
  } catch (_) {}

  try {
    final interviews = await client
        .from('interviews')
        .select('role, overall_score, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(5);
    for (final i in interviews as List) {
      final role = (i['role'] ?? 'Interview').toString();
      entries.add(ActivityEntry(
        text: 'Interview: $role (${i['overall_score'] ?? 0}/100)',
        time: parseTime(i['created_at']),
        type: 'interview',
      ));
    }
  } catch (_) {}

  try {
    final apps = await client
        .from('applications')
        .select('title, company, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(5);
    for (final a in apps as List) {
      final title = (a['title'] ?? 'a job').toString();
      final company = (a['company'] ?? '').toString();
      entries.add(ActivityEntry(
        text: company.isEmpty
            ? 'Applied to $title'
            : 'Applied to $title at $company',
        time: parseTime(a['created_at']),
        type: 'application',
      ));
    }
  } catch (_) {}

  // Time se sort, top 6
  entries.sort((a, b) => b.time.compareTo(a.time));
  return entries.take(6).toList();
});

/// Smart suggestions (real — user ke data ke gaps pe based).
final suggestionsProvider = FutureProvider<List<String>>((ref) async {
  final stats = await ref.watch(homeStatsProvider.future);
  final s = <String>[];

  if (!stats.hasResume) {
    s.add('Analyze your resume to get an ATS score and improvement tips.');
  } else if (stats.resumeScore < 75) {
    s.add('Your resume scored ${stats.resumeScore}. Re-analyze after improving it.');
  }

  if (stats.profileCompletion < 100) {
    s.add('Complete your profile (${stats.profileCompletion}%) for better personalized advice.');
  }

  if (stats.interviewsCount == 0) {
    s.add('Practice a mock interview to build your confidence.');
  } else if (stats.avgInterviewScore < 70) {
    s.add('Your interview average is ${stats.avgInterviewScore}. Practice more to improve.');
  }

  if (stats.applicationsCount == 0) {
    s.add('Explore Job Hub and apply to jobs that match your skills.');
  }

  // Hamesha kuch na kuch dikhe
  if (s.isEmpty) {
    s.add('You are doing great! Keep applying and practicing to stay sharp.');
  }
  return s.take(4).toList();
});