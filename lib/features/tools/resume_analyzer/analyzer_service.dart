import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../core/errors/failure.dart';
import '../../../services/ai_service.dart';
import 'dart:convert';

/// Ek resume section ka score (Contact, Experience, Skills, etc.)
class SectionScore {
  final String name;
  final int score;
  final String note;

  const SectionScore({
    required this.name,
    required this.score,
    required this.note,
  });

  factory SectionScore.fromMap(Map<String, dynamic> map) {
    return SectionScore(
      name: (map['name'] ?? '').toString(),
      score: AnalysisResult._toInt(map['score']),
      note: (map['note'] ?? '').toString(),
    );
  }
}

/// Resume analysis ka result (AI se aaya) — JobScan/Enhancv level detail.
class AnalysisResult {
  final int score;          // overall quality
  final int atsScore;       // ATS friendliness
  final int matchScore;     // job match (JD diya toh)
  final String summary;     // 2-3 line overview
  final List<SectionScore> sections;   // section-wise scores
  final List<String> keywordsFound;    // resume me mile keywords
  final List<String> keywordsMissing;  // missing important keywords
  final List<String> atsIssues;        // ATS/formatting problems
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> suggestions;

  const AnalysisResult({
    required this.score,
    required this.atsScore,
    required this.matchScore,
    required this.summary,
    required this.sections,
    required this.keywordsFound,
    required this.keywordsMissing,
    required this.atsIssues,
    required this.strengths,
    required this.weaknesses,
    required this.suggestions,
  });

  factory AnalysisResult.fromMap(Map<String, dynamic> map) {
    return AnalysisResult(
      score: _toInt(map['score']),
      atsScore: _toInt(map['ats_score']),
      matchScore: _toInt(map['match_score'] ?? map['score']),
      summary: (map['summary'] ?? '').toString(),
      sections: _toSections(map['sections']),
      keywordsFound: _toList(map['keywords_found']),
      keywordsMissing: _toList(map['keywords_missing']),
      atsIssues: _toList(map['ats_issues']),
      strengths: _toList(map['strengths']),
      weaknesses: _toList(map['weaknesses']),
      suggestions: _toList(map['suggestions']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v.replaceAll('%', '').trim()) ?? 0;
    return 0;
  }

  static List<String> _toList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    return [];
  }

  static List<SectionScore> _toSections(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => SectionScore.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }
}

/// Resume Analyzer ka logic — PDF text nikaalo + AI se analyze karo.
class AnalyzerService {
  AnalyzerService._();

  /// PDF file se text nikaalo.
  static Future<Either<Failure, String>> extractText(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(document).extractText();
      document.dispose();

      if (text.trim().isEmpty) {
        return left(const Failure(
            'Is PDF me text nahi mila. Text-based resume PDF upload karo (image nahi).'));
      }
      return right(text.trim());
    } catch (e) {
      return left(Failure('PDF padhne me problem: $e'));
    }
  }

  /// Resume text ko AI se analyze karo.
  /// [jobDescription] optional — diya toh JD ke against match karega.
  static Future<Either<Failure, AnalysisResult>> analyze(
    String resumeText, {
    String jobDescription = '',
  }) async {
    final result = await AiService.run(
      task: 'analyze_resume',
      payload: {
        'resume_text': resumeText,
        'job_description': jobDescription,
      },
    );

    return result.match(
      (failure) => left(failure),
      (data) {
        try {
          // AI 'result' me JSON string bhejta hai — use parse karo
          final raw = data['result']?.toString() ?? '';
          final cleaned = _extractJson(raw);
          final map = _parseJson(cleaned);
          if (map == null) {
            return left(const Failure(
                'AI ka jawab samajh nahi aaya. Dobara try karo.'));
          }
          return right(AnalysisResult.fromMap(map));
        } catch (e) {
          return left(Failure('Result parse nahi hua: $e'));
        }
      },
    );
  }

  /// AI kabhi kabhi ```json ... ``` me wrap karta hai — clean karo.
  static String _extractJson(String raw) {
    var text = raw.trim();
    text = text.replaceAll('```json', '').replaceAll('```', '').trim();
    // Pehla { se aakhri } tak lo
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return text;
  }

  static Map<String, dynamic>? _parseJson(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }
}