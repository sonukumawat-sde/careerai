import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../services/ai_service.dart';
import '../../services/supabase_service.dart';
import 'coach_data.dart';

/// Coach ka poora logic — profile context, AI chat, aur history save/load.
class CoachService {
  CoachService._();

  // -------------------- PROFILE CONTEXT --------------------

  /// User ka profile laao (personalization ke liye).
  /// Return: {user_name, user_role, target_role, experience, industry}
  /// Koi field null ho toh empty string. Kabhi crash nahi.
  static Future<Map<String, String>> getProfileContext() async {
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

      // Alag-alag possible column naam handle karo (safe)
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

  // -------------------- AI CHAT --------------------

  /// AI coach se ek reply lao.
  /// [history] = pichli baat (short summary), personalization profile se.
  static Future<Either<Failure, String>> sendMessage({
    required String message,
    String history = '',
  }) async {
    final profile = await getProfileContext();

    final result = await AiService.run(
      task: 'coach_chat',
      payload: {
        'message': message,
        'history': history,
        ...profile,
      },
    );

    return result.match(
      (failure) => left(failure),
      (data) {
        final text = data['result']?.toString().trim() ?? '';
        if (text.isEmpty) {
          return left(const Failure('Coach abhi reply nahi de paya. Dobara try karo.'));
        }
        return right(text);
      },
    );
  }

  /// Personalized welcome message lao (chat khulte hi).
  /// Fail ho toh ek safe default de do.
  static Future<String> getWelcome() async {
    final profile = await getProfileContext();
    final name = profile['user_name'] ?? '';

    final result = await AiService.run(
      task: 'coach_welcome',
      payload: {...profile},
    );

    return result.match(
      (_) => _defaultWelcome(name),
      (data) {
        final text = data['result']?.toString().trim() ?? '';
        return text.isEmpty ? _defaultWelcome(name) : text;
      },
    );
  }

  static String _defaultWelcome(String name) {
    final hi = name.isNotEmpty ? 'Hi $name! 👋' : 'Hi! 👋';
    return '$hi Main tera AI Career Coach hoon. Resume, interview, jobs ya career '
        'growth — kisi bhi cheez me help chahiye toh bindaas poochh!';
  }

  // -------------------- HISTORY (Supabase) --------------------

  /// Nayi chat save karo → id return karo (aage update ke liye).
  static Future<String?> createChat({
    required String title,
    required String lastMessage,
    required List<ChatMessage> messages,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return null;

      final data = await SupabaseService.client
          .from('coach_chats')
          .insert({
            'user_id': userId,
            'title': _shortTitle(title),
            'last_message': lastMessage,
            'messages': messages.map(_msgToMap).toList(),
          })
          .select('id')
          .single();

      return data['id']?.toString();
    } catch (_) {
      return null;
    }
  }

  /// Existing chat update karo (nayi messages ke saath).
  static Future<void> updateChat({
    required String chatId,
    required String lastMessage,
    required List<ChatMessage> messages,
  }) async {
    try {
      await SupabaseService.client.from('coach_chats').update({
        'last_message': lastMessage,
        'messages': messages.map(_msgToMap).toList(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', chatId);
    } catch (_) {}
  }

  /// User ke saare chats laao (recent pehle).
  static Future<List<CoachChat>> getChats() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return [];

      final data = await SupabaseService.client
          .from('coach_chats')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      return (data as List)
          .map((e) => CoachChat.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Chat delete karo.
  static Future<void> deleteChat(String chatId) async {
    try {
      await SupabaseService.client
          .from('coach_chats')
          .delete()
          .eq('id', chatId);
    } catch (_) {}
  }

  // -------------------- helpers --------------------

  static Map<String, dynamic> _msgToMap(ChatMessage m) =>
      {'text': m.text, 'isUser': m.isUser};

  /// Title chhota rakho (pehle user message se).
  static String _shortTitle(String s) {
    final clean = s.trim().replaceAll('\n', ' ');
    if (clean.length <= 40) return clean;
    return '${clean.substring(0, 40)}...';
  }
}