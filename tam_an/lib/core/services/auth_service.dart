import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
// Import file Model (Đường dẫn này phải chuẩn với dự án của bạn)
import '../../data/models/user_model.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HÀM ĐĂNG KÝ (ĐÃ CẬP NHẬT THÊM AVATAR) ---
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required String dob,
    required String gender,
    Uint8List? avatarBytes,
  }) async {
    try {
      // 1. Tạo tài khoản Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) return "Lỗi không xác định";

      String? avatarUrl;
      if (avatarBytes != null) {
        try {
          final ref = FirebaseStorage.instance.ref().child('avatars/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
          await ref.putData(avatarBytes, SettableMetadata(contentType: 'image/jpeg'));
          avatarUrl = await ref.getDownloadURL();
        } catch (e) {
          // nếu upload thất bại thì bỏ qua avatar nhưng không fail toàn bộ đăng ký
          avatarUrl = null;
        }
      }

      // 2. Tạo đối tượng UserModel chuẩn chỉnh
      UserModel newUser = UserModel(
        uid: user.uid,
        email: email,
        username: username,
        dob: dob,
        gender: gender,
        avatarUrl: avatarUrl, // nếu null thì không có avatar
        // Các trường thống kê sẽ tự động lấy giá trị mặc định là 0
      );

      // 3. Đẩy lên Firestore
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

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

  // --- HÀM ĐĂNG NHẬP (Giữ nguyên) ---
  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Người dùng không tồn tại.';
      if (e.code == 'wrong-password') return 'Mật khẩu không đúng.';
      if (e.code == 'invalid-credential') return 'Email hoặc Mật khẩu không đúng.';
      if (e.code == 'invalid-email') return 'Định dạng email không đúng.';
      if (e.code == 'too-many-requests') return 'Đăng nhập sai quá nhiều lần. Hãy thử lại sau.';
      return e.message;
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }

  // --- LẤY THÔNG TIN USER HIỆN TẠI (Giữ nguyên) ---
  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Lỗi lấy user: $e");
      return null;
    }
  }

  // --- HÀM ĐĂNG XUẤT (Giữ nguyên) ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- CẬP NHẬT AVATAR CHO NGƯỜI DÙNG HIỆN TẠI ---
  Future<String?> updateAvatar(String base64) async {
    // Deprecated: keep for backward compatibility but do nothing
    return 'Không hỗ trợ cập nhật avatar bằng base64 nữa. Vui lòng dùng bytes.';
  }

  // Upload avatar bytes to Firebase Storage and update Firestore with the download URL
  Future<String?> updateAvatarFromBytes(Uint8List bytes) async {
    final user = _auth.currentUser;
    if (user == null) return 'Người dùng chưa đăng nhập';
    try {
      final ref = FirebaseStorage.instance.ref().child('avatars/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      await _firestore.collection('users').doc(user.uid).update({'avatarUrl': url});
      return null;
    } catch (e) {
      return 'Lỗi cập nhật avatar: $e';
    }
  }

  // --- CẬP NHẬT THÔNG TIN HỒ SƠ (username, email) ---
  Future<String?> updateProfile({String? username, String? email}) async {
    final user = _auth.currentUser;
    if (user == null) return 'Người dùng chưa đăng nhập';
    try {
      // Nếu thay đổi email, cố gắng cập nhật trong FirebaseAuth nếu API khả dụng.
      bool authEmailUpdated = false;
      if (email != null && email.isNotEmpty && email != user.email) {
        try {
          final dynUser = user as dynamic;
          // Kiểm tra xem method có tồn tại và không null trước khi gọi
          final updateFn = dynUser.updateEmail;
          if (updateFn != null) {
            await dynUser.updateEmail(email);
            authEmailUpdated = true;
          } else {
            // Method không tồn tại trên phiên bản này
            authEmailUpdated = false;
          }
        } on NoSuchMethodError {
          // Không hỗ trợ updateEmail trên runtime/phiên bản hiện tại
          authEmailUpdated = false;
        }
      }

      final Map<String, dynamic> data = {};
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;

      if (data.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(data);
      }

      // Nếu email đã được thay đổi ở Firestore nhưng không thể cập nhật trong FirebaseAuth,
      // trả về thông báo cảnh báo để UI hiển thị (không coi là lỗi fatal).
      if (email != null && email.isNotEmpty && email != user.email && !authEmailUpdated) {
        return 'Email được cập nhật trong hồ sơ nhưng không thể cập nhật trong hệ thống xác thực trên nền tảng này. Vui lòng đăng nhập lại hoặc thay đổi email từ trang quản lý tài khoản.';
      }

      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') return 'Vui lòng đăng nhập lại trước khi thay đổi email.';
      return e.message;
    } catch (e) {
      return 'Lỗi cập nhật profile: $e';
    }
  }
}