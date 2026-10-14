import 'package:flutter/material.dart';
import '../../../../core/theme/app_gradients.dart';
import '../resume_builder_data.dart';

/// Step 2 — Professional Summary. Ek short bio.
class SummaryStep extends StatelessWidget {
  final ResumeData data;
  final VoidCallback onChanged;

  const SummaryStep({
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
              child: const Icon(Icons.article_outlined,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Professional Summary',
                      style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('A short intro that highlights your strengths.',
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
                  'Tip: Keep it 2-3 sentences. Mention your role, experience, and key skills.',
                  style: TextStyle(
                      color: Color(0xFF475569), fontSize: 12.5, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('Your Summary',
              style: TextStyle(
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
            initialValue: data.summary,
            maxLines: 6,
            onChanged: (v) {
              data.summary = v;
              onChanged();
            },
            style: const TextStyle(
                fontSize: 15, color: Color(0xFF0F172A), height: 1.5),
            decoration: const InputDecoration(
              hintText:
                  'e.g. Passionate Flutter Developer with 3+ years of experience building scalable mobile apps. Skilled in Dart, Firebase, and clean architecture...',
              hintStyle: TextStyle(
                  color: Color(0xFF94A3B8), fontSize: 14, height: 1.5),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text('${data.summary.length} characters',
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ),
      ],
    );
  }
}