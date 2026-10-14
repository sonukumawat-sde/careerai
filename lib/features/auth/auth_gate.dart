import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/widgets/main_shell.dart';
import '../../services/supabase_service.dart';
import '../../services/local_storage.dart' as app_storage;
import '../onboarding/onboarding_screen.dart';
import 'auth_screen.dart';

/// The app's gate. Decides what to show when the app opens:
///
/// 1. User is logged in         -> Home (MainShell)
/// 2. Onboarding not seen       -> Onboarding (then role -> signup)
/// 3. Onboarding completed      -> Login/Signup
///
/// Listens to Supabase auth state — screen changes automatically on login/logout.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = SupabaseService.client.auth.currentSession;

        // 1. Logged in -> Home
        if (session != null) {
          return const MainShell();
        }

        // 2. Onboarding dekhi nahi -> Onboarding
       if (!app_storage.LocalStorage.hasSeenOnboarding) {
          return const OnboardingScreen();
        }

        // 3. Onboarding dekh li, par logged out -> Login
        return const AuthScreen();
      },
    );
  }
}