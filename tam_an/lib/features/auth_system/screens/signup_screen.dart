import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import để format ngày tháng
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import 'sign_in.dart'; // Import màn hình Login
import '../../input_tracking/widgets/custom_app_bar.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. Khởi tạo các Controller để lấy dữ liệu nhập vào
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _dobController = TextEditingController(); // Controller cho ngày sinh

  // 2. Biến lưu giới tính đang chọn (Mặc định là Nam)
  String _selectedGender = "Nam";

  // Avatar bytes + base64 để lưu lên Firestore
  Uint8List? _avatarBytes;
  String? _avatarBase64;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(source: source, maxWidth: 800, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _avatarBytes = bytes;
        _avatarBase64 = base64Encode(bytes);
      });
    } catch (e) {
      // Không block, chỉ log
      // ignore: avoid_print
      print('Error picking image: $e');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primaryYellow),
              title: const Text('Chọn từ thư viện', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primaryYellow),
              title: const Text('Chụp ảnh', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 3. Hàm hiển thị lịch để chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Mặc định lùi về 18 năm trước
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Custom màu cho lịch (Theme tối)
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryYellow, // Màu chọn
              onPrimary: Colors.black, // Chữ trên màu chọn
              surface: Color(0xFF2A2A2A), // Nền lịch
              onSurface: Colors.white, // Chữ ngày tháng
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format ngày thành dạng dd/MM/yyyy
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kích thước màn hình
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            // Bỏ height cố định để tránh lỗi overflow khi bàn phím hiện lên
            // height: size.height - 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const SizedBox(height: 32), // Khoảng cách tới form
                  // 2. FORM ĐĂNG KÝ (Stack)
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // --- LỚP DƯỚI: KHUNG CARD MÀU ĐEN ---
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Tên tài khoản
                            _buildTextField(
                              controller: _usernameController,
                              hint: "Tên tài khoản",
                              icon: Icons.person_outline,
                            ),
                            const SizedBox(height: 16),

                            // Email
                            _buildTextField(
                              controller: _emailController,
                              hint: "Email",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),

                            // Mật khẩu
                            _buildTextField(
                              controller: _passwordController,
                              hint: "Mật khẩu",
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 16),

                            // Xác nhận mật khẩu
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hint: "Nhập lại mật khẩu",
                              icon: Icons.lock_reset,
                              isPassword: true,
                            ),
                            const SizedBox(height: 16),

                            // Ngày sinh (ReadOnly - Bấm vào hiện lịch)
                            _buildTextField(
                              controller: _dobController,
                              hint: "Ngày/Tháng/Năm sinh",
                              icon: Icons.calendar_today,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                            ),
                            const SizedBox(height: 16),

                            // Giới tính (Custom Radio Row)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Giới tính:",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildGenderOption("Nam"),
                                _buildGenderOption("Nữ"),
                                _buildGenderOption("Khác"),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // Nút Đăng Ký
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  // 1. Lấy dữ liệu từ ô nhập
                                  final email = _emailController.text.trim();
                                  final password = _passwordController.text
                                      .trim();
                                  final confirmPass = _confirmPasswordController
                                      .text
                                      .trim();
                                  final username = _usernameController.text
                                      .trim();
                                  final dob = _dobController.text.trim();

                                  // 2. Kiểm tra lỗi nhập liệu (Validate)
                                  if (email.isEmpty ||
                                      password.isEmpty ||
                                      username.isEmpty ||
                                      dob.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Vui lòng nhập đầy đủ thông tin",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (password != confirmPass) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Mật khẩu xác nhận không khớp",
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // 3. Hiện vòng tròn xoay (Loading)
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => const Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primaryYellow,
                                      ),
                                    ),
                                  );

                                  // 4. Gọi Service Đăng Ký
                                  final authService = AuthService();
                                  String? error = await authService.signUp(
                                    email: email,
                                    password: password,
                                    username: username,
                                    dob: dob,
                                    gender: _selectedGender,
                                    avatarBytes: _avatarBytes,
                                  );

                                  // 5. Tắt vòng tròn loading
                                  if (context.mounted) Navigator.pop(context);

                                  // 6. Xử lý Kết quả
                                  if (error == null) {
                                    // ---> THÀNH CÔNG: HIỆN HỘP THOẠI THÔNG BÁO <---
                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible:
                                            false, // Bắt buộc phải bấm nút mới đóng được
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor: const Color(
                                              0xFF303030,
                                            ), // Màu nền tối trùng với App
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              side: const BorderSide(
                                                color: Colors.white10,
                                              ),
                                            ),
                                            title: const Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color:
                                                      AppColors.primaryYellow,
                                                ),
                                                SizedBox(width: 10),
                                                Text(
                                                  "Thành công!",
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primaryYellow,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: const Text(
                                              "Tài khoản của bạn đã được tạo thành công.\nHãy đăng nhập để bắt đầu sử dụng nhé!",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 16,
                                              ),
                                            ),
                                            actions: [
                                              // Nút: ĐẾN ĐĂNG NHẬP
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                    ); // Đóng hộp thoại
                                                    // Chuyển sang màn hình Login
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const LoginScreen(),
                                                      ),
                                                    );
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.primaryYellow,
                                                    foregroundColor:
                                                        Colors.black,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Đến Đăng Nhập Ngay",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  } else {
                                    // -> THẤT BẠI: Hiện lỗi đỏ bên dưới
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(error),
                                          backgroundColor: Colors.redAccent,
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryYellow,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Đăng Ký',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Nút "Đã có tài khoản?"
                            TextButton(
                              onPressed: () {
                                // Điều hướng về màn hình Login
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(color: Colors.white70),
                                  children: [
                                    TextSpan(text: 'Đã có tài khoản? '),
                                    TextSpan(
                                      text: 'Đăng nhập ngay',
                                      style: TextStyle(
                                        color: AppColors.primaryYellow,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- LỚP TRÊN: AVATAR TRÒN TO ---
                      Positioned(
                        top: 0,
                        child: GestureDetector(
                          onTap: _showImageSourceSheet,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.primaryYellow,
                                shape: BoxShape.circle,
                              ),
                              child: _avatarBytes != null
                                  ? CircleAvatar(
                                      radius: 40,
                                      backgroundColor: AppColors.primaryYellow,
                                      backgroundImage: MemoryImage(_avatarBytes!),
                                    )
                                  : const Icon(
                                      Icons.person_add_alt_1, // Icon khác login một chút
                                      size: 50,
                                      color: Color(0xFF2A2A2A),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40), // Khoảng trống dưới cùng
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget con: Ô nhập liệu (Đã nâng cấp)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: Icon(
          icon,
          color: Colors.white38,
          size: 20,
        ), // Thêm icon bên trái
        filled: true,
        fillColor: const Color(0xFF353535),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primaryYellow),
        ),
      ),
    );
  }

  // Widget con: Nút chọn giới tính
  Widget _buildGenderOption(String value) {
    final bool isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryYellow : const Color(0xFF353535),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryYellow : Colors.white24,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
