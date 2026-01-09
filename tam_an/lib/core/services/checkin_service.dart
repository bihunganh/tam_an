import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/checkin_model.dart';

class CheckInService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hàm thêm Check-in mới
  Future<void> addNewCheckIn(CheckInModel checkIn) async {
    final userRef = _firestore.collection('users').doc(checkIn.userId);
    final checkInRef = userRef.collection('checkin_history').doc(); // Tự sinh ID mới

    // Sử dụng Transaction để đảm bảo tính toàn vẹn dữ liệu
    // (Hoặc lưu cả 2 hoặc không lưu cái nào nếu lỗi)
    await _firestore.runTransaction((transaction) async {
      // 1. Đọc dữ liệu User hiện tại để lấy thống kê cũ
      DocumentSnapshot userSnapshot = await transaction.get(userRef);
      
      if (!userSnapshot.exists) {
        throw Exception("Người dùng không tồn tại!");
      }

      Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

      // Lấy các chỉ số cũ (nếu chưa có thì mặc định là 0 hoặc rỗng)
      int currentTotal = userData['totalCheckins'] ?? 0;
      Map<String, dynamic> currentMoodCounts = userData['moodCounts'] ?? {};
      int currentStreak = userData['currentStreak'] ?? 0;
      
      // --- XỬ LÝ LOGIC TÍNH TOÁN MỚI ---
      
      // a. Tăng tổng số lần check-in
      int newTotal = currentTotal + 1;

      // b. Cập nhật số lượng từng loại cảm xúc
      // VD: "Vui": 5 -> "Vui": 6
      String moodLabel = checkIn.moodLabel;
      if (currentMoodCounts.containsKey(moodLabel)) {
        currentMoodCounts[moodLabel] = currentMoodCounts[moodLabel] + 1;
      } else {
        currentMoodCounts[moodLabel] = 1;
      }

      // c. Tính Streak (Chuỗi ngày liên tục) - Logic đơn giản
      // (Để đơn giản cho đồ án, ta cứ tăng streak lên 1 mỗi lần check-in, 
      // nếu muốn xịn hơn phải so sánh ngày check-in cuối cùng)
      int newStreak = currentStreak + 1; 

      // 2. GHI DỮ LIỆU (WRITE)
      
      // a. Lưu check-in chi tiết vào sub-collection (kèm ID vừa sinh)
      // Lưu ý: checkInRef.id là ID tự sinh của Firestore
      transaction.set(checkInRef, checkIn.toMap()); 

      // b. Cập nhật thống kê vào User Profile
      transaction.update(userRef, {
        'totalCheckins': newTotal,
        'moodCounts': currentMoodCounts,
        'currentStreak': newStreak,
        'lastCheckInDate': DateTime.now().toIso8601String(), // Lưu lại ngày giờ check-in cuối
      });
    });
  }
  
  // Hàm lấy danh sách lịch sử check-in (Stream - Tự động cập nhật)
  Stream<List<CheckInModel>> getCheckInHistory(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('checkin_history')
        .orderBy('timestamp', descending: true) // Mới nhất lên đầu
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        // Gọi hàm fromMap trong Model để chuyển đổi
        return CheckInModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}