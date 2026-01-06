import '../../../../data/models/checkin_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InsightService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<int> getLongestStreak() async {
    final user = _auth.currentUser;
    if (user == null) return 0;

    try {
      // --- SỬA LẠI ĐƯỜNG DẪN PATH ---
      // Phải tìm trong collection 'checkins' nơi chứa userId
      // Thay vì tìm trong users/{id}/check-ins
      final querySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('checkin_history') // Tên collection này phải khớp 100% với trong DB
          .orderBy('timestamp', descending: true) // Sắp xếp mới nhất trước
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("DEBUG: Không tìm thấy bản ghi check-in nào cho user này.");
        return 0;
      }

      print("DEBUG: Tìm thấy ${querySnapshot.docs.length} bản ghi.");

      // 2. Lấy list ngày (Chuẩn hóa về 00:00:00)
      // Lưu ý: Kiểm tra xem field trong DB của bạn tên là 'date' hay 'timestamp'
      // Ở các bước trước chúng ta lưu là 'timestamp'
      final checkinDates = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Kiểm tra field nào chứa ngày tháng
        Timestamp timestamp = data['timestamp'] ?? data['date'] ?? Timestamp.now();
        final date = timestamp.toDate();
        return DateTime(date.year, date.month, date.day);
      }).toList();

      // 3. Sắp xếp và loại trùng
      final uniqueDates = checkinDates.toSet().toList();
      uniqueDates.sort((a, b) => b.compareTo(a)); // Mới nhất trước

      if (uniqueDates.isEmpty) return 0;
      if (uniqueDates.length == 1) return 1;

      // 4. Thuật toán tính chuỗi (Logic của bạn đã đúng, giữ nguyên)
      int longestStreak = 1; // Ít nhất là 1 nếu list không rỗng
      int currentStreak = 1;

      for (int i = 0; i < uniqueDates.length - 1; i++) {
        DateTime today = uniqueDates[i];
        DateTime yesterday = uniqueDates[i + 1];

        // Tính khoảng cách ngày
        final difference = today.difference(yesterday).inDays;

        if (difference == 1) {
          // Liên tiếp
          currentStreak++;
        } else {
          // Đứt chuỗi -> Cập nhật max
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
          currentStreak = 1; // Reset
        }
      }

      // Check lần cuối sau khi hết vòng lặp
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      print("DEBUG: Chuỗi dài nhất tính được là: $longestStreak");
      return longestStreak;

    } catch (e) {
      print("Lỗi tính chuỗi ngày: $e");
      return 0;
    }
  }

  // Hàm chính: Nhận vào danh sách log -> Trả về danh sách các câu nhận định (Insights)
  List<String> generateInsights(List<CheckInModel> logs) {
    if (logs.isEmpty) return ["Chưa đủ dữ liệu để phân tích."];

    List<String> insights = [];

    // 1. PHÂN TÍCH TÁC NHÂN TIÊU CỰC (Nguyên nhân buồn)
    // Logic: Tìm tag xuất hiện nhiều nhất trong các lần mood <= 2
    String? badTrigger = _analyzeTagCorrelation(logs, isPositive: false);
    if (badTrigger != null) {
      insights.add("⚠️ Cảnh báo: Tâm An nhận thấy bạn thường cảm thấy không tốt khi liên quan đến **$badTrigger**. Hãy thử điều chỉnh xem sao nhé!");
    }

    // 2. PHÂN TÍCH TÁC NHÂN TÍCH CỰC (Liều thuốc tinh thần)
    // Logic: Tìm tag xuất hiện nhiều nhất trong các lần mood >= 4
    String? goodBooster = _analyzeTagCorrelation(logs, isPositive: true);
    if (goodBooster != null) {
      insights.add("💡 Mẹo nhỏ: Bạn có vẻ rất vui vẻ khi **$goodBooster**. Hãy dành nhiều thời gian hơn cho việc này!");
    }

    // 3. PHÂN TÍCH THỜI GIAN (Hội chứng "Sunday Blues" hoặc khung giờ xấu)
    String? badTime = _analyzeTimePattern(logs);
    if (badTime != null) {
      insights.add(badTime);
    }

    // 4. PHÂN TÍCH XU HƯỚNG (Trend)
    // So sánh trung bình mood 3 ngày gần nhất vs 3 ngày trước đó
    String? trend = _analyzeTrend(logs);
    if (trend != null) {
      insights.add(trend);
    }

    if (insights.isEmpty) {
      insights.add("Dữ liệu của bạn khá cân bằng, chưa có dấu hiệu bất thường.");
    }

    return insights;
  }

  // --- HÀM CON: TÌM TƯƠNG QUAN TAG ---
  String? _analyzeTagCorrelation(List<CheckInModel> logs, {required bool isPositive}) {
    Map<String, int> tagCounts = {};
    int countRelevantLogs = 0;

    for (var log in logs) {
      // Lọc log theo tiêu chí Vui hoặc Buồn
      bool condition = isPositive ? (log.moodLevel >= 4) : (log.moodLevel <= 2);

      if (condition) {
        countRelevantLogs++;
        // Gom tất cả các tag (Location, Activity, Companion) vào 1 rổ để đếm
        List<String> allTags = [
          if (log.location.isNotEmpty) "ở ${log.location}",
          ...log.activities.map((e) => "hoạt động $e"),
          ...log.companions.map((e) => "cùng $e")
        ];

        for (var tag in allTags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }
    }

    if (tagCounts.isEmpty) return null;

    // Tìm tag xuất hiện nhiều nhất
    var sortedEntries = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // Sắp xếp giảm dần

    var topEntry = sortedEntries.first;

    // QUY TẮC "THÔNG MINH":
    // Chỉ đưa ra nhận định nếu tag đó xuất hiện trong ít nhất 30% số lần check-in loại đó
    // Ví dụ: Buồn 10 lần, thì tag "Họp" phải xuất hiện ít nhất 3 lần mới đáng ngờ.
    if (countRelevantLogs >= 3 && (topEntry.value / countRelevantLogs) > 0.3) {
      int percentage = ((topEntry.value / countRelevantLogs) * 100).toInt();
      return "${topEntry.key} ($percentage% số lần)";
    }

    return null;
  }

  // --- HÀM CON: TÌM TƯƠNG QUAN THỜI GIAN ---
  String? _analyzeTimePattern(List<CheckInModel> logs) {
    // Đếm số lần buồn theo Thứ trong tuần
    Map<int, int> badDays = {}; // 1 (Mon) -> 7 (Sun)

    for (var log in logs) {
      if (log.moodLevel <= 2) {
        badDays[log.timestamp.weekday] = (badDays[log.timestamp.weekday] ?? 0) + 1;
      }
    }

    if (badDays.isEmpty) return null;

    var sortedDays = badDays.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    var topDay = sortedDays.first;

    // Nếu ngày xấu nhất chiếm > 40% tổng số lần buồn
    int totalBadLogs = badDays.values.reduce((a, b) => a + b);
    if (totalBadLogs >= 3 && (topDay.value / totalBadLogs) > 0.4) {
      String dayName = _getDayName(topDay.key);
      return "📅 Chu kỳ cảm xúc: Mức độ lo lắng của bạn thường tăng cao vào **$dayName**. Có chuyện gì xảy ra vào ngày này chăng?";
    }
    return null;
  }

  // --- HÀM CON: PHÂN TÍCH XU HƯỚNG ---
  String? _analyzeTrend(List<CheckInModel> logs) {
    if (logs.length < 5) return null;

    // Lấy 5 log gần nhất
    var recentLogs = logs.take(5).toList();
    // Lấy 5 log trước đó (nếu có)
    var previousLogs = logs.skip(5).take(5).toList();

    if (previousLogs.isEmpty) return null;

    double recentAvg = recentLogs.map((e) => e.moodLevel).reduce((a, b) => a + b) / recentLogs.length;
    double prevAvg = previousLogs.map((e) => e.moodLevel).reduce((a, b) => a + b) / previousLogs.length;

    double diff = recentAvg - prevAvg;

    if (diff >= 1.0) {
      return "📈 Tin vui: Tâm trạng của bạn đang có xu hướng **cải thiện rõ rệt** trong vài ngày qua!";
    } else if (diff <= -1.0) {
      return "📉 Lưu ý: Tâm trạng của bạn đang **đi xuống** so với trước. Hãy dành thời gian nghỉ ngơi nhé.";
    }

    return null;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return "Thứ Hai";
      case 2: return "Thứ Ba";
      case 3: return "Thứ Tư";
      case 4: return "Thứ Năm";
      case 5: return "Thứ Sáu";
      case 6: return "Thứ Bảy";
      case 7: return "Chủ Nhật";
      default: return "";
    }
  }
}