import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'settings_service.dart';

/// Notifications Settings — real toggles, database me save.
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  bool _loading = true;
  final Map<String, bool> _settings = {
    'notif_push': true,
    'notif_job_alerts': true,
    'notif_application': true,
    'notif_interview': true,
    'notif_email': true,
    'notif_marketing': false,
  };

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
        for (final key in _settings.keys) {
          if (data[key] != null) _settings[key] = data[key] as bool;
        }
        _loading = false;
      }),
    );
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => _settings[key] = value);
    // Turant database me save
    await SettingsService.updateSetting(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                _sectionLabel('GENERAL'),
                _tile(
                  'Push Notifications',
                  'Receive notifications on your device',
                  Icons.notifications_active_outlined,
                  'notif_push',
                ),
                const SizedBox(height: 20),

                _sectionLabel('JOBS'),
                _tile(
                  'Job Alerts',
                  'New jobs matching your profile',
                  Icons.work_outline,
                  'notif_job_alerts',
                ),
                _tile(
                  'Application Updates',
                  'Status changes on your applications',
                  Icons.assignment_outlined,
                  'notif_application',
                ),
                _tile(
                  'Interview Reminders',
                  'Reminders for interview practice',
                  Icons.mic_none_outlined,
                  'notif_interview',
                ),
                const SizedBox(height: 20),

                _sectionLabel('OTHER'),
                _tile(
                  'Email Notifications',
                  'Get important updates via email',
                  Icons.mail_outline,
                  'notif_email',
                ),
                _tile(
                  'Promotions & Offers',
                  'News, tips, and special offers',
                  Icons.local_offer_outlined,
                  'notif_marketing',
                ),
              ],
            ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 4),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6)),
    );
  }

  Widget _tile(String title, String subtitle, IconData icon, String key) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: AppBrand.violet.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppBrand.violet, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: _settings[key] ?? false,
            activeColor: AppBrand.violet,
            onChanged: (v) => _toggle(key, v),
          ),
        ],
      ),
    );
  }
}