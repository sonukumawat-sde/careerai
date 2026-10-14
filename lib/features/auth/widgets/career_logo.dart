import 'package:flutter/material.dart';

/// CareerAI logo — asli image (assets/images/logo.png).
class CareerLogo extends StatelessWidget {
  final double height;
  const CareerLogo({super.key, this.height = 170});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}