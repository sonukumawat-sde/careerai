import 'package:hive_flutter/hive_flutter.dart';

/// Local storage — sirf chhoti device-level cheezein (jaise onboarding dekhi kya).
/// User ka asli data (profile, role) database me jata hai, yaha nahi.
class LocalStorage {
  LocalStorage._();

  static const String _boxName = 'careerai_box';
  static late Box _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  static bool get hasSeenOnboarding =>
      _box.get('seen_onboarding', defaultValue: false) as bool;

  static Future<void> setSeenOnboarding() async =>
      _box.put('seen_onboarding', true);
}