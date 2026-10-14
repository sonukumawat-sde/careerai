import 'package:fpdart/fpdart.dart';
import '../../../core/errors/failure.dart';
import '../../../services/supabase_service.dart';
import 'resume_service.dart';

/// Resume database ka logic — analyze kiye resumes save + laao.
class ResumeService {
  ResumeService._();

  /// Analyze kiya resume database me save karo.
  static Future<Either<Failure, Unit>> saveResume({
    required String fileName,
    required int score,
    required int atsScore,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

      await SupabaseService.client.from('resumes').insert({
        'user_id': userId,
        'file_name': fileName,
        'score': score,
        'ats_score': atsScore,
      });
      return right(unit);
    } catch (e) {
      return left(Failure('Resume save nahi hua: $e'));
    }
  }

  /// User ke saare resumes laao.
  static Future<Either<Failure, List<Map<String, dynamic>>>>
      getResumes() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

      final data = await SupabaseService.client
          .from('resumes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final resumes = (data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return right(resumes);
    } catch (e) {
      return left(Failure('Resumes nahi mile: $e'));
    }
  }

  /// Resume delete karo.
  static Future<Either<Failure, Unit>> deleteResume(String id) async {
    try {
      await SupabaseService.client.from('resumes').delete().eq('id', id);
      return right(unit);
    } catch (e) {
      return left(Failure('Delete nahi hua: $e'));
    }
  }
}