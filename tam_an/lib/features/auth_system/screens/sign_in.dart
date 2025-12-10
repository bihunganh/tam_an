import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main_screen.dart'; // Hoặc điều hướng thẳng vào MainScreen

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kích thước màn hình
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height - 50, // Trừ hao SafeArea
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // 1. Header: Logo & Icon User nhỏ góc phải
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'A n T â m',
                        style: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                        ),
                      ),
                      // Icon user nhỏ góc phải (theo thiết kế)
                      const Icon(Icons.person, color: Color(0xFFCCCCCC), size: 28),
                    ],
                  ),

                  const Spacer(), // Đẩy form xuống giữa màn hình

                  // 2. FORM ĐĂNG NHẬP (Dùng Stack để Avatar chồi lên)
                  Stack(
                    clipBehavior: Clip.none, // Quan trọng: Để Avatar không bị cắt khi nằm đè lên viền
                    alignment: Alignment.topCenter,
                    children: [
                      // --- LỚP DƯỚI: KHUNG CARD MÀU ĐEN ---
                      Container(
                        margin: const EdgeInsets.only(top: 50), // Chừa chỗ cho Avatar ở trên
                        padding: const EdgeInsets.fromLTRB(24, 70, 24, 24), // Padding top lớn để né Avatar
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A), // Màu nền Card tối hơn nền App
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
                          mainAxisSize: MainAxisSize.min, // Ôm sát nội dung
                          children: [
                            // Input Tên đăng nhập
                            _buildTextField(hint: "Tên Đăng Nhập"),
                            const SizedBox(height: 16),
                            
                            // Input Mật khẩu
                            _buildTextField(hint: "Mật Khẩu", isPassword: true),
                            const SizedBox(height: 24),

                            // Nút Đăng Nhập (Màu vàng)
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Giả lập đăng nhập thành công -> Vào MainScreen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MainScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryYellow,
                                  foregroundColor: Colors.black, // Màu chữ
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Đăng Nhập',
                                  style: TextStyle(
                                    fontSize: 18, 
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Nút Quay lại (Góc trái dưới của Card)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                icon: const Icon(Icons.undo, color: Colors.white70),
                                onPressed: () {
                                  Navigator.pop(context); // Quay lại màn hình trước
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- LỚP TRÊN: AVATAR TRÒN TO ---
                      Positioned(
                        top: 0, // Nằm hẳn lên trên cùng
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A), // Viền ngoài cùng màu với Card
                            shape: BoxShape.circle,
                            boxShadow: [
                              // Bóng mờ nhẹ để tách biệt
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(8), // Độ dày viền đen
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.primaryYellow, // Nền vàng bên trong
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF2A2A2A), // Icon người màu đen
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(flex: 2), // Khoảng trống dưới cùng
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget con: Ô nhập liệu (TextField)
  Widget _buildTextField({required String hint, bool isPassword = false}) {
    return TextField(
      obscureText: isPassword, // Ẩn chữ nếu là mật khẩu
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF353535), // Màu nền input
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        // Viền bo tròn
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.primaryYellow), // Focus thì viền vàng
        ),
      ),
    );
  }
}