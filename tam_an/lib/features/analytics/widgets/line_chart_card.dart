import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../../core/constants/app_colors.dart';

class LineChartCard extends StatelessWidget {
  final List<Offset> points;
  final List<String> labels;
  final String range;
  final ValueChanged<String> onRangeChanged;

  const LineChartCard({Key? key, required this.points, required this.labels, required this.range, required this.onRangeChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Biến thiên cảm xúc', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              // Dropdown Menu
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: const Color(0xFF383838), borderRadius: BorderRadius.circular(8)),
                child: DropdownButton<String>(
                  value: range,
                  dropdownColor: const Color(0xFF4A4A4A),
                  underline: const SizedBox(),
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryBlue, size: 18),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  items: ['7 ngày cuối', '14 ngày cuối', 'Cả tháng'].map((String value) {
                    return DropdownMenuItem<String>(value: value, child: Text(value));
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) onRangeChanged(newValue);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              painter: SixColorChartPainter(points: points, labels: labels),
            ),
          ),
        ],
      ),
    );
  }
}

class SixColorChartPainter extends CustomPainter {
  final List<Offset> points;
  final List<String> labels;
  SixColorChartPainter({required this.points, required this.labels});

  final List<Color> moodColors = [AppColors.moodMad, AppColors.moodSad, AppColors.moodAnxiety, AppColors.moodNeutral, AppColors.moodFun, AppColors.moodHappy];

  @override
  void paint(Canvas canvas, Size size) {
    double leftPadding = 20.0; double bottomPadding = 30.0;
    double w = size.width - leftPadding; double h = size.height - bottomPadding;
    int n = labels.length;
    double stepX = n > 1 ? w / (n - 1) : w;

    // Dải màu
    double segH = h / 6;
    Paint barP = Paint()..style = PaintingStyle.fill;
    for(int i=0; i<6; i++) {
      barP.color = moodColors[5-i];
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, i*segH+2, 6, segH-4), const Radius.circular(3)), barP);
    }

    // Lưới & Chữ (Thông minh)
    Paint gridP = Paint()..color = Colors.white10..strokeWidth = 1;
    TextPainter tp = TextPainter(textDirection: ui.TextDirection.ltr);

    List<int> idxs = [];
    if(n <= 7) idxs = List.generate(n, (i)=>i);
    else {
      idxs.add(0);
      idxs.add((n * 0.25).round());
      idxs.add((n * 0.5).round());
      idxs.add((n * 0.75).round());
      idxs.add(n-1);
      idxs = idxs.toSet().toList()..sort(); // Unique & Sort
    }

    for(int i=0; i<n; i++) {
      double x = leftPadding + i*stepX;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridP);
      if(idxs.contains(i) && i < labels.length) {
        tp.text = TextSpan(text: labels[i], style: const TextStyle(color: Colors.white54, fontSize: 10));
        tp.layout();

        double textX = x - tp.width/2;
        if(i==0) textX = x;
        if(i==n-1) textX = x - tp.width;

        tp.paint(canvas, Offset(textX, h + 10));
      }
    }

    if(points.isEmpty) return;
    Paint lineP = Paint()..color = Colors.white..strokeWidth=2..style=PaintingStyle.stroke;
    Path path = Path();
    double getY(double v) => h - ((v.clamp(1.0, 6.0)-1)/5 * h);
    path.moveTo(leftPadding + points[0].dx.toInt()*stepX, getY(points[0].dy));

    for(int i=0; i<points.length-1; i++) {
      double x1 = leftPadding + points[i].dx.toInt()*stepX;
      double y1 = getY(points[i].dy);
      double x2 = leftPadding + points[i+1].dx.toInt()*stepX;
      double y2 = getY(points[i+1].dy);
      path.cubicTo(x1+(x2-x1)/2, y1, x1+(x2-x1)/2, y2, x2, y2);
    }
    canvas.drawPath(path, lineP);

    Paint dotF = Paint()..style=PaintingStyle.fill;
    Paint dotS = Paint()..style=PaintingStyle.stroke..color=Colors.white..strokeWidth=2;
    for(var p in points) {
      double x = leftPadding + p.dx.toInt()*stepX;
      double y = getY(p.dy);
      dotF.color = moodColors[(p.dy-1).round().clamp(0,5)];
      canvas.drawCircle(Offset(x, y), 5, dotF);
      canvas.drawCircle(Offset(x, y), 5, dotS);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
