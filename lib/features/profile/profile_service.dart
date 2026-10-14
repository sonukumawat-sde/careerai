import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../services/supabase_service.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

/// User profile ka logic — database (profiles table) se baat karta hai.
class ProfileService {
  ProfileService._();

  /// User ka role save/update karo (database me).
  static Future<Either<Failure, Unit>> updateRole(String role) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        return left(const Failure('User logged in nahi hai.'));
      }
      await SupabaseService.client
          .from('profiles')
          .update({'role': role, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
      return right(unit);
    } catch (e) {
      return left(Failure('Role save nahi hua: $e'));
    }
    
  }

  /// User ka poora profile laao (database se).
  static Future<Either<Failure, Map<String, dynamic>>> getProfile() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        return left(const Failure('User logged in nahi hai.'));
      }
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      return right(data);
    } catch (e) {
      return left(Failure('Profile nahi mila: $e'));
    }
  }
  /// Poora profile update karo (edit profile, personal details, preferences).
  static Future<Either<Failure, Unit>> updateProfile(
      Map<String, dynamic> data) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        return left(const Failure('User logged in nahi hai.'));
      }
      await SupabaseService.client
          .from('profiles')
          .update({
            ...data,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      return right(unit);
    } catch (e) {
      return left(Failure('Profile update nahi hua: $e'));
    }
  }
  /// Profile photo upload karo (Supabase Storage) + URL database me save.
  static Future<Either<Failure, String>> uploadAvatar(File imageFile) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        return left(const Failure('User logged in nahi hai.'));
      }

      // File ka naam: userId.jpg (har user ka apna, overwrite hoga)
      final fileName = '$userId.jpg';
      final bytes = await imageFile.readAsBytes();

      // Storage me upload (upsert = overwrite agar pehle se hai)
      await SupabaseService.client.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Public URL lo (cache-bust ke liye timestamp)
      final url = SupabaseService.client.storage
          .from('avatars')
          .getPublicUrl(fileName);
      final finalUrl =
          '$url?t=${DateTime.now().millisecondsSinceEpoch}';

      // Database me URL save
      await SupabaseService.client
          .from('profiles')
          .update({'avatar_url': finalUrl}).eq('id', userId);

      return right(finalUrl);
    } catch (e) {
      return left(Failure('Photo upload nahi hua: $e'));
    }
  }
}