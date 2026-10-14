import 'package:flutter/material.dart';
import '../../../core/theme/app_gradients.dart';
import 'analyzer_service.dart';

/// Resume Analysis Result — JobScan/Enhancv level premium UI.
/// Score gauges, match meter, section bars, keyword chips, ATS issues.
class ResultScreen extends StatelessWidget {
  final AnalysisResult result;
  final bool hasJobDescription;
  const ResultScreen({
    super.key,
    required this.result,
    this.hasJobDescription = false,
  });

  Color _scoreColor(int s) {
    if (s >= 75) return const Color(0xFF22C55E);
    if (s >= 50) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  String _scoreLabel(int s) {
    if (s >= 85) return 'Excellent';
    if (s >= 70) return 'Good';
    if (s >= 50) return 'Average';
    return 'Needs Work';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Analysis Result'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          _heroScoreCard(),
          const SizedBox(height: 14),
          _metricsRow(),
          const SizedBox(height: 14),
          if (result.summary.trim().isNotEmpty) ...[
            _summaryCard(),
            const SizedBox(height: 20),
          ],
          if (result.sections.isNotEmpty) ...[
            _sectionScoresCard(),
            const SizedBox(height: 20),
          ],
          if (result.keywordsFound.isNotEmpty ||
              result.keywordsMissing.isNotEmpty) ...[
            _keywordsCard(),
            const SizedBox(height: 20),
          ],
          if (result.atsIssues.isNotEmpty) ...[
            _listSection('ATS & Formatting Issues', Icons.report_gmailerrorred,
                const Color(0xFFEF4444), result.atsIssues),
            const SizedBox(height: 20),
          ],
          _listSection('Strengths', Icons.check_circle,
              const Color(0xFF22C55E), result.strengths),
          const SizedBox(height: 20),
          _listSection('Areas to Improve', Icons.warning_amber_rounded,
              const Color(0xFFF59E0B), result.weaknesses),
          const SizedBox(height: 20),
          _listSection('AI Suggestions', Icons.auto_awesome, AppBrand.violet,
              result.suggestions),
        ],
      ),
    );
  }

  // ---------- HERO SCORE (big ring) ----------
  Widget _heroScoreCard() {
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
          const Text('RESUME SCORE',
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
                    value: result.score / 100,
                    strokeWidth: 13,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${result.score}',
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
            child: Text(_scoreLabel(result.score),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  // ---------- METRICS ROW (ATS + Match) ----------
  Widget _metricsRow() {
    return Row(
      children: [
        Expanded(
          child: _metricTile(
            'ATS Score',
            result.atsScore,
            Icons.verified_outlined,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _metricTile(
            hasJobDescription ? 'Job Match' : 'Quality',
            hasJobDescription ? result.matchScore : result.score,
            hasJobDescription ? Icons.work_outline : Icons.star_outline,
          ),
        ),
      ],
    );
  }

  Widget _metricTile(String label, int value, IconData icon) {
    final c = _scoreColor(value);
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: c, size: 20),
              ),
              const Spacer(),
              Text('$value%',
                  style: TextStyle(
                      color: c, fontSize: 26, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(c),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- SUMMARY ----------
  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppBrand.violet.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppBrand.violet.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology_alt, color: AppBrand.violet, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(result.summary,
                style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  // ---------- SECTION SCORES (bars) ----------
  Widget _sectionScoresCard() {
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
                  color: AppBrand.indigo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    color: AppBrand.indigo, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Section Breakdown',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          ...result.sections.map(_sectionBar),
        ],
      ),
    );
  }

  Widget _sectionBar(SectionScore s) {
    final c = _scoreColor(s.score);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(s.name,
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
              Text('${s.score}',
                  style: TextStyle(
                      color: c, fontSize: 15, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: s.score / 100,
              minHeight: 7,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation(c),
            ),
          ),
          if (s.note.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(s.note,
                style: const TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 12, height: 1.4)),
          ],
        ],
      ),
    );
  }

  // ---------- KEYWORDS (found + missing chips) ----------
  Widget _keywordsCard() {
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
                  color: AppBrand.violet.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.key_rounded,
                    color: AppBrand.violet, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Keyword Analysis',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          if (result.keywordsFound.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Found in your resume',
                style: TextStyle(
                    color: Color(0xFF22C55E),
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _chips(result.keywordsFound, const Color(0xFF22C55E), true),
          ],
          if (result.keywordsMissing.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('Missing / recommended',
                style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _chips(result.keywordsMissing, const Color(0xFFEF4444), false),
          ],
        ],
      ),
    );
  }

  Widget _chips(List<String> items, Color color, bool found) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((k) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(found ? Icons.check : Icons.add, color: color, size: 14),
              const SizedBox(width: 5),
              Text(k,
                  style: TextStyle(
                      color: color,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------- GENERIC LIST SECTION ----------
  Widget _listSection(
      String title, IconData icon, Color color, List<String> items) {
    if (items.isEmpty) return const SizedBox.shrink();
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
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${items.length}',
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(item,
                          style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 14,
                              height: 1.5)),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}