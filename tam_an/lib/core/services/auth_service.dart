import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- 1. ĐĂNG KÝ (SIGN UP) ---
  // Đảm bảo: Tạo Auth -> Upload Ảnh -> Lưu Firestore rồi mới kết thúc
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required String dob,
    required String gender,
    Uint8List? avatarBytes,
  }) async {
    try {
      // B1: Tạo User trên Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) return "Không thể tạo tài khoản trên hệ thống.";

      String? avatarUrl;

      // B2: Upload ảnh đại diện nếu người dùng có chọn
      if (avatarBytes != null) {
        try {
          // Lưu tên file theo UID để dễ quản lý
          final ref = _storage.ref().child('avatars/${user.uid}.jpg');
          await ref.putData(
              avatarBytes,
              SettableMetadata(contentType: 'image/jpeg')
          );
          avatarUrl = await ref.getDownloadURL();
        } catch (e) {
          debugPrint("Lỗi upload ảnh (vẫn tiếp tục đăng ký): $e");
        }
      }

      // B3: Tạo dữ liệu UserModel
      UserModel newUser = UserModel(
        uid: user.uid,
        email: email,
        username: username,
        dob: dob,
        gender: gender,
        avatarUrl: avatarUrl,
      );

      // B4: Lưu vào Firestore - QUAN TRỌNG: Phải await để đảm bảo dữ liệu đã vào DB
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'Mật khẩu của bạn quá yếu.';
      if (e.code == 'email-already-in-use') return 'Email này đã được đăng ký tài khoản.';
      if (e.code == 'invalid-email') return 'Định dạng email không hợp lệ.';
      return e.message;
    } catch (e) {
      return "Lỗi hệ thống không xác định: $e";
    }
  }

  // --- 2. ĐĂNG NHẬP (SIGN IN) ---
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Email hoặc mật khẩu không chính xác.';
      }
      return e.message;
    } catch (e) {
      return "Lỗi đăng nhập: $e";
    }
  }

  // --- 3. ĐĂNG XUẤT (SIGN OUT) ---
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Lỗi đăng xuất: $e");
    }
  }

  // --- 4. LẤY THÔNG TIN USER TỪ FIRESTORE ---
  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint("Lỗi lấy dữ liệu người dùng: $e");
    }
    return null;
  }

  // --- 5. UPLOAD ẢNH (Dùng cho cả Đăng ký và Sửa hồ sơ) ---
  Future<String?> uploadImageToStorage(Uint8List bytes) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final String fileName = 'avatars/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Lỗi khi upload ảnh lên Storage: $e");
      rethrow;
    }
  }

  // --- 6. CẬP NHẬT HỒ SƠ TRÊN FIRESTORE ---
  Future<String?> updateProfile({String? username, String? avatarUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return 'Bạn cần đăng nhập để thực hiện.';

    try {
      final Map<String, dynamic> dataToUpdate = {};
      if (username != null && username.isNotEmpty) dataToUpdate['username'] = username;
      if (avatarUrl != null && avatarUrl.isNotEmpty) dataToUpdate['avatarUrl'] = avatarUrl;

      if (dataToUpdate.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(dataToUpdate);
      }
      return null;
    } catch (e) {
      return 'Không thể cập nhật hồ sơ: $e';
    }
  }
}