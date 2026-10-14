import 'package:flutter/material.dart';
import '../../../../core/theme/app_gradients.dart';
import '../resume_builder_data.dart';

/// Step 4 — Education. Multiple add/remove.
class EducationStep extends StatelessWidget {
  final ResumeData data;
  final VoidCallback onChanged;

  const EducationStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
              child: const Icon(Icons.school_outlined,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Education',
                      style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Add your degrees and qualifications.',
                      style:
                          TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        ...data.educations.asMap().entries.map((entry) {
          final i = entry.key;
          final edu = entry.value;
          return _eduCard(i, edu);
        }),

        GestureDetector(
          onTap: () {
            data.educations.add(Education());
            onChanged();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppBrand.violet.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppBrand.violet.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: AppBrand.violet, size: 20),
                SizedBox(width: 8),
                Text('Add Education',
                    style: TextStyle(
                        color: AppBrand.violet,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        if (data.educations.isEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: Text('No education added yet. Tap above to add.',
                style: TextStyle(
                    color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
                    fontSize: 13)),
          ),
        ],
      ],
    );
  }

  Widget _eduCard(int index, Education edu) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF1F5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppBrand.violet.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('Education ${index + 1}',
                    style: const TextStyle(
                        color: AppBrand.violet,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  data.educations.removeAt(index);
                  onChanged();
                },
                child: const Icon(Icons.delete_outline,
                    color: Color(0xFFEF4444), size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _miniField('Degree', 'e.g. B.Tech in Computer Science', edu.degree,
              (v) {
            edu.degree = v;
            onChanged();
          }),
          _miniField('Institution', 'e.g. IIT Delhi', edu.institution, (v) {
            edu.institution = v;
            onChanged();
          }),
          _miniField('Location', 'e.g. New Delhi, India', edu.location, (v) {
            edu.location = v;
            onChanged();
          }),
          _miniField('Year', 'e.g. 2018 - 2022', edu.year, (v) {
            edu.year = v;
            onChanged();
          }),
          _miniField('Coursework (optional)',
              'e.g. Data Structures, Algorithms, DBMS', edu.coursework, (v) {
            edu.coursework = v;
            onChanged();
          }),
        ],
      ),
    );
  }

  Widget _miniField(String label, String hint, String value,
      ValueChanged<String> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 6),
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextFormField(
              initialValue: value,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle:
                    const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}