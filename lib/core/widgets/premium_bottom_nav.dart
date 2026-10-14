import 'package:flutter/material.dart';
import '../theme/app_gradients.dart';

/// Bottom navigation — simple, professional. Selected tab pe top indicator + purple icon/label.
class PremiumBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PremiumBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome, 'Tools'),
    _NavItem(Icons.work_outline_rounded, Icons.work_rounded, 'Jobs'),
    _NavItem(Icons.psychology_outlined, Icons.psychology_rounded, 'Coach'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFEEF1F5), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              return Expanded(
                child: _buildItem(_items[i], i == currentIndex, () => onTap(i)),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(_NavItem item, bool selected, VoidCallback onTap) {
    final color =
        selected ? AppBrand.violet : const Color(0xFF94A3B8);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(selected ? item.activeIcon : item.icon, color: color, size: 25),
          const SizedBox(height: 5),
          Text(
            item.label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(this.icon, this.activeIcon, this.label);
}