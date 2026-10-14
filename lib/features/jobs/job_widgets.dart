import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';

/// Ek job ka data (real — JSearch API se).
class Job {
  final String id;
  final String title;
  final String company;
  final String? logo;
  final String location;
  final String type;
  final bool remote;
  final String description;
  final String applyLink;
  final Color color;

  const Job({
    required this.id,
    required this.title,
    required this.company,
    this.logo,
    required this.location,
    required this.type,
    required this.remote,
    required this.description,
    required this.applyLink,
    required this.color,
  });

  factory Job.fromMap(Map<String, dynamic> map, Color color) {
    return Job(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Unknown Role',
      company: map['company']?.toString() ?? 'Company',
      logo: map['logo']?.toString(),
      location: map['location']?.toString() ?? 'Remote',
      type: map['type']?.toString() ?? 'Full-time',
      remote: map['remote'] == true,
      description: map['description']?.toString() ?? '',
      applyLink: map['applyLink']?.toString() ?? '',
      color: color,
    );
  }
}

/// Brand colors rotate karne ke liye (har job ko alag color).
const List<Color> jobColors = [
  AppBrand.violet,
  AppBrand.blueAccent,
  AppBrand.indigo,
  AppBrand.purple,
];

/// Premium job card.
class JobCard extends StatelessWidget {
  final Job job;
  final bool saved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const JobCard({
    super.key,
    required this.job,
    required this.saved,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                // Company logo (image ya initial)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: job.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (job.logo != null && job.logo!.isNotEmpty)
                      ? Image.network(
                          job.logo!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _initial(),
                        )
                      : _initial(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(job.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.2)),
                      const SizedBox(height: 2),
                      Text(job.company,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onSave,
                  child: Icon(
                    saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? AppBrand.violet : const Color(0xFFCBD5E1),
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(Icons.location_on_outlined, job.location),
                _chip(Icons.work_outline, job.type),
                if (job.remote) _chip(Icons.wifi, 'Remote'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _initial() => Center(
        child: Text(
          job.company.isNotEmpty ? job.company[0].toUpperCase() : '?',
          style: TextStyle(
              color: job.color, fontSize: 22, fontWeight: FontWeight.w800),
        ),
      );

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}