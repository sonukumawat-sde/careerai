import 'package:flutter/material.dart';
import '../../features/home/home_screen.dart';
import '../../features/tools/tools_screen.dart';
import '../../features/jobs/jobs_screen.dart';
import '../../features/coach/coach_screen.dart';
import 'premium_bottom_nav.dart';
import 'placeholder_screen.dart';

/// App ka main frame — premium custom bottom nav.
/// 4 tabs: Home, Tools, Jobs, Coach. (Profile avatar se khulta.)
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  late final List<Widget> _screens = [
    HomeScreen(onGoToJobs: () => setState(() => _index = 2)),
    const ToolsScreen(),
    const JobsScreen(),
    const CoachScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: PremiumBottomNav(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}