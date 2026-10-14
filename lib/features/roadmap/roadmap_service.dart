import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../services/ai_service.dart';
import '../../services/supabase_service.dart';

/// Ek roadmap phase.
class RoadmapPhase {
  final String title;
  final String timeline;
  final List<String> skills;
  final List<String> actions;

  const RoadmapPhase({
    required this.title,
    required this.timeline,
    required this.skills,
    required this.actions,
  });

  factory RoadmapPhase.fromMap(Map<String, dynamic> m) => RoadmapPhase(
        title: (m['title'] ?? '').toString(),
        timeline: (m['timeline'] ?? '').toString(),
        skills: _list(m['skills']),
        actions: _list(m['actions']),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'timeline': timeline,
        'skills': skills,
        'actions': actions,
      };

  static List<String> _list(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).toList();
    }
    return [];
  }
}

/// Poora career roadmap.
class CareerRoadmap {
  String id;
  final String currentStatus;
  final String goal;
  final String summary;
  final String duration;
  final List<RoadmapPhase> phases;
  final DateTime createdAt;

  CareerRoadmap({
    this.id = '',
    required this.currentStatus,
    required this.goal,
    required this.summary,
    required this.duration,
    required this.phases,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CareerRoadmap.fromMap(Map<String, dynamic> map) {
    final rawPhases = map['phases'];
    final phases = <RoadmapPhase>[];
    if (rawPhases is List) {
      for (final p in rawPhases) {
        if (p is Map) {
          phases.add(RoadmapPhase.fromMap(Map<String, dynamic>.from(p)));
        }
      }
    }
    return CareerRoadmap(
      id: (map['id'] ?? '').toString(),
      currentStatus: (map['current_status'] ?? '').toString(),
      goal: (map['goal'] ?? '').toString(),
      summary: (map['summary'] ?? '').toString(),
      duration: (map['duration'] ?? '').toString(),
      phases: phases,
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

/// Career Roadmap ka logic — AI generate + save/load.
class RoadmapService {
  RoadmapService._();

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

  /// AI se roadmap generate karo.
  static Future<Either<Failure, CareerRoadmap>> generate({
    required String currentStatus,
    required String goal,
  }) async {
    final profile = await _profileContext();

    final result = await AiService.run(
      task: 'career_roadmap',
      payload: {
        'current_status': currentStatus,
        'goal': goal,
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
            return left(const Failure('Roadmap nahi bana. Dobara try karo.'));
          }
          final roadmap = CareerRoadmap(
            currentStatus: currentStatus,
            goal: goal,
            summary: (map['summary'] ?? '').toString(),
            duration: (map['duration'] ?? '').toString(),
            phases: _phases(map['phases']),
          );
          if (roadmap.phases.isEmpty) {
            return left(const Failure('Roadmap khali aaya. Dobara try karo.'));
          }
          return right(roadmap);
        } catch (e) {
          return left(Failure('Roadmap parse nahi hua: $e'));
        }
      },
    );
  }

  /// Roadmap save karo → id return.
  static Future<String?> save(CareerRoadmap r) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return null;

      final data = await SupabaseService.client
          .from('roadmaps')
          .insert({
            'user_id': userId,
            'current_status': r.currentStatus,
            'goal': r.goal,
            'summary': r.summary,
            'duration': r.duration,
            'phases': r.phases.map((p) => p.toJson()).toList(),
          })
          .select('id')
          .single();

      final id = data['id']?.toString();
      if (id != null) r.id = id;
      return id;
    } catch (_) {
      return null;
    }
  }

  /// Saved roadmaps laao (recent pehle).
  static Future<List<CareerRoadmap>> getRoadmaps() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return [];
      final data = await SupabaseService.client
          .from('roadmaps')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => CareerRoadmap.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Roadmap delete karo.
  static Future<void> delete(String id) async {
    try {
      await SupabaseService.client.from('roadmaps').delete().eq('id', id);
    } catch (_) {}
  }

  // helpers
  static List<RoadmapPhase> _phases(dynamic v) {
    if (v is List) {
      return v
          .whereType<Map>()
          .map((e) => RoadmapPhase.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

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
}