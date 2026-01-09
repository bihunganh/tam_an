import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/checkin_model.dart';
import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CheckInService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm thêm Check-in mới (Đã nâng cấp logic Streak và Notification)
  Future<void> addNewCheckIn(CheckInModel checkIn) async {
    final userRef = _firestore.collection('users').doc(checkIn.userId);
    final checkInRef = userRef.collection('checkin_history').doc();

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) throw Exception("Người dùng không tồn tại!");

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      int currentTotal = userData['totalCheckins'] ?? 0;
      Map<String, dynamic> currentMoodCounts = userData['moodCounts'] ?? {};
      int currentStreak = userData['currentStreak'] ?? 0;

      // --- LOGIC TÍNH TOÁN STREAK MỚI ---
      DateTime now = DateTime.now();
      int newStreak = currentStreak;

      String? lastDateStr = userData['lastCheckInDate'];
      if (lastDateStr == null) {
        newStreak = 1; // Lần đầu tiên check-in
      } else {
        DateTime lastDate = DateTime.parse(lastDateStr);
        DateTime yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
        DateTime todayStart = DateTime(now.year, now.month, now.day);

        if (lastDate.isBefore(todayStart) && lastDate.isAfter(yesterday.subtract(const Duration(seconds: 1)))) {
          // Check-in vào ngày hôm sau của ngày cuối -> Tăng streak
          newStreak = currentStreak + 1;
        } else if (lastDate.isBefore(yesterday)) {
          // Đã quá 1 ngày không check-in -> Reset về 1
          newStreak = 1;
        }
        // Nếu đã check-in trong hôm nay rồi thì giữ nguyên streak không cộng thêm
      }

      // Cập nhật Mood Counts
      String moodLabel = checkIn.moodLabel;
      currentMoodCounts[moodLabel] = (currentMoodCounts[moodLabel] ?? 0) + 1;

      // THỰC HIỆN GHI DỮ LIỆU
      transaction.set(checkInRef, checkIn.toMap());
      transaction.update(userRef, {
        'totalCheckins': currentTotal + 1,
        'moodCounts': currentMoodCounts,
        'currentStreak': newStreak,
        'lastCheckInDate': now.toIso8601String(),
      });
    });

    // --- QUAN TRỌNG: HỦY THÔNG BÁO NHẮC 8H TỐI ---
    // Vì người dùng đã check-in rồi nên tối nay không cần nhắc nữa
    await FlutterLocalNotificationsPlugin().cancel(101);
  }

  // --- HÀM KIỂM TRA MẤT CHUỖI KHI MỞ APP ---
  Future<void> checkAndNotifyStreakLoss(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();

    if (!userDoc.exists) return;

    Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
    String? lastDateStr = userData['lastCheckInDate'];
    int currentStreak = userData['currentStreak'] ?? 0;

    if (lastDateStr != null && currentStreak > 0) {
      DateTime lastDate = DateTime.parse(lastDateStr);
      DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
      DateTime yesterdayStart = DateTime(yesterday.year, yesterday.month, yesterday.day);

      // Nếu ngày cuối check-in còn trước cả ngày hôm qua -> Đã mất chuỗi
      if (lastDate.isBefore(yesterdayStart)) {
        // 1. Gửi thông báo chia buồn
        await NotificationService().showStreakLostNotification();

        // 2. Reset chuỗi về 0 trên database
        await userRef.update({'currentStreak': 0});
      }
    }
  }

  Stream<List<CheckInModel>> getCheckInHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('checkin_history')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CheckInModel.fromMap(doc.data(), doc.id)).toList());
  }
}