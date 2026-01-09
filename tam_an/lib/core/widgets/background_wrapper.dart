import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;

  const BackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base Background Color
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        
        // Abstract Patterns
        Positioned.fill(
          child: CustomPaint(
            painter: isDark ? DarkBackgroundPainter() : LightBackgroundPainter(),
          ),
        ),
        
        // Content
        child,
      ],
    );
  }
}

class LightBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryWarm.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    
    // Subtle waves
    for (var i = 0; i < 3; i++) {
      path.reset();
      double yOffset = size.height * (0.3 + i * 0.2);
      path.moveTo(0, yOffset);
      
      for (double x = 0; x <= size.width; x++) {
        double y = yOffset + math.sin((x / size.width * 2 * math.pi) + (i * math.pi / 2)) * 30;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DarkBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Seed for consistency
    final paint = Paint()..color = Colors.white.withOpacity(0.3);

    // Subtle particles (stars)
    for (var i = 0; i < 50; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double radius = random.nextDouble() * 1.5;
      
      canvas.drawCircle(
        Offset(x, y), 
        radius, 
        Paint()..color = Colors.white.withOpacity(random.nextDouble() * 0.3)
      );
    }

    // Aurora-like glow
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final Gradient gradient = RadialGradient(
      center: const Alignment(-0.8, -0.6),
      radius: 1.2,
      colors: [
        AppColors.primaryWarm.withOpacity(0.05),
        Colors.transparent,
      ],
    );
    
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}