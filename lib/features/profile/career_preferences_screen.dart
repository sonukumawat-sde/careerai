import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'profile_service.dart';

/// Career Preferences — target role, salary, location, remote (real, database).
class CareerPreferencesScreen extends StatefulWidget {
  const CareerPreferencesScreen({super.key});

  @override
  State<CareerPreferencesScreen> createState() =>
      _CareerPreferencesScreenState();
}

class _CareerPreferencesScreenState extends State<CareerPreferencesScreen> {
  final _roleController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController();
  bool _openToRemote = false;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _roleController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await ProfileService.getProfile();
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _loading = false),
      (data) => setState(() {
        _roleController.text = (data['target_role'] ?? '').toString();
        _salaryController.text = (data['expected_salary'] ?? '').toString();
        _locationController.text =
            (data['preferred_location'] ?? '').toString();
        _openToRemote = (data['open_to_remote'] ?? false) as bool;
        _loading = false;
      }),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await ProfileService.updateProfile({
      'target_role': _roleController.text.trim(),
      'expected_salary': _salaryController.text.trim(),
      'preferred_location': _locationController.text.trim(),
      'open_to_remote': _openToRemote,
    });
    if (!mounted) return;
    setState(() => _saving = false);
    result.match(
      (failure) => _showMsg(failure.message, false),
      (_) {
        _showMsg('Preferences saved!', true);
        Navigator.pop(context);
      },
    );
  }

  void _showMsg(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? AppBrand.violet : const Color(0xFFEF4444),
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
        title: const Text('Career Preferences'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppBrand.violet.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppBrand.violet.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tune, color: AppBrand.violet, size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Set your preferences to get matched with the right jobs.',
                          style: TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _label('Target Role'),
                _field(_roleController,
                    'e.g. Senior Flutter Developer', Icons.work_outline),
                const SizedBox(height: 18),

                _label('Expected Salary'),
                _field(_salaryController, 'e.g. ₹12-18 LPA',
                    Icons.payments_outlined),
                const SizedBox(height: 18),

                _label('Preferred Location'),
                _field(_locationController, 'e.g. Bangalore, Remote',
                    Icons.location_on_outlined),
                const SizedBox(height: 20),

                // Remote toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi, color: AppBrand.violet, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Open to Remote Work',
                            style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                      Switch(
                        value: _openToRemote,
                        activeColor: AppBrand.violet,
                        onChanged: (v) => setState(() => _openToRemote = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                GestureDetector(
                  onTap: _saving ? null : _save,
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
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text('Save Preferences',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w700)),
    );
  }

  Widget _field(TextEditingController controller, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}