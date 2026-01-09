import 'package:flutter/material.dart';

/// Health-style colored circular icon inspired by Apple Health aesthetics.
class HealthIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double circleSize;
  final Gradient? gradient;

  const HealthIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 18,
    this.circleSize = 40,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? LinearGradient(colors: [color.withOpacity(0.95), color.withOpacity(0.65)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        gradient: g,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: size),
      ),
    );
  }
}
