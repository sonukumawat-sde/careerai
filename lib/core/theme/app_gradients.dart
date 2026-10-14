import 'package:flutter/material.dart';

/// CareerAI ka OFFICIAL brand color system.
/// Ye colors branding image se match karte hain — deep purple background,
/// violet-blue gradient, aur glowing accents. Poora app isi pe khada hai.
class AppBrand {
  AppBrand._();

  // ---- Core brand colors (branding image se) ----
  static const Color violet = Color(0xFF8B5CF6);   // primary violet
  static const Color purple = Color(0xFF7C3AED);   // deep purple
  static const Color indigo = Color(0xFF6366F1);   // indigo blue
  static const Color blueAccent = Color(0xFF3B82F6); // blue pop
  static const Color cyanGlow = Color(0xFF22D3EE);  // robot eye cyan

  // ---- Backgrounds (deep space purple-black) ----
  static const Color bgTop = Color(0xFF1E1340);     // deep purple top
  static const Color bgMid = Color(0xFF130B2B);     // mid
  static const Color bgBottom = Color(0xFF0A0618);  // near-black bottom

  // ---- Glass surfaces ----
  static const Color glassFill = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x24FFFFFF);
}

/// Gradients jo poore app me use honge.
class AppGradients {
  AppGradients._();

  /// Main app background — 3-stop deep purple gradient (branding jaisa).
  static const LinearGradient authBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppBrand.bgTop,
      AppBrand.bgMid,
      AppBrand.bgBottom,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Primary button gradient (violet -> purple -> indigo).
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppBrand.violet,
      AppBrand.purple,
    ],
  );

  /// Illustration ke peeche ka soft glow.
  static const RadialGradient purpleGlow = RadialGradient(
    colors: [
      Color(0x558B5CF6),
      Color(0x00000000),
    ],
  );

  // Purane naam bhi rakhe hain taaki baaki files na tootein.
  static const Color glassBorder = AppBrand.glassBorder;
  static const Color glassFill = AppBrand.glassFill;
}