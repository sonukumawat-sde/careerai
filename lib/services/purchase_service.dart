import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/supabase_service.dart';

/// RevenueCat ka saara logic — initialize, offerings, purchase, restore.
class PurchaseService {
  PurchaseService._();

  // RevenueCat API key (test key — production me badlenge)
  static const String _apiKey = 'goog_RCNUKUCqfdzVbaFEPeoFNgDLvBv ';

  // Entitlement identifier (RevenueCat dashboard me set karenge)
  static const String entitlementId = 'premium';

  /// App start pe ek baar call karo (main.dart me).
  static Future<void> init() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      final config = PurchasesConfiguration(_apiKey);
      await Purchases.configure(config);

      // User login ho toh RevenueCat ko bhi user ID do (taaki purchases sync rahe)
      final userId = SupabaseService.currentUser?.id;
      if (userId != null) {
        await Purchases.logIn(userId);
      }
    } catch (e) {
      // Init fail hone pe app crash na ho
    }
  }

  /// User login/signup ke baad call karo (RevenueCat ko user ID do).
  static Future<void> loginUser(String userId) async {
    try {
      await Purchases.logIn(userId);
    } catch (_) {}
  }

  /// Logout pe call karo.
  static Future<void> logoutUser() async {
    try {
      await Purchases.logOut();
    } catch (_) {}
  }

  /// Available plans (offerings) lao — monthly/yearly.
  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (_) {
      return null;
    }
  }

  /// Purchase karo (ek package select karke).
  static Future<bool> purchase(Package package) async {
    try {
     final result = await Purchases.purchasePackage(package);
      final isPremium =
          result.customerInfo.entitlements.all[entitlementId]?.isActive ?? false;  
      if (isPremium) {
        await _syncPremiumToSupabase(true);
      }
      return isPremium;
    } catch (e) {
      return false;
    }
  }

  /// Restore purchases (naye phone pe ya reinstall ke baad).
  static Future<bool> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      final isPremium =
          info.entitlements.all[entitlementId]?.isActive ?? false;
      if (isPremium) {
        await _syncPremiumToSupabase(true);
      }
      return isPremium;
    } catch (_) {
      return false;
    }
  }

  /// Abhi premium hai ya nahi (RevenueCat se check).
  static Future<bool> checkPremiumStatus() async {
    try {
      final info = await Purchases.getCustomerInfo();
      final isPremium =
          info.entitlements.all[entitlementId]?.isActive ?? false;
      await _syncPremiumToSupabase(isPremium);
      return isPremium;
    } catch (_) {
      return false;
    }
  }

  /// Supabase profiles table me is_premium update karo.
  static Future<void> _syncPremiumToSupabase(bool isPremium) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return;
      await SupabaseService.client
          .from('profiles')
          .update({'is_premium': isPremium}).eq('id', userId);
    } catch (_) {}
  }
}