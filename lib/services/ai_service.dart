import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../core/errors/failure.dart';

/// AI ka SINGLE gateway. Poore app ka har AI feature yahi se jayega.
///
/// App -> Supabase Edge Function ('ai-proxy') -> Gemini -> wapas.
/// Gemini key server pe hai, app me kabhi nahi (secure).
class AiService {
  AiService._();

  static Future<Either<Failure, Map<String, dynamic>>> run({
    required String task,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final res = await SupabaseService.client.functions.invoke(
        'ai-proxy',
        body: {'task': task, 'payload': payload},
      );

      final data = res.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['error'] != null) {
          return left(Failure(map['error'].toString()));
        }
        return right(map);
      }
      return left(const Failure('AI se galat format aaya. Dobara try karo.'));
    } on FunctionException catch (e) {
      return left(Failure('AI service error: ${e.details ?? "unknown"}'));
    } catch (e) {
      return left(Failure('Kuch galat hua: $e'));
    }
  }
}