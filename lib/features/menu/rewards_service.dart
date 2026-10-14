import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../services/supabase_service.dart';

/// User ke rewards ka poora data (points + counts + level).
class RewardsData {
  final int totalPoints;
  final int applicationsCount;
  final int savedJobsCount;
  final int resumesCount;
  final int referralCount;
  final int level;
  final String rank;
  final int currentLevelXp;
  final int nextLevelXp;

  const RewardsData({
    required this.totalPoints,
    required this.applicationsCount,
    required this.savedJobsCount,
    required this.resumesCount,
    required this.referralCount,
    required this.level,
    required this.rank,
    required this.currentLevelXp,
    required this.nextLevelXp,
  });
}

/// Rewards ka logic — sab counts + points database se laao, level calculate karo.
class RewardsService {
  RewardsService._();

  static Future<Either<Failure, RewardsData>> getRewards() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

     final client = SupabaseService.client;

      // Sab data ek-ek laao
      final appsData =
          await client.from('applications').select('id').eq('user_id', userId);
      final savedData =
          await client.from('saved_jobs').select('id').eq('user_id', userId);
      final resumesData =
          await client.from('resumes').select('id').eq('user_id', userId);
      final referralRow = await client
          .from('referrals')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      final applications = (appsData as List).length;
      final savedJobs = (savedData as List).length;
      final resumes = (resumesData as List).length;

      final referralPoints =
          (referralRow?['reward_points'] ?? 0) as int;
      final referralCount = (referralRow?['referred_count'] ?? 0) as int;

      // Total points calculate: referral points + activities
      // apply +5 each, resume +10 each, save +2 each
      final totalPoints = referralPoints +
          (applications * 5) +
          (resumes * 10) +
          (savedJobs * 2);

      // Level calculate (har 500 points = 1 level)
      final level = (totalPoints ~/ 500) + 1;
      final currentLevelXp = totalPoints % 500;
      const nextLevelXp = 500;
      final rank = _rankForLevel(level);

      return right(RewardsData(
        totalPoints: totalPoints,
        applicationsCount: applications,
        savedJobsCount: savedJobs,
        resumesCount: resumes,
        referralCount: referralCount,
        level: level,
        rank: rank,
        currentLevelXp: currentLevelXp,
        nextLevelXp: nextLevelXp,
      ));
    } catch (e) {
      return left(Failure('Rewards nahi mile: $e'));
    }
  }

  static String _rankForLevel(int level) {
    if (level >= 10) return 'Master';
    if (level >= 7) return 'Expert';
    if (level >= 4) return 'Pro';
    if (level >= 2) return 'Rising Star';
    return 'Beginner';
  }
}