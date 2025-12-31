class UserModel {
  final String uid;
  final String email;
  final String username;
  final String dob;
  final String gender;
  final String? avatarUrl;

  // --- PHẦN THỐNG KÊ (Statistic) ---
  final int totalCheckins;
  final int currentStreak;
  final Map<String, int> moodCounts;

  final List<String> locationTags;
  final List<String> activityTags;
  final List<String> companionTags;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.dob,
    required this.gender,
    this.avatarUrl,
    this.locationTags = const [],
    this.activityTags = const [],
    this.companionTags = const [],
    this.totalCheckins = 0,
    this.currentStreak = 0,
    this.moodCounts = const {},
  });

  // Chuyển từ Firebase về Object Dart
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      username: data['username'] ?? 'Người dùng',
      dob: data['dob'] ?? '',
      gender: data['gender'] ?? 'Khác',
      avatarUrl: data['avatarUrl'],
      locationTags: List<String>.from(data['locationTags'] ?? []),
      activityTags: List<String>.from(data['activityTags'] ?? []),
      companionTags: List<String>.from(data['companionTags'] ?? []),
      totalCheckins: data['totalCheckins'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      moodCounts: Map<String, int>.from(data['moodCounts'] ?? {}),
    );
  }

  // Chuyển từ Object Dart thành JSON để đẩy lên Firebase
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'dob': dob,
      'gender': gender,
      'avatarUrl': avatarUrl,
      'locationTags': locationTags,
      'activityTags': activityTags,
      'companionTags': companionTags,
      'totalCheckins': totalCheckins,
      'currentStreak': currentStreak,
      'moodCounts': moodCounts,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? dob,
    String? gender,
    String? avatarUrl,
    List<String>? locationTags,
    List<String>? activityTags,
    List<String>? companionTags,
    int? totalCheckins,
    int? currentStreak,
    Map<String, int>? moodCounts,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      locationTags: locationTags ?? this.locationTags,
      activityTags: activityTags ?? this.activityTags,
      companionTags: companionTags ?? this.companionTags,
      totalCheckins: totalCheckins ?? this.totalCheckins,
      currentStreak: currentStreak ?? this.currentStreak,
      moodCounts: moodCounts ?? this.moodCounts,
    );
  }
}