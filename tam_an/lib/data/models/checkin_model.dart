import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInModel {
  final String id;             // ID riêng của mỗi lần check-in
  final String userId;         // Của người dùng nào
  final DateTime timestamp;    // Thời gian check-in
  
  // --- CẢM XÚC ---
  final int moodLevel;         // Mức độ (1-5) để tính toán trung bình
  final String moodLabel;      // Nhãn ("Vui", "Buồn", "Bình thường"...)
  
  // --- CHI TIẾT (Phần bạn vừa yêu cầu thêm) ---
  final String note;           // Ghi chú nhật ký
  final String location;       // Địa điểm ("Nhà", "Trường học"...)
  final List<String> companions; // Ở cùng ai ("Một mình", "Gia đình", "Bạn bè"...)
  final List<String> activities; // Hoạt động ("Học tập", "Ngủ", "Ăn uống"...)

  CheckInModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.moodLevel,
    required this.moodLabel,
    this.note = '',           // Mặc định rỗng nếu người dùng lười ghi
    this.location = '',       // Mặc định rỗng
    this.companions = const [], // Mặc định danh sách trống
    this.activities = const [],
  });

  // 1. Chuyển đổi dữ liệu từ Firebase về App (Load lịch sử)
  factory CheckInModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CheckInModel(
      id: documentId,
      userId: data['userId'] ?? '',
      // Xử lý ngày tháng từ Firebase (Timestamp) về DateTime của Flutter
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      moodLevel: data['moodLevel'] ?? 3,
      moodLabel: data['moodLabel'] ?? '',
      note: data['note'] ?? '',
      location: data['location'] ?? '',
      // Ép kiểu về List<String> an toàn để tránh lỗi
      companions: List<String>.from(data['companions'] ?? []),
      activities: List<String>.from(data['activities'] ?? []),
    );
  }

  // 2. Đóng gói dữ liệu từ App để đẩy lên Firebase (Lưu check-in)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'timestamp': timestamp, // Firebase tự hiểu kiểu DateTime
      'moodLevel': moodLevel,
      'moodLabel': moodLabel,
      'note': note,
      'location': location,
      'companions': companions,
      'activities': activities,
    };
  }
}