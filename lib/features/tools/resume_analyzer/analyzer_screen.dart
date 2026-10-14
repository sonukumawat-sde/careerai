import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_gradients.dart';
import 'analyzer_service.dart';
import 'result_screen.dart';
import 'resume_service.dart';
import '../../../core/premium/premium_service.dart';
import '../../../core/premium/premium_widgets.dart';
import '../../premium/premium_screen.dart';

/// Resume Analyzer — upload screen. Resume choose karo → analyze.
class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  File? _selectedFile;
  String? _fileName;
  bool _analyzing = false;
  int _remaining = 3; // free left

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    final left = await PremiumService.remaining(
        'resume_analyzer', FeatureLimits.resumeAnalyzer);
    if (!mounted) return;
    setState(() => _remaining = left);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.single.path != null) {
      setState(() {
        _selectedFile = File(result.single.path!);
        _fileName = result.single.name;
      });
    }
  }

 Future<void> _analyze() async {
    if (_selectedFile == null) return;

    // Premium gating — free limit check
    final canUse = await PremiumService.canUse(
        'resume_analyzer', FeatureLimits.resumeAnalyzer);
    if (!canUse) {
      if (!mounted) return;
      showPremiumLock(
  context,
  feature: 'Resume Analyzer',
  benefits: const [
    'Unlimited resume analysis',
    'Detailed ATS score & keyword match',
    'Section-by-section breakdown',
    'AI-powered improvement suggestions',
  ],
);
      return;
    }

    setState(() => _analyzing = true);

    // 1. PDF se text nikaalo
    final textResult = await AnalyzerService.extractText(_selectedFile!);
    if (!mounted) return;

    await textResult.match(
      (failure) async {
        setState(() => _analyzing = false);
        _showError(failure.message);
      },
      (resumeText) async {
        // 2. AI se analyze karo
        final analysisResult = await AnalyzerService.analyze(resumeText);
        if (!mounted) return;
        setState(() => _analyzing = false);

       analysisResult.match(
          (failure) => _showError(failure.message),
         (result) async {
            // Usage record karo (free count +1)
            await PremiumService.recordUsage('resume_analyzer');
            // Resume database me save karo
            await ResumeService.saveResume(
              fileName: _fileName ?? 'Resume.pdf',
              score: result.score,
              atsScore: result.atsScore,
            );
            if (!mounted) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ResultScreen(result: result),
              ),
            );
          },
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Resume Analyzer'),
        centerTitle: true,
      ),
      body: _analyzing ? _loadingView() : _uploadView(),
    );
  }

  Widget _uploadView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        // Hero card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppBrand.purple, AppBrand.violet, AppBrand.indigo],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppBrand.violet.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('AI Resume Analysis',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text(
                  'Upload your resume and get an instant score, ATS check, and personalized suggestions.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ---- Smart Usage Card (subscription psychology) ----
        SmartUsageCard(
          remaining: _remaining,
          total: FeatureLimits.resumeAnalyzer,
          price: '₹149',
          onUpgrade: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PremiumScreen()),
          ),
        ),
        const SizedBox(height: 20),

        // Upload box
        GestureDetector(
          onTap: _pickFile,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _selectedFile != null
                    ? AppBrand.violet
                    : const Color(0xFFCBD5E1),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppBrand.violet.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _selectedFile != null
                        ? Icons.check_circle
                        : Icons.upload_file,
                    color: AppBrand.violet,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _fileName ?? 'Tap to upload your resume',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text('PDF format only',
                    style:
                        TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Analyze button
        GestureDetector(
          onTap: _selectedFile != null ? _analyze : null,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: _selectedFile != null
                  ? AppGradients.buttonGradient
                  : null,
              color: _selectedFile != null ? null : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _selectedFile != null
                  ? [
                      BoxShadow(
                        color: AppBrand.violet.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text('Analyze Resume',
                  style: TextStyle(
                      color: _selectedFile != null
                          ? Colors.white
                          : const Color(0xFF94A3B8),
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingView() {
    return Center(
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
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 44),
          ),
          const SizedBox(height: 28),
          const Text('Analyzing your resume...',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text('Our AI is reviewing every detail.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
          const SizedBox(height: 28),
          const CircularProgressIndicator(color: AppBrand.violet),
        ],
      ),
    );
  }
}