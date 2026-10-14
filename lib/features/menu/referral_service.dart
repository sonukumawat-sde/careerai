import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../services/supabase_service.dart';

/// Refer & Earn ka logic — user ka referral code + stats.
class ReferralService {
  ReferralService._();

  /// User ka referral data laao. Agar nahi hai toh naya code bana ke do.
  static Future<Either<Failure, Map<String, dynamic>>> getOrCreate() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return left(const Failure('Login required.'));
      final userId = user.id;

      // Pehle existing dekho
      final existing = await SupabaseService.client
          .from('referrals')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        return right(Map<String, dynamic>.from(existing));
      }

      // Naya code banao (naam + random se)
      final code = _generateCode(user.email ?? 'user');

      final inserted = await SupabaseService.client
          .from('referrals')
          .insert({
            'user_id': userId,
            'referral_code': code,
            'referred_count': 0,
            'reward_points': 0,
          })
          .select()
          .single();

      return right(Map<String, dynamic>.from(inserted));
    } catch (e) {
      return left(Failure('Referral data nahi mila: $e'));
    }
  }

  /// Email + random se ek unique-ish code banao (jaise RAHUL7X2K).
  static String _generateCode(String email) {
    final name = email.split('@').first.toUpperCase();
    final clean = name.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final prefix = clean.length >= 4 ? clean.substring(0, 4) : clean;
    final random = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7); // last few digits
    return '$prefix$random';
  }
}