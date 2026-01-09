import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../main_screen.dart'; 
import '../../../../core/navigation/app_router.dart';
import '../../input_tracking/widgets/custom_app_bar.dart';
import 'signup_screen.dart'; 
import 'package:provider/provider.dart';
import '../../../../core/providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Hàm điều hướng về Home (Dùng chung cho cả Logo và Nút Back)
  void _navigateToHome() {
    AppRouter.pushAndRemoveUntil(context, const MainScreen(showNavBar: false));
  }

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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primaryBlue),
      ),
    );

    final authService = AuthService();
    String? error = await authService.signIn(email: email, password: password);

    if (context.mounted) Navigator.pop(context);

      if (error == null) {
      if (context.mounted) {
          // Load current user into provider so UI updates (avatar, profile, logout)
          try {
            Provider.of<UserProvider>(context, listen: false).loadUser();
          } catch (_) {}

          AppRouter.pushReplacement(context, const MainScreen(showLoginSuccess: true));
      }
    } else {
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
      
      // 1. SỬA APPBAR: Truyền hàm quay về Home vào onLogoTap
      appBar: CustomAppBar(
        onLogoTap: _navigateToHome,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            // Đảm bảo chiều cao tối thiểu để không bị lỗi layout khi bàn phím hiện
            height: size.height - 80, 
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // 2. NÚT BACK CHUYÊN NGHIỆP HƠN (Đặt ở góc trái trên)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _navigateToHome,
                      icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white70),
                      label: const Text(
                        "Về trang chủ",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),

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
                            _buildTextField(
                              controller: _emailController,
                              hint: "Email",
                              icon: Icons.email_outlined
                            ),
                            const SizedBox(height: 16),
                            
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
                                onPressed: _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
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
                            
                            // Đã xóa nút Undo cũ ở đây đi
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
                              color: AppColors.primaryBlue,
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
                  
                  const SizedBox(height: 20),

                  // 3. THÊM DÒNG: "CHƯA CÓ TÀI KHOẢN? ĐĂNG KÝ"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Bạn chưa có tài khoản? ",
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Chuyển sang màn hình Đăng ký
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: const Text(
                          "Đăng ký ngay",
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 3),
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
      controller: controller,
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
          borderSide: const BorderSide(color: AppColors.primaryBlue),
        ),
      ),
    );
  }
}