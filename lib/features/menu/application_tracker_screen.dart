import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../jobs/jobs_service.dart';

/// Menu > Application Tracker — user ke applied jobs (real, database se).
class ApplicationTrackerScreen extends StatefulWidget {
  const ApplicationTrackerScreen({super.key});

  @override
  State<ApplicationTrackerScreen> createState() =>
      _ApplicationTrackerScreenState();
}

class _ApplicationTrackerScreenState extends State<ApplicationTrackerScreen> {
  List<Map<String, dynamic>> _apps = [];
  bool _loading = true;

  final _brandColors = const [
    AppBrand.violet,
    AppBrand.blueAccent,
    AppBrand.indigo,
    AppBrand.purple,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await JobsService.getApplications();
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _loading = false),
      (data) => setState(() {
        _loading = false;
        _apps = data;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Application Tracker'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : _apps.isEmpty
              ? _empty()
              : RefreshIndicator(
                  color: AppBrand.violet,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    itemCount: _apps.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) =>
                        _appCard(_apps[i], _brandColors[i % _brandColors.length]),
                  ),
                ),
    );
  }

  Widget _appCard(Map<String, dynamic> app, Color color) {
    final company = (app['company'] ?? '').toString();
    final title = (app['title'] ?? '').toString();
    final location = (app['location'] ?? '').toString();
    final status = (app['status'] ?? 'applied').toString();

    return Container(
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Center(
                  child: Text(
                    company.isNotEmpty ? company[0].toUpperCase() : '?',
                    style: TextStyle(
                        color: color,
                        fontSize: 21,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                        location.isEmpty ? company : '$company · $location',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppBrand.violet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: const TextStyle(
                      color: AppBrand.violet,
                      fontSize: 11,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _timeline(_statusStep(status)),
        ],
      ),
    );
  }

  int _statusStep(String status) {
    switch (status) {
      case 'applied':
        return 0;
      case 'review':
      case 'under_review':
        return 1;
      case 'interview':
        return 2;
      case 'offer':
        return 3;
      default:
        return 0;
    }
  }

  Widget _timeline(int currentStep) {
    const labels = ['Applied', 'Review', 'Interview', 'Offer'];
    return Row(
      children: List.generate(4, (i) {
        final done = i <= currentStep;
        final isLast = i == 3;
        return Expanded(
          child: Row(
            children: [
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
                        ? const Icon(Icons.check, color: Colors.white, size: 11)
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
            child: const Icon(Icons.assignment_outlined,
                color: AppBrand.violet, size: 44),
          ),
          const SizedBox(height: 18),
          const Text('No applications yet',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text('Apply to jobs and track their status here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ),
        ],
      ),
    );
  }
}