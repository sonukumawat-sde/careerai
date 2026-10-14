import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'roadmap_service.dart';

/// Career Roadmap — input, AI generate, timeline UI, saved roadmaps.
class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({super.key});

  @override
  State<RoadmapScreen> createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> {
  final _statusController = TextEditingController();
  final _goalController = TextEditingController();

  bool _generating = false;
  bool _loadingSaved = true;
  CareerRoadmap? _roadmap; // current generated/viewing
  List<CareerRoadmap> _saved = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _statusController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final list = await RoadmapService.getRoadmaps();
    if (!mounted) return;
    setState(() {
      _saved = list;
      _loadingSaved = false;
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _generate() async {
    final goal = _goalController.text.trim();
    if (goal.isEmpty) {
      _showError('Please enter your career goal.');
      return;
    }

    setState(() => _generating = true);

    final result = await RoadmapService.generate(
      currentStatus: _statusController.text.trim(),
      goal: goal,
    );
    if (!mounted) return;
    setState(() => _generating = false);

    await result.match(
      (failure) async => _showError(failure.message),
      (roadmap) async {
        await RoadmapService.save(roadmap);
        if (!mounted) return;
        setState(() => _roadmap = roadmap);
        _loadSaved();
      },
    );
  }

  void _viewSaved(CareerRoadmap r) {
    setState(() => _roadmap = r);
  }

  void _backToInput() {
    setState(() => _roadmap = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_generating) return _generatingView();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Career Roadmap'),
        centerTitle: true,
        leading: _roadmap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backToInput,
              )
            : null,
      ),
      body: _roadmap != null ? _roadmapView(_roadmap!) : _inputView(),
    );
  }

  // ---------- INPUT VIEW ----------
  Widget _inputView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        // Hero
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppBrand.purple, AppBrand.violet, AppBrand.indigo],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.map_outlined,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Your Personalized Roadmap',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text(
                  'Tell us your goal and get a step-by-step plan to reach it.',
                  style: TextStyle(
                      color: Colors.white70, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        const Text('Where are you now? (optional)',
            style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _input(_statusController,
            'e.g. Final year CSE student, know basic Python', 2),
        const SizedBox(height: 20),

        const Text('What is your goal?',
            style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 15,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        _input(_goalController, 'e.g. Become a Data Scientist at a top company',
            2),
        const SizedBox(height: 24),

        GestureDetector(
          onTap: _generate,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppGradients.buttonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppBrand.violet.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text('Generate Roadmap',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Saved roadmaps
        const Text('Saved Roadmaps',
            style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (_loadingSaved)
          const Center(
              child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(color: AppBrand.violet),
          ))
        else if (_saved.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEF1F5)),
            ),
            child: const Column(
              children: [
                Icon(Icons.map_outlined, color: Color(0xFFCBD5E1), size: 36),
                SizedBox(height: 10),
                Text('No roadmaps yet',
                    style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('Generate your first career roadmap above.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          )
        else
          ..._saved.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () => _viewSaved(r),
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppBrand.violet.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: const Icon(Icons.route,
                              color: AppBrand.violet, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.goal,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 2),
                              Text('${r.phases.length} phases · ${r.duration}',
                                  style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Text(r.timeAgo,
                            style: const TextStyle(
                                color: Color(0xFFCBD5E1), fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              )),
      ],
    );
  }

  Widget _input(TextEditingController c, String hint, int minLines) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: c,
        minLines: minLines,
        maxLines: minLines + 2,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  // ---------- ROADMAP VIEW ----------
  Widget _roadmapView(CareerRoadmap r) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppBrand.purple, AppBrand.violet, AppBrand.indigo],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.goal,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (r.duration.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(r.duration,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              if (r.summary.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(r.summary,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13, height: 1.5)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Phases (timeline)
        ...r.phases.asMap().entries.map((e) {
          final isLast = e.key == r.phases.length - 1;
          return _phaseCard(e.key + 1, e.value, isLast);
        }),
      ],
    );
  }

  Widget _phaseCard(int number, RoadmapPhase phase, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppBrand.violet, AppBrand.indigo],
                  ),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text('$number',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900)),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppBrand.violet.withValues(alpha: 0.2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEF1F5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(phase.title,
                      style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  if (phase.timeline.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(phase.timeline,
                        style: const TextStyle(
                            color: AppBrand.violet,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ],
                  if (phase.skills.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text('SKILLS TO LEARN',
                        style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: phase.skills
                          .map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color:
                                      AppBrand.violet.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(s,
                                    style: const TextStyle(
                                        color: AppBrand.violet,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ))
                          .toList(),
                    ),
                  ],
                  if (phase.actions.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('ACTION STEPS',
                        style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 8),
                    ...phase.actions.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(Icons.check_circle_outline,
                                    color: Color(0xFF22C55E), size: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(a,
                                    style: const TextStyle(
                                        color: Color(0xFF475569),
                                        fontSize: 13,
                                        height: 1.4)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- GENERATING ----------
  Widget _generatingView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppGradients.buttonGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppBrand.violet.withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.map_outlined,
                  color: Colors.white, size: 44),
            ),
            const SizedBox(height: 28),
            const Text('Building your roadmap...',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('AI is planning your career journey.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
            const SizedBox(height: 28),
            const CircularProgressIndicator(color: AppBrand.violet),
          ],
        ),
      ),
    );
  }
}