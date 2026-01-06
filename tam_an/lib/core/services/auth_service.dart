import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
// Hãy đảm bảo đường dẫn import Model này đúng với dự án của bạn
import '../../data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- 1. ĐĂNG KÝ (SIGN UP) ---
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required String dob,
    required String gender,
    Uint8List? avatarBytes,
  }) async {
    try {
      // Tạo User Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) return "Lỗi không xác định khi tạo tài khoản.";

      String? avatarUrl;

      // Nếu có chọn ảnh -> Upload lên Storage
      if (avatarBytes != null) {
        try {
          final ref = _storage.ref().child('avatars/${user.uid}_${DateTime
              .now()
              .millisecondsSinceEpoch}.jpg');
          await ref.putData(
              avatarBytes, SettableMetadata(contentType: 'image/jpeg'));
          avatarUrl = await ref.getDownloadURL();
        } catch (e) {
          print("Lỗi upload avatar lúc đăng ký: $e");
          // Nếu lỗi upload ảnh, vẫn cho đăng ký thành công nhưng không có avatar
          avatarUrl = null;
        }
      }

      // Tạo Model User
      UserModel newUser = UserModel(
        uid: user.uid,
        email: email,
        username: username,
        dob: dob,
        gender: gender,
        avatarUrl: avatarUrl,
        // Các chỉ số khác model tự khởi tạo default
      );

      // Lưu vào Firestore
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());

      return null; // Trả về null nghĩa là thành công
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return 'Mật khẩu quá yếu (cần > 6 ký tự)';
      if (e.code == 'email-already-in-use') return 'Email này đã được sử dụng';
      if (e.code == 'invalid-email') return 'Email không hợp lệ';
      return e.message;
    } catch (e) {
      return "Lỗi hệ thống: $e";
    }
  }

  // --- 2. ĐĂNG NHẬP (SIGN IN) ---
  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        return 'Tài khoản hoặc mật khẩu không chính xác.';
      }
      if (e.code == 'wrong-password') return 'Mật khẩu không đúng.';
      if (e.code == 'invalid-email') return 'Định dạng email không đúng.';
      if (e.code == 'too-many-requests')
        return 'Bạn đã thử quá nhiều lần. Hãy đợi một chút.';
      return e.message;
    } catch (e) {
      return "Lỗi đăng nhập: $e";
    }
  }

  // --- 3. ĐĂNG XUẤT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- 4. LẤY USER HIỆN TẠI ---
  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(
          firebaseUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print("Lỗi lấy thông tin user: $e");
      return null;
    }
  }

  // --- 5. CẬP NHẬT AVATAR TỪ BYTES (QUAN TRỌNG) ---
  Future<String?> updateAvatarFromBytes(Uint8List bytes) async {
    final user = _auth.currentUser;
    if (user == null) return 'Vui lòng đăng nhập lại.';

    try {
      // A. Thử xóa ảnh cũ trên Storage để tiết kiệm dung lượng (Optional)
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final oldUrl = doc.data()?['avatarUrl'] as String?;
          // Chỉ xóa nếu đó là link của Firebase Storage
          if (oldUrl != null &&
              oldUrl.contains('firebasestorage.googleapis.com')) {
            await _storage.refFromURL(oldUrl).delete();
          }
        }
      } catch (e) {
        print("Không xóa được ảnh cũ (không sao, tiếp tục): $e");
      }

      // B. Upload ảnh mới
      final String fileName = 'avatars/${user.uid}_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      // Upload kèm Metadata để browser hiểu đây là ảnh JPEG
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

      // Lấy URL public
      final String newUrl = await ref.getDownloadURL();

      // C. Cập nhật Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'avatarUrl': newUrl
      });

      return null; // Thành công
    } catch (e) {
      print("Lỗi updateAvatarFromBytes: $e");
      return 'Lỗi khi tải ảnh lên: $e';
    }
  }

// --- A. HÀM CHỈ UPLOAD ẢNH LÊN STORAGE (KHÔNG LƯU VÀO FIRESTORE) ---
  Future<String?> uploadImageToStorage(Uint8List bytes) async {
    final user = _auth.currentUser;
    if (user == null) return null; // Hoặc throw error tùy logic

    try {
      // 1. Tạo tên file
      final String fileName = 'avatars/${user.uid}_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child(fileName);

      // 2. Upload với Metadata
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));

      // 3. Lấy và trả về URL
      return await ref.getDownloadURL();
    } catch (e) {
      print("Lỗi upload ảnh: $e");
      throw e; // Ném lỗi để bên màn hình bắt được
    }
  }

  // --- B. CẬP NHẬT PROFILE (HỖ TRỢ CẢ TÊN, EMAIL VÀ AVATAR URL) ---
  Future<String?> updateProfile(
      {String? username, String? email, String? avatarUrl}) async {
    final user = _auth.currentUser;
    if (user == null) return 'Người dùng chưa đăng nhập';

    try {
      final Map<String, dynamic> dataToUpdate = {};

      if (username != null && username.isNotEmpty)
        dataToUpdate['username'] = username;
      if (avatarUrl != null && avatarUrl.isNotEmpty)
        dataToUpdate['avatarUrl'] = avatarUrl;

      // Logic email giữ nguyên
      if (email != null && email.isNotEmpty && email != user.email) {
        dataToUpdate['email'] = email;
        // ... code xử lý verify email cũ ...
      }

      if (dataToUpdate.isNotEmpty) {
        await _firestore.collection('users').doc(user.uid).update(dataToUpdate);
      }

      return null; // Thành công
    } catch (e) {
      return 'Lỗi cập nhật hồ sơ: $e';
    }
  }
}