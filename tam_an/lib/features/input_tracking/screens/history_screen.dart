import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
// Đã xóa import custom_app_bar vì không cần dùng nữa

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    // --- SỬA LẠI: Dùng Container thay vì Scaffold ---
    return Container(
      color: AppColors.background,
      // Bỏ SafeArea luôn vì MainScreen đã lo việc đó
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          // 2. Lịch
          _buildCalendar(),

          const SizedBox(height: 20),

          // 3. Tiêu đề danh sách
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Nhật ký ngày ${_selectedDay?.day}",
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 16, 
                fontWeight: FontWeight.bold
              ),
            ),
          ),

          const SizedBox(height: 10),

          // 4. Danh sách Nhật ký
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHistoryItem(
              time: "14:30",
              mood: "Căng Thẳng",
              moodColor: AppColors.moodCangThang,
              tags: ["Công ty", "Họp", "Đồng nghiệp"],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHistoryItem(
              time: "18:00",
              mood: "Tức giận",
              moodColor: AppColors.moodGianDu,
              tags: ["Ở Nhà", "Code", "Một Mình"],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildHistoryItem(
              time: "20:00",
              mood: "Vui vẻ",
              moodColor: AppColors.moodVui,
              tags: ["Ăn tối", "Gia đình"],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Con: Lịch (Giữ nguyên) ---
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
            border: Border.fromBorderSide(BorderSide(color: AppColors.primaryYellow, width: 2)),
          ),
          selectedTextStyle: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.bold),
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

  // --- Widget Con: Thẻ Nhật Ký (Giữ nguyên) ---
  Widget _buildHistoryItem({
    required String time,
    required String mood,
    required Color moodColor,
    required List<String> tags,
  }) {
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
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 4),
            blurRadius: 5,
          )
        ],
        border: Border(
          top: BorderSide(color: moodColor.withOpacity(0.8), width: 2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Text(
                mood,
                style: TextStyle(
                  color: moodColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: moodColor, blurRadius: 10),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: Colors.white.withOpacity(0.1), height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: tags.map((tag) => Container(
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
}