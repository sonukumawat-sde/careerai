import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';
import 'interview_data.dart';
import 'interview_service.dart';
import 'interview_result_screen.dart';

/// Interview Session — ek-ek question, answer input, progress, phir feedback.
class InterviewSessionScreen extends StatefulWidget {
  final InterviewSession session;
  const InterviewSessionScreen({super.key, required this.session});

  @override
  State<InterviewSessionScreen> createState() =>
      _InterviewSessionScreenState();
}

class _InterviewSessionScreenState extends State<InterviewSessionScreen> {
  final _answerController = TextEditingController();
  int _current = 0;
  bool _evaluating = false;

  InterviewSession get _s => widget.session;
  InterviewQA get _q => _s.questions[_current];
  bool get _isLast => _current == _s.questions.length - 1;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _next() {
    // Current answer save
    _q.userAnswer = _answerController.text.trim();

    if (_isLast) {
      _finish();
      return;
    }
    setState(() {
      _current++;
      _answerController.text = _q.userAnswer; // agar pehle bhara ho
    });
  }

  void _prev() {
    _q.userAnswer = _answerController.text.trim();
    setState(() {
      _current--;
      _answerController.text = _q.userAnswer;
    });
  }

  Future<void> _finish() async {
    setState(() => _evaluating = true);

    // AI se feedback lao
    final result = await InterviewService.getFeedback(_s);
    if (!mounted) return;

    await result.match(
      (failure) async {
        setState(() => _evaluating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      (scored) async {
        // History save
        await InterviewService.saveSession(scored);
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => InterviewResultScreen(session: scored),
          ),
        );
      },
    );
  }

  Future<bool> _confirmExit() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quit Interview?'),
        content: const Text(
            'Your progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quit',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_evaluating) return _evaluatingView();

    final progress = (_current + 1) / _s.questions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmExit() && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAFC),
          title: Text('Question ${_current + 1} of ${_s.questions.length}'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor:
                      const AlwaysStoppedAnimation(AppBrand.violet),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                children: [
                  // Question card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppBrand.purple,
                          AppBrand.violet,
                          AppBrand.indigo
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
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
                        Row(
                          children: [
                            const Icon(Icons.help_outline,
                                color: Colors.white70, size: 18),
                            const SizedBox(width: 6),
                            Text('QUESTION ${_current + 1}',
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(_q.question,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                height: 1.4)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Answer input
                  const Text('Your Answer',
                      style: TextStyle(
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
                      controller: _answerController,
                      minLines: 5,
                      maxLines: 10,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Type your answer here...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text('Tip: Answer as you would in a real interview.',
                      style: TextStyle(
                          color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ),

            // Bottom nav
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF64748B).withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    if (_current > 0) ...[
                      Expanded(
                        child: GestureDetector(
                          onTap: _prev,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Center(
                              child: Text('Previous',
                                  style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: _next,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: AppGradients.buttonGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppBrand.violet.withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                                _isLast ? 'Finish & Get Feedback' : 'Next',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _evaluatingView() {
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
              child: const Icon(Icons.assignment_turned_in,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 28),
            const Text('Evaluating your answers...',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('AI is scoring your interview.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 28),
            const CircularProgressIndicator(color: AppBrand.violet),
          ],
        ),
      ),
    );
  }
}