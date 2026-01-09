import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../../core/services/checkin_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/checkin_model.dart';
import '../../../../data/models/user_model.dart';
import '../widgets/history_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final CheckInService _checkInService = CheckInService();
  final AuthService _authService = AuthService();

  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _getUserId();
  }

  void _getUserId() async {
    UserModel? user = await _authService.getCurrentUser();
    if (mounted && user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Lấy theme hệ thống

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Tự động lấy trắng/đen
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calendar Section
            _currentUserId == null
                ? _buildCalendar(theme, {})
                : StreamBuilder<List<CheckInModel>>(
                stream: _checkInService.getCheckInHistory(_currentUserId!),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return _buildCalendar(theme, {});

                  final Map<DateTime, int> dominantByDate = _processDominantMoods(snapshot.data!);
                  return _buildCalendar(theme, dominantByDate);
                }),

            const SizedBox(height: 20),
            _buildMoodLegend(theme),
            const SizedBox(height: 10),
            EmotionDonutChart(userId: _currentUserId, selectedDay: _selectedDay),
            const SizedBox(height: 20),

            // Nhật ký header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nhật ký ngày ${_selectedDay != null ? DateFormat('dd/MM').format(_selectedDay!) : ''}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // History List Section
            _buildHistoryList(theme),

            DailyEmotionSummary(userId: _currentUserId, selectedDay: _selectedDay),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- LOGIC XỬ LÝ DỮ LIỆU ---
  Map<DateTime, int> _processDominantMoods(List<CheckInModel> logs) {
    final Map<DateTime, Map<int, int>> countsByDate = {};
    for (final item in logs) {
      final d = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      countsByDate.putIfAbsent(d, () => {});
      final m = countsByDate[d]!;
      m[item.moodLevel] = (m[item.moodLevel] ?? 0) + 1;
    }

    final Map<DateTime, int> dominantByDate = {};
    countsByDate.forEach((date, counts) {
      int dominant = counts.keys.first;
      int best = 0;
      counts.forEach((lvl, cnt) {
        if (cnt > best) {
          best = cnt;
          dominant = lvl;
        }
      });
      dominantByDate[date] = dominant;
    });
    return dominantByDate;
  }

  // --- WIDGET CẤU THÀNH ---
  Widget _buildCalendar(ThemeData theme, Map<DateTime, int> moodMap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Nền lịch tự đổi theo Theme
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(theme.brightness == Brightness.dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TableCalendar(
        locale: 'en_US',
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 17),
          leftChevronIcon: Icon(Icons.chevron_left, color: theme.iconTheme.color),
          rightChevronIcon: Icon(Icons.chevron_right, color: theme.iconTheme.color),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
          weekendTextStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
          outsideTextStyle: TextStyle(color: theme.disabledColor),
          // Sử dụng Primary Color (Xanh/Vàng) cho ngày được chọn
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.primary, width: 2),
          ),
          selectedTextStyle: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyle(color: theme.colorScheme.primary),
        ),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            final d = DateTime(day.year, day.month, day.day);
            final lvl = moodMap[d];
            if (lvl == null) return null;
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _getMoodColor(lvl), width: 3),
              ),
              child: Center(child: Text('${day.day}', style: theme.textTheme.bodyMedium)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistoryList(ThemeData theme) {
    if (_currentUserId == null) {
      return const Padding(padding: EdgeInsets.only(top: 50), child: CircularProgressIndicator());
    }
    return StreamBuilder<List<CheckInModel>>(
      stream: _checkInService.getCheckInHistory(_currentUserId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();

        List<CheckInModel> dailyHistory = snapshot.data!.where((item) => isSameDay(item.timestamp, _selectedDay)).toList();

        if (dailyHistory.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text("Không có nhật ký trong ngày này.", style: TextStyle(color: theme.disabledColor)),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dailyHistory.length,
          itemBuilder: (context, index) => _buildHistoryItem(dailyHistory[index], theme),
        );
      },
    );
  }

  Widget _buildHistoryItem(CheckInModel item, ThemeData theme) {
    Color moodColor = _getMoodColor(item.moodLevel);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // Tự động lấy màu trắng/xám đậm
        borderRadius: BorderRadius.circular(20),
        border: Border(top: BorderSide(color: moodColor.withOpacity(0.8), width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DateFormat('HH:mm').format(item.timestamp), style: theme.textTheme.titleMedium),
              Text(item.moodLabel, style: TextStyle(color: moodColor, fontWeight: FontWeight.bold)),
            ],
          ),
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(item.note, style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
          ],
          Divider(color: theme.dividerColor.withOpacity(0.1), height: 24),
          _buildTags(item, theme),
        ],
      ),
    );
  }

  Widget _buildTags(CheckInModel item, ThemeData theme) {
    List<String> tags = [if (item.location.isNotEmpty) item.location, ...item.activities, ...item.companions];
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: tags.map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
        child: Text(tag, style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
      )).toList(),
    );
  }

  Widget _buildMoodLegend(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _legendItem(AppColors.moodMad, 'Tức giận', theme),
          _legendItem(AppColors.moodSad, 'Buồn', theme),
          _legendItem(AppColors.moodAnxiety, 'Căng thẳng', theme),
          _legendItem(AppColors.moodNeutral, 'Bình thường', theme),
          _legendItem(AppColors.moodFun, 'Vui', theme),
          _legendItem(AppColors.moodHappy, 'Hạnh phúc', theme),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
      ]),
    );
  }

  Color _getMoodColor(int level) {
    switch (level) {
      case 6: return AppColors.moodHappy;
      case 5: return AppColors.moodFun;
      case 4: return AppColors.moodNeutral;
      case 3: return AppColors.moodAnxiety;
      case 2: return AppColors.moodSad;
      default: return AppColors.moodMad;
    }
  }
}