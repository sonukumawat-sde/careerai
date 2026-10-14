import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'applied_data.dart';

/// Applied job card — company + status badge + progress timeline.
class AppliedJobCard extends StatelessWidget {
  final AppliedJob job;
  final VoidCallback onTap;

  const AppliedJobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isRejected = job.status == AppStatus.rejected;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEEF1F5)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: job.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(job.company[0],
                        style: TextStyle(
                            color: job.color,
                            fontSize: 21,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('${job.company} · ${job.location}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: job.status.statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(job.status.label,
                      style: TextStyle(
                          color: job.status.statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Timeline (agar rejected nahi hai)
            if (!isRejected)
              _timeline(job.status.step)
            else
              Row(
                children: [
                  const Icon(Icons.cancel,
                      color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 6),
                  const Text('Application not selected',
                      style: TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            const SizedBox(height: 12),
            Text('Applied ${job.appliedDate}',
                style: const TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// Progress timeline — 4 steps: Applied, Review, Interview, Offer.
  Widget _timeline(int currentStep) {
    const labels = ['Applied', 'Review', 'Interview', 'Offer'];
    return Row(
      children: List.generate(4, (i) {
        final done = i <= currentStep;
        final isLast = i == 3;
        return Expanded(
          child: Row(
            children: [
              // Dot
              Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: done ? AppBrand.violet : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: done
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 11)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(labels[i],
                      style: TextStyle(
                          color: done
                              ? AppBrand.violet
                              : const Color(0xFF94A3B8),
                          fontSize: 9,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              // Line (last ke baad nahi)
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: i < currentStep
                        ? AppBrand.violet
                        : const Color(0xFFF1F5F9),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}