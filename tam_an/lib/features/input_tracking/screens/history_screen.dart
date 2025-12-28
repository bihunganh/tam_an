import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../../core/services/checkin_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/checkin_model.dart';
import '../../../../data/models/user_model.dart';

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
    // 1. Dùng SingleChildScrollView bao bọc toàn bộ
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView( 
        child: Column(
          children: [
            // 1. Lịch
            _buildCalendar(),

            const SizedBox(height: 20),

            // 2. Tiêu đề danh sách
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nhật ký ngày ${_selectedDay != null ? DateFormat('dd/MM').format(_selectedDay!) : ''}",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 3. DANH SÁCH CHECK-IN
            // Bỏ Expanded đi vì đang nằm trong SingleChildScrollView
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
                          child: Center(child: Text("Lỗi: ${snapshot.error}", style: const TextStyle(color: Colors.red))),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 50),
                          child: Center(
                            child: Text("Chưa có nhật ký nào.\nHãy check-in ngay!", 
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white54)
                            ),
                          ),
                        );
                      }

                      List<CheckInModel> allHistory = snapshot.data!;
                      
                      List<CheckInModel> dailyHistory = allHistory.where((item) {
                        return isSameDay(item.timestamp, _selectedDay);
                      }).toList();

                      if (dailyHistory.isEmpty) {
                         return const Padding(
                           padding: EdgeInsets.only(top: 50),
                           child: Center(
                            child: Text("Không có nhật ký trong ngày này.", 
                              style: TextStyle(color: Colors.white30)
                            ),
                                                   ),
                         );
                      }

                      // 2. Cấu hình ListView để cuộn chung với màn hình
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 20),
                        shrinkWrap: true, // Quan trọng: Co lại vừa đủ nội dung
                        physics: const NeverScrollableScrollPhysics(), // Quan trọng: Tắt cuộn riêng
                        itemCount: dailyHistory.length,
                        itemBuilder: (context, index) {
                          final item = dailyHistory[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            child: _buildHistoryItem(item),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  // ... (Phần _buildHistoryItem và _buildCalendar giữ nguyên như code cũ của bạn)
  Widget _buildHistoryItem(CheckInModel item) {
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
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: moodColor.withOpacity(0.15),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
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
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                item.moodLabel,
                style: TextStyle(
                  color: moodColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: moodColor, blurRadius: 10)],
                ),
              ),
            ],
          ),
          
          if (item.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.note,
              style: const TextStyle(color: Colors.white70, fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],

          Divider(color: Colors.white.withOpacity(0.1), height: 24),
          
          if (allTags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allTags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        locale: 'en_US',
        firstDay: DateTime.utc(2020, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
        ),
        calendarStyle: const CalendarStyle(
          defaultTextStyle: TextStyle(color: Colors.white),
          weekendTextStyle: TextStyle(color: Colors.white70),
          outsideTextStyle: TextStyle(color: Colors.grey),
          selectedDecoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.fromBorderSide(BorderSide(color: AppColors.primaryBlue, width: 2)),
          ),
          selectedTextStyle: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
          todayDecoration: BoxDecoration(
            color: Colors.white10,
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
      ),
    );
  }
}