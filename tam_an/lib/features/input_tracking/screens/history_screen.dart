import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
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

  Widget _buildMoodLegend(ThemeData theme) {
    Widget legendItem(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          legendItem(AppColors.moodMad, 'Tức giận'),
          legendItem(AppColors.moodSad, 'Buồn'),
          legendItem(AppColors.moodAnxiety, 'Lo âu'),
          legendItem(AppColors.moodNeutral, 'Bình thường'),
          legendItem(AppColors.moodFun, 'Vui'),
          legendItem(AppColors.moodHappy, 'Hạnh phúc'),
        ],
      ),
    );
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Load user's check-in history to compute per-day mood summary
            _currentUserId == null
                ? _buildCalendar(theme, {})
                : StreamBuilder<List<CheckInModel>>(
                    stream: _checkInService.getCheckInHistory(_currentUserId!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return _buildCalendar(theme, {});

                      // Group by date and compute dominant mood per day
                      final Map<DateTime, Map<int, int>> countsByDate = {};
                      for (final item in snapshot.data!) {
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

                      return _buildCalendar(theme, dominantByDate);
                    }),
            const SizedBox(height: 20),
            _buildMoodLegend(theme),
            const SizedBox(height: 10),
            EmotionDonutChart(userId: _currentUserId, selectedDay: _selectedDay),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nhật ký ngày ${_selectedDay != null ? DateFormat('dd/MM').format(_selectedDay!) : ''}",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _currentUserId == null
                ? const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                  )
                : StreamBuilder<List<CheckInModel>>(
                    stream: _checkInService.getCheckInHistory(_currentUserId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                        );
                      }

                      if (snapshot.hasError) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Center(child: Text("Lỗi: ${snapshot.error}", style: TextStyle(color: theme.colorScheme.error))),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "Chưa có nhật ký nào.\nHãy check-in ngay!",
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                            ),
                          ),
                        );
                      }

                      List<CheckInModel> allHistory = snapshot.data!;
                      List<CheckInModel> dailyHistory = allHistory.where((item) {
                        return isSameDay(item.timestamp, _selectedDay);
                      }).toList();

                      if (dailyHistory.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text(
                              "Không có nhật ký trong ngày này.",
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4)),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dailyHistory.length,
                        itemBuilder: (context, index) {
                          final item = dailyHistory[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: _buildHistoryItem(item, theme),
                          );
                        },
                      );
                    },
                  ),
                  DailyEmotionSummary(userId: _currentUserId, selectedDay: _selectedDay),
                  const SizedBox(height: 20),
                
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(CheckInModel item, ThemeData theme) {
    Color moodColor;
    if (item.moodLevel == 6) moodColor = AppColors.moodHappy;
    else if (item.moodLevel == 5) moodColor = AppColors.moodFun;
    else if (item.moodLevel == 4) moodColor = AppColors.moodNeutral;
    else if (item.moodLevel == 3) moodColor = AppColors.moodAnxiety;
    else if (item.moodLevel == 2) moodColor = AppColors.moodSad;
    else moodColor = AppColors.moodMad;

    List<String> allTags = [
      if (item.location.isNotEmpty) item.location,
      ...item.activities,
      ...item.companions
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border(
          top: BorderSide(color: moodColor.withOpacity(0.8), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('HH:mm').format(item.timestamp),
                style: theme.textTheme.titleMedium,
              ),
              Text(
                item.moodLabel,
                style: TextStyle(
                  color: moodColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.note,
              style: theme.textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
            ),
          ],
          Divider(color: theme.dividerColor, height: 24),
          if (allTags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar(ThemeData theme, Map<DateTime, int> moodMap) {
    Color _colorForMood(int level) {
      if (level == 6) return AppColors.moodHappy;
      if (level == 5) return AppColors.moodFun;
      if (level == 4) return AppColors.moodNeutral;
      if (level == 3) return AppColors.moodAnxiety;
      if (level == 2) return AppColors.moodSad;
      return AppColors.moodMad;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
        child: TableCalendar(
        locale: 'en_US',
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        eventLoader: (day) {
          final d = DateTime(day.year, day.month, day.day);
          if (moodMap.containsKey(d)) return [moodMap[d]];
          return const [];
        },
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleMedium ?? const TextStyle(),
          leftChevronIcon: Icon(Icons.chevron_left, color: theme.iconTheme.color),
          rightChevronIcon: Icon(Icons.chevron_right, color: theme.iconTheme.color),
        ),
        calendarStyle: CalendarStyle(
          defaultTextStyle: TextStyle(color: theme.textTheme.bodyMedium?.color),
          weekendTextStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
          outsideTextStyle: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5)),
          selectedDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: const Border.fromBorderSide(BorderSide(color: AppColors.primaryBlue, width: 2)),
          ),
          selectedTextStyle: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
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
            final color = _colorForMood(lvl);
            return Container(
              margin: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Text('${day.day}', style: theme.textTheme.bodyMedium),
              ),
            );
          },
        ),
      ),
    );
  }
}
