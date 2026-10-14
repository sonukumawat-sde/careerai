import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../core/theme/app_gradients.dart';
import '../../services/purchase_service.dart';

/// Premium/Upgrade screen — plans, feature comparison, REAL subscribe.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _yearly = true; // yearly default (better value)
  bool _loading = true;
  bool _purchasing = false;
  Offerings? _offerings;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() => _loading = true);
    final offerings = await PurchaseService.getOfferings();
    if (!mounted) return;
    setState(() {
      _offerings = offerings;
      _loading = false;
      if (offerings?.current == null) {
        _error = 'Plans abhi load nahi ho rahe. Dobara try karo.';
      }
    });
  }

  Package? get _selectedPackage {
    final current = _offerings?.current;
    if (current == null) return null;
    if (_yearly) {
      return current.annual ?? current.availablePackages.firstOrNull;
    }
    return current.monthly ?? current.availablePackages.firstOrNull;
  }

  Future<void> _purchase() async {
    final package = _selectedPackage;
    if (package == null) {
      _showMessage('Plan available nahi hai abhi.');
      return;
    }

    setState(() => _purchasing = true);
    final success = await PurchaseService.purchase(package);
    if (!mounted) return;
    setState(() => _purchasing = false);

    if (success) {
      _showMessage('Welcome to CareerAI Pro! 🎉', success: true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      _showMessage('Payment complete nahi hua. Dobara try karo.');
    }
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    final restored = await PurchaseService.restore();
    if (!mounted) return;
    setState(() => _purchasing = false);

    if (restored) {
      _showMessage('Purchase restore ho gaya! 🎉', success: true);
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      _showMessage('Koi purchase nahi mila is account me.');
    }
  }

  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _priceFor(bool yearly) {
    final current = _offerings?.current;
    if (current == null) return yearly ? '₹999' : '₹149';
    final pkg = yearly
        ? (current.annual ?? current.availablePackages.firstOrNull)
        : (current.monthly ?? current.availablePackages.firstOrNull);
    return pkg?.storeProduct.priceString ?? (yearly ? '₹999' : '₹149');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B4B),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppBrand.violet.withValues(alpha: 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white70, size: 22),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.workspace_premium,
                        color: Colors.white, size: 44),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('CareerAI Pro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text('Unlock unlimited AI power for your career',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 15)),
                const SizedBox(height: 28),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  )
                else if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        Text(_error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70)),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _loadOfferings,
                          child: const Text('Retry',
                              style: TextStyle(color: AppBrand.violet)),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // ---- Plan toggle ----
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _planTab('Monthly', false),
                        _planTab('Yearly', true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ---- Price card ----
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppBrand.violet.withValues(alpha: 0.3),
                          AppBrand.indigo.withValues(alpha: 0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppBrand.violet.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        if (_yearly)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('BEST VALUE',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800)),
                          ),
                        const SizedBox(height: 12),
                        Text(_priceFor(_yearly),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w900,
                                height: 1)),
                        const SizedBox(height: 6),
                        Text(
                            _yearly
                                ? 'per year, billed annually'
                                : 'per month, billed monthly',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text("What's included",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 16),
                  _feature('Unlimited Resume Analysis'),
                  _feature('Unlimited AI Coach Chats'),
                  _feature('Unlimited Interview Practice'),
                  _feature('Unlimited Resume Downloads'),
                  _feature('Personalized Career Roadmap'),
                  _feature('Priority Support'),
                  const SizedBox(height: 28),

                  // ---- Subscribe button ----
                  GestureDetector(
                    onTap: _purchasing ? null : _purchase,
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _purchasing
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Text('Subscribe Now',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _purchasing ? null : _restore,
                    child: Text('Restore Purchases',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],

                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _trust(Icons.check_circle_outline, 'Cancel anytime'),
                    const SizedBox(width: 20),
                    _trust(Icons.lock_outline, 'Secure payment'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _planTab(String label, bool isYearly) {
    final selected = _yearly == isYearly;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _yearly = isYearly),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: selected ? AppGradients.buttonGradient : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  Widget _feature(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _trust(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.6), size: 16),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
      ],
    );
  }
}