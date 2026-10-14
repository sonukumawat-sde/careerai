import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failure.dart';
import '../../services/supabase_service.dart';
import '../../services/purchase_service.dart';

/// Auth ka saara logic — signup, login, Google login, logout.
class AuthService {
  AuthService._();

  // Web Client ID (Google Cloud Console se) — native Google sign-in ke liye
  static const String _webClientId =
      '52866015860-k6vlfv940skpd1ujlbhd7uivnhtqjmou.apps.googleusercontent.com';

  /// Naya account banao (signup).
  static Future<Either<Failure, User>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await SupabaseService.client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
     final user = res.user;
      if (user == null) {
        return left(const Failure('Account nahi bana. Dobara try karo.'));
      }
      await PurchaseService.loginUser(user.id);
      return right(user);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure('Kuch galat hua: $e'));
    }
  }

  /// Login karo (existing account).
  static Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await SupabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = res.user;
      if (user == null) {
        return left(const Failure('Login fail hua. Email/password check karo.'));
      }
      await PurchaseService.loginUser(user.id);
      return right(user);
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure('Kuch galat hua: $e'));
    }
  }

  /// Google se login (native popup — browser nahi).
  static Future<Either<Failure, User>> signInWithGoogle() async {
    try {
      final signIn = GoogleSignIn.instance;

      // Initialize (serverClientId = Web Client ID)
      await signIn.initialize(serverClientId: _webClientId);

      // Native Google account chooser popup
      final googleUser = await signIn.authenticate();

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        return left(const Failure('Google login fail hua. Dobara try karo.'));
      }

      // Access token (scopes ke liye)
      final authorization = await googleUser.authorizationClient
          .authorizationForScopes(['email', 'profile']);
      final accessToken = authorization?.accessToken;

      // Supabase me sign in
      final res = await SupabaseService.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = res.user;
      if (user == null) {
        return left(const Failure('Login fail hua. Dobara try karo.'));
      }
      await PurchaseService.loginUser(user.id);
      return right(user);
    } on GoogleSignInException catch (e) {
      // User ne cancel kiya ya koi Google error
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return left(const Failure('Google login cancel ho gaya.'));
      }
      return left(Failure('Google login error: ${e.description ?? e.code}'));
    } on AuthException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure('Kuch galat hua: $e'));
    }
  }

  /// Logout.
  static Future<void> logout() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    await PurchaseService.logoutUser();
    await SupabaseService.client.auth.signOut();
  }
  /// Referral code apply karo (signup ke baad). Backend function call karta hai.
  static Future<String> applyReferralCode(String code) async {
    try {
      if (code.trim().isEmpty) return 'empty';
      final res = await SupabaseService.client.rpc(
        'apply_referral_code',
        params: {'p_code': code.trim().toUpperCase()},
      );
      return res?.toString() ?? 'error';
    } catch (e) {
      return 'error';
    }
  }
}