import 'package:flutter/material.dart';
import '../../../../core/theme/app_gradients.dart';
import '../resume_builder_data.dart';

/// Achievements step — list add/remove.
class AchievementsStep extends StatelessWidget {
  final ResumeData data;
  final VoidCallback onChanged;

  const AchievementsStep({
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
              child: const Icon(Icons.emoji_events_outlined,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Achievements',
                      style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Awards, certifications, or highlights. Optional.',
                      style:
                          TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tip banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppBrand.violet.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppBrand.violet.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: AppBrand.violet, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'e.g. "Winner, XYZ Hackathon 2024" or "AWS Certified Developer"',
                  style: TextStyle(
                      color: Color(0xFF475569), fontSize: 12.5, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ...data.achievements.asMap().entries.map((entry) {
          final i = entry.key;
          return _achievementField(i);
        }),

        GestureDetector(
          onTap: () {
            data.achievements.add('');
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
                Text('Add Achievement',
                    style: TextStyle(
                        color: AppBrand.violet,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
        if (data.achievements.isEmpty) ...[
          const SizedBox(height: 16),
          Center(
            child: Text('No achievements added yet. Tap above to add.',
                style: TextStyle(
                    color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
                    fontSize: 13)),
          ),
        ],
      ],
    );
  }

  Widget _achievementField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextFormField(
                initialValue: data.achievements[index],
                onChanged: (v) {
                  data.achievements[index] = v;
                  onChanged();
                },
                style:
                    const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                decoration: const InputDecoration(
                  hintText: 'e.g. Winner, XYZ Hackathon 2024',
                  hintStyle:
                      TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              data.achievements.removeAt(index);
              onChanged();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline,
                  color: Color(0xFFEF4444), size: 20),
            ),
          ),
        ],
      ),
    );
  }
}