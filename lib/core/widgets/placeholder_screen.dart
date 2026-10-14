import 'package:flutter/material.dart';

/// Temporary screen. Har module ka real UI hum baad ke steps me banayenge.
/// Abhi ye bas dikhata hai ki tab kaam kar raha hai.
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String note;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.note = 'Ye module agle step me banega.',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: scheme.primary),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(note,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }
}