import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // --- KHỞI TẠO (QUAN TRỌNG: Không được xóa đoạn này) ---
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HÀM 1: ĐĂNG KÝ ---
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required String dob,
    required String gender,
  }) async {
    try {
      // Tạo user trên Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) return "Lỗi không xác định";

      // Lưu thông tin phụ vào Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'username': username,
        'email': email,
        'dob': dob,
        'gender': gender,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'Mật khẩu quá yếu (cần > 6 ký tự)';
      if (e.code == 'email-already-in-use') return 'Email này đã được đăng ký rồi';
      if (e.code == 'invalid-email') return 'Email không hợp lệ';
      return e.message;
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }

  // --- HÀM 2: ĐĂNG NHẬP 
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Thành công
    } on FirebaseAuthException catch (e) {
      // Dịch lỗi sang tiếng Việt
      if (e.code == 'user-not-found') return 'Email này chưa được đăng ký.';
      if (e.code == 'wrong-password') return 'Sai mật khẩu.';
      if (e.code == 'invalid-email') return 'Định dạng email không đúng.';
      if (e.code == 'invalid-credential') return 'Email hoặc mật khẩu không đúng.'; // Lỗi mới của Firebase
      if (e.code == 'too-many-requests') return 'Đăng nhập sai quá nhiều lần. Hãy thử lại sau.';
      return e.message;
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }
}