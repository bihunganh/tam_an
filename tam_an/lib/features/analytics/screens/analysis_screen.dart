import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/checkin_model.dart';
import '../../../core/services/insight_service.dart';
import '../../../../core/providers/theme_provider.dart'; // Import ThemeProvider

// Extracted widgets
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
  DateTime _selectedMonth = DateTime.now();
  String _lineChartRange = '7 ngày cuối';
  String _selectedStressCategory = 'Hành động';

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
      _fetchAndProcessData();
    });
  }

  Future<void> _fetchAndProcessData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    DateTime startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    DateTime endOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    if (endOfMonth.isAfter(DateTime.now())) endOfMonth = DateTime.now();

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
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _processLineChartData(DateTime currentMonthEndDate) {
    DateTime startDate;
    int daysToRender;

    if (_lineChartRange == 'Cả tháng') {
      startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
      daysToRender = currentMonthEndDate.difference(startDate).inDays + 1;
    } else {
      daysToRender = (_lineChartRange == '7 ngày cuối') ? 7 : 14;
      startDate = currentMonthEndDate.subtract(Duration(days: daysToRender - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    }

    Map<String, List<int>> groupedData = {};
    for (int i = 0; i < daysToRender; i++) {
      DateTime d = startDate.add(Duration(days: i));
      String key = DateFormat('d').format(d);
      groupedData[key] = [];
    }

    for (var log in _monthlyLogs) {
      if (log.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1)))) {
        String key = DateFormat('d').format(log.timestamp.toLocal());
        if (groupedData.containsKey(key)) {
          groupedData[key]!.add(log.moodLevel);
        }
      }
    }

    List<Offset> points = [];
    List<String> labels = [];
    int index = 0;

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
    final theme = Theme.of(context); //

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, //
      body: Column(
        children: [
          _buildCompactMonthSelector(theme), // Truyền theme vào header

          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)) //
                : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  _buildLineChartCard(),
                  const SizedBox(height: 20),

                  if (_monthlyLogs.isNotEmpty) ...[
                    _buildPieChartCard(),
                    const SizedBox(height: 20),
                  ],

                  _buildInsightCard(),
                  const SizedBox(height: 20),

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

  Widget _buildCompactMonthSelector(ThemeData theme) {
    String monthStr = DateFormat('MMMM, yyyy', 'vi_VN').format(_selectedMonth);
    monthStr = monthStr.replaceFirst(monthStr[0], monthStr[0].toUpperCase());

    return Container(
      // Màu nền header nhạt hơn một chút để tạo chiều sâu
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF1E1E1E)
          : Colors.grey[100],
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () => _changeMonth(-1),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.chevron_left, color: theme.iconTheme.color, size: 28), //
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("THỐNG KÊ", style: TextStyle(color: theme.colorScheme.primary.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 2),
                  Text(
                    monthStr,
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16, fontWeight: FontWeight.bold), //
                  ),
                ],
              ),

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
                          ? theme.disabledColor
                          : theme.iconTheme.color,
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

  Widget _buildPieChartCard() {
    return PieChartCard(moodCounts: _moodCounts);
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
}

// --- PAINTERS CẬP NHẬT THEME ---

class SixColorChartPainter extends CustomPainter {
  final List<Offset> points;
  final List<String> labels;
  final ThemeData theme; // Nhận theme từ widget chính

  SixColorChartPainter({required this.points, required this.labels, required this.theme});

  final List<Color> moodColors = [AppColors.moodMad, AppColors.moodSad, AppColors.moodAnxiety, AppColors.moodNeutral, AppColors.moodFun, AppColors.moodHappy];

  @override
  void paint(Canvas canvas, Size size) {
    double leftPadding = 20.0; double bottomPadding = 30.0;
    double w = size.width - leftPadding; double h = size.height - bottomPadding;
    int n = labels.length;
    double stepX = n > 1 ? w / (n - 1) : w;

    double segH = h / 6;
    Paint barP = Paint()..style = PaintingStyle.fill;
    for(int i=0; i<6; i++) {
      barP.color = moodColors[5-i];
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, i*segH+2, 6, segH-4), const Radius.circular(3)), barP);
    }

    // Cập nhật màu lưới theo Theme
    Paint gridP = Paint()..color = theme.dividerColor.withOpacity(0.1)..strokeWidth = 1;
    TextPainter tp = TextPainter(textDirection: ui.TextDirection.ltr);

    List<int> idxs = [];
    if(n <= 7) idxs = List.generate(n, (i)=>i);
    else {
      idxs.addAll([0, (n * 0.25).round(), (n * 0.5).round(), (n * 0.75).round(), n-1]);
      idxs = idxs.toSet().toList()..sort();
    }

    for(int i=0; i<n; i++) {
      double x = leftPadding + i*stepX;
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridP);
      if(idxs.contains(i) && i < labels.length) {
        // Cập nhật màu chữ nhãn biểu đồ
        tp.text = TextSpan(text: labels[i], style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 10));
        tp.layout();
        double textX = x - tp.width/2;
        if(i==0) textX = x;
        if(i==n-1) textX = x - tp.width;
        tp.paint(canvas, Offset(textX, h + 10));
      }
    }

    if(points.isEmpty) return;
    // Cập nhật màu đường biểu đồ
    Paint lineP = Paint()..color = theme.colorScheme.primary..strokeWidth=2..style=PaintingStyle.stroke;
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
    Paint dotS = Paint()..style=PaintingStyle.stroke..color=theme.scaffoldBackgroundColor..strokeWidth=2;
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
  final ThemeData theme; // Nhận theme để xử lý màu nền tâm biểu đồ

  MoodPieChartPainter({required this.moodCounts, required this.total, required this.theme});

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
        // Viền giữa các miếng bánh
        Paint border = Paint()..color = theme.colorScheme.surface..style = PaintingStyle.stroke..strokeWidth = 2;
        canvas.drawArc(rect, startAngle, sweepAngle, true, border);
        startAngle += sweepAngle;
      }
    }
    // Lỗ hổng tâm biểu đồ tròn lấy theo màu Surface của theme
    Paint holePaint = Paint()..color = theme.colorScheme.surface;
    canvas.drawCircle(center, radius * 0.5, holePaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}