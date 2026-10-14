import 'package:flutter/material.dart';
import '../../../../core/theme/app_gradients.dart';
import '../resume_builder_data.dart';

/// Step 5 — Skills. Chips/tags add/remove.
class SkillsStep extends StatefulWidget {
  final ResumeData data;
  final VoidCallback onChanged;

  const SkillsStep({
    super.key,
    required this.data,
    required this.onChanged,
  });

  @override
  State<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<SkillsStep> {
  final _controller = TextEditingController();

  // Popular skills suggestions
  final _suggestions = const [
    'Flutter', 'Dart', 'React', 'JavaScript', 'Python', 'Java',
    'Firebase', 'SQL', 'Git', 'REST API', 'UI/UX', 'Node.js',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSkill(String skill) {
    final s = skill.trim();
    if (s.isNotEmpty && !widget.data.skills.contains(s)) {
      setState(() {
        widget.data.skills.add(s);
        _controller.clear();
      });
      widget.onChanged();
    }
  }

  void _removeSkill(String skill) {
    setState(() => widget.data.skills.remove(skill));
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final availableSuggestions =
        _suggestions.where((s) => !widget.data.skills.contains(s)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppGradients.buttonGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppBrand.violet.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(Icons.code, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Skills',
                      style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 19,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 2),
                  Text('Add your top skills. Type or pick below.',
                      style:
                          TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Input field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.done,
            onSubmitted: _addSkill,
            style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Type a skill and press enter...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
              prefixIcon:
                  const Icon(Icons.add, color: AppBrand.violet, size: 20),
              suffixIcon: GestureDetector(
                onTap: () => _addSkill(_controller.text),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppGradients.buttonGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Add',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Added skills
        if (widget.data.skills.isNotEmpty) ...[
          const Text('Your Skills',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: widget.data.skills.map((skill) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppGradients.buttonGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppBrand.violet.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(skill,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => _removeSkill(skill),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // Suggestions
        if (availableSuggestions.isNotEmpty) ...[
          const Text('Popular Skills',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: availableSuggestions.map((skill) {
              return GestureDetector(
                onTap: () => _addSkill(skill),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: AppBrand.violet.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add,
                          color: AppBrand.violet, size: 15),
                      const SizedBox(width: 4),
                      Text(skill,
                          style: const TextStyle(
                              color: AppBrand.violet,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}