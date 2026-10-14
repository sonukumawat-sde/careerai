import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../tools/resume_analyzer/resume_service.dart';

/// Menu > My Resumes — user ke analyze kiye resumes (real, database se).
class MyResumesScreen extends StatefulWidget {
  const MyResumesScreen({super.key});

  @override
  State<MyResumesScreen> createState() => _MyResumesScreenState();
}

class _MyResumesScreenState extends State<MyResumesScreen> {
  List<Map<String, dynamic>> _resumes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ResumeService.getResumes();
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _loading = false),
      (data) => setState(() {
        _loading = false;
        _resumes = data;
      }),
    );
  }

  Future<void> _delete(String id) async {
    await ResumeService.deleteResume(id);
    _load();
  }

  Color _scoreColor(int s) {
    if (s >= 75) return const Color(0xFF22C55E);
    if (s >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('My Resumes'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : _resumes.isEmpty
              ? _empty()
              : RefreshIndicator(
                  color: AppBrand.violet,
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    itemCount: _resumes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) => _resumeCard(_resumes[i]),
                  ),
                ),
    );
  }

  Widget _resumeCard(Map<String, dynamic> resume) {
    final fileName = (resume['file_name'] ?? 'Resume.pdf').toString();
    final score = (resume['score'] ?? 0) as int;
    final atsScore = (resume['ats_score'] ?? 0) as int;
    final id = resume['id'].toString();

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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppGradients.buttonGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.description,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(fileName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ),
              GestureDetector(
                onTap: () => _confirmDelete(id),
                child: const Icon(Icons.delete_outline,
                    color: Color(0xFFEF4444), size: 22),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _scoreBox('Resume Score', score, _scoreColor(score)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _scoreBox('ATS Score', atsScore, _scoreColor(atsScore)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scoreBox(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Resume?'),
        content: const Text('Ye resume record delete ho jayega.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _delete(id);
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Delete'),
          ),
        ],
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
            child: const Icon(Icons.description_outlined,
                color: AppBrand.violet, size: 44),
          ),
          const SizedBox(height: 18),
          const Text('No resumes yet',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 17,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text('Analyze a resume from Tools to see it here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          ),
        ],
      ),
    );
  }
}