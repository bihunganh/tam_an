import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import file Model vừa tạo (Nhớ kiểm tra đường dẫn đúng với máy bạn)
import '../../data/models/user_model.dart'; 

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- HÀM ĐĂNG KÝ (Đã nâng cấp) ---
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
    required String dob,
    required String gender,
  }) async {
    try {
      // 1. Tạo tài khoản Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user == null) return "Lỗi không xác định";

      // 2. Tạo đối tượng UserModel chuẩn chỉnh
      UserModel newUser = UserModel(
        uid: user.uid,
        email: email,
        username: username,
        dob: dob,
        gender: gender,
        // Các trường thống kê sẽ tự động lấy giá trị mặc định là 0 và rỗng
      );

      // 3. Đẩy lên Firestore bằng hàm .toMap()
      // set() sẽ tạo mới hoặc ghi đè document có ID là user.uid
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
  // --- LẤY THÔNG TIN USER HIỆN TẠI ---
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

  // --- HÀM ĐĂNG XUẤT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }
}