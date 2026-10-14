import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/app_config.dart';

/// Supabase ka single entry point.
/// Auth, Database, Storage, Edge Functions — sab yahi se access hote hain.
class SupabaseService {
  SupabaseService._();

  /// App start pe main.dart me call hota hai.
  static Future<void> init() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
  }

  /// Poore app me `SupabaseService.client` se access karo.
  static SupabaseClient get client => Supabase.instance.client;

  /// Abhi ka logged-in user (null agar login nahi hai).
  static User? get currentUser => client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;
}