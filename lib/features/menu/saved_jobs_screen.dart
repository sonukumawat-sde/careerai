import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../jobs/job_widgets.dart';
import '../jobs/jobs_service.dart';
import '../jobs/job_detail_screen.dart';

/// Menu > Saved Jobs — user ke database se saved jobs (real).
class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({super.key});

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  List<Job> _jobs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await JobsService.getSavedJobs();
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _loading = false),
      (jobsData) => setState(() {
        _loading = false;
        _jobs = [
          for (int i = 0; i < jobsData.length; i++)
            Job.fromMap({
              'id': jobsData[i]['job_id'],
              'title': jobsData[i]['title'],
              'company': jobsData[i]['company'],
              'location': jobsData[i]['location'],
              'type': jobsData[i]['type'],
              'applyLink': jobsData[i]['apply_link'],
              'logo': jobsData[i]['logo'],
              'remote': false,
              'description': '',
            }, jobColors[i % jobColors.length])
        ];
      }),
    );
  }

  Future<void> _unsave(Job job) async {
    await JobsService.unsaveJob(job.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Saved Jobs'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : _jobs.isEmpty
              ? _empty()
              : RefreshIndicator(
                  color: AppBrand.violet,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    itemCount: _jobs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) => JobCard(
                      job: _jobs[i],
                      saved: true,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => JobDetailScreen(job: _jobs[i]),
                        ),
                      ),
                      onSave: () => _unsave(_jobs[i]),
                    ),
                  ),
                ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppBrand.violet.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.bookmark_border,
                color: AppBrand.violet, size: 44),
          ),
          const SizedBox(height: 18),
          const Text('No saved jobs yet',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text('Save jobs from the Jobs tab to see them here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ),
        ],
      ),
    );
  }
}