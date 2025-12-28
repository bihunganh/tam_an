import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
// Đã xóa import custom_app_bar

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  // Danh sách thời gian lọc
  final List<String> timeRanges = ['7 ngày qua', '14 ngày qua', '30 ngày qua'];
  String selectedTimeRange = '7 ngày qua';

  // Dữ liệu tâm trạng
  final List<double> moodData = [6.0, 4.5, 5.5, 3.5, 5.0, 4.0, 6.5];
  final List<String> dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    // --- SỬA LẠI: Dùng Container thay vì Scaffold ---
    return Container(
      color: AppColors.background,
      // Bỏ SafeArea vì MainScreen đã có
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với tiêu đề
            const Text(
              'Thống kê',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Card chứa biểu đồ
            _buildChartCard(),
            const SizedBox(height: 20),

            // Card chứa tip và suggestion
            _buildTipCard(),
            const SizedBox(height: 20),

            // Tiêu đề "Người dùng..."
            const Text(
              'NGƯỜI DÙNG NHẠNG HÀNG HÀNG ĐẦU',
              style: TextStyle(
                color: Color(0xFF999999),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),

            // Danh sách các hạng mục
              _buildCategoryItem('Công việc', 80, AppColors.moodMad),
            const SizedBox(height: 16),
              _buildCategoryItem('Code', 60, AppColors.moodSad),
            const SizedBox(height: 16),
              _buildCategoryItem('Học bài', 40, AppColors.moodHappy),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- Các Widget con giữ nguyên logic ---

  Widget _buildChartCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Phân Tích',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF383838),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DropdownButton<String>(
                  value: selectedTimeRange,
                  dropdownColor: const Color(0xFF4A4A4A),
                  underline: const SizedBox(),
                  items: timeRanges.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTimeRange = newValue ?? '7 ngày qua';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLineChart(),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    double chartHeight = 180;
    double chartWidth = MediaQuery.of(context).size.width - 80;
    double maxValue = 7.0;

    List<Offset> points = [];
    for (int i = 0; i < moodData.length; i++) {
      double x = (chartWidth / (moodData.length - 1)) * i;
      double y = chartHeight - (moodData[i] / maxValue * chartHeight);
      points.add(Offset(x, y));
    }

    return Column(
      children: [
        Container(
          height: chartHeight + 40,
          color: const Color(0xFF383838),
          padding: const EdgeInsets.only(left: 40, right: 10, top: 10, bottom: 30),
          child: CustomPaint(
            painter: LineChartPainter(
              points: points,
              chartHeight: chartHeight,
              chartWidth: chartWidth,
            ),
            size: Size(chartWidth, chartHeight),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40, right: 10, top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayLabels
                .map((day) => Text(
                      day,
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 11,
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4A4A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb,
              color: Color(0xFF383838),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tâm ích nhân hiểu',
                  style: TextStyle(
                        color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Bạn thường xuyên cảm thấy căng thẳng vào các buổi học\nHãy thả lỏng cơ thể.',
                  style: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String category, int percentage, Color barColor) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            category,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFF383838),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 35,
          child: Text(
            '$percentage%',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF999999),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

// --- Custom Painter giữ nguyên ---
class LineChartPainter extends CustomPainter {
  final List<Offset> points;
  final double chartHeight;
  final double chartWidth;

  LineChartPainter({
    required this.points,
    required this.chartHeight,
    required this.chartWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final gridPaint = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 6; i++) {
      double y = (chartHeight / 6) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(chartWidth, y),
        gridPaint,
      );
    }

    final linePaint = Paint()
      ..color = AppColors.primaryBlue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], linePaint);
    }

    final dotPaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, dotPaint);
    }

    final ringPaint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final point in points) {
      canvas.drawCircle(point, 7, ringPaint);
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) => false;
}