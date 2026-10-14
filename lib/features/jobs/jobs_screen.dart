import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'job_widgets.dart';
import 'job_detail_screen.dart';
import 'jobs_service.dart';
import 'applied_data.dart';
import 'applied_widgets.dart';
import 'filter_sheet.dart';

/// Jobs tab — REAL jobs (JSearch API). Search + tabs + cards.
class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  int _tab = 0; // 0=Recommended, 1=Saved, 2=Applied
  final _tabs = const ['Recommended', 'Saved', 'Applied'];
  final _searchController = TextEditingController();

  List<Job> _jobs = [];
  final Set<String> _savedIds = {};
  bool _loading = true;
  String? _error;

  // Applied (real)
  List<AppliedJob> _applied = [];
  bool _appliedLoading = false;
  bool _appliedLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadJobs('developer');
    _loadSavedIds();
  }

  Future<void> _loadSavedIds() async {
    final ids = await JobsService.getSavedJobIds();
    if (!mounted) return;
    setState(() {
      _savedIds.clear();
      _savedIds.addAll(ids);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs(String query) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await JobsService.searchJobs(query: query);
    if (!mounted) return;

    result.match(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (jobsData) => setState(() {
        _loading = false;
        _jobs = [
          for (int i = 0; i < jobsData.length; i++)
            Job.fromMap(jobsData[i], jobColors[i % jobColors.length])
        ];
      }),
    );
  }

  Future<void> _loadApplied() async {
    setState(() => _appliedLoading = true);
    final result = await JobsService.getApplications();
    if (!mounted) return;
    result.match(
      (failure) => setState(() {
        _appliedLoading = false;
        _appliedLoaded = true;
        _applied = [];
      }),
      (rows) => setState(() {
        _appliedLoading = false;
        _appliedLoaded = true;
        _applied = [
          for (int i = 0; i < rows.length; i++)
            AppliedJob.fromMap(rows[i], jobColors[i % jobColors.length])
        ];
      }),
    );
  }

  void _onTabChanged(int i) {
    setState(() => _tab = i);
    // Applied tab pe pehli baar aaye toh load karo
    if (i == 2 && !_appliedLoaded) _loadApplied();
  }

  void _search() {
    final q = _searchController.text.trim();
    _loadJobs(q.isEmpty ? 'developer' : q);
  }

  void _openDetail(Job job) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => JobDetailScreen(job: job)),
    );
  }

  Future<void> _toggleSave(Job job) async {
    final id = job.id;
    final wasSaved = _savedIds.contains(id);

    setState(() {
      if (wasSaved) {
        _savedIds.remove(id);
      } else {
        _savedIds.add(id);
      }
    });

    if (wasSaved) {
      await JobsService.unsaveJob(id);
    } else {
      await JobsService.saveJob({
        'id': job.id,
        'title': job.title,
        'company': job.company,
        'location': job.location,
        'type': job.type,
        'applyLink': job.applyLink,
        'logo': job.logo,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ---- Header + Search ----
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Find Jobs',
                      style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Real tech jobs, updated live.',
                      style:
                          TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: Color(0xFF94A3B8), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (_) => _search(),
                            decoration: const InputDecoration(
                              hintText: 'Search job title, skill...',
                              hintStyle: TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 14),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _search,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: AppGradients.buttonGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.search,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => showFilterSheet(context),
                          child: const Icon(Icons.tune,
                              color: Color(0xFF64748B), size: 22),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ---- Tabs ----
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2F7),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: List.generate(_tabs.length, (i) {
                    final selected = _tab == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _onTabChanged(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient:
                                selected ? AppGradients.buttonGradient : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(_tabs[i],
                                style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : const Color(0xFF64748B),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    // Applied tab (REAL)
    if (_tab == 2) {
      if (_appliedLoading) {
        return const Center(
          child: CircularProgressIndicator(color: AppBrand.violet),
        );
      }
      if (_applied.isEmpty) {
        return _empty(Icons.assignment_outlined, 'No applications yet',
            'Jobs you apply to will appear here.');
      }
      return RefreshIndicator(
        color: AppBrand.violet,
        onRefresh: _loadApplied,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          itemCount: _applied.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) => AppliedJobCard(
            job: _applied[i],
            onTap: () {},
          ),
        ),
      );
    }

    // Saved tab
    if (_tab == 1) {
      final savedJobs = _jobs.where((j) => _savedIds.contains(j.id)).toList();
      if (savedJobs.isEmpty) {
        return _empty(Icons.bookmark_border, 'No saved jobs',
            'Tap the bookmark on any job to save it.');
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        itemCount: savedJobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) => JobCard(
          job: savedJobs[i],
          saved: true,
          onTap: () => _openDetail(savedJobs[i]),
          onSave: () => _toggleSave(savedJobs[i]),
        ),
      );
    }

    // Recommended tab
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppBrand.violet),
      );
    }
    if (_error != null) {
      return _empty(Icons.error_outline, 'Could not load jobs', _error!);
    }
    if (_jobs.isEmpty) {
      return _empty(Icons.search_off, 'No jobs found',
          'Try a different search keyword.');
    }
    return RefreshIndicator(
      color: AppBrand.violet,
      onRefresh: () => _loadJobs(_searchController.text.trim().isEmpty
          ? 'developer'
          : _searchController.text.trim()),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        itemCount: _jobs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) => JobCard(
          job: _jobs[i],
          saved: _savedIds.contains(_jobs[i].id),
          onTap: () => _openDetail(_jobs[i]),
          onSave: () => _toggleSave(_jobs[i]),
        ),
      ),
    );
  }

  Widget _empty(IconData icon, String title, String sub) {
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
            child: Icon(icon, color: AppBrand.violet, size: 44),
          ),
          const SizedBox(height: 18),
          Text(title,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(sub,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ),
        ],
      ),
    );
  }
}