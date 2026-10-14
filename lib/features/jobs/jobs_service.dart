import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/failure.dart';
import '../../services/supabase_service.dart';

/// Real jobs laata hai — jobs-proxy Edge Function se (JSearch API).
class JobsService {
  JobsService._();

  /// Jobs search karo. [query] = "flutter developer" type.
  static Future<Either<Failure, List<Map<String, dynamic>>>> searchJobs({
    String query = 'developer',
    int page = 1,
  }) async {
    try {
      final res = await SupabaseService.client.functions.invoke(
        'jobs-proxy',
        body: {'query': query, 'page': page},
      );

      final data = res.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['error'] != null) {
          return left(Failure(map['error'].toString()));
        }
        final jobsList = map['jobs'];
        if (jobsList is List) {
          final jobs = jobsList
              .map((j) => Map<String, dynamic>.from(j as Map))
              .toList();
          return right(jobs);
        }
      }
      return left(const Failure('Jobs nahi mile. Dobara try karo.'));
    } on FunctionException catch (e) {
      return left(Failure('Jobs service error: ${e.details ?? "unknown"}'));
    } catch (e) {
      return left(Failure('Kuch galat hua: $e'));
    }
  }
  /// Job ko save karo (database me).
  static Future<Either<Failure, Unit>> saveJob(Map<String, dynamic> job) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

      await SupabaseService.client.from('saved_jobs').insert({
        'user_id': userId,
        'job_id': job['id'] ?? '',
        'title': job['title'] ?? '',
        'company': job['company'] ?? '',
        'location': job['location'] ?? '',
        'type': job['type'] ?? '',
        'apply_link': job['applyLink'] ?? '',
        'logo': job['logo'],
      });
      return right(unit);
    } catch (e) {
      return left(Failure('Save nahi hua: $e'));
    }
  }

  /// Saved job hatao (database se).
  static Future<Either<Failure, Unit>> unsaveJob(String jobId) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

      await SupabaseService.client
          .from('saved_jobs')
          .delete()
          .eq('user_id', userId)
          .eq('job_id', jobId);
      return right(unit);
    } catch (e) {
      return left(Failure('Remove nahi hua: $e'));
    }
  }

  /// Saved jobs laao (database se).
  static Future<Either<Failure, List<Map<String, dynamic>>>>
      getSavedJobs() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

      final data = await SupabaseService.client
          .from('saved_jobs')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final jobs = (data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return right(jobs);
    } catch (e) {
      return left(Failure('Saved jobs nahi mile: $e'));
    }
  }

  /// Kaunse job IDs saved hai (set) — taaki bookmark icon sahi dikhe.
  static Future<Set<String>> getSavedJobIds() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return {};

      final data = await SupabaseService.client
          .from('saved_jobs')
          .select('job_id')
          .eq('user_id', userId);

      return (data as List)
          .map((e) => (e as Map)['job_id'].toString())
          .toSet();
    } catch (_) {
      return {};
    }
  }
  /// Job apply karo — application database me save.
  static Future<Either<Failure, Unit>> applyToJob(
      Map<String, dynamic> job) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

      await SupabaseService.client.from('applications').insert({
        'user_id': userId,
        'job_id': job['id'] ?? '',
        'title': job['title'] ?? '',
        'company': job['company'] ?? '',
        'location': job['location'] ?? '',
        'apply_link': job['applyLink'] ?? '',
        'status': 'applied',
      });
      return right(unit);
    } catch (e) {
      return left(Failure('Apply save nahi hua: $e'));
    }
  }

  /// Applied jobs laao (database se).
  static Future<Either<Failure, List<Map<String, dynamic>>>>
      getApplications() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return left(const Failure('Login required.'));

      final data = await SupabaseService.client
          .from('applications')
          .select()
          .eq('user_id', userId)
          .order('applied_at', ascending: false);

      final apps = (data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return right(apps);
    } catch (e) {
      return left(Failure('Applications nahi mile: $e'));
    }
  }

  /// Kaunse jobs apply kiye (set) — taaki "Applied" dikhe.
  static Future<Set<String>> getAppliedJobIds() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return {};

      final data = await SupabaseService.client
          .from('applications')
          .select('job_id')
          .eq('user_id', userId);

      return (data as List)
          .map((e) => (e as Map)['job_id'].toString())
          .toSet();
    } catch (_) {
      return {};
    }
  }
}