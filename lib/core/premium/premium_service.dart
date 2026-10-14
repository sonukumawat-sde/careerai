import '../../services/supabase_service.dart';

/// Har feature ki free limit (month me).
class FeatureLimits {
  static const int resumeAnalyzer = 3; // 3 analysis/month free
 static const int resumeBuilder = 3; // 3 resumes free
  static const int interviewPractice = 2; // 2/day free
  static const int careerCoach = 5; // 5 messages/day free
}

/// Premium + usage ka logic. Har module isse check karega.
class PremiumService {
  PremiumService._();

  /// User premium hai ya nahi.
  static Future<bool> isPremium() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return false;

      final data = await SupabaseService.client
          .from('profiles')
          .select('is_premium')
          .eq('id', userId)
          .single();

      return (data['is_premium'] ?? false) as bool;
    } catch (_) {
      return false;
    }
  }

  /// Current period string (month, jaise "2026-07").
  static String _currentPeriod() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// Kisi feature ka usage count laao (is month).
  static Future<int> getUsage(String feature) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return 0;

      final data = await SupabaseService.client
          .from('feature_usage')
          .select('used_count')
          .eq('user_id', userId)
          .eq('feature', feature)
          .eq('period', _currentPeriod())
          .maybeSingle();

      if (data == null) return 0;
      return (data['used_count'] ?? 0) as int;
    } catch (_) {
      return 0;
    }
  }

  /// Feature use kar sakta hai? (premium ya limit ke andar)
  static Future<bool> canUse(String feature, int freeLimit) async {
    // Premium user - hamesha yes
    if (await isPremium()) return true;
    // Free user - limit check
    final used = await getUsage(feature);
    return used < freeLimit;
  }

  /// Feature use hone pe count +1 karo.
  static Future<void> recordUsage(String feature) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;
      final period = _currentPeriod();

      // Pehle current dekho
      final existing = await SupabaseService.client
          .from('feature_usage')
          .select('id, used_count')
          .eq('user_id', userId)
          .eq('feature', feature)
          .eq('period', period)
          .maybeSingle();

      if (existing == null) {
        // Naya banao
        await SupabaseService.client.from('feature_usage').insert({
          'user_id': userId,
          'feature': feature,
          'period': period,
          'used_count': 1,
        });
      } else {
        // Count badhao
        final newCount = ((existing['used_count'] ?? 0) as int) + 1;
        await SupabaseService.client
            .from('feature_usage')
            .update({'used_count': newCount}).eq('id', existing['id']);
      }
    } catch (_) {}
  }

  /// Kitne free uses bache hai (dikhane ke liye).
  static Future<int> remaining(String feature, int freeLimit) async {
    if (await isPremium()) return -1; // -1 = unlimited
    final used = await getUsage(feature);
    final left = freeLimit - used;
    return left < 0 ? 0 : left;
  }
}