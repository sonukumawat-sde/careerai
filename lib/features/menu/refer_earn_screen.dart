import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_gradients.dart';
import 'referral_service.dart';

/// Menu > Refer & Earn — real referral code + share + stats.
class ReferEarnScreen extends StatefulWidget {
  const ReferEarnScreen({super.key});

  @override
  State<ReferEarnScreen> createState() => _ReferEarnScreenState();
}

class _ReferEarnScreenState extends State<ReferEarnScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await ReferralService.getOrCreate();
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _loading = false),
      (data) => setState(() {
        _data = data;
        _loading = false;
      }),
    );
  }

  String get _code => _data?['referral_code']?.toString() ?? '...';
  int get _count => (_data?['referred_count'] ?? 0) as int;
  int get _points => (_data?['reward_points'] ?? 0) as int;

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

 void _share() {
    // NOTE: App launch hone pe ye link asli Play Store link se badal dena
    const appLink = 'https://careerai.app'; // abhi placeholder

    Share.share(
      'Join me on CareerAI — the AI-powered app to land your dream job! 🚀\n\n'
      'Use my referral code: $_code\n\n'
      'Download now: $appLink',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Refer & Earn'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                // ---- Hero ----
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppBrand.purple,
                        AppBrand.violet,
                        AppBrand.indigo
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppBrand.violet.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.card_giftcard,
                            color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: 16),
                      const Text('Invite Friends, Earn Rewards',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      const Text(
                          'Share your code. When friends join, you both earn Pro rewards!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Stats ----
                Row(
                  children: [
                    Expanded(
                      child: _statCard(
                          '$_count', 'Friends Joined', Icons.people_outline),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _statCard('$_points', 'Points Earned',
                          Icons.stars_outlined),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ---- Referral code box ----
                const Text('Your Referral Code',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppBrand.violet.withValues(alpha: 0.3),
                        width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_code,
                            style: const TextStyle(
                                color: AppBrand.violet,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2)),
                      ),
                      GestureDetector(
                        onTap: _copyCode,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppBrand.violet.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.copy,
                              color: AppBrand.violet, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ---- Share button ----
                GestureDetector(
                  onTap: _share,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppGradients.buttonGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppBrand.violet.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share, color: Colors.white, size: 20),
                        SizedBox(width: 10),
                        Text('Share Invite',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ---- How it works ----
                const Text('How it works',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                _step('1', 'Share your referral code with friends'),
                _step('2', 'They sign up using your code'),
                _step('3', 'You both earn Pro rewards & points'),
              ],
            ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppBrand.violet, size: 26),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 24,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _step(String num, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: AppGradients.buttonGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(num,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}