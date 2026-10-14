import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'rewards_service.dart';
import 'achievements_data.dart';

/// Menu > Rewards & Achievements — real points, level, badges.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  RewardsData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await RewardsService.getRewards();
    if (!mounted) return;
    result.match(
      (failure) => setState(() => _loading = false),
      (data) => setState(() {
        _data = data;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Rewards & Achievements'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppBrand.violet))
          : _data == null
              ? const Center(child: Text('Could not load rewards.'))
              : RefreshIndicator(
                  color: AppBrand.violet,
                  onRefresh: _load,
                  child: _content(_data!),
                ),
    );
  }

  Widget _content(RewardsData d) {
    final unlockedCount =
        allAchievements.where((a) => a.isUnlocked(d)).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        // ---- Level hero card ----
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            children: [
              // Level badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('LVL',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      Text('${d.level}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              height: 1)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(d.rank,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${d.totalPoints} total points',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 16),
              // XP bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Level ${d.level}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12)),
                      Text('${d.currentLevelXp} / ${d.nextLevelXp} XP',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: d.currentLevelXp / d.nextLevelXp,
                      minHeight: 10,
                      backgroundColor: Colors.white.withValues(alpha: 0.25),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ---- Stats row ----
        Row(
          children: [
            Expanded(child: _statCard('${d.totalPoints}', 'Points', Icons.stars_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('$unlockedCount', 'Badges', Icons.emoji_events_outlined)),
            const SizedBox(width: 10),
            Expanded(child: _statCard('${d.referralCount}', 'Referrals', Icons.people_outline)),
          ],
        ),
        const SizedBox(height: 24),

        // ---- Achievements ----
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Achievements',
                style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 18,
                    fontWeight: FontWeight.w800)),
            Text('$unlockedCount / ${allAchievements.length}',
                style: const TextStyle(
                    color: AppBrand.violet,
                    fontSize: 14,
                    fontWeight: FontWeight.w800)),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: allAchievements.length,
          itemBuilder: (context, i) =>
              _badgeCard(allAchievements[i], allAchievements[i].isUnlocked(d)),
        ),
        const SizedBox(height: 24),

        // ---- How to earn ----
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEEF1F5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How to Earn Points',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              _earnRow(Icons.description, 'Analyze a resume', '+10'),
              _earnRow(Icons.send, 'Apply to a job', '+5'),
              _earnRow(Icons.bookmark, 'Save a job', '+2'),
              _earnRow(Icons.card_giftcard, 'Refer a friend', '+50'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEF1F5)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppBrand.violet, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _badgeCard(Achievement a, bool unlocked) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked
              ? a.color.withValues(alpha: 0.3)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: a.color.withValues(alpha: 0.15),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: unlocked
                  ? a.color.withValues(alpha: 0.12)
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              unlocked ? a.icon : Icons.lock_outline,
              color: unlocked ? a.color : const Color(0xFF94A3B8),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: unlocked
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(a.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _earnRow(IconData icon, String label, String points) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppBrand.violet.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppBrand.violet, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
          Text(points,
              style: const TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}