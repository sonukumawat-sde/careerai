/// Interview module ke saare data models.

/// Interview ka type.
enum InterviewType { roleBased, resumeBased, topicBased }

/// Difficulty level.
enum InterviewDifficulty { easy, medium, hard }

/// String <-> enum helpers (Supabase save/load ke liye)
InterviewType interviewTypeFromString(String s) {
  switch (s) {
    case 'resumeBased':
      return InterviewType.resumeBased;
    case 'topicBased':
      return InterviewType.topicBased;
    default:
      return InterviewType.roleBased;
  }
}

String interviewTypeToString(InterviewType t) => t.name; // roleBased/resumeBased/topicBased

InterviewDifficulty difficultyFromString(String s) {
  switch (s) {
    case 'easy':
      return InterviewDifficulty.easy;
    case 'hard':
      return InterviewDifficulty.hard;
    default:
      return InterviewDifficulty.medium;
  }
}

String difficultyToString(InterviewDifficulty d) => d.name; // easy/medium/hard

/// Ek interview question + user ka answer + AI feedback.
class InterviewQA {
  final String question;
  String userAnswer;
  String feedback; // AI feedback
  String idealAnswer; // AI ka ideal answer
  int score; // is answer ka score (0-10)

  InterviewQA({
    required this.question,
    this.userAnswer = '',
    this.feedback = '',
    this.idealAnswer = '',
    this.score = 0,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'userAnswer': userAnswer,
        'feedback': feedback,
        'idealAnswer': idealAnswer,
        'score': score,
      };

  factory InterviewQA.fromJson(Map<String, dynamic> j) => InterviewQA(
        question: (j['question'] ?? '').toString(),
        userAnswer: (j['userAnswer'] ?? '').toString(),
        feedback: (j['feedback'] ?? '').toString(),
        idealAnswer: (j['idealAnswer'] ?? '').toString(),
        score: _toInt(j['score']),
      );
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is double) return v.round();
  if (v is String) return int.tryParse(v.replaceAll('%', '').trim()) ?? 0;
  return 0;
}

/// Poora interview session ka data.
class InterviewSession {
  String id;
  final String role;
  final InterviewType type;
  final InterviewDifficulty difficulty;
  final List<InterviewQA> questions;
  int overallScore; // 0-100
  String strengths;
  String weaknesses;
  String tips;
  final DateTime createdAt;

  InterviewSession({
    this.id = '',
    required this.role,
    required this.type,
    required this.difficulty,
    required this.questions,
    this.overallScore = 0,
    this.strengths = '',
    this.weaknesses = '',
    this.tips = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Difficulty ka naam (display).
  String get difficultyLabel {
    switch (difficulty) {
      case InterviewDifficulty.easy:
        return 'Easy';
      case InterviewDifficulty.medium:
        return 'Medium';
      case InterviewDifficulty.hard:
        return 'Hard';
    }
  }

  /// Type ka naam (display).
  String get typeLabel {
    switch (type) {
      case InterviewType.roleBased:
        return 'Role-Based';
      case InterviewType.resumeBased:
        return 'Resume-Based';
      case InterviewType.topicBased:
        return 'Topic-Based';
    }
  }

  /// Score ka label.
  String get scoreLabel {
    if (overallScore >= 85) return 'Excellent';
    if (overallScore >= 70) return 'Good';
    if (overallScore >= 50) return 'Average';
    return 'Needs Work';
  }

  /// "2h ago" style time.
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  /// Supabase se load.
  factory InterviewSession.fromMap(Map<String, dynamic> map) {
    final rawQ = map['questions'];
    final qs = <InterviewQA>[];
    if (rawQ is List) {
      for (final q in rawQ) {
        if (q is Map) {
          qs.add(InterviewQA.fromJson(Map<String, dynamic>.from(q)));
        }
      }
    }
    return InterviewSession(
      id: (map['id'] ?? '').toString(),
      role: (map['role'] ?? '').toString(),
      type: interviewTypeFromString((map['type'] ?? 'roleBased').toString()),
      difficulty:
          difficultyFromString((map['difficulty'] ?? 'medium').toString()),
      questions: qs,
      overallScore: _toInt(map['overall_score']),
      strengths: (map['strengths'] ?? '').toString(),
      weaknesses: (map['weaknesses'] ?? '').toString(),
      tips: (map['tips'] ?? '').toString(),
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

/// Interview type ki UI info (cards ke liye).
class InterviewTypeInfo {
  final InterviewType type;
  final String title;
  final String description;
  final String emoji;

  const InterviewTypeInfo({
    required this.type,
    required this.title,
    required this.description,
    required this.emoji,
  });
}

/// 3 interview types (home screen cards).
const List<InterviewTypeInfo> kInterviewTypes = [
  InterviewTypeInfo(
    type: InterviewType.roleBased,
    title: 'Role-Based',
    description: 'Questions tailored to a specific job role',
    emoji: '💼',
  ),
  InterviewTypeInfo(
    type: InterviewType.resumeBased,
    title: 'Resume-Based',
    description: 'Questions based on your resume & experience',
    emoji: '📄',
  ),
  InterviewTypeInfo(
    type: InterviewType.topicBased,
    title: 'Topic-Based',
    description: 'Practice by topic — DSA, System Design, HR',
    emoji: '🎯',
  ),
];