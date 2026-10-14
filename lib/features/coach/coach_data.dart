import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';

/// Coach ka quick action (ready-made topic).
class CoachAction {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String prompt; // tap karne pe ye message bhejega

  const CoachAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.prompt,
  });
}

/// Quick action cards (Coach landing pe).
const List<CoachAction> coachActions = [
  CoachAction(
    icon: Icons.description_outlined,
    title: 'Resume Advice',
    subtitle: 'Improve your resume',
    color: AppBrand.violet,
    prompt: 'Can you give me advice to improve my resume?',
  ),
  CoachAction(
    icon: Icons.record_voice_over_outlined,
    title: 'Interview Tips',
    subtitle: 'Ace your interviews',
    color: AppBrand.blueAccent,
    prompt: 'Give me tips to prepare for a job interview.',
  ),
  CoachAction(
    icon: Icons.payments_outlined,
    title: 'Salary Negotiation',
    subtitle: 'Get paid what you deserve',
    color: Color(0xFF22C55E),
    prompt: 'How do I negotiate a higher salary?',
  ),
  CoachAction(
    icon: Icons.school_outlined,
    title: 'Skill Suggestions',
    subtitle: 'What to learn next',
    color: Color(0xFFF59E0B),
    prompt: 'What skills should I learn to grow in my career?',
  ),
  CoachAction(
    icon: Icons.search,
    title: 'Job Search',
    subtitle: 'Find the right jobs',
    color: Color(0xFFEC4899),
    prompt: 'Give me a job search strategy.',
  ),
  CoachAction(
    icon: Icons.psychology_alt_outlined,
    title: 'Confused?',
    subtitle: 'Job vs higher studies',
    color: AppBrand.indigo,
    prompt: 'I am confused between doing a job or higher studies. Help me decide.',
  ),
];

/// ============ PREMIUM TOPICS (Level 3) ============
/// Ye premium features — tap pe premium lock pop aayega.
class PremiumTopic {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const PremiumTopic({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

const List<PremiumTopic> coachPremiumTopics = [
  PremiumTopic(
    icon: Icons.map_outlined,
    title: 'Deep Career Roadmap',
    subtitle: 'Personalized 6-month step-by-step plan',
    color: AppBrand.violet,
  ),
  PremiumTopic(
    icon: Icons.fact_check_outlined,
    title: 'Resume & LinkedIn Review',
    subtitle: 'Line-by-line expert review in chat',
    color: Color(0xFF22C55E),
  ),
  PremiumTopic(
    icon: Icons.handshake_outlined,
    title: 'Mock Salary Negotiation',
    subtitle: 'Practice with your AI coach',
    color: Color(0xFFF59E0B),
  ),
];

/// Premium benefits (lock pop me dikhane ke liye).
const List<String> coachPremiumBenefits = [
  'Personalized 6-month career roadmap',
  'In-chat resume & LinkedIn review',
  'Mock salary negotiation practice',
  'Unlimited coach messages',
];

/// ============ DAILY CAREER TIPS (static rotating) ============
/// Roz ek tip dikhega (date se rotate). No AI cost.
const List<String> dailyCareerTips = [
  'Your LinkedIn headline should say what you do, not just "Student". Try "CSE Student | Flutter Developer | Open to Internships".',
  'Quantify everything on your resume. "Improved performance" is weak. "Cut load time by 40%" gets interviews.',
  'Apply within 24-48 hours of a job posting. Early applicants get 8x more responses.',
  'Before any interview, prepare 3 STAR stories (Situation, Task, Action, Result) you can adapt to any question.',
  'Tailor your resume for each job. Match keywords from the job description — most resumes are filtered by ATS first.',
  'Cold email > job portal. A short, genuine message to a hiring manager on LinkedIn beats 50 portal applications.',
  'Learn to say "I don\'t know, but here\'s how I\'d find out" in interviews. Honesty + problem-solving beats fake confidence.',
  'Build one solid project you can talk about for 10 minutes. Depth beats a list of 10 shallow projects.',
  'Your first salary isn\'t your last. Prioritize learning and a good manager early in your career.',
  'Follow up after every interview with a short thank-you note. Most people don\'t — it makes you memorable.',
  'Skills over degree, but a degree still opens the first door. Do both: finish it AND build real skills.',
  'Network before you need a job. Comment on posts, help others, stay visible. Opportunities come from people.',
  'Never leave a job interview without asking your own questions. It shows genuine interest.',
  'Rejection is redirection. Every "no" is data — ask for feedback and improve for the next one.',
  'A referral makes you 4x more likely to get hired. Ask your seniors, alumni, and connections.',
];

/// Aaj ka tip (date ke hisaab se rotate).
String todaysTip() {
  final dayOfYear =
      DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  return dailyCareerTips[dayOfYear % dailyCareerTips.length];
}

/// Ek chat message.
class ChatMessage {
  final String text;
  final bool isUser; // true = user, false = coach
  const ChatMessage({required this.text, required this.isUser});

  factory ChatMessage.fromMap(Map<String, dynamic> map) => ChatMessage(
        text: (map['text'] ?? '').toString(),
        isUser: map['isUser'] == true,
      );
}

/// Saved conversation (Supabase se aata hai).
class CoachChat {
  final String id;
  final String title;
  final String lastMessage;
  final List<ChatMessage> messages;
  final DateTime updatedAt;

  const CoachChat({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.messages,
    required this.updatedAt,
  });

  factory CoachChat.fromMap(Map<String, dynamic> map) {
    final rawMsgs = map['messages'];
    final msgs = <ChatMessage>[];
    if (rawMsgs is List) {
      for (final m in rawMsgs) {
        if (m is Map) {
          msgs.add(ChatMessage.fromMap(Map<String, dynamic>.from(m)));
        }
      }
    }
    return CoachChat(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? 'Chat').toString(),
      lastMessage: (map['last_message'] ?? '').toString(),
      messages: msgs,
      updatedAt:
          DateTime.tryParse((map['updated_at'] ?? '').toString()) ??
              DateTime.now(),
    );
  }

  /// "2h ago" style time.
  String get timeAgo {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}