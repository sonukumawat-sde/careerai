import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'features/auth/auth_gate.dart';
import 'features/splash/splash_screen.dart';
import 'services/supabase_service.dart';
import 'services/local_storage.dart';
import 'services/purchase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.init();
  await LocalStorage.init(); 
  await PurchaseService.init();
   // onboarding dekhi ya nahi, ye yaad rakhne ke liye

  runApp(const ProviderScope(child: CareerAiApp()));
}

class CareerAiApp extends StatelessWidget {
  const CareerAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: const SplashScreen(nextScreen: AuthGate()),
    );
  }
}