import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Settings ka logic — notification prefs + language (real, database).
class SettingsService {
  SettingsService._();

  /// Saari settings laao (notification toggles + language).
  static Future<Either<Failure, Map<String, dynamic>>> getSettings() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

      final data = await SupabaseService.client
          .from('profiles')
          .select(
              'notif_push, notif_job_alerts, notif_application, notif_interview, notif_email, notif_marketing, app_language')
          .eq('id', userId)
          .single();

      return right(Map<String, dynamic>.from(data));
    } catch (e) {
      return left(Failure('Settings nahi mile: $e'));
    }
  }

  /// Ek setting update karo (jaise notif_push = false).
  static Future<Either<Failure, Unit>> updateSetting(
      String key, dynamic value) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

      await SupabaseService.client
          .from('profiles')
          .update({key: value}).eq('id', userId);
      return right(unit);
    } catch (e) {
      return left(Failure('Update nahi hua: $e'));
    }
  }

  /// Password change karo (Supabase Auth se, real).
  static Future<Either<Failure, Unit>> changePassword(
      String newPassword) async {
    try {
      await SupabaseService.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return right(unit);
    } catch (e) {
      return left(Failure('Password change nahi hua: $e'));
    }
  }
}