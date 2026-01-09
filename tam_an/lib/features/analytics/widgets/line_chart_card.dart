import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../../core/constants/app_colors.dart';

class LineChartCard extends StatelessWidget {
  final List<Offset> points;
  final List<String> labels;
  final String range;
  final ValueChanged<String> onRangeChanged;

  const LineChartCard({
    Key? key,
    required this.points,
    required this.labels,
    required this.range,
    required this.onRangeChanged
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20), // Tăng bo góc cho hiện đại
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: isDark ? null : Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  'Biến thiên cảm xúc',
                  style: TextStyle(
                      color: theme.textTheme.titleMedium?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold
                  )
              ),

              // Dropdown Menu Tối ưu hóa
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF383838) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10)
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: range,
                    dropdownColor: theme.colorScheme.surface,
                    icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.primary, size: 18),
                    style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600
                    ),
                    items: ['7 ngày cuối', '14 ngày cuối', 'Cả tháng'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) onRangeChanged(newValue);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: CustomPaint(
              // Truyền theme vào Painter để xử lý màu lưới và màu chữ
              painter: SixColorChartPainter(
                  points: points,
                  labels: labels,
                  theme: theme
              ),
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
  final ThemeData theme;

  SixColorChartPainter({
    required this.points,
    required this.labels,
    required this.theme
  });

  final List<Color> moodColors = [
    AppColors.moodMad,
    AppColors.moodSad,
    AppColors.moodAnxiety,
    AppColors.moodNeutral,
    AppColors.moodFun,
    AppColors.moodHappy
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = theme.brightness == Brightness.dark;
    double leftPadding = 25.0;
    double bottomPadding = 30.0;
    double w = size.width - leftPadding;
    double h = size.height - bottomPadding;
    int n = labels.length;
    double stepX = n > 1 ? w / (n - 1) : w;

    // 1. Dải màu tâm trạng bên trái (Thanh Sidebar màu)
    double segH = h / 6;
    Paint barP = Paint()..style = PaintingStyle.fill;
    for(int i=0; i<6; i++) {
      barP.color = moodColors[5-i].withOpacity(0.8);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(0, i*segH+2, 6, segH-4),
              const Radius.circular(3)
          ),
          barP
      );
    }

    // 2. Vẽ lưới và nhãn ngày tháng
    Paint gridP = Paint()
      ..color = isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)
      ..strokeWidth = 1;

    TextPainter tp = TextPainter(textDirection: ui.TextDirection.ltr);

    List<int> idxs = [];
    if(n <= 7) idxs = List.generate(n, (i)=>i);
    else {
      idxs.addAll([0, (n * 0.25).round(), (n * 0.5).round(), (n * 0.75).round(), n-1]);
      idxs = idxs.toSet().toList()..sort();
    }

    for(int i=0; i<n; i++) {
      double x = leftPadding + i*stepX;
      // Vẽ đường lưới dọc mờ
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridP);

      if(idxs.contains(i) && i < labels.length) {
        tp.text = TextSpan(
            text: labels[i],
            style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold
            )
        );
        tp.layout();

        double textX = x - tp.width/2;
        if(i==0) textX = x;
        if(i==n-1) textX = x - tp.width;

        tp.paint(canvas, Offset(textX, h + 10));
      }
    }

    // 3. Vẽ đường biểu đồ chính
    if(points.isEmpty) return;

    // Màu đường line lấy theo màu Primary của Theme (Xanh hoặc Vàng)
    Paint lineP = Paint()
      ..color = theme.colorScheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    double getY(double v) => h - ((v.clamp(1.0, 6.0)-1)/5 * h);

    // Bắt đầu vẽ đường cong mượt (Bezier Curve)
    path.moveTo(leftPadding + points[0].dx.toInt()*stepX, getY(points[0].dy));

    for(int i=0; i<points.length-1; i++) {
      double x1 = leftPadding + points[i].dx.toInt()*stepX;
      double y1 = getY(points[i].dy);
      double x2 = leftPadding + points[i+1].dx.toInt()*stepX;
      double y2 = getY(points[i+1].dy);
      path.cubicTo(x1+(x2-x1)/2, y1, x1+(x2-x1)/2, y2, x2, y2);
    }
    canvas.drawPath(path, lineP);

    // 4. Vẽ các điểm tròn (Dots) tại mỗi mốc dữ liệu
    Paint dotF = Paint()..style = PaintingStyle.fill;
    Paint dotS = Paint()
      ..style = PaintingStyle.stroke
      ..color = theme.scaffoldBackgroundColor
      ..strokeWidth = 2;

    for(var p in points) {
      double x = leftPadding + p.dx.toInt()*stepX;
      double y = getY(p.dy);

      // Màu điểm tròn tương ứng với tâm trạng
      dotF.color = moodColors[(p.dy-1).round().clamp(0,5)];

      canvas.drawCircle(Offset(x, y), 5, dotF);
      canvas.drawCircle(Offset(x, y), 6, dotS); // Viền trắng bao quanh điểm để tách biệt với đường line
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}