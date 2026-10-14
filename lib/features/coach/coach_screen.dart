import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/premium/premium_widgets.dart';
import 'coach_data.dart';
import 'coach_service.dart';
import 'chat_screen.dart';

/// Coach landing — daily tip, quick actions, premium topics, real history.
class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  List<CoachChat> _chats = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    final chats = await CoachService.getChats();
    if (!mounted) return;
    setState(() {
      _chats = chats;
      _loading = false;
    });
  }

  Future<void> _openChat(BuildContext context,
      {String? initialPrompt, CoachChat? existingChat}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          initialPrompt: initialPrompt,
          existingChat: existingChat,
        ),
      ),
    );
    // Wapas aane pe history refresh karo
    _loadChats();
  }

  void _showPremiumTopic(BuildContext context, PremiumTopic topic) {
    showPremiumLock(
      context,
      feature: topic.title,
      benefits: coachPremiumBenefits,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _headerCard(),
            const SizedBox(height: 16),
            _dailyTipCard(),
            const SizedBox(height: 16),
            _newChatButton(),
            const SizedBox(height: 26),

            // ---- Quick actions ----
            const Text('How can I help you?',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            _quickActionsGrid(),
            const SizedBox(height: 26),

            // ---- Premium topics ----
            Row(
              children: [
                const Text('Pro Coaching',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w800)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('PRO',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...coachPremiumTopics.map(_premiumTopicCard),
            const SizedBox(height: 26),

            // ---- Recent conversations (REAL) ----
            const Text('Recent Conversations',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _recentChats(),
          ],
        ),
      ),
    );
  }

  // ---------- HEADER ----------
  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.psychology,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Career Coach',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 4),
                Text('Your personal mentor, available 24/7.',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- DAILY TIP ----------
  Widget _dailyTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.lightbulb,
                color: Color(0xFFF59E0B), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TIP OF THE DAY',
                    style: TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(todaysTip(),
                    style: const TextStyle(
                        color: Color(0xFF78350F),
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- NEW CHAT ----------
  Widget _newChatButton() {
    return GestureDetector(
      onTap: () => _openChat(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: AppBrand.violet.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                color: AppBrand.violet, size: 22),
            SizedBox(width: 10),
            Text('Start New Conversation',
                style: TextStyle(
                    color: AppBrand.violet,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  // ---------- QUICK ACTIONS ----------
  Widget _quickActionsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.35,
      children: coachActions.map((action) {
        return GestureDetector(
          onTap: () => _openChat(context, initialPrompt: action.prompt),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: action.color.withValues(alpha: 0.15)),
              boxShadow: [
                BoxShadow(
                  color: action.color.withValues(alpha: 0.1),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: action.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child:
                      Icon(action.icon, color: action.color, size: 20),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.title,
                        style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(action.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------- PREMIUM TOPIC CARD ----------
  Widget _premiumTopicCard(PremiumTopic topic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showPremiumTopic(context, topic),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEF1F5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: topic.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(topic.icon, color: topic.color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.title,
                        style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(topic.subtitle,
                        style: const TextStyle(
                            color: Color(0xFF94A3B8), fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.lock_outline,
                  color: Color(0xFFF59E0B), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- RECENT CHATS (real) ----------
  Widget _recentChats() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
            child: CircularProgressIndicator(color: AppBrand.violet)),
      );
    }
    if (_chats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEF1F5)),
        ),
        child: const Column(
          children: [
            Icon(Icons.chat_bubble_outline,
                color: Color(0xFFCBD5E1), size: 36),
            SizedBox(height: 10),
            Text('No conversations yet',
                style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
            SizedBox(height: 4),
            Text('Start a chat to get personalized career advice.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF94A3B8), fontSize: 12)),
          ],
        ),
      );
    }
    return Column(
      children: _chats.map((chat) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _openChat(context, existingChat: chat),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEEF1F5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppBrand.violet.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(Icons.chat_bubble_outline,
                          color: AppBrand.violet, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(chat.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(chat.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(chat.timeAgo,
                        style: const TextStyle(
                            color: Color(0xFFCBD5E1), fontSize: 11)),
                  ],
                ),
              ),
            ),
          )).toList(),
    );
  }
}