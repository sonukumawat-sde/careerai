import 'package:flutter/material.dart';
import '../../core/theme/app_gradients.dart';
import 'notification_data.dart';
import 'notification_widgets.dart';

/// Notification screen — premium, branding colors, filter chips.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _filter = 'All';
  final _filters = const ['All', 'Resume', 'Jobs', 'Interviews'];

  List<AppNotification> get _filtered {
    if (_filter == 'All') return dummyNotifications;
    return dummyNotifications.where((n) => n.category == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Mark all read',
                style: TextStyle(
                    color: AppBrand.violet,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- Filter chips ----
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final f = _filters[i];
                return FilterChipItem(
                  label: f,
                  selected: _filter == f,
                  onTap: () => setState(() => _filter = f),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // ---- List ya empty state ----
          Expanded(
            child: items.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => NotificationCard(
                      item: items[i],
                      onTap: () {},
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppBrand.violet.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none,
                color: AppBrand.violet, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('No notifications yet',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('We\'ll notify you when something important happens.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
        ],
      ),
    );
  }
}