import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';

/// Job filters bottom sheet kholta hai.
void showFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  final Set<String> _jobTypes = {};
  final Set<String> _experience = {};
  String _location = 'Any';
  RangeValues _salary = const RangeValues(5, 30);
  bool _remoteOnly = false;

  final _types = const ['Full-time', 'Part-time', 'Internship', 'Contract'];
  final _expLevels = const ['Fresher', '1-3 yrs', '3-5 yrs', '5+ yrs'];
  final _locations = const ['Any', 'Bangalore', 'Hyderabad', 'Delhi', 'Mumbai', 'Remote'];

  void _reset() {
    setState(() {
      _jobTypes.clear();
      _experience.clear();
      _location = 'Any';
      _salary = const RangeValues(5, 30);
      _remoteOnly = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle + header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filters',
                        style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    GestureDetector(
                      onTap: _reset,
                      child: const Text('Reset',
                          style: TextStyle(
                              color: AppBrand.violet,
                              fontSize: 14,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              children: [
                // Location
                _label('Location'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _locations.map((loc) {
                    final selected = _location == loc;
                    return _chip(loc, selected,
                        () => setState(() => _location = loc));
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Salary range
                _label('Salary Range (LPA)'),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹${_salary.start.round()} LPA',
                        style: const TextStyle(
                            color: AppBrand.violet,
                            fontWeight: FontWeight.w700)),
                    Text('₹${_salary.end.round()} LPA',
                        style: const TextStyle(
                            color: AppBrand.violet,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
                RangeSlider(
                  values: _salary,
                  min: 0,
                  max: 50,
                  divisions: 50,
                  activeColor: AppBrand.violet,
                  inactiveColor: const Color(0xFFE2E8F0),
                  labels: RangeLabels(
                    '₹${_salary.start.round()}',
                    '₹${_salary.end.round()}',
                  ),
                  onChanged: (v) => setState(() => _salary = v),
                ),
                const SizedBox(height: 20),

                // Job type
                _label('Job Type'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _types.map((t) {
                    final selected = _jobTypes.contains(t);
                    return _chip(t, selected, () {
                      setState(() {
                        if (selected) {
                          _jobTypes.remove(t);
                        } else {
                          _jobTypes.add(t);
                        }
                      });
                    });
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Experience
                _label('Experience'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _expLevels.map((e) {
                    final selected = _experience.contains(e);
                    return _chip(e, selected, () {
                      setState(() {
                        if (selected) {
                          _experience.remove(e);
                        } else {
                          _experience.add(e);
                        }
                      });
                    });
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Remote toggle
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFEEF1F5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi, color: AppBrand.violet, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('Remote only',
                            style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                      ),
                      Switch(
                        value: _remoteOnly,
                        activeColor: AppBrand.violet,
                        onChanged: (v) => setState(() => _remoteOnly = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Apply button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            decoration: const BoxDecoration(color: Colors.white),
            child: SafeArea(
              top: false,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppGradients.buttonGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppBrand.violet.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('Apply Filters',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Align(
        alignment: Alignment.centerLeft,
        child: Text(t,
            style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800)),
      );

  Widget _chip(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: selected ? AppGradients.buttonGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? Colors.transparent : const Color(0xFFE2E8F0)),
        ),
        child: Text(text,
            style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}