import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'settings_service.dart';

/// Language settings — select language (real, database me save).
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  bool _loading = true;
  String _selected = 'English';

  // Available languages (English abhi active, baaki aane wale)
  final _languages = const [
    {'name': 'English', 'native': 'English', 'available': true},
    {'name': 'Hindi', 'native': 'हिन्दी', 'available': false},
    {'name': 'Tamil', 'native': 'தமிழ்', 'available': false},
    {'name': 'Telugu', 'native': 'తెలుగు', 'available': false},
    {'name': 'Bengali', 'native': 'বাংলা', 'available': false},
    {'name': 'Marathi', 'native': 'मराठी', 'available': false},
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await SettingsService.getSettings();
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _loading = false),
      (data) => setState(() {
        _selected = (data['app_language'] ?? 'English').toString();
        _loading = false;
      }),
    );
  }

  Future<void> _select(String lang, bool available) async {
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$lang coming soon!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _selected = lang);
    await SettingsService.updateSetting('app_language', lang);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Language set to $lang'),
        backgroundColor: AppBrand.violet,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Language'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                const Text('Choose your preferred language',
                    style: TextStyle(
                        color: Color(0xFF64748B), fontSize: 14)),
                const SizedBox(height: 20),
                ..._languages.map((lang) {
                  final name = lang['name'] as String;
                  final native = lang['native'] as String;
                  final available = lang['available'] as bool;
                  final selected = _selected == name;

                  return GestureDetector(
                    onTap: () => _select(name, available),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppBrand.violet.withValues(alpha: 0.06)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected
                              ? AppBrand.violet
                              : const Color(0xFFEEF1F5),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(name,
                                      style: TextStyle(
                                          color: selected
                                              ? AppBrand.violet
                                              : const Color(0xFF0F172A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  if (!available) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Text('Soon',
                                          style: TextStyle(
                                              color: Color(0xFF94A3B8),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(native,
                                  style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 13)),
                            ],
                          ),
                          const Spacer(),
                          if (selected)
                            const Icon(Icons.check_circle,
                                color: AppBrand.violet, size: 24),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}