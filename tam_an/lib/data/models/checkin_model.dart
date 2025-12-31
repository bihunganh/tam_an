import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInModel {
  final String id;
  final String userId;
  final DateTime timestamp;

  // --- CẢM XÚC ---
  final int moodLevel;
  final String moodLabel;

  // --- CHI TIẾT ---
  final String note;
  final String location;
  final List<String> companions;
  final List<String> activities;

  CheckInModel({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.moodLevel,
    required this.moodLabel,
    this.note = '',
    this.location = '',
    this.companions = const [],
    this.activities = const [],
  });

  // 1. Chuyển đổi dữ liệu từ Firebase về App (Load lịch sử)
  // --- PHIÊN BẢN NÂNG CẤP AN TOÀN ---
  factory CheckInModel.fromMap(Map<String, dynamic> data, String documentId) {

    // Xử lý thông minh cho Timestamp: Nhận cả String và Timestamp
    DateTime date;
    try {
      if (data['timestamp'] is Timestamp) {
        // Trường hợp chuẩn: Dữ liệu từ Firebase
        date = (data['timestamp'] as Timestamp).toDate();
      } else if (data['timestamp'] is String) {
        // Trường hợp dự phòng: Dữ liệu cũ hoặc chuỗi ISO 8601
        date = DateTime.parse(data['timestamp']);
      } else {
        // Trường hợp lỗi: Lấy giờ hiện tại để không crash app
        date = DateTime.now();
      }
    } catch (e) {
      date = DateTime.now();
    }

    return CheckInModel(
      id: documentId,
      userId: data['userId'] ?? '',
      timestamp: date, // Đã xử lý an toàn ở trên
      moodLevel: data['moodLevel'] ?? 3,
      moodLabel: data['moodLabel'] ?? '',
      note: data['note'] ?? '',
      location: data['location'] ?? '',
      companions: List<String>.from(data['companions'] ?? []),
      activities: List<String>.from(data['activities'] ?? []),
    );
  }

  // 2. Đóng gói dữ liệu từ App để đẩy lên Firebase (Lưu check-in)
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      // Ép kiểu rõ ràng thành Timestamp để Firebase lưu đúng định dạng đồng hồ
      'timestamp': Timestamp.fromDate(timestamp),
      'moodLevel': moodLevel,
      'moodLabel': moodLabel,
      'note': note,
      'location': location,
      'companions': companions,
      'activities': activities,
    };
  }
}