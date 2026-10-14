import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';
import 'interview_data.dart';

/// Interview Result — overall score, strengths/weaknesses/tips, per-question feedback.
class InterviewResultScreen extends StatelessWidget {
  final InterviewSession session;
  const InterviewResultScreen({super.key, required this.session});

  Color _scoreColor(int s) {
    if (s >= 75) return const Color(0xFF22C55E);
    if (s >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _qScoreColor(int s) {
    // per-question 0-10
    if (s >= 7) return const Color(0xFF22C55E);
    if (s >= 4) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Interview Result'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF0F172A)),
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _heroScore(),
          const SizedBox(height: 16),
          _metaRow(),
          const SizedBox(height: 24),

          if (session.strengths.trim().isNotEmpty)
            _feedbackCard('Strengths', Icons.check_circle,
                const Color(0xFF22C55E), session.strengths),
          if (session.weaknesses.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _feedbackCard('Areas to Improve', Icons.warning_amber_rounded,
                const Color(0xFFF59E0B), session.weaknesses),
          ],
          if (session.tips.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _feedbackCard('Tips for Next Time', Icons.auto_awesome,
                AppBrand.violet, session.tips),
          ],
          const SizedBox(height: 26),

          const Text('Question Breakdown',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ...session.questions.asMap().entries.map(
                (e) => _questionCard(e.key + 1, e.value),
              ),
        ],
      ),
    );
  }

  Widget _heroScore() {
    final c = _scoreColor(session.overallScore);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppBrand.purple, AppBrand.violet, AppBrand.indigo],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppBrand.violet.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('YOUR SCORE',
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1)),
          const SizedBox(height: 16),
          SizedBox(
            width: 150,
            height: 150,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: session.overallScore / 100,
                    strokeWidth: 13,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${session.overallScore}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                            height: 1)),
                    const Text('out of 100',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(session.scoreLabel,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _metaRow() {
    Widget chip(IconData icon, String text) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEEF1F5)),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppBrand.violet, size: 20),
                const SizedBox(height: 6),
                Text(text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF475569),
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        );

    return Row(
      children: [
        chip(Icons.category_outlined, session.typeLabel),
        const SizedBox(width: 10),
        chip(Icons.bar_chart, session.difficultyLabel),
        const SizedBox(width: 10),
        chip(Icons.quiz_outlined, '${session.questions.length} Qs'),
      ],
    );
  }

  Widget _feedbackCard(
      String title, IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 12),
          Text(text,
              style: const TextStyle(
                  color: Color(0xFF475569), fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _questionCard(int number, InterviewQA qa) {
    final c = _qScoreColor(qa.score);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF1F5)),
        ),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              alignment: Alignment.center,
              child: Text('${qa.score}/10',
                  style: TextStyle(
                      color: c, fontSize: 12, fontWeight: FontWeight.w900)),
            ),
            title: Text('Q$number. ${qa.question}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            children: [
              // Your answer
              _block('Your Answer',
                  qa.userAnswer.isEmpty ? '(No answer given)' : qa.userAnswer,
                  const Color(0xFF64748B)),
              const SizedBox(height: 12),
              // Feedback
              if (qa.feedback.trim().isNotEmpty)
                _block('Feedback', qa.feedback, AppBrand.violet),
              if (qa.idealAnswer.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _block('Ideal Answer', qa.idealAnswer,
                    const Color(0xFF22C55E)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _block(String label, String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(text,
              style: const TextStyle(
                  color: Color(0xFF334155), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}