import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/premium/premium_service.dart';
import '../../core/premium/premium_widgets.dart';
import '../premium/premium_screen.dart';
import 'coach_data.dart';
import 'coach_service.dart';
import 'chat_widgets.dart';

/// Chat screen — conversation with the AI coach. Personalized + gated + history saved.
class ChatScreen extends StatefulWidget {
  final String? initialPrompt;
  final CoachChat? existingChat; // to open an existing chat
  const ChatScreen({super.key, this.initialPrompt, this.existingChat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _typing = false;
  bool _loadingWelcome = false;
  String? _chatId; // Supabase chat id (for save/update)

  final _quickReplies = const [
    'Tell me more',
    'Give an example',
    'What should I do next?',
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Case 1: opening an existing chat
    if (widget.existingChat != null) {
      _chatId = widget.existingChat!.id;
      setState(() {
        _messages.addAll(widget.existingChat!.messages);
      });
      _scrollToBottom();
      return;
    }

    // Case 2: new chat — fetch personalized welcome
    setState(() => _loadingWelcome = true);
    final welcome = await CoachService.getWelcome();
    if (!mounted) return;
    setState(() {
      _loadingWelcome = false;
      _messages.add(ChatMessage(text: welcome, isUser: false));
    });

    // Came from a quick action (initial prompt) → auto-send
    if (widget.initialPrompt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _send(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Chat ka short history text (AI ko context dene ke liye — last 6 msg).
  String _historyText() {
    final recent = _messages.length > 6
        ? _messages.sublist(_messages.length - 6)
        : _messages;
    return recent
        .map((m) => '${m.isUser ? "User" : "Coach"}: ${m.text}')
        .join('\n');
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty || _typing) return;

    // ---- Premium gating (5 messages/day free) ----
    final canUse = await PremiumService.canUse(
        'career_coach', FeatureLimits.careerCoach);
    if (!canUse) {
      if (!mounted) return;
      showPremiumLock(
        context,
        feature: 'Career Coach',
        benefits: coachPremiumBenefits,
      );
      return;
    }

    setState(() {
      _messages.add(ChatMessage(text: text.trim(), isUser: true));
      _typing = true;
    });
    _controller.clear();
    _scrollToBottom();

    // History text banao (AI ko context dene ke liye) — current msg ke bina
    final historyForAi = _messages.length > 1
        ? _messages
            .sublist(0, _messages.length - 1)
            .where((m) => m.isUser || _messages.indexOf(m) != 0)
            .map((m) => '${m.isUser ? "User" : "Coach"}: ${m.text}')
            .join('\n')
        : '';

    final result = await CoachService.sendMessage(
      message: text.trim(),
      history: historyForAi,
    );
    if (!mounted) return;

    setState(() {
      _typing = false;
      result.match(
        (failure) => _messages.add(ChatMessage(
          text: 'Sorry, kuch problem aa gayi: ${failure.message}',
          isUser: false,
        )),
        (reply) => _messages.add(ChatMessage(text: reply, isUser: false)),
      );
    });
    _scrollToBottom();

    // Usage record (free count +1) — sirf successful reply pe
    await PremiumService.recordUsage('career_coach');

    // History save (Supabase)
    await _saveHistory();
  }

  /// Chat ko Supabase me save/update karo.
  Future<void> _saveHistory() async {
    // Sirf tab save karo jab user ne kuch bheja ho
    final hasUserMsg = _messages.any((m) => m.isUser);
    if (!hasUserMsg) return;

    final lastMsg = _messages.last.text;
    final firstUserMsg =
        _messages.firstWhere((m) => m.isUser, orElse: () => _messages.first);

    if (_chatId == null) {
      // Nayi chat — create
      final id = await CoachService.createChat(
        title: firstUserMsg.text,
        lastMessage: lastMsg,
        messages: _messages,
      );
      if (id != null) _chatId = id;
    } else {
      // Existing — update
      await CoachService.updateChat(
        chatId: _chatId!,
        lastMessage: lastMsg,
        messages: _messages,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppGradients.buttonGradient,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.psychology, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Career Coach',
                    style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.w800)),
                Row(
                  children: [
                    CircleAvatar(
                        radius: 3, backgroundColor: Color(0xFF22C55E)),
                    SizedBox(width: 4),
                    Text('Online',
                        style: TextStyle(
                            color: Color(0xFF22C55E), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ---- Messages ----
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              children: [
                if (_loadingWelcome) const TypingIndicator(),
                ..._messages
                    .map((m) => ChatBubble(text: m.text, isUser: m.isUser)),
                if (_typing) const TypingIndicator(),
              ],
            ),
          ),

          // ---- Quick replies ----
          if (!_typing && !_loadingWelcome && _messages.length > 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) => Center(
                  child: QuickReplyChip(
                    text: _quickReplies[i],
                    onTap: () => _send(_quickReplies[i]),
                  ),
                ),
              ),
            ),

          // ---- Input box ----
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF64748B).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(24),
                        border:
                            Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Ask your coach anything...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                        ),
                        onSubmitted: _send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => _send(_controller.text),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        gradient: AppGradients.buttonGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppBrand.violet.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}