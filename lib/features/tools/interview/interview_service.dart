import 'dart:convert';
import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../core/errors/failure.dart';
import '../../../services/ai_service.dart';
import '../../../services/supabase_service.dart';
import 'interview_data.dart';

/// Interview module ka poora logic — AI questions, feedback, history.
class InterviewService {
  InterviewService._();

  // -------------------- PROFILE (personalization) --------------------

  static Future<Map<String, String>> _profileContext() async {
    final empty = {
      'user_name': '',
      'user_role': '',
      'target_role': '',
      'experience': '',
      'industry': '',
    };
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return empty;
      final data = await SupabaseService.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return empty;

      String pick(List<String> keys) {
        for (final k in keys) {
          final v = data[k];
          if (v != null && v.toString().trim().isNotEmpty) {
            return v.toString().trim();
          }
        }
        return '';
      }

      return {
        'user_name': pick(['full_name', 'name']),
        'user_role': pick(['role', 'current_status', 'status']),
        'target_role': pick(['target_role', 'desired_role', 'goal']),
        'experience': pick(['experience', 'experience_level']),
        'industry': pick(['industry', 'field', 'domain']),
      };
    } catch (_) {
      return empty;
    }
  }

  // -------------------- RESUME TEXT (resume-based) --------------------

  /// PDF se text nikaalo (Resume-Based interview ke liye).
  static Future<Either<Failure, String>> extractResumeText(File pdf) async {
    try {
      final bytes = await pdf.readAsBytes();
      final doc = PdfDocument(inputBytes: bytes);
      final text = PdfTextExtractor(doc).extractText();
      doc.dispose();
      if (text.trim().isEmpty) {
        return left(const Failure(
            'Is PDF me text nahi mila. Text-based resume upload karo.'));
      }
      return right(text.trim());
    } catch (e) {
      return left(Failure('PDF padhne me problem: $e'));
    }
  }

  // -------------------- QUESTIONS --------------------

  /// AI se interview questions lao.
  static Future<Either<Failure, List<InterviewQA>>> generateQuestions({
    required String role,
    required InterviewType type,
    required InterviewDifficulty difficulty,
    required int count,
    String resumeText = '',
  }) async {
    final profile = await _profileContext();

    final result = await AiService.run(
      task: 'interview_questions',
      payload: {
        'role': role,
        'type': interviewTypeToString(type),
        'difficulty': difficultyToString(difficulty),
        'count': count,
        'resume_text': resumeText,
        ...profile,
      },
    );

    return result.match(
      (failure) => left(failure),
      (data) {
        try {
          final raw = data['result']?.toString() ?? '';
          final map = _parseJson(_extractJson(raw));
          if (map == null) {
            return left(const Failure('Questions nahi bane. Dobara try karo.'));
          }
          final list = map['questions'];
          if (list is! List || list.isEmpty) {
            return left(const Failure('Questions nahi mile. Dobara try karo.'));
          }
          final qas = list
              .map((q) => InterviewQA(question: q.toString().trim()))
              .where((qa) => qa.question.isNotEmpty)
              .toList();
          if (qas.isEmpty) {
            return left(const Failure('Questions khali aaye. Dobara try karo.'));
          }
          return right(qas);
        } catch (e) {
          return left(Failure('Questions parse nahi hue: $e'));
        }
      },
    );
  }

  // -------------------- FEEDBACK --------------------

  /// User ke answers pe AI feedback lao. session ko update karke return karta hai.
  static Future<Either<Failure, InterviewSession>> getFeedback(
      InterviewSession session) async {
    final qa = session.questions
        .map((q) => {'question': q.question, 'userAnswer': q.userAnswer})
        .toList();

    final result = await AiService.run(
      task: 'interview_feedback',
      payload: {
        'role': session.role,
        'type': interviewTypeToString(session.type),
        'difficulty': difficultyToString(session.difficulty),
        'qa': qa,
      },
    );

    return result.match(
      (failure) => left(failure),
      (data) {
        try {
          final raw = data['result']?.toString() ?? '';
          final map = _parseJson(_extractJson(raw));
          if (map == null) {
            return left(const Failure('Feedback nahi aaya. Dobara try karo.'));
          }

          session.overallScore = _toInt(map['overall_score']);
          session.strengths = (map['strengths'] ?? '').toString();
          session.weaknesses = (map['weaknesses'] ?? '').toString();
          session.tips = (map['tips'] ?? '').toString();

          // Per-question feedback map karo (same order)
          final per = map['per_question'];
          if (per is List) {
            for (var i = 0; i < session.questions.length && i < per.length; i++) {
              final p = per[i];
              if (p is Map) {
                session.questions[i].score = _toInt(p['score']);
                session.questions[i].feedback =
                    (p['feedback'] ?? '').toString();
                session.questions[i].idealAnswer =
                    (p['ideal_answer'] ?? '').toString();
              }
            }
          }
          return right(session);
        } catch (e) {
          return left(Failure('Feedback parse nahi hua: $e'));
        }
      },
    );
  }

  // -------------------- HISTORY (Supabase) --------------------

  /// Interview save karo → id return.
  static Future<String?> saveSession(InterviewSession s) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return null;

      final data = await SupabaseService.client
          .from('interviews')
          .insert({
            'user_id': userId,
            'role': s.role,
            'type': interviewTypeToString(s.type),
            'difficulty': difficultyToString(s.difficulty),
            'overall_score': s.overallScore,
            'strengths': s.strengths,
            'weaknesses': s.weaknesses,
            'tips': s.tips,
            'questions': s.questions.map((q) => q.toJson()).toList(),
          })
          .select('id')
          .single();

      final id = data['id']?.toString();
      if (id != null) s.id = id;
      return id;
    } catch (_) {
      return null;
    }
  }

  /// User ke saare interviews lao (recent pehle).
  static Future<List<InterviewSession>> getSessions() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return [];
      final data = await SupabaseService.client
          .from('interviews')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) =>
              InterviewSession.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Interview delete karo.
  static Future<void> deleteSession(String id) async {
    try {
      await SupabaseService.client.from('interviews').delete().eq('id', id);
    } catch (_) {}
  }

  // -------------------- helpers --------------------

  static String _extractJson(String raw) {
    var text = raw.trim();
    text = text.replaceAll('```json', '').replaceAll('```', '').trim();
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return text;
  }

  static Map<String, dynamic>? _parseJson(String s) {
    try {
      final decoded = jsonDecode(s);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) return int.tryParse(v.replaceAll('%', '').trim()) ?? 0;
    return 0;
  }
}