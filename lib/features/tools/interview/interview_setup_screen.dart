import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/premium/premium_service.dart';
import 'interview_data.dart';
import 'interview_service.dart';
import 'interview_session_screen.dart';

/// Interview Setup — role/topic + difficulty + count choose, phir start.
class InterviewSetupScreen extends StatefulWidget {
  final InterviewType type;
  const InterviewSetupScreen({super.key, required this.type});

  @override
  State<InterviewSetupScreen> createState() => _InterviewSetupScreenState();
}

class _InterviewSetupScreenState extends State<InterviewSetupScreen> {
  final _roleController = TextEditingController();
  InterviewDifficulty _difficulty = InterviewDifficulty.medium;
  int _count = 5;
  bool _loading = false;

  // Resume-based ke liye
  File? _resumeFile;
  String? _resumeName;

  String get _inputLabel {
    switch (widget.type) {
      case InterviewType.roleBased:
        return 'Job Role';
      case InterviewType.topicBased:
        return 'Topic';
      case InterviewType.resumeBased:
        return 'Target Role (optional)';
    }
  }

  String get _inputHint {
    switch (widget.type) {
      case InterviewType.roleBased:
        return 'e.g. Flutter Developer, Data Analyst';
      case InterviewType.topicBased:
        return 'e.g. DSA, System Design, SQL, HR';
      case InterviewType.resumeBased:
        return 'e.g. Software Engineer';
    }
  }

  @override
  void dispose() {
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.single.path != null) {
      setState(() {
        _resumeFile = File(result.single.path!);
        _resumeName = result.single.name;
      });
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _start() async {
    final role = _roleController.text.trim();

    // Role-based aur topic-based me input zaroori
    if (widget.type != InterviewType.resumeBased && role.isEmpty) {
      _showError('Please enter a ${_inputLabel.toLowerCase()}.');
      return;
    }
    // Resume-based me PDF zaroori
    if (widget.type == InterviewType.resumeBased && _resumeFile == null) {
      _showError('Please upload your resume PDF.');
      return;
    }

    setState(() => _loading = true);

    // Resume-based → text nikaalo
    String resumeText = '';
    if (widget.type == InterviewType.resumeBased) {
      final res = await InterviewService.extractResumeText(_resumeFile!);
      final failed = res.match((f) {
        _showError(f.message);
        return true;
      }, (text) {
        resumeText = text;
        return false;
      });
      if (failed) {
        if (mounted) setState(() => _loading = false);
        return;
      }
    }

    // AI se questions lao
    final result = await InterviewService.generateQuestions(
      role: role,
      type: widget.type,
      difficulty: _difficulty,
      count: _count,
      resumeText: resumeText,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    result.match(
      (failure) => _showError(failure.message),
      (questions) {
        // Usage record (free count +1) — interview shuru hone pe
        PremiumService.recordUsage('interview_practice');

        final session = InterviewSession(
          role: role.isEmpty ? 'Resume-Based' : role,
          type: widget.type,
          difficulty: _difficulty,
          questions: questions,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => InterviewSessionScreen(session: session),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final typeInfo =
        kInterviewTypes.firstWhere((t) => t.type == widget.type);

    if (_loading) return _loadingView();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Setup Interview'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          // Type banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppBrand.purple, AppBrand.violet, AppBrand.indigo],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(typeInfo.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(typeInfo.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(typeInfo.description,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Resume upload (only resume-based)
          if (widget.type == InterviewType.resumeBased) ...[
            const Text('Upload Resume',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickResume,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _resumeFile != null
                        ? AppBrand.violet
                        : const Color(0xFFCBD5E1),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                        _resumeFile != null
                            ? Icons.check_circle
                            : Icons.upload_file,
                        color: AppBrand.violet,
                        size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(_resumeName ?? 'Tap to upload PDF',
                          style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Role / Topic input
          Text(_inputLabel,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _roleController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: _inputHint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Difficulty
          const Text('Difficulty',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Row(
            children: InterviewDifficulty.values.map((d) {
              final selected = _difficulty == d;
              final label = d == InterviewDifficulty.easy
                  ? 'Easy'
                  : d == InterviewDifficulty.medium
                      ? 'Medium'
                      : 'Hard';
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = d),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient:
                          selected ? AppGradients.buttonGradient : null,
                      color: selected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: selected
                              ? Colors.transparent
                              : const Color(0xFFE2E8F0)),
                    ),
                    child: Center(
                      child: Text(label,
                          style: TextStyle(
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Question count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Number of Questions',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w800)),
              Text('$_count',
                  style: const TextStyle(
                      color: AppBrand.violet,
                      fontSize: 18,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          Slider(
            value: _count.toDouble(),
            min: 3,
            max: 10,
            divisions: 7,
            activeColor: AppBrand.violet,
            label: '$_count',
            onChanged: (v) => setState(() => _count = v.round()),
          ),
          const SizedBox(height: 20),

          // Start button
          GestureDetector(
            onTap: _start,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppGradients.buttonGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppBrand.violet.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('Start Interview',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loadingView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppGradients.buttonGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppBrand.violet.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.psychology,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 28),
            const Text('Preparing your interview...',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('AI is crafting your questions.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 28),
            const CircularProgressIndicator(color: AppBrand.violet),
          ],
        ),
      ),
    );
  }
}