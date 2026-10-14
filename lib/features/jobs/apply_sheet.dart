import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'job_widgets.dart';

/// Apply bottom sheet kholta hai.
void showApplySheet(BuildContext context, Job job) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ApplySheet(job: job),
  );
}

class _ApplySheet extends StatefulWidget {
  final Job job;
  const _ApplySheet({required this.job});

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  int _selectedResume = 0;
  final _noteController = TextEditingController();
  bool _submitting = false;

  final _resumes = const [
    'My Resume 2026.pdf',
    'Flutter Developer CV.pdf',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 1200)); // fake submit
    if (!mounted) return;
    Navigator.pop(context); // close sheet
    _showSuccess();
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Color(0xFF22C55E), size: 48),
              ),
              const SizedBox(height: 18),
              const Text('Application Submitted!',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(
                  'Your application for ${widget.job.title} at ${widget.job.company} has been sent. Track it in the Applied tab.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 14, height: 1.4)),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppGradients.buttonGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Done',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Apply for ${widget.job.title}',
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('at ${widget.job.company}',
                  style: const TextStyle(
                      color: Color(0xFF64748B), fontSize: 14)),
              const SizedBox(height: 24),

              // Select resume
              const Text('Select Resume',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              ...List.generate(_resumes.length, (i) {
                final selected = _selectedResume == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedResume = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppBrand.violet.withValues(alpha: 0.06)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppBrand.violet
                            : const Color(0xFFE2E8F0),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.description,
                            color: selected
                                ? AppBrand.violet
                                : const Color(0xFF94A3B8),
                            size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_resumes[i],
                              style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                        ),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: AppBrand.violet, size: 22),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Cover note
              const Text('Cover Note (optional)',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Add a short note to the recruiter...',
                    hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              GestureDetector(
                onTap: _submitting ? null : _submit,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppGradients.buttonGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Submit Application',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}