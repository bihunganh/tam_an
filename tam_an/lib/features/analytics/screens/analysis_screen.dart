import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

import '../../../core/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/checkin_model.dart';
import '../../../core/services/insight_service.dart';

// extracted widgets
import '../widgets/line_chart_card.dart';
import '../widgets/pie_chart_card.dart';
import '../widgets/insight_card.dart';
import '../widgets/stress_analysis_card.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = true;

  // --- GLOBAL STATE ---
  DateTime _selectedMonth = DateTime.now();

  // --- CHART STATE ---
  // Thêm tùy chọn 'Cả tháng' vào đây
  String _lineChartRange = '7 ngày cuối'; // Options: '7 ngày cuối', '14 ngày cuối', 'Cả tháng'

  // --- STRESS CAUSE STATE ---
  String _selectedStressCategory = 'Hành động';

  // --- DỮ LIỆU ---
  List<CheckInModel> _monthlyLogs = [];
  List<Offset> _lineChartPoints = [];
  List<String> _lineChartLabels = [];
  Map<int, int> _moodCounts = {};
  List<String> _aiInsights = [];

  Map<String, int> _negativeActivities = {};
  Map<String, int> _negativeLocations = {};
  Map<String, int> _negativeCompanions = {};

  final AuthService _authService = AuthService();
  final InsightService _insightService = InsightService();

  @override
  void initState() {
    super.initState();
    _fetchAndProcessData();
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset, 1);
      // Khi đổi tháng, reset lại view về mặc định hoặc giữ nguyên tùy ý (ở đây giữ nguyên)
      _fetchAndProcessData();
    });
  }

  Future<void> _fetchAndProcessData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    // 1. Lấy dữ liệu THÁNG (Tính toán ngày đầu và cuối tháng)
    DateTime startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    DateTime endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    // Nếu là tháng tương lai hoặc hiện tại, giới hạn lại đến thời điểm hiện tại
    if (endOfMonth.isAfter(DateTime.now())) {
      endOfMonth = DateTime.now();
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('checkin_history')
          .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
          .where('timestamp', isLessThanOrEqualTo: endOfMonth)
          .orderBy('timestamp', descending: true)
          .get();

      List<CheckInModel> allLogs = snapshot.docs.map((doc) => CheckInModel.fromMap(doc.data(), doc.id)).toList();
      _monthlyLogs = allLogs;

      // Xử lý các phần dữ liệu
      if (allLogs.isEmpty) {
        _aiInsights = ["Chưa có dữ liệu cho tháng này."];
      } else {
        _aiInsights = _insightService.generateInsights(allLogs);
      }

      _processLineChartData(endOfMonth); 
      _processPieChartData();
      _processStressCauses();

      if (mounted) setState(() => _isLoading = false);

    } catch (e) {
      print("❌ Lỗi Analysis: $e");
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // --- LOGIC XỬ LÝ BIỂU ĐỒ LINE (ĐÃ NÂNG CẤP) ---
  void _processLineChartData(DateTime currentMonthEndDate) {
    DateTime startDate;
    int daysToRender;

    // Logic xác định khoảng thời gian dựa trên Dropdown
    if (_lineChartRange == 'Cả tháng') {
      // Bắt đầu từ ngày 1
      startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      // Số ngày = khoảng cách từ ngày 1 đến ngày cuối (hoặc hôm nay)
      daysToRender = currentMonthEndDate.difference(startDate).inDays + 1;
    } else {
      // Logic cũ cho 7 và 14 ngày
      daysToRender = (_lineChartRange == '7 ngày cuối') ? 7 : 14;
      startDate = currentMonthEndDate.subtract(Duration(days: daysToRender - 1));
      // Reset giờ về 0h00 để tính toán khung cho chuẩn
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    }

    // Tạo khung dữ liệu (Map)
    Map<String, List<int>> groupedData = {};
    for (int i = 0; i < daysToRender; i++) {
      DateTime d = startDate.add(Duration(days: i));
      String key = DateFormat('d').format(d); // Key là ngày: "1", "2"...
      groupedData[key] = [];
    }

    // Đổ dữ liệu thật vào khung
    for (var log in _monthlyLogs) {
      // Chỉ lấy log nằm trong khoảng startDate -> currentMonthEndDate
      if (log.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1)))) {
        String key = DateFormat('d').format(log.timestamp.toLocal());
        if (groupedData.containsKey(key)) {
          groupedData[key]!.add(log.moodLevel);
        }
      }
    }

    // Chuyển đổi sang List<Offset> để vẽ
    List<Offset> points = [];
    List<String> labels = [];
    int index = 0;

    // Sort keys để đảm bảo vẽ đúng thứ tự từ trái qua phải (quan trọng cho chế độ Cả tháng)
    // Tuy nhiên vì ta tạo khung groupedData theo vòng lặp thời gian nên thứ tự insertion đã đúng rồi.
    groupedData.forEach((key, moods) {
      labels.add(key);
      if (moods.isNotEmpty) {
        double avg = moods.reduce((a, b) => a + b) / moods.length;
        points.add(Offset(index.toDouble(), avg));
      }
      index++;
    });

    _lineChartPoints = points;
    _lineChartLabels = labels;
  }

  void _processPieChartData() {
    _moodCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
    for (var log in _monthlyLogs) {
      int mood = log.moodLevel;
      if (mood >= 1 && mood <= 6) {
        _moodCounts[mood] = (_moodCounts[mood] ?? 0) + 1;
      }
    }
  }

  void _processStressCauses() {
    _negativeActivities.clear();
    _negativeLocations.clear();
    _negativeCompanions.clear();
    for (var log in _monthlyLogs) {
      if (log.moodLevel <= 2) {
        for (var item in log.activities) _negativeActivities[item] = (_negativeActivities[item] ?? 0) + 1;
        if (log.location.isNotEmpty) _negativeLocations[log.location] = (_negativeLocations[log.location] ?? 0) + 1;
        for (var item in log.companions) _negativeCompanions[item] = (_negativeCompanions[item] ?? 0) + 1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Dùng Scaffold để quản lý SafeArea tốt hơn
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // 1. COMPACT HEADER (Đã sửa cho gọn đẹp)
          _buildCompactMonthSelector(),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  // 2. LINE CHART (Có thêm 'Cả tháng')
                  _buildLineChartCard(),
                  const SizedBox(height: 20),

                  // 3. PIE CHART
                  if (_monthlyLogs.isNotEmpty) ...[
                    _buildPieChartCard(),
                    const SizedBox(height: 20),
                  ],

                  // 4. AI INSIGHT
                  _buildInsightCard(),
                  const SizedBox(height: 20),

                  // 5. STRESS ANALYSIS
                  if (_monthlyLogs.isNotEmpty)
                    _buildStressAnalysisCard(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HEADER MỚI (GỌN GÀNG HƠN) ---
  Widget _buildCompactMonthSelector() {
    String monthStr = DateFormat('MMMM, yyyy', 'vi_VN').format(_selectedMonth);
    monthStr = monthStr.replaceFirst(monthStr[0], monthStr[0].toUpperCase());

    return Container(
      color: const Color(0xFF202020), // Màu nền tối hơn background chút để tách biệt
      child: SafeArea( // Tự động tránh tai thỏ/status bar
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nút Previous nhỏ gọn
              InkWell(
                onTap: () => _changeMonth(-1),
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.chevron_left, color: Colors.white70, size: 28),
                ),
              ),

              // Text Tháng
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("THỐNG KÊ", style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 2),
                  Text(
                    monthStr,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Nút Next nhỏ gọn
              InkWell(
                onTap: DateTime(_selectedMonth.year, _selectedMonth.month + 1).isAfter(DateTime.now())
                    ? null
                    : () => _changeMonth(1),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                      Icons.chevron_right,
                      color: DateTime(_selectedMonth.year, _selectedMonth.month + 1).isAfter(DateTime.now())
                          ? Colors.white12
                          : Colors.white70,
                      size: 28
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineChartCard() {
    // Delegate to extracted widget; keep dropdown behaviour handled here via callback
    if (_monthlyLogs.isEmpty) return const SizedBox.shrink();
    return LineChartCard(
      points: _lineChartPoints,
      labels: _lineChartLabels,
      range: _lineChartRange,
      onRangeChanged: (r) {
        setState(() => _lineChartRange = r);
        DateTime endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);
        if (endOfMonth.isAfter(DateTime.now())) endOfMonth = DateTime.now();
        _processLineChartData(endOfMonth);
      },
    );
  }

  // ... (Các widget PieChart, Insight, StressAnalysis giữ nguyên như code trước) ...
  // Để code gọn, tôi sẽ copy lại các widget này ở dưới đây để bạn tiện copy-paste full file.

  Widget _buildPieChartCard() {
    return PieChartCard(moodCounts: _moodCounts);
  }

  Widget _buildLegendItem(int level, String label, Color color) {
    // kept for compatibility but now handled inside PieChartCard
    return const SizedBox.shrink();
  }

  Widget _buildInsightCard() {
    return InsightCard(insights: _aiInsights);
  }

  Widget _buildStressAnalysisCard() {
    return StressAnalysisCard(
      negativeActivities: _negativeActivities,
      negativeLocations: _negativeLocations,
      negativeCompanions: _negativeCompanions,
      selectedCategory: _selectedStressCategory,
      onCategoryChanged: (v) => setState(() => _selectedStressCategory = v),
    );
  }

  Widget _buildCategoryItem(String category, int percentage, Color barColor) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis)),
        Expanded(
          child: Stack(
            children: [
              Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF383838), borderRadius: BorderRadius.circular(4))),
              FractionallySizedBox(
                widthFactor: percentage / 100,
                child: Container(height: 8, decoration: BoxDecoration(color: barColor, borderRadius: BorderRadius.circular(4))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 35, child: Text('$percentage%', textAlign: TextAlign.right, style: const TextStyle(color: Colors.white54, fontSize: 12))),
      ],
    );
  }
}

// --- PAINTERS (Giữ nguyên) ---

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

    // Logic Anchor Points (Quan trọng cho chế độ Cả tháng)
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

        // Căn lề thông minh
        double textX = x - tp.width/2;
        if(i==0) textX = x;
        if(i==n-1) textX = x - tp.width;

        tp.paint(canvas, Offset(textX, h + 10));
      }
    }

    // Đường & Dot
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

class MoodPieChartPainter extends CustomPainter {
  final Map<int, int> moodCounts;
  final int total;
  MoodPieChartPainter({required this.moodCounts, required this.total});

  final List<Color> moodColors = [Colors.grey, AppColors.moodMad, AppColors.moodSad, AppColors.moodAnxiety, AppColors.moodNeutral, AppColors.moodFun, AppColors.moodHappy];

  @override
  void paint(Canvas canvas, Size size) {
    double radius = size.width / 2;
    Offset center = Offset(size.width / 2, size.height / 2);
    Rect rect = Rect.fromCircle(center: center, radius: radius);
    double startAngle = -math.pi / 2;

    Paint paint = Paint()..style = PaintingStyle.fill;
    for (int i = 6; i >= 1; i--) {
      int count = moodCounts[i] ?? 0;
      if (count > 0) {
        double sweepAngle = (count / total) * 2 * math.pi;
        paint.color = moodColors[i];
        canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
        Paint border = Paint()..color = const Color(0xFF2A2A2A)..style = PaintingStyle.stroke..strokeWidth = 2;
        canvas.drawArc(rect, startAngle, sweepAngle, true, border);
        startAngle += sweepAngle;
      }
    }
    Paint holePaint = Paint()..color = const Color(0xFF2A2A2A);
    canvas.drawCircle(center, radius * 0.5, holePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}