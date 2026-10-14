import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'profile_service.dart';

/// Personal Details — education, experience, skills (real, database).
/// Ye data AI ko personalized resume/coaching dene me kaam aata hai.
class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillsController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _educationController.dispose();
    _experienceController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final result = await ProfileService.getProfile();
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _loading = false),
      (data) => setState(() {
        _educationController.text = (data['education'] ?? '').toString();
        _experienceController.text = (data['experience'] ?? '').toString();
        _skillsController.text = (data['skills'] ?? '').toString();
        _loading = false;
      }),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await ProfileService.updateProfile({
      'education': _educationController.text.trim(),
      'experience': _experienceController.text.trim(),
      'skills': _skillsController.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    result.match(
      (failure) => _showMsg(failure.message, false),
      (_) {
        _showMsg('Details saved!', true);
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
        title: const Text('Personal Details'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                // Info banner
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
                      const Icon(Icons.auto_awesome,
                          color: AppBrand.violet, size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'These details help our AI give you better resume tips and job matches.',
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

                _label('Education'),
                _field(_educationController,
                    'e.g. B.Tech in Computer Science, XYZ University',
                    Icons.school_outlined,
                    maxLines: 2),
                const SizedBox(height: 18),

                _label('Experience'),
                _field(_experienceController,
                    'e.g. 2 years as Flutter Developer at ABC Corp',
                    Icons.work_outline,
                    maxLines: 3),
                const SizedBox(height: 18),

                _label('Skills'),
                _field(_skillsController,
                    'e.g. Flutter, Dart, Firebase, REST API',
                    Icons.code,
                    maxLines: 2),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('Separate skills with commas',
                      style: TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 12)),
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
                          : const Text('Save Details',
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

  Widget _field(TextEditingController controller, String hint, IconData icon,
      {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}