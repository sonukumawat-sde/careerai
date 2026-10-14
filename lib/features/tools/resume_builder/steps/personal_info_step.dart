import 'package:flutter/material.dart';
import '../../../../core/theme/app_gradients.dart';
import '../resume_builder_data.dart';

/// Step 1 — Personal Info. Naam, email, phone, location, LinkedIn.
class PersonalInfoStep extends StatelessWidget {
  final ResumeData data;
  final VoidCallback onChanged;

  const PersonalInfoStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          Icons.person_outline,
          'Personal Information',
          'Let\'s start with your basic details.',
        ),
        const SizedBox(height: 24),
        _field(
          label: 'Full Name',
          hint: 'e.g. Rahul Sharma',
          icon: Icons.badge_outlined,
          value: data.fullName,
          onChanged: (v) {
            data.fullName = v;
            onChanged();
          },
        ),
        _field(
          label: 'Email',
          hint: 'e.g. rahul@email.com',
          icon: Icons.mail_outline,
          value: data.email,
          keyboard: TextInputType.emailAddress,
          onChanged: (v) {
            data.email = v;
            onChanged();
          },
        ),
        _field(
          label: 'Phone',
          hint: 'e.g. +91 98765 43210',
          icon: Icons.phone_outlined,
          value: data.phone,
          keyboard: TextInputType.phone,
          onChanged: (v) {
            data.phone = v;
            onChanged();
          },
        ),
        _field(
          label: 'Location',
          hint: 'e.g. Bangalore, India',
          icon: Icons.location_on_outlined,
          value: data.location,
          onChanged: (v) {
            data.location = v;
            onChanged();
          },
        ),
       _field(
          label: 'LinkedIn (optional)',
          hint: 'e.g. linkedin.com/in/rahul',
          icon: Icons.link,
          value: data.linkedIn,
          onChanged: (v) {
            data.linkedIn = v;
            onChanged();
          },
        ),
        _field(
          label: 'GitHub (optional)',
          hint: 'e.g. github.com/rahul',
          icon: Icons.code,
          value: data.github,
          onChanged: (v) {
            data.github = v;
            onChanged();
          },
        ),
      ],
    );
  }

  Widget _header(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: AppGradients.buttonGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppBrand.violet.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 19,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required IconData icon,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextFormField(
              initialValue: value,
              keyboardType: keyboard,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: Icon(icon, color: AppBrand.violet, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}