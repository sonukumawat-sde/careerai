/// App-wide constants aur configuration.
///
/// IMPORTANT (bhai dhyan se):
/// - Yaha SIRF public keys aati hain (Supabase anon key public hoti hai, safe hai).
/// - Gemini AI ki SECRET KEY yaha KABHI mat daalna.
///   Wo Supabase Edge Function me rahegi (server pe), app me nahi.
class AppConfig {
  AppConfig._();

  static const String appName = 'CareerAI';
  static const String tagline = 'Your Personal AI Career Assistant';

  // TODO: Supabase project banao (supabase.com) aur ye 2 values yaha paste karo.
  // Ye "anon/public" key hai — client me daalna safe hai.
  static const String supabaseUrl = 'https://tffaiowxzgmgiapqfqle.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_wShbLuKfYUIMcnCry3JLxA_htRaYQKh';

  // Free plan ki daily limits (baad me monetization me use hongi)
  static const int freeResumeAnalysisLimit = 3;
  static const int freeInterviewQuestionsPerDay = 5;
  static const int freeCoachMessagesPerDay = 10;
  static const int freeJobSavesLimit = 10;
}