import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_gradients.dart';
import 'job_widgets.dart';
import 'jobs_service.dart';
/// Job Detail — real job info + real Apply link.
class JobDetailScreen extends StatefulWidget {
  final Job job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _saved = false;

  Future<void> _applyNow() async {
    final job = widget.job;

    // 1. Database me application save karo
    await JobsService.applyToJob({
      'id': job.id,
      'title': job.title,
      'company': job.company,
      'location': job.location,
      'applyLink': job.applyLink,
    });

    // 2. Apply link kholo
    final link = job.applyLink;
    if (link.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apply link not available.')),
      );
      return;
    }
    final uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open apply link.')),
      );
    }
    // 3. Success feedback
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Application tracked! Check Application Tracker.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Job Details'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => setState(() => _saved = !_saved),
            icon: Icon(
              _saved ? Icons.bookmark : Icons.bookmark_border,
              color: _saved ? AppBrand.violet : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // ---- Company header ----
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFEEF1F5)),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: job.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (job.logo != null && job.logo!.isNotEmpty)
                      ? Image.network(job.logo!,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => _initial(job))
                      : _initial(job),
                ),
                const SizedBox(height: 14),
                Text(job.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(job.company,
                    style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _infoBox(Icons.location_on_outlined, 'Location', job.location),
                    const SizedBox(width: 10),
                    _infoBox(Icons.work_outline, 'Job Type', job.type),
                  ],
                ),
                if (job.remote) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi, color: Color(0xFF22C55E), size: 18),
                        SizedBox(width: 8),
                        Text('Remote Available',
                            style: TextStyle(
                                color: Color(0xFF22C55E),
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),

          // ---- Job description ----
          const Text('Job Description',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEF1F5)),
            ),
            child: Text(
              _cleanDescription(job.description),
              style: const TextStyle(
                  color: Color(0xFF475569), fontSize: 14, height: 1.7),
            ),
          ),
          const SizedBox(height: 16),
          // Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppBrand.violet.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: AppBrand.violet, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tap "Apply Now" to view full details and apply on the company website.',
                    style: TextStyle(
                        color: Color(0xFF475569), fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ---- Bottom bar: Save + Apply ----
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _saved = !_saved),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _saved ? Icons.bookmark : Icons.bookmark_border,
                    color: _saved ? AppBrand.violet : const Color(0xFF64748B),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _applyNow,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppGradients.buttonGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppBrand.violet.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('Apply Now',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  /// Description ko clean karo — extra spaces, lambा text handle.
  String _cleanDescription(String raw) {
    if (raw.trim().isEmpty) {
      return 'No description provided. Tap Apply to see full details.';
    }
    var text = raw
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .trim();
    if (text.length > 600) {
      text = '${text.substring(0, 600).trim()}...';
    }
    return text;
  }

  Widget _initial(Job job) => Center(
        child: Text(
          job.company.isNotEmpty ? job.company[0].toUpperCase() : '?',
          style: TextStyle(
              color: job.color, fontSize: 30, fontWeight: FontWeight.w800),
        ),
      );

  Widget _infoBox(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppBrand.violet, size: 18),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
            const SizedBox(height: 2),
            Text(value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}