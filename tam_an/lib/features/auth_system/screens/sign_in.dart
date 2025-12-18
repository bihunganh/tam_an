import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart'; // Import Service
import '../../../../main_screen.dart'; 
import '../../input_tracking/widgets/custom_app_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controller để lấy dữ liệu nhập
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Hàm xử lý Đăng Nhập
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập Email và Mật khẩu")),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu cần trên 6 kí tự"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; 
    }


    // Hiện Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryYellow),
      ),
    );

    // Gọi Service
    final authService = AuthService();
    String? error = await authService.signIn(email: email, password: password);

    // Tắt Loading
    if (context.mounted) Navigator.pop(context);

    if (error == null) {
      // THÀNH CÔNG -> Vào màn hình chính
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen(showLoginSuccess: true)),
        );
      }
    } else {
      // THẤT BẠI -> Hiện lỗi
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height - 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const Spacer(),

                  // FORM ĐĂNG NHẬP
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // --- CARD ---
                      Container(
                        margin: const EdgeInsets.only(top: 50),
                        padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
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
                            // Input Email (Đã sửa từ username sang email cho đúng chuẩn Firebase)
                            _buildTextField(
                              controller: _emailController,
                              hint: "Email",
                              icon: Icons.email_outlined
                            ),
                            const SizedBox(height: 16),
                            
                            // Input Mật khẩu
                            _buildTextField(
                              controller: _passwordController,
                              hint: "Mật Khẩu", 
                              isPassword: true,
                              icon: Icons.lock_outline
                            ),
                            const SizedBox(height: 24),

                            // Nút Đăng Nhập
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _handleLogin, // Gọi hàm xử lý
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryYellow,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Đăng Nhập',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Nút Quay lại
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.undo, color: Colors.white70),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- AVATAR ---
                      Positioned(
                        top: 0,
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
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primaryYellow,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    bool isPassword = false,
    IconData? icon,
  }) {
    return TextField(
      controller: controller, // Gắn controller
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white38, size: 20) : null,
        filled: true,
        fillColor: const Color(0xFF353535),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
}